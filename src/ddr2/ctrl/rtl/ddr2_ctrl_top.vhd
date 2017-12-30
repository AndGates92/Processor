library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library common_rtl_pkg;
use common_rtl_pkg.functions_pkg.all;
library ddr2_ctrl_rtl_pkg;
use ddr2_ctrl_rtl_pkg.ddr2_ctrl_pkg.all;
use ddr2_ctrl_rtl_pkg.ddr2_ctrl_ctrl_top_pkg.all;
use ddr2_ctrl_rtl_pkg.ddr2_ctrl_regs_pkg.all;

entity ddr2_ctrl_top is
generic (
	REG_NUM			: positive := 4;
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
end entity ddr2_ctrl_top;

architecture rtl of ddr2_ctrl_top is

	-- Register Values
	signal DDR2ODT				: std_logic_vector(int_to_bit_num(ODT_MAX_VALUE) - 1 downto 0);
	signal DDR2DataStrobesEnable		: std_logic;
	signal DDR2ReadDataStrobesEnable	: std_logic;
	signal DDR2HighTemperature		: std_logic;
	signal DDR2DLLReset			: std_logic;
	signal DDR2CASLatency			: std_logic_vector(int_to_bit_num(CAS_LATENCY_MAX_VALUE) - 1 downto 0);
	signal DDR2BurstType			: std_logic;
	signal DDR2BurstLength			: std_logic_vector(int_to_bit_num(BURST_LENGTH_MAX_VALUE) - 1 downto 0);
	signal DDR2PowerDownExitMode		: std_logic;
	signal DDR2AdditiveLatency		: std_logic_vector(int_to_bit_num(AL_MAX_VALUE) - 1 downto 0);
	signal DDR2OutBufferEnable		: std_logic;
	signal DDR2DLLEnable			: std_logic;
	signal DDR2DrivingStrength		: std_logic;
	signal DDR2WriteRecovery		: std_logic_vector(int_to_bit_num(WRITE_REC_MAX_VALUE) - 1 downto 0);

begin

	CTRL_TOP_I: ddr2_ctrl_ctrl_top generic map (
		BANK_CTRL_NUM => BANK_CTRL_NUM,
		COL_CTRL_NUM => COL_CTRL_NUM,
		BURST_LENGTH_L => BURST_LENGTH_L,
		BANK_NUM => BANK_NUM,
		COL_L => COL_L,
		ROW_L => ROW_L,
		MRS_REG_L => ADDR_MEM_L,
		MAX_OUTSTANDING_BURSTS => MAX_OUTSTANDING_BURSTS
	)
	port map (
		clk => clk,
		rst => rst,

		-- MRS configuration
		DDR2CASLatency => DDR2CASLatency,
		DDR2BurstLength => DDR2BurstLength,
		DDR2AdditiveLatency => DDR2AdditiveLatency,
		DDR2HighTemperatureRefresh => DDR2HighTemperatureRefresh,

		-- Column Controller
		-- Controller
		ColCtrlCtrlReq => ColCtrlCtrlReq,
		ColCtrlReadBurstIn => ColCtrlReadBurstIn,
		ColCtrlColMemIn => ColCtrlColMemIn,
		ColCtrlBankMemIn => ColCtrlBankMemIn,
		ColCtrlBurstLength => ColCtrlBurstLength,

		ColCtrlCtrlAck => ColCtrlCtrlAck,

		-- Bank Controllers
		-- Transaction Controller
		BankCtrlRowMemIn => BankCtrlRowMemIn,
		BankCtrlCtrlReq => BankCtrlCtrlReq,

		BankCtrlCtrlAck => BankCtrlCtrlAck,

		-- MRS Controller
		-- Transaction Controller
		MRSCtrlCtrlReq => MRSCtrlCtrlReq,
		MRSCtrlCtrlCmd => MRSCtrlCtrlCmd,
		MRSCtrlCtrlData => MRSCtrlCtrlData,

		MRSCtrlCtrlAck => MRSCtrlCtrlAck,
		MRSCtrlMRSReq => MRSCtrlMRSReq,

		-- Refresh Controller
		-- Transaction Controller
		RefCtrlRefreshReq => RefCtrlRefreshReq,
		RefCtrlNonReadOpEnable => RefCtrlNonReadOpEnable,
		RefCtrlReadOpEnable => RefCtrlReadOpEnable,

		-- PHY Init
		PhyInitCompleted => PhyInitCompleted,

		-- Controller
		RefCtrlCtrlReq => RefCtrlCtrlReq,

		RefCtrlCtrlAck => RefCtrlCtrlAck,

		-- ODT Controller
		-- ODT
		ODT => ODT,

		-- Arbiter
		-- Command Decoder
		CmdDecColMem => CmdDecColMem,
		CmdDecRowMem => CmdDecRowMem,
		CmdDecBankMem => CmdDecBankMem,
		CmdDecCmdMem => CmdDecCmdMem,
		CmdDecMRSCmd => CmdDecMRSCmd

	);

	REGS_I: ddr2_ctrl_regs generic map (
		REG_NUM => REG_NUM,
		REG_L => MRS_REG_L
	)
	port map (
		clk => clk,
		rst => rst,

		-- Command Decoder
		MRSCmd => CmdDecMRSCmd,
		Cmd => CmdDecCmdMem,

		-- Register Values
		DDR2ODT => DDR2ODT,
		DDR2DataStrobesEnable => DDR2DataStrobesEnable,
		DDR2ReadDataStrobesEnable => DDR2ReadDataStrobesEnable,
		DDR2HighTemperature => DDR2HighTemperatureRefresh,
		DDR2DLLReset => DDR2DLLReset,
		DDR2CASLatency => DDR2CASLatency,
		DDR2BurstType => DDR2BurstType,
		DDR2BurstLength => DDR2BurstLength,
		DDR2PowerDownExitMode => DDR2PowerDownExitMode,
		DDR2AdditiveLatency => DDR2AdditiveLatency,
		DDR2OutBufferEnable => DDR2OutBufferEnable,
		DDR2DLLEnable => DDR2DLLEnable,
		DDR2DrivingStrength => DDR2DrivingStrength,
		DDR2WriteRecovery => DDR2WriteRecovery

	);

end rtl;
