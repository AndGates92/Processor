library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

package ddr2_log_pkg is 

	constant ddr2_ctrl_regs_log_file		: string := "ddr2_ctrl_registers.log";
	constant ddr2_ctrl_arbiter_top_log_file	: string := "ddr2_ctrl_arbiter_top.log";
	constant ddr2_ctrl_arbiter_log_file	: string := "ddr2_ctrl_arbiter.log";
	constant ddr2_ctrl_bank_ctrl_log_file	: string := "ddr2_ctrl_bank_ctrl.log";
	constant ddr2_ctrl_col_ctrl_log_file	: string := "ddr2_ctrl_col_ctrl.log";
	constant ddr2_ctrl_cmd_ctrl_log_file	: string := "ddr2_ctrl_cmd_ctrl.log";
	constant ddr2_ctrl_ctrl_top_log_file	: string := "ddr2_ctrl_ctrl_top.log";
	constant ddr2_ctrl_ref_ctrl_log_file	: string := "ddr2_ctrl_ref_ctrl.log";
	constant ddr2_ctrl_odt_ctrl_log_file	: string := "ddr2_ctrl_odt_ctrl.log";
	constant ddr2_ctrl_mrs_ctrl_log_file	: string := "ddr2_ctrl_mrs_ctrl.log";
	constant ddr2_ctrl_cmd_dec_log_file	: string := "ddr2_ctrl_cmd_dec.log";
	constant ddr2_ctrl_init_log_file		: string := "ddr2_ctrl_init.log";

end package ddr2_log_pkg;
