library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library common_rtl_pkg;
use common_rtl_pkg.functions_pkg.all;
library ddr2_rtl_pkg;
use ddr2_rtl_pkg.ddr2_gen_ac_timing_pkg.all;

package ddr2_ctrl_arbiter_ctrl_pkg is

	constant WINDOW_L		: integer := 4;
	constant CNT_ARR_FOUR_ACT_WIN_L	: integer := int_to_bit_num(T_FAW);
	constant CNT_ACT_TO_ACT_L	: integer := int_to_bit_num(T_RRD);

	subtype four_act_win_unsigned is unsigned((CNT_ARR_FOUR_ACT_WIN_L - 1) downto 0);
	type four_act_win_unsigned_arr is array (integer range <>) of four_act_win_unsigned;

	component ddr2_ctrl_arbiter_ctrl is
	--generic (

	--);
	port (

		rst		: in std_logic;
		clk		: in std_logic;

		ODTCtrlPauseArbiter	: in std_logic;
		BankActCmd		: in std_logic;

		PauseArbiter		: out std_logic;
		AllowBankActivate	: out std_logic
	);
	end component;

end package ddr2_ctrl_arbiter_ctrl_pkg;
