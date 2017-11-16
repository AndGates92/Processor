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
use ddr2_rtl_pkg.ddr2_mrs_pkg.all;
use ddr2_rtl_pkg.ddr2_mrs_max_pkg.all;
use ddr2_rtl_pkg.ddr2_ctrl_ref_ctrl_pkg.all;
use ddr2_rtl_pkg.ddr2_gen_ac_timing_pkg.all;
library ddr2_tb_pkg;
use ddr2_tb_pkg.ddr2_pkg_tb.all;
use ddr2_tb_pkg.ddr2_log_pkg.all;

entity ddr2_ctrl_ref_ctrl_tb is
end entity ddr2_ctrl_ref_ctrl_tb;

architecture bench of ddr2_ctrl_ref_ctrl_tb is

	constant CLK_PERIOD	: time := DDR2_CLK_PERIOD * 1 ns;
	constant NUM_TEST	: integer := 50;
	constant NUM_EXTRA_TEST	: integer := 0;
	constant TOT_NUM_TEST	: integer := NUM_TEST + NUM_EXTRA_TEST;

	constant MAX_REQUESTS_PER_TEST		: integer := 50;
	constant MAX_SELF_REFRESH_TIME		: integer := 2*AUTO_REFRESH_EXIT_TIME;
	constant MAX_CMD_REQ_ACK_DELAY		: integer := 20;
	constant MAX_ODT_CMD_REQ_ACK_DELAY	: integer := 20;
	constant MAX_BANK_IDLE_DELAY		: integer := AUTO_REFRESH_EXIT_TIME;

	constant MAX_PHY_COMPLETED_DELAY	: integer := 100;

	signal clk_tb	: std_logic := '0';
	signal stop	: boolean := false;
	signal rst_tb	: std_logic;

	-- Auto Refresh Time
	signal DDR2HighTemperatureRefresh_tb	: std_logic;

	-- Transaction Controller
	signal RefreshReq_tb		: std_logic;
	signal NonReadOpEnable_tb	: std_logic;
	signal ReadOpEnable_tb		: std_logic;

	-- PHY Init
	signal PhyInitCompleted_tb	: std_logic;

	-- Bank Controller
	signal BankIdle_tb		: std_logic_vector(BANK_NUM_TB - 1 downto 0);

	-- ODT Controller
	signal ODTCtrlAck_tb		: std_logic;

	signal RefCmdAccepted_tb	: std_logic;
	signal ODTCtrlReq_tb		: std_logic;
	signal ODTCmd_tb		: std_logic_vector(MEM_CMD_L - 1 downto 0);

	-- Arbitrer
	signal CmdAck_tb		: std_logic;

	signal CmdOut_tb		: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal CmdReq_tb		: std_logic;

	-- Controller
	signal CtrlReq_tb		: std_logic;

	signal CtrlAck_tb		: std_logic;



begin

	DUT: ddr2_ctrl_ref_ctrl generic map (
		BANK_NUM => BANK_NUM_TB
	)
	port map (
		clk => clk_tb,
		rst => rst_tb,

		-- High temperature flag
		DDR2HighTemperatureRefresh => DDR2HighTemperatureRefresh_tb,

		-- Transaction Controller
		RefreshReq => RefreshReq_tb,
		NonReadOpEnable => NonReadopEnable_tb,
		ReadOpEnable => ReadopEnable_tb,

		-- PHY Init
		PhyInitCompleted => PhyInitCompleted_tb,

		-- Bank Controller
		BankIdle => BankIdle_tb,

		-- ODT Controller
		ODTCtrlAck => ODTCtrlAck_tb,

		RefCmdAccepted => RefCmdAccepted_tb,
		ODTCtrlReq => ODTCtrlReq_tb,
		ODTCmd => ODTCmd_tb,

		-- Arbitrer
		CmdAck => CmdAck_tb,

		CmdOut => CmdOut_tb,
		CmdReq => CmdReq_tb,

		-- Controller
		CtrlReq => CtrlReq_tb,

		CtrlAck => CtrlAck_tb
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

		procedure test_param(variable num_requests : out integer; variable high_temp : out boolean; variable self_refresh : out bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable ctrl_completed_delay, cmd_req_ack_delay, odt_cmd_req_ack_delay, self_refresh_time, bank_idle_delay : out int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable seed1, seed2 : inout positive) is
			variable rand_val		: real;
			variable num_requests_int	: integer;
		begin

			num_requests_int := 0;
			while (num_requests_int = 0) loop
				uniform(seed1, seed2, rand_val);
				num_requests_int := integer(rand_val*real(MAX_REQUESTS_PER_TEST));
			end loop;
			num_requests := num_requests_int;

			uniform(seed1, seed2, rand_val);
			high_temp := rand_bool(rand_val, 0.5);

			for i in 0 to (num_requests_int - 1) loop
				uniform(seed1, seed2, rand_val);
				cmd_req_ack_delay(i) := integer(rand_val*real(MAX_CMD_REQ_ACK_DELAY));
				uniform(seed1, seed2, rand_val);
				odt_cmd_req_ack_delay(i) := integer(rand_val*real(MAX_ODT_CMD_REQ_ACK_DELAY));
				uniform(seed1, seed2, rand_val);
				self_refresh_time(i) := integer(rand_val*real(MAX_SELF_REFRESH_TIME));
				uniform(seed1, seed2, rand_val);
				ctrl_completed_delay(i) := integer(rand_val*real(MAX_PHY_COMPLETED_DELAY));
				uniform(seed1, seed2, rand_val);
				bank_idle_delay(i) := integer(rand_val*real(MAX_BANK_IDLE_DELAY));
				uniform(seed1, seed2, rand_val);
				self_refresh(i) := rand_bool(rand_val, 0.5);
			end loop;
			for i in num_requests_int to (MAX_REQUESTS_PER_TEST - 1) loop
				cmd_req_ack_delay(i) := int_arr_def;
				odt_cmd_req_ack_delay(i) := int_arr_def;
				self_refresh_time(i) := int_arr_def;
				ctrl_completed_delay(i) := int_arr_def;
				bank_idle_delay(i) := int_arr_def;
				self_refresh(i) := false;
			end loop;

		end procedure test_param;

		procedure run_ref_ctrl(variable num_requests_exp : in integer; variable high_temp : in boolean; variable self_refresh_arr : in bool_arr(0 to (MAX_REQUESTS_PER_TEST-1)); variable ctrl_completed_delay_arr, cmd_req_ack_delay_arr, odt_cmd_req_ack_delay_arr, self_refresh_time_arr, bank_idle_delay_arr : in int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable num_requests_rtl : out integer; variable cmd_arr_rtl, cmd_arr_exp : out int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to 1); variable ctrl_err_arr, cmd_err_arr, odt_err_arr : out int_arr(0 to (MAX_REQUESTS_PER_TEST - 1))) is
			variable num_requests_rtl_int	: integer;
			variable self_refresh		: boolean;
			variable cmd_req_ack_delay	: integer;
			variable odt_cmd_req_ack_delay	: integer;
			variable self_refresh_time	: integer;
			variable bank_idle_delay	: integer;
			variable ctrl_completed_delay	: integer;
			variable ctrl_req		: boolean;
			variable cmd_req		: boolean;
			variable odt_req		: boolean;
			variable outstanding_ref	: boolean;

			variable odt_err		: integer;
			variable ctrl_err		: integer;
			variable cmd_err		: integer;
		begin
			num_requests_rtl_int := 0;

			ref_loop: loop

				exit ref_loop when (num_requests_rtl_int = num_requests_exp);

				if (RefreshReq_tb = '1') then
					outstanding_ref := true;
					self_refresh := false;
					cmd_req_ack_delay := 0;
					odt_cmd_req_ack_delay := 0;
					self_refresh_time := 0;
					ctrl_completed_delay := 0;
					bank_idle_delay := 0;
				else
					outstanding_ref := false;
					self_refresh := self_refresh_arr(num_requests_rtl_int);
					cmd_req_ack_delay := cmd_req_ack_delay_arr(num_requests_rtl_int);
					odt_cmd_req_ack_delay := odt_cmd_req_ack_delay_arr(num_requests_rtl_int);
					self_refresh_time := self_refresh_time_arr(num_requests_rtl_int);
					ctrl_completed_delay := ctrl_completed_delay_arr(num_requests_rtl_int);
					bank_idle_delay := bank_idle_delay_arr(num_requests_rtl_int);
				end if;

				odt_err := 0;
				cmd_err := 0;
				ctrl_err := 0;

				ctrl_req := false;
				odt_req := false;
				cmd_req := false;

				-- High temperature flag
				DDR2HighTemperatureRefresh_tb <= bool_to_std_logic(high_temp);

				-- PHY Init
				PhyInitCompleted_tb <= '0';

				-- Bank Controller
				BankIdle_tb <= (others => '0');

				-- ODT Controller
				ODTCtrlAck_tb <= '0';

				-- Arbitrer
				CmdAck_tb <= '0';

				-- Controller
				CtrlReq_tb <= '0';

				for i in 0 to ctrl_completed_delay loop
					wait for 1 ps;
					if (i = ctrl_completed_delay) then
						PhyInitCompleted_tb <= '1';
					end if;
					if (ODTCtrlReq_tb = '1') then
						odt_err := odt_err + 1;
					end if;
					if (CtrlAck_tb = '1') then
						ctrl_err := ctrl_err + 1;
					end if;
					if (CmdReq_tb = '1') then
						cmd_err := cmd_err + 1;
					end if;
					wait until ((clk_tb = '1') and (clk_tb'event));
				end loop;

				if (self_refresh) then
					CtrlReq_tb <= '1';
					ctrl_req := true;
				else
					CtrlReq_tb <= '0';
					ctrl_req := false;
				end if;

				while (RefreshReq_tb = '0') loop
					wait for 1 ps;
					if (ODTCtrlReq_tb = '1') then
						odt_err := odt_err + 1;
					end if;
					if (CtrlAck_tb = '1') then
						ctrl_err := ctrl_err + 1;
					end if;
					if (CmdReq_tb = '1') then
						cmd_err := cmd_err + 1;
					end if;
					wait until ((clk_tb = '1') and (clk_tb'event));
				end loop;

				for i in 0 to bank_idle_delay loop
					wait for 1 ps;
					if (i = bank_idle_delay) then
						BankIdle_tb <= std_logic_vector(to_unsigned((2**(BANK_NUM_TB) - 1), BANK_NUM_TB));
					else
						BankIdle_tb <= std_logic_vector(to_unsigned((2**(i mod BANK_NUM_TB)), BANK_NUM_TB));
					end if;
					if (ODTCtrlReq_tb = '1') then
						odt_err := odt_err + 1;
					end if;
					if (CtrlAck_tb = '1') then
						ctrl_err := ctrl_err + 1;
					end if;
					if (CmdReq_tb = '1') then
						cmd_err := cmd_err + 1;
					end if;
					wait until ((clk_tb = '1') and (clk_tb'event));
				end loop;

				if (self_refresh) then

					while (ODTCtrlReq_tb = '0') loop
						wait for 1 ps;
						if (CmdReq_tb = '1') then
							cmd_err := cmd_err + 1;
						end if;

						if (CtrlAck_tb = '1') then
							if (ctrl_req = true) then
								CtrlReq_tb <= '0';
								ctrl_req := false;
							else
								ctrl_err := ctrl_err + 1;
							end if;
						end if;
						wait until ((clk_tb = '1') and (clk_tb'event));
					end loop;

					odt_req := true;

					for i in 0 to odt_cmd_req_ack_delay loop
						wait for 1 ps;
						if (i = odt_cmd_req_ack_delay) then
							odt_req := false;
							ODTCtrlAck_tb <= '1';
						end if;

						if (CtrlAck_tb = '1') then
							if (ctrl_req = true) then
								CtrlReq_tb <= '0';
								ctrl_req := false;
							else
								ctrl_err := ctrl_err + 1;
							end if;
						end if;
						if (CmdReq_tb = '1') then
							cmd_err := cmd_err + 1;
						end if;
						wait until ((clk_tb = '1') and (clk_tb'event));
					end loop;

					ODTCtrlAck_tb <= '0';

					while (CmdReq_tb = '0') loop
						wait for 1 ps;
						if (ODTCtrlReq_tb = '1') then
							odt_err := odt_err + 1;
						end if;
						if (CtrlAck_tb = '1') then
							if (ctrl_req = true) then
								CtrlReq_tb <= '0';
								ctrl_req := false;
							else
								ctrl_err := ctrl_err + 1;
							end if;
						end if;
						wait until ((clk_tb = '1') and (clk_tb'event));
					end loop;

					cmd_req := true;

					for i in 0 to cmd_req_ack_delay loop
						wait for 1 ps;
						if (i = cmd_req_ack_delay) then
							cmd_arr_rtl(num_requests_rtl_int, 0) := to_integer(unsigned(CmdOut_tb));
							cmd_arr_exp(num_requests_rtl_int, 0) := to_integer(unsigned(CMD_SELF_REF_ENTRY));
							CmdAck_tb <= '1';
						end if;

						if (CtrlAck_tb = '1') then
							if (ctrl_req = true) then
								CtrlReq_tb <= '0';
								ctrl_req := false;
							else
								ctrl_err := ctrl_err + 1;
							end if;
						end if;
						if (ODTCtrlReq_tb = '1') then
							odt_err := odt_err + 1;
						end if;
						wait until ((clk_tb = '1') and (clk_tb'event));
					end loop;

					CmdAck_tb <= '0';
					cmd_req := false;

					if (ctrl_req = true) then
						ctrl_err := ctrl_err + 1;
					end if;

					for i in 0 to self_refresh_time loop
						wait for 1 ps;
						if (CmdReq_tb = '1') then
							cmd_err := cmd_err + 1;
						end if;
						if (CtrlAck_tb = '1') then
							ctrl_err := ctrl_err + 1;
						end if;
						if (ODTCtrlReq_tb = '1') then
							odt_err := odt_err + 1;
						end if;
						wait until ((clk_tb = '1') and (clk_tb'event));
					end loop;

					CtrlReq_tb <= '1';
					ctrl_req := true;

					while (CtrlAck_tb = '0') loop
						wait for 1 ps;
						if (ODTCtrlReq_tb = '1') then
							odt_err := odt_err + 1;
						end if;
						wait until ((clk_tb = '1') and (clk_tb'event));
					end loop;

					CtrlReq_tb <= '0';
					ctrl_req := false;

					while (CmdReq_tb = '0') loop
						wait for 1 ps;
						if (ODTCtrlReq_tb = '1') then
							odt_err := odt_err + 1;
						end if;
						if (CtrlAck_tb = '1') then
							ctrl_err := ctrl_err + 1;
						end if;
						wait until ((clk_tb = '1') and (clk_tb'event));
					end loop;

					cmd_req := true;

					for i in 0 to cmd_req_ack_delay loop
						wait for 1 ps;
						if (i = cmd_req_ack_delay) then
							cmd_arr_rtl(num_requests_rtl_int, 1) := to_integer(unsigned(CmdOut_tb));
							cmd_arr_exp(num_requests_rtl_int, 1) := to_integer(unsigned(CMD_SELF_REF_EXIT));
							CmdAck_tb <= '1';
						end if;

						if (CtrlAck_tb = '1') then
							ctrl_err := ctrl_err + 1;
						end if;
						if (ODTCtrlReq_tb = '1') then
							odt_err := odt_err + 1;
						end if;
						wait until ((clk_tb = '1') and (clk_tb'event));
					end loop;

				else

					while (CmdReq_tb = '0') loop
						wait for 1 ps;
						if (ODTCtrlReq_tb = '1') then
							odt_err := odt_err + 1;
						end if;
						if (CtrlAck_tb = '1') then
							ctrl_err := ctrl_err + 1;
						end if;
						wait until ((clk_tb = '1') and (clk_tb'event));
					end loop;

					cmd_req := true;

					for i in 0 to cmd_req_ack_delay loop
						wait for 1 ps;
						if (i = cmd_req_ack_delay) then
							cmd_arr_rtl(num_requests_rtl_int, 0) := to_integer(unsigned(CmdOut_tb));
							cmd_arr_rtl(num_requests_rtl_int, 1) := 0;
							cmd_arr_exp(num_requests_rtl_int, 0) := to_integer(unsigned(CMD_AUTO_REF));
							cmd_arr_exp(num_requests_rtl_int, 1) := 0;
							CmdAck_tb <= '1';
						else
							CmdAck_tb <= '0';
						end if;
						if (ODTCtrlReq_tb = '1') then
							odt_err := odt_err + 1;
						end if;
						if (CtrlAck_tb = '1') then
							ctrl_err := ctrl_err + 1;
						end if;
						wait until ((clk_tb = '1') and (clk_tb'event));
					end loop;

				end if;

				CmdAck_tb <= '0';
				cmd_req := false;

				while ((ReadOpEnable_tb = '0') or (NonReadOpEnable_tb = '0')) loop
					wait for 1 ps;
					if (ODTCtrlReq_tb = '1') then
						odt_err := odt_err + 1;
					end if;
					if (CtrlAck_tb = '1') then
						ctrl_err := ctrl_err + 1;
					end if;
					if (CmdReq_tb = '1') then
						cmd_err := cmd_err + 1;
					end if;
					wait until ((clk_tb = '1') and (clk_tb'event));
				end loop;

				if (self_refresh = true) then
					wait for 1 ps;
					while (ODTCtrlReq_tb = '0') loop
						if (CmdReq_tb = '1') then
							cmd_err := cmd_err + 1;
						end if;

						if (CtrlAck_tb = '1') then
							ctrl_err := ctrl_err + 1;
						end if;
						wait until ((clk_tb = '1') and (clk_tb'event));
					end loop;

					odt_req := true;

					for i in 0 to odt_cmd_req_ack_delay loop
						wait for 1 ps;
						if (i = odt_cmd_req_ack_delay) then
							odt_req := false;
							ODTCtrlAck_tb <= '1';
						end if;

						if (CtrlAck_tb = '1') then
							ctrl_err := ctrl_err + 1;
						end if;
						if (CmdReq_tb = '1') then
							cmd_err := cmd_err + 1;
						end if;
						wait until ((clk_tb = '1') and (clk_tb'event));
					end loop;

					ODTCtrlAck_tb <= '0';

				end if;

				odt_err_arr(num_requests_rtl_int) := odt_err; 
				cmd_err_arr(num_requests_rtl_int) := cmd_err; 
				ctrl_err_arr(num_requests_rtl_int) := ctrl_err; 

				if (outstanding_ref = false) then
					num_requests_rtl_int := num_requests_rtl_int + 1;
				end if;

			end loop;

			num_requests_rtl := num_requests_rtl_int;

		end procedure run_ref_ctrl;

		procedure verify(variable num_requests_exp, num_requests_rtl : in integer; variable cmd_arr_rtl, cmd_arr_exp : in int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to 1); variable ctrl_err_arr, cmd_err_arr, odt_err_arr : in int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); file file_pointer : text; variable pass: out integer) is
			variable file_line	: line;

			variable no_cmd_err	: boolean;
			variable no_ctrl_err	: boolean;
			variable no_odt_cmd_err	: boolean;

			variable cmd_match	: boolean;
		begin

			write(file_line, string'( "PHY Refresh Controller: Number of requests: " & integer'image(num_requests_exp)));
			writeline(file_pointer, file_line);

			no_cmd_err := compare_int_arr(reset_int_arr(0, num_requests_exp), cmd_err_arr, num_requests_exp);
			no_odt_cmd_err := compare_int_arr(reset_int_arr(0, num_requests_exp), odt_err_arr, num_requests_exp);
			no_ctrl_err := compare_int_arr(reset_int_arr(0, num_requests_exp), ctrl_err_arr, num_requests_exp);

			cmd_match := compare_int_arr_2d(cmd_arr_rtl, cmd_arr_exp, num_requests_exp, 2);

			if ((num_requests_exp = num_requests_rtl) and (no_cmd_err = true)  and (no_odt_cmd_err = true) and (no_ctrl_err = true) and (cmd_match = true)) then
				write(file_line, string'( "PHY Refresh Controller: PASS"));
				writeline(file_pointer, file_line);
				pass := 1;
			elsif (no_cmd_err = false) then
				write(file_line, string'( "PHY Refresh Controller: FAIL (Command Handshake Error)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_requests_exp - 1) loop
					write(file_line, string'( "PHY Refresh Controller: Request #" & integer'image(i) & ": " & integer'image(cmd_err_arr(i)) & " Error(s)"));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (no_odt_cmd_err = false) then
				write(file_line, string'( "PHY Refresh Controller: FAIL (ODT Command Handshake Error)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_requests_exp - 1) loop
					write(file_line, string'( "PHY Refresh Controller: Request #" & integer'image(i) & ": " & integer'image(odt_err_arr(i)) & " Error(s)"));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (no_ctrl_err = false) then
				write(file_line, string'( "PHY Refresh Controller: FAIL (Controller Handshake Error)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_requests_exp - 1) loop
					write(file_line, string'( "PHY Refresh Controller: Request #" & integer'image(i) & ": " & integer'image(ctrl_err_arr(i)) & " Error(s)"));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (num_requests_exp /= num_requests_rtl) then
				write(file_line, string'( "PHY Refresh Controller: FAIL (Number requests mismatch): exp " & integer'image(num_requests_exp) & " vs rtl " & integer'image(num_requests_rtl)));
				writeline(file_pointer, file_line);
				pass := 0;
			elsif (cmd_match = false) then
				write(file_line, string'( "PHY Refresh Controller: FAIL (Command mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_requests_exp - 1) loop
					for j in 0 to 1 loop
						write(file_line, string'( "PHY Refresh Controller: Request #" & integer'image(i) & " Command # " & integer'image(j) & ": exp " & integer'image(cmd_arr_exp(i, j)) & " vs rtl " & integer'image(cmd_arr_rtl(i, j))));
						writeline(file_pointer, file_line);
					end loop;
				end loop;
				pass := 0;
			else
				write(file_line, string'( "PHY Refresh Controller: FAIL (Unknown error)"));
				writeline(file_pointer, file_line);
				pass := 0;
			end if;
		end procedure verify;

		variable seed1, seed2	: positive;

		variable num_requests_exp		: integer;
		variable num_requests_rtl		: integer;

		variable high_temp		: boolean;

		variable self_refresh_arr		: bool_arr(0 to (MAX_REQUESTS_PER_TEST-1));
		variable ctrl_completed_delay_arr	: int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable cmd_req_ack_delay_arr		: int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable odt_cmd_req_ack_delay_arr	: int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable self_refresh_time_arr		: int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable bank_idle_delay_arr		: int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));

		variable cmd_arr_rtl			: int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to 1);
		variable cmd_arr_exp			: int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to 1);

		variable ctrl_err_arr			: int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable cmd_err_arr			: int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable odt_err_arr			: int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));

		variable pass		: integer;
		variable num_pass	: integer;

		file file_pointer	: text;
		variable file_line	: line;

	begin

		wait for 1 ns;

		num_pass := 0;

		reset;
		file_open(file_pointer, ddr2_ctrl_ref_ctrl_log_file, append_mode);

		write(file_line, string'( "PHY Refresh Controller Test"));
		writeline(file_pointer, file_line);

		for i in 0 to NUM_TEST-1 loop

			test_param(num_requests_exp, high_temp, self_refresh_arr, ctrl_completed_delay_arr, cmd_req_ack_delay_arr, odt_cmd_req_ack_delay_arr, self_refresh_time_arr, bank_idle_delay_arr, seed1, seed2);

			run_ref_ctrl(num_requests_exp, high_temp, self_refresh_arr, ctrl_completed_delay_arr, cmd_req_ack_delay_arr, odt_cmd_req_ack_delay_arr, self_refresh_time_arr, bank_idle_delay_arr, num_requests_rtl, cmd_arr_rtl, cmd_arr_exp, ctrl_err_arr, cmd_err_arr, odt_err_arr);

			verify(num_requests_exp, num_requests_rtl, cmd_arr_rtl, cmd_arr_exp, ctrl_err_arr, cmd_err_arr, odt_err_arr, file_pointer, pass);

			num_pass := num_pass + pass;

			wait until ((clk_tb'event) and (clk_tb = '1'));

		end loop;

		file_close(file_pointer);

		file_open(file_pointer, summary_file, append_mode);
		write(file_line, string'( "PHY Refresh Controller => PASSES: " & integer'image(num_pass) & " out of " & integer'image(TOT_NUM_TEST)));
		writeline(file_pointer, file_line);

		if (num_pass = TOT_NUM_TEST) then
			write(file_line, string'( "PHY Refresh Controller: TEST PASSED"));
		else
			write(file_line, string'( "PHY Refresh Controller: TEST FAILED: " & integer'image(TOT_NUM_TEST-num_pass) & " failures"));
		end if;
		writeline(file_pointer, file_line);

		file_close(file_pointer);
		stop <= true;

		wait;

	end process test;

end bench;
