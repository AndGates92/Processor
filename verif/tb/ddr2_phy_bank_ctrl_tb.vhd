library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;
use work.ddr2_pkg.all;
use work.ddr2_phy_pkg.all;
use work.ddr2_phy_bank_ctrl_pkg.all;
use work.tb_pkg.all;

entity ddr2_phy_bank_ctrl_tb is
end entity ddr2_phy_bank_ctrl_tb;

architecture bench of ddr2_phy_bank_ctrl_tb is

	constant CLK_PERIOD	: time := DDR2_CLK_PERIOD * 1 ns;
	constant NUM_TEST	: integer := 1000;
	constant NUM_EXTRA_TEST	: integer := MAX_OUTSTANDING_BURSTS;
	constant TOT_NUM_TEST	: integer := NUM_TEST + NUM_EXTRA_TEST;

	constant MAX_BURST_DELAY	: integer := 20;

	signal clk_tb	: std_logic := '0';
	signal stop	: boolean := false;
	signal rst_tb	: std_logic;

	-- User Interface
	signal RowMemIn_tb	: std_logic_vector(ROW_L - 1 downto 0);
	signal CtrlReq_tb	: std_logic;

	signal CtrlAck_tb	: std_logic;

	-- Arbitrer
	signal RowMemOut_tb	: std_logic_vector(ROW_L - 1 downto 0);
	signal CmdOut_tb	: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal CmdReq_tb	: std_logic;

	signal CmdAck_tb	: std_logic;

	-- Controller
	signal ZeroOutstandingBursts_tb	: std_logic;
	signal BankIdle_tb		: std_logic;
	signal BankActive_tb		: std_logic;

	signal EndDataPhase_tb		: std_logic;
	signal ReadBurst_tb		: std_logic;

begin

	DUT: ddr2_phy_bank_ctrl
	port map (
		clk => clk_tb,
		rst => rst_tb,

		RowMemIn => RowMemIn_tb,
		CtrlReq => CtrlReq_tb,

		CtrlAck => CtrlAck_tb,

		CmdAck => CmdAck_tb,

		RowMemOut => RowMemOut_tb,
		CmdOut => CmdOut_tb,
		CmdReq => CmdReq_tb,

		ReadBurst => ReadBurst_tb,
		EndDataPhase => EndDataPhase_tb,

		ZeroOutstandingBursts => ZeroOutstandingBursts_tb,
		BankIdle => BankIdle_tb,
		BankActive => BankActive_tb

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

		procedure setup_extra_tests(variable num_bursts : out int_arr(0 to (NUM_EXTRA_TEST-1)); variable rows: out int_arr(0 to ((NUM_EXTRA_TEST*MAX_OUTSTANDING_BURSTS) - 1)); variable read_burst: out bool_arr(0 to ((NUM_EXTRA_TEST*MAX_OUTSTANDING_BURSTS) - 1)); variable bl, cmd_delay: out int_arr(0 to ((NUM_EXTRA_TEST*MAX_OUTSTANDING_BURSTS) - 1)); variable seed1, seed2: inout positive) is
			variable rand_val		: real;
			variable scaled_rand_val	: integer;
		begin
			for i in 0 to NUM_EXTRA_TEST-1 loop
				scaled_rand_val := 0;
				while (scaled_rand_val = 0) loop
					uniform(seed1, seed2, rand_val);
					scaled_rand_val := integer(rand_val*real(MAX_OUTSTANDING_BURSTS));
				end loop;
				num_bursts(i) := scaled_rand_val;

				uniform(seed1, seed2, rand_val);
				rows((i*MAX_OUTSTANDING_BURSTS) to (((i+1)*MAX_OUTSTANDING_BURSTS) - 1)) := reset_int_arr(integer(rand_val*(2.0**(real(ROW_L)) - 1.0)), MAX_OUTSTANDING_BURSTS);

			end loop;

			for i in 0 to (MAX_OUTSTANDING_BURSTS*NUM_EXTRA_TEST)-1 loop
				if (i < MAX_OUTSTANDING_BURSTS) then
					bl(i) := 1;
				else
					scaled_rand_val := 0;
					while (scaled_rand_val = 0) loop
						uniform(seed1, seed2, rand_val);
						scaled_rand_val := integer(rand_val*(2.0**(real(COL_L)) - 1.0));
					end loop;
					bl(i) := scaled_rand_val;
				end if;
				uniform(seed1, seed2, rand_val);
				cmd_delay(i) := integer(rand_val*real(MAX_BURST_DELAY));
				uniform(seed1, seed2, rand_val);
				read_burst(i) := rand_bool(rand_val);
			end loop;


		end procedure setup_extra_tests;

		procedure test_param(variable num_bursts : out integer; variable rows: out int_arr(0 to (MAX_OUTSTANDING_BURSTS - 1)); variable read_burst: out bool_arr(0 to (MAX_OUTSTANDING_BURSTS - 1)); variable bl, cmd_delay: out int_arr(0 to (MAX_OUTSTANDING_BURSTS - 1)); variable seed1, seed2: inout positive) is
			variable rand_val	: real;
			variable num_bursts_int	: integer;
			variable bl_int		: integer;
		begin
			num_bursts_int := 0;
			while (num_bursts_int = 0) loop
				uniform(seed1, seed2, rand_val);
				num_bursts_int := integer(rand_val*real(MAX_OUTSTANDING_BURSTS));
			end loop;
			num_bursts := num_bursts_int;

			for i in 0 to (num_bursts_int - 1) loop
				uniform(seed1, seed2, rand_val);
				rows(i) := integer(rand_val*(2.0**(real(ROW_L)) - 1.0));
				bl_int := 0;
				while (bl_int = 0) loop
					uniform(seed1, seed2, rand_val);
					bl_int := integer(rand_val*(2.0**(real(COL_L)) - 1.0));
				end loop;
				bl(i) := bl_int;
				uniform(seed1, seed2, rand_val);
				cmd_delay(i) := integer(rand_val*real(MAX_BURST_DELAY));
				uniform(seed1, seed2, rand_val);
				read_burst(i) := rand_bool(rand_val);
			end loop;
			for i in num_bursts to (MAX_OUTSTANDING_BURSTS - 1) loop
				rows(i) := int_arr_def;
				bl(i) := int_arr_def;
				cmd_delay(i) := int_arr_def;
				read_burst(i) := false;
			end loop;
		end procedure test_param;

		procedure run_bank_ctrl (variable num_bursts_exp: in integer; variable cmd_delay_arr, rows_arr_exp, bl_arr : in int_arr(0 to (MAX_OUTSTANDING_BURSTS - 1)); variable read_arr : in bool_arr(0 to (MAX_OUTSTANDING_BURSTS - 1)); variable num_bursts_rtl : out integer; variable err_arr, rows_arr_rtl : out int_arr(0 to (MAX_OUTSTANDING_BURSTS - 1))) is
			variable row_cmd_cnt		: integer;
			variable data_phase_cnt		: integer;
			variable data_phase_burst_num	: integer;
			variable num_bursts_rtl_int	: integer;
			variable err_arr_int		: integer;
			variable ctrl_req		: boolean;
			variable cmd_req		: boolean;
			variable cmd_delay		: integer;
		begin
			num_bursts_rtl_int := 0;
			data_phase_burst_num := 0;
			row_cmd_cnt := 0;
			data_phase_cnt := 0;

			ReadBurst_tb <= '0';
			EndDataPhase_tb <= '0';
			CmdAck_tb <= '0';
			CtrlReq_tb <= '1';
			ctrl_req := true;

			err_arr_int := 0;

			RowMemIn_tb <= std_logic_vector(to_unsigned(rows_arr_exp(num_bursts_rtl_int), ROW_L));
			cmd_delay := cmd_delay_arr(num_bursts_rtl_int);

			act_loop: loop

				exit act_loop when ((num_bursts_rtl_int = num_bursts_exp) and (data_phase_burst_num = num_bursts_exp));

				if (ctrl_req = false) then
					for i in row_cmd_cnt to cmd_delay loop
						wait until ((clk_tb = '1') and (clk_tb'event));
						if (i = cmd_delay) then
							CtrlReq_tb <= '1';
							ctrl_req := true;
							RowMemIn_tb <= std_logic_vector(to_unsigned(rows_arr_exp(num_bursts_rtl_int), ROW_L));
							row_cmd_cnt := 0;
						end if;
					end loop;
				end if;

				-- wait bank to be in the idle state
				while (BankIdle_tb = '0') loop
					if (CtrlAck_tb = '1') then
						CtrlReq_tb <= '0';
						ctrl_req := false;
					end if;
					wait until ((clk_tb = '1') and (clk_tb'event));
				end loop;

				while (CmdReq_tb = '0') loop
					if (CtrlAck_tb = '1') then
						CtrlReq_tb <= '0';
						ctrl_req := false;
					end if;
					wait until ((clk_tb = '1') and (clk_tb'event));
				end loop;

				cmd_req := true;

				while(CmdReq_tb = '1' and CmdAck_tb = '0') loop
					if (CtrlAck_tb = '1') then
						if (ctrl_req = false) then
							err_arr_int := err_arr_int + 1;
						else
							CtrlReq_tb <= '0';
							ctrl_req := false;
							err_arr_int := 0;
						end if;
					end if;
					CmdAck_tb <= '1';
					rows_arr_rtl(num_bursts_rtl_int) := to_integer(unsigned(RowMemOut_tb));
					if (cmd_req = false) then
						err_arr_int := err_arr_int + 1;
					else
						cmd_req := false;
					end if;
					wait until ((clk_tb = '1') and (clk_tb'event));
				end loop;

				err_arr(num_bursts_rtl_int) := err_arr_int;
				num_bursts_rtl_int := num_bursts_rtl_int + 1;

				if (num_bursts_rtl_int < num_bursts_exp) then
					cmd_delay := cmd_delay_arr(num_bursts_rtl_int);
				end if;

				err_arr_int := 0;
				CmdAck_tb <= '0';

				while((ZeroOutstandingBursts_tb = '0') or (EndDataPhase_tb = '0')) loop
					wait until ((clk_tb = '1') and (clk_tb'event));
					-- Controller Row Request
					if (num_bursts_rtl_int < num_bursts_exp) then
						if (ctrl_req = false) then
							if (CtrlAck_tb = '1') then
								err_arr_int := err_arr_int + 1;
							end if;
							if (row_cmd_cnt = cmd_delay) then
								CtrlReq_tb <= '1';
								ctrl_req := true;
								RowMemIn_tb <= std_logic_vector(to_unsigned(rows_arr_exp(num_bursts_rtl_int), ROW_L));
								cmd_req := true;
								row_cmd_cnt := 0;
							else
								row_cmd_cnt := row_cmd_cnt + 1;
							end if;
						else
							if (CtrlAck_tb = '1') then
								if (ctrl_req = false) then
									err_arr_int := err_arr_int + 1;
								else
									CtrlReq_tb <= '0';
									ctrl_req := false;
									rows_arr_rtl(num_bursts_rtl_int) := to_integer(unsigned(RowMemOut_tb));
									err_arr(num_bursts_rtl_int) := err_arr_int;
									num_bursts_rtl_int := num_bursts_rtl_int + 1;
									cmd_delay := cmd_delay_arr(num_bursts_rtl_int);
									err_arr_int := 0;
								end if;
							end if;
						end if;
					else
						CtrlReq_tb <= '0';
						ctrl_req := false;
					end if;
					-- Data phase
					if (data_phase_burst_num < num_bursts_exp) then

						if (BankActive_tb = '1') then
							if (data_phase_cnt = bl_arr(data_phase_burst_num)) then
								data_phase_cnt := 0;
								ReadBurst_tb <= bool_to_std_logic(read_arr(data_phase_burst_num));
								data_phase_burst_num := data_phase_burst_num + 1;
								EndDataPhase_tb <= '1';
							else
								data_phase_cnt := data_phase_cnt + 1;
								EndDataPhase_tb <= '0';
							end if;
						else
							EndDataPhase_tb <= '0';
						end if;
					else
						EndDataPhase_tb <= '0';
					end if;
				end loop;

				wait until ((clk_tb = '1') and (clk_tb'event));
				EndDataPhase_tb <= '0';

			end loop;

			num_bursts_rtl := num_bursts_rtl_int;

			while (BankIdle_tb = '0') loop
				wait until ((clk_tb = '1') and (clk_tb'event));
			end loop;

		end procedure run_bank_ctrl;

		procedure verify(variable num_bursts_exp, num_bursts_rtl: in integer; variable err_arr, rows_arr_exp, rows_arr_rtl : in int_arr(0 to (MAX_OUTSTANDING_BURSTS - 1)); file file_pointer : text; variable pass: out integer) is
			variable match_rows	: boolean;
			variable no_errors	: boolean;
			variable file_line	: line;
		begin

			write(file_line, string'( "PHY Bank Controller Status: Bank Idle: " & bool_to_str(std_logic_to_bool(BankIdle_tb)) & " Bank Active: " & bool_to_str(std_logic_to_bool(BankActive_tb)) & " Number of bursts: exp " & integer'image(num_bursts_exp) & " rtl " & integer'image(num_bursts_rtl) & " No outstanding burst: " & bool_to_str(std_logic_to_bool(ZeroOutstandingBursts_tb))));
			writeline(file_pointer, file_line);

			match_rows := compare_int_arr(rows_arr_exp, rows_arr_rtl, num_bursts_exp);
			no_errors := compare_int_arr(reset_int_arr(0, num_bursts_exp), err_arr, num_bursts_exp);

			if ((BankActive_tb = '0') and (ZeroOutstandingBursts_tb = '1') and (BankIdle_tb = '1') and (match_rows = true) and (no_errors = true) and (num_bursts_exp = num_bursts_rtl)) then
				write(file_line, string'( "PHY Bank Controller: PASS"));
				writeline(file_pointer, file_line);
				pass := 1;
			elsif (BankIdle_tb = '0') then
				write(file_line, string'( "PHY Bank Controller: FAIL (Bank not in the idle)"));
				writeline(file_pointer, file_line);
				pass := 0;
			elsif (BankActive_tb = '1') then
				write(file_line, string'( "PHY Bank Controller: FAIL (Bank was not precharged after use)"));
				writeline(file_pointer, file_line);
				pass := 0;
			elsif (ZeroOutstandingBursts_tb = '0') then
				write(file_line, string'( "PHY Bank Controller: FAIL (Outstanding bursts)"));
				writeline(file_pointer, file_line);
				pass := 0;
			elsif (num_bursts_exp /= num_bursts_rtl) then
				write(file_line, string'( "PHY Bank Controller: FAIL (Number bursts mismatch: exp " & integer'image(num_bursts_exp) & " rtl " & integer'image(num_bursts_rtl)));
				writeline(file_pointer, file_line);
				pass := 0;
			elsif (match_rows = false) then
				write(file_line, string'( "PHY Bank Controller: FAIL (Row mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_bursts_exp - 1) loop
					write(file_line, string'( "PHY Bank Controller: Burst #" & integer'image(i) & " exp " & integer'image(rows_arr_exp(i))) & " vs rtl " & integer'image(rows_arr_rtl(i)));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (no_errors = false) then
				write(file_line, string'( "PHY Bank Controller: FAIL (Handshake Error)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_bursts_exp - 1) loop
					write(file_line, string'( "PHY Bank Controller: Error Burst #" & integer'image(i) & ": " & integer'image(err_arr(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			else
				write(file_line, string'( "PHY Bank Controller: FAIL (Unknown error)"));
				writeline(file_pointer, file_line);
				pass := 0;
			end if;
		end procedure verify;

		variable seed1, seed2	: positive;

		variable num_bursts_exp	: integer;
		variable rows_arr_exp	: int_arr(0 to (MAX_OUTSTANDING_BURSTS - 1));

		variable num_bursts_rtl	: integer;
		variable rows_arr_rtl	: int_arr(0 to (MAX_OUTSTANDING_BURSTS - 1));

		variable read_arr	: bool_arr(0 to (MAX_OUTSTANDING_BURSTS - 1));

		variable bl_arr		: int_arr(0 to (MAX_OUTSTANDING_BURSTS - 1));
		variable cmd_delay_arr	: int_arr(0 to (MAX_OUTSTANDING_BURSTS - 1));
		variable err_arr	: int_arr(0 to (MAX_OUTSTANDING_BURSTS - 1));

		variable num_bursts_exp_extra	: int_arr(0 to (NUM_EXTRA_TEST - 1));
		variable rows_arr_exp_extra	: int_arr(0 to ((NUM_EXTRA_TEST*MAX_OUTSTANDING_BURSTS) - 1));

		variable num_bursts_rtl_extra	: integer;
		variable rows_arr_rtl_extra	: int_arr(0 to (MAX_OUTSTANDING_BURSTS - 1));

		variable read_arr_extra	: bool_arr(0 to ((NUM_EXTRA_TEST*MAX_OUTSTANDING_BURSTS) - 1));

		variable bl_arr_extra		: int_arr(0 to ((NUM_EXTRA_TEST*MAX_OUTSTANDING_BURSTS) - 1));
		variable cmd_delay_arr_extra	: int_arr(0 to ((NUM_EXTRA_TEST*MAX_OUTSTANDING_BURSTS) - 1));
		variable err_arr_extra	: int_arr(0 to (MAX_OUTSTANDING_BURSTS - 1));


		variable pass	: integer;
		variable num_pass	: integer;

		file file_pointer	: text;
		variable file_line	: line;

	begin

		wait for 1 ns;

		num_pass := 0;

		reset;
		file_open(file_pointer, log_file, append_mode);

		write(file_line, string'( "PHY Bank Controller Test"));
		writeline(file_pointer, file_line);

		for i in 0 to NUM_TEST-1 loop

			test_param(num_bursts_exp, rows_arr_exp, read_arr, bl_arr, cmd_delay_arr, seed1, seed2);

			run_bank_ctrl(num_bursts_exp, cmd_delay_arr, rows_arr_exp, bl_arr, read_arr, num_bursts_rtl, err_arr, rows_arr_rtl);

			verify(num_bursts_exp, num_bursts_rtl, err_arr, rows_arr_exp, rows_arr_rtl, file_pointer, pass);

			num_pass := num_pass + pass;

			wait until ((clk_tb'event) and (clk_tb = '1'));
		end loop;

		if (NUM_EXTRA_TEST > 0) then

			setup_extra_tests(num_bursts_exp_extra, rows_arr_exp_extra, read_arr_extra, bl_arr_extra, cmd_delay_arr_extra, seed1, seed2);

			for i in 0 to NUM_EXTRA_TEST-1 loop

				run_bank_ctrl(num_bursts_exp_extra(i), cmd_delay_arr_extra((i*MAX_OUTSTANDING_BURSTS) to (((i+1)*MAX_OUTSTANDING_BURSTS)-1)), rows_arr_exp_extra((i*MAX_OUTSTANDING_BURSTS) to (((i+1)*MAX_OUTSTANDING_BURSTS)-1)), bl_arr_extra((i*MAX_OUTSTANDING_BURSTS) to (((i+1)*MAX_OUTSTANDING_BURSTS)-1)), read_arr_extra((i*MAX_OUTSTANDING_BURSTS) to (((i+1)*MAX_OUTSTANDING_BURSTS)-1)), num_bursts_rtl_extra, err_arr_extra, rows_arr_rtl_extra);

				verify(num_bursts_exp_extra(i), num_bursts_rtl_extra, err_arr_extra, rows_arr_exp_extra((i*MAX_OUTSTANDING_BURSTS) to (((i+1)*MAX_OUTSTANDING_BURSTS)-1)), rows_arr_rtl_extra, file_pointer, pass);

				num_pass := num_pass + pass;

				wait until ((clk_tb'event) and (clk_tb = '1'));
			end loop;

		end if;

		file_close(file_pointer);

		file_open(file_pointer, summary_file, append_mode);
		write(file_line, string'( "PHY Bank Controller => PASSES: " & integer'image(num_pass) & " out of " & integer'image(TOT_NUM_TEST)));
		writeline(file_pointer, file_line);

		if (num_pass = TOT_NUM_TEST) then
			write(file_line, string'( "PHY Bank Controller: TEST PASSED"));
		else
			write(file_line, string'( "PHY Bank Controller: TEST FAILED: " & integer'image(TOT_NUM_TEST-num_pass) & " failures"));
		end if;
		writeline(file_pointer, file_line);

		file_close(file_pointer);
		stop <= true;

	end process test;

end bench;
