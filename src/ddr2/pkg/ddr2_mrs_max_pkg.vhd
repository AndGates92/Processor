library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.functions_pkg.all;
use work.ddr2_mrs_pkg.all;

package ddr2_mrs_max_pkg is 

	-- MRS configuration
	constant ODT_MAX_VALUE			: integer := max_int(to_integer(unsigned(ODT_50OHM)), max_int(to_integer(unsigned(ODT_DISABLED)), max_int(to_integer(unsigned(ODT_75OHM)), to_integer(unsigned(ODT_150OHM)))));
	constant nDQS_MAX_VALUE			: integer := max_std_logic(nDQS_ENABLE, nDQS_DISABLE);
	constant RDQS_MAX_VALUE			: integer := max_std_logic(RDQS_ENABLE, RDQS_DISABLE);
	constant HITEMP_REF_MAX_VALUE		: integer := max_std_logic(HITEMP_REF_DISABLE, HITEMP_REF_ENABLE);
	constant CAS_LATENCY_MAX_VALUE		: integer := max_int(to_integer(unsigned(CAS6)), max_int(to_integer(unsigned(CAS5)), max_int(to_integer(unsigned(CAS4)), to_integer(unsigned(CAS3)))));
	constant BURST_TYPE_MAX_VALUE		: integer := max_std_logic(INTL_BURST, SEQ_BURST);
	constant BURST_LENGTH_MAX_VALUE		: integer := max_int(to_integer(unsigned(BL4)), to_integer(unsigned(BL8)));
	constant POWER_DOWN_EXIT_MAX_VALUE	: integer := max_std_logic(FAST_POWER_DOWN_EXIT, SLOW_POWER_DOWN_EXIT);
	constant AL_MAX_VALUE			: integer := max_int(to_integer(unsigned(AL5)), max_int(to_integer(unsigned(AL4)), max_int(to_integer(unsigned(AL3)), max_int(to_integer(unsigned(AL2)), max_int(to_integer(unsigned(AL1)), to_integer(unsigned(AL0)))))));
	constant OUT_BUFFER_MAX_VALUE		: integer := max_std_logic(OUT_BUF_DISABLE, OUT_BUF_ENABLE);
	constant nDLL_MAX_VALUE			: integer := max_std_logic(nDLL_ENABLE, nDLL_DISABLE);
	constant DRIVING_STRENGTH_MAX_VALUE	: integer := max_std_logic(WEAK, NORMAL);
	constant WRITE_REC_MAX_VALUE		: integer := max_int(to_integer(unsigned(WRITE_REC_800)), max_int(to_integer(unsigned(WRITE_REC_667)), max_int(to_integer(unsigned(WRITE_REC_533)), max_int(to_integer(unsigned(WRITE_REC_400_3)), to_integer(unsigned(WRITE_REC_400_2))))));

	constant MAX_MRS_FIELD			: integer := max_int(ODT_MAX_VALUE, max_int(nDQS_MAX_VALUE, max_int(RDQS_MAX_VALUE, max_int(HITEMP_REF_MAX_VALUE, max_int(CAS_LATENCY_MAX_VALUE, max_int(BURST_TYPE_MAX_VALUE, max_int(BURST_LENGTH_MAX_VALUE, max_int(POWER_DOWN_EXIT_MAX_VALUE, max_int(AL_MAX_VALUE, max_int(OUT_BUFFER_MAX_VALUE, max_int(nDLL_MAX_VALUE, max_int(DRIVING_STRENGTH_MAX_VALUE, WRITE_REC_MAX_VALUE))))))))))));

	-- Derived parameters
	constant READ_LATENCY_MAX_VALUE		: positive := CAS_LATENCY_MAX_VALUE + AL_MAX_VALUE;
	constant WRITE_LATENCY_MAX_VALUE	: positive := READ_LATENCY_MAX_VALUE - 1;

end package ddr2_mrs_max_pkg;
