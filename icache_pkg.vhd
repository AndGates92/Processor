library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;

package icache_pkg is 

	constant VALID_L		: positive := 1;
	constant CACHE_LINE		: positive := 128;
	constant CACHE_LINE_L		: positive := VALID_L + int_to_bit_num(PROGRAM_MEMORY) + INSTR_L;

	constant CACHE_LINE_SEARCH	: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(2, STATE_L));
	constant EXTRACT_DATA		: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(3, STATE_L));
	constant MEMORY_ACCESS		: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(4, STATE_L));

	component icache is
	generic (
		ADDR_MEM_L	: positive := 8
	);
	port (
		rst		: in std_logic;
		clk		: in std_logic;

		Start		: in std_logic;
		Done		: out std_logic;
		Instr		: out std_logic_vector(INSTR_L - 1 downto 0);
		Address		: in std_logic_vector(ADDR_MEM_L - 1 downto 0);

		-- Memory access
		DoneMemory	: in std_logic;
		EnableMemory	: out std_logic;
		AddressMem	: out std_logic_vector(ADDR_MEM_L - 1 downto 0);
		InstrOut	: in std_logic_vector(INSTR_L - 1 downto 0)
	);
	end component;

	type icache_line is std_logic_vector(CACHE_LINE_L - 1 downto 0);
	type icache_mem is array(0 to CACHE_LINE - 1) of icache_line;

end package icache_pkg;
