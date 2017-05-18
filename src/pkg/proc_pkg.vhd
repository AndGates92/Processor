library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package proc_pkg is 

	function int_to_bit_num(op2_l : integer) return integer;
	function max_int(x, y : integer) return integer;

	constant PROC_CLK_PERIOD	: positive := 10; -- ns

	constant DATA_MEMORY_MB	: positive := 1; -- 1 MB
	constant DATA_MEMORY	: positive := DATA_MEMORY_MB*(integer(2.0**(3.0) * 2.0**(10.0)));

	constant PROGRAM_MEMORY_MB	: real := 0.5; -- 512 kB
	constant PROGRAM_MEMORY	: positive := integer(PROGRAM_MEMORY_MB*(2.0**(3.0) * 2.0**(10.0)));

	constant INSTR_L	: positive := 28;
	constant DATA_L		: positive := 28;

	constant INCR_PC	: positive := 4;
	constant INCR_PC_L	: positive := positive(int_to_bit_num(INCR_PC));

	constant STATE_L	: positive := 3;

	constant IDLE		: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(0, STATE_L));
	constant OUTPUT		: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(1, STATE_L));

end package proc_pkg;

package body proc_pkg is

	function int_to_bit_num(op2_l : integer) return integer is
		variable nbit, tmp	: integer;
	begin
		tmp := integer(ceil(log2(real(op2_l))));
		nbit := tmp;

		return nbit;
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

end package body proc_pkg;