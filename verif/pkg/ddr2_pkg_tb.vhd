library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;

package ddr2_pkg_tb is 

	constant CLK_RATIO_TB		: positive := 4;

	constant BANK_NUM_TB	: positive := 8;
	constant BANK_L_TB	: positive := positive(int_to_bit_num(BANK_NUM_TB));

	constant COL_L_TB	: positive := 10;
	constant ROW_L_TB	: positive := 13;

	constant ADDR_MEM_L_TB	: positive := 13;
	constant DDR2_ADDR_L_TB	: positive := ROW_L_TB + COL_L_TB + BANK_L_TB;

	constant DDR2_DATA_L_TB	: positive := 16;

end package ddr2_pkg_tb;
