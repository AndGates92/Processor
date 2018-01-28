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
library ddr2_ctrl_rtl_pkg;
use ddr2_ctrl_rtl_pkg.ddr2_mrs_max_pkg.all;
use ddr2_ctrl_rtl_pkg.ddr2_define_pkg.all;
use ddr2_ctrl_rtl_pkg.ddr2_ctrl_pkg.all;
use ddr2_ctrl_rtl_pkg.ddr2_ctrl_top_pkg.all;
library ddr2_ctrl_tb_pkg;
use ddr2_ctrl_tb_pkg.ddr2_pkg_tb.all;
use ddr2_ctrl_tb_pkg.ddr2_log_pkg.all;

entity ddr2_ctrl_top_tb is
end entity ddr2_ctrl_top_tb;

architecture bench of ddr2_ctrl_top_tb is

	constant CLK_PERIOD		: time := DDR2_CLK_PERIOD * 1 ns;
	constant NUM_TESTS		: integer := 1000;
	constant NUM_EXTRA_TESTS	: integer := 0;
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
	signal MRSCtrlMRSReq_tb			: std_logic;

	-- Refresh Controller
	-- Transaction Controller
	signal RefCtrlRefreshReq_tb		: std_logic;
	signal RefCtrlNonReadOpEnable_tb	: std_logic;
	signal RefCtrlReadOpEnable_tb		: std_logic;

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

	DUT: ddr2_ctrl_init_top generic map (
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
		MRSCtrlMRSReq => MRSCtrlMRSReq_tb,

		-- Refresh Controller
		-- Transaction Controller
		RefCtrlRefreshReq => RefCtrlRefreshReq_tb,
		RefCtrlNonReadOpEnable => RefCtrlNonReadOpEnable_tb,
		RefCtrlReadOpEnable => RefCtrlReadOpEnable_tb,

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
			-- Controller
			RefCtrlCtrlReq_tb <= '0';


			rst_tb <= '0';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_tb <= '1';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_tb <= '0';
		end procedure reset;

		procedure test_param(variable num_bursts, mrs_req, bank_req, col_req, ref_req : out integer; variable num_bursts_arr : out int_arr(0 to (BANK_NUM_TB - 1)); variable bank, cols, rows, mrs_data : out int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable read_burst : out bool_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable bl, cmd_delay, ctrl_delay : out int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable rw_burst, ref, mrs, auto_ref : out bool_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable ref_delay, mrs_cmd : out int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable seed1, seed2 : inout positive) is
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
			variable mrs_int		: boolean;
			variable bank_req_int		: integer;
			variable mrs_req_int		: integer;
			variable col_req_int		: integer;
			variable ref_req_int		: integer;
		begin
			num_bursts_int := 0;
			bank_req := 0;
			bank_req_int := 0;
			mrs_req := 0;
			mrs_req_int := 0;
			col_req := 0;
			col_req_int := 0;
			ref_req := 0;
			ref_req_int := 0;
			mrs_int := false;
			ref_int := false;
			num_bursts_arr_int := reset_int_arr(0, BANK_NUM_TB);
			uniform(seed1, seed2, rand_val);
			num_bursts_int := integer(rand_val*real(BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));
			num_bursts := num_bursts_int;

			for i in 0 to (num_bursts_int - 1) loop
				uniform(seed1, seed2, rand_val);
				rw_burst_int := rand_bool(rand_val, 0.5);
				rw_burst(i) := rw_burst_int;

				uniform(seed1, seed2, rand_val);
				ref_int := rand_bool(rand_val, 0.25);
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

					burst_bits_int := to_integer(unsigned(CmdDecMRSCmd_tb(int_to_bit_num(BURST_LENGTH_MAX_VALUE) - 1 downto 0)));

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
					bl(bank_req_int) := bl_int;

					uniform(seed1, seed2, rand_val);
					rows(i) := integer(rand_val*(2.0**(real(ROW_L_TB)) - 1.0));

					uniform(seed1, seed2, rand_val);
					read_burst(i) := rand_bool(rand_val, 0.5);

					bank_req_int := bank_req_int + 1;
					col_req_int := col_req_int + 1;

					mrs(i) := false;
					mrs_data(i) := 0;
					mrs_cmd(i) := to_integer(unsigned(CMD_NOP));

				else

					uniform(seed1, seed2, rand_val);
					mrs_int := rand_bool(rand_val, 0.5);
					mrs(i) := mrs_int;
					if (mrs_int = true) then
						mrs_req_int := mrs_req_int + 1;
					end if;

					uniform(seed1, seed2, rand_val);
					mrs_data(i) := integer(rand_val*(2.0**(real(ADDR_MEM_L_TB)) - 1.0));

					uniform(seed1, seed2, rand_val);
					mrs_cmd_id := round(rand_val*real(REG_NUM_TB-1));
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

			bank_req := bank_req_int;
			mrs_req := mrs_req_int;
			col_req := col_req_int;
			ref_req := ref_req_int;
			num_bursts_arr := num_bursts_arr_int;

		end procedure test_param;

		procedure run_ctrl_top(variable num_bursts_exp : in integer; variable bank, cols, rows, mrs_data : in int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable read_burst : in bool_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable bl, cmd_delay, ctrl_delay : in int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable rw_burst, ref, auto_ref, mrs : in bool_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable ref_delay, mrs_cmd : in int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable num_bursts_rtl : out integer; variable mrs_ctrl_err_arr, bank_ctrl_err_arr, col_ctrl_err_arr, ref_ctrl_err_arr, mrs_ctrl_bank_rtl, mrs_ctrl_bank_exp, mrs_ctrl_row_rtl, mrs_ctrl_row_exp, mrs_ctrl_cmd_rtl, mrs_ctrl_cmd_exp, mrs_ctrl_mrs_rtl, mrs_ctrl_mrs_exp, cmd_sent_in_self_ref_err : out int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable bank_ctrl_row_rtl, bank_ctrl_row_exp, bank_ctrl_cmd_rtl, bank_ctrl_cmd_exp, bank_ctrl_mrs_rtl, bank_ctrl_mrs_exp : out int_arr_2d(0 to (BANK_NUM_TB - 1), 0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable ref_cmd_rtl, ref_cmd_exp : out int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1), 0 to 1); variable col_rtl, col_exp, col_cmd_rtl, col_cmd_exp, col_ctrl_bank_rtl, col_ctrl_bank_exp : out int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1), 0 to (integer(2.0**(real(BURST_LENGTH_L_TB)) - 1.0)))) is

			variable mrs_bank_ctrl_bursts_int	: integer;
			variable col_cmd_bursts_int		: integer;
			variable ref_cmd_bursts_int		: integer;

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

			variable stop_mrs_bank			: boolean;
			variable end_col_cmd			: boolean;
			variable ref_done_int			: boolean;
			variable ref_done			: boolean;

			variable mrs_bank_ctrl_handshake	: bool_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));

			variable bank_ctrl_cnt_rtl		: int_arr(0 to (BANK_NUM_TB - 1));
			variable bank_ctrl_cnt_exp		: int_arr(0 to (BANK_NUM_TB - 1));

			variable mrs_bank_ctrl_err_int		: integer;
			variable col_cmd_err_int		: integer;
			variable ref_cmd_err_int		: integer;

			variable bl_cnt				: integer;

			variable mrs_cmd_cnt_rtl		: integer;
			variable col_cmd_cnt_rtl		: integer;
			variable ref_cmd_cnt_rtl		: integer;

			variable mrs_cmd_cnt			: integer;
			variable bank_act_cnt			: integer;
			variable col_cmd_cnt			: integer;
			variable ref_cmd_cnt			: integer;

			variable mrs_cnt			: integer;
			variable ref_cnt			: integer;

			variable mrs_cnt_exp			: integer;
			variable col_cnt_exp			: integer;
			variable ref_cnt_exp			: integer;

			variable burst_bits			: integer;
			variable exp_self_ref_exit		: boolean;
			variable col_cmd_bl_cnt			: integer;
			variable cmd_sent_in_self_ref		: integer;

		begin

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
			-- Controller
			RefCtrlCtrlReq_tb <= '0';

			mrs_bank_ctrl_bursts_int := 0;
			col_cmd_bursts_int := 0;
			ref_cmd_bursts_int := 0;

			rw_burst_bank := rw_burst(mrs_bank_ctrl_bursts_int);
			rw_burst_col := rw_burst(col_cmd_bursts_int);

			ref_ctrl_en := ref(ref_cmd_bursts_int);
			ref_ctrl_auto_ref := auto_ref(ref_cmd_bursts_int);

			mrs_ctrl_en := mrs(mrs_bank_ctrl_bursts_int);

			bank_ctrl_bank := bank(mrs_bank_ctrl_bursts_int);
			bank_ctrl_row := rows(mrs_bank_ctrl_bursts_int);

			col_ctrl_bank := bank(col_cmd_bursts_int);
			col_ctrl_col := cols(col_cmd_bursts_int);
			col_ctrl_bl := bl(col_cmd_bursts_int);
			col_ctrl_read_burst := read_burst(col_cmd_bursts_int);

			mrs_ctrl_cmd := mrs_cmd(mrs_bank_ctrl_bursts_int);
			mrs_ctrl_data := mrs_data(mrs_bank_ctrl_bursts_int);

			bank_ctrl_delay_int := ctrl_delay(mrs_bank_ctrl_bursts_int);
			col_cmd_delay_int := cmd_delay(col_cmd_bursts_int);
			mrs_cmd_delay_int := cmd_delay(mrs_bank_ctrl_bursts_int);
			ref_delay_int := ref_delay(ref_cmd_bursts_int);

			ctrl_delay_cnt := 0;
			col_cmd_delay_cnt := 0;
			ref_delay_cnt := 0;

			mrs_bank_ctrl_req := false;
			col_cmd_req := false;
			ref_ctrl_req := false;
			self_ref := false;

			end_col_cmd := false;
			ref_done_int := false;
			ref_done := false;

			mrs_bank_ctrl_handshake := reset_bool_arr(false, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));

			bank_ctrl_cnt_exp := reset_int_arr(0, BANK_NUM_TB);
			bank_ctrl_cnt_rtl := reset_int_arr(0, BANK_NUM_TB);

			bank_ctrl_err_arr := reset_int_arr(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));
			mrs_ctrl_err_arr := reset_int_arr(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));
			col_ctrl_err_arr := reset_int_arr(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));
			ref_ctrl_err_arr := reset_int_arr(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));

			bank_ctrl_row_rtl := reset_int_arr_2d(0, BANK_NUM_TB, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));
			bank_ctrl_row_exp := reset_int_arr_2d(0, BANK_NUM_TB, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));
			bank_ctrl_cmd_rtl := reset_int_arr_2d(to_integer(unsigned(CMD_NOP)), BANK_NUM_TB, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));
			bank_ctrl_cmd_exp := reset_int_arr_2d(to_integer(unsigned(CMD_NOP)), BANK_NUM_TB, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));
			bank_ctrl_mrs_rtl := reset_int_arr_2d(0, BANK_NUM_TB, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));
			bank_ctrl_mrs_exp := reset_int_arr_2d(0, BANK_NUM_TB, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));

			mrs_ctrl_bank_rtl := reset_int_arr(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));
			mrs_ctrl_bank_exp := reset_int_arr(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));
			mrs_ctrl_row_rtl := reset_int_arr(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));
			mrs_ctrl_row_exp := reset_int_arr(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));
			mrs_ctrl_cmd_rtl := reset_int_arr(to_integer(unsigned(CMD_NOP)), (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));
			mrs_ctrl_cmd_exp := reset_int_arr(to_integer(unsigned(CMD_NOP)), (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));
			mrs_ctrl_mrs_rtl := reset_int_arr(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));
			mrs_ctrl_mrs_exp := reset_int_arr(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));

			col_rtl := reset_int_arr_2d(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB), integer(2.0**(real(BURST_LENGTH_L_TB))));
			col_exp := reset_int_arr_2d(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB), integer(2.0**(real(BURST_LENGTH_L_TB))));
			col_cmd_rtl := reset_int_arr_2d(to_integer(unsigned(CMD_NOP)), (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB), integer(2.0**(real(BURST_LENGTH_L_TB))));
			col_cmd_exp := reset_int_arr_2d(to_integer(unsigned(CMD_NOP)), (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB), integer(2.0**(real(BURST_LENGTH_L_TB))));
			col_ctrl_bank_rtl := reset_int_arr_2d(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB), integer(2.0**(real(BURST_LENGTH_L_TB))));
			col_ctrl_bank_exp := reset_int_arr_2d(0, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB), integer(2.0**(real(BURST_LENGTH_L_TB))));

			ref_cmd_rtl := reset_int_arr_2d(to_integer(unsigned(CMD_NOP)), (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB), 2);
			ref_cmd_exp := reset_int_arr_2d(to_integer(unsigned(CMD_NOP)), (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB), 2);

			mrs_bank_ctrl_err_int := 0;
			col_cmd_err_int := 0;
			ref_cmd_err_int := 0;

			bl_cnt := 0;

			mrs_cmd_cnt := 0;
			bank_act_cnt := 0;
			col_cmd_cnt := 0;
			ref_cmd_cnt := 0;

			mrs_cnt := 0;
			ref_cnt := 0;

			mrs_cnt_exp := 0;
			col_cnt_exp := 0;
			ref_cnt_exp := 0;

			exp_self_ref_exit := false;
			col_cmd_bl_cnt := 0;
			cmd_sent_in_self_ref := 0;

			ctrl_top_loop: loop

				wait until ((clk_tb = '1') and (clk_tb'event));

				exit ctrl_top_loop when ((mrs_bank_ctrl_bursts_int = num_bursts_exp) and (col_cmd_bursts_int = num_bursts_exp) and (ref_cmd_bursts_int = num_bursts_exp) and (col_cmd_cnt = bank_act_cnt) and (ref_cmd_cnt = ref_cnt) and (mrs_cmd_cnt = mrs_cnt));

				wait for 1 ps;

				if (CmdDecCmdMem_tb = CMD_MODE_REG_SET) then
					burst_bits := to_integer(unsigned(CmdDecMRSCmd_tb(int_to_bit_num(BURST_LENGTH_MAX_VALUE) - 1 downto 0)));
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

					if (stop_mrs_bank = false) then
						if (rw_burst_bank = true) then

							MRSCtrlCtrlReq_tb <= '0';
							MRSCtrlCtrlCmd_tb <= (others => '0');
							MRSCtrlCtrlData_tb <= (others => '0');

							if (mrs_bank_ctrl_req = false) then

								if (ctrl_delay_cnt = bank_ctrl_delay_int) then 
									-- Transaction Controller
									for i in 0 to (BANK_NUM_TB - 1) loop
										if (i = bank_ctrl_bank) then
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

									mrs_cnt := mrs_cnt + 1;

									wait for 1 ps;
								else
									-- MRS Controller
									MRSCtrlCtrlReq_tb <= '0';
									MRSCtrlCtrlCmd_tb <= (others => '0');
									MRSCtrlCtrlData_tb <= (others => '0');

									ctrl_delay_cnt := ctrl_delay_cnt + 1;
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

					if (mrs_bank_ctrl_req = true) then

						if (rw_burst_bank = true) then

							if (BankCtrlCtrlAck_tb(bank_ctrl_bank) = '1') then

								if (BankCtrlCtrlReq_tb(bank_ctrl_bank) = '1') then
									BankCtrlCtrlReq_tb <= (others => '0');
									mrs_bank_ctrl_handshake(mrs_bank_ctrl_bursts_int) := true;
									mrs_bank_ctrl_req := false;
									bank_ctrl_err_arr(bank_act_cnt) := mrs_bank_ctrl_err_int;
									mrs_bank_ctrl_err_int := 0;

									bank_ctrl_row_exp(bank_ctrl_bank, bank_ctrl_cnt_exp(bank_ctrl_bank)) := bank_ctrl_row;
									bank_ctrl_mrs_exp(bank_ctrl_bank, bank_ctrl_cnt_exp(bank_ctrl_bank)) := 0;
									bank_ctrl_cmd_exp(bank_ctrl_bank, bank_ctrl_cnt_exp(bank_ctrl_bank)) := to_integer(unsigned(CMD_BANK_ACT));

									bank_ctrl_cnt_exp(bank_ctrl_bank) := bank_ctrl_cnt_exp(bank_ctrl_bank) + 1;

									bank_act_cnt := bank_act_cnt + 1;

								else
									mrs_bank_ctrl_err_int := mrs_bank_ctrl_err_int + 1;
								end if; 
							else
								if ((BankCtrlCtrlAck_tb /= ZERO_BANK_VEC) and (BankCtrlCtrlReq_tb = ZERO_BANK_VEC)) then
									mrs_bank_ctrl_err_int := mrs_bank_ctrl_err_int + 1;
								end if;
							end if;

						elsif (mrs_ctrl_en = true) then

							if (MRSCtrlCtrlAck_tb = '1') then
								if (MRSCtrlCtrlReq_tb = '1') then

									MRSCtrlCtrlReq_tb <= '0';
									mrs_bank_ctrl_handshake(mrs_bank_ctrl_bursts_int) := true;
									mrs_bank_ctrl_req := false;
									mrs_ctrl_err_arr(mrs_cnt_exp) := mrs_bank_ctrl_err_int;
									mrs_bank_ctrl_err_int := 0;

									mrs_ctrl_bank_exp(mrs_cnt_exp) := 0;
									mrs_ctrl_row_exp(mrs_cnt_exp) := 0;
									mrs_ctrl_mrs_exp(mrs_cnt_exp) := mrs_ctrl_data;
									mrs_ctrl_cmd_exp(mrs_cnt_exp) := mrs_ctrl_cmd;

									mrs_cnt_exp := mrs_cnt_exp + 1;

									if (MRSCtrlMRSReq_tb = '1') then
										stop_mrs_bank := true;
									end if;
								else
									mrs_bank_ctrl_err_int := mrs_bank_ctrl_err_int + 1;
								end if; 
							else
								if ((MRSCtrlCtrlAck_tb = '1') and (MRSCtrlCtrlReq_tb = '0')) then
									mrs_bank_ctrl_err_int := mrs_bank_ctrl_err_int + 1;
								end if;
							end if;

						end if;

					end if;
				end if;


				if ((col_cmd_bursts_int < mrs_bank_ctrl_bursts_int) and (col_cmd_bursts_int < num_bursts_exp)) then

					rw_burst_col := rw_burst(col_cmd_bursts_int);

					col_ctrl_bank := bank(col_cmd_bursts_int);
					col_ctrl_col := cols(col_cmd_bursts_int);
					col_ctrl_bl := bl(col_cnt_exp);
					col_ctrl_read_burst := read_burst(col_cmd_bursts_int);

					col_cmd_delay_int := cmd_delay(col_cmd_bursts_int);

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

								else

									ColCtrlCtrlReq_tb <= (others => '0');
									col_cmd_delay_cnt := col_cmd_delay_cnt + 1;
								end if;
							end if;

							if (col_cmd_req = true) then
								if (ColCtrlCtrlAck_tb(0) = '1') then
									if (ColCtrlCtrlReq_tb(0) = '1') then
										ColCtrlCtrlReq_tb <= (others => '0');
										col_ctrl_err_arr(col_cnt_exp) := col_cmd_err_int;
										col_cmd_err_int := 0;

										col_cmd_req := false;
										end_col_cmd := true;

										for bl_cnt in 0 to (col_ctrl_bl - 1) loop
											col_ctrl_bank_exp(col_cnt_exp, bl_cnt) := col_ctrl_bank;

											col_exp(col_cnt_exp, bl_cnt) := col_ctrl_col + (bl_cnt * integer(2.0**real(burst_bits)));
											if (col_ctrl_read_burst = true) then
												if (bl_cnt = (col_ctrl_bl - 1)) then
													col_cmd_exp(col_cnt_exp, bl_cnt) := to_integer(unsigned(CMD_READ_PRECHARGE));
												else
													col_cmd_exp(col_cnt_exp, bl_cnt) := to_integer(unsigned(CMD_READ));
												end if;
											else
												if (bl_cnt = (col_ctrl_bl - 1)) then
													col_cmd_exp(col_cnt_exp, bl_cnt) := to_integer(unsigned(CMD_WRITE_PRECHARGE));
												else
													col_cmd_exp(col_cnt_exp, bl_cnt) := to_integer(unsigned(CMD_WRITE));
												end if;
											end if;
										end loop;

										col_cnt_exp := col_cnt_exp + 1;

									else
										col_cmd_err_int := col_cmd_err_int + 1;
									end if;
								end if;

							end if;
						end if;
					else
						end_col_cmd := true;
					end if;

				end if;

				if ((ref_cmd_bursts_int <= col_cmd_bursts_int) and  (ref_cmd_bursts_int < mrs_bank_ctrl_bursts_int) and (ref_cmd_bursts_int < num_bursts_exp)) then

					ref_ctrl_en := ref(ref_cmd_bursts_int);
					ref_ctrl_auto_ref := auto_ref(ref_cmd_bursts_int);

					ref_delay_int := ref_delay(ref_cmd_bursts_int);

					if (ref_ctrl_en = true) then

						if (ref_done = false) then
							if (ref_ctrl_auto_ref = true) then -- Auto refresh command: Wait RefreshReq to be set and wait a delay before moving on
								RefCtrlCtrlReq_tb <= '0';
								if (ref_ctrl_req = false) then
									if (RefCtrlRefreshReq_tb = '1') then
										stop_mrs_bank := true;
										ref_ctrl_req := true;
										ref_cnt := ref_cnt + 1;
									end if;
								else
									if (RefCtrlRefreshReq_tb = '0') then
										if (ref_delay_cnt = ref_delay_int) then
											ref_done := true;
											ref_ctrl_req := false;

											ref_ctrl_err_arr(ref_cnt_exp) := ref_cmd_err_int;
											ref_cmd_err_int := 0;

											ref_cmd_exp(ref_cnt_exp, 0) := to_integer(unsigned(CMD_AUTO_REF));
											ref_cmd_exp(ref_cnt_exp, 1) := to_integer(unsigned(CMD_NOP));
											ref_cnt_exp := ref_cnt_exp + 1;
											ref_delay_cnt := 0;

										else
											ref_delay_cnt := ref_delay_cnt + 1;
										end if;
									end if;
								end if;
							else
								if (ref_ctrl_req = false) then
									if (ref_delay_cnt = ref_delay_int) then
										RefCtrlCtrlReq_tb <= '1';

										ref_delay_cnt := 0;
										ref_ctrl_req := true;

										ref_cnt := ref_cnt + 1;

										wait for 1 ps;
									else

										RefCtrlCtrlReq_tb <= '0';
										ref_delay_cnt := ref_delay_cnt + 1;
									end if;
								end if;

								if (ref_ctrl_req = true) then

									if (ref_done_int = false) then
										if (RefCtrlCtrlAck_tb = '1') then
											if (RefCtrlCtrlReq_tb = '1') then
												RefCtrlCtrlReq_tb <= '0';

												if (self_ref = false) then
													ref_cmd_exp(ref_cnt_exp, 0) := to_integer(unsigned(CMD_SELF_REF_ENTRY));
													self_ref := true;
													ref_ctrl_req := false;
												else

													ref_ctrl_err_arr(ref_cnt_exp) := ref_cmd_err_int;
													ref_cmd_err_int := 0;

													ref_cmd_exp(ref_cnt_exp, 1) := to_integer(unsigned(CMD_SELF_REF_EXIT));
													ref_cnt_exp := ref_cnt_exp + 1;

													self_ref := false;
													ref_done_int := true;

													wait for 1 ps;

												end if;
											else
												ref_cmd_err_int := ref_cmd_err_int + 1;
											end if;
										end if;
									end if;

									if (ref_done_int = true) then
										if (RefCtrlRefreshReq_tb = '0') then
											ref_done := true;
											ref_done_int := false;
											ref_ctrl_req := false;
										end if;
									end if;
								end if;
							end if;
						end if;
					else
						ref_done := true;
					end if;

				end if;

				wait until ((clk_tb = '0') and (clk_tb'event));

				if (ref_cmd_bursts_int < num_bursts_exp) then
					if (ref_done = true) then
						ref_done := false;
						ref_cmd_bursts_int := ref_cmd_bursts_int + 1;
					end if;
				end if;

				if (col_cmd_bursts_int < num_bursts_exp) then
					if (end_col_cmd = true) then
						end_col_cmd := false;
						col_cmd_bursts_int := col_cmd_bursts_int + 1;
					end if;
				end if;

				if (mrs_bank_ctrl_bursts_int < num_bursts_exp) then
					if (mrs_bank_ctrl_handshake(mrs_bank_ctrl_bursts_int) = true) then
						mrs_bank_ctrl_bursts_int := mrs_bank_ctrl_bursts_int + 1;
					end if;
				end if;

				if (exp_self_ref_exit = true) then

					if ((CmdDecCmdMem_tb = CMD_SELF_REF_ENTRY) or (CmdDecCmdMem_tb = CMD_SELF_REF_EXIT) or (CmdDecCmdMem_tb = CMD_AUTO_REF)) then
						ref_cmd_rtl(ref_cmd_cnt, 1) := to_integer(unsigned(CmdDecCmdMem_tb));
						cmd_sent_in_self_ref_err(ref_cmd_cnt) := cmd_sent_in_self_ref;
						cmd_sent_in_self_ref := 0;
						ref_cmd_cnt := ref_cmd_cnt + 1;
						exp_self_ref_exit := false;
					elsif ((CmdDecCmdMem_tb /= CMD_NOP) and (CmdDecCmdMem_tb /= CMD_DESEL)) then
						cmd_sent_in_self_ref := cmd_sent_in_self_ref + 1;
					end if;

				else

					if (CmdDecCmdMem_tb = CMD_SELF_REF_ENTRY) then
						ref_cmd_rtl(ref_cmd_cnt, 0) := to_integer(unsigned(CmdDecCmdMem_tb));
						exp_self_ref_exit := true;
						cmd_sent_in_self_ref := 0;
					elsif (CmdDecCmdMem_tb = CMD_AUTO_REF) then
						-- Auto Refresh may also happens because couter reaches 0 and not caused by the test
						if (ref_cmd_cnt < ref_cnt) then
							ref_cmd_rtl(ref_cmd_cnt, 0) := to_integer(unsigned(CmdDecCmdMem_tb));
							ref_cmd_rtl(ref_cmd_cnt, 1) := to_integer(unsigned(CMD_NOP));
							exp_self_ref_exit := false;
							cmd_sent_in_self_ref := 0;
							cmd_sent_in_self_ref_err(ref_cmd_cnt) := cmd_sent_in_self_ref;
							ref_cmd_cnt := ref_cmd_cnt + 1;
						end if;
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
						bank_ctrl_row_rtl(to_integer(unsigned(CmdDecBankMem_tb)), bank_ctrl_cnt_rtl(to_integer(unsigned(CmdDecBankMem_tb)))) := to_integer(unsigned(CmdDecRowMem_tb));
						bank_ctrl_mrs_rtl(to_integer(unsigned(CmdDecBankMem_tb)), bank_ctrl_cnt_rtl(to_integer(unsigned(CmdDecBankMem_tb)))) := 0;
						bank_ctrl_cmd_rtl(to_integer(unsigned(CmdDecBankMem_tb)), bank_ctrl_cnt_rtl(to_integer(unsigned(CmdDecBankMem_tb)))) := to_integer(unsigned(CmdDecCmdMem_tb));

						bank_ctrl_cnt_rtl(to_integer(unsigned(CmdDecBankMem_tb))) := bank_ctrl_cnt_rtl(to_integer(unsigned(CmdDecBankMem_tb))) + 1;
					elsif ((CmdDecCmdMem_tb = CMD_MODE_REG_SET) or (CmdDecCmdMem_tb = CMD_EXT_MODE_REG_SET_1) or (CmdDecCmdMem_tb = CMD_EXT_MODE_REG_SET_2) or (CmdDecCmdMem_tb = CMD_EXT_MODE_REG_SET_3)) then
						mrs_ctrl_bank_rtl(mrs_cmd_cnt) := 0;
						mrs_ctrl_row_rtl(mrs_cmd_cnt) := 0;
						mrs_ctrl_mrs_rtl(mrs_cmd_cnt) := to_integer(unsigned(CmdDecMRSCmd_tb));
						mrs_ctrl_cmd_rtl(mrs_cmd_cnt) := to_integer(unsigned(CmdDecCmdMem_tb));
						mrs_cmd_cnt := mrs_cmd_cnt + 1;
					end if;

				end if;

				if (stop_mrs_bank = true) then
					if ((MRSCtrlMRSReq_tb = '0') and (RefCtrlRefreshReq_tb = '0') and (RefCtrlNonReadOpEnable_tb = '1')) then -- Enable MRS/Bank ctrl after Refresh
						stop_mrs_bank := false;
					end if;
				end if;

			end loop;

			num_bursts_rtl := mrs_bank_ctrl_bursts_int;

		end procedure run_ctrl_top;

		procedure verify(variable num_bursts_rtl, num_bursts_exp, mrs_req, bank_req, col_req, ref_req : in integer; variable num_bursts_arr : in int_arr(0 to (BANK_NUM_TB - 1)); variable bank, cols, rows, mrs_data : in int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable read_burst : in bool_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable bl : in int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable rw_burst, ref, auto_ref, mrs : in bool_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable mrs_cmd : in int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable mrs_ctrl_err_arr, bank_ctrl_err_arr, col_ctrl_err_arr, ref_ctrl_err_arr, mrs_ctrl_bank_rtl, mrs_ctrl_bank_exp, mrs_ctrl_row_rtl, mrs_ctrl_row_exp, mrs_ctrl_cmd_rtl, mrs_ctrl_cmd_exp, mrs_ctrl_mrs_rtl, mrs_ctrl_mrs_exp, cmd_sent_in_self_ref_err : in int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable bank_ctrl_row_rtl, bank_ctrl_row_exp, bank_ctrl_cmd_rtl, bank_ctrl_cmd_exp, bank_ctrl_mrs_rtl, bank_ctrl_mrs_exp : in int_arr_2d(0 to (BANK_NUM_TB - 1), 0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable ref_cmd_rtl, ref_cmd_exp : in int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1), 0 to 1); variable col_rtl, col_exp, col_cmd_rtl, col_cmd_exp, col_ctrl_bank_rtl, col_ctrl_bank_exp : in int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1), 0 to (integer(2.0**(real(BURST_LENGTH_L_TB)) - 1.0))); file file_pointer : text; variable pass: out integer) is

			variable match_bank_ctrl_cmd	: boolean;
			variable match_bank_ctrl_mrs	: boolean;
			variable match_bank_ctrl_rows	: boolean;

			variable match_mrs_ctrl_cmd	: boolean;
			variable match_mrs_ctrl_mrs	: boolean;
			variable match_mrs_ctrl_rows	: boolean;
			variable match_mrs_ctrl_bank	: boolean;

			variable match_cols		: boolean;
			variable match_col_cmd		: boolean;
			variable match_col_ctrl_bank	: boolean;
			variable match_ref_cmd		: boolean;

			variable no_bank_ctrl_err		: boolean;
			variable no_mrs_ctrl_err		: boolean;
			variable no_col_ctrl_err		: boolean;
			variable no_ref_ctrl_err		: boolean;
			variable no_cmd_sent_in_self_ref	: boolean;

			variable file_line	: line;

		begin

			match_cols := compare_int_arr_2d(col_exp, col_rtl, col_req, integer(2.0**(real(BURST_LENGTH_L_TB))));

			match_bank_ctrl_mrs := compare_int_arr_2d(bank_ctrl_mrs_exp, bank_ctrl_mrs_rtl, BANK_NUM_TB, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));
			match_bank_ctrl_rows := compare_int_arr_2d(bank_ctrl_row_exp, bank_ctrl_row_rtl, BANK_NUM_TB, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));
			match_bank_ctrl_cmd := compare_int_arr_2d(bank_ctrl_cmd_exp, bank_ctrl_cmd_rtl, BANK_NUM_TB, (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB));

			match_mrs_ctrl_mrs := compare_int_arr(mrs_ctrl_mrs_exp, mrs_ctrl_mrs_rtl, mrs_req);
			match_mrs_ctrl_rows := compare_int_arr(mrs_ctrl_row_exp, mrs_ctrl_row_rtl, mrs_req);
			match_mrs_ctrl_cmd := compare_int_arr(mrs_ctrl_cmd_exp, mrs_ctrl_cmd_rtl, mrs_req);
			match_mrs_ctrl_bank := compare_int_arr(mrs_ctrl_bank_exp, mrs_ctrl_bank_rtl, mrs_req);

			match_col_cmd := compare_int_arr_2d(col_cmd_exp, col_cmd_rtl, col_req, integer(2.0**(real(BURST_LENGTH_L_TB))));
			match_col_ctrl_bank := compare_int_arr_2d(col_ctrl_bank_exp, col_ctrl_bank_rtl, col_req, integer(2.0**(real(BURST_LENGTH_L_TB))));
			match_ref_cmd := compare_int_arr_2d(ref_cmd_exp, ref_cmd_rtl, ref_req, 2);

			no_bank_ctrl_err := compare_int_arr(reset_int_arr(0, bank_req), bank_ctrl_err_arr, bank_req);
			no_mrs_ctrl_err := compare_int_arr(reset_int_arr(0, mrs_req), mrs_ctrl_err_arr, mrs_req);
			no_col_ctrl_err := compare_int_arr(reset_int_arr(0, col_req), col_ctrl_err_arr, col_req);
			no_ref_ctrl_err := compare_int_arr(reset_int_arr(0, ref_req), ref_ctrl_err_arr, ref_req);
			no_cmd_sent_in_self_ref := compare_int_arr(reset_int_arr(0, ref_req), cmd_sent_in_self_ref_err, ref_req);

			for i in 0 to (BANK_NUM_TB - 1) loop

				write(file_line, string'( "PHY Controller Top Level with Initialization block: Bank #" & integer'image(i) & ": Number of bursts " & integer'image(num_bursts_arr(i))));
				writeline(file_pointer, file_line);

			end loop;

			for i in 0 to (num_bursts_exp - 1) loop

				if ((rw_burst(i) = true) and (ref(i) = true)) then
					write(file_line, string'( "PHY Controller Top Level with Initialization Block: Burst #" & integer'image(i) & " Bank " & integer'image(bank(i)) & " Start Column " & integer'image(cols(i)) & " Row " & integer'image(rows(i)) & " Burst Length " & integer'image(bl(i)) & " Refresh : Auto-Refresh " & bool_to_str(auto_ref(i))));
				elsif ((rw_burst(i) = true) and (ref(i) = false)) then
					write(file_line, string'( "PHY Controller Top Level with Initialization Block: Burst #" & integer'image(i) & " Bank " & integer'image(bank(i)) & " Start Column " & integer'image(cols(i)) & " Row " & integer'image(rows(i)) & " Burst Length " & integer'image(bl(i)) & " Refresh : False"));
				elsif ((mrs(i) = true) and (ref(i) = true)) then
					write(file_line, string'( "PHY Controller Top Level with Initialization Block: Burst #" & integer'image(i) & " MRS Command " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(mrs_cmd(i), MEM_CMD_L))) & " MRS Data " & integer'image(mrs_data(i)) & " Refresh : Auto-Refresh " & bool_to_str(auto_ref(i))));
				elsif ((mrs(i) = true) and (ref(i) = false)) then
					write(file_line, string'( "PHY Controller Top Level with Initialization Block: Burst #" & integer'image(i) & " MRS Command " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(mrs_cmd(i), MEM_CMD_L))) & " MRS Data " & integer'image(mrs_data(i)) & " Refresh : False"));
				elsif (ref(i) = true) then
					write(file_line, string'( "PHY Controller Top Level with Initialization Block: Burst #" & integer'image(i) & " Refresh : Auto-Refresh " & bool_to_str(auto_ref(i))));
				else
					write(file_line, string'( "PHY Controller Top Level with Initialization Block: Burst #" & integer'image(i) & " No Command "));
				end if;

				writeline(file_pointer, file_line);

			end loop;

			if ((num_bursts_rtl = num_bursts_exp) and (match_cols = true) and (match_mrs_ctrl_mrs = true) and (match_mrs_ctrl_rows = true) and (match_mrs_ctrl_cmd = true) and (match_mrs_ctrl_bank = true) and (no_mrs_ctrl_err = true) and (match_bank_ctrl_mrs = true) and (match_bank_ctrl_rows = true) and (match_bank_ctrl_cmd = true) and (no_bank_ctrl_err = true) and (match_col_ctrl_bank = true) and (match_col_cmd = true) and (match_ref_cmd = true) and (no_col_ctrl_err = true) and (no_ref_ctrl_err = true) and (no_cmd_sent_in_self_ref = true)) then
				write(file_line, string'( "PHY Controller Top Level with Initialization Block: PASS"));
				writeline(file_pointer, file_line);
				pass := 1;
			elsif (num_bursts_rtl /= num_bursts_exp) then
				write(file_line, string'( "PHY Controller Top Level with Initialization Block: FAIL (Number bursts mismatch): exp " & integer'image(num_bursts_exp) & " vs rtl " & integer'image(num_bursts_rtl)));
				writeline(file_pointer, file_line);
				pass := 0;
			elsif (match_bank_ctrl_cmd = false) then
				write(file_line, string'( "PHY Controller Top Level with Initialization Block: FAIL (Bank Controller Bank Command mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (BANK_NUM_TB - 1) loop
					for j in 0 to (num_bursts_arr(i) - 1) loop
						if (bank_ctrl_cmd_exp(i, j) /= bank_ctrl_cmd_rtl(i, j)) then
							write(file_line, string'( "PHY Controller Top Level with Initialization Block: Bank " & integer'image(i) & " Burst #" & integer'image(j) & " details: Cmd exp " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(bank_ctrl_cmd_exp(i, j), MEM_CMD_L))) & " vs rtl " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(bank_ctrl_cmd_rtl(i, j), MEM_CMD_L)))));
							writeline(file_pointer, file_line);
						end if;
					end loop;
				end loop;
				pass := 0;
			elsif (match_bank_ctrl_rows = false) then
				write(file_line, string'( "PHY Controller Top Level with Initialization Block: FAIL (Bank Controller Row mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (BANK_NUM_TB - 1) loop
					for j in 0 to (num_bursts_arr(i) - 1) loop
						write(file_line, string'( "PHY Controller Top Level with Initialization Block: Bank " & integer'image(i) & " Burst #" & integer'image(j) & " details: Row exp " & integer'image(bank_ctrl_row_exp(i, j)) & " vs rtl " & integer'image(bank_ctrl_row_rtl(i, j))));
						writeline(file_pointer, file_line);
					end loop;
				end loop;
				pass := 0;
			elsif (match_bank_ctrl_mrs = false) then
				write(file_line, string'( "PHY Controller Top Level with Initialization Block: FAIL (Bank Controller MRS Data mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (BANK_NUM_TB - 1) loop
					for j in 0 to (num_bursts_arr(i) - 1) loop
						write(file_line, string'( "PHY Controller Top Level with Initialization Block: Bank " & integer'image(i) & " Burst #" & integer'image(j) & " details: MRS data exp " & integer'image(bank_ctrl_mrs_exp(i, j)) & " vs rtl " & integer'image(bank_ctrl_mrs_rtl(i, j))));
						writeline(file_pointer, file_line);
					end loop;
				end loop;
				pass := 0;
			elsif (no_bank_ctrl_err = false) then
				write(file_line, string'( "PHY Controller Top Level with Initialization Block: FAIL (Bank Controller Handshake Error)"));
				writeline(file_pointer, file_line);
				for i in 0 to (bank_req - 1) loop
					write(file_line, string'( "PHY Controller Top Level with Initialization Block: Error Burst #" & integer'image(i) & ": " & integer'image(bank_ctrl_err_arr(i)) & " Error(s)"));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (match_mrs_ctrl_cmd = false) then
				write(file_line, string'( "PHY Controller Top Level with Initialization Block: FAIL (MRS Controller Bank Command mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (mrs_req - 1) loop
					if (mrs_ctrl_cmd_exp(i) /= mrs_ctrl_cmd_rtl(i)) then
						write(file_line, string'( "PHY Controller Top Level with Initialization Block: Burst #" & integer'image(i) & " details: Cmd exp " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(mrs_ctrl_cmd_exp(i), MEM_CMD_L))) & " vs rtl " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(mrs_ctrl_cmd_rtl(i), MEM_CMD_L)))));
						writeline(file_pointer, file_line);
					end if;
				end loop;
				pass := 0;
			elsif (match_mrs_ctrl_bank = false) then
				write(file_line, string'( "PHY Controller Top Level with Initialization Block: FAIL (MRS Controller Bank mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (mrs_req - 1) loop
					if (mrs_ctrl_bank_exp(i) /= mrs_ctrl_bank_rtl(i)) then
						write(file_line, string'( "PHY Column Controller: Burst #" & integer'image(i) & " Bank exp " & integer'image(mrs_ctrl_bank_exp(i)) & " vs rtl " & integer'image(mrs_ctrl_bank_rtl(i))));
						writeline(file_pointer, file_line);
					end if;
				end loop;
				pass := 0;
			elsif (match_mrs_ctrl_rows = false) then
				write(file_line, string'( "PHY Controller Top Level with Initialization Block: FAIL (MRS Controller Row mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (mrs_req - 1) loop
					write(file_line, string'( "PHY Controller Top Level with Initialization Block: Burst #" & integer'image(i) & " details: Row exp " & integer'image(mrs_ctrl_row_exp(i)) & " vs rtl " & integer'image(mrs_ctrl_row_rtl(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (match_mrs_ctrl_mrs = false) then
				write(file_line, string'( "PHY Controller Top Level with Initialization Block: FAIL (MRS Controller MRS Data mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (mrs_req - 1) loop
					write(file_line, string'( "PHY Controller Top Level with Initialization Block: Burst #" & integer'image(i) & " details: MRS data exp " & integer'image(mrs_ctrl_mrs_exp(i)) & " vs rtl " & integer'image(mrs_ctrl_mrs_rtl(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (no_mrs_ctrl_err = false) then
				write(file_line, string'( "PHY Controller Top Level with Initialization Block: FAIL (MRS Controller Handshake Error)"));
				writeline(file_pointer, file_line);
				for i in 0 to (mrs_req - 1) loop
					write(file_line, string'( "PHY Controller Top Level with Initialization Block: Error Burst #" & integer'image(i) & ": " & integer'image(mrs_ctrl_err_arr(i)) & " Error(s)"));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (match_ref_cmd = false) then
				write(file_line, string'( "PHY Controller Top Level with Initialization Block: FAIL (Refresh Command mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (ref_req - 1) loop
					for j in 0 to 1 loop
						if (ref_cmd_exp(i, j) /= ref_cmd_rtl(i, j)) then
							write(file_line, string'( "PHY Controller Top Level with Initialization Block: Burst #" & integer'image(i) & " details: Cmd exp " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(ref_cmd_exp(i, j), MEM_CMD_L))) & " vs rtl " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(ref_cmd_rtl(i, j), MEM_CMD_L)))));
							writeline(file_pointer, file_line);
						end if;
					end loop;
				end loop;
				pass := 0;
			elsif (match_col_cmd = false) then
				write(file_line, string'( "PHY Controller Top Level with Initialization Block: FAIL (Column Command mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (col_req - 1) loop
					write(file_line, string'( "========================================================================================"));
					writeline(file_pointer, file_line);
					write(file_line, string'( "PHY Controller Top Level with Initialization Block: Burst #" & integer'image(i) & " details: Col " & integer'image(col_exp(i, 0)) & " Read Burst " & bool_to_str(read_burst(i)) & " Burst Length " & integer'image(bl(i))));
					writeline(file_pointer, file_line);
					for j in 0 to (bl(i) - 1) loop
						if (col_cmd_rtl(i,j) /= col_cmd_exp(i,j)) then
							write(file_line, string'( "PHY Column Controller: Burst #" & integer'image(i) & " Cmd #" & integer'image(j) & " Column Command exp " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(col_cmd_exp(i, j), MEM_CMD_L))) & " vs rtl " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(col_cmd_rtl(i, j), MEM_CMD_L)))));
							writeline(file_pointer, file_line);
						end if;
					end loop;
				end loop;
				write(file_line, string'( "========================================================================================"));
				writeline(file_pointer, file_line);
				pass := 0;
			elsif (match_col_ctrl_bank = false) then
				write(file_line, string'( "PHY Controller Top Level with Initialization Block: FAIL (Column Command Bank mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (col_req - 1) loop
					write(file_line, string'( "========================================================================================"));
					writeline(file_pointer, file_line);
					write(file_line, string'( "PHY Controller Top Level with Initialization Block: Burst #" & integer'image(i) & " details: Bank " & integer'image(col_ctrl_bank_exp(i, 0))));
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
				write(file_line, string'( "PHY Controller Top Level with Initialization Block: FAIL (Col mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (col_req - 1) loop
					write(file_line, string'( "========================================================================================"));
					writeline(file_pointer, file_line);
					write(file_line, string'( "PHY Controller Top Level with Initialization Block: Burst #" & integer'image(i) & " details: Start Col " & integer'image(col_exp(i, 0)) & " Burst Length " & integer'image(bl(i))));
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
			elsif (no_col_ctrl_err = false) then
				write(file_line, string'( "PHY Controller Top Level with Initialization Block: FAIL (Column Controller Handshake Error)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_bursts_exp - 1) loop
					write(file_line, string'( "PHY Controller Top Level with Initialization Block: Error Burst #" & integer'image(i) & ": " & integer'image(col_ctrl_err_arr(i)) & " Error(s)"));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (no_ref_ctrl_err = false) then
				write(file_line, string'( "PHY Controller Top Level with Initialization Block: FAIL (Refresh Controller Handshake Error)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_bursts_exp - 1) loop
					write(file_line, string'( "PHY Controller Top Level with Initialization Block: Error Burst #" & integer'image(i) & ": " & integer'image(ref_ctrl_err_arr(i)) & " Error(s)"));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (no_cmd_sent_in_self_ref = false) then
				write(file_line, string'( "PHY Controller Top Level with Initialization Block: FAIL (Commands detected during Self Refresh)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_bursts_exp - 1) loop
					write(file_line, string'( "PHY Controller Top Level with Initialization Block: Error Burst #" & integer'image(i) & ": " & integer'image(cmd_sent_in_self_ref_err(i)) & " Error(s)"));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			else
				write(file_line, string'( "PHY Controller Top Level with Initialization Block: FAIL (Unknown Command)"));
				writeline(file_pointer, file_line);
				pass := 0;
			end if;
		end procedure verify;

		variable seed1, seed2	: positive;

		variable num_bursts_exp	: integer;
		variable num_bursts_rtl	: integer;

		variable num_bursts_arr	: int_arr(0 to (BANK_NUM_TB - 1));

		variable bank_req	: integer;
		variable mrs_req	: integer;
		variable col_req	: integer;
		variable ref_req	: integer;

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

		variable bank_ctrl_err_arr		: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable mrs_ctrl_err_arr		: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable col_ctrl_err_arr		: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable ref_ctrl_err_arr		: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));

		variable bank_ctrl_row_rtl		: int_arr_2d(0 to (BANK_NUM_TB - 1), 0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable bank_ctrl_row_exp		: int_arr_2d(0 to (BANK_NUM_TB - 1), 0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable bank_ctrl_cmd_rtl		: int_arr_2d(0 to (BANK_NUM_TB - 1), 0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable bank_ctrl_cmd_exp		: int_arr_2d(0 to (BANK_NUM_TB - 1), 0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable bank_ctrl_mrs_rtl		: int_arr_2d(0 to (BANK_NUM_TB - 1), 0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable bank_ctrl_mrs_exp		: int_arr_2d(0 to (BANK_NUM_TB - 1), 0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));

		variable mrs_ctrl_bank_rtl		: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable mrs_ctrl_bank_exp		: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable mrs_ctrl_row_rtl		: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable mrs_ctrl_row_exp		: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable mrs_ctrl_cmd_rtl		: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable mrs_ctrl_cmd_exp		: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable mrs_ctrl_mrs_rtl		: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable mrs_ctrl_mrs_exp		: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));

		variable cmd_sent_in_self_ref_err	: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));

		variable ref_cmd_rtl			: int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1), 0 to 1);
		variable ref_cmd_exp			: int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1), 0 to 1);

		variable col_rtl			: int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1), 0 to (integer(2.0**(real(BURST_LENGTH_L_TB)) - 1.0)));
		variable col_exp			: int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1), 0 to (integer(2.0**(real(BURST_LENGTH_L_TB)) - 1.0)));
		variable col_cmd_rtl			: int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1), 0 to (integer(2.0**(real(BURST_LENGTH_L_TB)) - 1.0)));
		variable col_cmd_exp			: int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1), 0 to (integer(2.0**(real(BURST_LENGTH_L_TB)) - 1.0)));
		variable col_ctrl_bank_rtl		: int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1), 0 to (integer(2.0**(real(BURST_LENGTH_L_TB)) - 1.0)));
		variable col_ctrl_bank_exp		: int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1), 0 to (integer(2.0**(real(BURST_LENGTH_L_TB)) - 1.0)));

		variable pass		: integer;
		variable num_pass	: integer;

		file file_pointer	: text;
		variable file_line	: line;

	begin

		wait for 1 ns;

		num_pass := 0;

		reset;
		file_open(file_pointer, ddr2_ctrl_init_top_log_file, append_mode);

		write(file_line, string'( "PHY Controller Top Level with Initialization Block Test"));
		writeline(file_pointer, file_line);

		for i in 0 to NUM_TESTS-1 loop

			test_param(num_bursts_exp, mrs_req, bank_req, col_req, ref_req, num_bursts_arr, bank, cols, rows, mrs_data, read_burst, bl, cmd_delay, ctrl_delay, rw_burst, ref, mrs, auto_ref, ref_delay, mrs_cmd, seed1, seed2);

			run_ctrl_top(num_bursts_exp, bank, cols, rows, mrs_data, read_burst, bl, cmd_delay, ctrl_delay, rw_burst, ref, auto_ref, mrs, ref_delay, mrs_cmd, num_bursts_rtl, mrs_ctrl_err_arr, bank_ctrl_err_arr, col_ctrl_err_arr, ref_ctrl_err_arr, mrs_ctrl_bank_rtl, mrs_ctrl_bank_exp, mrs_ctrl_row_rtl, mrs_ctrl_row_exp, mrs_ctrl_cmd_rtl, mrs_ctrl_cmd_exp, mrs_ctrl_mrs_rtl, mrs_ctrl_mrs_exp, cmd_sent_in_self_ref_err, bank_ctrl_row_rtl, bank_ctrl_row_exp, bank_ctrl_cmd_rtl, bank_ctrl_cmd_exp, bank_ctrl_mrs_rtl, bank_ctrl_mrs_exp, ref_cmd_rtl, ref_cmd_exp, col_rtl, col_exp, col_cmd_rtl, col_cmd_exp, col_ctrl_bank_rtl, col_ctrl_bank_exp);

			verify(num_bursts_rtl, num_bursts_exp, mrs_req, bank_req, col_req, ref_req, num_bursts_arr, bank, cols, rows, mrs_data, read_burst, bl, rw_burst, ref, auto_ref, mrs, mrs_cmd, mrs_ctrl_err_arr, bank_ctrl_err_arr, col_ctrl_err_arr, ref_ctrl_err_arr, mrs_ctrl_bank_rtl, mrs_ctrl_bank_exp, mrs_ctrl_row_rtl, mrs_ctrl_row_exp, mrs_ctrl_cmd_rtl, mrs_ctrl_cmd_exp, mrs_ctrl_mrs_rtl, mrs_ctrl_mrs_exp, cmd_sent_in_self_ref_err, bank_ctrl_row_rtl, bank_ctrl_row_exp, bank_ctrl_cmd_rtl, bank_ctrl_cmd_exp, bank_ctrl_mrs_rtl, bank_ctrl_mrs_exp, ref_cmd_rtl, ref_cmd_exp, col_rtl, col_exp, col_cmd_rtl, col_cmd_exp, col_ctrl_bank_rtl, col_ctrl_bank_exp, file_pointer, pass);

			num_pass := num_pass + pass;

			wait until ((clk_tb'event) and (clk_tb = '1'));
		end loop;

		file_close(file_pointer);

		file_open(file_pointer, summary_file, append_mode);
		write(file_line, string'( "PHY Controller Top Level with Initialization Block => PASSES: " & integer'image(num_pass) & " out of " & integer'image(TOT_NUM_TESTS)));
		writeline(file_pointer, file_line);

		if (num_pass = TOT_NUM_TESTS) then
			write(file_line, string'( "PHY Controller Top Level with Initialization Block: TEST PASSED"));
		else
			write(file_line, string'( "PHY Controller Top Level with Initialization Block: TEST FAILED: " & integer'image(TOT_NUM_TESTS-num_pass) & " failures"));
		end if;
		writeline(file_pointer, file_line);

		file_close(file_pointer);
		stop <= true;

		wait;

	end process test;

end bench;
