library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.dcache_pkg.all;
use work.bram_pkg.all;
use work.functions_pkg.all;

entity dcache is
generic (
	ADDR_MEM_L	: positive := 32
);
port (
	rst		: in std_logic;
	clk		: in std_logic;

	-- debug
	Hit		: out std_logic;
	EndRst		: out std_logic;

	Start		: in std_logic;
	Done		: out std_logic;
	DataOut		: out std_logic_vector(DATA_L - 1 downto 0);
	DataIn		: in std_logic_vector(DATA_L - 1 downto 0);
	Read		: in std_logic;
	Address		: in std_logic_vector(ADDR_MEM_L - 1 downto 0);

	-- Memory access
	DoneMemory	: in std_logic;
	EnableMemory	: out std_logic;
	AddressMem	: out std_logic_vector(ADDR_MEM_L - 1 downto 0);
	DataMemIn	: out std_logic_vector(DATA_L - 1 downto 0);
	ReadMem		: out std_logic;
	DataMemOut	: in std_logic_vector(DATA_L - 1 downto 0)
);
end entity dcache;

architecture rtl_bram_1port of dcache is

	signal rstN, rstC		: std_logic;
	signal EndRstN, EndRstC		: std_logic;

	signal StateN, StateC		: std_logic_vector(STATE_DCACHE_L - 1 downto 0);
	signal HitC, HitN		: std_logic;
	signal DataOutN, DataOutC	: std_logic_vector(DATA_L - 1 downto 0);
	signal DataInN, DataInC		: std_logic_vector(DATA_L - 1 downto 0);
	signal AddressN, AddressC	: std_logic_vector(ADDR_MEM_L - 1 downto 0);
	signal ReadN, ReadC		: std_logic;

	-- BRAM
	signal PortA_AddressN, PortA_AddressC	: std_logic_vector(ADDR_BRAM_L - 1 downto 0);
	signal PortA_DataInN, PortA_DataInC	: std_logic_vector(DCACHE_LINE_L - 1 downto 0);
	signal PortA_DataOutN, PortA_DataOutC	: std_logic_vector(DCACHE_LINE_L - 1 downto 0);
	signal PortA_WriteN, PortA_WriteC	: std_logic;

	signal DoneReset	: std_logic;
	signal PortA_Address_rst	: std_logic_vector(ADDR_BRAM_L - 1 downto 0);

	-- BRAM connections
	signal PortA_Address	: std_logic_vector(ADDR_BRAM_L - 1 downto 0);
	signal PortA_Write	: std_logic;
	signal PortA_DataIn	: std_logic_vector(DCACHE_LINE_L - 1 downto 0);
	signal PortA_DataOut	: std_logic_vector(DCACHE_LINE_L - 1 downto 0);

begin

	state_det: process(StateC, Start, PortA_DataOut, AddressC, DoneMemory, DoneReset, ReadC)
	begin
		StateN <= StateC; -- avoid latches
		if (StateC = DCACHE_IDLE) then
			if (Start = '0') then
				StateN <= DCACHE_IDLE;
			else
				StateN <= BRAM_FWD;
			end if;
		elsif (StateC = RESET) then
			if (DoneReset = '1') then
				StateN <= DCACHE_OUTPUT;
			else
				StateN <= StateC;
			end if;
		elsif (StateC = BRAM_FWD) then
			StateN <= WAIT_BRAM_DATA;
		elsif (StateC = WAIT_BRAM_DATA) then
			StateN <= BRAM_RECV_DATA;
		elsif (StateC = BRAM_RECV_DATA) then
			if ((ReadC = '1') and (PortA_DataOut(DCACHE_LINE_L - DIRTY_BIT_L - 1 downto (DCACHE_LINE_L - int_to_bit_num(DATA_MEMORY) - DIRTY_BIT_L - VALID_L)) = ("1" & AddressC(int_to_bit_num(DATA_MEMORY) - 1 downto 0))))  then
				StateN <= DCACHE_OUTPUT;
			elsif ((ReadC = '0') and (PortA_DataOut(DCACHE_LINE_L - DIRTY_BIT_L - 1 downto (DCACHE_LINE_L - int_to_bit_num(DATA_MEMORY) - DIRTY_BIT_L - VALID_L)) = ("1" & AddressC(int_to_bit_num(DATA_MEMORY) - 1 downto 0))) and (PortA_DataOut(DCACHE_LINE_L - 1) = '0'))  then
				StateN <= WRITE_BRAM;
			else
				StateN <= MEMORY_ACCESS;
			end if;
		elsif (StateC = MEMORY_ACCESS) then
			if (DoneMemory = '1') then
				StateN <= DCACHE_OUTPUT;
			else
				StateN <= StateC;
			end if;
		elsif (StateC = WRITE_BRAM) then
			StateN <= DCACHE_OUTPUT;
		elsif (StateC = DCACHE_OUTPUT) then
			StateN <= DCACHE_IDLE;
		else
			StateN <= StateC;
		end if;
	end process state_det;

	reg: process(rst, clk)
	begin
		if (rst = '1') then

			rstC <= '1';
			EndRstC <= '0';

			DataOutC <= (others => '0');
			DataInC <= (others => '0');
			HitC <= '0';
			StateC <= RESET;
			AddressC <= (others => '0');
			ReadC <= '0';

			PortA_AddressC <= (others => '0');
			PortA_WriteC <= '0';
			PortA_DataInC <= (others => '0');
			PortA_DataOutC <= (others => '0');

		elsif ((clk'event) and (clk = '1')) then

			rstC <= rstN;
			EndRstC <= EndRstN;

			DataOutC <= DataOutN;
			DataInC <= DataInN;
			HitC <= HitN;
			StateC <= StateN;
			AddressC <= AddressN;
			ReadC <= ReadN;

			PortA_AddressC <= PortA_AddressN;
			PortA_WriteC <= PortA_WriteN;
			PortA_DataInC <= PortA_DataInN;
			PortA_DataOutC <= PortA_DataOutN;
		end if;
	end process reg;

	rstN <= rst;
	EndRstN <=	'0' when (StateC = RESET) else
			'1' when (StateC = DCACHE_OUTPUT) else
			EndRstC;

	EndRst <= EndRstC;

	AddressN <= Address when (StateC = DCACHE_IDLE) else AddressC;
	ReadN <= Read when (StateC = DCACHE_IDLE) else ReadC;
	DataInN <= DataIn when (StateC = DCACHE_IDLE) else DataInC;

	HitN <=	'0' when (StateC = DCACHE_IDLE) else
		'1' when (StateC = BRAM_RECV_DATA) and (PortA_DataOut(DCACHE_LINE_L - DIRTY_BIT_L - 1 downto DCACHE_LINE_L - DIRTY_BIT_L - int_to_bit_num(DATA_MEMORY) - VALID_L) = ("1" & AddressC(int_to_bit_num(DATA_MEMORY) - 1 downto 0))) else
		HitC;

	DataOutN <=	(others => '0') when (StateC = DCACHE_IDLE) else
			PortA_DataOut(DATA_L - 1 downto 0) when (Read = '1') and (StateC = BRAM_RECV_DATA) else
			DataMemOut when (StateC = MEMORY_ACCESS) else
			DataOutC;

	EnableMemory <= '1' when (StateC = MEMORY_ACCESS) else '0';

	AddressMem <= AddressC;
	DataMemIn <= PortA_DataOutC(DATA_L - 1 downto 0);
	DataOut <= DataOutC when (StateC = DCACHE_OUTPUT) else (others => '0');
	Done <= '1' when (StateC = DCACHE_OUTPUT) else '0';
	Hit <= '0' when (StateC = DCACHE_IDLE) else HitC;

	-- MSB is dirty bit and MSB-1 is valid bit
	-- Store only relevant address bits depending on the data memory size
	PortA_DataInN <=	"11" & AddressC(int_to_bit_num(DATA_MEMORY) - 1 downto 0) & DataInC when (StateC = WRITE_BRAM) or ((StateC = MEMORY_ACCESS) and (ReadC = '0')) else
				"01" & AddressC(int_to_bit_num(DATA_MEMORY) - 1 downto 0) & DataMemOut when (StateC = MEMORY_ACCESS) and (ReadC = '1') else
				(others => '0') when (StateC = DCACHE_IDLE) or (StateC = RESET) else
				PortA_DataInC;

	PortA_DataOutN <=	PortA_DataOut when (StateC = BRAM_RECV_DATA) else
				(others => '0') when (StateC = DCACHE_IDLE) else
				PortA_DataOutC;

	PortA_AddressN <=	PortA_Address_rst when (StateC = RESET) else
				AddressC(ADDR_BRAM_L + INCR_PC_L - 1 downto INCR_PC_L) when (StateC = BRAM_FWD) or (StateC = MEMORY_ACCESS) else
				(others => '0') when (StateC = DCACHE_IDLE) else
				PortA_AddressC;

	PortA_WriteN <=	'1' when (StateC = MEMORY_ACCESS) or (StateC = WRITE_BRAM) or (StateC = RESET) else
			'0' when (StateC = DCACHE_IDLE) else
			PortA_WriteC;

	PortA_DataIn <= PortA_DataInC;
	PortA_Address <= PortA_AddressC;
	PortA_Write <= '0' when(StateC = DCACHE_IDLE) else PortA_WriteC;

	BRAM_1PORT_I : bram_1port generic map(
		ADDR_BRAM_L => ADDR_BRAM_L,
		BRAM_LINE => DCACHE_LINE,
		DATA_L => DCACHE_LINE_L
	)
	 port map (
		PortA_clk => clk,

		-- BRAM
		PortA_Address => PortA_Address,
		PortA_Write => PortA_Write,
		PortA_DataIn => PortA_DataIn,
		PortA_DataOut => PortA_DataOut
	);

	BRAM_1PORT_RST_I : bram_rst generic map(
		ADDR_L => ADDR_BRAM_L
	)
	 port map (
		rst => rst,
		clk => clk,

		Start => rstC,
		Done => DoneReset,

		-- BRAM
		PortA_Address => PortA_Address_rst,
		PortB_Address => open
	);

end rtl_bram_1port;

architecture rtl_bram_2port of dcache is

	signal rstN, rstC		: std_logic;
	signal EndRstN, EndRstC		: std_logic;

	signal StateN, StateC		: std_logic_vector(STATE_DCACHE_L - 1 downto 0);
	signal HitC, HitN		: std_logic;
	signal DataOutN, DataOutC	: std_logic_vector(DATA_L - 1 downto 0);
	signal DataInN, DataInC		: std_logic_vector(DATA_L - 1 downto 0);
	signal AddressN, AddressC	: std_logic_vector(ADDR_MEM_L - 1 downto 0);
	signal ReadN, ReadC		: std_logic;

	-- BRAM
	signal PortA_AddressN, PortA_AddressC	: std_logic_vector(ADDR_BRAM_L - 1 downto 0);
	signal PortA_DataInN, PortA_DataInC	: std_logic_vector(DCACHE_LINE_L - 1 downto 0);
	signal PortA_DataOutN, PortA_DataOutC	: std_logic_vector(DCACHE_LINE_L - 1 downto 0);
	signal PortA_WriteN, PortA_WriteC	: std_logic;

	signal PortB_AddressN, PortB_AddressC	: std_logic_vector(ADDR_BRAM_L - 1 downto 0);
	signal PortB_DataInN, PortB_DataInC	: std_logic_vector(DCACHE_LINE_L - 1 downto 0);
	signal PortB_DataOutN, PortB_DataOutC	: std_logic_vector(DCACHE_LINE_L - 1 downto 0);
	signal PortB_WriteN, PortB_WriteC	: std_logic;

	signal DoneReset	: std_logic;
	signal PortA_Address_rst	: std_logic_vector(ADDR_BRAM_L - 1 downto 0);
	signal PortB_Address_rst	: std_logic_vector(ADDR_BRAM_L - 1 downto 0);

	-- BRAM connections
	signal PortA_Address	: std_logic_vector(ADDR_BRAM_L - 1 downto 0);
	signal PortA_Write	: std_logic;
	signal PortA_DataIn	: std_logic_vector(DCACHE_LINE_L - 1 downto 0);
	signal PortA_DataOut	: std_logic_vector(DCACHE_LINE_L - 1 downto 0);

	signal PortB_Address	: std_logic_vector(ADDR_BRAM_L - 1 downto 0);
	signal PortB_Write	: std_logic;
	signal PortB_DataIn	: std_logic_vector(DCACHE_LINE_L - 1 downto 0);
	signal PortB_DataOut	: std_logic_vector(DCACHE_LINE_L - 1 downto 0);

begin

	state_det: process(StateC, Start, PortA_DataOut, AddressC, DoneMemory, DoneReset, ReadC)
	begin
		StateN <= StateC; -- avoid latches
		if (StateC = DCACHE_IDLE) then
			if (Start = '0') then
				StateN <= DCACHE_IDLE;
			else
				StateN <= BRAM_FWD;
			end if;
		elsif (StateC = RESET) then
			if (DoneReset = '1') then
				StateN <= DCACHE_OUTPUT;
			else
				StateN <= StateC;
			end if;
		elsif (StateC = BRAM_FWD) then
			StateN <= WAIT_BRAM_DATA;
		elsif (StateC = WAIT_BRAM_DATA) then
			StateN <= BRAM_RECV_DATA;
		elsif (StateC = BRAM_RECV_DATA) then
			if ((ReadC = '1') and (PortA_DataOut(DCACHE_LINE_L - DIRTY_BIT_L - 1 downto (DCACHE_LINE_L - int_to_bit_num(DATA_MEMORY) - DIRTY_BIT_L - VALID_L)) = ("1" & AddressC(int_to_bit_num(DATA_MEMORY) - 1 downto 0))))  then
				StateN <= DCACHE_OUTPUT;
			elsif ((ReadC = '0') and (PortA_DataOut(DCACHE_LINE_L - DIRTY_BIT_L - 1 downto (DCACHE_LINE_L - int_to_bit_num(DATA_MEMORY) - DIRTY_BIT_L - VALID_L)) = ("1" & AddressC(int_to_bit_num(DATA_MEMORY) - 1 downto 0))) and (PortA_DataOut(DCACHE_LINE_L - 1) = '0'))  then
				StateN <= WRITE_BRAM;
			else
				StateN <= MEMORY_ACCESS;
			end if;
		elsif (StateC = MEMORY_ACCESS) then
			if (DoneMemory = '1') then
				StateN <= DCACHE_OUTPUT;
			else
				StateN <= StateC;
			end if;
		elsif (StateC = WRITE_BRAM) then
			StateN <= DCACHE_OUTPUT;
		elsif (StateC = DCACHE_OUTPUT) then
			StateN <= DCACHE_IDLE;
		else
			StateN <= StateC;
		end if;
	end process state_det;

	reg: process(rst, clk)
	begin
		if (rst = '1') then

			rstC <= '1';
			EndRstC <= '0';

			DataOutC <= (others => '0');
			DataInC <= (others => '0');
			HitC <= '0';
			StateC <= RESET;
			AddressC <= (others => '0');
			ReadC <= '0';

			PortA_AddressC <= (others => '0');
			PortA_WriteC <= '0';
			PortA_DataInC <= (others => '0');
			PortA_DataOutC <= (others => '0');

			PortB_AddressC <= (others => '0');
			PortB_WriteC <= '0';
			PortB_DataInC <= (others => '0');
			PortB_DataOutC <= (others => '0');

		elsif ((clk'event) and (clk = '1')) then

			rstC <= rstN;
			EndRstC <= EndRstN;

			DataOutC <= DataOutN;
			DataInC <= DataInN;
			HitC <= HitN;
			StateC <= StateN;
			AddressC <= AddressN;
			ReadC <= ReadN;

			PortA_AddressC <= PortA_AddressN;
			PortA_WriteC <= PortA_WriteN;
			PortA_DataInC <= PortA_DataInN;
			PortA_DataOutC <= PortA_DataOutN;

			PortB_AddressC <= PortB_AddressN;
			PortB_WriteC <= PortB_WriteN;
			PortB_DataInC <= PortB_DataInN;
			PortB_DataOutC <= PortB_DataOutN;

		end if;
	end process reg;

	rstN <= rst;
	EndRstN <=	'0' when (StateC = RESET) else
			'1' when (StateC = DCACHE_OUTPUT) else
			EndRstC;

	EndRst <= EndRstC;

	AddressN <= Address when (StateC = DCACHE_IDLE) else AddressC;
	ReadN <= Read when (StateC = DCACHE_IDLE) else ReadC;
	DataInN <= DataIn when (StateC = DCACHE_IDLE) else DataInC;

	HitN <=	'0' when (StateC = DCACHE_IDLE) else
		'1' when (StateC = BRAM_RECV_DATA) and (PortA_DataOut(DCACHE_LINE_L - DIRTY_BIT_L - 1 downto DCACHE_LINE_L - DIRTY_BIT_L - int_to_bit_num(DATA_MEMORY) - VALID_L) = ("1" & AddressC(int_to_bit_num(DATA_MEMORY) - 1 downto 0))) else
		HitC;

	DataOutN <=	(others => '0') when (StateC = DCACHE_IDLE) else
			PortA_DataOut(DATA_L - 1 downto 0) when (Read = '1') and (StateC = BRAM_RECV_DATA) else
			DataMemOut when (StateC = MEMORY_ACCESS) else
			DataOutC;

	EnableMemory <= '1' when (StateC = MEMORY_ACCESS) else '0';

	AddressMem <= AddressC;
	DataMemIn <= PortA_DataOutC(DATA_L - 1 downto 0);
	DataOut <= DataOutC when (StateC = DCACHE_OUTPUT) else (others => '0');
	Done <= '1' when (StateC = DCACHE_OUTPUT) else '0';
	Hit <= '0' when (StateC = DCACHE_IDLE) else HitC;

	-- MSB is dirty bit and MSB-1 is valid bit
	-- Store only relevant address bits depending on the data memory size
	PortA_DataInN <=	"11" & AddressC(int_to_bit_num(DATA_MEMORY) - 1 downto 0) & DataInC when (StateC = WRITE_BRAM) or ((StateC = MEMORY_ACCESS) and (ReadC = '0')) else
				"01" & AddressC(int_to_bit_num(DATA_MEMORY) - 1 downto 0) & DataMemOut when (StateC = MEMORY_ACCESS) and (ReadC = '1') else
				(others => '0') when (StateC = DCACHE_IDLE) or (StateC = RESET) else
				PortA_DataInC;

	PortA_DataOutN <=	PortA_DataOut when (StateC = BRAM_RECV_DATA) else
				(others => '0') when (StateC = DCACHE_IDLE) else
				PortA_DataOutC;

	PortA_AddressN <=	PortA_Address_rst when (StateC = RESET) else
				AddressC(ADDR_BRAM_L + INCR_PC_L - 1 downto INCR_PC_L) when (StateC = BRAM_FWD) or (StateC = MEMORY_ACCESS) else
				(others => '0') when (StateC = DCACHE_IDLE) else
				PortA_AddressC;

	PortA_WriteN <=	'1' when (StateC = MEMORY_ACCESS) or (StateC = WRITE_BRAM) or (StateC = RESET) else
			'0' when (StateC = DCACHE_IDLE) else
			PortA_WriteC;

	PortA_DataIn <= PortA_DataInC;
	PortA_Address <= PortA_AddressC;
	PortA_Write <= '0' when(StateC = DCACHE_IDLE) else PortA_WriteC;



	PortB_DataInN <=	(others => '0') when (StateC = DCACHE_IDLE) or (StateC = RESET) else
				PortB_DataInC;

	PortB_DataOutN <=	(others => '0') when (StateC = DCACHE_IDLE) else
				PortB_DataOutC;

	PortB_AddressN <=	PortB_Address_rst when (StateC = RESET) else
				(others => '0') when (StateC = DCACHE_IDLE) else
				PortB_AddressC;

	PortB_WriteN <=	'1' when (StateC = RESET) else
			'0' when (StateC = DCACHE_IDLE) else
			PortB_WriteC;

	PortB_DataIn <= PortB_DataInC;
	PortB_Address <= PortB_AddressC;
	PortB_Write <= PortB_WriteC;

	BRAM_2PORT_I : bram_2port generic map(
		ADDR_BRAM_L => ADDR_BRAM_L,
		BRAM_LINE => DCACHE_LINE,
		DATA_L => DCACHE_LINE_L
	)
	 port map (
		PortA_clk => clk,
		PortB_clk => clk,

		-- BRAM
		PortA_Address => PortA_Address,
		PortA_Write => PortA_Write,
		PortA_DataIn => PortA_DataIn,
		PortA_DataOut => PortA_DataOut,

		PortB_Address => PortB_Address,
		PortB_Write => PortB_Write,
		PortB_DataIn => PortB_DataIn,
		PortB_DataOut => PortB_DataOut
	);

	BRAM_2PORT_RST_I : bram_rst generic map(
		ADDR_L => ADDR_BRAM_L
	)
	 port map (
		rst => rst,
		clk => clk,

		Start => rstC,
		Done => DoneReset,

		-- BRAM
		PortA_Address => PortA_Address_rst,
		PortB_Address => PortB_Address_rst
	);

end rtl_bram_2port;
