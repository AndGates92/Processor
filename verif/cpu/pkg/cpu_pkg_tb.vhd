library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library cpu_rtl_pkg;
use cpu_rtl_pkg.proc_pkg.all;

package cpu_pkg_tb is

	constant STAT_REG_L_TB		: positive := 8;
	constant EN_REG_FILE_L_TB	: positive := 3;
	constant REG_NUM_TB		: positive := 4;
	constant OP1_L_TB		: integer := DATA_L;
	constant OP2_L_TB		: integer := DATA_L;
	constant DATA_L_TB		: integer := DATA_L;

end package cpu_pkg_tb;
