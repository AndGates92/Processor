library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

package common_log_pkg is 

	constant arbiter_log_file		: string := "arbiter.log";
	constant fifo_1clk_log_file		: string := "fifo_1clk.log";
	constant fifo_2clk_log_file		: string := "fifo_2clk.log";

end package common_log_pkg;
