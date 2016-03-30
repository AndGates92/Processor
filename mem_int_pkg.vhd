library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package mem_int_pkg is 

	component mem_int is
	generic (
		ADDR_L		: positive := 16;
		REG_L		: positive := 32
	);
	port (

		rst		: in std_logic;
		clk		: in std_logic;

		-- Memory access
		DoneMemory	: out std_logic;
		ReadMem		: in std_logic;
		EnableMemory	: in std_logic;
		DataMemIn	: in std_logic_vector(REG_L - 1 downto 0);
		AddressMem	: in std_logic_vector(ADDR_L - 1 downto 0);
		DataMemOut	: out std_logic_vector(REG_L - 1 downto 0)

	);
	end component;

end package reg_file_pkg;
