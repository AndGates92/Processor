library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;

package tb_pkg is 

	constant alu_log_file			: string := "alu.log";
	constant ctrl_log_file			: string := "ctrl.log";
	constant dcache_log_file		: string := "dcache.log";
	constant icache_log_file		: string := "icache.log";
	constant ddr2_phy_arbitrer_log_file	: string := "ddr2_phy_arbitrer.log";
	constant ddr2_phy_bank_ctrl_log_file	: string := "ddr2_phy_bank_ctrl.log";
	constant ddr2_phy_col_ctrl_log_file	: string := "ddr2_phy_col_ctrl.log";
	constant ddr2_phy_cmd_ctrl_log_file	: string := "ddr2_phy_cmd_ctrl.log";
	constant ddr2_phy_ref_ctrl_log_file	: string := "ddr2_phy_ref_ctrl.log";
	constant ddr2_phy_cmd_dec_log_file	: string := "ddr2_phy_cmd_dec.log";
	constant ddr2_phy_init_log_file		: string := "ddr2_phy_init.log";
	constant decode_log_file		: string := "decode.log";
	constant div_log_file			: string := "div.log";
	constant mul_log_file			: string := "mul.log";
	constant execute_dcache_log_file	: string := "execute_dcache.log";
	constant execute_log_file		: string := "execute.log";
	constant fifo_1clk_log_file		: string := "fifo_1clk.log";
	constant fifo_2clk_log_file		: string := "fifo_2clk.log";
	constant reg_file_log_file		: string := "reg_file.log";
	constant summary_file			: string := "summary";

	constant STAT_REG_L_TB	: positive := 8;
	constant EN_REG_FILE_L_TB	: positive := 3;
	constant REG_NUM_TB	: positive := 4;
	constant OP1_L_TB	: integer := DATA_L;
	constant OP2_L_TB	: integer := DATA_L;
	constant DATA_L_TB	: integer := DATA_L;

	constant int_arr_def	: integer := integer'high;

	type int_arr is array(integer range <>) of integer;
	type int_arr_2d is array(integer range <>, integer range <>) of integer;
	type int_arr_3d is array(integer range <>, integer range <>, integer range <>) of integer;
	type bool_arr is array(integer range <>) of boolean;
	type bool_arr_2d is array(integer range <>, integer range <>) of boolean;
	type bool_arr_3d is array(integer range <>, integer range <>, integer range <>) of boolean;


	procedure clk_gen (constant PERIOD : in time; constant PHASE : in time; signal stop : in boolean; signal clk : out std_logic);

	function max_time(time1, time2 : time) return time;
	function round(val : real) return integer;

	function rand_bool(rand_val, weight : real) return boolean;
	function rand_sign(sign_val, weight : real) return real;

	function reset_int_arr(val, num_el : integer) return int_arr;
	function compare_int_arr(arr1, arr2 : int_arr; num_el : integer) return boolean;
	function compare_int_arr_2d(arr1, arr2 : int_arr_2d; num_el1, num_el2 : integer) return boolean;
	function compare_int_arr_3d(arr1, arr2 : int_arr_3d; num_el1, num_el2, num_el3 : integer) return boolean;
	function reset_bool_arr(val : boolean; num_el : integer) return bool_arr;
	function compare_bool_arr(arr1, arr2 : bool_arr; num_el : integer) return boolean;
	function compare_bool_arr_2d(arr1, arr2 : bool_arr_2d; num_el1, num_el2 : integer) return boolean;
	function compare_bool_arr_3d(arr1, arr2 : bool_arr_3d; num_el1, num_el2, num_el3 : integer) return boolean;

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

	function rand_sign(sign_val, weight : real) return real is
		variable sign 	: real;
	begin
		assert (weight <= 1.0) report "weight must be less 1.0" severity FAILURE;
		if (sign_val > weight) then
			sign := -1.0;
		else
			sign := 1.0;
		end if;

		return sign;
	end function;

	function rand_bool(rand_val, weight : real) return boolean is
		variable bool	: boolean;
	begin
		assert (weight <= 1.0) report "weight must be less 1.0" severity FAILURE;
		if (rand_val > weight) then
			bool := True;
		else
			bool := False;
		end if;

		return bool;
	end function;

	function reset_int_arr(val, num_el : integer) return int_arr is
		variable arr : int_arr(0 to (num_el - 1));
	begin
		for i in 0 to (num_el-1) loop
			arr(i) := val;
		end loop;

		return arr;
	end;

	function compare_int_arr(arr1, arr2 : int_arr; num_el : integer) return boolean is
		variable match	: boolean;
	begin
		match := true;
		for i in 0 to (num_el-1) loop
			if (match = true) then
				if (arr1(i) /= arr2(i)) then
					match := false;
				end if;
			end if;
		end loop;

		return match;
	end;

	function compare_int_arr_2d(arr1, arr2 : int_arr_2d; num_el1, num_el2 : integer) return boolean is
		variable match	: boolean;
	begin
		match := true;
		for i in 0 to (num_el1-1) loop
			for j in 0 to (num_el2-1) loop
				if (match = true) then
					if (arr1(i, j) /= arr2(i, j)) then
						match := false;
					end if;
				end if;
			end loop;
		end loop;

		return match;
	end;

	function compare_int_arr_3d(arr1, arr2 : int_arr_3d; num_el1, num_el2, num_el3 : integer) return boolean is
		variable match	: boolean;
	begin
		match := true;
		for i in 0 to (num_el1-1) loop
			for j in 0 to (num_el2-1) loop
				for z in 0 to (num_el3-1) loop
					if (match = true) then
						if (arr1(i, j, z) /= arr2(i, j, z)) then
							match := false;
						end if;
					end if;
				end loop;
			end loop;
		end loop;

		return match;
	end;

	function reset_bool_arr(val : boolean; num_el : integer) return bool_arr is
		variable arr : bool_arr(0 to (num_el - 1));
	begin
		for i in 0 to (num_el-1) loop
			arr(i) := val;
		end loop;

		return arr;
	end;

	function compare_bool_arr(arr1, arr2 : bool_arr; num_el : integer) return boolean is
		variable match	: boolean;
	begin
		match := true;
		for i in 0 to (num_el-1) loop
			if (match = true) then
				if (arr1(i) /= arr2(i)) then
					match := false;
				end if;
			end if;
		end loop;

		return match;
	end;

	function compare_bool_arr_2d(arr1, arr2 : bool_arr_2d; num_el1, num_el2 : integer) return boolean is
		variable match	: boolean;
	begin
		match := true;
		for i in 0 to (num_el1-1) loop
			for j in 0 to (num_el2-1) loop
				if (match = true) then
					if (arr1(i, j) /= arr2(i, j)) then
						match := false;
					end if;
				end if;
			end loop;
		end loop;

		return match;
	end;

	function compare_bool_arr_3d(arr1, arr2 : bool_arr_3d; num_el1, num_el2, num_el3 : integer) return boolean is
		variable match	: boolean;
	begin
		match := true;
		for i in 0 to (num_el1-1) loop
			for j in 0 to (num_el2-1) loop
				for z in 0 to (num_el3-1) loop
					if (match = true) then
						if (arr1(i, j, z) /= arr2(i, j, z)) then
							match := false;
						end if;
					end if;
				end loop;
			end loop;
		end loop;

		return match;
	end;

	function round(val : real) return integer is
		variable rounded_val	: integer;
		variable floor_val	: real;
		variable decimal_val	: real;
	begin
		floor_val := real(integer(val)); -- chop off decimal part
		decimal_val := val - floor_val;
		if (decimal_val < 0.5) then
			rounded_val := integer(val);
		else
			rounded_val := integer(val) + 1;
		end if;

		return rounded_val;
	end;
end package body tb_pkg;
