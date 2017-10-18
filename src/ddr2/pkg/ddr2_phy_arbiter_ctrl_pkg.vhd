library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package ddr2_phy_arbiter_ctrl is

	constant WINDOW_L		: integer := 4;
	constant CNT_ARR_FOUR_ACT_WIN_L	: integer := int_to_bit_num(T_FAW_min);
	constant CNT_ACT_TO_ACT_L	: integer := int_to_bit_num(T_RRD);

	type four_act_win_unsigned is unsigned((CNT_ARR_FOUR_ACT_WIN_L - 1) downto 0);
	type four_act_win_unsigned_arr is array (integer range <>) of four_act_win_unsigned;

end package ddr2_phy_arbiter_ctrl;
