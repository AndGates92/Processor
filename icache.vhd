library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.icache_pkg.all;
use work.proc_pkg.all;

entity icache is
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
end entity icache;

architecture rtl of icache is

	constant ZERO_MATCH		: std_logic_vector(CACHE_LINE - 1 downto 0) := (others => '0');

	signal ICacheN, ICacheC		: icache_mem;
	signal CachePtrN, CachePtrC	: unsigned(int_to_bit_num(CACHE_LINE) - 1 downto 0);
	signal StateN, StateC		: std_logic_vector(STATE_L - 1 downto 0);
	signal MatchLineVecN, MatchLineVecC	: std_logic_vector(CACHE_LINE - 1 downto 0);
	signal AddressN, AddressC	: std_logic_vector(ADDR_MEM_L - 1 downto 0);
	signal HitC, HitN		: std_logic;

	signal InstrN, InstrC		: std_logic_vector(INSTR_L - 1 downto 0);

begin

	state_det: process(StateC, Start, MatchLineVecC, DoneMemory)
	begin
		StateN <= StateC; -- avoid latches
		if (StateC = IDLE) then
			if (Start = '0') then
				StateN <= IDLE;
			else
				StateN <= CACHE_LINE_SEARCH;
			end if;
		elsif (StateC = CACHE_LINE_SEARCH) then
			StateN <= EXTRACT_DATA;
		elsif (StateC = EXTRACT_DATA) then
			if (MatchLineVecC = ZERO_MATCH) then
				StateN <= MEMORY_ACCESS;
			else
				StateN <= OUTPUT;
			end if;
		elsif (StateC = MEMORY_ACCESS) then
			if (DoneMemory = '1') then
				StateN <= OUTPUT;
			else
				StateN <= StateC;
			end if;
		elsif (StateC = OUTPUT) then
			StateN <= IDLE;
		else
			StateN <= StateC;
		end if;
	end process state_det;

	reg: process(rst, clk)
	begin
		if (rst = '1') then

			InstrC <= (others => '0');
			HitC <= '0';
			MatchLineVecC <= (others => '0');
			StateC <= IDLE;
			CachePtrC <= (others => '0');
			ICacheC <= (others => (others => '0'));
			AddressC <= (others => '0');

		elsif (rising_edge(clk)) then

			InstrC <= InstrN;
			HitC <= HitN;
			MatchLineVecC <= MatchLineVecN;
			StateC <= StateN;
			CachePtrC <= CachePtrN;
			ICacheC <= ICacheN;
			AddressC <= AddressN;

		end if;
	end process reg;

	AddressN <= Address when (StateC = IDLE) else AddressC;
	HitN <=	'0' when (StateC = IDLE) else
		'1' when (MatchLineVecC /= ZERO_MATCH) else
		HitC;

	EnableMemory <= not HitC when (StateC = MEMORY_ACCESS) else '0';
	AddressMem <= AddressC;

	Instr <= InstrC when (StateC = OUTPUT) else (others => '0');
	Done <= '1' when (StateC = OUTPUT) else '0';

	CachePtrN <=	CachePtrC + 1 when (StateC = MEMORY_ACCESS) and ICacheC(to_integer(CachePtrC))(icache_line'length - 1 downto icache_line'length - 1) = '1') and ICacheC(to_integer(CachePtrC + 1))(icache_line'length - 1 downto icache_line'length - 1) = '0') and (DoneMemory = '1') else
			--CachePtrC + 1 when (StateC = CACHE_LINE_SEARCH) and ICacheC(to_integer(CachePtrC))(icache_line'length - 1 downto icache_line'length - 1) = '1') and ICacheC(to_integer(CachePtrC + 1))(icache_line'length - 1 downto icache_line'length - 1) = '0') else
			CachePtrC when ((StateC = MEMORY_ACCESS) and ICacheC(to_integer(CachePtrC))(icache_line'length - 1 downto icache_line'length - 1) = '0')) or (StateC /= CACHE_LINE_SEARCH) else
			(others => '0');

	CACHE_OP: for i in 0 to (CACHE_LINE - 1) generate
		STORE_INSTR: if (to_unsigned(i, CachePtrC'length) = CachePtrC) and (DoneMemory = '1') then
			CacheN(i)(icache_line'length - 1 downto icache_line'length - 1) <= '1';
			CacheN(i)(icache_line'length - 2 downto icache_line'length - int_to_bit_num(PROGRAM_MEMORY)) <= (AddressC(int_to_bit_num(PROGRAM_MEMORY) - 1 downto 0));
			CacheN(i)(icache_line'length - int_to_bit_num(PROGRAM_MEMORY) - 1 downto 0) <= InstrOut;
		else
			CacheN(i) <= CacheC(i);
		end generate STORE_INSTR;

		MATCH: if (StateC = CACHE_LINE_SEARCH) and (AddressC(int_to_bit_num(PROGRAM_MEMORY) - 1 downto 0) = CacheN(i)(icache_line'length - 2 downto icache_line'length - int_to_bit_num(PROGRAM_MEMORY))) generate
			MatchLineVecN(i) <= '1';
			InstrN <= CacheN(i)(icache_line'length - int_to_bit_num(PROGRAM_MEMORY) - 1 downto 0);
		else
			MatchLineVecN(i) <= '0';
		end generate MATCH;
	end generate CACHE_OP;


			

end rtl;
