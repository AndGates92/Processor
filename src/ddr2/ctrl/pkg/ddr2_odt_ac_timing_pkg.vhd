library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library common_rtl_pkg;
use common_rtl_pkg.functions_pkg.all;
library ddr2_rtl_pkg;
use ddr2_rtl_pkg.ddr2_define_pkg.all;
use ddr2_rtl_pkg.ddr2_io_ac_timing_pkg.all;

package ddr2_odt_ac_timing_pkg is 

	-- Timing parameter (in ns)
	constant T_AON_ns_min		: real := T_AC_ns_min;
	constant T_AON_ns_max		: real := T_AC_ns_max + 0.7;
	constant T_AONPD_ns_min		: real := T_AC_ns_min + 2.0;
	constant T_AONPD_ns_max		: real := T_AC_ns_max + 1.0 + 2.0*real(DDR2_CLK_PERIOD);
	constant T_AOF_ns_min		: real := T_AC_ns_min;
	constant T_AOF_ns_max		: real := T_AC_ns_max + 0.6;
	constant T_AOFPD_ns_min		: real := T_AC_ns_min + 2.0;
	constant T_AOFPD_ns_max		: real := T_AC_ns_max + 1.0 + 2.5*real(DDR2_CLK_PERIOD);

	-- Timing parameter (in nCK)
	constant T_AOND_min	: positive := 2;
	constant T_AOND_max	: positive := 2;
	constant T_ANPD		: positive := 3;
	constant T_AXPD		: positive := 8;
	constant T_AOFD		: positive := integer(ceil(2.5));
	constant T_AON_min	: positive := integer(ceil(T_AON_ns_min/(real(DDR2_CLK_PERIOD))));
	constant T_AON_max	: positive := integer(ceil(T_AON_ns_max/(real(DDR2_CLK_PERIOD))));
	constant T_AONPD_min	: positive := integer(ceil(T_AONPD_ns_min/(real(DDR2_CLK_PERIOD))));
	constant T_AONPD_max	: positive := integer(ceil(T_AONPD_ns_max/(real(DDR2_CLK_PERIOD))));
	constant T_AOF_min	: positive := integer(ceil(T_AOF_ns_min/(real(DDR2_CLK_PERIOD))));
	constant T_AOF_max	: positive := integer(ceil(T_AOF_ns_max/(real(DDR2_CLK_PERIOD))));
	constant T_AOFPD_min	: positive := integer(ceil(T_AOFPD_ns_min/(real(DDR2_CLK_PERIOD))));
	constant T_AOFPD_max	: positive := integer(ceil(T_AOFPD_ns_max/(real(DDR2_CLK_PERIOD))));

end package ddr2_odt_ac_timing_pkg;
