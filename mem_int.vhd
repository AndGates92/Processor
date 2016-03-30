library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.mem_int_pkg.all;

entity mem_int is
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
end entity mem_int;

architecture dummy of mem_int is

	signal DoneMemoryN, DoneMemoryC	 : std_logic;

begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then

			DoneMemoryC <= '0';

		elsif (rising_edge(clk)) then

			DoneMemoryC <= DoneMemoryN;

		end if;
	end process reg;

	DoneMemoryN <= EnableMemory;

	DoneMemory <= DoneMemoryC;
	DataMemOut <= (others => '0');

end dummy;
