library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;
use work.tb_pkg.all;

package ddr2_phy_bank_ctrl_pkg_tb is 

	type int_arr_ddr2_phy_bank_ctrl is array(0 to MAX_OUTSTANDING_BURSTS - 1) of integer;

	constant int_arr_ddr2_phy_bank_ctrl_def	: integer := integer'high;

end package ddr2_phy_bank_ctrl_pkg_tb;

package body ddr2_phy_bank_ctrl_pkg_tb is

end package body ddr2_phy_bank_ctrl_pkg_tb;
