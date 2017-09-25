library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.functions_pkg.all;
use work.ddr2_mrs_pkg.all;

package ddr2_mrs_max_pkg is 

	-- MRS configuration

	constant ODT_MAX_VALUE			: std_logic_vector(1 downto 0) := max_int(to_integer(unsigned(ODT_50OHM)), max_int(to_integer(unsigned(ODT_DISABLE)), max_int(to_integer(unsigned(ODT_75OHM)), to_integer(unsigned(ODT_150OHM)))));
	constant nDQS_NAX			: std_logic := nDQS_ENABLE;
	constant RDQS_MAX_VALUE			: std_logic := RDQS_ENABLE;
	constant HITEMP_REF_MAX_VALUE		: std_logic := HITEMP_REF_ENABLE;
	constant CAS_MAX_VALUE			: std_logic_vector(2 downto 0) := CAS5;
	constant BURST_TYPE_MAX_VALUE		: std_logic := SEQ_BURST;
	constant BURST_LENGTH_MAX_VALUE		: std_logic_vector(2 downto 0) := BL4;
	constant POWER_DOWN_EXIT_MAX_VALUE	: std_logic := SLOW_POWER_DOWN_EXIT;
	constant AL_MAX_VALUE			: std_logic_vector(2 downto 0) := AL5;
	constant OUT_BUFFER_MAX_VALUE		: std_logic := OUT_BUF_ENABLE;
	constant nDLL_MAX_VALUE			: std_logic := nDLL_ENABLE;
	constant DRIVING_STRENGTH_MAX_VALUE	: std_logic := NORMAL;

end package ddr2_mrs_max_pkg;
