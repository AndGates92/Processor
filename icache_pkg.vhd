library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;

package icache_pkg is 

	constant VALID_L	: positive := 1;
	constant ICACHE_LINE	: positive := 128;
	constant ADDR_BRAM_L	: positive := int_to_bit_num(ICACHE_LINE);
	constant ICACHE_LINE_L	: positive := VALID_L + int_to_bit_num(PROGRAM_MEMORY) + INSTR_L;

	constant RESET		: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(2, STATE_L));
	constant BRAM_FWD	: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(3, STATE_L));
	constant WAIT_BRAM_DATA	: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(4, STATE_L));
	constant BRAM_RECV_DATA	: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(5, STATE_L));
	constant MEMORY_ACCESS	: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(6, STATE_L));

	component icache is
	generic (
		ADDR_MEM_L	: positive := 32
	);
	port (
		rst		: in std_logic;
		clk		: in std_logic;

		-- debug
		Hit		: out std_logic;

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

end package icache_pkg;
