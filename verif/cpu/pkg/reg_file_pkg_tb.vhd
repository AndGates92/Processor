library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.reg_file_pkg.all;
use work.proc_pkg.all;
use work.cpu_tb_pkg.all;
use work.cpu_log_pkg.all;

package reg_file_pkg_tb is 

	type reg_file_array is array(0 to REG_NUM_TB-1) of integer;

	procedure reg_file_ref(variable RegFileIn_int: in reg_file_array; variable DataIn_int : in integer; variable AddressIn_int: in integer; variable AddressOut1_int : in integer; variable AddressOut2_int: in integer; variable Enable_int: in integer; variable Done_int: out integer; variable DataOut1_int: out integer; variable DataOut2_int : out integer; variable RegFileOut_int: out reg_file_array);

end package reg_file_pkg_tb;

package body reg_file_pkg_tb is

	procedure reg_file_ref(variable RegFileIn_int: in reg_file_array; variable DataIn_int : in integer; variable AddressIn_int: in integer; variable AddressOut1_int : in integer; variable AddressOut2_int: in integer; variable Enable_int: in integer; variable Done_int: out integer; variable DataOut1_int: out integer; variable DataOut2_int : out integer; variable RegFileOut_int: out reg_file_array) is
		variable Enable_vec	: std_logic_vector(EN_REG_FILE_L_TB - 1 downto 0);
		variable Done_tmp	: integer;
	begin

		Done_tmp := 0;
		RegFileOut_int := RegFileIn_int;
		Enable_vec := std_logic_vector(to_unsigned(Enable_int,EN_REG_FILE_L_TB));

		if (Enable_vec(1) = '1') then
			DataOut1_int := RegFileIn_int(AddressOut1_int);
			Done_tmp := Done_tmp + 1;
		else
			DataOut1_int := 0;
		end if;

		if (Enable_vec(2) = '1') then
			DataOut2_int := RegFileIn_int(AddressOut2_int);
			Done_tmp := Done_tmp + 2;
		else
			DataOut2_int := 0;
		end if;

		if (Enable_vec(0) = '1') then
			RegFileOut_int(AddressIn_int) := DataIn_int;
		end if;

		Done_int := Done_tmp;

	end procedure reg_file_ref;

end package body reg_file_pkg_tb;
