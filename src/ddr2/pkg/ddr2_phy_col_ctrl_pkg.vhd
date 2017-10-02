library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.functions_pkg.all;
use work.ddr2_phy_pkg.all;
use work.ddr2_mrs_max_pkg.all;
use work.ddr2_gen_ac_timing_pkg.all;

package ddr2_phy_col_ctrl_pkg is 

	-- Turn around time
	constant T_RTW_tat	: positive := 2 + (2**(BURST_LENGTH_MAX_VALUE - 1));
	constant T_WTR_tat	: positive := CAS_LATENCY_MAX_VALUE - 1 + (2**(BURST_LENGTH_MAX_VALUE - 1)) + T_WTR;

	constant T_COL_COL		: positive := 2**(BURST_LENGTH_MAX_VALUE - 1);
	constant CNT_COL_TO_COL_L	: positive := int_to_bit_num(T_COL_COL);

	constant CNT_COL_CTRL_L		: integer := int_to_bit_num(max_int(T_RTW_tat, T_WTR_tat));

	constant STATE_COL_CTRL_L	: positive := 2;

	constant COL_CTRL_IDLE		: std_logic_vector(STATE_COL_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(0, STATE_COL_CTRL_L));
	constant COL_CTRL_DATA_PHASE	: std_logic_vector(STATE_COL_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(1, STATE_COL_CTRL_L));
	constant CHANGE_BURST_OP	: std_logic_vector(STATE_COL_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(2, STATE_COL_CTRL_L));

	component ddr2_phy_col_ctrl is
	generic (
		BURST_LENGTH_L		: positive := 5;
		BANK_NUM		: positive := 8;
		COL_L			: positive := 10
	);
	port (

		rst		: in std_logic;
		clk		: in std_logic;

		-- MRS configuration
		DDR2CASLatency	: in std_logic_vector(int_to_bit_num(CAS_LATENCY_MAX_VALUE) - 1 downto 0);
		DDR2BurstLength	: in std_logic_vector(int_to_bit_num(BURST_LENGTH_MAX_VALUE) - 1 downto 0);

		-- Bank Controller
		BankActiveVec			: in std_logic_vector(BANK_NUM - 1 downto 0);
		ZeroOutstandingBurstsVec	: in std_logic_vector(BANK_NUM - 1 downto 0);

		EndDataPhaseVec			: out std_logic_vector(BANK_NUM - 1 downto 0);
		ReadBurstVec			: out std_logic_vector(BANK_NUM - 1 downto 0);

		-- Arbitrer
		CmdAck		: in std_logic;

		ColMemOut	: out std_logic_vector(COL_L - 1 downto 0);
		BankMemOut	: out std_logic_vector(int_to_bit_num(BANK_NUM) - 1 downto 0);
		CmdOut		: out std_logic_vector(MEM_CMD_L - 1 downto 0);
		CmdReq		: out std_logic;

		-- Controller
		CtrlReq		: in std_logic;
		ReadBurstIn	: in std_logic;
		ColMemIn	: in std_logic_vector(COL_L - 1 downto 0);
		BankMemIn	: in std_logic_vector(int_to_bit_num(BANK_NUM) - 1 downto 0);
		BurstLength	: in std_logic_vector(BURST_LENGTH_L - 1 downto 0);

		CtrlAck		: out std_logic

	);
	end component;


end package ddr2_phy_col_ctrl_pkg;
