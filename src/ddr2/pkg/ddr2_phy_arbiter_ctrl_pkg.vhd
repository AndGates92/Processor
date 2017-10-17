library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package ddr2_phy_arbiter_ctrl is

	constant WINDOW_L		: integer := 4;
	constant CNT_ARR_ARB_CTRL_L	: integer := int_to_bit_num(max_int(T_FAW_min, T_RRD));

	type arb_ctrl_unsigned_arr is array (integer range <>) of unsigned((CNT_ARR_ARB_CTRL_L - 1) downto 0);

end package ddr2_phy_arbiter_ctrl;
