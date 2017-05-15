library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;
use work.ddr2_pkg.all;

package ddr2_phy_col_ctrl_pkg is 

	constant T_RTW		: positive := 2 + (2**(to_integer(unsigned(BL)) - 1));
	constant T_COL_COL	: positive := 2**(to_integer(unsigned(BL)) - 1);

	constant CNT_COL_CTRL_L		: integer := int_to_bit_num(max_int(T_RAS, max_int(T_RC, max_int(T_ACT_COL, max_int(T_READ_PRE, T_WRITE_PRE)))));
	constant CNT_DELAY_L		: integer := int_to_bit_num(max_int(T_RP, T_COL_COL));

	constant STATE_COL_CTRL_L	: positive := 4;

	constant IDLE			: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(0, STATE_BANK_CTRL_L));

end package ddr2_phy_col_ctrl_pkg;
