library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ddr2_phy_pkg.all;
use work.proc_pkg.all;
use work.tb_pkg.all;

package ddr2_phy_bank_ctrl_pkg_tb is 

	constant MAX_BURST_DELAY	: positive := 20;

	procedure run_bank_ctrl (variable num_bursts_exp: in integer; variable rows_arr_exp, bl_arr : in int_arr(0 to (MAX_OUTSTANDING_BURSTS - 1)); variable num_bursts_exp: out integer; variable rows_arr_exp : out int_arr(0 to (MAX_OUTSTANDING_BURSTS - 1)));

end package ddr2_phy_bank_ctrl_pkg_tb;

package body ddr2_phy_bank_ctrl_pkg_tb is

	procedure run_bank_ctrl (variable num_bursts_exp: in integer; variable rows_arr_exp, bl_arr : in int_arr(0 to (MAX_OUTSTANDING_BURSTS - 1)); variable num_bursts_exp: out integer; variable rows_arr_exp : out int_arr(0 to (MAX_OUTSTANDING_BURSTS - 1)); variable seed1, seed2: inout positive) is
		variable delay	: integer;
	begin
		uniform(seed1, seed2, rand_val);
		delay := integer(rand_val*MAX_BURST_DELAY);

	end procedure run_bank_ctrl;

end package body ddr2_phy_bank_ctrl_pkg_tb;
