library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

package ddr2_log_pkg is 

	constant ddr2_phy_regs_log_file		: string := "ddr2_phy_registers.log";
	constant ddr2_phy_arbiter_log_file	: string := "ddr2_phy_arbiter.log";
	constant ddr2_phy_bank_ctrl_log_file	: string := "ddr2_phy_bank_ctrl.log";
	constant ddr2_phy_col_ctrl_log_file	: string := "ddr2_phy_col_ctrl.log";
	constant ddr2_phy_cmd_ctrl_log_file	: string := "ddr2_phy_cmd_ctrl.log";
	constant ddr2_phy_ref_ctrl_log_file	: string := "ddr2_phy_ref_ctrl.log";
	constant ddr2_phy_odt_ctrl_log_file	: string := "ddr2_phy_odt_ctrl.log";
	constant ddr2_phy_mrs_ctrl_log_file	: string := "ddr2_phy_mrs_ctrl.log";
	constant ddr2_phy_cmd_dec_log_file	: string := "ddr2_phy_cmd_dec.log";
	constant ddr2_phy_init_log_file		: string := "ddr2_phy_init.log";

end package ddr2_log_pkg;
