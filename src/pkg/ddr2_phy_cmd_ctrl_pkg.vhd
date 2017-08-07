library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;
use work.ddr2_phy_pkg.all;
use work.ddr2_mrs_pkg.all;

package ddr2_phy_cmd_ctrl_pkg is 

	component ddr2_phy_cmd_ctrl is
	generic (
		BANK_CTRL_NUM		: positive := 8;
		COL_CTRL_NUM		: positive := 1;
		BURST_LENGTH_L		: positive := 5;
		BANK_NUM		: positive := 8;
		COL_L			: positive := 10;
		ROW_L			: positive := 13;
		MAX_OUTSTANDING_BURSTS	: positive := 10
	);
	port (
		rst		: in std_logic;
		clk		: in std_logic;

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
		ColCtrlColMemIn		: in std_logic_vector(COL_CTRL_NUM*(COL_L - to_integer(unsigned(BURST_LENGTH))) - 1 downto 0);
		ColCtrlBankMemIn	: in std_logic_vector(COL_CTRL_NUM*(int_to_bit_num(BANK_NUM)) - 1 downto 0);
		ColCtrlBurstLength	: in std_logic_vector(COL_CTRL_NUM*BURST_LENGTH_L - 1 downto 0);

		ColCtrlCtrlAck		: out std_logic_vector(COL_CTRL_NUM - 1 downto 0);

		-- Bank Controllers
		-- Arbitrer
		BankCtrlCmdAck		: in std_logic_vector(BANK_CTRL_NUM - 1 downto 0);

		BankCtrlRowMemOut	: out std_logic_vector(BANK_CTRL_NUM*ROW_L - 1 downto 0);
		BankCtrlCmdOut		: out std_logic_vector(BANK_CTRL_NUM*MEM_CMD_L - 1 downto 0);
		BankCtrlCmdReq		: out std_logic_vector(BANK_CTRL_NUM - 1 downto 0);

		-- Transaction Controller
		BankCtrlRowMemIn	: in std_logic_vector(BANK_CTRL_NUM*ROW_L - 1 downto 0);
		BankCtrlCtrlReq		: in std_logic_vector(BANK_CTRL_NUM - 1 downto 0);

		BankCtrlCtrlAck		: out std_logic_vector(BANK_CTRL_NUM - 1 downto 0);

		-- Status
		BankIdleVec		: out std_logic_vector(BANK_CTRL_NUM - 1 downto 0)

	);
	end component;

end package ddr2_phy_cmd_ctrl_pkg;
