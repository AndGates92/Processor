library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;
use work.proc_pkg.all;
use work.ddr2_define_pkg.all;
use work.ddr2_phy_pkg.all;
use work.ddr2_phy_arbiter_pkg.all;
use work.type_conversion_pkg.all;
use work.tb_pkg.all;
use work.ddr2_pkg_tb.all;

entity ddr2_phy_arbiter_tb is
end entity ddr2_phy_arbiter_tb;

architecture bench of ddr2_phy_arbiter_tb is

	constant CLK_PERIOD	: time := DDR2_CLK_PERIOD * 1 ns;
	constant NUM_TESTS	: integer := 1000;
	constant TOT_NUM_TESTS	: integer := NUM_TESTS;

	constant MAX_REQUESTS_PER_TEST		: integer := 500;

	constant ZERO_BANK_CTRL_ACK	: std_logic_vector(BANK_CTRL_NUM_TB - 1 downto 0) := (others => '0');
	constant ZERO_COL_CTRL_ACK	: std_logic_vector(COL_CTRL_NUM_TB - 1 downto 0) := (others => '0');
	constant ZERO_REF_CTRL_ACK	: std_logic_vector(REF_CTRL_NUM_TB - 1 downto 0) := (others => '0');
	constant ZERO_MRS_CTRL_ACK	: std_logic_vector(MRS_CTRL_NUM_TB - 1 downto 0) := (others => '0');

	constant MAX_VALUE_PRIORITY_TB	: integer := (BANK_CTRL_NUM_TB + COL_CTRL_NUM_TB - 1);

	signal clk_tb	: std_logic := '0';
	signal stop	: boolean := false;
	signal rst_tb	: std_logic;

	-- Bank Controllers
	signal BankCtrlBankMem_tb	: std_logic_vector(BANK_CTRL_NUM_TB*(int_to_bit_num(BANK_NUM_TB)) - 1 downto 0);
	signal BankCtrlRowMem_tb	: std_logic_vector(BANK_CTRL_NUM_TB*ROW_L_TB - 1 downto 0);
	signal BankCtrlCmdMem_tb	: std_logic_vector(BANK_CTRL_NUM_TB*MEM_CMD_L - 1 downto 0);
	signal BankCtrlCmdReq_tb	: std_logic_vector(BANK_CTRL_NUM_TB - 1 downto 0);

	signal BankCtrlCmdAck_tb	: std_logic_vector(BANK_CTRL_NUM_TB - 1 downto 0);

	-- Column Controller
	signal ColCtrlColMem_tb		: std_logic_vector(COL_CTRL_NUM_TB*COL_L_TB - 1 downto 0);
	signal ColCtrlBankMem_tb	: std_logic_vector(COL_CTRL_NUM_TB*(int_to_bit_num(BANK_NUM_TB)) - 1 downto 0);
	signal ColCtrlCmdMem_tb		: std_logic_vector(COL_CTRL_NUM_TB*MEM_CMD_L - 1 downto 0);
	signal ColCtrlCmdReq_tb		: std_logic_vector(COL_CTRL_NUM_TB - 1 downto 0);

	signal ColCtrlCmdAck_tb		: std_logic_vector(COL_CTRL_NUM_TB - 1 downto 0);

	-- Refresh Controller
	signal RefCtrlCmdMem_tb		: std_logic_vector(REF_CTRL_NUM_TB*MEM_CMD_L - 1 downto 0);
	signal RefCtrlCmdReq_tb		: std_logic_vector(REF_CTRL_NUM_TB - 1 downto 0);

	signal RefCtrlCmdAck_tb		: std_logic_vector(REF_CTRL_NUM_TB - 1 downto 0);

	-- MRS Controller
	signal MRSCtrlMRSCmd_tb		: std_logic_vector(MRS_CTRL_NUM_TB*ADDR_MEM_L_TB - 1 downto 0);
	signal MRSCtrlCmdMem_tb		: std_logic_vector(MRS_CTRL_NUM_TB*MEM_CMD_L - 1 downto 0);
	signal MRSCtrlCmdReq_tb		: std_logic_vector(MRS_CTRL_NUM_TB - 1 downto 0);

	signal MRSCtrlCmdAck_tb		: std_logic_vector(MRS_CTRL_NUM_TB - 1 downto 0);

	-- Arbiter Controller
	signal AllowBankActivate_tb	: std_logic;

	signal BankActOut_tb		: std_logic;

	-- Command Decoder
	signal CmdDecColMem_tb		: std_logic_vector(COL_L_TB - 1 downto 0);
	signal CmdDecRowMem_tb		: std_logic_vector(ROW_L_TB - 1 downto 0);
	signal CmdDecBankMem_tb		: std_logic_vector(int_to_bit_num(BANK_NUM_TB) - 1 downto 0);
	signal CmdDecCmdMem_tb		: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal CmdDecMRSCmd_tb		: std_logic_vector(ADDR_MEM_L_TB - 1 downto 0);

begin

	DUT: ddr2_phy_arbiter generic map (
		ROW_L => ROW_L_TB,
		COL_L => COL_L_TB,
		ADDR_L => ADDR_MEM_L_TB,
		BANK_NUM => BANK_NUM_TB,
		BANK_CTRL_NUM => BANK_CTRL_NUM_TB,
		COL_CTRL_NUM => COL_CTRL_NUM_TB,
		MRS_CTRL_NUM => MRS_CTRL_NUM_TB,
		REF_CTRL_NUM => REF_CTRL_NUM_TB
	)
	port map (
		clk => clk_tb,
		rst => rst_tb,

		-- Bank Controllers
		BankCtrlBankMem => BankCtrlBankMem_tb,
		BankCtrlRowMem => BankCtrlRowMem_tb,
		BankCtrlCmdMem => BankCtrlCmdMem_tb,
		BankCtrlCmdReq => BankCtrlCmdReq_tb,

		BankCtrlCmdAck => BankCtrlCmdAck_tb,

		-- Column Controller
		ColCtrlColMem => ColCtrlColMem_tb,
		ColCtrlBankMem => ColCtrlBankMem_tb,
		ColCtrlCmdMem => ColCtrlCmdMem_tb,
		ColCtrlCmdReq => ColCtrlCmdReq_tb,

		ColCtrlCmdAck => ColCtrlCmdAck_tb,

		-- Refresh Controller
		RefCtrlCmdMem => RefCtrlCmdMem_tb,
		RefCtrlCmdReq => RefCtrlCmdReq_tb,

		RefCtrlCmdAck => RefCtrlCmdAck_tb,

		-- MRS Controller
		MRSCtrlMRSCmd => MRSCtrlMRSCmd_tb,
		MRSCtrlCmdMem => MRSCtrlCmdMem_tb,
		MRSCtrlCmdReq => MRSCtrlCmdReq_tb,

		MRSCtrlCmdAck => MRSCtrlCmdAck_tb,

		-- Arbiter Controller
		AllowBankActivate => AllowBankActivate_tb,

		BankActOut => BankActOut_tb,

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
			AllowBankActivate_tb <= '0';
			BankCtrlCmdReq_tb <= (others => '0');
			ColCtrlCmdReq_tb <= (others => '0');
			RefCtrlCmdReq_tb <= (others => '0');

			rst_tb <= '0';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_tb <= '1';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_tb <= '0';
		end procedure reset;

		procedure test_param(variable num_requests : out integer; variable bank_ctrl_bank, bank_ctrl_row, bank_ctrl_cmd : out int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (BANK_CTRL_NUM_TB - 1)); variable bank_ctrl_cmd_req : out bool_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (BANK_CTRL_NUM_TB - 1)); variable col_ctrl_bank, col_ctrl_col, col_ctrl_cmd : out int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (COL_CTRL_NUM_TB - 1)); variable col_ctrl_cmd_req : out bool_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (COL_CTRL_NUM_TB - 1)); variable ref_ctrl_cmd : out int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (REF_CTRL_NUM_TB - 1)); variable ref_ctrl_cmd_req : out bool_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (REF_CTRL_NUM_TB - 1)); variable mrs_ctrl_mrs_cmd, mrs_ctrl_cmd : out int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (REF_CTRL_NUM_TB - 1)); variable mrs_ctrl_cmd_req : out bool_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (REF_CTRL_NUM_TB - 1)); variable allow_act : out bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable seed1, seed2: inout positive) is
			variable rand_val		: real;
			variable num_requests_int	: integer;

			variable col_cmd_id		: integer;
			variable ref_cmd_id		: integer;
			variable mrs_cmd_id		: integer;
		begin

			num_requests_int := 0;
			while (num_requests_int = 0) loop
				uniform(seed1, seed2, rand_val);
				num_requests_int := integer(rand_val*real(MAX_REQUESTS_PER_TEST));
			end loop;
			num_requests := num_requests_int;

			for i in 0 to (num_requests_int - 1) loop
				for j in 0 to (BANK_CTRL_NUM_TB - 1) loop
					uniform(seed1, seed2, rand_val);
					bank_ctrl_bank(i, j) := integer(rand_val*real(BANK_NUM_TB - 1));
					uniform(seed1, seed2, rand_val);
					bank_ctrl_row(i, j) := integer(rand_val*real(2.0**(real(ROW_L_TB) - 1.0)));
					bank_ctrl_cmd(i, j) := to_integer(unsigned(CMD_BANK_ACT));
					uniform(seed1, seed2, rand_val);
					bank_ctrl_cmd_req(i, j) := rand_bool(rand_val, 0.5);
				end loop;

				for j in 0 to (COL_CTRL_NUM_TB - 1) loop
					uniform(seed1, seed2, rand_val);
					col_ctrl_bank(i, j) := integer(rand_val*real(BANK_NUM_TB - 1));
					uniform(seed1, seed2, rand_val);
					col_ctrl_col(i, j) := integer(rand_val*real(2.0**(real(COL_L_TB) - 1.0)));
					uniform(seed1, seed2, rand_val);
					col_cmd_id := integer(3.0*rand_val);
					if (col_cmd_id = 0) then
						col_ctrl_cmd(i, j) := to_integer(unsigned(CMD_WRITE));
					elsif (col_cmd_id = 1) then
						col_ctrl_cmd(i, j) := to_integer(unsigned(CMD_READ));
					elsif (col_cmd_id = 2) then
						col_ctrl_cmd(i, j) := to_integer(unsigned(CMD_WRITE_PRECHARGE));
					elsif (col_cmd_id = 3) then
						col_ctrl_cmd(i, j) := to_integer(unsigned(CMD_READ_PRECHARGE));
					else
						col_ctrl_cmd(i, j) := to_integer(unsigned(CMD_NOP));
					end if;
					uniform(seed1, seed2, rand_val);
					col_ctrl_cmd_req(i, j) := rand_bool(rand_val, 0.5);
				end loop;

				for j in 0 to (REF_CTRL_NUM_TB - 1) loop
					uniform(seed1, seed2, rand_val);
					ref_cmd_id := integer(2.0*rand_val);
					if (ref_cmd_id = 0) then
						ref_ctrl_cmd(i, j) := to_integer(unsigned(CMD_AUTO_REF));
					elsif (ref_cmd_id = 1) then
						ref_ctrl_cmd(i, j) := to_integer(unsigned(CMD_SELF_REF_ENTRY));
					elsif (ref_cmd_id = 2) then
						ref_ctrl_cmd(i, j) := to_integer(unsigned(CMD_SELF_REF_EXIT));
					else
						ref_ctrl_cmd(i, j) := to_integer(unsigned(CMD_NOP));
					end if;
					uniform(seed1, seed2, rand_val);
					ref_ctrl_cmd_req(i, j) := rand_bool(rand_val, 0.5);
				end loop;

				for j in 0 to (MRS_CTRL_NUM_TB - 1) loop
					uniform(seed1, seed2, rand_val);
					mrs_ctrl_mrs_cmd(i, j) := integer(rand_val*real(ADDR_MEM_L_TB - 1));
					uniform(seed1, seed2, rand_val);
					mrs_cmd_id := integer(3.0*rand_val);
					if (mrs_cmd_id = 0) then
						mrs_ctrl_cmd(i, j) := to_integer(unsigned(CMD_MODE_REG_SET));
					elsif (mrs_cmd_id = 1) then
						mrs_ctrl_cmd(i, j) := to_integer(unsigned(CMD_EXT_MODE_REG_SET_1));
					elsif (mrs_cmd_id = 2) then
						mrs_ctrl_cmd(i, j) := to_integer(unsigned(CMD_EXT_MODE_REG_SET_2));
					elsif (mrs_cmd_id = 3) then
						mrs_ctrl_cmd(i, j) := to_integer(unsigned(CMD_EXT_MODE_REG_SET_3));
					else
						mrs_ctrl_cmd(i, j) := to_integer(unsigned(CMD_NOP));
					end if;
					uniform(seed1, seed2, rand_val);
					mrs_ctrl_cmd_req(i, j) := rand_bool(rand_val, 0.5);
				end loop;

				uniform(seed1, seed2, rand_val);
				allow_act(i) := rand_bool(rand_val, 0.5);

			end loop;

		end procedure test_param;

		procedure run_arbiter(variable num_requests_exp : in integer; variable bank_ctrl_bank, bank_ctrl_row, bank_ctrl_cmd : in int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (BANK_CTRL_NUM_TB - 1)); variable bank_ctrl_cmd_req : in bool_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (BANK_CTRL_NUM_TB - 1)); variable col_ctrl_bank, col_ctrl_col, col_ctrl_cmd : in int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (COL_CTRL_NUM_TB - 1)); variable col_ctrl_cmd_req : in bool_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (COL_CTRL_NUM_TB - 1)); variable ref_ctrl_cmd : in int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (REF_CTRL_NUM_TB - 1)); variable ref_ctrl_cmd_req : in bool_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (REF_CTRL_NUM_TB - 1)); variable mrs_ctrl_mrs_cmd, mrs_ctrl_cmd : in int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (REF_CTRL_NUM_TB - 1)); variable mrs_ctrl_cmd_req : in bool_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (REF_CTRL_NUM_TB - 1)); variable allow_act : in bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable num_requests_rtl : out integer; variable bank_rtl, row_rtl, col_rtl, cmd_rtl, mrs_cmd_rtl, bank_exp, row_exp, col_exp, cmd_exp, mrs_cmd_exp : out int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable cmd_ack, col_ack_err, bank_ack_err, ref_ack_err, mrs_ack_err : out bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1))) is

			variable num_requests_rtl_int	: integer;
			variable num_cmd_rtl_int	: integer;

			variable priority		: integer;
			variable bank_priority		: integer;
			variable col_priority		: integer;
			variable ref_priority		: integer;
			variable mrs_priority		: integer;

			variable cmd_found		: boolean;

		begin

			num_requests_rtl_int := 0;
			num_cmd_rtl_int := 0;

			priority := 0;
			bank_priority := 0;
			col_priority := 0;
			ref_priority := 0;
			mrs_priority := 0;

			col_ack_err := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);
			bank_ack_err := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);
			ref_ack_err := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);
			mrs_ack_err := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);

			bank_rtl := reset_int_arr(0, MAX_REQUESTS_PER_TEST);
			col_rtl := reset_int_arr(0, MAX_REQUESTS_PER_TEST);
			row_rtl := reset_int_arr(0, MAX_REQUESTS_PER_TEST);
			mrs_cmd_rtl := reset_int_arr(0, MAX_REQUESTS_PER_TEST);
			cmd_rtl := reset_int_arr(to_integer(unsigned(CMD_NOP)), MAX_REQUESTS_PER_TEST);

			cmd_ack := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);

			bank_exp := reset_int_arr(0, MAX_REQUESTS_PER_TEST);
			col_exp := reset_int_arr(0, MAX_REQUESTS_PER_TEST);
			row_exp := reset_int_arr(0, MAX_REQUESTS_PER_TEST);
			mrs_cmd_exp := reset_int_arr(0, MAX_REQUESTS_PER_TEST);
			cmd_exp := reset_int_arr(to_integer(unsigned(CMD_NOP)), MAX_REQUESTS_PER_TEST);

			arb_loop: loop

				exit arb_loop when ((num_requests_rtl_int = num_requests_exp) and (num_cmd_rtl_int = num_requests_exp));

				cmd_found := false;

				if (num_requests_rtl_int < num_requests_exp) then

					for i in 0 to (BANK_CTRL_NUM_TB - 1) loop
						BankCtrlBankMem_tb((i+1)*int_to_bit_num(BANK_NUM_TB) - 1 downto i*int_to_bit_num(BANK_NUM_TB)) <= std_logic_vector(to_unsigned(bank_ctrl_bank(num_requests_rtl_int, i), int_to_bit_num(BANK_NUM_TB)));
						BankCtrlRowMem_tb((i+1)*ROW_L_TB - 1 downto i*ROW_L_TB) <= std_logic_vector(to_unsigned(bank_ctrl_row(num_requests_rtl_int, i), ROW_L_TB));
						BankCtrlCmdMem_tb((i+1)*MEM_CMD_L - 1 downto i*MEM_CMD_L) <= std_logic_vector(to_unsigned(bank_ctrl_cmd(num_requests_rtl_int, i), MEM_CMD_L));
						BankCtrlCmdReq_tb(i) <= bool_to_std_logic(bank_ctrl_cmd_req(num_requests_rtl_int, i));
					end loop;

					for i in 0 to (COL_CTRL_NUM_TB - 1) loop
						ColCtrlBankMem_tb((i+1)*int_to_bit_num(BANK_NUM_TB) - 1 downto i*int_to_bit_num(BANK_NUM_TB)) <= std_logic_vector(to_unsigned(col_ctrl_bank(num_requests_rtl_int, i), int_to_bit_num(BANK_NUM_TB)));
						ColCtrlColMem_tb((i+1)*COL_L_TB - 1 downto i*COL_L_TB) <= std_logic_vector(to_unsigned(col_ctrl_col(num_requests_rtl_int, i), COL_L_TB));
						ColCtrlCmdMem_tb((i+1)*MEM_CMD_L - 1 downto i*MEM_CMD_L) <= std_logic_vector(to_unsigned(col_ctrl_cmd(num_requests_rtl_int, i), MEM_CMD_L));
						ColCtrlCmdReq_tb(i) <= bool_to_std_logic(col_ctrl_cmd_req(num_requests_rtl_int, i));
					end loop;

					for i in 0 to (REF_CTRL_NUM_TB - 1) loop
						RefCtrlCmdMem_tb((i+1)*MEM_CMD_L - 1 downto i*MEM_CMD_L) <= std_logic_vector(to_unsigned(ref_ctrl_cmd(num_requests_rtl_int, i), MEM_CMD_L));
						RefCtrlCmdReq_tb(i) <= bool_to_std_logic(ref_ctrl_cmd_req(num_requests_rtl_int, i));
					end loop;

					for i in 0 to (REF_CTRL_NUM_TB - 1) loop
						MRSCtrlMRSCmd_tb((i+1)*ADDR_MEM_L_TB - 1 downto i*ADDR_MEM_L_TB) <= std_logic_vector(to_unsigned(mrs_ctrl_mrs_cmd(num_requests_rtl_int, i), ADDR_MEM_L_TB));
						MRSCtrlCmdMem_tb((i+1)*MEM_CMD_L - 1 downto i*MEM_CMD_L) <= std_logic_vector(to_unsigned(mrs_ctrl_cmd(num_requests_rtl_int, i), MEM_CMD_L));
						MRSCtrlCmdReq_tb(i) <= bool_to_std_logic(mrs_ctrl_cmd_req(num_requests_rtl_int, i));
					end loop;


					AllowBankActivate_tb <= bool_to_std_logic(allow_act(num_requests_rtl_int));

					num_requests_rtl_int := num_requests_rtl_int + 1;

				else

					BankCtrlBankMem_tb <= (others => '0');
					BankCtrlRowMem_tb <= (others => '0');
					BankCtrlCmdMem_tb <= (others => '0');

					BankCtrlCmdReq_tb <= (others => '0');

					ColCtrlBankMem_tb <= (others => '0');
					ColCtrlColMem_tb <= (others => '0');
					ColCtrlCmdMem_tb <= (others => '0');

					ColCtrlCmdReq_tb <= (others => '0');

					RefCtrlCmdMem_tb <= (others => '0');

					RefCtrlCmdReq_tb <= (others => '0');

					MRSCtrlMRSCmd_tb <= (others => '0');
					MRSCtrlCmdMem_tb <= (others => '0');

					MRSCtrlCmdReq_tb <= (others => '0');

					AllowBankActivate_tb <= '0';

				end if;

				wait until ((clk_tb = '0') and (clk_tb'event));

				if (num_cmd_rtl_int < num_requests_exp) then

					-- Store RTL outputs
					bank_rtl(num_cmd_rtl_int) := to_integer(unsigned(CmdDecBankMem_tb));
					col_rtl(num_cmd_rtl_int) := to_integer(unsigned(CmdDecColMem_tb));
					row_rtl(num_cmd_rtl_int) := to_integer(unsigned(CmdDecRowMem_tb));
					cmd_rtl(num_cmd_rtl_int) := to_integer(unsigned(CmdDecCmdMem_tb));
					mrs_cmd_rtl(num_cmd_rtl_int) := to_integer(unsigned(CmdDecMRSCmd_tb));

					mrs_cmd_exp(num_cmd_rtl_int) := mrs_ctrl_mrs_cmd(num_cmd_rtl_int, mrs_priority);

					-- General Priority
					if (cmd_found = false) then
						if (priority < COL_CTRL_NUM_TB) then
							if (col_ctrl_cmd_req(num_cmd_rtl_int, priority)) then
								cmd_ack(num_cmd_rtl_int) := std_logic_to_bool(ColCtrlCmdAck_tb(priority));

								bank_exp(num_cmd_rtl_int) := col_ctrl_bank(num_cmd_rtl_int, priority);
								col_exp(num_cmd_rtl_int) := col_ctrl_col(num_cmd_rtl_int, priority);
								row_exp(num_cmd_rtl_int) := 0;
								cmd_exp(num_cmd_rtl_int) := col_ctrl_cmd(num_cmd_rtl_int, priority);

								for i in 0 to (COL_CTRL_NUM_TB - 1) loop
									if (i /= priority) then
										if (ColCtrlCmdAck_tb(i) = '1') then
											col_ack_err(num_cmd_rtl_int) := true;
										end if;
									end if;
								end loop;

								if (BankCtrlCmdAck_tb /= ZERO_BANK_CTRL_ACK) then
									bank_ack_err(num_cmd_rtl_int) := true;
								end if;

								if (RefCtrlCmdAck_tb /= ZERO_REF_CTRL_ACK) then
									ref_ack_err(num_cmd_rtl_int) := true;
								end if;

								if (MRSCtrlCmdAck_tb /= ZERO_MRS_CTRL_ACK) then
									mrs_ack_err(num_cmd_rtl_int) := true;
								end if;

								cmd_found := true;
							end if;
						elsif ((priority >= COL_CTRL_NUM_TB) and (priority < (COL_CTRL_NUM_TB + BANK_CTRL_NUM_TB))) then
							if (allow_act(num_cmd_rtl_int) = true) then
								if (bank_ctrl_cmd_req(num_cmd_rtl_int, (priority - COL_CTRL_NUM_TB)) = true) then
									cmd_ack(num_cmd_rtl_int) := std_logic_to_bool(BankCtrlCmdAck_tb(priority - COL_CTRL_NUM_TB));

									bank_exp(num_cmd_rtl_int) := bank_ctrl_bank(num_cmd_rtl_int, priority - COL_CTRL_NUM_TB);
									col_exp(num_cmd_rtl_int) := 0;
									row_exp(num_cmd_rtl_int) := bank_ctrl_row(num_cmd_rtl_int, priority - COL_CTRL_NUM_TB);
									cmd_exp(num_cmd_rtl_int) := bank_ctrl_cmd(num_cmd_rtl_int, priority - COL_CTRL_NUM_TB);

									for i in 0 to (BANK_CTRL_NUM_TB - 1) loop
										if (i /= (priority - COL_CTRL_NUM_TB)) then
											if (BankCtrlCmdAck_tb(i) = '1') then
												bank_ack_err(num_cmd_rtl_int) := true;
											end if;
										end if;
									end loop;

									if (ColCtrlCmdAck_tb /= ZERO_COL_CTRL_ACK) then
										col_ack_err(num_cmd_rtl_int) := true;
									end if;

									if (RefCtrlCmdAck_tb /= ZERO_REF_CTRL_ACK) then
										ref_ack_err(num_cmd_rtl_int) := true;
									end if;

									if (MRSCtrlCmdAck_tb /= ZERO_MRS_CTRL_ACK) then
										mrs_ack_err(num_cmd_rtl_int) := true;
									end if;

									cmd_found := true;
								end if;
							end if;
						else
							bank_ack_err(num_cmd_rtl_int) := true;
							col_ack_err(num_cmd_rtl_int) := true;
							ref_ack_err(num_cmd_rtl_int) := true;
							mrs_ack_err(num_cmd_rtl_int) := true;
						end if;
					end if;

					-- Command
					if (cmd_found = false) then
						if (col_priority < COL_CTRL_NUM_TB) then
							if (col_ctrl_cmd_req(num_cmd_rtl_int, col_priority) = true) then
								cmd_ack(num_cmd_rtl_int) := std_logic_to_bool(ColCtrlCmdAck_tb(col_priority));

								bank_exp(num_cmd_rtl_int) := col_ctrl_bank(num_cmd_rtl_int, col_priority);
								col_exp(num_cmd_rtl_int) := col_ctrl_col(num_cmd_rtl_int, col_priority);
								row_exp(num_cmd_rtl_int) := 0;
								cmd_exp(num_cmd_rtl_int) := col_ctrl_cmd(num_cmd_rtl_int, col_priority);

								for i in 0 to (COL_CTRL_NUM_TB - 1) loop
									if (i /= col_priority) then
										if (ColCtrlCmdAck_tb(i) = '1') then
											col_ack_err(num_cmd_rtl_int) := true;
										end if;
									end if;
								end loop;

								if (BankCtrlCmdAck_tb /= ZERO_BANK_CTRL_ACK) then
									bank_ack_err(num_cmd_rtl_int) := true;
								end if;

								if (RefCtrlCmdAck_tb /= ZERO_REF_CTRL_ACK) then
									ref_ack_err(num_cmd_rtl_int) := true;
								end if;

								if (MRSCtrlCmdAck_tb /= ZERO_MRS_CTRL_ACK) then
									mrs_ack_err(num_cmd_rtl_int) := true;
								end if;

								cmd_found := true;
							end if;
						else
							bank_ack_err(num_cmd_rtl_int) := true;
							col_ack_err(num_cmd_rtl_int) := true;
							ref_ack_err(num_cmd_rtl_int) := true;
							mrs_ack_err(num_cmd_rtl_int) := true;
						end if;
					end if;

					-- Bank
					if (cmd_found = false) then
						if (allow_act(num_cmd_rtl_int) = true) then
							if (bank_priority < BANK_CTRL_NUM_TB) then
								if (bank_ctrl_cmd_req(num_cmd_rtl_int, bank_priority) = true) then
									cmd_ack(num_cmd_rtl_int) := std_logic_to_bool(BankCtrlCmdAck_tb(bank_priority));

									bank_exp(num_cmd_rtl_int) := bank_ctrl_bank(num_cmd_rtl_int, bank_priority);
									row_exp(num_cmd_rtl_int) := bank_ctrl_row(num_cmd_rtl_int, bank_priority);
									col_exp(num_cmd_rtl_int) := 0;
									cmd_exp(num_cmd_rtl_int) := bank_ctrl_cmd(num_cmd_rtl_int, bank_priority);

									for i in 0 to (BANK_CTRL_NUM_TB - 1) loop
										if (i /= bank_priority) then
											if (BankCtrlCmdAck_tb(i) = '1') then
												bank_ack_err(num_cmd_rtl_int) := true;
											end if;
										end if;
									end loop;

									if (ColCtrlCmdAck_tb /= ZERO_COL_CTRL_ACK) then
										col_ack_err(num_cmd_rtl_int) := true;
									end if;

									if (RefCtrlCmdAck_tb /= ZERO_REF_CTRL_ACK) then
										ref_ack_err(num_cmd_rtl_int) := true;
									end if;

									if (MRSCtrlCmdAck_tb /= ZERO_MRS_CTRL_ACK) then
										mrs_ack_err(num_cmd_rtl_int) := true;
									end if;

									cmd_found := true;
								end if;
							else
								bank_ack_err(num_cmd_rtl_int) := true;
								col_ack_err(num_cmd_rtl_int) := true;
								ref_ack_err(num_cmd_rtl_int) := true;
								mrs_ack_err(num_cmd_rtl_int) := true;
							end if;
						end if;
					end if;

					-- Refresh
					if (cmd_found = false) then
						if (ref_priority < REF_CTRL_NUM_TB) then
							if (ref_ctrl_cmd_req(num_cmd_rtl_int, ref_priority) = true) then
								cmd_ack(num_cmd_rtl_int) := std_logic_to_bool(RefCtrlCmdAck_tb(ref_priority));

								bank_exp(num_cmd_rtl_int) := 0;
								col_exp(num_cmd_rtl_int) := 0;
								row_exp(num_cmd_rtl_int) := 0;
								cmd_exp(num_cmd_rtl_int) := ref_ctrl_cmd(num_cmd_rtl_int, ref_priority);

								for i in 0 to (REF_CTRL_NUM_TB - 1) loop
									if (i /= ref_priority) then
										if (RefCtrlCmdAck_tb(i) = '1') then
											ref_ack_err(num_cmd_rtl_int) := true;
										end if;
									end if;
								end loop;

								if (ColCtrlCmdAck_tb /= ZERO_COL_CTRL_ACK) then
									col_ack_err(num_cmd_rtl_int) := true;
								end if;

								if (BankCtrlCmdAck_tb /= ZERO_BANK_CTRL_ACK) then
									bank_ack_err(num_cmd_rtl_int) := true;
								end if;

								if (MRSCtrlCmdAck_tb /= ZERO_MRS_CTRL_ACK) then
									mrs_ack_err(num_cmd_rtl_int) := true;
								end if;

								cmd_found := true;
							end if;
						else
							bank_ack_err(num_cmd_rtl_int) := true;
							col_ack_err(num_cmd_rtl_int) := true;
							ref_ack_err(num_cmd_rtl_int) := true;
							mrs_ack_err(num_cmd_rtl_int) := true;
						end if;
					end if;

					-- MRS Commandsh
					if (cmd_found = false) then
						if (mrs_priority < MRS_CTRL_NUM_TB) then
							if (mrs_ctrl_cmd_req(num_cmd_rtl_int, mrs_priority) = true) then
								cmd_ack(num_cmd_rtl_int) := std_logic_to_bool(MRSCtrlCmdAck_tb(mrs_priority));

								bank_exp(num_cmd_rtl_int) := 0;
								col_exp(num_cmd_rtl_int) := 0;
								row_exp(num_cmd_rtl_int) := 0;
								cmd_exp(num_cmd_rtl_int) := mrs_ctrl_cmd(num_cmd_rtl_int, mrs_priority);

								for i in 0 to (MRS_CTRL_NUM_TB - 1) loop
									if (i /= mrs_priority) then
										if (MRSCtrlCmdAck_tb(i) = '1') then
											mrs_ack_err(num_cmd_rtl_int) := true;
										end if;
									end if;
								end loop;

								if (ColCtrlCmdAck_tb /= ZERO_COL_CTRL_ACK) then
									col_ack_err(num_cmd_rtl_int) := true;
								end if;

								if (BankCtrlCmdAck_tb /= ZERO_BANK_CTRL_ACK) then
									bank_ack_err(num_cmd_rtl_int) := true;
								end if;

								if (RefCtrlCmdAck_tb /= ZERO_REF_CTRL_ACK) then
									ref_ack_err(num_cmd_rtl_int) := true;
								end if;

								cmd_found := true;
							end if;
						else
							bank_ack_err(num_cmd_rtl_int) := true;
							col_ack_err(num_cmd_rtl_int) := true;
							ref_ack_err(num_cmd_rtl_int) := true;
							mrs_ack_err(num_cmd_rtl_int) := true;
						end if;
					end if;

					if (priority < COL_CTRL_NUM_TB) then
						if (priority = MAX_VALUE_PRIORITY_TB) then
							priority := 0;
						else
							priority := priority + 1;
						end if;
					else
						if (allow_act(num_cmd_rtl_int) = true) then
							if (priority = MAX_VALUE_PRIORITY_TB) then
								priority := 0;
							else
								priority := priority + 1;
							end if;
						end if;
					end if;

					if (allow_act(num_cmd_rtl_int) = true) then
						if (bank_priority = (BANK_CTRL_NUM_TB - 1)) then
							bank_priority := 0;
						else
							bank_priority := bank_priority + 1;
						end if;
					end if;

					if (col_priority = (COL_CTRL_NUM_TB - 1)) then
						col_priority := 0;
					else
						col_priority := col_priority + 1;
					end if;

					if (ref_priority = (REF_CTRL_NUM_TB - 1)) then
						ref_priority := 0;
					else
						ref_priority := ref_priority + 1;
					end if;

					if (mrs_priority = (MRS_CTRL_NUM_TB - 1)) then
						mrs_priority := 0;
					else
						mrs_priority := mrs_priority + 1;
					end if;

					num_cmd_rtl_int := num_cmd_rtl_int + 1;

				end if;

				wait until ((clk_tb = '1') and (clk_tb'event));

			end loop;

			num_requests_rtl := num_requests_rtl_int;

		end procedure run_arbiter;

		procedure verify(variable num_requests_exp, num_requests_rtl : in integer; variable bank_rtl, row_rtl, col_rtl, cmd_rtl, mrs_cmd_rtl, bank_exp, row_exp, col_exp, cmd_exp, mrs_cmd_exp : in int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable cmd_ack, col_ack_err, bank_ack_err, ref_ack_err, mrs_ack_err : in bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); file file_pointer : text; variable pass: out integer) is

			variable match_bank		: boolean;
			variable match_row		: boolean;
			variable match_col		: boolean;
			variable match_cmd		: boolean;
			variable match_mrs_cmd		: boolean;
			variable match_ack		: boolean;

			variable match_col_err		: boolean;
			variable match_bank_err		: boolean;
			variable match_ref_err		: boolean;
			variable match_mrs_err		: boolean;

			variable file_line		: line;

		begin

			match_bank := compare_int_arr(bank_exp, bank_rtl, num_requests_exp);
			match_row := compare_int_arr(row_exp, row_rtl, num_requests_exp);
			match_col := compare_int_arr(col_exp, col_rtl, num_requests_exp);
			match_cmd := compare_int_arr(cmd_exp, cmd_rtl, num_requests_exp);
			match_mrs_cmd := compare_int_arr(mrs_cmd_exp, mrs_cmd_rtl, num_requests_exp);

			match_bank_err := compare_bool_arr(reset_bool_arr(false, num_requests_exp), bank_ack_err, num_requests_exp);
			match_col_err := compare_bool_arr(reset_bool_arr(false, num_requests_exp), col_ack_err, num_requests_exp);
			match_ref_err := compare_bool_arr(reset_bool_arr(false, num_requests_exp), ref_ack_err, num_requests_exp);
			match_mrs_err := compare_bool_arr(reset_bool_arr(false, num_requests_exp), mrs_ack_err, num_requests_exp);

			match_ack := true;
			for i in 0 to (num_requests_exp - 1) loop
				if ((cmd_ack(i) = false) and (cmd_exp(i) /= to_integer(unsigned(CMD_NOP)))) then
					match_ack := false;
				end if;
			end loop;

			for i in 0 to (num_requests_exp - 1) loop
				write(file_line, string'( "PHY Arbiter: Request #" & integer'image(i) & " details: Bank " & integer'image(bank_exp(i)) & " Row " & integer'image(row_exp(i)) & " Col " & integer'image(col_exp(i)) & " MRS " & integer'image(mrs_cmd_exp(i)) & " Cmd " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(cmd_exp(i), MEM_CMD_L)))));
				writeline(file_pointer, file_line);
			end loop;

			if ((match_bank = true) and (match_row = true) and (match_col = true) and (match_cmd = true)  and (match_mrs_cmd = true) and (match_ack = true) and (num_requests_exp = num_requests_rtl) and (match_bank_err = true) and (match_col_err = true) and (match_ref_err = true) and (match_mrs_err = true)) then
				write(file_line, string'( "PHY Arbiter: PASS"));
				writeline(file_pointer, file_line);
				pass := 1;
			elsif (num_requests_exp /= num_requests_rtl) then
				write(file_line, string'( "PHY Arbiter: FAIL (Number of requests mismatch): exp " & integer'image(num_requests_exp) & " rtl " & integer'image(num_requests_rtl)));
				writeline(file_pointer, file_line);
				pass := 0;
			elsif (match_bank = false) then
				write(file_line, string'( "PHY Arbiter: FAIL (Bank mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_requests_exp - 1) loop
					if (row_exp(i) /= row_rtl(i)) then
						write(file_line, string'( "PHY Arbiter: Request #" & integer'image(i) & " exp " & integer'image(bank_exp(i)) & " vs rtl " & integer'image(bank_rtl(i))));
						writeline(file_pointer, file_line);
					end if;
				end loop;
				pass := 0;
			elsif (match_row = false) then
				write(file_line, string'( "PHY Arbiter: FAIL (Row mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_requests_exp - 1) loop
					if (row_exp(i) /= row_rtl(i)) then
						write(file_line, string'( "PHY Arbiter: Request #" & integer'image(i) & " exp " & integer'image(row_exp(i)) & " vs rtl " & integer'image(row_rtl(i))));
						writeline(file_pointer, file_line);
					end if;
				end loop;
				pass := 0;
			elsif (match_mrs_cmd = false) then
				write(file_line, string'( "PHY Arbiter: FAIL (MRS Command mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_requests_exp - 1) loop
					if (mrs_cmd_exp(i) /= mrs_cmd_rtl(i)) then
						write(file_line, string'( "PHY Arbiter: Request #" & integer'image(i) & " exp " & integer'image(mrs_cmd_exp(i)) & " vs rtl " & integer'image(mrs_cmd_rtl(i))));
						writeline(file_pointer, file_line);
					end if;
				end loop;
				pass := 0;
			elsif (match_col = false) then
				write(file_line, string'( "PHY Arbiter: FAIL (Column mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_requests_exp - 1) loop
					if (col_exp(i) /= col_rtl(i)) then
						write(file_line, string'( "PHY Arbiter: Request #" & integer'image(i) & " exp " & integer'image(col_exp(i)) & " vs rtl " & integer'image(col_rtl(i))));
						writeline(file_pointer, file_line);
					end if;
				end loop;
				pass := 0;
			elsif (match_cmd = false) then
				write(file_line, string'( "PHY Arbiter: FAIL (Command mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_requests_exp - 1) loop
					if (cmd_exp(i) /= cmd_rtl(i)) then
						write(file_line, string'( "PHY Arbiter: Request #" & integer'image(i) & " exp " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(cmd_exp(i), MEM_CMD_L))) & " vs rtl " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(cmd_rtl(i), MEM_CMD_L)))));
						writeline(file_pointer, file_line);
					end if;
				end loop;
				pass := 0;
			elsif (match_bank_err = false) then
				write(file_line, string'( "PHY Arbiter: FAIL (Bank Controller Error)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_requests_exp - 1) loop
					if (bank_ack_err(i) = true) then
						write(file_line, string'( "PHY Arbiter: Error Request #" & integer'image(i) & ": " & bool_to_str(bank_ack_err(i))));
						writeline(file_pointer, file_line);
					end if;
				end loop;
				pass := 0;
			elsif (match_col_err = false) then
				write(file_line, string'( "PHY Arbiter: FAIL (Column Controller Error)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_requests_exp - 1) loop
					if (bank_ack_err(i) = true) then
						write(file_line, string'( "PHY Arbiter: Error Request #" & integer'image(i) & ": " & bool_to_str(col_ack_err(i))));
						writeline(file_pointer, file_line);
					end if;
				end loop;
				pass := 0;
			elsif (match_ref_err = false) then
				write(file_line, string'( "PHY Arbiter: FAIL (Refresh Controller Error)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_requests_exp - 1) loop
					if (ref_ack_err(i) = true) then
						write(file_line, string'( "PHY Arbiter: Error Request #" & integer'image(i) & ": " & bool_to_str(ref_ack_err(i))));
						writeline(file_pointer, file_line);
					end if;
				end loop;
				pass := 0;
			elsif (match_mrs_err = false) then
				write(file_line, string'( "PHY Arbiter: FAIL (MRS Controller Error)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_requests_exp - 1) loop
					if (mrs_ack_err(i) = true) then
						write(file_line, string'( "PHY Arbiter: Error Request #" & integer'image(i) & ": " & bool_to_str(mrs_ack_err(i))));
						writeline(file_pointer, file_line);
					end if;
				end loop;
				pass := 0;
			elsif (match_ack = false) then
				write(file_line, string'( "PHY Arbiter: FAIL (Handshake Error)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_requests_exp - 1) loop
					if ((cmd_ack(i) = false) and (cmd_exp(i) /= to_integer(unsigned(CMD_NOP)))) then
						write(file_line, string'( "PHY Arbiter: Request #" & integer'image(i) & " Command Ack " & bool_to_str(cmd_ack(i)) & " Cmd exp " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(cmd_exp(i), MEM_CMD_L))) & " vs rtl " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(cmd_rtl(i), MEM_CMD_L)))));
						writeline(file_pointer, file_line);
					end if;
				end loop;
				pass := 0;
			else
				write(file_line, string'( "PHY Arbiter: FAIL (Unknown error)"));
				writeline(file_pointer, file_line);
				pass := 0;
			end if;
		end procedure verify;

		variable seed1, seed2	: positive;

		variable num_requests_exp	: integer;
		variable num_requests_rtl	: integer;

		variable bank_ctrl_cmd		: int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (BANK_CTRL_NUM_TB - 1));
		variable bank_ctrl_row		: int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (BANK_CTRL_NUM_TB - 1));
		variable bank_ctrl_bank		: int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (BANK_CTRL_NUM_TB - 1));

		variable bank_ctrl_cmd_req	: bool_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (BANK_CTRL_NUM_TB - 1));

		variable col_ctrl_cmd		: int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (COL_CTRL_NUM_TB - 1));
		variable col_ctrl_col		: int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (COL_CTRL_NUM_TB - 1));
		variable col_ctrl_bank		: int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (COL_CTRL_NUM_TB - 1));

		variable col_ctrl_cmd_req	: bool_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (COL_CTRL_NUM_TB - 1));

		variable ref_ctrl_cmd		: int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (REF_CTRL_NUM_TB - 1));

		variable ref_ctrl_cmd_req	: bool_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (REF_CTRL_NUM_TB - 1));

		variable mrs_ctrl_mrs_cmd	: int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (REF_CTRL_NUM_TB - 1));
		variable mrs_ctrl_cmd		: int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (REF_CTRL_NUM_TB - 1));

		variable mrs_ctrl_cmd_req	: bool_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (REF_CTRL_NUM_TB - 1));

		variable allow_act		: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));

		variable bank_rtl		:int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable row_rtl		:int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable col_rtl		:int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable cmd_rtl		:int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable mrs_cmd_rtl		:int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));

		variable bank_exp		:int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable row_exp		:int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable col_exp		:int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable cmd_exp		:int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable mrs_cmd_exp		:int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));

		variable cmd_ack		: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));

		variable col_ack_err		: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable bank_ack_err		: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable ref_ack_err		: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable mrs_ack_err		: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));

		variable pass		: integer;
		variable num_pass	: integer;

		file file_pointer	: text;
		variable file_line	: line;


	begin

		wait for 1 ns;

		num_pass := 0;

		file_open(file_pointer, ddr2_phy_arbiter_log_file, append_mode);

		write(file_line, string'( "PHY Arbiter Test"));
		writeline(file_pointer, file_line);

		for i in 0 to NUM_TESTS-1 loop

			reset;

			test_param(num_requests_exp, bank_ctrl_bank, bank_ctrl_row, bank_ctrl_cmd, bank_ctrl_cmd_req, col_ctrl_bank, col_ctrl_col, col_ctrl_cmd, col_ctrl_cmd_req, ref_ctrl_cmd, ref_ctrl_cmd_req, mrs_ctrl_mrs_cmd, mrs_ctrl_cmd, mrs_ctrl_cmd_req, allow_act, seed1, seed2);

			run_arbiter(num_requests_exp, bank_ctrl_bank, bank_ctrl_row, bank_ctrl_cmd, bank_ctrl_cmd_req, col_ctrl_bank, col_ctrl_col, col_ctrl_cmd, col_ctrl_cmd_req, ref_ctrl_cmd, ref_ctrl_cmd_req, mrs_ctrl_mrs_cmd, mrs_ctrl_cmd, mrs_ctrl_cmd_req, allow_act, num_requests_rtl, bank_rtl, row_rtl, col_rtl, cmd_rtl, mrs_cmd_rtl, bank_exp, row_exp, col_exp, cmd_exp, mrs_cmd_exp,  cmd_ack, col_ack_err, bank_ack_err, ref_ack_err, mrs_ack_err);

			verify(num_requests_exp, num_requests_rtl, bank_rtl, row_rtl, col_rtl, cmd_rtl, mrs_cmd_rtl, bank_exp, row_exp, col_exp, cmd_exp, mrs_cmd_exp,  cmd_ack, col_ack_err, bank_ack_err, ref_ack_err, mrs_ack_err, file_pointer, pass);

			num_pass := num_pass + pass;

			wait until ((clk_tb'event) and (clk_tb = '1'));

		end loop;

		file_close(file_pointer);

		file_open(file_pointer, summary_file, append_mode);
		write(file_line, string'( "PHY Arbiter Controller => PASSES: " & integer'image(num_pass) & " out of " & integer'image(TOT_NUM_TESTS)));
		writeline(file_pointer, file_line);

		if (num_pass = TOT_NUM_TESTS) then
			write(file_line, string'( "PHY Arbiter Controller: TEST PASSED"));
		else
			write(file_line, string'( "PHY Arbiter Controller: TEST FAILED: " & integer'image(TOT_NUM_TESTS-num_pass) & " failures"));
		end if;
		writeline(file_pointer, file_line);

		file_close(file_pointer);
		stop <= true;

	end process test;

end bench;
