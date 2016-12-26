library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bram_pkg.all;
use work.proc_pkg.all;
use work.fifo_2clk_pkg.all;

entity fifo_2clk is
generic (
	ADDR_RST_VAL	: natural := 0;
	DATA_L		: positive := 32;
	FIFO_SIZE	: positive := 16;
	RD_CLK_PERIOD	: positive := 1000; -- period in ns
	WR_CLK_PERIOD	: positive := 1000 -- period in ns
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

	constant ADDR_L	: positive := int_to_bit_num(FIFO_SIZE);
	constant GRAY_RST_VAL	: natural := bin_to_gray(ADDR_RST_VAL, ADDR_L);

	type addr_array is array (0 to NUM_STAGES - 1) of unsigned(ADDR_L - 1 downto 0);

	signal WrPtrC	: unsigned(ADDR_L - 1 downto 0);
	signal RdPtrC	: unsigned(ADDR_L - 1 downto 0);

	signal WrPtrP1C, WrPtrP2C	: unsigned(ADDR_L - 1 downto 0);
	signal RdPtrP1C			: unsigned(ADDR_L - 1 downto 0);

	signal wr_cnt_rst_flag	: std_logic;
	signal rd_cnt_rst_flag	: std_logic;

	signal R_WrPtrC, R_WrPtrN	: addr_array;
	signal W_RdPtrC, W_RdPtrN	: addr_array;

	signal AddressRst	: std_logic_vector(ADDR_L - 1 downto 0);

	signal DataIn_fifo	: std_logic_vector(DATA_L - 1 downto 0);
	signal DataOut_fifo	: std_logic_vector(DATA_L - 1 downto 0);

	signal DoneReset	: std_logic;
	signal W_EndRstC, W_EndRstN	: std_logic;
	signal R_EndRstC, R_EndRstN	: std_logic;
	signal rst_wrC, rst_wrN	: std_logic;

	signal ValidOutC, ValidOutN	: std_logic;

	signal PortB_Write	: std_logic;
	signal PortA_Write	: std_logic;
begin


	WR_CNT : gray_cnt generic map (
		DATA_L => ADDR_L,
		BIN_RST_VAL => 0
	)
	port map (
		rst => rst_wr,
		sync_rst => '0',
		clk => clk_wr,

		gray_cnt_out => WrPtrC,

		bin_rst_flag => wr_cnt_rst_flag

	);

	WR_CNT_P1 : gray_cnt generic map (
		DATA_L => ADDR_L,
		BIN_RST_VAL => 1
	)
	port map (
		rst => rst_wr,
		sync_rst => wr_cnt_rst_flag,
		clk => clk_wr,

		gray_cnt_out => WrPtrP1C,

		bin_rst_flag => open

	);

	WR_CNT_P2 : gray_cnt generic map (
		DATA_L => ADDR_L,
		BIN_RST_VAL => 2
	)
	port map (
		rst => rst_wr,
		sync_rst => wr_cnt_rst_flag,
		clk => clk_wr,

		gray_cnt_out => WrPtrP2C,

		bin_rst_flag => open

	);

	RD_CNT : gray_cnt generic map (
		DATA_L => ADDR_L,
		BIN_RST_VAL => 0
	)
	port map (
		rst => rst_rd,
		sync_rst => '0',
		clk => clk_rd,

		gray_cnt_out => RdPtrC,

		bin_rst_flag => rd_cnt_rst_flag

	);

	RD_CNT_P1 : gray_cnt generic map (
		DATA_L => ADDR_L,
		BIN_RST_VAL => 1
	)
	port map (
		rst => rst_rd,
		sync_rst => rd_cnt_rst_flag,
		clk => clk_rd,

		gray_cnt_out => RdPtrP1C,

		bin_rst_flag => open

	);

	rd_reg : process(rst_rd, clk_rd) begin
		if (rst_rd = '1') then
			ValidOutC <= '0';
		elsif ((clk_rd'event) and (clk_rd = '1')) then
			ValidOutC <= ValidOutN;
		end if;
	end process rd_reg;

	register_stages : for i in 0 to (NUM_STAGES - 1) generate
		first_stage : if (i = 0) generate
			R_WrPtrN(0) <= WrPtrC;
			W_RdPtrN(0) <= RdPtrC;
		end generate first_stage;

		other_stages : if (i /= 0) generate
			R_WrPtrN(i) <= R_WrPtrC(i-1);
			W_RdPtrN(i) <= W_RdPtrC(i-1);
		end generate other_stages;

		wr_reg : process(rst_wr, clk_wr) begin
			if (rst_wr = '1') then
				W_RdPtrC(i) <= to_unsigned(GRAY_RST_VAL, DATA_L);
			elsif ((clk_wr'event) and (clk_wr = '1')) then
				W_RdPtrC(i) <= W_RdPtrN(i);
			end if;
		end process wr_reg;

		rd_reg : process(rst_rd, clk_rd) begin
			if (rst_rd = '1') then
				R_WrPtrC(i) <= to_unsigned(GRAY_RST_VAL, DATA_L);
			elsif ((clk_rd'event) and (clk_rd = '1')) then
				R_WrPtrC(i) <= R_WrPtrN(i);
			end if;
		end process rd_reg;
	end generate register_stages;

	emtpy_flag : fifo_ctrl generic map(
		ADDR_L => ADDR_L,
		RST_VAL => 1
	)
	port map (
		rst => rst_rd,
		clk => clk_rd,

		Ptr => RdPtrC,
		PtrP1 => RdPtrP1C,
		Ptr2 => R_WrPtrC(NUM_STAGES-1),

		En => En_rd,

		flag => empty,
		nflag => ValidOut
	);

	full_flag : fifo_ctrl generic map(
		ADDR_L => ADDR_L,
		RST_VAL => 0
	)
	port map (
		rst => rst_wr,
		clk => clk_wr,

		Ptr => WrPtrC,
		PtrP1 => WrPtrP1C,
		Ptr2 => W_RdPtrC(NUM_STAGES-1),

		En => En_wr,

		flag => full,
		nflag => open
	);

	FIFO_2PORT_I : bram_2port generic map(
		ADDR_BRAM_L => ADDR_L,
		BRAM_LINE => FIFO_SIZE,
		DATA_L => DATA_L
	)
	port map (
		PortA_clk => clk,
		PortB_clk => clk,

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
		ADDR_L => ADDR_L
	)
	 port map (
		rst => rst_wr,
		clk => clk,

		Start => rst_wrC,
		Done => DoneReset,

		-- BRAM
		PortA_Address => AddressRst,
		PortB_Address => open
	);

end rtl;
