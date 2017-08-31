library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package bram_pkg is 

	constant STATE_BRAM_L	: positive := 2;

	constant BRAM_IDLE	: std_logic_vector(STATE_BRAM_L - 1 downto 0) := std_logic_vector(to_unsigned(0, STATE_BRAM_L));
	constant BRAM_OUTPUT	: std_logic_vector(STATE_BRAM_L - 1 downto 0) := std_logic_vector(to_unsigned(1, STATE_BRAM_L));
	constant GEN_ADDR	: std_logic_vector(STATE_BRAM_L - 1 downto 0) := std_logic_vector(to_unsigned(2, STATE_BRAM_L));

	component bram_rst is
	generic (
		ADDR_L	: positive := 32
	);
	port (
		rst		: in std_logic;
		clk		: in std_logic;

		Start		: in std_logic;
		Done		: out std_logic;
		PortA_Address	: out std_logic_vector(ADDR_L - 1 downto 0);
		PortB_Address	: out std_logic_vector(ADDR_L - 1 downto 0)
	);
	end component;

	component bram_1port is
	generic(
		ADDR_BRAM_L	: positive := 10;
		BRAM_LINE	: positive := 128;
		DATA_L		: positive := 100
	);
	port (
		-- Port A
		PortA_clk	: in  std_logic;
		PortA_Write	: in  std_logic;
		PortA_Address	: in  std_logic_vector(ADDR_BRAM_L-1 downto 0);
		PortA_DataIn	: in  std_logic_vector(DATA_L-1 downto 0);
		PortA_DataOut	: out std_logic_vector(DATA_L-1 downto 0)
	);
	end component;

	component bram_2port is
	generic(
		ADDR_BRAM_L	: positive := 10;
		BRAM_LINE	: positive := 128;
		DATA_L		: positive := 100
	);
	port (
		-- Port A
		PortA_clk	: in  std_logic;
		PortA_Write	: in  std_logic;
		PortA_Address	: in  std_logic_vector(ADDR_BRAM_L-1 downto 0);
		PortA_DataIn	: in  std_logic_vector(DATA_L-1 downto 0);
		PortA_DataOut	: out std_logic_vector(DATA_L-1 downto 0);

		-- Port B
		PortB_clk	: in  std_logic;
		PortB_Write	: in  std_logic;
		PortB_Address	: in  std_logic_vector(ADDR_BRAM_L-1 downto 0);
		PortB_DataIn	: in  std_logic_vector(DATA_L-1 downto 0);
		PortB_DataOut	: out std_logic_vector(DATA_L-1 downto 0)
	);
	end component;

end package bram_pkg;

