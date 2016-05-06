library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bram_pkg.all;
use work.proc_pkg.all;
use work.fifo_2clk_pkg.all;

entity fifo_2clk is
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
end entity fifo_2clk;

architecture rtl of fifo_2clk is

--	type pipelineAddr is array(0 to NUM_STAGES-1) of unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);
--	signal R_WrPtrNextC, R_WrPtrNextN	: pipelineAddr;
--	signal R_RdPtrC, R_RdPtrN		: pipelineAddr;
--	signal W_WrPtrC, W_WrPtrN		: pipelineAddr;
--	signal W_RdPtrNextC, W_RdPtrNextN	: pipelineAddr;
--	signal W_WrPtrNextC, W_WrPtrNextN	: pipelineAddr;
--	signal W_RdPtrC, W_RdPtrN		: pipelineAddr;
--	signal R_WrPtrC, R_WrPtrN		: pipelineAddr;
--	signal R_RdPtrNextC, R_RdPtrNextN	: pipelineAddr;

--	signal R_WrPtrNext2C, R_WrPtrNext2N	: unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);
--	signal R_RdPtr2C, R_RdPtr2N		: unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);
--	signal W_WrPtr2C, W_WrPtr2N		: unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);
--	signal W_RdPtrNext2C, W_RdPtrNext2N	: unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);
--	signal W_WrPtrNext2C, W_WrPtrNext2N	: unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);
--	signal W_RdPtr2C, W_RdPtr2N		: unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);
--	signal R_WrPtr2C, R_WrPtr2N		: unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);
--	signal R_RdPtrNext2C, R_RdPtrNext2N	: unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);

	signal R_WrPtrNext1C, R_WrPtrNext1N	: unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);
	signal R_RdPtr1C, R_RdPtr1N		: unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);
	signal W_WrPtr1C, W_WrPtr1N		: unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);
	signal W_RdPtrNext1C, W_RdPtrNext1N	: unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);
	signal W_WrPtrNext1C, W_WrPtrNext1N	: unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);
	signal W_RdPtr1C, W_RdPtr1N		: unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);
	signal R_WrPtr1C, R_WrPtr1N		: unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);
	signal R_RdPtrNext1C, R_RdPtrNext1N	: unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);

	signal R_WrPtrNext0C, R_WrPtrNext0N	: unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);
	signal R_RdPtr0C, R_RdPtr0N		: unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);
	signal W_WrPtr0C, W_WrPtr0N		: unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);
	signal W_RdPtrNext0C, W_RdPtrNext0N	: unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);
	signal W_WrPtrNext0C, W_WrPtrNext0N	: unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);
	signal W_RdPtr0C, W_RdPtr0N		: unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);
	signal R_WrPtr0C, R_WrPtr0N		: unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);
	signal R_RdPtrNext0C, R_RdPtrNext0N	: unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);

	signal En_rdN			: std_logic;
	signal En_wrN			: std_logic;
	signal W_En_wrC, W_En_wrN	: std_logic_vector(NUM_STAGES - 1 downto 0);
	signal W_En_rdC, W_En_rdN	: std_logic_vector(NUM_STAGES - 1 downto 0);
	signal R_En_wrC, R_En_wrN	: std_logic_vector(NUM_STAGES - 1 downto 0);
	signal R_En_rdC, R_En_rdN	: std_logic_vector(NUM_STAGES - 1 downto 0);

	signal WrPtr		: unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);
	signal RdPtr		: unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);
	signal WrPtrNext	: unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);
	signal RdPtrNext	: unsigned(int_to_bit_num(FIFO_SIZE) - 1 downto 0);

	signal AddressRst	: std_logic_vector(int_to_bit_num(FIFO_SIZE) - 1 downto 0);

	signal W_fullC, W_fullN		: std_logic;
	signal R_emptyC, R_emptyN	: std_logic;

	signal EnReadC, EnReadN		: std_logic;
	signal EnWriteC, EnWriteN	: std_logic;

--	type pipelineData is array(0 to NUM_STAGES-1) of std_logic_vector(DATA_L - 1 downto 0);
--	signal W_DataInC, W_DataInN	: pipelineData;
	signal W_DataIn0C, W_DataIn0N	: std_logic_vector(DATA_L - 1 downto 0);
	signal W_DataIn1C, W_DataIn1N	: std_logic_vector(DATA_L - 1 downto 0);
--	signal W_DataIn2C, W_DataIn2N	: std_logic_vector(DATA_L - 1 downto 0);
	signal DataInN	: std_logic_vector(DATA_L - 1 downto 0);
	signal DataOut_fifo	: std_logic_vector(DATA_L - 1 downto 0);

	signal DoneReset	: std_logic;
	signal EndRstC, EndRstN	: std_logic_vector(NUM_STAGES - 1 downto 0);
	signal rst_wrC, rst_wrN	: std_logic;

	signal ValidOutC, ValidOutN	: std_logic;

	signal PortB_Write	: std_logic;
	signal PortA_Write	: std_logic;
begin

	-- Write register
	reg_wr: process(rst_wr, clk_wr)
	begin
		if (rst_wr = '1') then
			W_fullC <= '0';
			rst_wrC <= '1';
			EnWriteC <= '0';
		elsif ((clk_wr'event) and (clk_wr = '1')) then
			W_fullC <= W_fullN;
			rst_wrC <= rst_wrN;
			EnWriteC <= EnWriteN;
		end if;
	end process reg_wr;

	-- Read register
	reg_rd: process(rst_rd, clk_rd)
	begin
		if (rst_rd = '1') then
			R_emptyC <= '1';
			ValidOutC <= '0';
			EnReadC <= '0';
		elsif ((clk_rd'event) and (clk_rd = '1')) then
			R_emptyC <= R_emptyN;
			ValidOutC <= ValidOutN;
			EnReadC <= EnReadN;
		end if;
	end process reg_rd;

	EndRst <= EndRstC(NUM_STAGES - 1);

	ValidOutN <= R_En_rdC(NUM_STAGES - 1);
	ValidOut <= ValidOutC;

	rst_wrN <= rst_wr;

--	W_fullN <=	'1' when (W_RdPtrC(NUM_STAGES - 1) = W_WrPtrNextC(NUM_STAGES - 1)) and (W_En_wrC(NUM_STAGES - 1) = '1') and (W_En_rdC(NUM_STAGES - 1) = '0') and (EndRstC = '1') else
--			'0' when (W_RdPtrC(NUM_STAGES - 1) = W_WrPtrC(NUM_STAGES - 1)) and (W_En_rdC(NUM_STAGES - 1) = '1') else
--			W_fullC;

--	R_emptyN <=	'1' when ((R_WrPtrC(NUM_STAGES - 1) = R_RdPtrNextC(NUM_STAGES - 1)) and (R_En_rdC(NUM_STAGES - 1) = '1') and (R_En_wrC(NUM_STAGES - 1) = '0')) or (EndRstC = '0') else
--			'0' when (R_RdPtrC(NUM_STAGES - 1) = R_WrPtrC(NUM_STAGES - 1)) and (R_En_wrC(NUM_STAGES - 1) = '1') else
--			R_emptyC;

	W_fullN <=	'1' when (W_RdPtr1C = W_WrPtrNext0C) and (W_En_wrC(NUM_STAGES - 2) = '1') and (W_En_rdC(NUM_STAGES - 2) = '0') and (EndRstC(NUM_STAGES - 1) = '1') else
			'0' when (W_RdPtr1C = W_WrPtr1C) and (W_En_rdC(NUM_STAGES - 2) = '1') else
			W_fullC;

	R_emptyN <=	'1' when ((R_WrPtr1C = R_RdPtrNext0C) and (R_En_rdC(0) = '1') and (R_En_wrC(NUM_STAGES - 2) = '0')) or (EndRstC(NUM_STAGES - 1) = '0') else
			'0' when (R_RdPtr1C = R_WrPtr1C) and (R_En_wrC(NUM_STAGES - 2) = '1') else
			R_emptyC;

	full <= W_fullC;
	empty <= R_emptyC;

	EnReadN <=	'1' when (R_emptyC = '1') and (En_wr = '1') else
			'0' when (R_emptyC = '0') else
			EnReadC;

	EnWriteN <=	'1' when (W_fullC = '1') and (En_rd = '1') else
			'0' when (W_fullC = '0') else
			EnWriteC;

--	WrPtr <=	unsigned(AddressRst) when (EndRstC = '0') else
--			W_WrPtrC(0) when ((W_fullC = '1') and (EnWriteC = '0')) or (W_En_wrC(NUM_STAGES - 1) = '0') else
--			W_WrPtrNextC(0);
--	WrPtrNext <= (others => '0') when (W_WrPtrC(0) = to_unsigned(FIFO_SIZE - 1, int_to_bit_num(FIFO_SIZE))) else W_WrPtrC(0) + 1;
--	RdPtr <= R_RdPtrC(0) when ((R_emptyC = '1') and (EnReadC = '0')) or (R_En_rdC(NUM_STAGES - 1) = '0') else R_RdPtrNextC(0);
--	RdPtrNext <= (others => '0') when (R_RdPtrC(0) = to_unsigned(FIFO_SIZE - 1, int_to_bit_num(FIFO_SIZE))) else R_RdPtrC(0) + 1;
	WrPtr <=	unsigned(AddressRst) when (EndRstC(NUM_STAGES - 1) = '0') else
			W_WrPtr0C when ((W_fullC = '1') and (EnWriteC = '0')) or (En_wr = '0') else
			W_WrPtrNext0C;
	WrPtrNext <= (others => '0') when (W_WrPtr0C = to_unsigned(FIFO_SIZE - 1, int_to_bit_num(FIFO_SIZE))) else W_WrPtr0C + 1;
	RdPtr <= R_RdPtr0C when ((R_emptyC = '1') and (EnReadC = '0')) or (En_rd = '0') else R_RdPtrNext0N;
	RdPtrNext <= (others => '0') when (R_RdPtr0C = to_unsigned(FIFO_SIZE - 1, int_to_bit_num(FIFO_SIZE))) else R_RdPtr0C + 1;

--	En_rdN <= '0' when (R_emptyC = '1') and (R_WrPtrC(NUM_STAGES - 1) = R_RdPtrC(NUM_STAGES - 1)) else En_rd;
--	En_wrN <= '0' when (W_fullC = '1') and (W_WrPtrC(NUM_STAGES - 1) = W_RdPtrC(NUM_STAGES - 1)) else En_wr;
	En_rdN <= '0' when (R_emptyC = '1') and (EnReadC = '0') else En_rd;
	En_wrN <= '0' when (W_fullC = '1') and (EnWriteC = '0') else En_wr;

	DataInN <=DataIn when (EndRstC(NUM_STAGES - 1) = '1') else (others => '0');

	W_DataIn0N <= DataInN;

	-- Write register
	reg_wr0: process(rst_wr, clk_wr)
	begin
		if (rst_wr = '1') then
			W_DataIn0C <= (others => '0');
			W_WrPtrNext0C <= (others => '0');
			W_RdPtr0C <= (others => '0');
			W_RdPtrNext0C <= (others => '0');
			W_WrPtr0C <= (others => '0');
			W_En_wrC(0) <= '0';
			W_En_rdC(0) <= '0';
			EndRstC(0) <= '0';
		elsif ((clk_wr'event) and (clk_wr = '1')) then
			W_DataIn0C <= W_DataIn0N;
			W_WrPtrNext0C <= W_WrPtrNext0N;
			W_RdPtr0C <= W_RdPtr0N;
			W_RdPtrNext0C <= W_RdPtrNext0N;
			W_WrPtr0C <= W_WrPtr0N;
			W_En_rdC(0) <= W_En_rdN(0);
			W_En_wrC(0) <= W_En_wrN(0);
			EndRstC(0) <= EndRstN(0);
		end if;
	end process reg_wr0;

	W_WrPtrNext0N <= WrPtrNext;
	W_RdPtr0N <= RdPtr;
	W_RdPtrNext0N <= RdPtrNext;
	W_WrPtr0N <= WrPtr;
	W_En_wrN(0) <= En_wrN;
	W_En_rdN(0) <= En_rdN;

	EndRstN(0) <=	'0' when (rst_wr = '1') else
			'1' when (DoneReset = '1') else
			EndRstC(0);

	-- Read register
	reg_rd0: process(rst_rd, clk_rd)
	begin
		if (rst_rd = '1') then
			R_WrPtrNext0C <= (others => '0');
			R_RdPtr0C <= (others => '0');
			R_RdPtrNext0C <= (others => '0');
			R_WrPtr0C <= (others => '0');
			R_En_wrC(0) <= '0';
			R_En_rdC(0) <= '0';
		elsif ((clk_rd'event) and (clk_rd = '1')) then
			R_WrPtrNext0C <= R_WrPtrNext0N;
			R_RdPtr0C <= R_RdPtr0N;
			R_RdPtrNext0C <= R_RdPtrNext0N;
			R_WrPtr0C <= R_WrPtr0N;
			R_En_rdC(0) <= R_En_rdN(0);
			R_En_wrC(0) <= R_En_wrN(0);
		end if;
	end process reg_rd0;

	R_WrPtrNext0N <= WrPtrNext;
	R_RdPtr0N <= RdPtr;
	R_RdPtrNext0N <= RdPtrNext;
	R_WrPtr0N <= WrPtr;
	R_En_wrN(0) <= En_wrN;
	R_En_rdN(0) <= En_rdN;

	W_DataIn1N <= W_DataIn0C when (W_En_wrC(0) = '1') and (W_fullC = '0') else W_DataIn1C;
	-- Write register
	reg_wr1: process(rst_wr, clk_wr)
	begin
		if (rst_wr = '1') then
			W_DataIn1C <= (others => '0');
			W_WrPtrNext1C <= (others => '0');
			W_RdPtr1C <= (others => '0');
			W_RdPtrNext1C <= (others => '0');
			W_WrPtr1C <= (others => '0');
			W_En_wrC(1) <= '0';
			W_En_rdC(1) <= '0';
			EndRstC(1) <= '0';
		elsif ((clk_wr'event) and (clk_wr = '1')) then
			W_DataIn1C <= W_DataIn1N;
			W_WrPtrNext1C <= W_WrPtrNext1N;
			W_RdPtr1C <= W_RdPtr1N;
			W_RdPtrNext1C <= W_RdPtrNext1N;
			W_WrPtr1C <= W_WrPtr1N;
			W_En_rdC(1) <= W_En_rdN(1);
			W_En_wrC(1) <= W_En_wrN(1);
			EndRstC(1) <= EndRstN(1);
		end if;
	end process reg_wr1;

	W_WrPtrNext1N <= W_WrPtrNext0C;
	W_RdPtr1N <= W_RdPtr0C;
	W_RdPtrNext1N <= W_RdPtrNext0C;
	W_WrPtr1N <= W_WrPtr0C;
	W_En_wrN(1) <= W_En_wrC(0);
	W_En_rdN(1) <= W_En_rdC(0);

	EndRstN(1) <= EndRstC(0);

	-- Read register
	reg_rd1: process(rst_rd, clk_rd)
	begin
		if (rst_rd = '1') then
			R_WrPtrNext1C <= (others => '0');
			R_RdPtr1C <= (others => '0');
			R_RdPtrNext1C <= (others => '0');
			R_WrPtr1C <= (others => '0');
			R_En_wrC(1) <= '0';
			R_En_rdC(1) <= '0';
		elsif ((clk_rd'event) and (clk_rd = '1')) then
			R_WrPtrNext1C <= R_WrPtrNext1N;
			R_RdPtr1C <= R_RdPtr1N;
			R_RdPtrNext1C <= R_RdPtrNext1N;
			R_WrPtr1C <= R_WrPtr1N;
			R_En_rdC(1) <= R_En_rdN(1);
			R_En_wrC(1) <= R_En_wrN(1);
		end if;
	end process reg_rd1;

	R_WrPtrNext1N <= R_WrPtrNext0C;
	R_RdPtr1N <= R_RdPtr0C;
	R_RdPtrNext1N <= R_RdPtrNext0C;
	R_WrPtr1N <= R_WrPtr0C;
	R_En_wrN(1) <= R_En_wrC(0);
	R_En_rdN(1) <= R_En_rdC(0);

--	W_DataIn2N <= W_DataIn1C when (W_En_wrC(1) = '1') and (W_fullC = '0') else W_DataIn2C;
	-- Write register
--	reg_wr2: process(rst_wr, clk_wr)
--	begin
--		if (rst_wr = '1') then
--			W_DataIn2C <= (others => '0');
--			W_WrPtrNext2C <= (others => '0');
--			W_RdPtr2C <= (others => '0');
--			W_RdPtrNext2C <= (others => '0');
--			W_WrPtr2C <= (others => '0');
--			W_En_wrC(2) <= '0';
--			W_En_rdC(2) <= '0';
--			EndRstC(2) <= '0';
--		elsif ((clk_wr'event) and (clk_wr = '1')) then
--			W_DataIn2C <= W_DataIn2N;
--			W_WrPtrNext2C <= W_WrPtrNext2N;
--			W_RdPtr2C <= W_RdPtr2N;
--			W_RdPtrNext2C <= W_RdPtrNext2N;
--			W_WrPtr2C <= W_WrPtr2N;
--			W_En_rdC(2) <= W_En_rdN(2);
--			W_En_wrC(2) <= W_En_wrN(2);
--			EndRstC(2) <= EndRstN(2);
--		end if;
--	end process reg_wr2;

--	W_WrPtrNext2N <= W_WrPtrNext1C;
--	W_RdPtr2N <= W_RdPtr1C;
--	W_RdPtrNext2N <= W_RdPtrNext1C;
--	W_WrPtr2N <= W_WrPtr1C;
--	W_En_wrN(2) <= W_En_wrC(1);
--	W_En_rdN(2) <= W_En_rdC(1);

--	EndRstN(2) <= EndRstC(1);

	-- Read register
--	reg_rd2: process(rst_rd, clk_rd)
--	begin
--		if (rst_rd = '1') then
--			R_WrPtrNext2C <= (others => '0');
--			R_RdPtr2C <= (others => '0');
--			R_RdPtrNext2C <= (others => '0');
--			R_WrPtr2C <= (others => '0');
--			R_En_wrC(2) <= '0';
--			R_En_rdC(2) <= '0';
--		elsif ((clk_rd'event) and (clk_rd = '1')) then
--			R_WrPtrNext2C <= R_WrPtrNext2N;
--			R_RdPtr2C <= R_RdPtr2N;
--			R_RdPtrNext2C <= R_RdPtrNext2N;
--			R_WrPtr2C <= R_WrPtr2N;
--			R_En_rdC(2) <= R_En_rdN(2);
--			R_En_wrC(2) <= R_En_wrN(2);
--		end if;
--	end process reg_rd2;

--	R_WrPtrNext2N <= R_WrPtrNext1C;
--	R_RdPtr2N <= R_RdPtr1C;
--	R_RdPtrNext2N <= R_RdPtrNext1C;
--	R_WrPtr2N <= R_WrPtr1C;
--	R_En_wrN(2) <= R_En_wrC(1);
--	R_En_rdN(2) <= R_En_rdC(1);

	PortB_Write <=	W_En_wrC(NUM_STAGES - 1) when (W_fullC = '0') else '0';
	PortA_Write <=	'0';

	DataOut <= DataOut_fifo when (ValidOutC = '1') else (others => '0');

	FIFO_2PORT_I : bram_2port generic map(
		ADDR_BRAM_L => int_to_bit_num(FIFO_SIZE),
		BRAM_LINE => FIFO_SIZE,
		DATA_L => DATA_L
	)
	 port map (
		PortA_clk => clk_rd,
		PortB_clk => clk_wr,

		-- BRAM
		PortA_Address => std_logic_vector(R_RdPtr1C), -- std_logic_vector(R_RdPtrC(NUM_STAGES - 1)),
		PortA_Write => PortA_Write,
		PortA_DataIn => (others => '0'),
		PortA_DataOut => DataOut_fifo,

		PortB_Address => std_logic_vector(W_WrPtr1C),  -- std_logic_vector(W_WrPtrC(NUM_STAGES - 1)),
		PortB_Write => PortB_Write,
		PortB_DataIn => W_DataIn1C, -- W_DataInC(NUM_STAGES - 1),
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

-- /*  Array of unsigned not supported 
--	PIPELINE: for i in 0 to (NUM_STAGES - 1) generate
--		FIRST_STAGE: if (i = 0) generate
--			W_DataInN(i) <= DataInN;
			-- Write register
--			reg_wr_stage0: process(rst_wr, clk_wr)
--			begin
--				if (rst_wr = '1') then
--					W_DataInC(i) <= (others => '0');
--					W_WrPtrNextC(i) <= (others => '0');
--					W_RdPtrC(i) <= (others => '0');
--					W_RdPtrNextC(i) <= (others => '0');
--					W_WrPtrC(i) <= (others => '0');
--					W_En_wrC(i) <= '0';
--					W_En_rdC(i) <= '0';
--					EndRstC(i) <= '0';
--				elsif ((clk_wr'event) and (clk_wr = '1')) then
--					W_DataInC(i) <= W_DataInN(i);
--					W_WrPtrNextC(i) <= W_WrPtrNextN(i);
--					W_RdPtrC(i) <= W_RdPtrN(i);
--					W_RdPtrNextC(i) <= W_RdPtrNextN(i);
--					W_WrPtrC(i) <= W_WrPtrN(i);
--					W_En_wrC(i) <= W_En_wrN(i);
--					W_En_rdC(i) <= W_En_rdN(i);
--					EndRstC(i) <= EndRstN(i);
--				end if;
--			end process reg_wr_stage0;

--			W_WrPtrNextN(i) <= WrPtrNext;
--			W_RdPtrN(i) <= RdPtr;
--			W_RdPtrNextN(i) <= RdPtrNext;
--			W_WrPtrN(i) <= WrPtr;
--			W_En_wrN(i) <= En_wrN;
--			W_En_rdN(i) <= En_rdN;

--			EndRstN(0) <=	'0' when (rst_wr = '1') else
--					'1' when (DoneReset = '1') else
--					EndRstC(0);

			-- Read register
--			reg_rd_stage0: process(rst_rd, clk_rd)
--			begin
--				if (rst_rd = '1') then
--					R_WrPtrNextC(i) <= (others => '0');
--					R_RdPtrC(i) <= (others => '0');
--					R_RdPtrNextC(i) <= (others => '0');
--					R_WrPtrC(i) <= (others => '0');
--					R_En_wrC(i) <= '0';
--					R_En_rdC(i) <= '0';
--				elsif ((clk_rd'event) and (clk_rd = '1')) then
--					R_WrPtrNextC(i) <= R_WrPtrNextN(i);
--					R_RdPtrC(i) <= R_RdPtrN(i);
--					R_RdPtrNextC(i) <= R_RdPtrNextN(i);
--					R_WrPtrC(i) <= R_WrPtrN(i);
--					R_En_rdC(i) <= R_En_rdN(i);
--					R_En_wrC(i) <= R_En_wrN(i);
--				end if;
--			end process reg_rd_stage0;

--			R_WrPtrNextN(i) <= WrPtrNext;
--			R_RdPtrN(i) <= RdPtr;
--			R_RdPtrNextN(i) <= RdPtrNext;
--			R_WrPtrN(i) <= WrPtr;
--			R_En_wrN(i) <= En_wrN;
--			R_En_rdN(i) <= En_rdN;

--		end generate FIRST_STAGE;

--		OTHER_STAGES: if (i = 1) generate
--			W_DataInN(i) <= W_DataInC(i-1) when (W_En_wrC(i - 1) = '1') and (W_fullC = '0') else W_DataInC(i);
			-- Write register
--			reg_wr_stages: process(rst_wr, clk_wr)
--			begin
--				if (rst_wr = '1') then
--					W_DataInC(i) <= (others => '0');
--					W_WrPtrNextC(i) <= (others => '0');
--					W_RdPtrC(i) <= (others => '0');
--					W_RdPtrNextC(i) <= (others => '0');
--					W_WrPtrC(i) <= (others => '0');
--					W_En_wrC(i) <= '0';
--					W_En_rdC(i) <= '0';
--					EndRstC(i) <= '0';
--				elsif ((clk_wr'event) and (clk_wr = '1')) then
--					W_DataInC(i) <= W_DataInN(i);
--					W_WrPtrNextC(i) <= W_WrPtrNextN(i);
--					W_RdPtrC(i) <= W_RdPtrN(i);
--					W_RdPtrNextC(i) <= W_RdPtrNextN(i);
--					W_WrPtrC(i) <= W_WrPtrN(i);
--					W_En_rdC(i) <= W_En_rdN(i);
--					W_En_wrC(i) <= W_En_wrN(i);
--					EndRstC(i) <= EndRstN(i);
--				end if;
--			end process reg_wr_stages;

--			W_WrPtrNextN(i) <= W_WrPtrNextC(i-1);
--			W_RdPtrN(i) <= W_RdPtrC(i-1);
--			W_RdPtrNextN(i) <= W_RdPtrNextC(i-1);
--			W_WrPtrN(i) <= W_WrPtrC(i-1);
--			W_En_wrN(i) <= W_En_wrC(i-1);
--			W_En_rdN(i) <= W_En_rdC(i-1);

--			EndRstN(i) <= EndRstC(i-1);

			-- Read register
--			reg_rd_stages: process(rst_rd, clk_rd)
--			begin
--				if (rst_rd = '1') then
--					R_WrPtrNextC(i) <= (others => '0');
--					R_RdPtrC(i) <= (others => '0');
--					R_RdPtrNextC(i) <= (others => '0');
--					R_WrPtrC(i) <= (others => '0');
--					R_En_wrC(i) <= '0';
--					R_En_rdC(i) <= '0';
--				elsif ((clk_rd'event) and (clk_rd = '1')) then
--					R_WrPtrNextC(i) <= R_WrPtrNextN(i);
--					R_RdPtrC(i) <= R_RdPtrN(i);
--					R_RdPtrNextC(i) <= R_RdPtrNextN(i);
--					R_WrPtrC(i) <= R_WrPtrN(i);
--					R_En_rdC(i) <= R_En_rdN(i);
--					R_En_wrC(i) <= R_En_wrN(i);
--				end if;
--			end process reg_rd_stages;

--			R_WrPtrNextN(i) <= R_WrPtrNextC(i-1);
--			R_RdPtrN(i) <= R_RdPtrC(i-1);
--			R_RdPtrNextN(i) <= R_RdPtrNextC(i-1);
--			R_WrPtrN(i) <= R_WrPtrC(i-1);
--			R_En_wrN(i) <= R_En_wrC(i-1);
--			R_En_rdN(i) <= R_En_rdC(i-1);

--		end generate OTHER_STAGES;
--	end generate PIPELINE;

-- End of generate statement



end rtl;
