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
use ddr2_rtl_pkg.ddr2_mrs_max_pkg.all;
use ddr2_rtl_pkg.ddr2_define_pkg.all;
use ddr2_rtl_pkg.ddr2_phy_pkg.all;
use ddr2_rtl_pkg.ddr2_phy_ctrl_top_pkg.all;
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
	signal DDR2CASLatency_tb		: std_logic_vector(int_to_bit_num(CAS_LATENCY_MAX_VALUE) - 1 downto 0);
	signal DDR2BurstLength_tb		: std_logic_vector(int_to_bit_num(BURST_LENGTH_MAX_VALUE) - 1 downto 0);
	signal DDR2AdditiveLatency_tb		: std_logic_vector(int_to_bit_num(AL_MAX_VALUE) - 1 downto 0);
	signal DDR2WriteLatency_tb		: std_logic_vector(int_to_bit_num(WRITE_LATENCY_MAX_VALUE) - 1 downto 0);
	signal DDR2HighTemperatureRefresh_tb	: std_logic;

	-- Column Controller
	-- Controller
	signal ColCtrlCtrlReq_tb		: std_logic_vector(COL_CTRL_NUM_TB - 1 downto 0);
	signal ColCtrlReadBurstIn_tb		: std_logic_vector(COL_CTRL_NUM_TB - 1 downto 0);
	signal ColCtrlColMemIn_tb		: std_logic_vector(COL_CTRL_NUM_TB*COL_L_TB - 1 downto 0);
	signal ColCtrlBankMemIn_tb		: std_logic_vector(COL_CTRL_NUM_TB*(int_to_bit_num(BANK_NUM_TB)) - 1 downto 0);
	signal ColCtrlBurstLength_tb		: std_logic_vector(COL_CTRL_NUM_TB*BURST_LENGTH_L_TB - 1 downto 0);

	signal ColCtrlCtrlAck_tb		: std_logic_vector(COL_CTRL_NUM_TB - 1 downto 0);

	-- Bank Controllers
	-- Transaction Controller
	signal BankCtrlRowMemIn_tb		: std_logic_vector(BANK_CTRL_NUM_TB*ROW_L_TB - 1 downto 0);
	signal BankCtrlCtrlReq_tb		: std_logic_vector(BANK_CTRL_NUM_TB - 1 downto 0);

	signal BankCtrlCtrlAck_tb		: std_logic_vector(BANK_CTRL_NUM_TB - 1 downto 0);

	-- MRS Controller
	-- Transaction Controller
	signal MRSCtrlCtrlReq_tb		: std_logic;
	signal MRSCtrlCtrlCmd_tb		: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal MRSCtrlCtrlData_tb		: std_logic_vector(ADDR_MEM_L_TB - 1 downto 0);

	signal MRSCtrlCtrlAck_tb		: std_logic;

	-- Refresh Controller
	-- Transaction Controller
	signal RefCtrlRefreshReq_tb		: std_logic;
	signal RefCtrlNonReadOpEnable_tb	: std_logic;
	signal RefCtrlReadOpEnable_tb		: std_logic;

	-- PHY Init
	signal PhyInitCompleted_tb		: std_logic;

	-- Controller
	signal RefCtrlCtrlReq_tb		: std_logic;

	signal RefCtrlCtrlAck_tb		: std_logic;

	-- ODT Controller
	-- ODT
	signal ODT_tb				: std_logic;

	-- Arbiter
	-- Command Decoder
	signal CmdDecColMem_tb			: std_logic_vector(COL_L_TB - 1 downto 0);
	signal CmdDecRowMem_tb			: std_logic_vector(ROW_L_TB - 1 downto 0);
	signal CmdDecBankMem_tb			: std_logic_vector(int_to_bit_num(BANK_NUM_TB) - 1 downto 0);
	signal CmdDecCmdMem_tb			: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal CmdDecMRSCmd_tb			: std_logic_vector(ADDR_MEM_L_TB - 1 downto 0);

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

		procedure test_param(variable num_bursts, ref_req, burst_bits, al, wl, cas : out integer; variable high_temp : out boolean; variable num_bursts_arr : out int_arr(0 to (BANK_NUM_TB - 1)); variable bank, cols, rows, mrs_data : out int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable read_burst : out bool_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable bl, cmd_delay, ctrl_delay : out int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable rw_burst, ref, mrs, auto_ref : out bool_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable ref_delay, mrs_cmd : out int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable seed1, seed2 : inout positive) is
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
			variable ref_int		: boolean;
			variable ref_req_int		: integer;
		begin
			num_bursts_int := 0;
			ref_req := 0;
			ref_req_int := 0;
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
				ref_int := rand_bool(rand_val, 0.5);
				ref(i) := ref_int;
				if (ref_int = true) then
					ref_req_int := ref_req_int + 1;
				end if;

				uniform(seed1, seed2, rand_val);
				auto_ref(i) := rand_bool(rand_val, 0.25);

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
				auto_ref(i) := false;

				mrs(i) := false;
				mrs_data(i) := int_arr_def;
				mrs_cmd(i) := int_arr_def;

				rw_burst(i) := false;
			end loop;

			ref_req := ref_req_int;

		end procedure test_param;

		procedure run_ctrl_top(variable num_bursts_exp, ref_req, burst_bits, al, wl, cas : in integer; variable high_temp : in boolean; variable bank, cols, rows, mrs_data : in int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable read_burst : in bool_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable bl, cmd_delay, ctrl_delay : in int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable rw_burst, ref, auto_ref, mrs : in bool_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable ref_delay, mrs_cmd : in int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable num_bursts_rtl : out integer; variable mrs_bank_ctrl_err_arr, col_ctrl_err_arr, ref_ctrl_err_arr, bank_ctrl_bank_rtl, bank_ctrl_bank_exp, row_rtl, row_exp, mrs_bank_cmd_rtl, mrs_bank_cmd_exp, mrs_rtl, mrs_exp, cmd_sent_in_self_ref_err : out int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable ref_cmd_rtl, ref_cmd_exp : out int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1), 0 to 1); variable col_rtl, col_exp, col_cmd_rtl, col_cmd_exp, col_ctrl_bank_rtl, col_ctrl_bank_exp : out int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1), 0 to (integer(2.0**(real(BURST_LENGTH_L_TB)) - 1.0)))) is

			variable mrs_bank_ctrl_bursts_int	: integer;
			variable ref_col_cmd_bursts_int		: integer;

			variable bank_ctrl_bank			: integer;
			variable bank_ctrl_row			: integer;

			variable col_ctrl_bank			: integer;
			variable col_ctrl_col			: integer;
			variable col_ctrl_bl			: integer;
			variable col_ctrl_read_burst		: boolean;

			variable mrs_ctrl_cmd			: integer;
			variable mrs_ctrl_data			: integer;

			variable rw_burst_bank			: boolean;
			variable rw_burst_col			: boolean;
			variable ref_ctrl_en			: boolean;
			variable ref_ctrl_auto_ref		: boolean;
			variable mrs_ctrl_en			: boolean;

			variable col_cmd_delay_int		: integer;
			variable bank_ctrl_delay_int		: integer;
			variable mrs_cmd_delay_int		: integer;
			variable ref_delay_int			: integer;

			variable ctrl_delay_cnt			: integer;
			variable col_cmd_delay_cnt		: integer;
			variable ref_delay_cnt			: integer;

			variable mrs_bank_ctrl_req		: boolean;
			variable col_cmd_req			: boolean;
			variable ref_ctrl_req			: boolean;
			variable self_ref			: boolean;

			variable end_col_cmd			: boolean;
			variable ref_done			: boolean;

			variable mrs_bank_ctrl_handshake	: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));

			variable mrs_bank_ctrl_err_int		: integer;
			variable col_cmd_err_int		: integer;
			variable ref_ctrl_err_int		: integer;

			variable bl_cnt				: integer;

			variable mrs_bank_cmd_cnt_rtl		: integer;
			variable col_cmd_cnt_rtl		: integer;
			variable ref_cmd_cnt_rtl		: integer;

			variable rtl_ref_cmd_cnt		: integer;

			variable mrs_bank_cmd_cnt		: integer;
			variable col_cmd_cnt			: integer;
			variable ref_cmd_cnt			: integer;

			variable exp_self_ref_exit		: boolean;
			variable col_cmd_bl_cnt			: integer;
			variable cmd_sent_in_self_ref		: integer;

		begin

			-- MRS configuration
			DDR2BurstLength_tb <= std_logic_vector(to_unsigned(burst_bits, int_to_bit_num(BURST_LENGTH_MAX_VALUE)));
			DDR2CASLatency_tb <= std_logic_vector(to_unsigned(cas, int_to_bit_num(CAS_LATENCY_MAX_VALUE)));
			DDR2AdditiveLatency_tb <= std_logic_vector(to_unsigned(al, int_to_bit_num(AL_MAX_VALUE)));
			DDR2WriteLatency_tb <= std_logic_vector(to_unsigned(wl, int_to_bit_num(WRITE_LATENCY_MAX_VALUE)));
			DDR2HighTemperatureRefresh_tb <= bool_to_std_logic(high_temp);

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
			MRSCtrlCtrlReq_tb <= '0';
			MRSCtrlCtrlCmd_tb <= CMD_NOP;
			MRSCtrlCtrlData_tb <= (others => '0');

			-- Refresh Controller
			-- PHY Init
			PhyInitCompleted_tb <= '0';

			-- Controller
			RefCtrlCtrlReq_tb <= '0';

			mrs_bank_ctrl_bursts_int := 0;
			ref_col_cmd_bursts_int := 0;

			rw_burst_bank := rw_burst(mrs_bank_ctrl_bursts_int);
			rw_burst_col := rw_burst(ref_col_cmd_bursts_int);
			ref_ctrl_en := ref(ref_col_cmd_bursts_int);
			ref_ctrl_auto_ref := auto_ref(ref_col_cmd_bursts_int);
			mrs_ctrl_en := mrs(mrs_bank_ctrl_bursts_int);

			bank_ctrl_bank := bank(mrs_bank_ctrl_bursts_int);
			bank_ctrl_row := rows(mrs_bank_ctrl_bursts_int);

			col_ctrl_bank := bank(ref_col_cmd_bursts_int);
			col_ctrl_col := cols(ref_col_cmd_bursts_int);
			col_ctrl_bl := bl(ref_col_cmd_bursts_int);
			col_ctrl_read_burst := read_burst(ref_col_cmd_bursts_int);

			mrs_ctrl_cmd := mrs_cmd(mrs_bank_ctrl_bursts_int);
			mrs_ctrl_data := mrs_data(mrs_bank_ctrl_bursts_int);

			bank_ctrl_delay_int := ctrl_delay(mrs_bank_ctrl_bursts_int);
			col_cmd_delay_int := cmd_delay(ref_col_cmd_bursts_int);
			mrs_cmd_delay_int := cmd_delay(mrs_bank_ctrl_bursts_int);
			ref_delay_int := ref_delay(ref_col_cmd_bursts_int);

			ctrl_delay_cnt := 0;
			col_cmd_delay_cnt := 0;
			ref_delay_cnt := 0;

			mrs_bank_ctrl_req := false;
			col_cmd_req := false;
			ref_ctrl_req := false;
			self_ref := false;

			end_col_cmd := false;
			ref_done := false;

			mrs_bank_ctrl_handshake := reset_bool_arr(false, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));

			mrs_bank_ctrl_err_arr := reset_int_arr(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));
			col_ctrl_err_arr := reset_int_arr(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));
			ref_ctrl_err_arr := reset_int_arr(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));

			bank_ctrl_bank_rtl := reset_int_arr(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));
			bank_ctrl_bank_exp := reset_int_arr(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));
			col_ctrl_bank_rtl := reset_int_arr(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));
			col_ctrl_bank_exp := reset_int_arr(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));
			row_rtl := reset_int_arr(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));
			row_exp := reset_int_arr(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));
			mrs_bank_cmd_rtl := reset_int_arr(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));
			mrs_bank_cmd_exp := reset_int_arr(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));
			mrs_rtl := reset_int_arr(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));
			mrs_exp := reset_int_arr(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));

			col_rtl := reset_int_arr_2d(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB), integer(2.0**(real(BURST_LENGTH_L_TB))));
			col_exp := reset_int_arr_2d(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB), integer(2.0**(real(BURST_LENGTH_L_TB))));
			col_cmd_rtl := reset_int_arr_2d(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB), integer(2.0**(real(BURST_LENGTH_L_TB))));
			col_cmd_exp := reset_int_arr_2d(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB), integer(2.0**(real(BURST_LENGTH_L_TB))));
			col_ctrl_bank_rtl := reset_int_arr_2d(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB), integer(2.0**(real(BURST_LENGTH_L_TB))));
			col_ctrl_bank_exp := reset_int_arr_2d(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB), integer(2.0**(real(BURST_LENGTH_L_TB))));

			mrs_bank_ctrl_err_int := 0;
			col_cmd_err_int := 0;
			ref_ctrl_err_int := 0;

			bl_cnt := 0;

			rtl_ref_cmd_cnt := 0;

			mrs_bank_cmd_cnt := 0;
			col_cmd_cnt := 0;
			ref_cmd_cnt := 0;

			exp_self_ref_exit := false;
			col_cmd_bl_cnt := 0;
			cmd_sent_in_self_ref := 0;

			ctrl_top: loop

				wait until ((clk_tb = '1') and (clk_tb'event));

				exit ctrl_loop when ((mrs_bank_ctrl_bursts_int = num_bursts_exp) and (ref_col_cmd_burst_int = num_bursts_exp) and (col_cmd_cnt = num_bursts_exp) and (mrs_bank_cmd_cnt = num_bursts_exp) and (ref_req = ref_cmd_cnt));

				if (mrs_bank_ctrl_handshake(mrs_bank_ctrl_bursts_int) = true) then
					mrs_bank_ctrl_bursts_int := mrs_bank_ctrl_bursts_int + 1;
				end if;

				if (mrs_bank_ctrl_bursts_int < num_bursts_exp) then

					rw_burst_bank := rw_burst(mrs_bank_ctrl_bursts_int);
					mrs_ctrl_en := mrs(mrs_bank_ctrl_bursts_int);

					bank_ctrl_bank := bank(mrs_bank_ctrl_bursts_int);
					bank_ctrl_row := rows(mrs_bank_ctrl_bursts_int);

					mrs_ctrl_cmd := mrs_cmd(mrs_bank_ctrl_bursts_int);
					mrs_ctrl_data := mrs_data(mrs_bank_ctrl_bursts_int);

					bank_ctrl_delay_int := ctrl_delay(mrs_bank_ctrl_bursts_int);
					mrs_cmd_delay_int := cmd_delay(mrs_bank_ctrl_bursts_int);

					if (stop_mrs_bank = true) then
						if ((RefreshReq_tb = '0') and (NonReadOpEnable = '1')) then -- Enable MRS/Bank ctrl after Refresh
							stop_mrs_bank := false;
						end if;
					else
						if (rw_burst_bank = true) then

							MRSCtrlCtrlReq_tb <= '0';
							MRSCtrlCtrlCmd_tb <= (others => '0');
							MRSCtrlCtrlData_tb <= (others => '0');

							if (mrs_bank_ctrl_req = false) then

								if (ctrl_delay_cnt = bank_ctrl_delay_int) then 
									-- Transaction Controller
									for i in 0 to (BANK_NUM_TB - 1) loop
										if (i = bank_ctrl_bank_int) then
											BankCtrlRowMemIn_tb(((i+1)*ROW_L_TB - 1) downto i*ROW_L_TB) <= std_logic_vector(to_unsigned(bank_ctrl_row, ROW_L_TB));
										else
											BankCtrlRowMemIn_tb(((i+1)*ROW_L_TB - 1) downto i*ROW_L_TB) <= (others => '0');
										end if;
									end loop;
									BankCtrlCtrlReq_tb <= std_logic_vector(to_unsigned(integer(2.0**(real(bank_ctrl_bank))), BANK_NUM_TB));
									ctrl_delay_cnt := 0;
									mrs_bank_ctrl_req := true;

									wait for 1 ps;
								else
									-- Transaction Controller
									BankCtrlRowMemIn_tb <= (others => '0');
									BankCtrlCtrlReq_tb <= (others => '0');
									ctrl_delay_cnt := ctrl_delay_cnt + 1;
								end if;

							end if;

							if (mrs_bank_ctrl_req = true) then

								if (BankCtrlCtrlAck_tb(bank_ctrl_bank) = '1') then
									if (BankCtrlCtrlReq_tb(bank_ctrl_bank) = '1') then
										BankCtrlCtrlReq_tb <= (others => '0');
										mrs_bank_ctrl_handshake(mrs_bank_ctrl_bursts_int) := true;
										mrs_bank_ctrl_req := false;
										mrs_bank_ctrl_err_arr(mrs_bank_ctrl_bursts_int) := mrs_bank_ctrl_err_int;
										mrs_bank_ctrl_err_int := 0;

										bank_ctrl_bank_exp(mrs_bank_ctrl_bursts_int) := bank_ctrl_bank;
										row_exp(mrs_bank_ctrl_bursts_int) := bank_ctrl_row;
										mrs_exp(mrs_bank_ctrl_bursts_int) := 0;
										mrs_bank_cmd_exp(mrs_bank_ctrl_burst_int) := to_integer(unsigned(CMD_BANK_ACT));
										if (RefreshReq_tb = '1') then
											stop_mrs_bank := true;
										end if;
									else
										mrs_bank_ctrl_err_int := mrs_bank_ctrl_err_int + 1;
									end if; 
								else
									if ((BankCtrlCtrlAck_tb /= ZERO_BANK_VEC) and (BankCtrlCtrlReq_tb = ZERO_BANK_VEC)) then
										mrs_bank_ctrl_err_int := mrs_bank_ctrl_err_int + 1;
									end if;
								end if;

							end if;

						elsif (mrs_ctrl_en = true) then

							BankCtrlCtrlReq_tb <= (others => '0');
							BankCtrlRowMemIn_tb <= (others => '0');

							if (mrs_bank_ctrl_req = false) then

								if (ctrl_delay_cnt = mrs_cmd_delay_int) then
									-- MRS Controller
									MRSCtrlCtrlReq_tb <= '1';
									MRSCtrlCtrlCmd_tb <= std_logic_vector(to_unsigned(mrs_ctrl_cmd, MEM_CMD_L));
									MRSCtrlCtrlData_tb <= std_logic_vector(to_unsigned(mrs_ctrl_data, ADDR_MEM_L_TB));

									ctrl_delay_cnt := 0;
									mrs_bank_ctrl_req := true;

									wait for 1 ps;
								else
									-- MRS Controller
									MRSCtrlCtrlReq_tb <= '0';
									MRSCtrlCtrlCmd_tb <= (others => '0');
									MRSCtrlCtrlData_tb <= (others => '0');

									ctrl_delay_cnt := ctrl_delay_cnt + 1;
								end if;

							end if;

							if (mrs_bank_ctrl_req = true) then

								if (MRSCtrlCtrlAck_tb = '1') then
									if (MRSCtrlCtrlReq_tb = '1') then

										MRSCtrlCtrlReq_tb <= '0';
										mrs_bank_ctrl_handshake(mrs_bank_ctrl_bursts_int) := true;
										mrs_bank_ctrl_req := false;
										mrs_bank_ctrl_err_arr(mrs_bank_ctrl_bursts_int) := mrs_bank_ctrl_err_int;
										mrs_bank_ctrl_err_int := 0;

										bank_ctrl_bank_exp(mrs_bank_ctrl_bursts_int) := 0;
										row_exp(mrs_bank_ctrl_bursts_int) := 0;
										mrs_exp(mrs_bank_ctrl_bursts_int) := mrs_data;
										mrs_bank_cmd_exp(mrs_bank_ctrl_burst_int) := mrs_cmd;
										if (RefreshReq_tb = '1') then
											stop_mrs_bank := true;
										end if;
									else
										mrs_bank_ctrl_err_int := mrs_bank_ctrl_err_int + 1;
									end if; 
								else
									if ((MRSCtrlCtrlAck_tb = '1') and (BankCtrlCtrlReq_tb = '0')) then
										mrs_bank_ctrl_err_int := mrs_bank_ctrl_err_int + 1;
									end if;
								end if;

							end if;

						else

							BankCtrlCtrlReq_tb <= (others => '0');
							BankCtrlRowMemIn_tb <= (others => '0');
							MRSCtrlCtrlReq_tb <= '0';
							MRSCtrlCtrlCmd_tb <= (others => '0');
							MRSCtrlCtrlData_tb <= (others => '0');

							if (ctrl_delay_cnt = bank_ctrl_delay_int) then 
								ctrl_delay_cnt := 0;
								mrs_bank_ctrl_handshake(mrs_bank_ctrl_bursts_int) := true;
							else
								ctrl_delay_cnt := ctrl_delay_cnt + 1;
							end if;

						end if;

					end if;

				end if;

				if ((ref_col_cmd_bursts_int < mrs_bank_ctrl_bursts_int) and (ref_col_cmd_bursts_int < num_bursts_exp)) then

					rw_burst_col := rw_burst(ref_col_cmd_bursts_int);
					ref_ctrl_en := ref(ref_col_cmd_bursts_int);
					ref_ctrl_auto_ref := auto_ref(ref_col_cmd_bursts_int);

					col_ctrl_bank := bank(ref_col_cmd_bursts_int);
					col_ctrl_col := cols(ref_col_cmd_bursts_int);
					col_ctrl_bl := bl(ref_col_cmd_bursts_int);
					col_ctrl_read_burst := read_burst(ref_col_cmd_bursts_int);

					col_cmd_delay_int := cmd_delay(ref_col_cmd_bursts_int);
					ref_delay_int := ref_delay(ref_col_cmd_bursts_int);

					if (rw_burst_col = true) then
						if (end_col_cmd = false) then
							if (col_cmd_req = false) then
								if (col_cmd_delay_cnt = col_cmd_delay_int) then
									-- Transaction Controller
									ColCtrlBurstLength_tb <= std_logic_vector(to_unsigned(col_ctrl_bl-1, BURST_LENGTH_L_TB));
									ColCtrlBankMemIn_tb <= std_logic_vector(to_unsigned(col_ctrl_bank, int_to_bit_num(BANK_NUM_TB)));
									ColCtrlColMemIn_tb <= std_logic_vector(to_unsigned(col_ctrl_col, COL_L_TB));
									ColCtrlReadBurstIn_tb(0) <= bool_to_std_logic(col_ctrl_read_burst);
									ColCtrlCtrlReq_tb(0) <= '1';

									col_cmd_delay_cnt := 0;
									col_cmd_req := true;

									wait for 1 ps;
								else

									ColCtrlCtrlReq_tb <= (others => '0');
									col_cmd_delay_cnt := col_cmd_delay_cnt + 1;
								end if;
							end if;

							if (col_cmd_req = true) then
								if (ColCtrlCtrlAck_tb(0) = '1') then
									if (ColCtrlCtrlReq_tb(0) = '1') then
										ColCtrlCtrlReq_tb <= (others => '0');
										col_ctrl_err_arr(ref_col_cmd_bursts_int) := col_cmd_err_int;
										col_cmd_err_int := 0;

										col_cmd_req := false;
										end_col_cmd := true;

										for bl_cnt in 0 to (col_ctrl_bl - 1) loop
											col_ctrl_bank_exp(ref_col_cmd_bursts_int, bl_cnt) := col_ctrl_bank;
											col_exp(ref_col_cmd_bursts_int, bl_cnt) := col_ctrl_col + (bl_cnt * integer(2.0**real(burst_bits)));
											if (col_ctrl_read_burst = true) then
												if (bl_cnt = (col_ctrl_bl - 1)) then
													col_cmd_exp(ref_col_cmd_bursts_int, bl_cnt) := to_integer(unsigned(CMD_READ_PRECHARGE));
												else
													col_cmd_exp(ref_col_cmd_bursts_int, bl_cnt) := to_integer(unsigned(CMD_READ));
												end if;
											else
												if (bl_cnt = (col_ctrl_bl - 1)) then
													col_cmd_exp(ref_col_cmd_bursts_int, bl_cnt) := to_integer(unsigned(CMD_WRITE_PRECHARGE));
												else
													col_cmd_exp(ref_col_cmd_bursts_int, bl_cnt) := to_integer(unsigned(CMD_WRITE));
												end if;
											end if;
										end loop;
									else
										col_cmd_err_int := col_cmd_err_int + 1;
									end if; 
								end if;

							end if;
						end if;
					else
						end_col_cmd := true;
					end if;

					if (ref_ctrl_en = true) then
						if (ref_done = false) then
							if (ref_ctrl_auto_ref = true) then -- Auto refresh command: Wait RefreshReq to be set and wait a delay before moving on
								if (ref_ctrl_req = false) then
									if (RefreshReq_tb = '1') then
										ref_ctrl_req := true;
									end if;
								else
									if (ref_delay_cnt = ref_delay_int) then
										ref_done := true;
										ref_ctrl_req := false;

										ref_ctrl_err_arr(rtl_ref_cmd_cnt) := ref_cmd_err_int;
										ref_cmd_err_int := 0;

										ref_cmd_exp(rtl_ref_cmd_cnt, 0) := to_integer(unsigned(CMD_AUTO_REF));
										ref_cmd_exp(rtl_ref_cmd_cnt, 1) := to_integer(unsigned(CMD_NOP));
										rtl_ref_cmd_cnt := rtl_ref_cmd_cnt + 1;
										ref_delay_cnt := 0;
									else
										ref_delay_cnt := ref_delay_cnt + 1;
									end if;
								end if;
							else
								if (ref_ctrl_req = false) then
									if (ref_delay_cnt = ref_delay_int) then
										RefCtrlCtrlReq_tb <= '1';

										ref_delay_cnt := 0;
										ref_cmd_req := true;

										wait for 1 ps;
									else

										RefCtrlCtrlReq_tb <= '0';
										ref_delay_cnt := ref_delay_cnt + 1;
									end if;
								end if;

								if (ref_ctrl_req = true) then
									if (RefCtrlCtrlAck_tb = '1') then
										if (RefCtrlCtrlReq_tb = '1') then
											RefCtrlCtrlReq_tb <= '0';
											ref_ctrl_err_arr(rtl_ref_cmd_cnt) := ref_cmd_err_int;
											ref_cmd_err_int := 0;

											ref_ctrl_req := false;

											if (self_ref = false) then
												ref_cmd_exp(rtl_ref_cmd_cnt, 0) := to_integer(unsigned(CMD_SELF_REF_ENTRY));
												self_ref := true;
											else
												ref_cmd_exp(rtl_ref_cmd_cnt, 1) := to_integer(unsigned(CMD_SELF_REF_EXIT));
												rtl_ref_cmd_cnt := rtl_ref_cmd_cnt + 1;
												self_ref := false;
												ref_done := true;
											end if;
										else
											ref_cmd_err_int := ref_cmd_err_int + 1;
										end if;
									end if;
								end if;
							end if;
						end if;
					else
						ref_done := true;
					end if;

					if ((end_col_cmd = true) and (ref_done = true)) then
						end_col_cmd := false;
						ref_done := false;
						ref_col_cmd_bursts_int := ref_col_cmd_bursts_int + 1;
					end if;

				end if;

				if (exp_self_ref_exit = true) then

					if ((CmdDecCmdMem_tb = CMD_SELF_REF_ENTRY) or (CmdDecCmdMem_tb = CMD_SELF_REF_EXIT) or (CmdDecCmdMem_tb = CMD_AUTO_REF)) then
						ref_cmd_rtl(ref_cmd_cnt, 1) := to_integer(unsigned(CmdDecCmdMem_tb));
						cmd_sent_in_self_ref_err(ref_cmd_cnt) := cmd_sent_in_self_ref;
						cmd_sent_in_self_ref := 0;
						ref_cmd_cnt := ref_cmd_cnt + 1;
						exp_self_ref_exit := false;
					elsif ((CmdDecCmdMem_tb /= CMD_NOP) or (CmdDecCmdMem_tb /= CMD_DESEL)) then
						cmd_sent_in_self_ref := cmd_sent_in_self_ref + 1;
					end if;

				else

					if (CmdDecCmdMem_tb = CMD_SELF_REF_ENTRY) then
						ref_cmd_rtl(ref_cmd_cnt, 0) := to_integer(unsigned(CmdDecCmdMem_tb));
						exp_self_ref_exit := true;
						cmd_sent_in_self_ref := 0;
					elsif (CmdDecCmdMem_tb = CMD_AUTO_REF) then
						ref_cmd_rtl(ref_cmd_cnt, 0) := to_integer(unsigned(CmdDecCmdMem_tb));
						ref_cmd_rtl(ref_cmd_cnt, 1) := to_integer(unsigned(CMD_NOP));
						exp_self_ref_exit := false;
						cmd_sent_in_self_ref := 0;
						cmd_sent_in_self_ref_err(ref_cmd_cnt) := cmd_sent_in_self_ref;
						ref_cmd_cnt := ref_cmd_cnt + 1;
					elsif ((CmdDecCmdMem_tb = CMD_READ_PRECHARGE) or (CmdDecCmdMem_tb = CMD_WRITE_PRECHARGE)) then
						col_cmd_rtl(col_cmd_cnt, col_cmd_bl_cnt) := to_integer(unsigned(CmdDecCmdMem_tb));
						col_ctrl_bank_rtl(col_cmd_cnt, col_cmd_bl_cnt) := to_integer(unsigned(CmdDecBankMem_tb));
						col_rtl(col_cmd_cnt, col_cmd_bl_cnt) := to_integer(unsigned(CmdDecColMem_tb));
						col_cmd_cnt := col_cmd_cnt + 1;
						col_cmd_bl_cnt := 0;
					elsif ((CmdDecCmdMem_tb = CMD_READ) or (CmdDecCmdMem_tb = CMD_WRITE)) then
						col_cmd_rtl(col_cmd_cnt, col_cmd_bl_cnt) := to_integer(unsigned(CmdDecCmdMem_tb));
						col_ctrl_bank_rtl(col_cmd_cnt, col_cmd_bl_cnt) := to_integer(unsigned(CmdDecBankMem_tb));
						col_rtl(col_cmd_cnt, col_cmd_bl_cnt) := to_integer(unsigned(CmdDecColMem_tb));
						col_cmd_bl_cnt := col_cmd_bl_cnt + 1;
					elsif (CmdDecCmdMem_tb = CMD_BANK_ACT) then
						bank_ctrl_bank_rtl(mrs_bank_cmd_cnt) := to_integer(unsigned(CmdDecBankMem_tb));
						row_rtl(mrs_bank_cmd_cnt) := to_integer(unsigned(CmdDecRowMem_tb));
						mrs_rtl(mrs_bank_cmd_cnt) := 0;
						mrs_bank_cmd_rtl(mrs_bank_cmd_cnt) := to_integer(unsigned(CmdDecCmdMem_tb));
						mrs_bank_cmd_cnt := mrs_bank_cmd_cnt + 1;
					elsif ((CmdDecCmdMem_tb = CMD_MODE_REG_SET) or (CmdDecCmdMem_tb = CMD_EXT_MODE_REG_SET_1) or (CmdDecCmdMem_tb = CMD_EXT_MODE_REG_SET_2) or (CmdDecCmdMem_tb = CMD_EXT_MODE_REG_SET_3)) then
						bank_ctrl_bank_rtl(mrs_bank_cmd_cnt) := 0;
						row_rtl(mrs_bank_cmd_cnt) := 0;
						mrs_rtl(mrs_bank_cmd_cnt) := to_integer(unsigned(CmdDecMRSCmd_tb));
						mrs_bank_cmd_rtl(mrs_bank_cmd_cnt) := to_integer(unsigned(CmdDecCmdMem_tb));
						mrs_bank_cmd_cnt := mrs_bank_cmd_cnt + 1;
					end if;

				end if;

			end loop;

			num_bursts_rtl := mrs_bank_ctrl_bursts_int;

		end procedure run_ctrl_top;

		procedure verify(variable num_bursts_rtl, num_bursts_exp, ref_req : in integer; variable bank, cols, rows, mrs_data : in int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable read_burst : in bool_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable bl : in int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable rw_burst, ref, auto_ref, mrs : in bool_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable mrs_cmd : in int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable mrs_bank_ctrl_err_arr, col_ctrl_err_arr, ref_ctrl_err_arr, bank_ctrl_bank_rtl, bank_ctrl_bank_exp, row_rtl, row_exp, mrs_bank_cmd_rtl, mrs_bank_cmd_exp, mrs_rtl, mrs_exp, cmd_sent_in_self_ref_err : out int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable ref_cmd_rtl, ref_cmd_exp : out int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1), 0 to 1); variable col_rtl, col_exp, col_cmd_rtl, col_cmd_exp, col_ctrl_bank_rtl, col_ctrl_bank_exp : out int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1), 0 to (integer(2.0**(real(BURST_LENGTH_L_TB)) - 1.0))); file file_pointer : text; variable pass: out integer) is

			variable match_mrs		: boolean;
			variable match_cols		: boolean;
			variable match_rows		: boolean;
			variable match_col_cmd		: boolean;
			variable match_mrs_bank_cmd	: boolean;
			variable match_col_ctrl_bank	: boolean;
			variable match_bank_ctrl_bank	: boolean;
			variable match_ref_cmd		: boolean;

			variable no_mrs_bank_ctrl_err		: boolean;
			variable no_col_ctrl_err		: boolean;
			variable no_ref_ctrl_err		: boolean;
			variable no_cmd_sent_in_self_ref	: boolean;

			variable file_line	: line;

		begin

			match_cols := compare_int_arr_2d(col_exp, col_rtl, num_bursts_exp, integer(2.0**(real(BURST_LENGTH_L_TB))));
			match_mrs := compare_int_arr(mrs_exp, mrs_rtl, num_bursts_exp);
			match_row := compare_int_arr(row_exp, row_rtl, num_bursts_exp);
			match_col_cmd := compare_int_arr_2d(col_cmd_exp, col_cmd_rtl, num_bursts_exp, integer(2.0**(real(BURST_LENGTH_L_TB))));
			match_mrs_bank_cmd := compare_int_arr(mrs_bank_cmd_exp, mrs_bank_cmd_rtl, num_bursts_exp, integer(2.0**(real(BURST_LENGTH_L_TB))));
			match_col_ctrl_bank := compare_int_arr_2d(col_ctrl_bank_exp, col_ctrl_bank_rtl, num_bursts_exp, integer(2.0**(real(BURST_LENGTH_L_TB))));
			match_bank_ctrl_bank := compare_int_arr(bank_ctrl_bank_exp, bank_ctrl_bank_rtl, num_bursts_exp);
			match_ref_cmd := compare_int_arr_2d(ref_cmd_exp, ref_cmd_rtl, ref_req, 2);

			no_mrs_bank_ctrl_err := compare_int_arr(reset_int_arr(0, num_bursts_exp), mrs_bank_ctrl_err_arr, num_bursts_exp);
			no_col_ctrl_err := compare_int_arr(reset_int_arr(0, num_bursts_exp), col_ctrl_err_arr, num_bursts_exp);
			no_ref_ctrl_err := compare_int_arr(reset_int_arr(0, ref_req), ref_ctrl_err_arr, ref_req);
			no_cmd_sent_in_self_ref := compare_int_arr(reset_int_arr(0, ref_req), cmd_sent_in_self_ref_err, ref_req);

			for i in 0 to (num_bursts_exp - 1) loop

				if ((rw_burst(i) = true) and (ref(i) = true)) then
					write(file_line, string'( "PHY Controller Top Level: Burst #" & integer'image(i) & " Bank " & integer'image(bank(i)) & " Start Column " & integer'image(cols(i)) & " Row " & integer'image(rows(i)) & " Burst Length " & integer'image(bl(i)) & " Refresh : Auto-Refresh " & bool_to_std_bool(auto_ref(i))));
				elsif ((rw_burst(i) = true) and (ref(i) = false)) then
					write(file_line, string'( "PHY Controller Top Level: Burst #" & integer'image(i) & " Bank " & integer'image(bank(i)) & " Start Column " & integer'image(cols(i)) & " Row " & integer'image(rows(i)) & " Burst Length " & integer'image(bl(i)) & " Refresh : False"));
				elsif ((mrs(i) = true) and (ref(i) = true)) then
					write(file_line, string'( "PHY Controller Top Level: Burst #" & integer'image(i) & " MRS Command " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(mrs(i)))) & " MRS Data " & integer'image(mrs_data(i)) & " Refresh : Auto-Refresh " & bool_to_std_bool(auto_ref(i))));
				elsif ((mrs(i) = true) and (ref(i) = false)) then
					write(file_line, string'( "PHY Controller Top Level: Burst #" & integer'image(i) & " MRS Command " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(mrs(i)))) & " MRS Data " & integer'image(mrs_data(i)) & " Refresh : False"));
				elsif (ref(i) = true) then
					write(file_line, string'( "PHY Controller Top Level: Burst #" & integer'image(i) & " Refresh : Auto-Refresh " & bool_to_std_bool(auto_ref(i))));
				else
					write(file_line, string'( "PHY Controller Top Level: Burst #" & integer'image(i) & " No Command "));
				end if;

				writeline(file_pointer, file_line);

			end loop;

			if ((num_bursts_rtl = num_bursts_exp) and (match_cols = true) and (match_mrs = true) and (match_row = true) and (match_col_cmd = true) and (match_mrs_bank_cmd = true) and (match_col_ctrl_bank = true) and (match_bank_ctrl_bank = true) and (match_ref_cmd = true) and (no_mrs_bank_ctrl_err = true) and (no_col_ctrl_err = true) and (no_ref_ctrl_err = true) and (no_cmd_sent_in_self_ref = true)) then
				write(file_line, string'( "PHY Controller Top Level: PASS"));
				writeline(file_pointer, file_line);
				pass := 1;
			elsif (num_bursts_rtl /= num_bursts_exp) then
				write(file_line, string'( "PHY Controller Top Level: FAIL (Number bursts mismatch): exp " & integer'image(num_bursts_exp) & " vs rtl " & integer'image(num_bursts_rtl)));
				writeline(file_pointer, file_line);
				pass := 0;
			elsif (match_mrs_bank_cmd = false) then
				write(file_line, string'( "PHY Controller Top Level: FAIL (MRS/Bank Command mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_bursts_exp - 1) loop
					write(file_line, string'( "PHY Controller Top Level: Burst #" & integer'image(i) & " details: Cmd exp " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(mrs_bank_cmd_exp(i)))) & " vs rtl " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(mrs_bank_cmd_rtl(i))))));
					writeline(file_pointer, file_line);
				end loop;
			elsif (match_bank_ctrl_bank = false) then
				write(file_line, string'( "PHY Controller Top Level: FAIL (Bank Controller Bank mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_bursts_exp - 1) loop
					write(file_line, string'( "PHY Column Controller: Burst #" & integer'image(i) & " Bank exp " & integer'image(bank_ctrl_bank_exp(i)) & " vs rtl " & integer'image(bank_ctrl_bank_rtl(i))));
					writeline(file_pointer, file_line);
				end loop;
			elsif (match_ref_cmd = false) then
				write(file_line, string'( "PHY Controller Top Level: FAIL (Refresh Command mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_bursts_exp - 1) loop
					for j in 0 to 1 loop
						write(file_line, string'( "PHY Controller Top Level: Burst #" & integer'image(i) & " details: Cmd exp " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(ref_cmd_exp(i, j)))) & " vs rtl " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(ref_cmd_rtl(i, j))))));
						writeline(file_pointer, file_line);
					end loop;
				end loop;
			elsif (match_col_cmd = false) then
				write(file_line, string'( "PHY Controller Top Level: FAIL (Column Command mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_bursts_exp - 1) loop
					write(file_line, string'( "========================================================================================"));
					writeline(file_pointer, file_line);
					write(file_line, string'( "PHY Controller Top Level: Burst #" & integer'image(i) & " details: Col " & integer'image(col_exp(i, 0)) & " Read Burst " & bool_to_std_logic(read_burst(i)) & " Burst Length " & integer'image(bl(i))));
					writeline(file_pointer, file_line);
					for j in 0 to (bl(i) - 1) loop
						if (col_cmd_rtl(i,j) /= col_cmd_exp(i,j)) then
							write(file_line, string'( "PHY Column Controller: Burst #" & integer'image(i) & " Cmd #" & integer'image(j) & " Column Command exp " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(col_cmd_exp(i, j), MEM_CMD_L))) & " vs rtl " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(col_cmd_rtl(i, j))))));
							writeline(file_pointer, file_line);
						end if;
					end loop;
				end loop;
				write(file_line, string'( "========================================================================================"));
				writeline(file_pointer, file_line);
				pass := 0;
			elsif (match_col_ctrl_bank = false) then
				write(file_line, string'( "PHY Controller Top Level: FAIL (Column Command Bank mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_bursts_exp - 1) loop
					write(file_line, string'( "========================================================================================"));
					writeline(file_pointer, file_line);
					write(file_line, string'( "PHY Controller Top Level: Burst #" & integer'image(i) & " details: Bank " & integer'image(col_ctrl_bank_exp(i, 0))));
					writeline(file_pointer, file_line);
					for j in 0 to (bl(i) - 1) loop
						if (col_ctrl_bank_rtl(i,j) /= col_ctrl_bank_exp(i,j)) then
							write(file_line, string'( "PHY Column Controller: Burst #" & integer'image(i) & " Cmd #" & integer'image(j) & " Column exp " & integer'image(col_ctrl_bank_exp(i, j)) & " vs rtl " & integer'image(col_ctrl_bank_rtl(i, j))));
							writeline(file_pointer, file_line);
						end if;
					end loop;
				end loop;
				write(file_line, string'( "========================================================================================"));
				writeline(file_pointer, file_line);
				pass := 0;
			elsif (match_cols = false) then
				write(file_line, string'( "PHY Controller Top Level: FAIL (Col mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_bursts_exp - 1) loop
					write(file_line, string'( "========================================================================================"));
					writeline(file_pointer, file_line);
					write(file_line, string'( "PHY Controller Top Level: Burst #" & integer'image(i) & " details: Start Col " & integer'image(col_exp(i, 0)) & " Burst Length " & integer'image(bl(i))));
					writeline(file_pointer, file_line);
					for j in 0 to (bl(i) - 1) loop
						if (col_rtl(i,j) /= col_exp(i,j)) then
							write(file_line, string'( "PHY Column Controller: Burst #" & integer'image(i) & " Cmd #" & integer'image(j) & " Column exp " & integer'image(col_exp(i, j)) & " vs rtl " & integer'image(col_rtl(i, j))));
							writeline(file_pointer, file_line);
						end if;
					end loop;
				end loop;
				write(file_line, string'( "========================================================================================"));
				writeline(file_pointer, file_line);
				pass := 0;
			elsif (match_rows = false) then
				write(file_line, string'( "PHY Controller Top Level: FAIL (Row mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_bursts_exp - 1) loop
					write(file_line, string'( "PHY Controller Top Level: Burst #" & integer'image(i) & " details: Row exp " & integer'image(row_exp(i)) & " vs rtl " & integer'image(row_rtl(i))));
					writeline(file_pointer, file_line);
				end loop;
			elsif (match_mrs = false) then
				write(file_line, string'( "PHY Controller Top Level: FAIL (MRS Data mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_bursts_exp - 1) loop
					write(file_line, string'( "PHY Controller Top Level: Burst #" & integer'image(i) & " details: MRS data exp " & integer'image(mrs_exp(i)) & " vs rtl " & integer'image(mrs_rtl(i))));
					writeline(file_pointer, file_line);
				end loop;
			elsif (no_mrs_bank_ctrl_err = false) then
				write(file_line, string'( "PHY Controller Top Level: FAIL (MRS/Bank Controller Handshake Error)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_bursts_exp - 1) loop
					write(file_line, string'( "PHY Controller Top Level: Error Burst #" & integer'image(i) & ": " & integer'image(mrs_bank_ctrl_err_arr(i)) & " Error(s)"));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (no_col_ctrl_err = false) then
				write(file_line, string'( "PHY Controller Top Level: FAIL (Column Controller Handshake Error)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_bursts_exp - 1) loop
					write(file_line, string'( "PHY Controller Top Level: Error Burst #" & integer'image(i) & ": " & integer'image(col_ctrl_err_arr(i)) & " Error(s)"));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (no_ref_ctrl_err = false) then
				write(file_line, string'( "PHY Controller Top Level: FAIL (Refresh Controller Handshake Error)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_bursts_exp - 1) loop
					write(file_line, string'( "PHY Controller Top Level: Error Burst #" & integer'image(i) & ": " & integer'image(ref_ctrl_err_arr(i)) & " Error(s)"));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (no_cmd_sent_in_self_ref = false) then
				write(file_line, string'( "PHY Controller Top Level: FAIL (Commands detected during Self Refresh)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_bursts_exp - 1) loop
					write(file_line, string'( "PHY Controller Top Level: Error Burst #" & integer'image(i) & ": " & integer'image(cmd_sent_in_self_ref_err(i)) & " Error(s)"));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			else
				write(file_line, string'( "PHY Controller Top Level: FAIL (Unknown Command)"));
				writeline(file_pointer, file_line);
			end if;
		end procedure verify;

		variable seed1, seed2	: positive;

		variable num_bursts_exp	: integer;
		variable num_bursts_rtl	: integer;

		variable ref_req	: integer;
		variable burst_bits	: integer;
		variable al		: integer;
		variable wl		: integer;
		variable cas		: integer;

		variable high_temp	: boolean;

		variable bank		: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable cols		: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable rows		: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable mrs_data	: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));

		variable read_burst	: bool_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));

		variable bl		: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable cmd_delay	: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable ctrl_delay	: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));

		variable rw_burst	: bool_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable ref		: bool_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable auto_ref	: bool_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable mrs		: bool_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));

		variable ref_delay	: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable mrs_cmd	: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));

		variable mrs_bank_ctrl_err_arr		: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable col_ctrl_err_arr		: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable ref_ctrl_err_arr		: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable bank_ctrl_bank_rtl		: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable bank_ctrl_bank_exp		: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable row_rtl			: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable row_exp			: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable mrs_bank_cmd_rtl		: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable mrs_bank_cmd_exp		: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable mrs_rtl			: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable mrs_exp			: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable cmd_sent_in_self_ref_err	: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));

		variable ref_cmd_rtl			: int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1), 0 to 1);
		variable ref_cmd_exp			: int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1), 0 to 1);

		variable col_rtl			: int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1), 0 to (integer(2.0**(real(BURST_LENGTH_L_TB)) - 1.0)));
		variable col_exp			: int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1), 0 to (integer(2.0**(real(BURST_LENGTH_L_TB)) - 1.0)));
		variable col_cmd_rtl			: int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1), 0 to (integer(2.0**(real(BURST_LENGTH_L_TB)) - 1.0)));
		variable col_cmd_exp			: int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1), 0 to (integer(2.0**(real(BURST_LENGTH_L_TB)) - 1.0)));
		variable col_ctrl_bank_rtl		: int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1), 0 to (integer(2.0**(real(BURST_LENGTH_L_TB)) - 1.0)));
		variable col_ctrl_bank_exp		: int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1), 0 to (integer(2.0**(real(BURST_LENGTH_L_TB)) - 1.0)));

		variable pass	: integer;
		variable num_pass	: integer;

		file file_pointer	: text;
		variable file_line	: line;

	begin

		wait for 1 ns;

		num_pass := 0;

		reset;
		file_open(file_pointer, ddr2_phy_ctrl_top_log_file, append_mode);

		write(file_line, string'( "PHY Controller Top Level Test"));
		writeline(file_pointer, file_line);

		for i in 0 to NUM_TEST-1 loop

			test_param(num_bursts_exp, ref_req, burst_bits, al, wl, cas, high_temp, num_bursts_arr, bank, cols, rows, mrs_data, read_burst, bl, cmd_delay, ctrl_delay, rw_burst, ref, mrs, auto_ref, ref_delay, mrs_cmd, seed1, seed2);

			run_ctrl_top(num_bursts_exp, ref_req, burst_bits, al, wl, cas, high_temp, bank, cols, rows, mrs_data, read_burst, bl, cmd_delay, ctrl_delay, rw_burst, ref, auto_ref, mrs, ref_delay, mrs_cmd, num_bursts_rtl, mrs_bank_ctrl_err_arr, col_ctrl_err_arr, ref_ctrl_err_arr, bank_ctrl_bank_rtl, bank_ctrl_bank_exp, row_rtl, row_exp, mrs_bank_cmd_rtl, mrs_bank_cmd_exp, mrs_rtl, mrs_exp, cmd_sent_in_self_ref_err, ref_cmd_rtl, ref_cmd_exp, col_rtl, col_exp, col_cmd_rtl, col_cmd_exp, col_ctrl_bank_rtl, col_ctrl_bank_exp);

			verify(num_bursts_rtl, num_bursts_exp, ref_req, bank, cols, rows, mrs_data, read_burst, bl, rw_burst, ref, auto_ref, mrs, mrs_cmd, mrs_bank_ctrl_err_arr, col_ctrl_err_arr, ref_ctrl_err_arr, bank_ctrl_bank_rtl, bank_ctrl_bank_exp, row_rtl, row_exp, mrs_bank_cmd_rtl, mrs_bank_cmd_exp, mrs_rtl, mrs_exp, cmd_sent_in_self_ref_err, ref_cmd_rtl, ref_cmd_exp, col_rtl, col_exp, col_cmd_rtl, col_cmd_exp, col_ctrl_bank_rtl, col_ctrl_bank_exp, file_pointer, pass);

			num_pass := num_pass + pass;

			wait until ((clk_tb'event) and (clk_tb = '1'));
		end loop;

		file_close(file_pointer);

		file_open(file_pointer, summary_file, append_mode);
		write(file_line, string'( "PHY Controller Top Level => PASSES: " & integer'image(num_pass) & " out of " & integer'image(TOT_NUM_TESTS)));
		writeline(file_pointer, file_line);

		if (num_pass = TOT_NUM_TESTS) then
			write(file_line, string'( "PHY Controller Top Level: TEST PASSED"));
		else
			write(file_line, string'( "PHY Controller Top Level: TEST FAILED: " & integer'image(TOT_NUM_TESTS-num_pass) & " failures"));
		end if;
		writeline(file_pointer, file_line);

		file_close(file_pointer);
		stop <= true;

		wait;

	end process test;

end bench;
