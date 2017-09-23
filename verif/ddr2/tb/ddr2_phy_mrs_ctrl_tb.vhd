library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;
use work.proc_pkg.all;
use work.ddr2_define_pkg.all;
use work.ddr2_phy_pkg.all;
use work.ddr2_phy_odt_ctrl_pkg.all;
use work.type_conversion_pkg.all;
use work.tb_pkg.all;
use work.ddr2_pkg_tb.all;

entity ddr2_phy_odt_ctrl_tb is
end entity ddr2_phy_odt_ctrl_tb;

architecture bench of ddr2_phy_odt_ctrl_tb is

	constant CLK_PERIOD	: time := DDR2_CLK_PERIOD * 1 ns;
	constant NUM_TESTS	: integer := 10000;
	constant TOT_NUM_TESTS	: integer := NUM_TESTS;

	constant MAX_REQUESTS_PER_TEST	: integer := 500;
	constant MAX_CMD_PER_REQUESTS	: integer := 500;
	constant MAX_DELAY		: integer := 20;

	constant MRS_REG_L_TB	: positive := 13;

	signal clk_tb	: std_logic := '0';
	signal stop	: boolean := false;
	signal rst_tb	: std_logic;

	-- Transaction Controller
	signal CtrlReq_tb	: std_logic;
	signal CtrlCmd_tb	: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal CtrlData_tb	: std_logic_vector(MRS_REG_L - 1 downto 0);

	signal CtrlAck_tb	: std_logic;

	-- Commands
	signal CmdAck_tb	: std_logic;

	signal CmdReq_tb	: std_logic;
	signal Cmd_tb		: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal Data_tb		: std_logic_vector(MRS_REG_L - 1 downto 0);

	-- ODT Controller
	signal ODTCtrlAck_tb	: std_logic;

	signal ODTCtrlReq_tb	: std_logic;

	-- Turn ODT signal on after MRS command(s)
	signal MRSUpdateCompleted_tb	: std_logic;

begin

	DUT: ddr2_phy_odt_ctrl generic map (
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

		procedure test_param(variable num_requests : out integer; variable num_cmd_per_request : out int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable ctrl_cmd, ctrl_data, ctrl_delay, odt_delay, cmd_delay : out int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (MAX_CMD_PER_REQUEST - 1)); variable odt_delay : out int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable seed1, seed2: inout positive) is
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
				odt_delay(i, j) := integer(rand_val*real(MAX_DELAY));

				for j in 0 to (num_cmd_per_request_int - 1) loop
					uniform(seed1, seed2, rand_val);
					ctrl_delay(i, j) := integer(rand_val*real(MAX_DELAY));
					uniform(seed1, seed2, rand_val);
					cmd_delay(i, j) := integer(rand_val*real(MAX_DELAY));
					uniform(seed1, seed2, rand_val);
					ctrl_cmd(i, j) := integer(rand_val*real(MAX_MEM_CMD_ID));
					uniform(seed1, seed2, rand_val);
					ctrl_data(i, j) := integer(rand_val*real(2.0**(real(MRS_REG_L_TB))));
				end loop;

				for j in num_cmd_per_request_int to (MAX_CMD_PER_REQUEST - 1) loop
					ctrl_delay(i, j) := 0;
					cmd_delay(i, j) := 0;
					ctrl_cmd(i, j) := CMD_NOP;
					ctrl_data(i, j) := 0;
				end loop;
			end loop;

			for i in num_requests_int to (MAX_REQUESTS_PER_TEST - 1) loop
				num_cmd_per_request(i) := 0;
				odt_delay(i) := 0;
				for j in 0 to (MAX_CMD_PER_REQUEST - 1) loop
					ctrl_delay(i, j) := 0;
					cmd_delay(i, j) := 0;
					ctrl_cmd(i, j) := CMD_NOP;
					ctrl_data(i, j) := 0;
				end loop;
			end loop;

		end procedure test_param;

		procedure run_mrs_ctrl(variable num_requests_exp : in integer; variable num_cmd_per_request_arr_exp : in int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable ctrl_cmd_arr_exp, ctrl_data_arr_exp, ctrl_delay_arr, cmd_delay_arr : in int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (MAX_CMD_PER_REQUEST - 1)); variable odt_delay_arr : in int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable num_requests_rtl : out integer; variable num_cmd_per_request_arr_rtl, error_arr : out int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable ctrl_cmd_arr_rtl, ctrl_data_arr_rtl : out int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (MAX_CMD_PER_REQUEST - 1))) is
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

			ctrl_cmd_arr_rtl = reset_int_arr_2d(0, MAX_REQUESTS_PER_TEST, MAX_CMD_PER_REQUEST);
			ctrl_data_arr_rtl = reset_int_arr_2d(0, MAX_REQUESTS_PER_TEST, MAX_CMD_PER_REQUEST);

			num_cmd_per_request_arr_rtl = reset_int_arr(0, MAX_REQUESTS_PER_TEST);
			error_arr = reset_int_arr(0, MAX_REQUESTS_PER_TEST);

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
						ODTCtrlReq_tb <= '0';
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

						CtrlAck_tb <= '0';
					end loop;

					for i in 0 to cmd_delay loop
						wait until ((clk_tb = '1') and (clk_tb'event));
						wait until ((clk_tb = '0') and (clk_tb'event));

						if (CmdReq_tb = '0') begin
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
							CtrlAck_tb <= '1';
							ctrl_cmd_arr_rtl(num_requests_rtl_int, cmd_num_cmd_per_request_rtl_int) := to_integer(unsigned(Cmd_tb));
							ctrl_data_arr_rtl(num_requests_rtl_int, cmd_num_cmd_per_request_rtl_int) := to_integer(unsigned(Data_tb));
							cmd_num_cmd_per_request_rtl_int := cmd_num_cmd_per_request_rtl_int + 1;
						else
							CtrlAck_tb <= '0';
						end if;

					end loop;
				end loop;

				error_arr(num_requests_rtl_int) := error_int;
				num_requests_rtl_int := num_requests_rtl_int + 1;

			end loop;

		end procedure run_mrs_ctrl;


