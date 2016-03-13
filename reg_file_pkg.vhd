library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;

package reg_file_pkg is 

	component reg_file
	generic (
		REG_L	: positive := 16;
		REG_NUM	: positive := 16;
		OUT_NUM	: positive := 2;
		EN_L	: positive := 3
	);
	port (
		rst		: in std_logic;
		clk		: in std_logic;
		DataIn		: in std_logic_vector(REG_L - 1 downto 0);
		AddressIn	: in std_logic_vector(count_length(REG_NUM) - 1 downto 0);
		AddressOut1	: in std_logic_vector(count_length(REG_NUM) - 1 downto 0);
		AddressOut2	: in std_logic_vector(count_length(REG_NUM) - 1 downto 0);
		Enable		: in std_logic_vector(3-1 downto 0);
		Done		: out std_logic_vector(2-1 downto 0);
		End_LS		: out std_logic;
		DataOut1	: out std_logic_vector(REG_L-1 downto 0);
		DataOut2	: out std_logic_vector(REG_L-1 downto 0)
	);
	end component;
end package reg_file_pkg;
