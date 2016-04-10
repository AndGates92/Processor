library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package proc_pkg is 

	function int_to_bit_num(op2_l : integer) return integer;

	constant DATA_MEMORY_MB	: positive := 1; -- 1 MB
	constant DATA_MEMORY	: positive := DATA_MEMORY_MB*(integer(2.0**(3.0) * 2.0**(10.0)));

	constant PROGRAM_MEMORY_MB	: real := 0.5; -- 256 kB
	constant PROGRAM_MEMORY	: positive := integer(PROGRAM_MEMORY_MB*(2.0**(3.0) * 2.0**(10.0)));

	constant INSTR_L	: positive := 28;

	constant STATE_L	: positive := 3;

	constant IDLE		: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(0, STATE_L));
	constant OUTPUT		: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(1, STATE_L));

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

end package proc_pkg;

package body proc_pkg is

	function int_to_bit_num(op2_l : integer) return integer is
		variable nbit, tmp	: integer;
	begin
		tmp := integer(ceil(log2(real(op2_l))));
		nbit := tmp;

		return nbit;
	end;
end package body proc_pkg;
