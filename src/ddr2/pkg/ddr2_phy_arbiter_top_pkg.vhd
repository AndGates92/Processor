library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library common_rtl_pkg;
use common_rtl_pkg.functions_pkg.all;
library ddr2_rtl_pkg;
use ddr2_rtl_pkg.ddr2_phy_pkg.all;

package ddr2_phy_arbiter_top_pkg is 

	component ddr2_phy_arbiter_top is
	generic (
		BANK_CTRL_NUM	: positive := 8;
		COL_CTRL_NUM	: positive := 1;
		BANK_NUM	: positive := 8;
		COL_L		: positive := 10;
		ROW_L		: positive := 14;
		ADDR_L		: positive := 14

	);
	port (

		rst		: in std_logic;
		clk		: in std_logic;

		-- Bank Controllers
		BankCtrlBankMem		: in std_logic_vector(BANK_CTRL_NUM*(int_to_bit_num(BANK_NUM)) - 1 downto 0);
		BankCtrlRowMem		: in std_logic_vector(BANK_CTRL_NUM*ROW_L - 1 downto 0);
		BankCtrlCmdMem		: in std_logic_vector(BANK_CTRL_NUM*MEM_CMD_L - 1 downto 0);
		BankCtrlCmdReq		: in std_logic_vector(BANK_CTRL_NUM - 1 downto 0);

		BankCtrlCmdAck		: out std_logic_vector(BANK_CTRL_NUM - 1 downto 0);

		-- Column Controller
		ColCtrlColMem		: in std_logic_vector(COL_CTRL_NUM*COL_L - 1 downto 0);
		ColCtrlBankMem		: in std_logic_vector(COL_CTRL_NUM*(int_to_bit_num(BANK_NUM)) - 1 downto 0);
		ColCtrlCmdMem		: in std_logic_vector(COL_CTRL_NUM*MEM_CMD_L - 1 downto 0);
		ColCtrlCmdReq		: in std_logic_vector(COL_CTRL_NUM - 1 downto 0);

		ColCtrlCmdAck		: out std_logic_vector(COL_CTRL_NUM - 1 downto 0);

		-- Refresh Controller
		RefCtrlCmdMem		: in std_logic_vector(MEM_CMD_L - 1 downto 0);
		RefCtrlCmdReq		: in std_logic;

		RefCtrlCmdAck		: out std_logic;

		-- MRS Controller
		MRSCtrlMRSCmd		: in std_logic_vector(ADDR_L - 1 downto 0);
		MRSCtrlCmdMem		: in std_logic_vector(MEM_CMD_L - 1 downto 0);
		MRSCtrlCmdReq		: in std_logic;

		MRSCtrlCmdAck		: out std_logic;

		-- ODT Ctrl MRS update
		ODTCtrlPauseArbiter	: in std_logic;

		-- Command Decoder
		CmdDecColMem		: out std_logic_vector(COL_L - 1 downto 0);
		CmdDecRowMem		: out std_logic_vector(ROW_L - 1 downto 0);
		CmdDecBankMem		: out std_logic_vector(int_to_bit_num(BANK_NUM) - 1 downto 0);
		CmdDecCmdMem		: out std_logic_vector(MEM_CMD_L - 1 downto 0);
		CmdDecMRSCmd		: out std_logic_vector(ADDR_L - 1 downto 0)
	);
	end component;

end package ddr2_phy_arbiter_top_pkg;
