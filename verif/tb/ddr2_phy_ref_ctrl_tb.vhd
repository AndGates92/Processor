library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;
use work.ddr2_phy_pkg.all;
use work.ddr2_mrs_pkg.all;
use work.ddr2_gen_ac_timing_pkg.all;
use work.ddr2_phy_ref_ctrl_pkg.all;
use work.type_conversion_pkg.all;
use work.tb_pkg.all;
use work.proc_pkg.all;
use work.ddr2_pkg_tb.all;

entity ddr2_phy_ref_ctrl_tb is
end entity ddr2_phy_ref_ctrl_tb;

architecture bench of ddr2_phy_ref_ctrl_tb is

	constant CLK_PERIOD	: time := DDR2_CLK_PERIOD * 1 ns;
	constant NUM_TEST	: integer := 1000;
	constant NUM_EXTRA_TEST	: integer := 0;
	constant TOT_NUM_TEST	: integer := NUM_TEST + NUM_EXTRA_TEST;

	constant MAX_REQUESTS_PER_TEST		: integer := 50;
	constant MAX_SELF_REFRESH_TIME		: integer := 2*AUTO_REF_TIME;
	constant MAX_CMD_REQ_ACK_DELAY		: integer := 20;
	constant MAX_ODT_CMD_REQ_ACK_DELAY	: integer := 20;
	constant MAX_BANK_IDLE_DELAY		: integer := AUTO_REF_TIME;

	signal clk_tb	: std_logic := '0';
	signal stop	: boolean := false;
	signal rst_tb	: std_logic;

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

	signal ODTDisable_tb		: std_logic;
	signal ODTCtrlReq_tb		: std_logic;

	-- Arbitrer
	signal CmdAck_tb		: std_logic;

	signal CmdOut_tb		: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal CmdReq_tb		: std_logic;

	-- Controller
	signal CtrlReq_tb		: std_logic;

	signal CtrlAck_tb		: std_logic;



begin

	DUT: ddr2_phy_ref_ctrl generic map (
		BANK_NUM => BANK_NUM_TB
	)
	port map (
		clk => clk_tb,
		rst => rst_tb,

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

		ODTDisable => ODTDisable_tb,
		ODTCtrlReq => ODTCtrlReq_tb,

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

		procedure test_param(variable num_requests : out integer; variable self_refresh: out bool_arr(0 to (MAX_REQUESTS_PER_TEST); variable cmd_req_ack_delay, odt_cmd_req_ack_delay, self_refresh_time, bank_idle_delay: out int_arr(0 to (MAX_REQUESTS_PER_TEST); variable seed1, seed2: inout positive) is
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
				uniform(seed1, seed2, rand_val);
				cmd_req_ack_delay(i) := integer(rand_val*real(MAX_CMD_REQ_ACK_DELAY));
				uniform(seed1, seed2, rand_val);
				odt_cmd_req_ack_delay(i) := integer(rand_val*real(MAX_ODT_CMD_REQ_ACK_DELAY));
				uniform(seed1, seed2, rand_val);
				self_refresh_time(i) := integer(rand_val*real(MAX_SELF_REFRESH_TIME));
				uniform(seed1, seed2, rand_val);
				bank_idle_delay(i) := integer(rand_val*real(MAX_BANK_IDLE_DELAY));
				uniform(seed1, seed2, rand_val);
				self_refresh(i) := rand_bool(rand_val);
			end loop;
			for i in num_requests_int to (MAX_REQUESTS_PER_TEST - 1) loop
				cmd_req_ack_delay(i) := int_arr_def;
				odt_cmd_req_ack_delay(i) := int_arr_def;
				self_refresh_time(i) := int_arr_def;
				bank_idle_delay(i) := int_arr_def;
				self_refresh(i) := false;
			end loop;

		end procedure test_param;

		procedure verify(variable num_bursts_exp, num_bursts_rtl: in integer; variable err_arr, col_err_arr, start_col_arr_exp : in int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1)); variable col_err_arr_exp, col_err_arr_rtl : in int_arr_2d(0 to (MAX_OUTSTANDING_BURSTS_TB - 1), 0 to (integer(2.0**(real(BURST_LENGTH_L_TB)) - 1.0))); variable bank_arr_exp, bank_arr_rtl, bl_arr_exp, bl_arr_rtl : in int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1)); variable read_arr_exp, read_arr_rtl : in bool_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1)); file file_pointer : text; variable pass: out integer) is
			variable match_cols		: boolean;
			variable match_banks		: boolean;
			variable match_bl		: boolean;
			variable match_read_burst	: boolean;
			variable no_errors		: boolean;
			variable file_line		: line;
		begin

			write(file_line, string'( "PHY Refresh Controller: Number of bursts: " & integer'image(num_bursts_exp)));
			writeline(file_pointer, file_line);

			no_errors := compare_int_arr(reset_int_arr(0, num_bursts_exp), err_arr, num_bursts_exp);
			match_cols := compare_int_arr(reset_int_arr(0, num_bursts_exp), col_err_arr, num_bursts_exp);
			match_banks := compare_int_arr(bank_arr_exp, bank_arr_rtl, num_bursts_exp);
			match_read_burst := compare_bool_arr(read_arr_exp, read_arr_rtl, num_bursts_exp);
			match_bl := compare_int_arr(bl_arr_exp, bl_arr_rtl, num_bursts_exp);

			if ((match_bl = true) and (match_read_burst = true) and (match_banks = true) and (match_cols = true) and (no_errors = true) and (num_bursts_exp = num_bursts_rtl)) then
				for i in 0 to (num_bursts_exp - 1) loop
					write(file_line, string'( "PHY Column Controller: Burst #" & integer'image(i) & " details: Start Col " & integer'image(start_col_arr_exp(i)) & " Burst Length " & integer'image(bl_arr_exp(i))));
					writeline(file_pointer, file_line);
				end loop;
				write(file_line, string'( "PHY Column Controller: PASS"));
				writeline(file_pointer, file_line);
				pass := 1;
			elsif (match_bl = false) then
				write(file_line, string'( "PHY Column Controller: FAIL (Burst Length mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_bursts_exp - 1) loop
					write(file_line, string'( "PHY Column Controller: Burst #" & integer'image(i) & " Beats: exp " & integer'image(bl_arr_exp(i)) & " vs rtl " & integer'image(bl_arr_rtl(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (match_read_burst = false) then
				write(file_line, string'( "PHY Column Controller: FAIL (Read Burst count mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_bursts_exp - 1) loop
					write(file_line, string'( "PHY Column Controller: Read Burst #" & integer'image(i) & " exp " & bool_to_str(read_arr_exp(i)) & " vs rtl " & bool_to_str(read_arr_rtl(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (match_cols = false) then
				write(file_line, string'( "PHY Column Controller: FAIL (Col mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_bursts_exp - 1) loop
					write(file_line, string'( "========================================================================================"));
					writeline(file_pointer, file_line);
					write(file_line, string'( "PHY Column Controller: Burst #" & integer'image(i) & " details: Start Col " & integer'image(start_col_arr_exp(i)) & " Burst Length " & integer'image(bl_arr_exp(i))));
					writeline(file_pointer, file_line);
					for j in 0 to (col_err_arr(i) - 1) loop
						write(file_line, string'( "PHY Column Controller: Burst #" & integer'image(i) & " exp " & integer'image(col_err_arr_exp(i, j)) & " vs rtl " & integer'image(col_err_arr_rtl(i, j))));
						writeline(file_pointer, file_line);
					end loop;
				end loop;
				write(file_line, string'( "========================================================================================"));
				writeline(file_pointer, file_line);
				pass := 0;
			elsif (num_bursts_exp /= num_bursts_rtl) then
				write(file_line, string'( "PHY Column Controller: FAIL (Number bursts mismatch): exp " & integer'image(num_bursts_exp) & " rtl " & integer'image(num_bursts_rtl)));
				writeline(file_pointer, file_line);
				pass := 0;
			elsif (match_banks = false) then
				write(file_line, string'( "PHY Column Controller: FAIL (Bank mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_bursts_exp - 1) loop
					write(file_line, string'( "PHY Column Controller: Burst #" & integer'image(i) & " exp " & integer'image(bank_arr_exp(i))) & " vs rtl " & integer'image(bank_arr_rtl(i)));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (no_errors = false) then
				write(file_line, string'( "PHY Column Controller: FAIL (Handshake Error)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_bursts_exp - 1) loop
					write(file_line, string'( "PHY Column Controller: Error Burst #" & integer'image(i) & ": " & integer'image(err_arr(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			else
				write(file_line, string'( "PHY Column Controller: FAIL (Unknown error)"));
				writeline(file_pointer, file_line);
				pass := 0;
			end if;
		end procedure verify;

		variable seed1, seed2	: positive;

		variable num_bursts_exp	: integer;
		variable num_bursts_rtl	: integer;

		variable start_col_arr_exp	: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));
		variable cols_arr		: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));
		variable col_err_arr		: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));

		variable read_arr_exp		: bool_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));
		variable read_arr_rtl		: bool_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));
		variable last_arr		: bool_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));

		variable bank_arr_exp		: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));
		variable bl_arr_exp		: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));

		variable bank_arr_rtl		: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));
		variable bl_arr_rtl		: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));

		variable cmd_delay_arr		: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));
		variable cmd_act_delay_arr	: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));
		variable cmd_ack_ack_delay_arr	: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));
		variable err_arr		: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));

		variable col_err_arr_exp	: int_arr_2d(0 to (MAX_OUTSTANDING_BURSTS_TB - 1), 0 to (integer(2.0**(real(BURST_LENGTH_L_TB)) - 1.0)));
		variable col_err_arr_rtl	: int_arr_2d(0 to (MAX_OUTSTANDING_BURSTS_TB - 1), 0 to (integer(2.0**(real(BURST_LENGTH_L_TB)) - 1.0)));

		variable num_bursts_exp_extra		: int_arr(0 to (NUM_EXTRA_TEST - 1));
		variable num_bursts_rtl_extra		: integer;

		variable start_col_arr_exp_extra	: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));
		variable cols_arr_extra			: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB*NUM_EXTRA_TEST - 1));
		variable col_err_arr_extra		: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));

		variable read_arr_exp_extra		: bool_arr(0 to (MAX_OUTSTANDING_BURSTS_TB*NUM_EXTRA_TEST - 1));
		variable read_arr_rtl_extra		: bool_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));
		variable last_arr_extra			: bool_arr(0 to (MAX_OUTSTANDING_BURSTS_TB*NUM_EXTRA_TEST - 1));

		variable bank_arr_exp_extra		: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB*NUM_EXTRA_TEST - 1));
		variable bl_arr_exp_extra		: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB*NUM_EXTRA_TEST - 1));

		variable bank_arr_rtl_extra		: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));
		variable bl_arr_rtl_extra		: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));

		variable cmd_delay_arr_extra		: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB*NUM_EXTRA_TEST - 1));
		variable cmd_act_delay_arr_extra	: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB*NUM_EXTRA_TEST - 1));
		variable cmd_ack_ack_delay_arr_extra	: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB*NUM_EXTRA_TEST - 1));
		variable err_arr_extra			: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));

		variable col_err_arr_exp_extra		: int_arr_2d(0 to (MAX_OUTSTANDING_BURSTS_TB - 1), 0 to (integer(2.0**(real(BURST_LENGTH_L_TB)) - 1.0)));
		variable col_err_arr_rtl_extra		: int_arr_2d(0 to (MAX_OUTSTANDING_BURSTS_TB - 1), 0 to (integer(2.0**(real(BURST_LENGTH_L_TB)) - 1.0)));

		variable pass		: integer;
		variable num_pass	: integer;

		file file_pointer	: text;
		variable file_line	: line;

	begin

		wait for 1 ns;

		num_pass := 0;

		reset;
		file_open(file_pointer, log_file, append_mode);

		write(file_line, string'( "PHY Column Controller Test"));
		writeline(file_pointer, file_line);

		for i in 0 to NUM_TEST-1 loop

			test_param(num_bursts_exp, cols_arr, read_arr_exp, last_arr, bl_arr_exp, cmd_delay_arr, cmd_act_delay_arr, cmd_ack_ack_delay_arr, bank_arr_exp, seed1, seed2);

			run_col_ctrl(num_bursts_exp, cmd_ack_ack_delay_arr, cmd_delay_arr, cmd_act_delay_arr, cols_arr, bl_arr_exp, bank_arr_exp, read_arr_exp, last_arr, num_bursts_rtl, read_arr_rtl, err_arr, bl_arr_rtl, bank_arr_rtl, col_err_arr, start_col_arr_exp, col_err_arr_exp, col_err_arr_rtl);

			verify(num_bursts_exp, num_bursts_rtl, err_arr, col_err_arr, start_col_arr_exp, col_err_arr_exp, col_err_arr_rtl, bank_arr_exp, bank_arr_rtl, bl_arr_exp, bl_arr_rtl, read_arr_exp, read_arr_rtl, file_pointer, pass);

			num_pass := num_pass + pass;

			wait until ((clk_tb'event) and (clk_tb = '1'));

		end loop;

		if (NUM_EXTRA_TEST > 0) then

			setup_extra_tests(num_bursts_exp_extra, cols_arr_extra, read_arr_exp_extra, last_arr_extra, bl_arr_exp_extra, cmd_delay_arr_extra, cmd_act_delay_arr_extra, cmd_ack_ack_delay_arr_extra, bank_arr_exp_extra, seed1, seed2);

			for i in 0 to NUM_EXTRA_TEST-1 loop

				reset;

				run_col_ctrl(num_bursts_exp_extra(i), cmd_ack_ack_delay_arr_extra((i*MAX_OUTSTANDING_BURSTS_TB) to (((i+1)*MAX_OUTSTANDING_BURSTS_TB) - 1)), cmd_delay_arr_extra((i*MAX_OUTSTANDING_BURSTS_TB) to (((i+1)*MAX_OUTSTANDING_BURSTS_TB) - 1)), cmd_act_delay_arr_extra((i*MAX_OUTSTANDING_BURSTS_TB) to (((i+1)*MAX_OUTSTANDING_BURSTS_TB) - 1)), cols_arr_extra((i*MAX_OUTSTANDING_BURSTS_TB) to (((i+1)*MAX_OUTSTANDING_BURSTS_TB) - 1)), bl_arr_exp_extra((i*MAX_OUTSTANDING_BURSTS_TB) to (((i+1)*MAX_OUTSTANDING_BURSTS_TB) - 1)), bank_arr_exp_extra((i*MAX_OUTSTANDING_BURSTS_TB) to (((i+1)*MAX_OUTSTANDING_BURSTS_TB) - 1)), read_arr_exp_extra((i*MAX_OUTSTANDING_BURSTS_TB) to (((i+1)*MAX_OUTSTANDING_BURSTS_TB) - 1)), last_arr_extra((i*MAX_OUTSTANDING_BURSTS_TB) to (((i+1)*MAX_OUTSTANDING_BURSTS_TB) - 1)), num_bursts_rtl_extra, read_arr_rtl_extra, err_arr_extra, bl_arr_rtl_extra, bank_arr_rtl_extra, col_err_arr_extra, start_col_arr_exp_extra, col_err_arr_exp_extra, col_err_arr_rtl_extra);

				verify(num_bursts_exp_extra(i), num_bursts_rtl_extra, err_arr_extra, col_err_arr_extra, start_col_arr_exp_extra, col_err_arr_exp_extra, col_err_arr_rtl_extra, bank_arr_exp_extra((i*MAX_OUTSTANDING_BURSTS_TB) to (((i+1)*MAX_OUTSTANDING_BURSTS_TB) - 1)), bank_arr_rtl_extra, bl_arr_exp_extra((i*MAX_OUTSTANDING_BURSTS_TB) to (((i+1)*MAX_OUTSTANDING_BURSTS_TB) - 1)), bl_arr_rtl_extra, read_arr_exp_extra((i*MAX_OUTSTANDING_BURSTS_TB) to (((i+1)*MAX_OUTSTANDING_BURSTS_TB) - 1)), read_arr_rtl_extra, file_pointer, pass);

				num_pass := num_pass + pass;

				wait until ((clk_tb'event) and (clk_tb = '1'));

			end loop;

		end if;

		file_close(file_pointer);

		file_open(file_pointer, summary_file, append_mode);
		write(file_line, string'( "PHY Column Controller => PASSES: " & integer'image(num_pass) & " out of " & integer'image(TOT_NUM_TEST)));
		writeline(file_pointer, file_line);

		if (num_pass = TOT_NUM_TEST) then
			write(file_line, string'( "PHY Column Controller: TEST PASSED"));
		else
			write(file_line, string'( "PHY Column Controller: TEST FAILED: " & integer'image(TOT_NUM_TEST-num_pass) & " failures"));
		end if;
		writeline(file_pointer, file_line);

		file_close(file_pointer);
		stop <= true;

	end process test;

end bench;
