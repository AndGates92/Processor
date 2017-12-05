library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library common_rtl_pkg;
use common_rtl_pkg.functions_pkg.all;
library ddr2_ctrl_rtl_pkg;
use ddr2_ctrl_rtl_pkg.ddr2_define_pkg.all;

package ddr2_gen_ac_timing_pkg is 

	-- Timing parameter (in ns)
	constant T_WTR_ns		: real := max_real(7.5, (real(2*DDR2_CLK_PERIOD)));
	constant T_RTP_ns		: real := 7.5;
	constant T_RCD_ns		: real := 12.5;
	constant T_RAP_ns		: real := T_RCD_ns;
	constant T_RAS_ns_min		: real := 45.0;
	constant T_RAS_ns_max		: real := 7.0e4;
	constant T_RP_ns		: real := 12.5;
	constant T_RC_ns		: real := T_RAS_ns_min + T_RP_ns;
	constant T_RRD_ns		: real := 10.0;
	constant T_FAW_ns		: real := 45.0;
	constant T_WR_ns		: real := 15.0;
	constant T_RFC_ns		: real := 127.5;
	constant T_XSNR_ns		: real := T_RFC_ns + 10.0;
	constant T_MOD_ns_min		: real := 0.0;
	constant T_MOD_ns_max		: real := 12.0;
	constant T_REFI_ns_lowT		: real := 7.8e3;
	constant T_REFI_ns_highT	: real := 3.9e3;

	-- Timing parameter (in nCK)
	constant T_MRD		: positive := 2;
	constant T_CCD		: positive := 2;
	constant T_XSRD		: positive := 200;
	constant T_XP		: positive := 2;
	constant T_XARD		: positive := 2;
	constant T_XARDS_max	: positive := 8;
	constant T_WTR		: positive := integer(ceil(T_WTR_ns/(real(DDR2_CLK_PERIOD))));
	constant T_RTP		: positive := integer(ceil(T_RTP_ns/(real(DDR2_CLK_PERIOD))));
	constant T_RCD		: positive := integer(ceil(T_RCD_ns/(real(DDR2_CLK_PERIOD))));
	constant T_RP		: positive := integer(ceil(T_RP_ns/(real(DDR2_CLK_PERIOD))));
	constant T_RC		: positive := integer(ceil(T_RC_ns/(real(DDR2_CLK_PERIOD))));
	constant T_RAP		: positive := integer(ceil(T_RAP_ns/(real(DDR2_CLK_PERIOD))));
	constant T_RAS_min	: positive := integer(ceil(T_RAS_ns_min/(real(DDR2_CLK_PERIOD))));
	constant T_RAS_max	: positive := integer(ceil(T_RAS_ns_max/(real(DDR2_CLK_PERIOD))));
	constant T_RRD		: positive := integer(ceil(T_RRD_ns/(real(DDR2_CLK_PERIOD))));
	constant T_FAW		: positive := integer(ceil(T_FAW_ns/(real(DDR2_CLK_PERIOD))));
	constant T_WR		: positive := integer(ceil(T_WR_ns/(real(DDR2_CLK_PERIOD))));
	constant T_RFC		: positive := integer(ceil(T_RFC_ns/(real(DDR2_CLK_PERIOD))));
	constant T_XSNR		: positive := integer(ceil(T_XSNR_ns/(real(DDR2_CLK_PERIOD))));
	constant T_MOD_min	: positive := integer(ceil(T_MOD_ns_min/(real(DDR2_CLK_PERIOD))));
	constant T_MOD_max	: positive := integer(ceil(T_MOD_ns_max/(real(DDR2_CLK_PERIOD))));
	constant T_REFI_lowT	: positive := integer(ceil(T_REFI_ns_lowT/(real(DDR2_CLK_PERIOD))));
	constant T_REFI_highT	: positive := integer(ceil(T_REFI_ns_highT/(real(DDR2_CLK_PERIOD))));

end package ddr2_gen_ac_timing_pkg;
