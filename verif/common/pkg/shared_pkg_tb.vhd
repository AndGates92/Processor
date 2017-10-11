library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

package shared_pkg_tb is 

	constant summary_file			: string := "summary";

	constant int_arr_def	: integer := integer'high;

	type int_arr is array(integer range <>) of integer;
	type int_arr_2d is array(integer range <>, integer range <>) of integer;
	type int_arr_3d is array(integer range <>, integer range <>, integer range <>) of integer;
	type bool_arr is array(integer range <>) of boolean;
	type bool_arr_2d is array(integer range <>, integer range <>) of boolean;
	type bool_arr_3d is array(integer range <>, integer range <>, integer range <>) of boolean;

	procedure clk_gen (constant PERIOD : in time; constant PHASE : in time; signal stop : in boolean; signal clk : out std_logic);

end package shared_pkg_tb;

package body shared_pkg_tb is

	procedure clk_gen (constant PERIOD : in time; constant PHASE : in time; signal stop : in boolean; signal clk : out std_logic) is
		variable clk_tmp	: std_logic;
	begin
		assert (PERIOD > 0 fs) report "zero clock period" severity FAILURE;

		clk <= '0';
		clk_tmp := '0';
		wait for PHASE;

		while not stop loop
			clk <= not clk_tmp;
			clk_tmp := not clk_tmp;
			wait for (PERIOD/2);
		end loop;

	end procedure clk_gen;

end package body shared_pkg_tb;
