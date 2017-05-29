library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;
use work.ddr2_phy_pkg.all;
use work.ddr2_phy_bank_ctrl_pkg.all;
use work.ddr2_mrs_pkg.all;
use work.ddr2_timing_pkg.all;

package ddr2_phy_data_ctrl_pkg is 

	constant T_WRITE_TO_PRE_DIFF_BANK	: positive := 1;
	constant T_WRITE_TO_ACT_DIFF_BANK	: positive := 1;
	constant T_READ_TO_PRE_DIFF_BANK	: positive := 1;
	constant T_READ_TO_ACT_DIFF_BANK	: positive := 1;

	constant T_WRITE_TO_PRE_SAME_BANK	: positive := T_WRITE_PRE;
	constant T_WRITE_TO_ACT_SAME_BANK	: positive := T_WRITE_ACT;
	constant T_READ_TO_PRE_SAME_BANK	: positive := T_READ_PRE;
	constant T_READ_TO_ACT_SAME_BANK	: positive := T_READ_ACT;

	constant CNT_BANK_CTRL_L	: integer := int_to_bit_num(max_int(T_RAS_min, max_int(T_RC, T_ACT_COL)));
	constant CNT_DELAY_L		: integer := int_to_bit_num(max_int(T_READ_PRE, max_int(T_WRITE_PRE, T_RP)));

	constant STATE_BANK_CTRL_L	: positive := 3;

	constant DATA_CTRL_IDLE		: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(0, STATE_BANK_CTRL_L));

end package ddr2_phy_data_ctrl_pkg;
