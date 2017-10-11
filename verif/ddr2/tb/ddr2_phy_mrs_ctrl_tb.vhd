library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;
use work.ddr2_define_pkg.all;
use work.functions_pkg_tb.all;
use work.ddr2_phy_pkg.all;
use work.ddr2_gen_ac_timing_pkg.all;
use work.ddr2_phy_mrs_ctrl_pkg.all;
use work.type_conversion_pkg.all;
use work.shared_pkg_tb.all;
use work.ddr2_pkg_tb.all;
use work.ddr2_log_pkg.all;

entity ddr2_phy_mrs_ctrl_tb is
end entity ddr2_phy_mrs_ctrl_tb;

architecture bench of ddr2_phy_mrs_ctrl_tb is

	constant CLK_PERIOD		: time := DDR2_CLK_PERIOD * 1 ns;
	constant NUM_TESTS		: integer := 1000;
	constant NUM_EXTRA_TESTS	: integer := 16;
	constant TOT_NUM_TESTS		: integer := NUM_TESTS + NUM_EXTRA_TESTS;

	constant MAX_REQUESTS_PER_TEST	: integer := 50;
	constant MAX_CMD_PER_REQUEST	: integer := 50;
	constant MAX_DELAY		: integer := T_MOD_max; -- max delay in the same block between MRS commands is T_MOD_max otherwise it will be processed next time around

	constant MRS_REG_L_TB	: positive := 13;

	signal clk_tb	: std_logic := '0';
	signal stop	: boolean := false;
	signal rst_tb	: std_logic;

	-- Transaction Controller
	signal CtrlReq_tb	: std_logic;
	signal CtrlCmd_tb	: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal CtrlData_tb	: std_logic_vector(MRS_REG_L_TB - 1 downto 0);

	signal CtrlAck_tb	: std_logic;

	-- Commands
	signal CmdAck_tb	: std_logic;

	signal CmdReq_tb	: std_logic;
	signal Cmd_tb		: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal Data_tb		: std_logic_vector(MRS_REG_L_TB - 1 downto 0);

	-- ODT Controller
	signal ODTCtrlAck_tb	: std_logic;

	signal ODTCtrlReq_tb	: std_logic;

	-- Turn ODT signal on after MRS command(s)
	signal MRSUpdateCompleted_tb	: std_logic;

begin

	DUT: ddr2_phy_mrs_ctrl generic map (
		MRS_REG_L => MRS_REG_L_TB
	)
	port map (
		clk => clk_tb,
		rst => rst_tb,

		-- Transaction Controller
		CtrlReq => CtrlReq_tb,
		CtrlCmd => CtrlCmd_tb,
		CtrlData => CtrlData_tb,

		CtrlAck => CtrlAck_tb,

		-- Commands
		CmdAck => CmdAck_tb,

		CmdReq => CmdReq_tb,
		Cmd => Cmd_tb,
		Data => Data_tb,

		-- ODT Controller
		ODTCtrlAck => ODTCtrlAck_tb,

		ODTCtrlReq => ODTCtrlReq_tb,

		-- Turn ODT signal on after MRS command(s)
		MRSUpdateCompleted => MRSUpdateCompleted_tb
	);

	clk_gen(CLK_PERIOD, 0 ns, stop, clk_tb);

	test: process

		procedure reset is
		begin

			-- Transaction Controller
			CtrlReq_tb <= '0';
			CtrlCmd_tb <= CMD_NOP;
			CtrlData_tb <= (others => '0');

			-- Commands
			CmdAck_tb <= '0';

			-- ODT Controller
			ODTCtrlAck_tb <= '0';

			rst_tb <= '0';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_tb <= '1';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_tb <= '0';
		end procedure reset;

		procedure setup_extra_tests(variable rand_odt_delay, rand_ctrl_delay, rand_cmd_delay : in boolean; variable num_requests : out integer; variable num_cmd_per_request : out int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable ctrl_cmd, ctrl_data, ctrl_delay, cmd_delay : out int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (MAX_CMD_PER_REQUEST - 1)); variable odt_delay : out int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable seed1, seed2: inout positive) is
			variable rand_val	: real;
			variable num_requests_int	: integer;
			variable num_cmd_per_request_int	: integer;
		begin
			num_requests_int := 0;
			while (num_requests_int = 0) loop
				uniform(seed1, seed2, rand_val);
				num_requests_int := integer(rand_val*real(MAX_REQUESTS_PER_TEST));
			end loop;
			num_requests := num_requests_int;

			for i in 0 to (num_requests_int - 1) loop
				num_cmd_per_request_int := 0;
				while (num_cmd_per_request_int = 0) loop
					uniform(seed1, seed2, rand_val);
					num_cmd_per_request_int := integer(rand_val*real(MAX_CMD_PER_REQUEST));
				end loop;
				num_cmd_per_request(i) := num_cmd_per_request_int;

				if (rand_odt_delay = true) then
					odt_delay(i) := 0;
				else
					uniform(seed1, seed2, rand_val);
					odt_delay(i) := integer(rand_val*real(MAX_DELAY));
				end if;

				for j in 0 to (num_cmd_per_request_int - 1) loop
					if (rand_ctrl_delay = true) then
						ctrl_delay(i, j) := 0;
					else
						uniform(seed1, seed2, rand_val);
						ctrl_delay(i, j) := integer(rand_val*real(MAX_DELAY));
					end if;
					if (rand_cmd_delay = true) then
						cmd_delay(i, j) := 0;
					else
						uniform(seed1, seed2, rand_val);
						cmd_delay(i, j) := integer(rand_val*real(MAX_DELAY));
					end if;
					uniform(seed1, seed2, rand_val);
					ctrl_cmd(i, j) := integer(rand_val*real(MAX_MEM_CMD_ID));
					uniform(seed1, seed2, rand_val);
					ctrl_data(i, j) := integer(rand_val*real((2.0**(real(MRS_REG_L_TB))) - 1.0));
				end loop;

				for j in num_cmd_per_request_int to (MAX_CMD_PER_REQUEST - 1) loop
					ctrl_delay(i, j) := 0;
					cmd_delay(i, j) := 0;
					ctrl_cmd(i, j) := to_integer(unsigned(CMD_NOP));
					ctrl_data(i, j) := 0;
				end loop;
			end loop;

			for i in num_requests_int to (MAX_REQUESTS_PER_TEST - 1) loop
				num_cmd_per_request(i) := 0;
				odt_delay(i) := 0;
				for j in 0 to (MAX_CMD_PER_REQUEST - 1) loop
					ctrl_delay(i, j) := 0;
					cmd_delay(i, j) := 0;
					ctrl_cmd(i, j) := to_integer(unsigned(CMD_NOP));
					ctrl_data(i, j) := 0;
				end loop;
			end loop;

		end procedure setup_extra_tests;

		procedure test_param(variable num_requests : out integer; variable num_cmd_per_request : out int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable ctrl_cmd, ctrl_data, ctrl_delay, cmd_delay : out int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (MAX_CMD_PER_REQUEST - 1)); variable odt_delay : out int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable seed1, seed2: inout positive) is
			variable rand_val	: real;
			variable num_requests_int	: integer;
			variable num_cmd_per_request_int	: integer;
		begin
			num_requests_int := 0;
			while (num_requests_int = 0) loop
				uniform(seed1, seed2, rand_val);
				num_requests_int := integer(rand_val*real(MAX_REQUESTS_PER_TEST));
			end loop;
			num_requests := num_requests_int;

			for i in 0 to (num_requests_int - 1) loop
				num_cmd_per_request_int := 0;
				while (num_cmd_per_request_int = 0) loop
					uniform(seed1, seed2, rand_val);
					num_cmd_per_request_int := integer(rand_val*real(MAX_CMD_PER_REQUEST));
				end loop;
				num_cmd_per_request(i) := num_cmd_per_request_int;

				uniform(seed1, seed2, rand_val);
				odt_delay(i) := integer(rand_val*real(MAX_DELAY));

				for j in 0 to (num_cmd_per_request_int - 1) loop
					uniform(seed1, seed2, rand_val);
					ctrl_delay(i, j) := integer(rand_val*real(MAX_DELAY));
					uniform(seed1, seed2, rand_val);
					cmd_delay(i, j) := integer(rand_val*real(MAX_DELAY));
					uniform(seed1, seed2, rand_val);
					ctrl_cmd(i, j) := integer(rand_val*real(MAX_MEM_CMD_ID));
					uniform(seed1, seed2, rand_val);
					ctrl_data(i, j) := integer(rand_val*real((2.0**(real(MRS_REG_L_TB))) - 1.0));
				end loop;

				for j in num_cmd_per_request_int to (MAX_CMD_PER_REQUEST - 1) loop
					ctrl_delay(i, j) := 0;
					cmd_delay(i, j) := 0;
					ctrl_cmd(i, j) := to_integer(unsigned(CMD_NOP));
					ctrl_data(i, j) := 0;
				end loop;
			end loop;

			for i in num_requests_int to (MAX_REQUESTS_PER_TEST - 1) loop
				num_cmd_per_request(i) := 0;
				odt_delay(i) := 0;
				for j in 0 to (MAX_CMD_PER_REQUEST - 1) loop
					ctrl_delay(i, j) := 0;
					cmd_delay(i, j) := 0;
					ctrl_cmd(i, j) := to_integer(unsigned(CMD_NOP));
					ctrl_data(i, j) := 0;
				end loop;
			end loop;

		end procedure test_param;

		procedure run_mrs_ctrl(variable num_requests_exp : in integer; variable num_cmd_per_request_arr_exp : in int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable ctrl_cmd_arr_exp, ctrl_data_arr_exp, ctrl_delay_arr, cmd_delay_arr : in int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (MAX_CMD_PER_REQUEST - 1)); variable odt_delay_arr : in int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable num_requests_rtl : out integer; variable num_cmd_per_request_arr_rtl, mrs_ctrl_err_arr : out int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable ctrl_cmd_arr_rtl, ctrl_data_arr_rtl : out int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (MAX_CMD_PER_REQUEST - 1))) is
			variable num_requests_rtl_int			: integer;
			variable num_cmd_per_request_rtl_int		: integer;

			variable ctrl_num_cmd_per_request_rtl_int	: integer;
			variable cmd_num_cmd_per_request_rtl_int	: integer;

			variable ctrl_cmd	: integer;
			variable ctrl_data	: integer;
			variable ctrl_delay	: integer;
			variable odt_delay	: integer;
			variable cmd_delay	: integer;

			variable error_int	: integer;

			variable ctrl_delay_cnt	: integer;
			variable cmd_delay_cnt	: integer;

			variable ctrl_accepted	: boolean;

		begin

			num_requests_rtl_int := 0;
			ctrl_num_cmd_per_request_rtl_int := 0;
			cmd_num_cmd_per_request_rtl_int := 0;

			num_cmd_per_request_rtl_int := num_cmd_per_request_arr_exp(num_requests_rtl_int);

			ctrl_cmd := ctrl_cmd_arr_exp(num_requests_rtl_int, ctrl_num_cmd_per_request_rtl_int);
			ctrl_data := ctrl_data_arr_exp(num_requests_rtl_int, ctrl_num_cmd_per_request_rtl_int);
			ctrl_delay := ctrl_delay_arr(num_requests_rtl_int, ctrl_num_cmd_per_request_rtl_int);
			odt_delay := odt_delay_arr(num_requests_rtl_int);
			cmd_delay := cmd_delay_arr(num_requests_rtl_int, cmd_num_cmd_per_request_rtl_int);

			ctrl_cmd_arr_rtl := reset_int_arr_2d(0, MAX_REQUESTS_PER_TEST, MAX_CMD_PER_REQUEST);
			ctrl_data_arr_rtl := reset_int_arr_2d(0, MAX_REQUESTS_PER_TEST, MAX_CMD_PER_REQUEST);

			num_cmd_per_request_arr_rtl := reset_int_arr(0, MAX_REQUESTS_PER_TEST);
			mrs_ctrl_err_arr := reset_int_arr(0, MAX_REQUESTS_PER_TEST);

			error_int := 0;
			ctrl_accepted := false;

			ctrl_delay_cnt := 0;
			cmd_delay_cnt := 0;

			mrs_loop : loop

				exit mrs_loop when (num_requests_rtl_int = num_requests_exp);

				num_cmd_per_request_rtl_int := num_cmd_per_request_arr_exp(num_requests_rtl_int);

				ctrl_num_cmd_per_request_rtl_int := 0;
				cmd_num_cmd_per_request_rtl_int := 0;

				ctrl_cmd := ctrl_cmd_arr_exp(num_requests_rtl_int, ctrl_num_cmd_per_request_rtl_int);
				ctrl_data := ctrl_data_arr_exp(num_requests_rtl_int, ctrl_num_cmd_per_request_rtl_int);
				ctrl_delay := ctrl_delay_arr(num_requests_rtl_int, ctrl_num_cmd_per_request_rtl_int);
				odt_delay := odt_delay_arr(num_requests_rtl_int);
				cmd_delay := cmd_delay_arr(num_requests_rtl_int, cmd_num_cmd_per_request_rtl_int);

				error_int := 0;

				ctrl_delay_cnt := 0;
				cmd_delay_cnt := 0;

				CtrlReq_tb <= '0';
				CtrlCmd_tb <= CMD_NOP;
				CtrlData_tb <= (others => '0');

				CmdAck_tb <= '0';
				ctrl_accepted := false;

				ODTCtrlAck_tb <= '0';

				for i in 0 to ctrl_delay loop
					wait until ((clk_tb = '1') and (clk_tb'event));
					if (i = ctrl_delay) then
						CtrlReq_tb <= '1';
						CtrlData_tb <= std_logic_vector(to_unsigned(ctrl_data, MRS_REG_L_TB));
						CtrlCmd_tb <= std_logic_vector(to_unsigned(ctrl_cmd, MEM_CMD_L));
						ctrl_accepted := false;
					end if;
				end loop;

				wait until ((clk_tb = '0') and (clk_tb'event));

				if (CtrlAck_tb = '1') then
					ctrl_accepted := true;
					CtrlReq_tb <= '0';
					CtrlCmd_tb <= CMD_NOP;
					CtrlData_tb <= (others => '0');

					ctrl_num_cmd_per_request_rtl_int := ctrl_num_cmd_per_request_rtl_int + 1;

					if (ctrl_num_cmd_per_request_rtl_int < num_cmd_per_request_rtl_int) then
						ctrl_cmd := ctrl_cmd_arr_exp(num_requests_rtl_int, ctrl_num_cmd_per_request_rtl_int);
						ctrl_data := ctrl_data_arr_exp(num_requests_rtl_int, ctrl_num_cmd_per_request_rtl_int);
						ctrl_delay := ctrl_delay_arr(num_requests_rtl_int, ctrl_num_cmd_per_request_rtl_int);
					end if;
				end if;

				while (ODTCtrlReq_tb = '0') loop
					wait until ((clk_tb = '1') and (clk_tb'event));
					wait until ((clk_tb = '0') and (clk_tb'event));

					if (ctrl_accepted = false) then
						if (CtrlAck_tb = '1') then
							ctrl_accepted := true;
							CtrlReq_tb <= '0';
							CtrlCmd_tb <= CMD_NOP;
							CtrlData_tb <= (others => '0');

							ctrl_num_cmd_per_request_rtl_int := ctrl_num_cmd_per_request_rtl_int + 1;

							if (ctrl_num_cmd_per_request_rtl_int < num_cmd_per_request_rtl_int) then
								ctrl_cmd := ctrl_cmd_arr_exp(num_requests_rtl_int, ctrl_num_cmd_per_request_rtl_int);
								ctrl_data := ctrl_data_arr_exp(num_requests_rtl_int, ctrl_num_cmd_per_request_rtl_int);
								ctrl_delay := ctrl_delay_arr(num_requests_rtl_int, ctrl_num_cmd_per_request_rtl_int);
							end if;
						end if;
					else

						if (CtrlAck_tb = '1') then
							error_int := error_int + 1;
						end if;

						if (ctrl_num_cmd_per_request_rtl_int < num_cmd_per_request_rtl_int) then
							if (ctrl_delay_cnt = ctrl_delay) then
								CtrlReq_tb <= '1';
								CtrlData_tb <= std_logic_vector(to_unsigned(ctrl_data, MRS_REG_L_TB));
								CtrlCmd_tb <= std_logic_vector(to_unsigned(ctrl_cmd, MEM_CMD_L));
								ctrl_accepted := false;
								ctrl_delay_cnt := 0;
							else
								ctrl_delay_cnt := ctrl_delay_cnt + 1;
							end if;
						end if;
					end if;

					ODTCtrlAck_tb <= '0';
				end loop;

				for i in 0 to odt_delay loop
					wait until ((clk_tb = '1') and (clk_tb'event));
					wait until ((clk_tb = '0') and (clk_tb'event));

					if (ctrl_accepted = false) then
						if (CtrlAck_tb = '1') then
							ctrl_accepted := true;
							CtrlReq_tb <= '0';
							CtrlCmd_tb <= CMD_NOP;
							CtrlData_tb <= (others => '0');

							ctrl_num_cmd_per_request_rtl_int := ctrl_num_cmd_per_request_rtl_int + 1;

							if (ctrl_num_cmd_per_request_rtl_int < num_cmd_per_request_rtl_int) then
								ctrl_cmd := ctrl_cmd_arr_exp(num_requests_rtl_int, ctrl_num_cmd_per_request_rtl_int);
								ctrl_data := ctrl_data_arr_exp(num_requests_rtl_int, ctrl_num_cmd_per_request_rtl_int);
								ctrl_delay := ctrl_delay_arr(num_requests_rtl_int, ctrl_num_cmd_per_request_rtl_int);
							end if;
						end if;
					else

						if (CtrlAck_tb = '1') then
							error_int := error_int + 1;
						end if;

						if (ctrl_num_cmd_per_request_rtl_int < num_cmd_per_request_rtl_int) then
							if (ctrl_delay_cnt = ctrl_delay) then
								CtrlReq_tb <= '1';
								CtrlData_tb <= std_logic_vector(to_unsigned(ctrl_data, MRS_REG_L_TB));
								CtrlCmd_tb <= std_logic_vector(to_unsigned(ctrl_cmd, MEM_CMD_L));
								ctrl_accepted := false;
								ctrl_delay_cnt := 0;
							else
								ctrl_delay_cnt := ctrl_delay_cnt + 1;
							end if;
						end if;
					end if;

					if (i = odt_delay) then
						ODTCtrlAck_tb <= '1';
					else
						ODTCtrlAck_tb <= '0';
					end if;
				end loop;

				for cmd_num in 0 to (num_cmd_per_request_rtl_int - 1) loop

					while (CmdReq_tb = '0') loop
						wait until ((clk_tb = '1') and (clk_tb'event));
						wait until ((clk_tb = '0') and (clk_tb'event));

						ODTCtrlAck_tb <= '0';

						if (ctrl_accepted = false) then
							if (CtrlAck_tb = '1') then
								ctrl_accepted := true;
								CtrlReq_tb <= '0';
								CtrlCmd_tb <= CMD_NOP;
								CtrlData_tb <= (others => '0');

								ctrl_num_cmd_per_request_rtl_int := ctrl_num_cmd_per_request_rtl_int + 1;

								if (ctrl_num_cmd_per_request_rtl_int < num_cmd_per_request_rtl_int) then
									ctrl_cmd := ctrl_cmd_arr_exp(num_requests_rtl_int, ctrl_num_cmd_per_request_rtl_int);
									ctrl_data := ctrl_data_arr_exp(num_requests_rtl_int, ctrl_num_cmd_per_request_rtl_int);
									ctrl_delay := ctrl_delay_arr(num_requests_rtl_int, ctrl_num_cmd_per_request_rtl_int);
								end if;
							end if;
						else

							if (CtrlAck_tb = '1') then
								error_int := error_int + 1;
							end if;

							if (ctrl_num_cmd_per_request_rtl_int < num_cmd_per_request_rtl_int) then
								if (ctrl_delay_cnt = ctrl_delay) then
									CtrlReq_tb <= '1';
									CtrlData_tb <= std_logic_vector(to_unsigned(ctrl_data, MRS_REG_L_TB));
									CtrlCmd_tb <= std_logic_vector(to_unsigned(ctrl_cmd, MEM_CMD_L));
									ctrl_accepted := false;
									ctrl_delay_cnt := 0;
								else
									ctrl_delay_cnt := ctrl_delay_cnt + 1;
								end if;
							end if;
						end if;

						CmdAck_tb <= '0';
					end loop;

					wait until ((clk_tb = '1') and (clk_tb'event));
					wait until ((clk_tb = '0') and (clk_tb'event));

					for i in 0 to cmd_delay loop

						if (CmdReq_tb = '0') then
							error_int := error_int + 1;
						end if;

						if (ctrl_accepted = false) then
							if (CtrlAck_tb = '1') then
								ctrl_accepted := true;
								CtrlReq_tb <= '0';
								CtrlCmd_tb <= CMD_NOP;
								CtrlData_tb <= (others => '0');

								ctrl_num_cmd_per_request_rtl_int := ctrl_num_cmd_per_request_rtl_int + 1;

								if (ctrl_num_cmd_per_request_rtl_int < num_cmd_per_request_rtl_int) then
									ctrl_cmd := ctrl_cmd_arr_exp(num_requests_rtl_int, ctrl_num_cmd_per_request_rtl_int);
									ctrl_data := ctrl_data_arr_exp(num_requests_rtl_int, ctrl_num_cmd_per_request_rtl_int);
									ctrl_delay := ctrl_delay_arr(num_requests_rtl_int, ctrl_num_cmd_per_request_rtl_int);
								end if;
							end if;
						else

							if (CtrlAck_tb = '1') then
								error_int := error_int + 1;
							end if;

							if (ctrl_num_cmd_per_request_rtl_int < num_cmd_per_request_rtl_int) then
								if (ctrl_delay_cnt = ctrl_delay) then
									CtrlReq_tb <= '1';
									CtrlData_tb <= std_logic_vector(to_unsigned(ctrl_data, MRS_REG_L_TB));
									CtrlCmd_tb <= std_logic_vector(to_unsigned(ctrl_cmd, MEM_CMD_L));
									ctrl_accepted := false;
									ctrl_delay_cnt := 0;
								else
									ctrl_delay_cnt := ctrl_delay_cnt + 1;
								end if;
							end if;
						end if;

						if (i = cmd_delay) then

							CmdAck_tb <= '1';
							ctrl_cmd_arr_rtl(num_requests_rtl_int, cmd_num_cmd_per_request_rtl_int) := to_integer(unsigned(Cmd_tb));
							ctrl_data_arr_rtl(num_requests_rtl_int, cmd_num_cmd_per_request_rtl_int) := to_integer(unsigned(Data_tb));
							cmd_num_cmd_per_request_rtl_int := cmd_num_cmd_per_request_rtl_int + 1;

							if (cmd_num_cmd_per_request_rtl_int < num_cmd_per_request_rtl_int) then 
								cmd_delay := cmd_delay_arr(num_requests_rtl_int, cmd_num_cmd_per_request_rtl_int);
							end if;
						else
							CmdAck_tb <= '0';
						end if;

						wait until ((clk_tb = '1') and (clk_tb'event));
						wait until ((clk_tb = '0') and (clk_tb'event));

					end loop;

				end loop;

				while (MRSUpdateCompleted_tb = '0') loop
						wait until ((clk_tb = '1') and (clk_tb'event));
				end loop;

				wait until ((clk_tb = '0') and (clk_tb'event));

				ODTCtrlAck_tb <= '1';

				wait until ((clk_tb = '1') and (clk_tb'event));
				wait until ((clk_tb = '0') and (clk_tb'event));

				ODTCtrlAck_tb <= '0';


				mrs_ctrl_err_arr(num_requests_rtl_int) := error_int;
				num_cmd_per_request_arr_rtl(num_requests_rtl_int) := cmd_num_cmd_per_request_rtl_int;
				num_requests_rtl_int := num_requests_rtl_int + 1;

			end loop;

			num_requests_rtl := num_requests_rtl_int;

		end procedure run_mrs_ctrl;

		procedure verify (variable num_requests_exp, num_requests_rtl : in integer; variable num_cmd_per_request_arr_exp, num_cmd_per_request_arr_rtl : in int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable ctrl_cmd_arr_exp, ctrl_data_arr_exp, ctrl_cmd_arr_rtl, ctrl_data_arr_rtl : in int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (MAX_CMD_PER_REQUEST - 1)); variable mrs_ctrl_err_arr : in int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); file file_pointer : text; variable pass: out integer) is

			variable file_line	: line;

			variable no_errors		: boolean;
			variable match_cmd_per_request	: boolean;
			variable match_ctrl_cmd		: boolean;
			variable match_ctrl_data	: boolean;

		begin

			write(file_line, string'( "PHY MRS Controller: Number of requests: " & integer'image(num_requests_exp)));
			writeline(file_pointer, file_line);

			no_errors := compare_int_arr(reset_int_arr(0, num_requests_exp), mrs_ctrl_err_arr, num_requests_exp);
			match_cmd_per_request := compare_int_arr(num_cmd_per_request_arr_exp, num_cmd_per_request_arr_rtl, num_requests_exp);

			match_ctrl_cmd := compare_int_arr_2d(ctrl_cmd_arr_exp, ctrl_cmd_arr_rtl, num_requests_exp, MAX_CMD_PER_REQUEST);

			match_ctrl_data := compare_int_arr_2d(ctrl_data_arr_exp, ctrl_data_arr_rtl, num_requests_exp, MAX_CMD_PER_REQUEST);

			if ((num_requests_exp = num_requests_rtl) and (no_errors = true) and (match_cmd_per_request = true) and (match_ctrl_cmd = true) and (match_ctrl_data = true)) then
				write(file_line, string'( "PHY MRS Controller: PASS"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_requests_exp - 1) loop
					write(file_line, string'( "PHY MRS Controller: Request #" & integer'image(i) & " Number of Commands " & integer'image(num_cmd_per_request_arr_exp(i))));
					writeline(file_pointer, file_line);
					for j in 0 to (num_cmd_per_request_arr_exp(i) - 1) loop
						write(file_line, string'( "PHY MRS Controller: Request #" & integer'image(i) & " Command #" & integer'image(j) & ": " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(ctrl_cmd_arr_exp(i, j), MEM_CMD_L))) & " Data " & integer'image(ctrl_data_arr_exp(i, j))));
						writeline(file_pointer, file_line);
					end loop;
				end loop;
				pass := 1;
			elsif (match_cmd_per_request = false) then
				write(file_line, string'( "PHY MRS Controller: FAIL (Number command mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_requests_exp - 1) loop
					write(file_line, string'( "PHY MRS Controller: Error Request #" & integer'image(i) & ": exp " & integer'image(num_cmd_per_request_arr_exp(i)) & " rtl " & integer'image(num_cmd_per_request_arr_rtl(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (match_ctrl_data = false) then
				write(file_line, string'( "PHY MRS Controller: FAIL (Command mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_requests_exp - 1) loop
					write(file_line, string'( "PHY MRS Controller: Request #" & integer'image(i) & " Number of Commands " & integer'image(num_cmd_per_request_arr_exp(i))));
					writeline(file_pointer, file_line);
					for j in 0 to (num_cmd_per_request_arr_exp(i) - 1) loop
						write(file_line, string'( "PHY MRS Controller: Request #" & integer'image(i) & " Command #" & integer'image(j) & ": Data exp "  & integer'image(ctrl_data_arr_exp(i, j)) & " vs rtl "  & integer'image(ctrl_data_arr_rtl(i, j))));
						writeline(file_pointer, file_line);
					end loop;
				end loop;
			elsif (match_ctrl_cmd = false) then
				write(file_line, string'( "PHY MRS Controller: FAIL (Command mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_requests_exp - 1) loop
					write(file_line, string'( "PHY MRS Controller: Request #" & integer'image(i) & " Number of Commands " & integer'image(num_cmd_per_request_arr_exp(i))));
					writeline(file_pointer, file_line);
					for j in 0 to (num_cmd_per_request_arr_exp(i) - 1) loop
						write(file_line, string'( "PHY MRS Controller: Request #" & integer'image(i) & " Command #" & integer'image(j) & ": exp " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(ctrl_cmd_arr_exp(i, j), MEM_CMD_L))) & " vs rtl " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(ctrl_cmd_arr_exp(i, j), MEM_CMD_L)))));
						writeline(file_pointer, file_line);
					end loop;
				end loop;
			elsif (num_requests_exp /= num_requests_rtl) then 
				write(file_line, string'( "PHY MRS Controller: FAIL (Number requests mismatch): exp " & integer'image(num_requests_exp) & " rtl " & integer'image(num_requests_rtl)));
				writeline(file_pointer, file_line);
				pass := 0;
			elsif (no_errors = false) then
				write(file_line, string'( "PHY MRS Controller: FAIL (Handshake Error)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_requests_exp - 1) loop
					write(file_line, string'( "PHY MRS Controller: Error Request #" & integer'image(i) & ": " & integer'image(mrs_ctrl_err_arr(i)) & " Error(s)"));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			else
				write(file_line, string'( "PHY MRS Controller: FAIL (Unknown error)"));
				writeline(file_pointer, file_line);
				pass := 0;
			end if;
		end procedure verify;

		variable seed1, seed2	: positive;

		variable num_requests_exp	: integer;
		variable num_requests_rtl	: integer;

		variable num_cmd_per_request_arr_exp	: int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable num_cmd_per_request_arr_rtl	: int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));

		variable ctrl_cmd_arr_exp	: int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (MAX_CMD_PER_REQUEST - 1));
		variable ctrl_data_arr_exp	: int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (MAX_CMD_PER_REQUEST - 1));
		variable ctrl_cmd_arr_rtl	: int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (MAX_CMD_PER_REQUEST - 1));
		variable ctrl_data_arr_rtl	: int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (MAX_CMD_PER_REQUEST - 1));

		variable ctrl_delay_arr		: int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (MAX_CMD_PER_REQUEST - 1));
		variable cmd_delay_arr		: int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (MAX_CMD_PER_REQUEST - 1));
		variable odt_delay_arr		: int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));

		variable mrs_ctrl_err_arr	: int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));

		variable rand_odt_delay		: boolean;
		variable rand_cmd_delay		: boolean;
		variable rand_ctrl_delay	: boolean;

		variable pass	: integer;
		variable num_pass	: integer;

		file file_pointer	: text;
		variable file_line	: line;

	begin

		wait for 1 ns;

		num_pass := 0;

		reset;
		file_open(file_pointer, ddr2_phy_mrs_ctrl_log_file, append_mode);

		write(file_line, string'( "PHY MRS Controller Test"));
		writeline(file_pointer, file_line);

		for i in 0 to NUM_TESTS-1 loop

			test_param(num_requests_exp, num_cmd_per_request_arr_exp, ctrl_cmd_arr_exp, ctrl_data_arr_exp, ctrl_delay_arr, cmd_delay_arr, odt_delay_arr, seed1, seed2);

			run_mrs_ctrl(num_requests_exp, num_cmd_per_request_arr_exp, ctrl_cmd_arr_exp, ctrl_data_arr_exp, ctrl_delay_arr, cmd_delay_arr, odt_delay_arr, num_requests_rtl, num_cmd_per_request_arr_rtl, mrs_ctrl_err_arr, ctrl_cmd_arr_rtl, ctrl_data_arr_rtl);

			verify(num_requests_exp, num_requests_rtl, num_cmd_per_request_arr_exp, num_cmd_per_request_arr_rtl, ctrl_cmd_arr_exp, ctrl_data_arr_exp, ctrl_cmd_arr_rtl, ctrl_data_arr_rtl, mrs_ctrl_err_arr, file_pointer, pass);

			num_pass := num_pass + pass;

			wait until ((clk_tb'event) and (clk_tb = '1'));

		end loop;

		if (NUM_EXTRA_TESTS > 0) then

			for i in 0 to NUM_EXTRA_TESTS-1 loop

				if ((i mod 8) = 0) then
					rand_odt_delay := false;
					rand_cmd_delay := false;
					rand_ctrl_delay := false;
				elsif ((i mod 8) = 1) then
					rand_odt_delay := true;
					rand_cmd_delay := false;
					rand_ctrl_delay := false;
				elsif ((i mod 8) = 2) then
					rand_odt_delay := false;
					rand_cmd_delay := true;
					rand_ctrl_delay := false;
				elsif ((i mod 8) = 3) then
					rand_odt_delay := true;
					rand_cmd_delay := true;
					rand_ctrl_delay := false;
				elsif ((i mod 8) = 4) then
					rand_odt_delay := false;
					rand_cmd_delay := false;
					rand_ctrl_delay := true;
				elsif ((i mod 8) = 5) then
					rand_odt_delay := true;
					rand_cmd_delay := false;
					rand_ctrl_delay := true;
				elsif ((i mod 8) = 6) then
					rand_odt_delay := false;
					rand_cmd_delay := true;
					rand_ctrl_delay := true;
				else
					rand_odt_delay := false;
					rand_cmd_delay := true;
					rand_ctrl_delay := true;
				end if;

				setup_extra_tests(rand_odt_delay, rand_ctrl_delay, rand_cmd_delay, num_requests_exp, num_cmd_per_request_arr_exp, ctrl_cmd_arr_exp, ctrl_data_arr_exp, ctrl_delay_arr, cmd_delay_arr, odt_delay_arr, seed1, seed2);

				run_mrs_ctrl(num_requests_exp, num_cmd_per_request_arr_exp, ctrl_cmd_arr_exp, ctrl_data_arr_exp, ctrl_delay_arr, cmd_delay_arr, odt_delay_arr, num_requests_rtl, num_cmd_per_request_arr_rtl, mrs_ctrl_err_arr, ctrl_cmd_arr_rtl, ctrl_data_arr_rtl);

				verify(num_requests_exp, num_requests_rtl, num_cmd_per_request_arr_exp, num_cmd_per_request_arr_rtl, ctrl_cmd_arr_exp, ctrl_data_arr_exp, ctrl_cmd_arr_rtl, ctrl_data_arr_rtl, mrs_ctrl_err_arr, file_pointer, pass);

				num_pass := num_pass + pass;

				wait until ((clk_tb'event) and (clk_tb = '1'));


			end loop;

		end if;

		file_close(file_pointer);

		file_open(file_pointer, summary_file, append_mode);
		write(file_line, string'( "PHY MRS Controller => PASSES: " & integer'image(num_pass) & " out of " & integer'image(TOT_NUM_TESTS)));
		writeline(file_pointer, file_line);

		if (num_pass = TOT_NUM_TESTS) then
			write(file_line, string'( "PHY MRS Controller: TEST PASSED"));
		else
			write(file_line, string'( "PHY MRS Controller: TEST FAILED: " & integer'image(TOT_NUM_TESTS-num_pass) & " failures"));
		end if;
		writeline(file_pointer, file_line);

		file_close(file_pointer);
		stop <= true;

		wait;

	end process test;

end bench;
