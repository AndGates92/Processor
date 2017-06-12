library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;
use work.ddr2_mrs_pkg.all;
use work.ddr2_timing_pkg.all;

package ddr2_phy_col_ctrl_pkg is 

	constant T_RTW		: positive := 2 + (2**(to_integer(unsigned(BL)) - 1));
	constant T_COL_COL	: positive := 2**(to_integer(unsigned(BL)) - 1);

	constant CNT_COL_CTRL_L		: integer := int_to_bit_num(max_int(T_RTW, T_COL_COL));

	constant STATE_COL_CTRL_L	: positive := 2;

	constant COL_CTRL_IDLE		: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(0, STATE_BANK_CTRL_L));
	constant DATA_PHASE		: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(1, STATE_BANK_CTRL_L));
	constant CHANGE_BURST_OP	: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(2, STATE_BANK_CTRL_L));

end package ddr2_phy_col_ctrl_pkg;
