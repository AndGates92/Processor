library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.icache_pkg.all;
use work.proc_pkg.all;

entity bram is
generic(
	ADDR_BRAM_L	: positive := 10;
	DATA_L		: positive := 100;
port (
	-- Port A
	PortA_clk   : in  std_logic;
	PortA_Write    : in  std_logic;
	PortA_Address  : in  std_logic_vector(ADDR_BRAM_L-1 downto 0);
	PortA_DataIn   : in  std_logic_vector(DATA_L-1 downto 0);
	PortA_DataOut  : out std_logic_vector(DATA_L-1 downto 0);

	-- Port B
	PortB_clk   : in  std_logic;
	PortB_Write    : in  std_logic;
	PortB_Address  : in  std_logic_vector(ADDR_BRAM_L-1 downto 0);
	PortB_DataIn   : in  std_logic_vector(DATA_L-1 downto 0);
	PortB_DataOut  : out std_logic_vector(DATA_L-1 downto 0)
);
end bram;
 
architecture rtl of bram is
	type mem_type is array ( (2**ADDR_BRAM_L)-1 downto 0 ) of std_logic_vector(DATA_L-1 downto 0);
	signal mem : mem_type;
	signal PortA_DataOutC, PortA_DataOutN : std_logic_vector(DATA_L-1 downto 0);
	signal PortB_DataOutC, PortB_DataOutN : std_logic_vector(DATA_L-1 downto 0);
begin
 
	-- Port A
	portA_reg: process(PortA_clk)
	begin
		if (rising_edge(PortA_clk)) then
			if (PortA_Write = '1') then
				mem(to_integer(unsigned(PortA_Address))) <= PortA_DataIn;
			end if;

			PortA_DataOutC <= PortA_DataOutN;
		end if;
	end process portA_reg;

	PortA_DataOutN <= mem(to_integer(unsigned(PortA_Address)));
	PortA_DataOut <=  PortA_DataOutC;

	-- Port B
	portB_reg: process(PortB_clk)
	begin
		if (rising_edge(PortB_clk)) then
			if (PortB_Write = '1') then
				mem(to_integer(unsigned(PortB_Address))) <= PortB_DataIn;
			end if;

			PortB_DataOutC <= PortB_DataOutN;
		end if;
	end process portB_reg;

	PortB_DataOutN <= mem(to_integer(unsigned(PortB_Address)));
	PortB_DataOut <=  PortB_DataOutC; 

end rtl;
