library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package cpu_log_pkg is

	constant alu_log_file			: string := "alu.log";
	constant ctrl_log_file			: string := "ctrl.log";
	constant dcache_log_file		: string := "dcache.log";
	constant icache_log_file		: string := "icache.log";
	constant div_log_file			: string := "div.log";
	constant mul_log_file			: string := "mul.log";
	constant reg_file_log_file		: string := "reg_file.log";
	constant decode_log_file		: string := "decode.log";
	constant execute_dcache_log_file	: string := "execute_dcache.log";
	constant execute_log_file		: string := "execute.log";

end package cpu_log_pkg;
