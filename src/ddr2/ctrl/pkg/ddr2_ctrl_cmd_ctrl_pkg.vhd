library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library common_rtl_pkg;
use common_rtl_pkg.functions_pkg.all;
library ddr2_ctrl_rtl_pkg;
use ddr2_ctrl_rtl_pkg.ddr2_ctrl_pkg.all;
use ddr2_ctrl_rtl_pkg.ddr2_mrs_max_pkg.all;

package ddr2_ctrl_cmd_ctrl_pkg is 

	component ddr2_ctrl_cmd_ctrl is
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
		BankIdleVec		: out std_logic_vector(BANK_CTRL_NUM - 1 downto 0)

	);
	end component;

end package ddr2_ctrl_cmd_ctrl_pkg;
