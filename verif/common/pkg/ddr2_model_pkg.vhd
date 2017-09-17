library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package ddr2_model_pkg is 

	component ddr2_model is
	generic (
		ADDR_L		: positive := 16;
		DATA_L		: positive := 32
	);
	port (

		rst		: in std_logic;
		clk		: in std_logic;

		-- Memory access
		DoneMemory	: out std_logic;
		ReadMem		: in std_logic;
		EnableMemory	: in std_logic;
		DataMemIn	: in std_logic_vector(DATA_L - 1 downto 0);
		AddressMem	: in std_logic_vector(ADDR_L - 1 downto 0);
		DataMemOut	: out std_logic_vector(DATA_L - 1 downto 0)

	);
	end component;

end package ddr2_model_pkg;
