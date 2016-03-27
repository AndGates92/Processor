library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package proc_pkg is 

	constant STATE_L	: positive := 3;

	constant IDLE		: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(0, STATE_L));
	constant OUTPUT		: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(1, STATE_L));

	function count_length(op2_l : integer) return integer;

end package proc_pkg;

package body proc_pkg is

	function count_length(op2_l : integer) return integer is
		variable nbit, tmp	: integer;
	begin
		tmp := integer(ceil(log2(real(op2_l))));
		nbit := tmp;

		return nbit;
	end;
end package body proc_pkg;
