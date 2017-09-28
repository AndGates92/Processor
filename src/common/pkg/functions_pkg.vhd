library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package functions_pkg is 

	function int_to_bit_num(arg : integer) return integer;
	function min_int(x, y : integer) return integer;
	function max_int(x, y : integer) return integer;
	function max_real(x, y : real) return real;
	function max_std_logic(x, y : std_logic) return integer;

end package functions_pkg;

package body functions_pkg is

	function int_to_bit_num(arg : integer) return integer is
		variable nbit, tmp	: integer;
	begin

		assert (arg > 0) report "arg of int_to_bit_num must nbe larger than 0" severity ERROR;
		if (arg = 1) then
			tmp := 1;
		else
			tmp := integer(ceil(log2(real(arg))));
		end if;
		nbit := tmp;

		return nbit;
	end;

	function min_int(x, y : integer) return integer is
		variable max_val	: integer;
	begin
		if (x <= y) then
			max_val := x;
		else
			max_val := y;
		end if;

		return max_val;
	end;

	function max_int(x, y : integer) return integer is
		variable max_val	: integer;
	begin
		if (x > y) then
			max_val := x;
		else
			max_val := y;
		end if;

		return max_val;
	end;

	function max_real(x, y : real) return real is
		variable max_val	: real;
	begin
		if (x > y) then
			max_val := x;
		else
			max_val := y;
		end if;

		return max_val;
	end;

	function max_std_logic(x, y : std_logic) return integer is
		variable max_val	: integer;
	begin
		if ((x = '1') or (y = '1')) then
			max_val := 1;
		else
			max_val := 0;
		end if;

		return max_val;
	end;

end package body functions_pkg;
