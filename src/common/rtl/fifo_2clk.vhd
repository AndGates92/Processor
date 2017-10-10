library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
library common_rtl_pkg;
use common_rtl_pkg.bram_pkg.all;
use common_rtl_pkg.functions_pkg.all;
use common_rtl_pkg.fifo_1clk_pkg.all;

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

	signal WrPtrC		: std_logic_vector(ADDR_L - 1 downto 0);
	signal WrPtrCMux	: std_logic_vector(ADDR_L - 1 downto 0);
	signal RdPtrC		: std_logic_vector(ADDR_L - 1 downto 0);

	signal WrPtrP1C, WrPtrP2C	: std_logic_vector(ADDR_L - 1 downto 0);
	signal RdPtrP1C			: std_logic_vector(ADDR_L - 1 downto 0);

	signal wr_cnt_rst_flag	: std_logic;
	signal rd_cnt_rst_flag	: std_logic;

	signal R_WrPtrC, R_WrPtrN	: addr_array;
	signal W_RdPtrC, W_RdPtrN	: addr_array;

	signal AddressRst	: std_logic_vector(ADDR_L - 1 downto 0);

	signal DataIn_fifo	: std_logic_vector(DATA_L - 1 downto 0);

	signal DoneReset		: std_logic;
	signal W_EndRstC, W_EndRstN	: std_logic;
	signal R_EndRstC, R_EndRstN	: std_logic_vector(NUM_STAGES-1 downto 0);
	signal rst_wrC, rst_wrN		: std_logic;

	signal En_wr_incr	: std_logic;
	signal En_rd_incr	: std_logic;

	signal PortB_Write	: std_logic;
	signal PortA_Write	: std_logic;

	signal fullC	: std_logic;
	signal nEmpty	: std_logic;

begin

	-- Write register
	reg_wr: process(rst_wr, clk_wr)
	begin
		if (rst_wr = '1') then
			W_EndRstC <= '0';
			rst_wrC <= '1';
		elsif ((clk_wr'event) and (clk_wr = '1')) then
			W_EndRstC <= W_EndRstN;
			rst_wrC <= rst_wrN;
		end if;
	end process reg_wr;

	rst_wrN <= rst_wr;

	En_wr_incr <= En_wr and W_EndRstC;

	WrPtrCMux <=	AddressRst when (W_EndRstC = '0') else
			WrPtrC;

	WR_CNT : gray_cnt generic map (
		DATA_L => ADDR_L,
		BIN_RST_VAL => 0
	)
	port map (
		rst => rst_wr,
		sync_rst => '0',
		clk => clk_wr,

		En => En_wr_incr,

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

		En => En_wr_incr,

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

		En => En_wr_incr,

		gray_cnt_out => WrPtrP2C,

		bin_rst_flag => open

	);

	En_rd_incr <= En_rd and R_EndRstC(NUM_STAGES-1);

	RD_CNT : gray_cnt generic map (
		DATA_L => ADDR_L,
		BIN_RST_VAL => 0
	)
	port map (
		rst => rst_rd,
		sync_rst => '0',
		clk => clk_rd,

		En => En_rd_incr,

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

		En => En_rd_incr,

		gray_cnt_out => RdPtrP1C,

		bin_rst_flag => open

	);

	W_EndRstN <=	'0' when (rst_wr = '1') else
			'1' when (DoneReset = '1') else
			W_EndRstC;

	EndRst <= W_EndRstC;

	register_stages : for i in 0 to (NUM_STAGES - 1) generate
		first_stage : if (i = 0) generate
			R_EndRstN(0) <= W_EndRstN;
			R_WrPtrN(0) <= unsigned(WrPtrC);
			W_RdPtrN(0) <= unsigned(RdPtrC);
		end generate first_stage;

		other_stages : if (i /= 0) generate
			R_EndRstN(i) <= R_EndRstC(i-1);
			R_WrPtrN(i) <= R_WrPtrC(i-1);
			W_RdPtrN(i) <= W_RdPtrC(i-1);
		end generate other_stages;

		wr_reg : process(rst_wr, clk_wr) begin
			if (rst_wr = '1') then
				W_RdPtrC(i) <= to_unsigned(GRAY_RST_VAL, ADDR_L);
			elsif ((clk_wr'event) and (clk_wr = '1')) then
				W_RdPtrC(i) <= W_RdPtrN(i);
			end if;
		end process wr_reg;

		rd_reg : process(rst_rd, clk_rd) begin
			if (rst_rd = '1') then
				R_EndRstC(i) <= '0';
				R_WrPtrC(i) <= to_unsigned(GRAY_RST_VAL, ADDR_L);
			elsif ((clk_rd'event) and (clk_rd = '1')) then
				R_EndRstC(i) <= R_EndRstN(i);
				R_WrPtrC(i) <= R_WrPtrN(i);
			end if;
		end process rd_reg;
	end generate register_stages;

	ValidOut <= nEmpty and En_rd;

	empty_flag : fifo_ctrl generic map(
		ADDR_L => ADDR_L,
		RST_VAL => 1
	)
	port map (
		rst => rst_rd,
		clk => clk_rd,

		Ptr => std_logic_vector(RdPtrC),
		PtrP1 => std_logic_vector(RdPtrP1C),
		Ptr2 => std_logic_vector(R_WrPtrC(NUM_STAGES-1)),

		En => En_rd,

		flag => empty,
		nflag => nEmpty
	);

	full_flag : fifo_ctrl generic map(
		ADDR_L => ADDR_L,
		RST_VAL => 0
	)
	port map (
		rst => rst_wr,
		clk => clk_wr,

		Ptr => std_logic_vector(WrPtrC),
		PtrP1 => std_logic_vector(WrPtrP1C),
		Ptr2 => std_logic_vector(W_RdPtrC(NUM_STAGES-1)),

		En => En_wr,

		flag => fullC,
		nflag => open
	);

	full <= fullC;

	PortB_Write <=	En_wr_incr when (fullC = '0') else '0';
	PortA_Write <=	'0';

	DataIn_fifo <= DataIn when (W_EndRstC = '1') else (others => '0');


	FIFO_2PORT_I : bram_2port generic map(
		ADDR_BRAM_L => ADDR_L,
		BRAM_LINE => FIFO_SIZE,
		DATA_L => DATA_L
	)
	port map (
		PortA_clk => clk_rd,
		PortB_clk => clk_wr,

		-- BRAM
		PortA_Address => RdPtrC,
		PortA_Write => PortA_Write,
		PortA_DataIn => (others => '0'),
		PortA_DataOut => DataOut,

		PortB_Address => WrPtrCMux,
		PortB_Write => PortB_Write,
		PortB_DataIn => DataIn_fifo,
		PortB_DataOut => open
	);

	FIFO_RST_I : bram_rst generic map(
		ADDR_L => ADDR_L
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
