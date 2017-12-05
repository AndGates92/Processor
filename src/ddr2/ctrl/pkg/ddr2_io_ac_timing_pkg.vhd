library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library common_rtl_pkg;
use common_rtl_pkg.functions_pkg.all;
library ddr2_ctrl_rtl_pkg;
use ddr2_ctrl_rtl_pkg.ddr2_define_pkg.all;

package ddr2_io_ac_timing_pkg is 

	-- Timing parameter (in ns)
	constant T_AC_ns_min		: real := -0.4;
	constant T_AC_ns_max		: real := 0.4;
	constant T_DQSCK_ns_min		: real := -0.35;
	constant T_DQSCK_ns_max		: real := 0.35;

	-- Timing parameter (in nCK)
	constant T_CH_min	: real := 0.48;
	constant T_CH_max	: real := 0.52;
	constant T_CL_min	: real := 0.48;
	constant T_CL_max	: real := 0.52;

end package ddr2_io_ac_timing_pkg;
