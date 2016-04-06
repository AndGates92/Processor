library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.icache_pkg.all;
use work.proc_pkg.all;

entity bram is
	port(
		PortA_rst		: in std_logic;
		PortA_clk		: in std_logic;
		PortB_rst		: in std_logic;
		PortB_clk		: in std_logic;

		-- BRAM
		PortA_Address	: in std_logic_vector(ADDR_BRAM_L - 1 downto 0);
		PortA_Write	: in std_logic;
		PortA_DataIn	: in std_logic_vector(CACHE_LINE_L - 1 downto 0);
		PortA_DataOut	: out std_logic_vector(CACHE_LINE_L - 1 downto 0);

		PortB_Address	: in std_logic_vector(ADDR_BRAM_L - 1 downto 0);
		PortB_Write	: in std_logic;
		PortB_DataIn	: in std_logic_vector(CACHE_LINE_L - 1 downto 0);
		PortB_DataOut	: out std_logic_vector(CACHE_LINE_L - 1 downto 0);

	);
end entity bram;

architecture rtl of bram is
	type bram_t is array (CACHE_LINE - 1 downto 0) of std_logic_vector(CACHE_LINE_L - 1 downto 0);
	signal BRAMMemC, BRAMMemN	: bram_t;
	signal PortA_DataOutC, PortA_DataOutN	: std_logic_vector(CACHE_LINE_L - 1 downto 0);
	signal PortB_DataOutC, PortB_DataOutN	: std_logic_vector(CACHE_LINE_L - 1 downto 0);

begin

	reg: process(PortA_rst, PortA_clk)
	begin
		if (PortA_rst = '1') then

			BRAMMemC <= (others => (others => '0'));
			PortA_DataOutC <= (others => '0');

		elsif (rising_edge(PortA_clk)) then

			BRAMMemC <= BRAMemN;
			PortA_DataOutC <= PortA_DataOutN;

		end if;
	end process reg;

	PortA_DataOutN <= BRAMMemC(to_integer(unsigned(PortA_Address)));
	PortA_DataOut <= PortA_DataOutC;
	BRAMMemN(to_integer(unsigned(PortA_Address))) <= PortA_Datain when (PortA_Write = '1') else (others => '0');

	reg: process(PortB_rst, PortB_clk)
	begin
		if (PortB_rst = '1') then

			PortB_DataOutC <= (others => '0');

		elsif (rising_edge(PortB_clk)) then

			PortB_DataOutC <= PortB_DataOutN;

		end if;
	end process reg;

	PortB_DataOutN <= BRAMMemC(to_integer(unsigned(PortB_Address)));
	PortB_DataOut <= PortB_DataOutC;
	BRAMMemN(to_integer(unsigned(PortB_Address))) <= PortB_Datain when (PortB_Write = '1') else (others => '0');


end rtl;
