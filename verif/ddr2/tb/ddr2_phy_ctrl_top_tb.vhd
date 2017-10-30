library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;
library common_rtl_pkg;
use common_rtl_pkg.type_conversion_pkg.all;
use common_rtl_pkg.functions_pkg.all;
library common_tb_pkg;
use common_tb_pkg.functions_pkg_tb.all;
use common_tb_pkg.shared_pkg_tb.all;
library ddr2_rtl_pkg;
use ddr2_rtl_pkg.ddr2_define_pkg.all;
use ddr2_rtl_pkg.ddr2_phy_pkg.all;
use ddr2_rtl_pkg.ddr2_phy_cmd_ctrl_pkg.all;
library ddr2_tb_pkg;
use ddr2_tb_pkg.ddr2_pkg_tb.all;
use ddr2_tb_pkg.ddr2_log_pkg.all;

entity ddr2_phy_ctrl_top_tb is
end entity ddr2_phy_ctrl_top_tb;

architecture bench of ddr2_phy_ctrl_top_tb is

	constant CLK_PERIOD		: time := DDR2_CLK_PERIOD * 1 ns;
	constant NUM_TESTS		: integer := 1000;
	constant NUM_EXTRA_TESTS	: integer := 16;
	constant TOT_NUM_TESTS		: integer := NUM_TESTS + NUM_EXTRA_TESTS;
	constant MAX_ATTEMPTS		: integer := 20;

	constant ZERO_BANK_VEC		: std_logic_vector(BANK_NUM_TB - 1 downto 0) := (others => '0');

	constant MAX_BURST_DELAY	: integer := 20;
	constant MAX_CMD_DELAY		: integer := 20;
	constant MAX_REF_DELAY		: integer := integer(2.0**(real(COL_L_TB)));
	constant MAX_BANK_CMD_WAIT	: integer := 5;
	constant MAX_CMD_ACK_ACK_DELAY	: integer := 4;

	constant BURST_LENGTH_L_TB	: integer := COL_L_TB;

	constant REG_NUM_TB		: positive := 4;

	signal clk_tb	: std_logic := '0';
	signal stop	: boolean := false;
	signal rst_tb	: std_logic;

	-- MRS configuration
	signal DDR2CASLatency			; std_logic_vector(int_to_bit_num(CAS_LATENCY_MAX_VALUE) - 1 downto 0);
	signal DDR2BurstLength			; std_logic_vector(int_to_bit_num(BURST_LENGTH_MAX_VALUE) - 1 downto 0);
	signal DDR2AdditiveLatency		; std_logic_vector(int_to_bit_num(AL_MAX_VALUE) - 1 downto 0);
	signal DDR2WriteLatency			; std_logic_vector(int_to_bit_num(WRITE_LATENCY_MAX_VALUE) - 1 downto 0);
	signal DDR2HighTemperatureRefresh	; std_logic;

	-- Column Controller
	-- Controller
	signal ColCtrlCtrlReq		; std_logic_vector(COL_CTRL_NUM - 1 downto 0);
	signal ColCtrlReadBurstIn	; std_logic_vector(COL_CTRL_NUM - 1 downto 0);
	signal ColCtrlColMemIn		; std_logic_vector(COL_CTRL_NUM*COL_L - 1 downto 0);
	signal ColCtrlBankMemIn		; std_logic_vector(COL_CTRL_NUM*(int_to_bit_num(BANK_NUM)) - 1 downto 0);
	signal ColCtrlBurstLength	; std_logic_vector(COL_CTRL_NUM*BURST_LENGTH_L - 1 downto 0);

	signal ColCtrlCtrlAck		; std_logic_vector(COL_CTRL_NUM - 1 downto 0);

	-- Bank Controllers
	-- Transaction Controller
	signal BankCtrlRowMemIn		; std_logic_vector(BANK_CTRL_NUM*ROW_L - 1 downto 0);
	signal BankCtrlCtrlReq		; std_logic_vector(BANK_CTRL_NUM - 1 downto 0);

	signal BankCtrlCtrlAck		; std_logic_vector(BANK_CTRL_NUM - 1 downto 0);

	-- MRS Controller
	-- Transaction Controller
	signal MRSCtrlCtrlReq		; std_logic;
	signal MRSCtrlCtrlCmd		; std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal MRSCtrlCtrlData		; std_logic_vector(ADDR_MEM_L_TB - 1 downto 0);

	signal MRSCtrlCtrlAck		; std_logic;

	-- Refresh Controller
	-- Transaction Controller
	signal RefCtrlRefreshReq	; std_logic;
	signal RefCtrlNonReadOpEnable	; std_logic;
	signal RefCtrlReadOpEnable	; std_logic;

	-- PHY Init
	signal PhyInitCompleted		; std_logic;

	-- Controller
	signal RefCtrlCtrlReq		; std_logic;

	signal RefCtrlCtrlAck		; std_logic;

	-- ODT Controller
	-- ODT
	signal ODT			; std_logic;

	-- Arbiter
	-- Command Decoder
	signal CmdDecColMem		; std_logic_vector(COL_L - 1 downto 0);
	signal CmdDecRowMem		; std_logic_vector(ROW_L - 1 downto 0);
	signal CmdDecBankMem		; std_logic_vector(int_to_bit_num(BANK_NUM) - 1 downto 0);
	signal CmdDecCmdMem		; std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal CmdDecMRSCmd		; std_logic_vector(ADDR_MEM_L_TB - 1 downto 0)

begin

	DUT: ddr2_phy_ctrl_top generic map (
		BANK_CTRL_NUM => BANK_CTRL_NUM_TB,
		COL_CTRL_NUM => COL_CTRL_NUM_TB,
		BURST_LENGTH_L => BURST_LENGTH_L_TB,
		BANK_NUM => BANK_NUM_TB,
		COL_L => COL_L_TB,
		ROW_L => ROW_L_TB,
		MRS_REG_L => ADDR_MEM_L_TB,
		MAX_OUTSTANDING_BURSTS => MAX_OUTSTANDING_BURSTS_TB
	)
	port map (
		clk => clk_tb,
		rst => rst_tb,

		-- MRS configuration
		DDR2CASLatency => DDR2CASLatency_tb,
		DDR2BurstLength => DDR2BurstLength_tb,
		DDR2AdditiveLatency => DDR2AdditiveLatency_tb,
		DDR2WriteLatency => DDR2WriteLatency_tb,
		DDR2HighTemperatureRefresh => DDR2HighTemperatureRefresh_tb,

		-- Column Controller
		-- Controller
		ColCtrlCtrlReq => ColCtrlCtrlReq_tb,
		ColCtrlReadBurstIn => ColCtrlReadBurstIn_tb,
		ColCtrlColMemIn => ColCtrlColMemIn_tb,
		ColCtrlBankMemIn => ColCtrlBankMemIn_tb,
		ColCtrlBurstLength => ColCtrlBurstLength_tb,

		ColCtrlCtrlAck => ColCtrlCtrlAck_tb,

		-- Bank Controllers
		-- Transaction Controller
		BankCtrlRowMemIn => BankCtrlRowMemIn_tb,
		BankCtrlCtrlReq => BankCtrlCtrlReq_tb,

		BankCtrlCtrlAck => BankCtrlCtrlAck_tb,

		-- MRS Controller
		-- Transaction Controller
		MRSCtrlCtrlReq => MRSCtrlCtrlReq_tb,
		MRSCtrlCtrlCmd => MRSCtrlCtrlCmd_tb,
		MRSCtrlCtrlData => MRSCtrlCtrlData_tb,

		MRSCtrlCtrlAck => MRSCtrlCtrlAck_tb,

		-- Refresh Controller
		-- Transaction Controller
		RefCtrlRefreshReq => RefCtrlRefreshReq_tb,
		RefCtrlNonReadOpEnable => RefCtrlNonReadOpEnable_tb,
		RefCtrlReadOpEnable => RefCtrlReadOpEnable_tb,

		-- PHY Init
		PhyInitCompleted => PhyInitCompleted_tb,

		-- Controller
		RefCtrlCtrlReq => RefCtrlCtrlReq_tb,

		RefCtrlCtrlAck => RefCtrlCtrlAck_tb,

		-- ODT Controller
		-- ODT
		ODT => ODT_tb,

		-- Arbiter
		-- Command Decoder
		CmdDecColMem => CmdDecColMem_tb,
		CmdDecRowMem => CmdDecRowMem_tb,
		CmdDecBankMem => CmdDecBankMem_tb,
		CmdDecCmdMem => CmdDecCmdMem_tb,
		CmdDecMRSCmd => CmdDecMRSCmd_tb

	);

	clk_gen(CLK_PERIOD, 0 ns, stop, clk_tb);

	test: process

		procedure reset is
		begin
			rst_tb <= '0';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_tb <= '1';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_tb <= '0';
		end procedure reset;

		procedure test_param(variable num_bursts, burst_bits, al, wl, cas : out integer; variable high_temp : out boolean; variable num_bursts_arr : out int_arr(0 to (BANK_NUM_TB - 1)); variable bank, cols, rows, mrs_data : out int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable read_burst : out bool_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable bl, cmd_delay, ctrl_delay : out int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable rw_burst, ref, mrs : out bool_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable ref_delay, mrs_cmd : out int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable seed1, seed2 : inout positive) is
			variable rand_val		: real;
			variable bl4_int		: boolean;
			variable num_bursts_arr_int	: int_arr(0 to (BANK_NUM_TB - 1));
			variable num_bursts_int		: integer;
			variable bl_int			: integer;
			variable col_int		: integer;
			variable bank_int		: integer;
			variable attempt_num		: integer;
			variable burst_bits_int		: integer;
			variable rw_burst_int		: boolean;
			variable mrs_cmd_id		: integer;
		begin
			num_bursts_int := 0;
			num_bursts_arr_int := reset_int_arr(0, BANK_NUM_TB);
			uniform(seed1, seed2, rand_val);
			num_bursts_int := integer(rand_val*real(BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));
			num_bursts := num_bursts_int;

			uniform(seed1, seed2, rand_val);
			bl4_int := rand_bool(rand_val, 0.5);

			if (bl4_int = true) then
				burst_bits_int := 2;
			else
				burst_bits_int := 3;
			end if;
			burst_bits := burst_bits_int;

			uniform(seed1, seed2, rand_val);
			al := integer(rand_val*real(AL_MAX_VALUE));

			uniform(seed1, seed2, rand_val);
			wl := integer(rand_val*real(WRITE_LATENCY_MAX_VALUE));

			uniform(seed1, seed2, rand_val);
			cas := integer(rand_val*real(CAS_LATENCY_MAX_VALUE));

			uniform(seed1, seed2, rand_val);
			high_temp := rand_bool(rand_val, 0.5);

			for i in 0 to (num_bursts_int - 1) loop
				uniform(seed1, seed2, rand_val);
				rw_burst_int := rand_bool(rand_val, 0.5);
				rw_burst(i) := rw_burst_int;

				uniform(seed1, seed2, rand_val);
				ref(i) := rand_bool(rand_val, 0.5);

				uniform(seed1, seed2, rand_val);
				ref_delay(i) := integer(rand_val*real(MAX_REF_DELAY));

				uniform(seed1, seed2, rand_val);
				cmd_delay(i) := integer(rand_val*real(MAX_CMD_DELAY));

				uniform(seed1, seed2, rand_val);
				ctrl_delay(i) := integer(rand_val*real(MAX_BURST_DELAY));

				if (rw_burst_int = true) then -- rd/wr burst
					-- select bank
					uniform(seed1, seed2, rand_val);
					bank_int := integer(rand_val*real(BANK_NUM_TB - 1));
					bank(i) := bank_int;
					num_bursts_arr_int(bank_int) := num_bursts_arr_int(bank_int) + 1;

					uniform(seed1, seed2, rand_val);
					col_int := integer(rand_val*(2.0**(real(COL_L_TB - burst_bits_int)) - 1.0));
					cols(i) := col_int*(2**burst_bits_int);
					bl_int := 0;
					attempt_num := 0;
					while ((bl_int <= 0) and (attempt_num < MAX_ATTEMPTS)) loop
						uniform(seed1, seed2, rand_val);
						bl_int := round(rand_val*((2.0**(real(COL_L_TB - burst_bits_int)) - real(col_int) - 1.0)));
						attempt_num := attempt_num + 1;
					end loop;
					if (attempt_num = MAX_ATTEMPTS) then
						bl_int := 1;
					end if;
					bl(i) := bl_int;

					uniform(seed1, seed2, rand_val);
					rows(i) := integer(rand_val*(2.0**(real(ROW_L_TB)) - 1.0));

					uniform(seed1, seed2, rand_val);
					read_burst(i) := rand_bool(rand_val, 0.5);

					mrs(i) := false;
					mrs_data(i) := 0;
					mrs_cmd(i) := to_integer(unsigned(CMD_NOP));

				else

					uniform(seed1, seed2, rand_val);
					mrs(i) := rand_bool(rand_val, 0.5);

					uniform(seed1, seed2, rand_val);
					mrs_data(i) := integer(rand_val*(2.0**(real(ADDR_MEM_L_TB)) - 1.0));

					uniform(seed1, seed2, rand_val);
					mrs_cmd_id := integer(rand_val*real(REG_NUM_TB));
					if (mrs_cmd_id = 0) then
						mrs_cmd(i) := to_integer(unsigned(CMD_MODE_REG_SET));
					elsif (mrs_cmd_id = 1) then
						mrs_cmd(i) := to_integer(unsigned(CMD_EXT_MODE_REG_SET_1));
					elsif (mrs_cmd_id = 2) then
						mrs_cmd(i) := to_integer(unsigned(CMD_EXT_MODE_REG_SET_2));
					elsif (mrs_cmd_id = 3) then
						mrs_cmd(i) := to_integer(unsigned(CMD_EXT_MODE_REG_SET_3));
					else
						uniform(seed1, seed2, rand_val);
						mrs_cmd(i) := integer(rand_val*real(2.0**(real(MEM_CMD_L)) - 1.0));
					end if;

					bank(i) := int_arr_def;
					rows(i) := int_arr_def;
					cols(i) := int_arr_def;
					bl(i) := int_arr_def;

					read_burst(i) := false;

				end if;

			end loop;

			for i in num_bursts_int to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1) loop

				bank(i) := int_arr_def;
				rows(i) := int_arr_def;
				cols(i) := int_arr_def;
				bl(i) := int_arr_def;

				ref_delay(i) := int_arr_def;
				cmd_delay(i) := int_arr_def;
				ctrl_delay(i) := int_arr_def;
				read_burst(i) := false;

				ref(i) := false;

				mrs(i) := false;
				mrs_data(i) := int_arr_def;
				mrs_cmd(i) := int_arr_def;

				rw_burst(i) := false;
			end loop;

		end procedure test_param;

		procedure run_ctrl_top(variable num_bursts_exp, burst_bits, al, wl, cas : in integer; variable high_temp : in boolean; variable bank, cols, rows, mrs_data : in int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable read_burst : in bool_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable bl, cmd_delay, ctrl_delay : in int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable rw_burst, ref, mrs : in bool_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable ref_delay, mrs_cmd : in int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable bank_rtl, bank_exp, col_rtl, col_exp, row_rtl, row_exp, cmd_rtl, cmd_exp, mrs_rtl, mrs_exp : out int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1))) is

			variable bank_ctrl_bursts_int		: integer;
			variable col_ctrl_bursts_int		: integer;
			variable ref_ctrl_bursts_int		: integer;
			variable mrs_ctrl_bursts_int		: integer;

			variable bank_ctrl_bank			: integer;
			variable bank_ctrl_row			: integer;

			variable col_ctrl_bank			: integer;
			variable col_ctrl_col			: integer;
			variable col_ctrl_bl			: integer;
			variable col_ctrl_read_burst		: boolean;

			variable mrs_ctrl_cmd			: integer;
			variable mrs_ctrl_data			: integer;

			variable rw_burst_int			: boolean;
			variable ref_ctrl_en			: boolean;
			variable mrs_ctrl_en			: boolean;

			variable col_cmd_delay_int		: integer;
			variable bank_ctrl_delay_int		: integer;
			variable mrs_cmd_delay_int		: integer;
			variable ref_delay_int			: integer;

		begin

			-- MRS configuration
			DDR2BurstLength_tb <= std_logic_vector(to_unsigned(burst_bits, int_to_bit_num(BURST_LENGTH_MAX_VALUE)));
			DDR2CASLatency_tb <= std_logic_vector(to_unsigned(cas, int_to_bit_num(CAS_LATENCY_MAX_VALUE)));
			DDR2AdditiveLatency_tb <= std_logic_vector(to_unsigned(al, int_to_bit_num(AL_MAX_VALUE)));
			DDR2WriteLatency_tb <= std_logic_vector(to_unsigned(wl, int_to_bit_num(WRITE_LATENCY_MAX_VALUE)));
			DDR2HighTemperature <= bool_to_std_logic(high_temp);

			-- Column Controller
			-- Controller
			ColCtrlCtrlReq_tb <= (others => '0');
			ColCtrlReadBurstIn_tb <= (others => '0');
			ColCtrlColMemIn_tb <= (others => '0');
			ColCtrlBankMemIn_tb <= (others => '0');
			ColCtrlBurstLength_tb <= (others => '0');

			-- Bank Controllers
			-- Transaction Controller
			BankCtrlRowMemIn_tb <= (others => '0');
			BankCtrlCtrlReq_tb <= (others => '0');

			-- MRS Controller
			-- Transaction Controller
			MRSCtrlCtrlReq <= '0';
			MRSCtrlCtrlCmd <= CMD_NOP;
			MRSCtrlCtrlData <= (others => '0');

			-- Refresh Controller
			-- PHY Init
			PhyInitCompleted <= '0';

			-- Controller
			RefCtrlCtrlReq <= '0';

			bank_ctrl_bursts_int := 0;
			col_ctrl_bursts_int := 0;
			ref_ctrl_bursts_int := 0;
			mrs_ctrl_bursts_int := 0;

			rw_burst_int := rw_burst(bank_ctrl_bursts_int);
			ref_ctrl_en := ref(ref_ctrl_bursts_int);
			mrs_ctrl_en := ref(mrs_ctrl_bursts_int);

			bank_ctrl_bank := bank(bank_ctrl_bursts_int);
			bank_ctrl_row := rows(bank_ctrl_bursts_int);

			col_ctrl_bank := bank(col_ctrl_bursts_int);
			col_ctrl_col := col(col_ctrl_bursts_int);
			col_ctrl_bl := bl(col_ctrl_bursts_int);
			col_ctrl_read_burst := read_burst(col_ctrl_bursts_int);

			mrs_ctrl_cmd := mrs_cmd(mrs_ctrl_bursts_int);
			mrs_ctrl_data := mrs_data(mrs_ctrl_bursts_int);

			bank_cmd_delay_int := ctrl_delay(bank_ctrl_bursts_int);
			col_cmd_delay_int := cmd_delay(col_ctrl_bursts_int);
			mrs_cmd_delay_int := cmd_delay(mrs_ctrl_bursts_int);
			ref_delay_int := ref_delay(ref_ctrl_bursts_int);

			ctrl_top: loop

				wait until ((clk_tb = '1') and (clk_tb'event));

				exit ctrl_loop when ((bank_ctrl_burst_int = num_bursts_exp) and (col_ctrl_burst_int = num_bursts_exp) and (mrs_ctrl_burst_int = num_bursts_exp) and (ref_ctrl_burst_int = num_bursts_exp));

		end procedure run_ctrl_top;
