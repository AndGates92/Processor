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
use ddr2_rtl_pkg.ddr2_define_pkg.all;
use ddr2_rtl_pkg.ddr2_phy_pkg.all;
use ddr2_rtl_pkg.ddr2_mrs_max_pkg.all;
use ddr2_rtl_pkg.ddr2_phy_bank_ctrl_pkg.all;
use ddr2_rtl_pkg.ddr2_gen_ac_timing_pkg.all;
library ddr2_tb_pkg;
use ddr2_tb_pkg.ddr2_pkg_tb.all;
use ddr2_tb_pkg.ddr2_log_pkg.all;

entity ddr2_phy_bank_ctrl_tb is
end entity ddr2_phy_bank_ctrl_tb;

architecture bench of ddr2_phy_bank_ctrl_tb is

	constant CLK_PERIOD	: time := DDR2_CLK_PERIOD * 1 ns;
	constant NUM_TEST	: integer := 1000;
	constant NUM_EXTRA_TEST	: integer := MAX_OUTSTANDING_BURSTS_TB;
	constant TOT_NUM_TEST	: integer := NUM_TEST + NUM_EXTRA_TEST;

	constant MAX_BURST_DELAY	: integer := 20;
	constant BANK_ID_TB		: integer := 0;

	signal clk_tb	: std_logic := '0';
	signal stop	: boolean := false;
	signal rst_tb	: std_logic;

	-- MRS configuration
	signal DDR2BurstLength_tb		: std_logic_vector(int_to_bit_num(BURST_LENGTH_MAX_VALUE) - 1 downto 0);
	signal DDR2AdditiveLatency_tb	: std_logic_vector(int_to_bit_num(AL_MAX_VALUE) - 1 downto 0);
	signal DDR2WriteLatency_tb		: std_logic_vector(int_to_bit_num(WRITE_LATENCY_MAX_VALUE) - 1 downto 0);

	-- User Interface
	signal RowMemIn_tb	: std_logic_vector(ROW_L_TB - 1 downto 0);
	signal CtrlReq_tb	: std_logic;

	signal CtrlAck_tb	: std_logic;

	-- Arbitrer
	signal RowMemOut_tb	: std_logic_vector(ROW_L_TB - 1 downto 0);
	signal BankMemOut_tb	: std_logic_vector(int_to_bit_num(BANK_NUM_TB) - 1 downto 0);
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

	DUT: ddr2_phy_bank_ctrl generic map (
		ROW_L => ROW_L_TB,
		BANK_ID => BANK_ID_TB,
		BANK_NUM => BANK_NUM_TB,
		MAX_OUTSTANDING_BURSTS => MAX_OUTSTANDING_BURSTS_TB
	)
	port map (
		clk => clk_tb,
		rst => rst_tb,

		DDR2BurstLength => DDR2BurstLength_tb,
		DDR2AdditiveLatency => DDR2AdditiveLatency_tb,
		DDR2WriteLatency => DDR2WriteLatency_tb,

		RowMemIn => RowMemIn_tb,

		CmdAck => CmdAck_tb,

		RowMemOut => RowMemOut_tb,
		BankMemOut => BankMemOut_tb,
		CmdOut => CmdOut_tb,
		CmdReq => CmdReq_tb,

		CtrlReq => CtrlReq_tb,
		ReadBurst => ReadBurst_tb,
		EndDataPhase => EndDataPhase_tb,

		CtrlAck => CtrlAck_tb,
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

		procedure setup_extra_tests(variable num_bursts, burst_bits, al, wl : out int_arr(0 to (NUM_EXTRA_TEST-1)); variable rows: out int_arr(0 to ((NUM_EXTRA_TEST*MAX_OUTSTANDING_BURSTS_TB) - 1)); variable read_burst: out bool_arr(0 to ((NUM_EXTRA_TEST*MAX_OUTSTANDING_BURSTS_TB) - 1)); variable bl, cmd_delay: out int_arr(0 to ((NUM_EXTRA_TEST*MAX_OUTSTANDING_BURSTS_TB) - 1)); variable seed1, seed2: inout positive) is
			variable rand_val		: real;
			variable scaled_rand_val	: integer;
			variable burst_bits_int		: integer;
			variable bl4_int		: boolean;
		begin
			bl4_int := false;
			for i in 0 to NUM_EXTRA_TEST-1 loop
				scaled_rand_val := 0;
				while (scaled_rand_val = 0) loop
					uniform(seed1, seed2, rand_val);
					scaled_rand_val := integer(rand_val*real(MAX_OUTSTANDING_BURSTS_TB));
				end loop;
				num_bursts(i) := scaled_rand_val;

				if ((i mod 2) = 0) then
					bl4_int := not bl4_int;
				end if;

				if (bl4_int = true) then
					burst_bits_int := 2;
				else
					burst_bits_int := 3;
				end if;
				burst_bits(i) := burst_bits_int;

				uniform(seed1, seed2, rand_val);
				al(i) := integer(rand_val*real(AL_MAX_VALUE));

				uniform(seed1, seed2, rand_val);
				wl(i) := integer(rand_val*real(WRITE_LATENCY_MAX_VALUE));

				uniform(seed1, seed2, rand_val);
				rows((i*MAX_OUTSTANDING_BURSTS_TB) to (((i+1)*MAX_OUTSTANDING_BURSTS_TB) - 1)) := reset_int_arr(integer(rand_val*(2.0**(real(ROW_L_TB)) - 1.0)), MAX_OUTSTANDING_BURSTS_TB);

			end loop;

			for i in 0 to (MAX_OUTSTANDING_BURSTS_TB*NUM_EXTRA_TEST)-1 loop
				if (i < MAX_OUTSTANDING_BURSTS_TB) then
					bl(i) := 1;
				else
					scaled_rand_val := 0;
					while (scaled_rand_val = 0) loop
						uniform(seed1, seed2, rand_val);
						scaled_rand_val := integer(rand_val*(2.0**(real(COL_L_TB)) - 1.0));
					end loop;
					bl(i) := scaled_rand_val;
				end if;
				uniform(seed1, seed2, rand_val);
				cmd_delay(i) := integer(rand_val*real(MAX_BURST_DELAY));
				uniform(seed1, seed2, rand_val);
				read_burst(i) := rand_bool(rand_val, 0.5);
			end loop;


		end procedure setup_extra_tests;

		procedure test_param(variable num_bursts, burst_bits, al, wl : out integer; variable rows: out int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1)); variable read_burst: out bool_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1)); variable bl, cmd_delay: out int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1)); variable seed1, seed2: inout positive) is
			variable rand_val	: real;
			variable bl4_int	: boolean;
			variable num_bursts_int	: integer;
			variable bl_int		: integer;
			variable burst_bits_int	: integer;
		begin
			num_bursts_int := 0;
			while (num_bursts_int = 0) loop
				uniform(seed1, seed2, rand_val);
				num_bursts_int := integer(rand_val*real(MAX_OUTSTANDING_BURSTS_TB));
			end loop;
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

			for i in 0 to (num_bursts_int - 1) loop
				uniform(seed1, seed2, rand_val);
				rows(i) := integer(rand_val*(2.0**(real(ROW_L_TB)) - 1.0));
				bl_int := 0;
				while (bl_int = 0) loop
					uniform(seed1, seed2, rand_val);
					bl_int := integer(rand_val*(2.0**(real(COL_L_TB)) - 1.0));
				end loop;
				bl(i) := bl_int;
				uniform(seed1, seed2, rand_val);
				cmd_delay(i) := integer(rand_val*real(MAX_BURST_DELAY));
				uniform(seed1, seed2, rand_val);
				read_burst(i) := rand_bool(rand_val, 0.5);
			end loop;
			for i in num_bursts to (MAX_OUTSTANDING_BURSTS_TB - 1) loop
				rows(i) := int_arr_def;
				bl(i) := int_arr_def;
				cmd_delay(i) := int_arr_def;
				read_burst(i) := false;
			end loop;
		end procedure test_param;

		procedure run_bank_ctrl (variable num_bursts_exp, burst_bits, al, wl: in integer; variable cmd_delay_arr, rows_arr_exp, bl_arr : in int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1)); variable read_arr : in bool_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1)); variable num_bursts_rtl : out integer; variable err_arr, rows_arr_rtl, bank_arr_rtl : out int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1))) is
			variable row_cmd_cnt		: integer;
			variable row_ctrl_cnt		: integer;
			variable data_phase_cnt		: integer;
			variable data_phase_burst_num	: integer;
			variable num_bursts_rtl_int	: integer;
			variable num_cmd_rtl_int	: integer;
			variable err_arr_int		: integer;
			variable ctrl_req		: boolean;
			variable cmd_delay		: integer;
			variable ctrl_delay		: integer;
		begin
			num_bursts_rtl_int := 0;
			num_cmd_rtl_int := 0;
			data_phase_burst_num := 0;
			row_cmd_cnt := 0;
			row_ctrl_cnt := 0;
			data_phase_cnt := 0;

			ReadBurst_tb <= '0';
			EndDataPhase_tb <= '0';
			CmdAck_tb <= '0';
			CtrlReq_tb <= '1';
			ctrl_req := true;

			err_arr_int := 0;

			RowMemIn_tb <= std_logic_vector(to_unsigned(rows_arr_exp(num_bursts_rtl_int), ROW_L_TB));
			cmd_delay := cmd_delay_arr(num_bursts_rtl_int);
			ctrl_delay := cmd_delay_arr(num_cmd_rtl_int);

			DDR2BurstLength_tb <= std_logic_vector(to_unsigned(burst_bits, int_to_bit_num(BURST_LENGTH_MAX_VALUE)));
			DDR2AdditiveLatency_tb <= std_logic_vector(to_unsigned(al, int_to_bit_num(AL_MAX_VALUE)));
			DDR2WriteLatency_tb <= std_logic_vector(to_unsigned(wl, int_to_bit_num(WRITE_LATENCY_MAX_VALUE)));

			act_loop: loop

				wait until ((clk_tb = '1') and (clk_tb'event));

				exit act_loop when ((num_bursts_rtl_int = num_bursts_exp) and (data_phase_burst_num = num_bursts_exp));

				wait for 1 ps;

				-- Controller Row Request
				if (num_bursts_rtl_int < num_bursts_exp) then

					ctrl_delay := cmd_delay_arr(num_bursts_rtl_int);

					if (ctrl_req = false) then
						if (CtrlAck_tb = '1') then
							err_arr_int := err_arr_int + 1;
						end if;
						if (row_ctrl_cnt = ctrl_delay) then
							CtrlReq_tb <= '1';
							ctrl_req := true;
							RowMemIn_tb <= std_logic_vector(to_unsigned(rows_arr_exp(num_bursts_rtl_int), ROW_L_TB));
							row_ctrl_cnt := 0;
						else
							row_ctrl_cnt := row_ctrl_cnt + 1;
						end if;
					else
						if (CtrlAck_tb = '1') then
							if (ctrl_req = false) then
								err_arr_int := err_arr_int + 1;
							else
								CtrlReq_tb <= '0';
								ctrl_req := false;
								err_arr(num_bursts_rtl_int) := err_arr_int;
								num_bursts_rtl_int := num_bursts_rtl_int + 1;
								err_arr_int := 0;
							end if;
						end if;
					end if;
				else
					CtrlReq_tb <= '0';
					ctrl_req := false;
				end if;

				-- Activate Request
				if (num_cmd_rtl_int < num_bursts_exp) then

					cmd_delay := cmd_delay_arr(num_cmd_rtl_int);

					if (CmdReq_tb = '1') then
						if (row_cmd_cnt = cmd_delay) then
							CmdAck_tb <= '1';
							rows_arr_rtl(num_cmd_rtl_int) := to_integer(unsigned(RowMemOut_tb));
							bank_arr_rtl(num_cmd_rtl_int) := to_integer(unsigned(BankMemOut_tb));
							num_cmd_rtl_int := num_cmd_rtl_int + 1;
							row_cmd_cnt := 0;
						else
							row_cmd_cnt := row_cmd_cnt + 1;
						end if;
					else
						CmdAck_tb <= '0';
						if (rows_arr_exp(num_cmd_rtl_int) = rows_arr_exp(num_cmd_rtl_int - 1)) then
							rows_arr_rtl(num_cmd_rtl_int) := rows_arr_exp(num_cmd_rtl_int);
							bank_arr_rtl(num_cmd_rtl_int) := BANK_ID_TB;
							num_cmd_rtl_int := num_cmd_rtl_int + 1;
						end if;
					end if;
				else
					CmdAck_tb <= '0';
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

			num_bursts_rtl := num_bursts_rtl_int;

			while (BankIdle_tb = '0') loop
				wait until ((clk_tb = '1') and (clk_tb'event));
			end loop;

		end procedure run_bank_ctrl;

		procedure verify(variable num_bursts_exp, num_bursts_rtl: in integer; variable err_arr, rows_arr_exp, rows_arr_rtl, bank_arr_rtl : in int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1)); file file_pointer : text; variable pass: out integer) is
			variable match_rows	: boolean;
			variable match_banks	: boolean;
			variable no_errors	: boolean;
			variable file_line	: line;
		begin

			write(file_line, string'( "PHY Bank Controller Status: Bank Idle: " & std_logic_to_str(BankIdle_tb) & " Bank Active: " & std_logic_to_str(BankActive_tb) & " Number of bursts: exp " & integer'image(num_bursts_exp) & " rtl " & integer'image(num_bursts_rtl) & " No outstanding burst: " & std_logic_to_str(ZeroOutstandingBursts_tb)));
			writeline(file_pointer, file_line);

			match_rows := compare_int_arr(rows_arr_exp, rows_arr_rtl, num_bursts_exp);
			match_banks := compare_int_arr(reset_int_arr(BANK_ID_TB, num_bursts_exp), bank_arr_rtl, num_bursts_exp);
			no_errors := compare_int_arr(reset_int_arr(0, num_bursts_exp), err_arr, num_bursts_exp);

			if ((BankActive_tb = '0') and (ZeroOutstandingBursts_tb = '1') and (BankIdle_tb = '1') and (match_rows = true) and (match_banks = true) and (no_errors = true) and (num_bursts_exp = num_bursts_rtl)) then
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
				write(file_line, string'( "PHY Bank Controller: FAIL (Number bursts mismatch): exp " & integer'image(num_bursts_exp) & " vs rtl " & integer'image(num_bursts_rtl)));
				writeline(file_pointer, file_line);
				pass := 0;
			elsif (match_rows = false) then
				write(file_line, string'( "PHY Bank Controller: FAIL (Row mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_bursts_exp - 1) loop
					write(file_line, string'( "PHY Bank Controller: Burst #" & integer'image(i) & " exp " & integer'image(rows_arr_exp(i)) & " vs rtl " & integer'image(rows_arr_rtl(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (match_banks = false) then
				write(file_line, string'( "PHY Bank Controller: FAIL (Bank mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_bursts_exp - 1) loop
					write(file_line, string'( "PHY Bank Controller: Burst #" & integer'image(i) & " exp " & integer'image(BANK_ID_TB) & " vs rtl " & integer'image(bank_arr_rtl(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (no_errors = false) then
				write(file_line, string'( "PHY Bank Controller: FAIL (Handshake Error)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_bursts_exp - 1) loop
					write(file_line, string'( "PHY Bank Controller: Error Burst #" & integer'image(i) & ": " & integer'image(err_arr(i)) & " Error(s)"));
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
		variable rows_arr_exp	: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));

		variable burst_bits	: integer;
		variable al		: integer;
		variable wl		: integer;

		variable num_bursts_rtl	: integer;
		variable rows_arr_rtl	: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));
		variable bank_arr_rtl	: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));

		variable read_arr	: bool_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));

		variable bl_arr		: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));
		variable cmd_delay_arr	: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));
		variable err_arr	: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));

		variable num_bursts_exp_extra	: int_arr(0 to (NUM_EXTRA_TEST - 1));
		variable rows_arr_exp_extra	: int_arr(0 to ((NUM_EXTRA_TEST*MAX_OUTSTANDING_BURSTS_TB) - 1));

		variable burst_bits_extra	: int_arr(0 to (NUM_EXTRA_TEST - 1));
		variable al_extra		: int_arr(0 to (NUM_EXTRA_TEST - 1));
		variable wl_extra		: int_arr(0 to (NUM_EXTRA_TEST - 1));

		variable num_bursts_rtl_extra	: integer;
		variable rows_arr_rtl_extra	: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));
		variable bank_arr_rtl_extra	: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));

		variable read_arr_extra	: bool_arr(0 to ((NUM_EXTRA_TEST*MAX_OUTSTANDING_BURSTS_TB) - 1));

		variable bl_arr_extra		: int_arr(0 to ((NUM_EXTRA_TEST*MAX_OUTSTANDING_BURSTS_TB) - 1));
		variable cmd_delay_arr_extra	: int_arr(0 to ((NUM_EXTRA_TEST*MAX_OUTSTANDING_BURSTS_TB) - 1));
		variable err_arr_extra	: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));

		variable pass	: integer;
		variable num_pass	: integer;

		file file_pointer	: text;
		variable file_line	: line;

	begin

		wait for 1 ns;

		num_pass := 0;

		reset;
		file_open(file_pointer, ddr2_phy_bank_ctrl_log_file, append_mode);

		write(file_line, string'( "PHY Bank Controller Test"));
		writeline(file_pointer, file_line);

		for i in 0 to NUM_TEST-1 loop

			test_param(num_bursts_exp, burst_bits, al, wl, rows_arr_exp, read_arr, bl_arr, cmd_delay_arr, seed1, seed2);

			run_bank_ctrl(num_bursts_exp, burst_bits, al, wl, cmd_delay_arr, rows_arr_exp, bl_arr, read_arr, num_bursts_rtl, err_arr, rows_arr_rtl, bank_arr_rtl);

			verify(num_bursts_exp, num_bursts_rtl, err_arr, rows_arr_exp, rows_arr_rtl, bank_arr_rtl, file_pointer, pass);

			num_pass := num_pass + pass;

			wait until ((clk_tb'event) and (clk_tb = '1'));
		end loop;

		if (NUM_EXTRA_TEST > 0) then

			setup_extra_tests(num_bursts_exp_extra, burst_bits_extra, al_extra, wl_extra, rows_arr_exp_extra, read_arr_extra, bl_arr_extra, cmd_delay_arr_extra, seed1, seed2);

			for i in 0 to NUM_EXTRA_TEST-1 loop

				run_bank_ctrl(num_bursts_exp_extra(i), burst_bits_extra(i), al_extra(i), wl_extra(i), cmd_delay_arr_extra((i*MAX_OUTSTANDING_BURSTS_TB) to (((i+1)*MAX_OUTSTANDING_BURSTS_TB)-1)), rows_arr_exp_extra((i*MAX_OUTSTANDING_BURSTS_TB) to (((i+1)*MAX_OUTSTANDING_BURSTS_TB)-1)), bl_arr_extra((i*MAX_OUTSTANDING_BURSTS_TB) to (((i+1)*MAX_OUTSTANDING_BURSTS_TB)-1)), read_arr_extra((i*MAX_OUTSTANDING_BURSTS_TB) to (((i+1)*MAX_OUTSTANDING_BURSTS_TB)-1)), num_bursts_rtl_extra, err_arr_extra, rows_arr_rtl_extra, bank_arr_rtl_extra);

				verify(num_bursts_exp_extra(i), num_bursts_rtl_extra, err_arr_extra, rows_arr_exp_extra((i*MAX_OUTSTANDING_BURSTS_TB) to (((i+1)*MAX_OUTSTANDING_BURSTS_TB)-1)), rows_arr_rtl_extra, bank_arr_rtl_extra, file_pointer, pass);

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

		wait;

	end process test;

end bench;
