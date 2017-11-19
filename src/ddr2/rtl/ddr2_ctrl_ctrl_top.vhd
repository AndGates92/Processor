library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library common_rtl_pkg;
use common_rtl_pkg.functions_pkg.all;
library ddr2_rtl_pkg;
use ddr2_rtl_pkg.ddr2_ctrl_pkg.all;
use ddr2_rtl_pkg.ddr2_mrs_max_pkg.all;
use ddr2_rtl_pkg.ddr2_ctrl_arbiter_top_pkg.all;
use ddr2_rtl_pkg.ddr2_ctrl_ref_ctrl_pkg.all;
use ddr2_rtl_pkg.ddr2_ctrl_mrs_ctrl_pkg.all;
use ddr2_rtl_pkg.ddr2_ctrl_odt_ctrl_pkg.all;
use ddr2_rtl_pkg.ddr2_ctrl_cmd_ctrl_pkg.all;
use ddr2_rtl_pkg.ddr2_gen_ac_timing_pkg.all;

entity ddr2_ctrl_ctrl_top is
generic (
	BANK_CTRL_NUM		: positive := 8;
	COL_CTRL_NUM		: positive := 1;
	BURST_LENGTH_L		: positive := 5;
	BANK_NUM		: positive := 8;
	COL_L			: positive := 10;
	ROW_L			: positive := 13;
	MRS_REG_L		: positive := 13;
	MAX_OUTSTANDING_BURSTS	: positive := 10
);
port (
	rst		: in std_logic;
	clk		: in std_logic;

	-- MRS configuration
	DDR2CASLatency			: in std_logic_vector(int_to_bit_num(CAS_LATENCY_MAX_VALUE) - 1 downto 0);
	DDR2BurstLength			: in std_logic_vector(int_to_bit_num(BURST_LENGTH_MAX_VALUE) - 1 downto 0);
	DDR2AdditiveLatency		: in std_logic_vector(int_to_bit_num(AL_MAX_VALUE) - 1 downto 0);
	DDR2WriteLatency		: in std_logic_vector(int_to_bit_num(WRITE_LATENCY_MAX_VALUE) - 1 downto 0);
	DDR2HighTemperatureRefresh	: in std_logic;

	-- Column Controller
	-- Controller
	ColCtrlCtrlReq		: in std_logic_vector(COL_CTRL_NUM - 1 downto 0);
	ColCtrlReadBurstIn	: in std_logic_vector(COL_CTRL_NUM - 1 downto 0);
	ColCtrlColMemIn		: in std_logic_vector(COL_CTRL_NUM*COL_L - 1 downto 0);
	ColCtrlBankMemIn	: in std_logic_vector(COL_CTRL_NUM*(int_to_bit_num(BANK_NUM)) - 1 downto 0);
	ColCtrlBurstLength	: in std_logic_vector(COL_CTRL_NUM*BURST_LENGTH_L - 1 downto 0);

	ColCtrlCtrlAck		: out std_logic_vector(COL_CTRL_NUM - 1 downto 0);

	-- Bank Controllers
	-- Transaction Controller
	BankCtrlRowMemIn	: in std_logic_vector(BANK_CTRL_NUM*ROW_L - 1 downto 0);
	BankCtrlCtrlReq		: in std_logic_vector(BANK_CTRL_NUM - 1 downto 0);

	BankCtrlCtrlAck		: out std_logic_vector(BANK_CTRL_NUM - 1 downto 0);

	-- MRS Controller
	-- Transaction Controller
	MRSCtrlCtrlReq			: in std_logic;
	MRSCtrlCtrlCmd			: in std_logic_vector(MEM_CMD_L - 1 downto 0);
	MRSCtrlCtrlData			: in std_logic_vector(MRS_REG_L - 1 downto 0);

	MRSCtrlCtrlAck			: out std_logic;
	MRSCtrlMRSReq			: out std_logic;

	-- Refresh Controller
	-- Transaction Controller
	RefCtrlRefreshReq		: out std_logic;
	RefCtrlNonReadOpEnable		: out std_logic;
	RefCtrlReadOpEnable		: out std_logic;

	-- PHY Init
	PhyInitCompleted		: in std_logic;

	-- Controller
	RefCtrlCtrlReq			: in std_logic;

	RefCtrlCtrlAck			: out std_logic;

	-- ODT Controller
	-- ODT
	ODT				: out std_logic;

	-- Arbiter
	-- Command Decoder
	CmdDecColMem			: out std_logic_vector(COL_L - 1 downto 0);
	CmdDecRowMem			: out std_logic_vector(ROW_L - 1 downto 0);
	CmdDecBankMem			: out std_logic_vector(int_to_bit_num(BANK_NUM) - 1 downto 0);
	CmdDecCmdMem			: out std_logic_vector(MEM_CMD_L - 1 downto 0);
	CmdDecMRSCmd			: out std_logic_vector(MRS_REG_L - 1 downto 0)

);
end entity ddr2_ctrl_ctrl_top;

architecture rtl of ddr2_ctrl_ctrl_top is

	constant ZERO_BANK_IDLE_VEC	: std_logic_vector(BANK_CTRL_NUM - 1 downto 0) := (others => '0'); 

	-- Bank Status
	signal BankIdleVec		: std_logic_vector(BANK_CTRL_NUM - 1 downto 0);

	signal NoBankColCmd		: std_logic;

	-- Refresh Controller
	-- ODT Controller
	signal RefCtrlRefCmdAccepted	: std_logic;

	signal RefCtrlODTCtrlAck	: std_logic;

	signal RefCtrlODTCtrlReq	: std_logic;

	-- Arbitrer
	signal RefCtrlCmdAck		: std_logic;

	signal RefCtrlCmd		: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal RefCtrlCmdReq		: std_logic;

	-- ODT Controller
	-- Command sent to memory
	signal ODTCtrlCmd		: std_logic_vector(MEM_CMD_L - 1 downto 0);

	-- Stop Arbiter
	signal ODTCtrlPauseArbiter	: std_logic;

	-- MRS Controller
	-- Commands
	signal MRSCtrlCmdAck		: std_logic;

	signal MRSCtrlCmdReq		: std_logic;
	signal MRSCtrlCmd		: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal MRSCtrlData		: std_logic_vector(MRS_REG_L - 1 downto 0);

	signal MRSCtrlODTCtrlCmd	: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal RefCtrlODTCtrlCmd	: std_logic_vector(MEM_CMD_L - 1 downto 0);

	-- ODT Controller
	signal MRSCtrlMRSCmdAccepted	: std_logic;

	signal MRSCtrlODTCtrlAck	: std_logic;

	signal MRSCtrlODTCtrlReq	: std_logic;

	-- Turn ODT signal on after MRS command(s)
	signal MRSUpdateCompleted	: std_logic;

	-- Column Controller
	-- Arbitrer
	signal ColCtrlCmdAck		: std_logic_vector(COL_CTRL_NUM - 1 downto 0);

	signal ColCtrlColMem		: std_logic_vector(COL_CTRL_NUM*COL_L - 1 downto 0);
	signal ColCtrlBankMem		: std_logic_vector(COL_CTRL_NUM*(int_to_bit_num(BANK_NUM)) - 1 downto 0);
	signal ColCtrlCmd		: std_logic_vector(COL_CTRL_NUM*MEM_CMD_L - 1 downto 0);
	signal ColCtrlCmdReq		: std_logic_vector(COL_CTRL_NUM - 1 downto 0);

	-- Bank Controller
	-- Arbitrer
	signal BankCtrlCmdAck		: std_logic_vector(BANK_CTRL_NUM - 1 downto 0);

	signal BankCtrlRowMem		: std_logic_vector(BANK_CTRL_NUM*ROW_L - 1 downto 0);
	signal BankCtrlBankMem		: std_logic_vector(BANK_CTRL_NUM*(int_to_bit_num(BANK_NUM)) - 1 downto 0);
	signal BankCtrlCmd		: std_logic_vector(BANK_CTRL_NUM*MEM_CMD_L - 1 downto 0);
	signal BankCtrlCmdReq		: std_logic_vector(BANK_CTRL_NUM - 1 downto 0);

	signal CmdDecCmdMem_int		: std_logic_vector(MEM_CMD_L - 1 downto 0);

begin

	REF_CTRL_I: ddr2_ctrl_ref_ctrl generic map (
		BANK_NUM => BANK_NUM
	)
	port map (
		clk => clk,
		rst => rst,

		-- High temperature flag
		DDR2HighTemperatureRefresh => DDR2HighTemperatureRefresh,

		-- Transaction Controller
		RefreshReq => RefCtrlRefreshReq,
		NonReadOpEnable => RefCtrlNonReadopEnable,
		ReadOpEnable => RefCtrlReadopEnable,

		-- PHY Init
		PhyInitCompleted => PhyInitCompleted,

		-- Bank Controller
		BankIdle => BankIdleVec,

		-- ODT Controller
		RefCmdAccepted => RefCtrlRefCmdAccepted,

		ODTCtrlAck => RefCtrlODTCtrlAck,

		ODTCtrlReq => RefCtrlODTCtrlReq,
		ODTCmd => RefCtrlODTCtrlCmd,

		-- Arbitrer
		CmdAck => RefCtrlCmdAck,

		CmdOut => RefCtrlCmd,
		CmdReq => RefCtrlCmdReq,

		-- Controller
		CtrlReq => RefCtrlCtrlReq,

		CtrlAck => RefCtrlCtrlAck
	);
 
	ODT_CTRL_I: ddr2_ctrl_odt_ctrl -- generic map (

--	)
	port map (
		clk => clk,
		rst => rst,

		-- Command sent to memory
		Cmd => CmdDecCmdMem_int,

		NoBankColCmd => NoBankColCmd,

		-- MRS Controller
		MRSCmdAccepted => MRSCtrlMRSCmdAccepted,

		MRSCtrlReq => MRSCtrlODTCtrlReq,
		MRSCmd => MRSCtrlODTCtrlCmd,
		MRSUpdateCompleted => MRSUpdateCompleted,

		MRSCtrlAck => MRSCtrlODTCtrlAck,

		-- Refresh Controller
		RefCmdAccepted => RefCtrlRefCmdAccepted,

		RefCtrlReq => RefCtrlODTCtrlReq,
		RefCmd => RefCtrlODTCtrlCmd,

		RefCtrlAck => RefCtrlODTCtrlAck,

		-- Stop Arbiter
		PauseArbiter => ODTCtrlPauseArbiter,

		-- ODT
		ODT => ODT

	);

	MRS_CTRL_I: ddr2_ctrl_mrs_ctrl generic map (
		MRS_REG_L => MRS_REG_L
	)
	port map (
		clk => clk,
		rst => rst,

		-- Transaction Controller
		CtrlReq => MRSCtrlCtrlReq,
		CtrlCmd => MRSCtrlCtrlCmd,
		CtrlData => MRSCtrlCtrlData,

		CtrlAck => MRSCtrlCtrlAck,
		MRSReq => MRSCtrlMRSReq,

		-- Commands
		CmdAck => MRSCtrlCmdAck,

		CmdReq => MRSCtrlCmdReq,
		Cmd => MRSCtrlCmd,
		Data => MRSCtrlData,

		-- ODT Controller
		MRSCmdAccepted => MRSCtrlMRSCmdAccepted,

		ODTCtrlAck => MRSCtrlODTCtrlAck,

		ODTCtrlReq => MRSCtrlODTCtrlReq,
		ODTCmd => MRSCtrlODTCtrlCmd,

		-- Turn ODT signal on after MRS command(s)
		MRSUpdateCompleted => MRSUpdateCompleted
	);

	CMD_CTRL_I: ddr2_ctrl_cmd_ctrl generic map (
		BANK_CTRL_NUM => BANK_CTRL_NUM,
		COL_CTRL_NUM => COL_CTRL_NUM,
		BURST_LENGTH_L => BURST_LENGTH_L,
		BANK_NUM => BANK_NUM,
		COL_L => COL_L,
		ROW_L => ROW_L,
		MAX_OUTSTANDING_BURSTS => MAX_OUTSTANDING_BURSTS
	)
	port map (
		clk => clk,
		rst => rst,

		-- MRS configuration
		DDR2CASLatency => DDR2CASLatency,
		DDR2BurstLength => DDR2BurstLength,
		DDR2AdditiveLatency => DDR2AdditiveLatency,
		DDR2WriteLatency => DDR2WriteLatency,

		-- Column Controller
		-- Arbitrer
		ColCtrlCmdAck => ColCtrlCmdAck,

		ColCtrlColMemOut => ColCtrlColMem,
		ColCtrlBankMemOut => ColCtrlBankMem,
		ColCtrlCmdOut => ColCtrlCmd,
		ColCtrlCmdReq => ColCtrlCmdReq,

		-- Controller
		ColCtrlCtrlReq => ColCtrlCtrlReq,
		ColCtrlReadBurstIn => ColCtrlReadBurstIn,
		ColCtrlColMemIn => ColCtrlColMemIn,
		ColCtrlBankMemIn => ColCtrlBankMemIn,
		ColCtrlBurstLength => ColCtrlBurstLength,

		ColCtrlCtrlAck => ColCtrlCtrlAck,

		-- Bank Controllers
		-- Arbitrer
		BankCtrlCmdAck => BankCtrlCmdAck,

		BankCtrlRowMemOut => BankCtrlRowMem,
		BankCtrlBankMemOut => BankCtrlBankMem,
		BankCtrlCmdOut => BankCtrlCmd,
		BankCtrlCmdReq => BankCtrlCmdReq,

		-- Transaction Controller
		BankCtrlRowMemIn => BankCtrlRowMemIn,
		BankCtrlCtrlReq => BankCtrlCtrlReq,

		BankCtrlCtrlAck => BankCtrlCtrlAck,

		-- Status
		BankIdleVec => BankIdleVec

	);

	ARB_I: ddr2_ctrl_arbiter_top generic map (
		ROW_L => ROW_L,
		COL_L => COL_L,
		ADDR_L => MRS_REG_L,
		BANK_NUM => BANK_NUM,
		BANK_CTRL_NUM => BANK_CTRL_NUM,
		COL_CTRL_NUM => COL_CTRL_NUM
	)
	port map (
		clk => clk,
		rst => rst,

		-- Bank Controllers
		BankCtrlBankMem => BankCtrlBankMem,
		BankCtrlRowMem => BankCtrlRowMem,
		BankCtrlCmdMem => BankCtrlCmd,
		BankCtrlCmdReq => BankCtrlCmdReq,

		BankCtrlCmdAck => BankCtrlCmdAck,

		-- Column Controller
		ColCtrlColMem => ColCtrlColMem,
		ColCtrlBankMem => ColCtrlBankMem,
		ColCtrlCmdMem => ColCtrlCmd,
		ColCtrlCmdReq => ColCtrlCmdReq,

		ColCtrlCmdAck => ColCtrlCmdAck,

		-- Refresh Controller
		RefCtrlCmdMem => RefCtrlCmd,
		RefCtrlCmdReq => RefCtrlCmdReq,

		RefCtrlCmdAck => RefCtrlCmdAck,

		-- MRS Controller
		MRSCtrlMRSCmd => MRSCtrlData,
		MRSCtrlCmdMem => MRSCtrlCmd,
		MRSCtrlCmdReq => MRSCtrlCmdReq,

		MRSCtrlCmdAck => MRSCtrlCmdAck,

		-- Arbiter Controller
		ODTCtrlPauseArbiter => ODTCtrlPauseArbiter,

		-- Command Decoder
		CmdDecColMem => CmdDecColMem,
		CmdDecRowMem => CmdDecRowMem,
		CmdDecBankMem => CmdDecBankMem,
		CmdDecCmdMem => CmdDecCmdMem_int,
		CmdDecMRSCmd => CmdDecMRSCmd

	);

	CmdDecCmdMem <= CmdDecCmdMem_int;

	NoBankColCmd <= '1' when (BankIdleVec = ZERO_BANK_IDLE_VEC) else '0';

end rtl;
