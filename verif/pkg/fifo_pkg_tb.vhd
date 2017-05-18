library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;
use work.tb_pkg.all;

package fifo_pkg_tb is 

	procedure fifo_push_op(signal ctrl_flag : in std_logic; constant PERIOD : in time; signal DataIn : out std_logic_vector(DATA_L_TB - 1 downto 0); signal Enable : out std_logic; variable seed1, seed2 : inout positive);

end package fifo_pkg_tb;

package body fifo_pkg_tb is

	procedure fifo_push_op(signal ctrl_flag : in std_logic; constant PERIOD : in time; signal DataIn : out std_logic_vector(DATA_L_TB - 1 downto 0); signal Enable : out std_logic; variable seed1, seed2 : inout positive) is
		variable DataIn_in	: integer;
		variable rand_val, sign_val	: real;
		variable En_in	: boolean;

	begin

		uniform(seed1, seed2, rand_val);
		DataIn_in := integer(rand_val*(2.0**(real(DATA_L_TB)) - 1.0));
		DataIn <= std_logic_vector(to_unsigned(DataIn_in, DATA_L_TB));

		if (ctrl_flag = '0') then
			uniform(seed1, seed2, rand_val);
			En_in := rand_bool(rand_val);
			Enable <= bool_to_std_logic(En_in), '0' after PERIOD;
		else
			Enable <= '0';
		end if;

		wait for PERIOD;

	end procedure fifo_push_op;


end package body fifo_pkg_tb;