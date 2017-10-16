library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library common_rtl_pkg;
use common_rtl_pkg.functions_pkg.all;
library ddr2_rtl_pkg;
use ddr2_rtl_pkg.ddr2_phy_pkg.all;
use ddr2_rtl_pkg.ddr2_mrs_max_pkg.all;
use ddr2_rtl_pkg.ddr2_phy_ref_ctrl_pkg.all;
use ddr2_rtl_pkg.ddr2_phy_mrs_ctrl_pkg.all;
use ddr2_rtl_pkg.ddr2_phy_odt_ctrl_pkg.all;
use ddr2_rtl_pkg.ddr2_phy_cmd_ctrl_pkg.all;
use ddr2_rtl_pkg.ddr2_gen_ac_timing_pkg.all;

entity ddr2_phy_ctrl_top is
generic (
	BANK_CTRL_NUM		: positive := 8;
	COL_CTRL_NUM		: positive := 1;
	REF_CTRL_NUM		: positive := 1;
	ODT_CTRL_NUM		: positive := 1;
	MRS_CTRL_NUM		: positive := 1;
	BURST_LENGTH_L		: positive := 5;
	BANK_NUM		: positive := 8;
	COL_L			: positive := 10;
	ROW_L			: positive := 13;
	MAX_OUTSTANDING_BURSTS	: positive := 10
);
port (
	rst		: in std_logic;
	clk		: in std_logic;

	-- MRS configuration
	DDR2CASLatency		: in std_logic_vector(int_to_bit_num(CAS_LATENCY_MAX_VALUE) - 1 downto 0);
	DDR2BurstLength		: in std_logic_vector(int_to_bit_num(BURST_LENGTH_MAX_VALUE) - 1 downto 0);
	DDR2AdditiveLatency	: in std_logic_vector(int_to_bit_num(AL_MAX_VALUE) - 1 downto 0);
	DDR2WriteLatency	: in std_logic_vector(int_to_bit_num(WRITE_LATENCY_MAX_VALUE) - 1 downto 0);

	-- Column Controller
	-- Arbitrer
	ColCtrlCmdAck		: in std_logic_vector(COL_CTRL_NUM - 1 downto 0);

	ColCtrlColMemOut	: out std_logic_vector(COL_CTRL_NUM*COL_L - 1 downto 0);
	ColCtrlBankMemOut	: out std_logic_vector(COL_CTRL_NUM*(int_to_bit_num(BANK_NUM)) - 1 downto 0);
	ColCtrlCmdOut		: out std_logic_vector(COL_CTRL_NUM*MEM_CMD_L - 1 downto 0);
	ColCtrlCmdReq		: out std_logic_vector(COL_CTRL_NUM - 1 downto 0);

	-- Controller
	ColCtrlCtrlReq		: in std_logic_vector(COL_CTRL_NUM - 1 downto 0);
	ColCtrlReadBurstIn	: in std_logic_vector(COL_CTRL_NUM - 1 downto 0);
	ColCtrlColMemIn		: in std_logic_vector(COL_CTRL_NUM*COL_L - 1 downto 0);
	ColCtrlBankMemIn	: in std_logic_vector(COL_CTRL_NUM*(int_to_bit_num(BANK_NUM)) - 1 downto 0);
	ColCtrlBurstLength	: in std_logic_vector(COL_CTRL_NUM*BURST_LENGTH_L - 1 downto 0);

	ColCtrlCtrlAck		: out std_logic_vector(COL_CTRL_NUM - 1 downto 0);

	-- Bank Controllers
	-- Arbitrer
	BankCtrlCmdAck		: in std_logic_vector(BANK_CTRL_NUM - 1 downto 0);

	BankCtrlRowMemOut	: out std_logic_vector(BANK_CTRL_NUM*ROW_L - 1 downto 0);
	BankCtrlBankMemOut	: out std_logic_vector(BANK_CTRL_NUM*(int_to_bit_num(BANK_NUM)) - 1 downto 0);
	BankCtrlCmdOut		: out std_logic_vector(BANK_CTRL_NUM*MEM_CMD_L - 1 downto 0);
	BankCtrlCmdReq		: out std_logic_vector(BANK_CTRL_NUM - 1 downto 0);

	-- Transaction Controller
	BankCtrlRowMemIn	: in std_logic_vector(BANK_CTRL_NUM*ROW_L - 1 downto 0);
	BankCtrlCtrlReq		: in std_logic_vector(BANK_CTRL_NUM - 1 downto 0);

	BankCtrlCtrlAck		: out std_logic_vector(BANK_CTRL_NUM - 1 downto 0);

	-- Status
	BankIdleVec		: out std_logic_vector(BANK_CTRL_NUM - 1 downto 0);

	-- MRS Controller
	-- Transaction Controller
	MRSCtrlCtrlReq			: in std_logic_vector(MRS_CTRL_NUM - 1 downto 0);
	MRSCtrlCtrlCmd			: in std_logic_vector(MRS_CTRL_NUM*MEM_CMD_L - 1 downto 0);
	MRSCtrlCtrlData			: in std_logic_vector(MRS_CTRL_NUM*MRS_REG_L - 1 downto 0);

	MRSCtrlCtrlAck			: out std_logic_vector(MRS_CTRL_NUM - 1 downto 0);

	-- Commands
	MRSCtrlCmdAck			: in std_logic_vector(MRS_CTRL_NUM - 1 downto 0);

	MRSCtrlCmdReq			: out std_logic_vector(MRS_CTRL_NUM - 1 downto 0);
	MRSCtrlCmd			: out std_logic_vector(MRS_CTRL_NUM*MEM_CMD_L - 1 downto 0);
	MRSCtrlData			: out std_logic_vector(MRS_CTRL_NUM*MRS_REG_L - 1 downto 0);

	-- ODT Controller
	MRSCtrlODTCtrlAck		: in std_logic_vector(MRS_CTRL_NUM - 1 downto 0);

	MRSCtrlODTCtrlReq		: out std_logic_vector(MRS_CTRL_NUM - 1 downto 0);

	-- Turn ODT signal on after MRS command(s)
	MRSCtrlMRSUpdateCompleted	: out std_logic_vector(MRS_CTRL_NUM - 1 downto 0);

	-- Refresh Controller
	-- High Temperature Refresh
	HighTemperatureRefresh		: in std_logic_vector(REF_CTRL_NUM - 1 downto 0);

	-- Transaction Controller
	RefCtrlRefreshReq		: out std_logic_vector(REF_CTRL_NUM - 1 downto 0);
	RefCtrlNonReadOpEnable		: out std_logic_vector(REF_CTRL_NUM - 1 downto 0);
	RefCtrlReadOpEnable		: out std_logic_vector(REF_CTRL_NUM - 1 downto 0);

	-- PHY Init
	RefCtrlPhyInitCompleted		: in std_logic_vector(REF_CTRL_NUM - 1 downto 0);

	-- Bank Controller
	RefCtrlBankIdle			: in std_logic_vector(REF_CTRL_NUM*BANK_NUM - 1 downto 0);

	-- ODT Controller
	RefCtrlODTCtrlAck		: in std_logic_vector(REF_CTRL_NUM - 1 downto 0);

	RefCtrlODTDisable		: out std_logic_vector(REF_CTRL_NUM - 1 downto 0);
	RefCtrlODTCtrlReq		: out std_logic_vector(REF_CTRL_NUM - 1 downto 0);

	-- Arbitrer
	RefCtrlCmdAck			: in std_logic_vector(REF_CTRL_NUM - 1 downto 0);

	RefCtrlCmdOut			: out std_logic_vector(REF_CTRL_NUM*MEM_CMD_L - 1 downto 0);
	RefCtrlCmdReq			: out std_logic_vector(REF_CTRL_NUM - 1 downto 0);

	-- Controller
	RefCtrlCtrlReq			: in std_logic_vector(REF_CTRL_NUM - 1 downto 0);

	RefCtrlCtrlAck			: out std_logic_vector(REF_CTRL_NUM - 1 downto 0);

	-- ODT Controller
	-- Command sent to memory
	ODTCtrlCmd			: in std_logic_vector(ODT_CTRL_NUM*MEM_CMD_L - 1 downto 0);

	-- MRS Controller
	ODTCtrlMRSCtrlReq		: in std_logic_vector(ODT_CTRL_NUM - 1 downto 0);
	ODTCtrlMRSUpdateCompleted	: in std_logic_vector(ODT_CTRL_NUM - 1 downto 0);

	ODTCtrlMRSCtrlAck		: out std_logic_vector(ODT_CTRL_NUM - 1 downto 0);

	-- Refresh Controller
	ODTCtrlRefCtrlReq		: in std_logic_vector(ODT_CTRL_NUM - 1 downto 0);

	ODTCtrlRefCtrlAck		: out std_logic_vector(ODT_CTRL_NUM - 1 downto 0);

	-- Stop Arbiter
	ODTCtrlPauseArbiter		: out std_logic_vector(ODT_CTRL_NUM - 1 downto 0);

	-- ODT
	ODTCtrlODT			: out std_logic_vector(ODT_CTRL_NUM - 1 downto 0);

	-- Arbiter
	-- Command Decoder
	CmdDecColMem			: out std_logic_vector(COL_L - 1 downto 0);
	CmdDecRowMem			: out std_logic_vector(ROW_L - 1 downto 0);
	CmdDecBankMem			: out std_logic_vector(int_to_bit_num(BANK_NUM) - 1 downto 0);
	CmdDecCmdMem			: out std_logic_vector(MEM_CMD_L - 1 downto 0);
	CmdDecMRSCmd			: out std_logic_vector(ADDR_L - 1 downto 0)


);

architecture rtl of ddr2_phy_ctrl_top is

begin

	ref_ctrl_loop : for i in 0 to (REF_CTRL_NUM - 1) generate

		REF_CTRL_I: ddr2_phy_ref_ctrl generic map (
			BANK_NUM => BANK_NUM
		)
		port map (
			clk => clk,
			rst => rst,

			-- High temperature flag
			HighTemperatureRefresh => RefCtrlHighTemperatureRefresh,

			-- Transaction Controller
			RefreshReq => RefCtrlRefreshReq,
			NonReadOpEnable => RefCtrlNonReadopEnable,
			ReadOpEnable => RefCtrlReadopEnable,

			-- PHY Init
			PhyInitCompleted => RefCtrlPhyInitCompleted,

			-- Bank Controller
			BankIdle => BankIdleVec,

			-- ODT Controller
			ODTCtrlAck => RefCtrlODTCtrlAck,

			ODTDisable => RefCtrlODTDisable,
			ODTCtrlReq => RefCtrlODTCtrlReq,

			-- Arbitrer
			CmdAck => RefCtrlCmdAck,

			CmdOut => RefCtrlCmdOut,
			CmdReq => RefCtrlCmdReq,

			-- Controller
			CtrlReq => RefCtrlCtrlReq,

			CtrlAck => RefCtrlCtrlAck
		);
 
	end generate ref_ctrl_loop;


	odt_ctrl_loop : for i in 0 to (ODT_CTRL_NUM - 1) generate

		ODT_CTRL_I: ddr2_phy_odt_ctrl -- generic map (

	--	)
		port map (
			clk => clk,
			rst => rst,

			-- Command sent to memory
			Cmd => ODTCtrlCmd,

			-- MRS Controller
			MRSCtrlReq => ODTCtrlMRSCtrlReq,
			MRSUpdateCompleted => ODTCtrlMRSUpdateCompleted,

			MRSCtrlAck => ODTCtrlMRSCtrlAck,

			-- Refresh Controller
			RefCtrlReq => ODTCtrlRefCtrlReq,

			RefCtrlAck => ODTCtrlRefCtrlAck,

			-- Stop Arbiter
			PauseArbiter => ODTCtrlPauseArbiter,

			-- ODT
			ODT => ODTCtrlODT

		);
 
	end generate odt_ctrl_loop;


	mrs_ctrl_loop : for i in 0 to (MRS_CTRL_NUM - 1) generate

		MRS_CTRL_I: ddr2_phy_mrs_ctrl generic map (
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

			-- Commands
			CmdAck => MRSCtrlCmdAck,

			CmdReq => MRSCtrlCmdReq,
			Cmd => MRSCtrlCmd,
			Data => MRSCtrlData,

			-- ODT Controller
			ODTCtrlAck => MRSCtrlODTCtrlAck,

			ODTCtrlReq => MRSCtrlODTCtrlReq,

			-- Turn ODT signal on after MRS command(s)
			MRSUpdateCompleted => MRSCtrlMRSUpdateCompleted
		);
	 
	end generate mrs_ctrl_loop;

	CMD_CTRL_I: ddr2_phy_cmd_ctrl generic map (
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

		ColCtrlColMemOut => ColCtrlColMemOut,
		ColCtrlBankMemOut => ColCtrlBankMemOut,
		ColCtrlCmdOut => ColCtrlCmdOut,
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

		BankCtrlRowMemOut => BankCtrlRowMemOut,
		BankCtrlBankMemOut => BankCtrlBankMemOut,
		BankCtrlCmdOut => BankCtrlCmdOut,
		BankCtrlCmdReq => BankCtrlCmdReq,

		-- Transaction Controller
		BankCtrlRowMemIn => BankCtrlRowMemIn,
		BankCtrlCtrlReq => BankCtrlCtrlReq,

		BankCtrlCtrlAck => BankCtrlCtrlAck,

		-- Status
		BankIdleVec => BankIdleVec

	);

	ARB_I: ddr2_phy_arbiter generic map (
		ROW_L => ROW_L,
		COL_L => COL_L,
		ADDR_L => ADDR_MEM_L,
		BANK_NUM => BANK_NUM,
		BANK_CTRL_NUM => BANK_CTRL_NUM,
		COL_CTRL_NUM => COL_CTRL_NUM,
		MRS_CTRL_NUM => MRS_CTRL_NUM,
		REF_CTRL_NUM => REF_CTRL_NUM
	)
	port map (
		clk => clk_tb,
		rst => rst_tb,

		-- Bank Controllers
		BankCtrlBankMem => BankCtrlBankMem_tb,
		BankCtrlRowMem => BankCtrlRowMem_tb,
		BankCtrlCmdMem => BankCtrlCmdMem_tb,
		BankCtrlCmdReq => BankCtrlCmdReq_tb,

		BankCtrlCmdAck => BankCtrlCmdAck_tb,

		-- Column Controller
		ColCtrlColMem => ColCtrlColMem_tb,
		ColCtrlBankMem => ColCtrlBankMem_tb,
		ColCtrlCmdMem => ColCtrlCmdMem_tb,
		ColCtrlCmdReq => ColCtrlCmdReq_tb,

		ColCtrlCmdAck => ColCtrlCmdAck_tb,

		-- Refresh Controller
		RefCtrlCmdMem => RefCtrlCmdMem_tb,
		RefCtrlCmdReq => RefCtrlCmdReq_tb,

		RefCtrlCmdAck => RefCtrlCmdAck_tb,

		-- MRS Controller
		MRSCtrlMRSCmd => MRSCtrlMRSCmd_tb,
		MRSCtrlCmdMem => MRSCtrlCmdMem_tb,
		MRSCtrlCmdReq => MRSCtrlCmdReq_tb,

		MRSCtrlCmdAck => MRSCtrlCmdAck_tb,

		-- Arbiter Controller
		AllowBankActivate => AllowBankActivate_tb,

		BankActOut => BankActOut_tb,

		-- Command Decoder
		CmdDecColMem => CmdDecColMem_tb,
		CmdDecRowMem => CmdDecRowMem_tb,
		CmdDecBankMem => CmdDecBankMem_tb,
		CmdDecCmdMem => CmdDecCmdMem_tb,
		CmdDecMRSCmd => CmdDecMRSCmd_tb

	);



end rtl;
