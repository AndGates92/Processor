library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;
use work.proc_pkg.all;
use work.ddr2_define_pkg.all;
use work.ddr2_phy_pkg.all;
use work.ddr2_phy_bank_ctrl_pkg.all;
use work.tb_pkg.all;
use work.ddr2_pkg_tb.all;

entity ddr2_phy_bank_ctrl_tb is
end entity ddr2_phy_bank_ctrl_tb;

architecture bench of ddr2_phy_bank_ctrl_tb is

	constant CLK_PERIOD	: time := DDR2_CLK_PERIOD * 1 ns;
	constant NUM_TEST	: integer := 1000;
	constant TOT_NUM_TEST	: integer := NUM_TEST;

	constant MAX_REQUESTS_PER_TEST		: integer := 50;

	constant ZERO_BANK_CTRL_ACK	: std_logic_vector(BANK_CTRL_NUM_TB - 1 downto 0) := (others => '0');
	constant ZERO_COL_CTRL_ACK	: std_logic_vector(COL_CTRL_NUM_TB - 1 downto 0) := (others => '0');
	constant ZERO_REF_CTRL_ACK	: std_logic_vector(REF_CTRL_NUM_TB - 1 downto 0) := (others => '0');

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

	-- Arbitrer Controller
	signal AllowBankActivate_tb	: std_logic;

	signal BankActOut_tb		: std_logic;

	-- Command Decoder
	signal CmdDecColMem_tb		: std_logic_vector(COL_L_TB - 1 downto 0);
	signal CmdDecRowMem_tb		: std_logic_vector(ROW_L_TB - 1 downto 0);
	signal CmdDecBankMem_tb		: std_logic_vector(int_to_bit_num(BANK_NUM_TB) - 1 downto 0);
	signal CmdDecCmdMem_tb		: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal CmdDecMRSCmd_tb		: std_logic_vector(ADDR_L_TB - 1 downto 0);

begin

	DUT: ddr2_phy_bank_ctrl generic map (
		ROW_L => ROW_L_TB,
		COL_L => COL_L_TB,
		ADDR_L => ADDR_L_TB,
		BANK_NUM => BANK_NUM_TB,
		BANK_CTRL_NUM => BANK_CTRL_NUM_TB,
		COL_CTRL_NUM => COL_CTRL_NUM_TB,
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

		-- Arbitrer Controller
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
			rst_tb <= '0';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_tb <= '1';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_tb <= '0';
		end procedure reset;

		procedure test_param(variable num_requests : out integer; variable bank_ctrl_bank, bank_ctrl_row, bank_ctrl_cmd : out int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (BANK_CTRL_NUM_TB - 1)); variable bank_ctrl_cmd_req : out bool_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (BANK_CTRL_NUM_TB - 1)); variable col_ctrl_bank, col_ctrl_col, col_ctrl_cmd : out int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (COL_CTRL_NUM_TB - 1)); variable col_ctrl_cmd_req : out bool_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (COL_CTRL_NUM_TB - 1)); variable ref_ctrl_cmd : out int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (REF_CTRL_NUM_TB - 1)); variable ref_ctrl_cmd_req : out bool_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (REF_CTRL_NUM_TB - 1)); variable allow_act : out bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1))) is
			variable rand_val		: real;
			variable num_requests_int	: integer;
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
					bank_ctrl_row(i, j) := integer(rand_val*real(2.0**(real(ROW_L_TB))));
					bank_ctrl_cmd(i, j) := to_integer(unsigned(CMD_BANK_ACT));
					uniform(seed1, seed2, rand_val);
					bank_ctrl_cmd_req(i, j) := rand_bool(rand_val, 0.5);
				end loop;

				for j in 0 to (COL_CTRL_NUM_TB - 1) loop
					uniform(seed1, seed2, rand_val);
					col_ctrl_bank(i, j) := integer(rand_val*real(BANK_NUM_TB - 1));
					uniform(seed1, seed2, rand_val);
					col_ctrl_col(i, j) := integer(rand_val*real(2.0**(real(COL_L_TB))));
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

				uniform(seed1, seed2, rand_val);
				allow_act(i) := rand_bool(rand_val, 0.5);

			end loop;

		end procedure test_param;

		procedure run_arbitrer(variable num_requests_exp : in integer; variable bank_ctrl_bank, bank_ctrl_row, bank_ctrl_cmd : in int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (BANK_CTRL_NUM_TB - 1)); variable bank_ctrl_cmd_req : in bool_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (BANK_CTRL_NUM_TB - 1)); variable col_ctrl_bank, col_ctrl_col, col_ctrl_cmd : in int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (COL_CTRL_NUM_TB - 1)); variable col_ctrl_cmd_req : in bool_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (COL_CTRL_NUM_TB - 1)); variable ref_ctrl_cmd : in int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (REF_CTRL_NUM_TB - 1)); variable ref_ctrl_cmd_req : in bool_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (REF_CTRL_NUM_TB - 1)); variable allow_act : in bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable num_requests_rtl : out integer; variable bank_rtl, row_rtl, col_rtl, cmd_rtl, bank_exp, row_exp, col_exp, cmd_exp : out int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable cmd_ack, col_arr_err, bank_arr_err, ref_arr_err : out bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1))) is

			variable num_requests_rtl_int	: integer;
			variable num_cmd_rtl_int	: integer;

			variable priority		: integer;
			variable bank_priority		: integer;
			variable col_priority		: integer;
			variable ref_priority		: integer;

			variable cmd_found		: boolean;

		begin

			num_requests_rtl_int := 0;
			num_cmd_rtl_int := 0;

			priority := 0;
			bank_priority := 0;
			col_priority := 0;
			ref_priority := 0;

			col_arr_err := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);
			bank_arr_err := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);
			ref_arr_err := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);

			bank_rtl := reset_int_arr(0, MAX_REQUESTS_PER_TEST);
			col_rtl := reset_int_arr(0, MAX_REQUESTS_PER_TEST);
			row_rtl := reset_int_arr(0, MAX_REQUESTS_PER_TEST);
			cmd_rtl := reset_int_arr(to_integer(unsigned(CMD_NOP)), MAX_REQUESTS_PER_TEST);

			cmd_ack := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);

			bank_exp := reset_int_arr(0, MAX_REQUESTS_PER_TEST);
			col_exp := reset_int_arr(0, MAX_REQUESTS_PER_TEST);
			row_exp := reset_int_arr(0, MAX_REQUESTS_PER_TEST);
			cmd_exp := reset_int_arr(to_integer(unsigned(CMD_NOP)), MAX_REQUESTS_PER_TEST);

			arb_loop: loop

				wait until ((clk_tb = '1') and (clk_tb'event));

				exit arb_loop when ((num_requests_rtl_int = num_requests_exp) and (num_cmd_rtl_int = num_requests_exp));

				cmd_found := false;

				if (num_requests_rtl_int < num_requests_exp) then

					for i in 0 to (BANK_CTRL_NUM_TB - 1) loop
						BankCtrlBankMem_tb((i+1)*int_to_bit_num(BANK_NUM_TB) - 1 downto i*int_to_bit_num(BANK_NUM_TB)) <= bank_ctrl_bank(num_requests_rtl_int, i);
						BankCtrlRowMem_tb((i+1)*ROW_L_TB - 1 downto i*ROW_L_TB) <= bank_ctrl_row(num_requests_rtl_int, i);
						BankCtrlCmdMem_tb((i+1)*MEM_CMD_L - 1 downto i*MEM_CMD_L) <= bank_ctrl_cmd(num_requests_rtl_int, i);
						BankCtrlCmdMReq_tb(i) <= bool_to_std_logic(bank_ctrl_cmd_req(num_requests_rtl_int, i));
					end loop;

					for i in 0 to (COL_CTRL_NUM_TB - 1) loop
						ColCtrlBankMem_tb((i+1)*int_to_bit_num(BANK_NUM_TB) - 1 downto i*int_to_bit_num(BANK_NUM_TB)) <= col_ctrl_bank(num_requests_rtl_int, i);
						ColCtrlColMem_tb((i+1)*COL_L_TB - 1 downto i*COL_L_TB) <= col_ctrl_col(num_requests_rtl_int, i);
						ColCtrlCmdMem_tb((i+1)*MEM_CMD_L - 1 downto i*MEM_CMD_L) <= col_ctrl_cmd(num_requests_rtl_int, i);
						ColCtrlCmdMReq_tb(i) <= bool_to_std_logic(col_ctrl_cmd_req(num_requests_rtl_int, i));
					end loop;

					for i in 0 to (REF_CTRL_NUM_TB - 1) loop
						RefCtrlCmdMem_tb((i+1)*MEM_CMD_L - 1 downto i*MEM_CMD_L) <= ref_ctrl_cmd(num_requests_rtl_int, i);
						RefCtrlCmdReq_tb(i) <= bool_to_std_logic(ref_ctrl_cmd_req(num_requests_rtl_int, i));
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

					AllowBankActivate_tb <= '0';

				end if;

				wait for ((DDR2_CLK_PERIOD/2) * 1 ns);

				if (num_cmd_rtl_int < num_requests_exp) then

					-- General Priority
					if (cmd_found = false) then
						if (priority < COL_CTRL_NUM_TB) then
							if (col_ctrl_cmd_req(num_cmd_rtl_int, priority)) then
								bank_rtl(num_cmd_rtl_int) := to_integer(unsigned(CmdDecBankMem_tb));
								col_rtl(num_cmd_rtl_int) := to_integer(unsigned(CmdDecColMem_tb));
								row_rtl(num_cmd_rtl_int) := to_integer(unsigned(CmdDecRowMem_tb));
								cmd_rtl(num_cmd_rtl_int) := to_integer(unsigned(CmdDecCmdMem_tb));
								cmd_ack(num_cmd_rtl_int) := std_logic_to_bool(ColCtrlCmdAck_tb(priority));

								bank_exp(num_cmd_rtl_int) := col_ctrl_bank(num_requests_rtl_int, priority);
								col_exp(num_cmd_rtl_int) := col_ctrl_col(num_requests_rtl_int, priority);
								row_exp(num_cmd_rtl_int) := 0;
								cmd_exp(num_cmd_rtl_int) := col_ctrl_cmd(num_requests_rtl_int, priority);

								for i in 0 to (COL_CTRL_NUM_TB - 1) loop
									if (i /= priority) then
										col_ack_err(num_cmd_rtl_int) := true;
									end if;
								end loop;

								if (BankCtrlCmdAck_tb /= ZERO_BANK_CTRL_ACK) then
									bank_ack_arr(num_cmd_rtl_int) := true;
								end if;

								if (RefCtrlCmdAck_tb /= ZERO_REF_CTRL_ACK) then
									ref_ack_arr(num_cmd_rtl_int) := true;
								end if;

								cmd_found := true;
							end if;
						elsif ((priority >= COL_CTRL_NUM_TB) and (priority < BANK_CTRL_NUM_TB)) then
							if (allow_act(num_cmd_rtl_int) = true) then
								if (bank_ctrl_cmd_req(num_cmd_rtl_int, (priority - COL_CTRL_NUM_TB))) then
									bank_rtl(num_cmd_rtl_int) := to_integer(unsigned(CmdDecBankMem_tb));
									col_rtl(num_cmd_rtl_int) := to_integer(unsigned(CmdDecColMem_tb));
									row_rtl(num_cmd_rtl_int) := to_integer(unsigned(CmdDecRowMem_tb));
									cmd_rtl(num_cmd_rtl_int) := to_integer(unsigned(CmdDecCmdMem_tb));
									cmd_ack(num_cmd_rtl_int) := std_logic_to_bool(ColCtrlCmdAck_tb(priority));

									bank_exp(num_cmd_rtl_int) := bank_ctrl_bank(num_requests_rtl_int, priority);
									col_exp(num_cmd_rtl_int) := 0;
									row_exp(num_cmd_rtl_int) := bank_ctrl_col(num_requests_rtl_int, priority);
									cmd_exp(num_cmd_rtl_int) := bank_ctrl_cmd(num_requests_rtl_int, priority);


									for i in 0 to (BANK_CTRL_NUM_TB - 1) loop
										if (i /= (priority - COL_CTRL_NUM_TB)) then
											bank_ack_err(num_cmd_rtl_int) := true;
										end if;
									end loop;

									if (ColCtrlCmdAck_tb /= ZERO_COL_CTRL_ACK) then
										col_ack_arr(num_cmd_rtl_int) := true;
									end if;

									if (RefCtrlCmdAck_tb /= ZERO_REF_CTRL_ACK) then
										ref_ack_arr(num_cmd_rtl_int) := true;
									end if;

									cmd_found := true;
								end if;
							end if;
						else
							bank_ack_arr(num_cmd_rtl_int) := true;
							col_ack_arr(num_cmd_rtl_int) := true;
							ref_ack_arr(num_cmd_rtl_int) := true;
						end if;
					end if;

					-- Command
					if (cmd_found = false) then
						if (col_priority < COL_CTRL_NUM_TB) then
							if (col_ctrl_cmd_req(num_cmd_rtl_int, col_priority)) then
								bank_rtl(num_cmd_rtl_int) := to_integer(unsigned(CmdDecBankMem_tb));
								col_rtl(num_cmd_rtl_int) := to_integer(unsigned(CmdDecColMem_tb));
								row_rtl(num_cmd_rtl_int) := to_integer(unsigned(CmdDecRowMem_tb));
								cmd_rtl(num_cmd_rtl_int) := to_integer(unsigned(CmdDecCmdMem_tb));
								cmd_ack(num_cmd_rtl_int) := std_logic_to_bool(ColCtrlCmdAck_tb(col_priority));

								bank_exp(num_cmd_rtl_int) := col_ctrl_bank(num_requests_rtl_int, col_priority);
								col_exp(num_cmd_rtl_int) := col_ctrl_col(num_requests_rtl_int, col_priority);
								row_exp(num_cmd_rtl_int) := 0;
								cmd_exp(num_cmd_rtl_int) := col_ctrl_cmd(num_requests_rtl_int, col_priority);

								for i in 0 to (COL_CTRL_NUM_TB - 1) loop
									if (i /= col_priority) then
										col_ack_err(num_cmd_rtl_int) := true;
									end if;
								end loop;

								if (BankCtrlCmdAck_tb /= ZERO_BANK_CTRL_ACK) then
									bank_ack_arr(num_cmd_rtl_int) := true;
								end if;

								if (RefCtrlCmdAck_tb /= ZERO_REF_CTRL_ACK) then
									ref_ack_arr(num_cmd_rtl_int) := true;
								end if;

								cmd_found := true;
							end if;
						else
							bank_ack_arr(num_cmd_rtl_int) := true;
							col_ack_arr(num_cmd_rtl_int) := true;
							ref_ack_arr(num_cmd_rtl_int) := true;
						end if;
					end if;

					-- Bank
					if (cmd_found = false) then
						if (allow_act(num_cmd_rtl_int) = true) then
							if (bank_priority < BANK_CTRL_NUM_TB) then
								if (col_ctrl_cmd_req(num_cmd_rtl_int, bank_priority)) then
									bank_rtl(num_cmd_rtl_int) := to_integer(unsigned(CmdDecBankMem_tb));
									col_rtl(num_cmd_rtl_int) := to_integer(unsigned(CmdDecColMem_tb));
									row_rtl(num_cmd_rtl_int) := to_integer(unsigned(CmdDecRowMem_tb));
									cmd_rtl(num_cmd_rtl_int) := to_integer(unsigned(CmdDecCmdMem_tb));
									cmd_ack(num_cmd_rtl_int) := std_logic_to_bool(ColCtrlCmdAck_tb(bank_priority));

									bank_exp(num_cmd_rtl_int) := col_ctrl_bank(num_requests_rtl_int, bank_priority);
									col_exp(num_cmd_rtl_int) := col_ctrl_col(num_requests_rtl_int, bank_priority);
									row_exp(num_cmd_rtl_int) := 0;
									cmd_exp(num_cmd_rtl_int) := col_ctrl_cmd(num_requests_rtl_int, bank_priority);

									for i in 0 to (BANK_CTRL_NUM_TB - 1) loop
										if (i /= bank_priority) then
											bank_ack_err(num_cmd_rtl_int) := true;
										end if;
									end loop;

									if (ColCtrlCmdAck_tb /= ZERO_COL_CTRL_ACK) then
										col_ack_arr(num_cmd_rtl_int) := true;
									end if;

									if (RefCtrlCmdAck_tb /= ZERO_REF_CTRL_ACK) then
										ref_ack_arr(num_cmd_rtl_int) := true;
									end if;

									cmd_found := true;
								end if;
							else
								bank_ack_arr(num_cmd_rtl_int) := true;
								col_ack_arr(num_cmd_rtl_int) := true;
								ref_ack_arr(num_cmd_rtl_int) := true;
							end if;
						end if;
					end if;

					-- Refresh
					if (cmd_found = false) then
						if (ref_priority < BANK_CTRL_NUM_TB) then
							if (ref_ctrl_cmd_req(num_cmd_rtl_int, bank_priority)) then
								bank_rtl(num_cmd_rtl_int) := to_integer(unsigned(CmdDecBankMem_tb));
								col_rtl(num_cmd_rtl_int) := to_integer(unsigned(CmdDecColMem_tb));
								row_rtl(num_cmd_rtl_int) := to_integer(unsigned(CmdDecRowMem_tb));
								cmd_rtl(num_cmd_rtl_int) := to_integer(unsigned(CmdDecCmdMem_tb));
								cmd_ack(num_cmd_rtl_int) := std_logic_to_bool(ColCtrlCmdAck_tb(ref_priority));

								bank_exp(num_cmd_rtl_int) := ref_ctrl_bank(num_requests_rtl_int, ref_priority);
								col_exp(num_cmd_rtl_int) := 0;
								row_exp(num_cmd_rtl_int) := 0;
								cmd_exp(num_cmd_rtl_int) := ref_ctrl_cmd(num_requests_rtl_int, ref_priority);

								for i in 0 to (REF_CTRL_NUM_TB - 1) loop
									if (i /= ref_priority) then
										ref_ack_err(num_cmd_rtl_int) := true;
									end if;
								end loop;

								if (ColCtrlCmdAck_tb /= ZERO_COL_CTRL_ACK) then
									col_ack_arr(num_cmd_rtl_int) := true;
								end if;

								if (BankCtrlCmdAck_tb /= ZERO_BANK_CTRL_ACK) then
									ref_ack_arr(num_cmd_rtl_int) := true;
								end if;

								cmd_found := true;
							end if;
						else
							bank_ack_arr(num_cmd_rtl_int) := true;
							col_ack_arr(num_cmd_rtl_int) := true;
							ref_ack_arr(num_cmd_rtl_int) := true;
						end if;
					end if;


					if (priority < COL_CTRL_NUM_TB) then
						if (priority = MAX_VALUE_PRIORITY_TB) then
							priority := 0;
						else
							priority := priority + 1;
						end if;
					else
						if (allow_act(num_cmd_rtl_int) = true)
							if (priority = MAX_VALUE_PRIORITY_TB) then
								priority := 0;
							else
								priority := priority + 1;
							end if;
						end if;
					end if;

					if (allow_act(num_cmd_rtl_int) = true)
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

					num_cmd_rtl_int := num_cmd_rtl_int + 1;

				end if;
			end loop;

			num_requests_rtl := num_requests_rtl_int;

		end procedure run_arbitrer;

		procedure verify(variable num_requests_exp, num_requests_rtl : in integer; variable bank_rtl, row_rtl, col_rtl, cmd_rtl, bank_exp, row_exp, col_exp, cmd_exp : in int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable cmd_ack, col_arr_err, bank_arr_err, ref_arr_err : in bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); file file_pointer : text; variable pass: out integer) is

			variable match_bank		: boolean;
			variable match_row		: boolean;
			variable match_col		: boolean;
			variable match_cmd		: boolean;
			variable match_ack		: boolean;
			variable file_line		: line;

		begin

			match_bank := compare_int_arr(bank_exp, bank_rtl, num_requests_exp);
			match_row := compare_int_arr(row_exp, row_rtl, num_requests_exp);
			match_col := compare_int_arr(col_exp, col_rtl, num_requests_exp);
			match_cmd := compare_int_arr(cmd_exp, cmd_rtl, num_requests_exp);

			match_ack := false;
			for i in 0 to (num_requests_exp - 1) loop
				if ((cmd_ack = false) and (cmd_exp /= to_integer(unsigned(CMD_NOP)))) then
					match_ack := true;
				end if;
			end loop;

		end procedure verify;

		variable seed1, seed2	: positive;

		variable num_requests_exp	: integer;
		variable num_requests_rtl	: integer;

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

		variable allow_act		: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));

		variable bank_rtl		:int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable row_rtl		:int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable col_rtl		:int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable cmd_rtl		:int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));

		variable bank_exp		:int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable row_exp		:int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable col_exp		:int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable cmd_exp		:int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));

		variable cmd_ack		: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));

		variable col_arr_err		: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable bank_arr_err		: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable ref_arr_err		: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));

		variable pass		: integer;
		variable num_pass	: integer;

		file file_pointer	: text;
		variable file_line	: line;


	begin

		wait for 1 ns;

		num_pass := 0;

		reset;
		file_open(file_pointer, ddr2_phy_arbitrer_log_file, append_mode);

		write(file_line, string'( "PHY Arbitrer Test"));
		writeline(file_pointer, file_line);

		for i in 0 to NUM_TESTS-1 loop

			test_param(num_requests, bank_ctrl_bank, bank_ctrl_row, bank_ctrl_cmd, bank_ctrl_cmd_req, col_ctrl_bank, col_ctrl_col, col_ctrl_cmd, col_ctrl_cmd_req, ref_ctrl_cmd, ref_ctrl_cmd_req, allow_act);

			run_arbitrer(num_requests_exp, bank_ctrl_bank, bank_ctrl_row, bank_ctrl_cmd, bank_ctrl_cmd_req, col_ctrl_bank, col_ctrl_col, col_ctrl_cmd, col_ctrl_cmd_req, ref_ctrl_cmd, ref_ctrl_cmd_req, allow_act, num_requests_rtl, bank_rtl, row_rtl, col_rtl, cmd_rtl, bank_exp, row_exp, col_exp, cmd_exp, cmd_ack, col_arr_err, bank_arr_err, ref_arr_err);

			verify(num_requests_exp, num_requests_rtl, bank_rtl, row_rtl, col_rtl, cmd_rtl, bank_exp, row_exp, col_exp, cmd_exp, cmd_ack, col_arr_err, bank_arr_err, ref_arr_err, file_pointer, pass);

			num_pass := num_pass + pass;

			wait until ((clk_tb'event) and (clk_tb = '1'));

		end loop;

		file_close(file_pointer);

		file_open(file_pointer, summary_file, append_mode);
		write(file_line, string'( "PHY Arbitrer Controller => PASSES: " & integer'image(num_pass) & " out of " & integer'image(TOT_NUM_TESTS)));
		writeline(file_pointer, file_line);

		if (num_pass = TOT_NUM_TESTS) then
			write(file_line, string'( "PHY Arbitrer Controller: TEST PASSED"));
		else
			write(file_line, string'( "PHY Arbitrer Controller: TEST FAILED: " & integer'image(TOT_NUM_TESTS-num_pass) & " failures"));
		end if;
		writeline(file_pointer, file_line);

		file_close(file_pointer);
		stop <= true;

	end process test;





end bench;
