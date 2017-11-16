library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;
library common_rtl_pkg;
use common_rtl_pkg.type_conversion_pkg.all;
library common_tb_pkg;
use common_tb_pkg.functions_pkg_tb.all;
use common_tb_pkg.shared_pkg_tb.all;
library ddr2_rtl_pkg;
use ddr2_rtl_pkg.ddr2_define_pkg.all;
use ddr2_rtl_pkg.ddr2_ctrl_pkg.all;
use ddr2_rtl_pkg.ddr2_ctrl_odt_ctrl_pkg.all;
library ddr2_tb_pkg;
use ddr2_tb_pkg.ddr2_pkg_tb.all;
use ddr2_tb_pkg.ddr2_log_pkg.all;

entity ddr2_ctrl_odt_ctrl_tb is
end entity ddr2_ctrl_odt_ctrl_tb;

architecture bench of ddr2_ctrl_odt_ctrl_tb is

	constant CLK_PERIOD	: time := DDR2_CLK_PERIOD * 1 ns;
	constant NUM_TESTS	: integer := 10000;
	constant TOT_NUM_TESTS	: integer := NUM_TESTS;

	constant MAX_REQUESTS_PER_TEST	: integer := 500;
	constant MAX_BURST_DELAY	: integer := 20;

	signal clk_tb	: std_logic := '0';
	signal stop	: boolean := false;
	signal rst_tb	: std_logic;

	-- Command sent to memory
	signal Cmd_tb	: std_logic_vector(MEM_CMD_L - 1 downto 0);

	signal NoBankColCmd_tb	: std_logic;

	-- MRS Controller
	signal MRSCmdAccepted_tb	: std_logic;
	signal MRSCtrlReq_tb		: std_logic;
	signal MRSCmd_tb		: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal MRSUpdateCompleted_tb	: std_logic;

	signal MRSCtrlAck_tb		: std_logic;

	-- Refresh Controller
	signal RefCmdAccepted_tb	: std_logic;
	signal RefCtrlReq_tb		: std_logic;
	signal RefCmd_tb		: std_logic_vector(MEM_CMD_L - 1 downto 0);

	signal RefCtrlAck_tb		: std_logic;

	-- Stop Arbiter
	signal PauseArbiter_tb	: std_logic;

	-- ODT
	signal ODT_tb	: std_logic;

begin

	DUT: ddr2_ctrl_odt_ctrl -- generic map (

--	)
	port map (
		clk => clk_tb,
		rst => rst_tb,

		-- Command sent to memory
		Cmd => Cmd_tb,

		NoBankColCmd => NoBankColCmd_tb,

		-- MRS Controller
		MRSCmdAccepted => MRSCmdAccepted_tb,
		MRSCtrlReq => MRSCtrlReq_tb,
		MRSCmd => MRSCmd_tb,
		MRSUpdateCompleted => MRSUpdateCompleted_tb,

		MRSCtrlAck => MRSCtrlAck_tb,

		-- Refresh Controller
		RefCmdAccepted => RefCmdAccepted_tb,
		RefCtrlReq => RefCtrlReq_tb,
		RefCmd => RefCmd_tb,

		RefCtrlAck => RefCtrlAck_tb,

		-- Stop Arbiter
		PauseArbiter => PauseArbiter_tb,

		-- ODT
		ODT => ODT_tb

	);

	clk_gen(CLK_PERIOD, 0 ns, stop, clk_tb);

	test: process

		procedure reset is
		begin
			-- Command sent to memory
			Cmd_tb <= CMD_NOP;

			NoBankColCmd_tb <= '0';

			-- MRS Controller
			MRSCmdAccepted_tb <= '0';
			MRSCtrlReq_tb <= '0';
			MRSUpdateCompleted_tb <= '0';
			MRSCmd_tb <= (others => '0');

			-- Refresh Controller
			RefCmdAccepted_tb <= '0';
			RefCtrlReq_tb <= '0';
			RefCmd_tb <= (others => '0');

			rst_tb <= '0';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_tb <= '1';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_tb <= '0';
		end procedure reset;

		procedure test_param(variable num_requests : out integer; variable mrs_mem_cmd, mem_cmd, req_delay, delay_after_turn_off: out int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable mrs_ctrl_req, ref_ctrl_req, toggle_other_req, valid_mrs_ref: out bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable seed1, seed2: inout positive) is
			variable rand_val	: real;
			variable num_requests_int	: integer;
			variable mrs_cmd_id		: integer;
		begin
			num_requests_int := 0;
			while (num_requests_int = 0) loop
				uniform(seed1, seed2, rand_val);
				num_requests_int := integer(rand_val*real(MAX_REQUESTS_PER_TEST));
			end loop;
			num_requests := num_requests_int;

			for i in 0 to (num_requests_int - 1) loop
				uniform(seed1, seed2, rand_val);
				mem_cmd(i) := integer(rand_val*real(MAX_MEM_CMD_ID));
				uniform(seed1, seed2, rand_val);
				mrs_cmd_id := integer(3.0*rand_val);
				if (mrs_cmd_id = 0) then
					mrs_mem_cmd(i) := to_integer(unsigned(CMD_MODE_REG_SET));
				elsif (mrs_cmd_id = 1) then
					mrs_mem_cmd(i) := to_integer(unsigned(CMD_EXT_MODE_REG_SET_1));
				elsif (mrs_cmd_id = 2) then
					mrs_mem_cmd(i) := to_integer(unsigned(CMD_EXT_MODE_REG_SET_2));
				elsif (mrs_cmd_id = 3) then
					mrs_mem_cmd(i) := to_integer(unsigned(CMD_EXT_MODE_REG_SET_3));
				else
					mrs_mem_cmd(i) := to_integer(unsigned(CMD_NOP));
				end if;
				uniform(seed1, seed2, rand_val);
				req_delay(i) := integer(rand_val*real(MAX_BURST_DELAY));
				uniform(seed1, seed2, rand_val);
				delay_after_turn_off(i) := integer(rand_val*real(MAX_BURST_DELAY));
				uniform(seed1, seed2, rand_val);
				mrs_ctrl_req(i) := rand_bool(rand_val, 0.5);
				uniform(seed1, seed2, rand_val);
				ref_ctrl_req(i) := rand_bool(rand_val, 0.5);
				uniform(seed1, seed2, rand_val);
				toggle_other_req(i) := rand_bool(rand_val, 0.5);
				uniform(seed1, seed2, rand_val);
				valid_mrs_ref(i) := rand_bool(rand_val, 0.75);
			end loop;
			for i in num_requests_int to (MAX_OUTSTANDING_BURSTS_TB - 1) loop
				mem_cmd(i) := to_integer(unsigned(CMD_NOP));
				mrs_mem_cmd(i) := to_integer(unsigned(CMD_NOP));
				req_delay(i) := 0;
				delay_after_turn_off(i) := 0;
				mrs_ctrl_req(i) := false;
				ref_ctrl_req(i) := false;
				toggle_other_req(i) := false;
				valid_mrs_ref(i) := false;
			end loop;
		end procedure test_param;

		procedure run_odt_ctrl (variable num_requests_exp: in integer; variable mrs_mem_cmd_arr, mem_cmd_arr, req_delay_arr, delay_after_turn_off_arr : in int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable mrs_ctrl_req_arr, ref_ctrl_req_arr, toggle_other_req_arr, valid_mrs_ref_arr : in bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable num_requests_rtl: out integer; variable odt_disabled_arr_rtl, pause_arb_arr_rtl, odt_enabled_arr_rtl, odt_disabled_arr_exp, pause_arb_arr_exp, odt_enabled_arr_exp : out bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable odt_ctrl_err_arr, mem_cmd_sel_arr : out int_arr(0 to (MAX_REQUESTS_PER_TEST - 1))) is

			variable num_requests_rtl_int	: integer;
			variable req_delay		: integer;
			variable delay_after_turn_off	: integer;
			variable mem_cmd		: integer;
			variable mrs_mem_cmd		: integer;
			variable mem_cmd_sel		: integer;
			variable mrs_ctrl_req		: boolean;
			variable ref_ctrl_req		: boolean;
			variable toggle_other_req	: boolean;
			variable valid_mrs_ref		: boolean;

			variable err			: integer;
			variable toggle_cnt		: integer;

		begin

			num_requests_rtl_int := 0;

			mem_cmd := mem_cmd_arr(num_requests_rtl_int);
			mrs_mem_cmd := mrs_mem_cmd_arr(num_requests_rtl_int);
			req_delay := req_delay_arr(num_requests_rtl_int);
			delay_after_turn_off := delay_after_turn_off_arr(num_requests_rtl_int);

			mrs_ctrl_req := mrs_ctrl_req_arr(num_requests_rtl_int);
			ref_ctrl_req := ref_ctrl_req_arr(num_requests_rtl_int);
			toggle_other_req := toggle_other_req_arr(num_requests_rtl_int);
			valid_mrs_ref := valid_mrs_ref_arr(num_requests_rtl_int);

			odt_disabled_arr_rtl := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);
			pause_arb_arr_rtl := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);
			odt_enabled_arr_rtl := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);
			odt_disabled_arr_exp := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);
			pause_arb_arr_exp := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);
			odt_enabled_arr_exp := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);

			odt_ctrl_err_arr := reset_int_arr(0, MAX_REQUESTS_PER_TEST);
			mem_cmd_sel_arr := reset_int_arr(to_integer(unsigned(CMD_NOP)), MAX_REQUESTS_PER_TEST);

			err := 0;
			toggle_cnt := 0;

			odt_loop: loop

				exit odt_loop when (num_requests_rtl_int = num_requests_exp);

				mem_cmd := mem_cmd_arr(num_requests_rtl_int);
				mrs_mem_cmd := mrs_mem_cmd_arr(num_requests_rtl_int);
				req_delay := req_delay_arr(num_requests_rtl_int);
				delay_after_turn_off := delay_after_turn_off_arr(num_requests_rtl_int);

				mrs_ctrl_req := mrs_ctrl_req_arr(num_requests_rtl_int);
				ref_ctrl_req := ref_ctrl_req_arr(num_requests_rtl_int);
				toggle_other_req := toggle_other_req_arr(num_requests_rtl_int);
				valid_mrs_ref := valid_mrs_ref_arr(num_requests_rtl_int);

				MRSCtrlReq_tb <= '0';
				RefCtrlReq_tb <= '0';

				MRSCmdAccepted_tb <= '0';
				RefCmdAccepted_tb <= '0';

				MRSUpdateCompleted_tb <= '0';

				NoBankColCmd_tb <= '0';

				Cmd_tb <= CMD_NOP;
				MRSCmd_tb <= CMD_NOP;
				RefCmd_tb <= CMD_NOP;

				err := 0;
				toggle_cnt := 0;

				if ((valid_mrs_ref = true) and (mrs_ctrl_req = true)) then
					mem_cmd_sel := mrs_mem_cmd;
				elsif ((valid_mrs_ref = true) and (ref_ctrl_req = true)) then
					mem_cmd_sel := to_integer(unsigned(CMD_SELF_REF_ENTRY));
				else
					mem_cmd_sel := mem_cmd;
				end if;
				mem_cmd_sel_arr(num_requests_rtl_int) := mem_cmd_sel;

				for i in 0 to req_delay loop
					wait until ((clk_tb = '1') and (clk_tb'event));
					if (i = req_delay) then

						Cmd_tb <= std_logic_vector(to_unsigned(mem_cmd, MEM_CMD_L));
						MRSCmd_tb <= std_logic_vector(to_unsigned(mrs_mem_cmd, MEM_CMD_L));
						RefCmd_tb <= CMD_SELF_REF_ENTRY;
						MRSCtrlReq_tb <= bool_to_std_logic(mrs_ctrl_req);
						RefCtrlReq_tb <= bool_to_std_logic(ref_ctrl_req);

						MRSUpdateCompleted_tb <= '0';

					end if;
				end loop;

				wait until ((clk_tb = '0') and (clk_tb'event));

				if ((mem_cmd_sel = to_integer(unsigned(CMD_MODE_REG_SET))) or (mem_cmd_sel = to_integer(unsigned(CMD_EXT_MODE_REG_SET_1))) or (mem_cmd_sel = to_integer(unsigned(CMD_EXT_MODE_REG_SET_2))) or (mem_cmd_sel = to_integer(unsigned(CMD_EXT_MODE_REG_SET_3)))) then
					if (mrs_ctrl_req = true) then

						for i in 0 to req_delay loop
							wait until ((clk_tb = '1') and (clk_tb'event));
							if (i = req_delay) then
								NoBankColCmd_tb <= '1';
							end if;
						end loop;

						odt_disabled_arr_exp(num_requests_rtl_int) := true;
						odt_enabled_arr_exp(num_requests_rtl_int) := true;
						pause_arb_arr_exp(num_requests_rtl_int) := true;

						if (ODT_tb = '0') then
							odt_disabled_arr_rtl(num_requests_rtl_int) := true;
						else
							odt_disabled_arr_rtl(num_requests_rtl_int) := false;
						end if;

						pause_arb_arr_rtl(num_requests_rtl_int) := true;

						while (MRSCtrlAck_tb = '0') loop
							wait until ((clk_tb = '1') and (clk_tb'event));
							wait until ((clk_tb = '0') and (clk_tb'event));

							if (toggle_other_req = true) then
								if (toggle_cnt < req_delay) then
									toggle_cnt := toggle_cnt + 1;
								else
									RefCtrlReq_tb <= '1';
								end if;
							end if;

							if (RefCtrlAck_tb = '1') then
								err := err + 1;
							end if;
						end loop;

						wait until ((clk_tb = '1') and (clk_tb'event));

						MRSCtrlReq_tb <= '0';

						for i in 0 to req_delay loop
							if (i = req_delay) then
								MRSCmdAccepted_tb <= '1';
							else
								MRSCmdAccepted_tb <= '0';
							end if;

							wait until ((clk_tb = '1') and (clk_tb'event));

						end loop;

						wait until ((clk_tb = '0') and (clk_tb'event));

						MRSCmdAccepted_tb <= '0';

						for i in 0 to delay_after_turn_off loop
							wait until ((clk_tb = '1') and (clk_tb'event));

							if (toggle_other_req = true) then
								if (toggle_cnt < req_delay) then
									toggle_cnt := toggle_cnt + 1;
								else
									RefCtrlReq_tb <= '1';
									MRSCmd_tb <= CMD_NOP;
									RefCmd_tb <= CMD_SELF_REF_ENTRY;
								end if;
							end if;

							if ((MRSCtrlAck_tb = '1') or (RefCtrlAck_tb = '1')) then
								err := err + 1;
							end if;

							if (PauseArbiter_tb = '0') then
								pause_arb_arr_rtl(num_requests_rtl_int) := false;
							end if;

							if (i = delay_after_turn_off) then
								MRSUpdateCompleted_tb <= '1';
							end if;
						end loop;

						wait until ((clk_tb = '0') and (clk_tb'event));

						MRSCmd_tb <= CMD_NOP;
						RefCmd_tb <= CMD_SELF_REF_ENTRY;

						if (RefCtrlReq_tb = '1') then

							while (RefCtrlAck_tb = '0') loop
								wait until ((clk_tb = '1') and (clk_tb'event));
								wait until ((clk_tb = '0') and (clk_tb'event));

								MRSUpdateCompleted_tb <= '0';
							end loop;

							wait until ((clk_tb = '1') and (clk_tb'event));

							RefCtrlReq_tb <= '0';

							for i in 0 to req_delay loop
								if (i = req_delay) then
									RefCmdAccepted_tb <= '1';
								else
									RefCmdAccepted_tb <= '0';
								end if;

								wait until ((clk_tb = '1') and (clk_tb'event));

							end loop;

							wait until ((clk_tb = '0') and (clk_tb'event));

							RefCmdAccepted_tb <= '0';

							for i in 0 to delay_after_turn_off loop
								wait until ((clk_tb = '1') and (clk_tb'event));

								if (i = delay_after_turn_off) then
									RefCtrlReq_tb <= '1';
									RefCmd_tb <= CMD_SELF_REF_EXIT;
								end if;
							end loop;

							while (RefCtrlAck_tb = '0') loop

								wait until ((clk_tb = '1') and (clk_tb'event));

							end loop;

							wait until ((clk_tb = '0') and (clk_tb'event));

						end if;

						RefCtrlReq_tb <= '0';

						wait until ((clk_tb = '1') and (clk_tb'event));

						if (ODT_tb = '1') then
							odt_enabled_arr_rtl(num_requests_rtl_int) := true;
						else
							odt_enabled_arr_rtl(num_requests_rtl_int) := false;
						end if;

					end if;

				elsif (mem_cmd_sel = to_integer(unsigned(CMD_SELF_REF_ENTRY))) then
					if (ref_ctrl_req = true) then
						odt_disabled_arr_exp(num_requests_rtl_int) := true;
						odt_enabled_arr_exp(num_requests_rtl_int) := true;
						pause_arb_arr_exp(num_requests_rtl_int) := true;

						for i in 0 to req_delay loop
							wait until ((clk_tb = '1') and (clk_tb'event));
							if (i = req_delay) then
								NoBankColCmd_tb <= '1';
							end if;
						end loop;

						if (ODT_tb = '0') then
							odt_disabled_arr_rtl(num_requests_rtl_int) := true;
						else
							odt_disabled_arr_rtl(num_requests_rtl_int) := false;
						end if;

						pause_arb_arr_rtl(num_requests_rtl_int) := true;

						while (RefCtrlAck_tb = '0') loop
							wait until ((clk_tb = '1') and (clk_tb'event));
							wait until ((clk_tb = '0') and (clk_tb'event));

							if (toggle_other_req = true) then
								if (toggle_cnt < req_delay) then
									toggle_cnt := toggle_cnt + 1;
								else
									MRSCtrlReq_tb <= '1';
								end if;
							end if;

							if (MRSCtrlAck_tb = '1') then
								err := err + 1;
							end if;
						end loop;

						wait until ((clk_tb = '1') and (clk_tb'event));

						RefCtrlReq_tb <= '0';

						for i in 0 to req_delay loop
							if (i = req_delay) then
								RefCmdAccepted_tb <= '1';
							else
								RefCmdAccepted_tb <= '0';
							end if;

							wait until ((clk_tb = '1') and (clk_tb'event));

						end loop;

						wait until ((clk_tb = '0') and (clk_tb'event));

						RefCmdAccepted_tb <= '0';

						for i in 0 to delay_after_turn_off loop
							wait until ((clk_tb = '1') and (clk_tb'event));

							if (PauseArbiter_tb = '0') then
								pause_arb_arr_rtl(num_requests_rtl_int) := false;
							end if;

							if (toggle_other_req = true) then
								if (toggle_cnt < req_delay) then
									toggle_cnt := toggle_cnt + 1;
								else
									MRSCtrlReq_tb <= '1';
								end if;
							end if;

							if ((MRSCtrlAck_tb = '1') or (RefCtrlAck_tb = '1')) then
								err := err + 1;
							end if;

							if (i = delay_after_turn_off) then
								RefCtrlReq_tb <= '1';
								RefCmd_tb <= CMD_SELF_REF_EXIT;
							end if;
						end loop;

						while (RefCtrlAck_tb = '0') loop
							wait until ((clk_tb = '1') and (clk_tb'event));

							if (toggle_other_req = true) then
								if (toggle_cnt < req_delay) then
									toggle_cnt := toggle_cnt + 1;
								else
									MRSCtrlReq_tb <= '1';
									MRSCmd_tb <= std_logic_vector(to_unsigned(mrs_mem_cmd, MEM_CMD_L));
								end if;
							end if;

							if (MRSCtrlAck_tb = '1') then
								err := err + 1;
							end if;

						end loop;

						wait until ((clk_tb = '0') and (clk_tb'event));
						RefCtrlReq_tb <= '0';


						if (MRSCtrlReq_tb = '1') then
							MRSCmd_tb <= std_logic_vector(to_unsigned(mrs_mem_cmd, MEM_CMD_L));

							while (MRSCtrlAck_tb = '0') loop
								wait until ((clk_tb = '1') and (clk_tb'event));
								wait until ((clk_tb = '0') and (clk_tb'event));
							end loop;

							MRSCtrlReq_tb <= '0';

							wait until ((clk_tb = '1') and (clk_tb'event));

							MRSCtrlReq_tb <= '0';

							for i in 0 to req_delay loop
								if (i = req_delay) then
									MRSCmdAccepted_tb <= '1';
								else
									MRSCmdAccepted_tb <= '0';
								end if;

								wait until ((clk_tb = '1') and (clk_tb'event));

							end loop;

							MRSCmdAccepted_tb <= '0';

							for i in 0 to delay_after_turn_off loop
								wait until ((clk_tb = '1') and (clk_tb'event));

								if (i = delay_after_turn_off) then
									MRSUpdateCompleted_tb <= '1';
								end if;
							end loop;

						end if;

						wait until ((clk_tb = '1') and (clk_tb'event));

						if (ODT_tb = '1') then
							odt_enabled_arr_rtl(num_requests_rtl_int) := true;
						else
							odt_enabled_arr_rtl(num_requests_rtl_int) := false;
						end if;

					end if;

				elsif ((mem_cmd_sel = to_integer(unsigned(CMD_READ))) or (mem_cmd_sel = to_integer(unsigned(CMD_READ_PRECHARGE)))) then
					odt_disabled_arr_exp(num_requests_rtl_int) := true;
					odt_enabled_arr_exp(num_requests_rtl_int) := false;
					pause_arb_arr_exp(num_requests_rtl_int) := false;

					pause_arb_arr_rtl(num_requests_rtl_int) := false;
					if (ODT_tb = '0') then
						odt_disabled_arr_rtl(num_requests_rtl_int) := true;
						odt_enabled_arr_rtl(num_requests_rtl_int) := false;
					else
						odt_disabled_arr_rtl(num_requests_rtl_int) := false;
						odt_enabled_arr_rtl(num_requests_rtl_int) := true;
					end if;

					if ((MRSCtrlAck_tb = '1') or (RefCtrlAck_tb = '1')) then
						err := err + 1;
					end if;
				elsif ((mem_cmd_sel = to_integer(unsigned(CMD_BANK_ACT))) or (mem_cmd_sel = to_integer(unsigned(CMD_WRITE))) or (mem_cmd_sel = to_integer(unsigned(CMD_WRITE_PRECHARGE)))) then
					odt_disabled_arr_exp(num_requests_rtl_int) := false;
					odt_enabled_arr_exp(num_requests_rtl_int) := true;
					pause_arb_arr_exp(num_requests_rtl_int) := false;

					pause_arb_arr_rtl(num_requests_rtl_int) := false;
					if (ODT_tb = '1') then
						odt_disabled_arr_rtl(num_requests_rtl_int) := false;
						odt_enabled_arr_rtl(num_requests_rtl_int) := true;
					else
						odt_disabled_arr_rtl(num_requests_rtl_int) := true;
						odt_enabled_arr_rtl(num_requests_rtl_int) := false;
					end if;

					if ((MRSCtrlAck_tb = '1') or (RefCtrlAck_tb = '1')) then
						err := err + 1;
					end if;

				end if;

				odt_ctrl_err_arr(num_requests_rtl_int) := err;
				num_requests_rtl_int := num_requests_rtl_int + 1;

			end loop;

			num_requests_rtl := num_requests_rtl_int;

		end procedure run_odt_ctrl;

		procedure verify(variable num_requests_exp, num_requests_rtl: in integer;variable mem_cmd_sel_arr : in int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable mrs_ctrl_req_arr, ref_ctrl_req_arr: in bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable odt_disabled_arr_rtl, pause_arb_arr_rtl, odt_enabled_arr_rtl, odt_disabled_arr_exp, pause_arb_arr_exp, odt_enabled_arr_exp : in bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable odt_ctrl_err_arr : in int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); file file_pointer : text; variable pass: out integer) is

			variable no_errors		: boolean;
			variable match_pause_arb	: boolean;
			variable match_odt_enable	: boolean;
			variable match_odt_disable	: boolean;

			variable file_line	: line;
		begin

			write(file_line, string'( "PHY ODT Controller: Number of requests: " & integer'image(num_requests_exp)));
			writeline(file_pointer, file_line);

			match_pause_arb := compare_bool_arr(pause_arb_arr_exp, pause_arb_arr_rtl, num_requests_exp);
			match_odt_enable := compare_bool_arr(odt_enabled_arr_exp, odt_enabled_arr_rtl, num_requests_exp);
			match_odt_disable := compare_bool_arr(odt_disabled_arr_exp, odt_disabled_arr_rtl, num_requests_exp);
			no_errors := compare_int_arr(reset_int_arr(0, num_requests_exp), odt_ctrl_err_arr, num_requests_exp);

			if ((match_pause_arb = true) and (match_odt_enable = true) and (match_odt_disable = true) and (num_requests_exp = num_requests_rtl)) then
				write(file_line, string'( "PHY ODT Controller: PASS"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_requests_exp - 1) loop
					write(file_line, string'( "PHY ODT Controller: Request #" & integer'image(i) & " Command " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(mem_cmd_sel_arr(i), MEM_CMD_L))) & " MRS update request " & bool_to_str(mrs_ctrl_req_arr(i))  & " Self Refresh request " & bool_to_str(ref_ctrl_req_arr(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 1;
			elsif (match_pause_arb = false) then
				write(file_line, string'( "PHY ODT Controller: FAIL (Pause Arbiter flag mimatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_requests_exp - 1) loop
					write(file_line, string'( "PHY ODT Controller: Request #" & integer'image(i) & " Command " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(mem_cmd_sel_arr(i), MEM_CMD_L))) & " MRS update request " & bool_to_str(mrs_ctrl_req_arr(i))  & " Self Refresh request " & bool_to_str(ref_ctrl_req_arr(i)) & " Pause arbiter exp " & bool_to_str(pause_arb_arr_exp(i)) & " rtl " & bool_to_str(pause_arb_arr_rtl(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (match_odt_enable = false) then
				write(file_line, string'( "PHY ODT Controller: FAIL (ODT enable flag mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_requests_exp - 1) loop
					write(file_line, string'( "PHY ODT Controller: Request #" & integer'image(i) & " Command " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(mem_cmd_sel_arr(i), MEM_CMD_L))) & " MRS update request " & bool_to_str(mrs_ctrl_req_arr(i))  & " Self Refresh request " & bool_to_str(ref_ctrl_req_arr(i)) & " ODT enabled exp " & bool_to_str(odt_enabled_arr_exp(i)) & " rtl " & bool_to_str(odt_enabled_arr_rtl(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (match_odt_disable = false) then
				write(file_line, string'( "PHY ODT Controller: FAIL (ODT disable flag mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_requests_exp - 1) loop
					write(file_line, string'( "PHY ODT Controller: Request #" & integer'image(i) & " Command " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(mem_cmd_sel_arr(i), MEM_CMD_L))) & " MRS update request " & bool_to_str(mrs_ctrl_req_arr(i))  & " Self Refresh request " & bool_to_str(ref_ctrl_req_arr(i)) & " ODT disabled exp " & bool_to_str(odt_disabled_arr_exp(i)) & " rtl " & bool_to_str(odt_disabled_arr_rtl(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (num_requests_exp /= num_requests_rtl) then 
				write(file_line, string'( "PHY ODT Controller: FAIL (Number requests mismatch): exp " & integer'image(num_requests_exp) & " rtl " & integer'image(num_requests_rtl)));
				writeline(file_pointer, file_line);
				pass := 0;
			elsif (no_errors = false) then
				write(file_line, string'( "PHY ODT Controller: FAIL (Handshake Error)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_requests_exp - 1) loop
					write(file_line, string'( "PHY ODT Controller: Error Request #" & integer'image(i) & ": " & integer'image(odt_ctrl_err_arr(i)) & " Error(s)"));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			else
				write(file_line, string'( "PHY ODT Controller: FAIL (Unknown error)"));
				writeline(file_pointer, file_line);
				pass := 0;
			end if;
		end procedure verify;

		variable seed1, seed2	: positive;

		variable num_requests_exp	: integer;
		variable num_requests_rtl	: integer;

		variable mem_cmd_arr			: int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable mrs_mem_cmd_arr			: int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable mem_cmd_sel_arr			: int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable req_delay_arr			: int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable delay_after_turn_off_arr	: int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));

		variable mrs_ctrl_req_arr	: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable ref_ctrl_req_arr	: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable toggle_other_req_arr	: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable valid_mrs_ref_arr	: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));

		variable odt_disabled_arr_rtl	: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable odt_enabled_arr_rtl	: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable pause_arb_arr_rtl	: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable odt_disabled_arr_exp	: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable odt_enabled_arr_exp	: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable pause_arb_arr_exp	: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));

		variable odt_ctrl_err_arr	: int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));

		variable pass	: integer;
		variable num_pass	: integer;

		file file_pointer	: text;
		variable file_line	: line;

	begin

		wait for 1 ns;

		num_pass := 0;

		reset;
		file_open(file_pointer, ddr2_ctrl_odt_ctrl_log_file, append_mode);

		write(file_line, string'( "PHY ODT Controller Test"));
		writeline(file_pointer, file_line);

		for i in 0 to NUM_TESTS-1 loop

			test_param(num_requests_exp, mrs_mem_cmd_arr, mem_cmd_arr, req_delay_arr, delay_after_turn_off_arr, mrs_ctrl_req_arr, ref_ctrl_req_arr, toggle_other_req_arr, valid_mrs_ref_arr, seed1, seed2);

			run_odt_ctrl(num_requests_exp, mrs_mem_cmd_arr, mem_cmd_arr, req_delay_arr, delay_after_turn_off_arr, mrs_ctrl_req_arr, ref_ctrl_req_arr, toggle_other_req_arr, valid_mrs_ref_arr, num_requests_rtl, odt_disabled_arr_rtl, pause_arb_arr_rtl, odt_enabled_arr_rtl, odt_disabled_arr_exp, pause_arb_arr_exp, odt_enabled_arr_exp, odt_ctrl_err_arr, mem_cmd_sel_arr);

			verify(num_requests_exp, num_requests_rtl, mem_cmd_sel_arr, mrs_ctrl_req_arr, ref_ctrl_req_arr, odt_disabled_arr_rtl, pause_arb_arr_rtl, odt_enabled_arr_rtl, odt_disabled_arr_exp, pause_arb_arr_exp, odt_enabled_arr_exp, odt_ctrl_err_arr, file_pointer, pass);

			num_pass := num_pass + pass;

			wait until ((clk_tb'event) and (clk_tb = '1'));

		end loop;

		file_close(file_pointer);

		file_open(file_pointer, summary_file, append_mode);
		write(file_line, string'( "PHY ODT Controller => PASSES: " & integer'image(num_pass) & " out of " & integer'image(TOT_NUM_TESTS)));
		writeline(file_pointer, file_line);

		if (num_pass = TOT_NUM_TESTS) then
			write(file_line, string'( "PHY ODT Controller: TEST PASSED"));
		else
			write(file_line, string'( "PHY ODT Controller: TEST FAILED: " & integer'image(TOT_NUM_TESTS-num_pass) & " failures"));
		end if;
		writeline(file_pointer, file_line);

		file_close(file_pointer);
		stop <= true;

		wait;

	end process test;

end bench;
