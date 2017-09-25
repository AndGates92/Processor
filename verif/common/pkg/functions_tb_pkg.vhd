library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.shared_tb_pkg.all;

package functions_tb_pkg is 

	function max_time(time1, time2 : time) return time;
	function round(val : real) return integer;

	function rand_bool(rand_val, weight : real) return boolean;
	function rand_sign(sign_val, weight : real) return real;

	function reset_int_arr(val, num_el : integer) return int_arr;
	function reset_int_arr_2d(val, num_el1, num_el2 : integer) return int_arr_2d;
	function reset_int_arr_3d(val, num_el1, num_el2, num_el3 : integer) return int_arr_3d;
	function compare_int_arr(arr1, arr2 : int_arr; num_el : integer) return boolean;
	function compare_int_arr_2d(arr1, arr2 : int_arr_2d; num_el1, num_el2 : integer) return boolean;
	function compare_int_arr_3d(arr1, arr2 : int_arr_3d; num_el1, num_el2, num_el3 : integer) return boolean;
	function reset_bool_arr(val : boolean; num_el : integer) return bool_arr;
	function reset_bool_arr_2d(val : boolean; num_el1, num_el2 : integer) return bool_arr_2d;
	function reset_bool_arr_3d(val : boolean; num_el1, num_el2, num_el3 : integer) return bool_arr_3d;
	function compare_bool_arr(arr1, arr2 : bool_arr; num_el : integer) return boolean;
	function compare_bool_arr_2d(arr1, arr2 : bool_arr_2d; num_el1, num_el2 : integer) return boolean;
	function compare_bool_arr_3d(arr1, arr2 : bool_arr_3d; num_el1, num_el2, num_el3 : integer) return boolean;

end package functions_tb_pkg;

package body functions_tb_pkg is

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

	function reset_int_arr_2d(val, num_el1, num_el2 : integer) return int_arr_2d is
		variable arr : int_arr_2d(0 to (num_el1 - 1), 0 to (num_el2 - 1));
	begin
		for i in 0 to (num_el1-1) loop
			for j in 0 to (num_el2-1) loop
				arr(i, j) := val;
			end loop;
		end loop;

		return arr;
	end;

	function reset_int_arr_3d(val, num_el1, num_el2, num_el3 : integer) return int_arr_3d is
		variable arr : int_arr_3d(0 to (num_el1 - 1), 0 to (num_el2-1), 0 to (num_el3-1));
	begin
		for i in 0 to (num_el1-1) loop
			for j in 0 to (num_el2-1) loop
				for z in 0 to (num_el3-1) loop
					arr(i, j, z) := val;
				end loop;
			end loop;
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

	function reset_bool_arr_2d(val : boolean; num_el1, num_el2 : integer) return bool_arr_2d is
		variable arr : bool_arr_2d(0 to (num_el1 - 1), 0 to (num_el2 - 1));
	begin
		for i in 0 to (num_el1-1) loop
			for j in 0 to (num_el2-1) loop
				arr(i, j) := val;
			end loop;
		end loop;

		return arr;
	end;

	function reset_bool_arr_3d(val : boolean; num_el1, num_el2, num_el3 : integer) return bool_arr_3d is
		variable arr : bool_arr_3d(0 to (num_el1 - 1), 0 to (num_el2-1), 0 to (num_el3-1));
	begin
		for i in 0 to (num_el1-1) loop
			for j in 0 to (num_el2-1) loop
				for z in 0 to (num_el3-1) loop
					arr(i, j, z) := val;
				end loop;
			end loop;
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
end package body functions_tb_pkg;
