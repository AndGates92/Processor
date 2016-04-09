library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.icache_pkg.all;
use work.proc_pkg.all;

entity icache is
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
	Instr		: out std_logic_vector(INSTR_L - 1 downto 0);
	Address		: in std_logic_vector(ADDR_MEM_L - 1 downto 0);

	-- Memory access
	DoneMemory	: in std_logic;
	EnableMemory	: out std_logic;
	AddressMem	: out std_logic_vector(ADDR_MEM_L - 1 downto 0);
	InstrOut	: in std_logic_vector(INSTR_L - 1 downto 0)
);
end entity icache;

architecture rtl_bram_2port of icache is

	signal rstN, rstC			: std_logic;
	signal EndRstN, EndRstC			: std_logic;

	signal StateN, StateC			: std_logic_vector(STATE_L - 1 downto 0);
	signal HitC, HitN			: std_logic;
	signal InstrN, InstrC			: std_logic_vector(INSTR_L - 1 downto 0);
	signal AddressN, AddressC		: std_logic_vector(ADDR_MEM_L - 1 downto 0);


	-- BRAM
	signal PortA_AddressN, PortA_AddressC	: std_logic_vector(ADDR_BRAM_L - 1 downto 0);
	signal PortA_DataInN, PortA_DataInC	: std_logic_vector(ICACHE_LINE_L - 1 downto 0);
	signal PortA_DataOutN, PortA_DataOutC	: std_logic_vector(ICACHE_LINE_L - 1 downto 0);
	signal PortA_WriteN, PortA_WriteC	: std_logic;

	signal PortB_AddressN, PortB_AddressC	: std_logic_vector(ADDR_BRAM_L - 1 downto 0);
	signal PortB_DataInN, PortB_DataInC	: std_logic_vector(ICACHE_LINE_L - 1 downto 0);
	signal PortB_DataOutN, PortB_DataOutC	: std_logic_vector(ICACHE_LINE_L - 1 downto 0);
	signal PortB_WriteN, PortB_WriteC	: std_logic;

	signal DoneReset	: std_logic;
	signal PortA_Address_rst, PortB_Address_rst	: std_logic_vector(ADDR_BRAM_L - 1 downto 0);

	-- BRAM connections
	signal PortA_Address	: std_logic_vector(ADDR_BRAM_L - 1 downto 0);
	signal PortA_Write	: std_logic;
	signal PortA_DataIn	: std_logic_vector(ICACHE_LINE_L - 1 downto 0);
	signal PortA_DataOut	: std_logic_vector(ICACHE_LINE_L - 1 downto 0);

	signal PortB_Address	: std_logic_vector(ADDR_BRAM_L - 1 downto 0);
	signal PortB_Write	: std_logic;
	signal PortB_DataIn	: std_logic_vector(ICACHE_LINE_L - 1 downto 0);
	signal PortB_DataOut	: std_logic_vector(ICACHE_LINE_L - 1 downto 0);



begin

	state_det: process(StateC, Start, PortA_DataOut, AddressC, DoneMemory, DoneReset)
	begin
		StateN <= StateC; -- avoid latches
		if (StateC = IDLE) then
			if (rst = '1') then
				StateN <= RESET;
			elsif (Start = '0') then
				StateN <= IDLE;
			else
				StateN <= BRAM_FWD;
			end if;
		elsif (StateC = RESET) then
			if (DoneReset = '1') then
				StateN <= OUTPUT;
			else
				StateN <= StateC;
			end if;
		elsif (StateC = BRAM_FWD) then
			StateN <= WAIT_BRAM_DATA;
		elsif (StateC = WAIT_BRAM_DATA) then
			StateN <= BRAM_RECV_DATA;
		elsif (StateC = BRAM_RECV_DATA) then
			if (PortA_DataOutC(ICACHE_LINE_L - 1 downto ICACHE_LINE_L - int_to_bit_num(PROGRAM_MEMORY)) = ("1" & AddressC(int_to_bit_num(PROGRAM_MEMORY) - 1 downto 0))) then
				StateN <= OUTPUT;
			else
				StateN <= MEMORY_ACCESS;
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

			rstC <= '1';
			EndRstC <= '0';

			InstrC <= (others => '0');
			HitC <= '0';
			StateC <= IDLE;
			AddressC <= (others => '0');

			PortA_AddressC <= (others => '0');
			PortA_WriteC <= '0';
			PortA_DataInC <= (others => '0');
			PortA_DataOutC <= (others => '0');

			PortB_AddressC <= (others => '0');
			PortB_WriteC <= '0';
			PortB_DataInC <= (others => '0');
			PortB_DataOutC <= (others => '0');

		elsif (rising_edge(clk)) then

			rstC <= rstN;
			EndRstC <= EndRstN;

			InstrC <= InstrN;
			HitC <= HitN;
			StateC <= StateN;
			AddressC <= AddressN;

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
			'1' when (StateC = OUTPUT) else
			EndRstC;

	EndRst <= EndRstC;

	AddressN <= Address when (StateC = IDLE) else AddressC;

	HitN <=	'0' when (StateC = IDLE) else
		'1' when (StateC = BRAM_RECV_DATA) and (PortA_DataOutC(ICACHE_LINE_L - 1 downto ICACHE_LINE_L - 1 - int_to_bit_num(PROGRAM_MEMORY)) = ("1" & AddressC(int_to_bit_num(PROGRAM_MEMORY) - 1 downto 0))) else
		HitC;

	InstrN <=	(others => '0') when (StateC = IDLE) else
			PortA_DataOut(INSTR_L - 1 downto 0) when (StateC = WAIT_BRAM_DATA) else
			InstrOut when (StateC = MEMORY_ACCESS) else
			InstrC;

	PortA_DataInN <=	"1" & AddressC & InstrOut when (StateC = MEMORY_ACCESS) else
				(others => '0') when (StateC = IDLE) or (StateC = RESET) else
				PortA_DataInC;

	PortA_DataOutN <=	PortA_DataOut when (StateC = WAIT_BRAM_DATA) else
				(others => '0') when (StateC = IDLE) else
				PortA_DataOutC;

	PortA_AddressN <=	PortA_Address_rst when (StateC = RESET) else
				AddressC(ADDR_BRAM_L - 1 downto 0) when (StateC = BRAM_FWD) or (StateC = MEMORY_ACCESS) else
				(others => '0') when (StateC = IDLE) else
				PortA_AddressC;

	PortA_WriteN <=	'1' when ((StateC = MEMORY_ACCESS) and (DoneMemory = '1')) or (StateC = RESET) else
			'0' when (StateC = IDLE) else
			PortA_WriteC;

	PortB_DataInN <=	(others => '0') when (StateC = IDLE) or (StateC = RESET) else
				PortB_DataInC;

	PortB_DataOutN <=	(others => '0') when (StateC = IDLE) else
				PortB_DataOutC;

	PortB_AddressN <=	PortB_Address_rst when (StateC = RESET) else
				(others => '0') when (StateC = IDLE) else
				PortB_AddressC;

	PortB_WriteN <=	'1' when (StateC = RESET) else
			'0' when (StateC = IDLE) else
			PortB_WriteC;

	PortA_DataIn <= PortA_DataInC;
	PortA_Address <= PortA_AddressC;
	PortA_Write <= PortA_WriteC;

	PortB_DataIn <= PortB_DataInC;
	PortB_Address <= PortB_AddressC;
	PortB_Write <= PortB_WriteC;

	EnableMemory <= not HitC when (StateC = MEMORY_ACCESS) else '0';
	AddressMem <= AddressC;
	Instr <= InstrC when (StateC = OUTPUT) else (others => '0');
	Done <= '1' when (StateC = OUTPUT) else '0';
	Hit <= HitC;
	BRAM_2PORT_I : bram_2port generic map(
		ADDR_BRAM_L => ADDR_BRAM_L,
		DATA_L => ICACHE_LINE_L
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

architecture rtl_bram_1port of icache is

	signal rstN, rstC			: std_logic;
	signal EndRstN, EndRstC			: std_logic;

	signal StateN, StateC			: std_logic_vector(STATE_L - 1 downto 0);
	signal HitC, HitN			: std_logic;
	signal InstrN, InstrC			: std_logic_vector(INSTR_L - 1 downto 0);
	signal AddressN, AddressC		: std_logic_vector(ADDR_MEM_L - 1 downto 0);

	-- BRAM
	signal PortA_AddressN, PortA_AddressC	: std_logic_vector(ADDR_BRAM_L - 1 downto 0);
	signal PortA_DataInN, PortA_DataInC	: std_logic_vector(ICACHE_LINE_L - 1 downto 0);
	signal PortA_DataOutN, PortA_DataOutC	: std_logic_vector(ICACHE_LINE_L - 1 downto 0);
	signal PortA_WriteN, PortA_WriteC	: std_logic;

	signal DoneReset	: std_logic;
	signal PortA_Address_rst	: std_logic_vector(ADDR_BRAM_L - 1 downto 0);

	-- BRAM connections
	signal PortA_Address	: std_logic_vector(ADDR_BRAM_L - 1 downto 0);
	signal PortA_Write	: std_logic;
	signal PortA_DataIn	: std_logic_vector(ICACHE_LINE_L - 1 downto 0);
	signal PortA_DataOut	: std_logic_vector(ICACHE_LINE_L - 1 downto 0);

begin

	state_det: process(StateC, Start, PortA_DataOut, AddressC, DoneMemory, DoneReset)
	begin
		StateN <= StateC; -- avoid latches
		if (StateC = IDLE) then
			if (rst = '1') then
				StateN <= RESET;
			elsif (Start = '0') then
				StateN <= IDLE;
			else
				StateN <= BRAM_FWD;
			end if;
		elsif (StateC = RESET) then
			if (DoneReset = '1') then
				StateN <= OUTPUT;
			else
				StateN <= StateC;
			end if;
		elsif (StateC = BRAM_FWD) then
			StateN <= WAIT_BRAM_DATA;
		elsif (StateC = WAIT_BRAM_DATA) then
			StateN <= BRAM_RECV_DATA;
		elsif (StateC = BRAM_RECV_DATA) then
			if (PortA_DataOutC(ICACHE_LINE_L - 1 downto ICACHE_LINE_L - int_to_bit_num(PROGRAM_MEMORY)) = ("1" & AddressC(int_to_bit_num(PROGRAM_MEMORY) - 1 downto 0))) then
				StateN <= OUTPUT;
			else
				StateN <= MEMORY_ACCESS;
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

			rstC <= '1';
			EndRstC <= '0';

			InstrC <= (others => '0');
			HitC <= '0';
			StateC <= IDLE;
			AddressC <= (others => '0');

			PortA_AddressC <= (others => '0');
			PortA_WriteC <= '0';
			PortA_DataInC <= (others => '0');
			PortA_DataOutC <= (others => '0');

		elsif (rising_edge(clk)) then

			rstC <= rstN;
			EndRstC <= EndRstN;

			InstrC <= InstrN;
			HitC <= HitN;
			StateC <= StateN;
			AddressC <= AddressN;

			PortA_AddressC <= PortA_AddressN;
			PortA_WriteC <= PortA_WriteN;
			PortA_DataInC <= PortA_DataInN;
			PortA_DataOutC <= PortA_DataOutN;
		end if;
	end process reg;

	rstN <= rst;
	EndRstN <=	'0' when (StateC = RESET) else
			'1' when (StateC = OUTPUT) else
			EndRstC;

	EndRst <= EndRstC;

	AddressN <= Address when (StateC = IDLE) else AddressC;

	HitN <=	'0' when (StateC = IDLE) else
		'1' when (StateC = BRAM_RECV_DATA) and (PortA_DataOutC(ICACHE_LINE_L - 1 downto ICACHE_LINE_L - 1 - int_to_bit_num(PROGRAM_MEMORY)) = ("1" & Address(int_to_bit_num(PROGRAM_MEMORY) - 1 downto 0))) else
		HitC;

	InstrN <=	(others => '0') when (StateC = IDLE) else
			PortA_DataOut(INSTR_L - 1 downto 0) when (StateC = WAIT_BRAM_DATA) else
			InstrOut when (StateC = MEMORY_ACCESS) else
			InstrC;

	PortA_DataInN <=	"1" & AddressC(int_to_bit_num(PROGRAM_MEMORY) - 1 downto 0) & InstrOut when (StateC = MEMORY_ACCESS) else
				(others => '0') when (StateC = IDLE) or (StateC = RESET) else
				PortA_DataInC;

	PortA_DataOutN <=	PortA_DataOut when (StateC = MEMORY_ACCESS) else
				(others => '0') when (StateC = IDLE) else
				PortA_DataOutC;

	PortA_AddressN <=	PortA_Address_rst when (StateC = RESET) else
				AddressC(ADDR_BRAM_L - 1 downto 0) when (StateC = BRAM_FWD) or (StateC = MEMORY_ACCESS) else
				(others => '0') when (StateC = IDLE) else
				PortA_AddressC;

	PortA_WriteN <=	'1' when ((StateC = MEMORY_ACCESS) and (DoneMemory = '1')) or (StateC = RESET) else
			'0' when (StateC = IDLE) else
			PortA_WriteC;

	PortA_DataIn <= PortA_DataInC;
	PortA_Address <= PortA_AddressC;
	PortA_Write <= PortA_WriteC;

	EnableMemory <= not HitC when (StateC = MEMORY_ACCESS) else '0';
	AddressMem <= AddressC;
	Instr <= InstrC when (StateC = OUTPUT) else (others => '0');
	Done <= '1' when (StateC = OUTPUT) else '0';
	Hit <= HitC;

	BRAM_1PORT_I : bram_1port generic map(
		ADDR_BRAM_L => ADDR_BRAM_L,
		DATA_L => ICACHE_LINE_L
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


