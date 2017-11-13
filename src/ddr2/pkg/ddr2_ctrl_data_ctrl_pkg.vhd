library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library common_rtl_pkg;
use common_rtl_pkg.functions_pkg.all;
library ddr2_rtl_pkg;
use ddr2_rtl_pkg.ddr2_mrs_max_pkg.all;
use ddr2_rtl_pkg.ddr2_gen_ac_timing_pkg.all;

package ddr2_ctrl_data_ctrl_pkg is 

	constant T_WRITE_TO_READ_DIFF_BANK	: positive := (CAS - 1) + positive(2**(to_integer(unsigned(BURST_LENGTH))) - 1) + T_WTR;
	constant T_WRITE_TO_WRITE_DIFF_BANK	: positive := positive(2**(to_integer(unsigned(BURST_LENGTH))) - 1);
	constant T_READ_TO_WRITE_DIFF_BANK	: positive := positive(2**(to_integer(unsigned(BURST_LENGTH)) - 1)) + 2;
	constant T_READ_TO_READ_DIFF_BANK	: positive := positive(2**(to_integer(unsigned(BURST_LENGTH)) - 1));

	constant T_WRITE_TO_READ_SAME_BANK	: positive := (CAS - 1) + positive(2**(to_integer(unsigned(BURST_LENGTH))) - 1) + T_WTR;
	constant T_WRITE_TO_WRITE_SAME_BANK	: positive := positive(2**(to_integer(unsigned(BURST_LENGTH))) - 1);
	constant T_READ_TO_WRITE_SAME_BANK	: positive := positive(2**(to_integer(unsigned(BURST_LENGTH)) - 1)) + 2;
	constant T_READ_TO_READ_SAME_BANK	: positive := positive(2**(to_integer(unsigned(BURST_LENGTH)) - 1));

	constant CNT_BANK_CTRL_L	: integer := int_to_bit_num(max_int(T_RAS_min, max_int(T_RC, T_ACT_COL)));
	constant CNT_DELAY_L		: integer := int_to_bit_num(max_int(T_READ_PRE, max_int(T_WRITE_PRE, T_RP)));

	constant STATE_BANK_CTRL_L	: positive := 3;

	constant DATA_CTRL_IDLE		: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(0, STATE_BANK_CTRL_L));

end package ddr2_ctrl_data_ctrl_pkg;
