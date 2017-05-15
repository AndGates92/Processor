library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.alu_pkg.all;
use work.ctrl_pkg.all;
use work.decode_pkg.all;
use work.proc_pkg.all;

package tb_pkg is 

	constant log_file	: string := "summary.log";
	constant summary_file	: string := "summary";

	constant STAT_REG_L_TB	: positive := 8;
	constant EN_REG_FILE_L_TB	: positive := 3;
	constant REG_NUM_TB	: positive := 4;
	constant OP1_L_TB	: integer := DATA_L;
	constant OP2_L_TB	: integer := DATA_L;
	constant DATA_L_TB	: integer := DATA_L;

	constant int_arr_def	: integer := integer'high;

	type int_arr is array(integer range <>) of integer;

	procedure clk_gen (constant PERIOD : in time; constant PHASE : in time; signal stop : in boolean; signal clk : out std_logic);

	function rand_num return real;
	function max_time(time1, time2 : time) return time;
	function rand_bool(rand_val : real) return boolean;
	function rand_sign(sign_val : real) return real;
	function std_logic_to_bool(val : std_logic) return boolean;
	function bool_to_std_logic(val : boolean) return std_logic;
	function bool_to_str(val : boolean) return string;
	function compare_int_arr(arr1, arr2 : int_arr; num_el : integer) return boolean;

end package tb_pkg;

package body tb_pkg is

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

	function rand_num return real is
		variable seed1, seed2	: positive;
		variable rand_val	: real;
	begin
		uniform(seed1, seed2, rand_val);
		return rand_val;
	end function;

	function max_time(time1, time2 : time) return time is
		variable max	: time;
	begin
		if (time1 > time2) then
			max := time1;
		else
			max := time2;
		end if;

		return max;
	end function;

	function rand_sign(sign_val : real) return real is
		variable sign 	: real;
	begin
		if (sign_val > 0.5) then
			sign := -1.0;
		else
			sign := 1.0;
		end if;

		return sign;
	end function;

	function rand_bool(rand_val : real) return boolean is
		variable bool	: boolean;
	begin
		if (rand_val > 0.5) then
			bool := True;
		else
			bool := False;
		end if;

		return bool;
	end function;

	function std_logic_to_bool(val : std_logic) return boolean is
		variable val_conv	: boolean;
	begin
		if (val = '1') then
			val_conv := True;
		else
			val_conv := False;
		end if;

		return val_conv;
	end;

	function bool_to_std_logic(val : boolean) return std_logic is
		variable val_conv	: std_logic;
	begin
		if (val = true) then
			val_conv := '1';
		else
			val_conv := '0';
		end if;

		return val_conv;
	end;

	function bool_to_str(val : boolean) return string is
		variable val_conv	: string(1 to 5);
	begin
		if (val = true) then
			val_conv := "True ";
		else
			val_conv := "False";
		end if;

		return val_conv;
	end;

	function compare_int_arr(arr1, arr2 : int_arr; num_el : integer) return boolean is
		variable match	: boolean;
	begin
		match := true;
		for i in 0 to num_el loop
			if (match = true) then
				if (arr1(i) /= arr2(i)) then
					match := false;
				end if;
			end if;
		end loop;

		return match;
	end;
end package body tb_pkg;
