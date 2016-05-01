library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bram_pkg.all;
use work.proc_pkg.all;
use work.fifo_pkg.all;

entity fifo is
generic (
	DATA_L		: positive := 32;
	FIFO_SIZE	: positive := 16
);
port (
	rst_rd	: in std_logic;
	clk_rd	: in std_logic;
	DataOut	: out std_logic_vector(DATA_L - 1 downto 0);
	En_rd	: in std_logic;
	empty	: out std_logic;

	rst_wr	: in std_logic;
	clk_wr	: in std_logic;
	DataIn	: in std_logic_vector(DATA_L - 1 downto 0);
	En_wr	: in std_logic;
	full	: out std_logic;

	ValidOut	: out std_logic;
	EndRst		: out std_logic

);
end entity fifo;

architecture rtl of fifo is

	signal WrPtrC, WrPtrN	: unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);
	signal RdPtrC, RdPtrN	: unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);

	signal WrPtrNextC, WrPtrNextN	: unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);
	signal RdPtrNextC, RdPtrNextN	: unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);

	signal AddressRst	: std_logic_vector(int_to_bit_num(FIFO_SIZE) - 1 downto 0);

	signal fullC, fullN	: std_logic;
	signal emptyC, emptyN	: std_logic;

	signal DataIn_fifo	: std_logic_vector(DATA_L - 1 downto 0);
	signal DataOut_fifo	: std_logic_vector(DATA_L - 1 downto 0);

	signal DoneReset	: std_logic;
	signal EndRstC, EndRstN	: std_logic;
	signal rst_wrC, rst_wrN	: std_logic;

	signal ValidOutC, ValidOutN	: std_logic;

	signal PortB_Write	: std_logic;
	signal PortA_Write	: std_logic;
begin

	-- Write register
	reg_wr: process(rst_wr, clk_wr)
	begin
		if (rst_wr = '1') then
			fullC <= '0';
			WrPtrC <= (others => '0');
			WrPtrNextC <= (others => '0');
			EndRstC <= '0';
		elsif ((clk_wr'event) and (clk_wr = '1')) then
			fullC <= fullN;
			WrPtrC <= WrPtrN;
			WrPtrNextC <= WrPtrNextN;
			EndRstC <= EndRstN;
		end if;
	end process reg_wr;

	-- Read register
	reg_rd: process(rst_rd, clk_rd)
	begin
		if (rst_rd = '1') then
			emptyC <= '1';
			RdPtrC <= (others => '0');
			RdPtrNextC <= (others => '0');
			ValidOutC <= '0';
			rst_wrC <= '0';
		elsif ((clk_rd'event) and (clk_rd = '1')) then
			emptyC <= emptyN;
			RdPtrC <= RdPtrN;
			RdPtrNextC <= RdPtrNextN;
			ValidOutC <= ValidOutN;
			rst_wrC <= rst_wrN;
		end if;
	end process reg_rd;

	EndRstN <=	'0' when (rst_wr = '1') else
			'1' when (DoneReset = '1') else
			EndRstC;

	EndRst <= EndRstC;

	WrPtrN <=	unsigned(AddressRst) when (EndRstC = '0') else
			(others => '0') when (WrPtrC = to_unsigned(FIFO_SIZE - 1, int_to_bit_num(FIFO_SIZE))) and (En_wr = '1') and (fullC = '0') else
			WrPtrC + 1 when (En_wr = '1') and (fullC = '0') else
			WrPtrC;

	WrPtrNextN <= (others => '0') when (WrPtrC = to_unsigned(FIFO_SIZE - 1, int_to_bit_num(FIFO_SIZE))) else WrPtrC + 1;

	RdPtrN <=	(others => '0') when ((WrPtrC /= RdPtrC) and (emptyC = '0')) and (En_rd = '1') and (RdPtrC = to_unsigned(FIFO_SIZE - 1, int_to_bit_num(FIFO_SIZE))) else
			RdPtrC + 1 when ((WrPtrC /= RdPtrC) and (emptyC = '0')) and (En_rd = '1') else
			RdPtrC;

	RdPtrNextN <= (others => '0') when (RdPtrC = to_unsigned(FIFO_SIZE - 1, int_to_bit_num(FIFO_SIZE))) else RdPtrC + 1;

	fullN <=	'1' when (RdPtrC = WrPtrNextC) and (En_wr = '1') and (En_rd = '0') and (EndRstC = '1') else
			'0' when (RdPtrC = WrPtrC) and (En_rd = '1') else
			fullC;

	emptyN <=	'1' when ((WrPtrC = RdPtrNextC) and (En_rd = '1') and (En_wr = '0')) or (EndRstC = '0') or ((En_wr = '0') and (ValidOutC = '1') and (WrPtrC = RdPtrC)) else
			'0' when (RdPtrC = WrPtrC) and (En_wr = '1') else
			emptyC;

	PortB_Write <=	'1';
	PortA_Write <=	'0';

	DataIn_fifo <= DataIn when (EndRstC = '1') else (others => '0');

	ValidOutN <= En_rd when (emptyC = '0') or (WrPtrC /= RdPtrC) else '0';
	ValidOut <= ValidOutC;

	DataOut <= DataOut_fifo when (ValidOutC = '1') else (others => '0');

	rst_wrN <= rst_wr;

	full <= fullN;
	empty <= emptyN;

	FIFO_2PORT_I : bram_2port generic map(
		ADDR_BRAM_L => int_to_bit_num(FIFO_SIZE),
		BRAM_LINE => FIFO_SIZE,
		DATA_L => DATA_L
	)
	 port map (
		PortA_clk => clk_rd,
		PortB_clk => clk_wr,

		-- BRAM
		PortA_Address => std_logic_vector(RdPtrC),
		PortA_Write => PortA_Write,
		PortA_DataIn => (others => '0'),
		PortA_DataOut => DataOut_fifo,

		PortB_Address => std_logic_vector(WrPtrC),
		PortB_Write => PortB_Write,
		PortB_DataIn => DataIn_fifo,
		PortB_DataOut => open
	);

	FIFO_RST_I : bram_rst generic map(
		ADDR_L => int_to_bit_num(FIFO_SIZE)
	)
	 port map (
		rst => rst_wr,
		clk => clk_wr,

		Start => rst_wrC,
		Done => DoneReset,

		-- BRAM
		PortA_Address => AddressRst,
		PortB_Address => open
	);

end rtl;
