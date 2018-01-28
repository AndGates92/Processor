library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library common_rtl_pkg;
use common_rtl_pkg.functions_pkg.all;
library ddr2_ctrl_rtl_pkg;
use ddr2_ctrl_rtl_pkg.ddr2_ctrl_pkg.all;
use ddr2_ctrl_rtl_pkg.ddr2_ctrl_top_pkg.all;
use ddr2_ctrl_rtl_pkg.ddr2_ctrl_init_pkg.all;

entity ddr2_ctrl_init_top is
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
end entity ddr2_ctrl_init_top;

architecture rtl of ddr2_ctrl_init_top is

	-- Command Decoder
	-- Arbiter
	signal CtrlTopColMem	: std_logic_vector(COL_L - 1 downto 0);
	signal CtrlTopRowMem	: std_logic_vector(ROW_L - 1 downto 0);
	signal CtrlTopBankMem	: std_logic_vector(int_to_bit_num(BANK_NUM) - 1 downto 0);
	signal CtrlTopCmdMem	: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal CtrlTopMRSCmd	: std_logic_vector(MRS_REG_L - 1 downto 0);

	-- Command Decoder
	-- DDR Init
	signal CtrlInitCmdMem	: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal CtrlInitMRSCmd	: std_logic_vector(MRS_REG_L - 1 downto 0);

	-- PHY Init
	signal PhyInitCompleted	: std_logic;

begin

	CTRL_TOP_I: ddr2_ctrl_top generic map (
		BANK_CTRL_NUM => BANK_CTRL_NUM,
		COL_CTRL_NUM => COL_CTRL_NUM,
		BURST_LENGTH_L => BURST_LENGTH_L,
		BANK_NUM => BANK_NUM,
		COL_L => COL_L,
		ROW_L => ROW_L,
		MRS_REG_L => MRS_REG_L,
		MAX_OUTSTANDING_BURSTS => MAX_OUTSTANDING_BURSTS
	)
	port map (
		clk => clk,
		rst => rst,

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
		CmdDecColMem => CtrlTopColMem,
		CmdDecRowMem => CtrlTopRowMem,
		CmdDecBankMem => CtrlTopBankMem,
		CmdDecCmdMem => CtrlTopCmdMem,
		CmdDecMRSCmd => CtrlTopMRSCmd

	);

	CTRL_INIT_I: ddr2_ctrl_init generic map (
		BANK_L => int_to_bit_num(BANK_NUM),
		ADDR_MEM_L => MRS_REG_L
	)
	port map (
		clk => clk,
		rst => rst,

		MRSCmd => CtrlInitMRSCmd,
		Cmd => CtrlInitCmdMem,

		InitializationCompleted => PhyInitCompleted
	);
 
	CmdDecMRSCmd <= CtrlTopMRSCmd when (PhyInitCompleted = '1') else CtrlInitMRSCmd;
	CmdDecCmdMem <= CtrlTopCmdMem when (PhyInitCompleted = '1') else CtrlInitCmdMem;
	CmdDecBankMem <= CtrlTopBankMem when (PhyInitCompleted = '1') else (others => '0');
	CmdDecRowMem <= CtrlTopRowMem when (PhyInitCompleted = '1') else (others => '0');
	CmdDecColMem <= CtrlTopColMem when (PhyInitCompleted = '1') else (others => '0');

end rtl;
