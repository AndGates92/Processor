library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library common_rtl_pkg;
use common_rtl_pkg.functions_pkg.all;
library ddr2_ctrl_rtl_pkg;
use ddr2_ctrl_rtl_pkg.ddr2_ctrl_pkg.all;
use ddr2_ctrl_rtl_pkg.ddr2_mrs_max_pkg.all;

package ddr2_ctrl_ctrl_top_pkg is 

	component ddr2_ctrl_ctrl_top is
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
	end component;

end package ddr2_ctrl_ctrl_top_pkg;
