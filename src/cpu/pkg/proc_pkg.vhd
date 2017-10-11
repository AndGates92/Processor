library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
library common_rtl_pkg;
use common_rtl_pkg.functions_pkg.all;

package proc_pkg is 

	constant PROC_CLK_PERIOD	: positive := 10; -- ns

	constant DATA_MEMORY_MB	: positive := 1; -- 1 MB
	constant DATA_MEMORY	: positive := DATA_MEMORY_MB*(integer(2.0**(3.0) * 2.0**(10.0)));

	constant PROGRAM_MEMORY_MB	: real := 0.5; -- 512 kB
	constant PROGRAM_MEMORY	: positive := integer(PROGRAM_MEMORY_MB*(2.0**(3.0) * 2.0**(10.0)));

	constant INSTR_L	: positive := 28;
	constant DATA_L		: positive := 28;

	constant INCR_PC	: positive := 4;
	constant INCR_PC_L	: positive := positive(int_to_bit_num(INCR_PC));

end package proc_pkg;
