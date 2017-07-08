library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;
use work.ddr2_phy_pkg.all;
use work.ddr2_mrs_pkg.all;
use work.ddr2_timing_pkg.all;
use work.ddr2_phy_col_ctrl_pkg.all;
use work.tb_pkg.all;
use work.proc_pkg.all;
use work.ddr2_pkg_tb.all;

entity ddr2_phy_col_ctrl_tb is
end entity ddr2_phy_col_ctrl_tb;

architecture bench of ddr2_phy_col_ctrl_tb is

	constant CLK_PERIOD	: time := DDR2_CLK_PERIOD * 1 ns;
	constant NUM_TEST	: integer := 1000;
	constant NUM_EXTRA_TEST	: integer := 0; -- MAX_OUTSTANDING_BURSTS_TB;
	constant TOT_NUM_TEST	: integer := NUM_TEST + NUM_EXTRA_TEST;

	constant MAX_BURST_DELAY	: integer := 20;
	constant MAX_CMD_ACK_ACK_DELAY	: integer := 4;

	constant BURST_LENGTH_L_TB	: integer := COL_L_TB;

	signal clk_tb	: std_logic := '0';
	signal stop	: boolean := false;
	signal rst_tb	: std_logic;

	-- Bank Controller
	signal EndDataPhaseVec_tb		: std_logic_vector(BANK_NUM_TB - 1 downto 0);
	signal BankActiveVec_tb			: std_logic_vector(BANK_NUM_TB - 1 downto 0);
	signal ZeroOutstandingBurstsVec_tb	: std_logic_vector(BANK_NUM_TB - 1 downto 0);

	signal ReadBurstOut_tb			: std_logic;

	-- Arbitrer
	signal CmdAck_tb	: std_logic;

	signal ColMemOut_tb	: std_logic_vector(COL_L_TB - 1 downto 0);
	signal BankMemOut_tb	: std_logic_vector(int_to_bit_num(BANK_NUM_TB) - 1 downto 0);
	signal CmdOut_tb	: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal CmdReq_tb	: std_logic;

	-- Controller
	signal CtrlReq_tb	: std_logic;
	signal ReadBurstIn_tb	: std_logic;
	signal ColMemIn_tb	: std_logic_vector(COL_L_TB - to_integer(unsigned(BURST_LENGTH))  - 1 downto 0);
	signal BankMemIn_tb	: std_logic_vector(int_to_bit_num(BANK_NUM_TB) - 1 downto 0);
	signal BurstLength_tb	: std_logic_vector(BURST_LENGTH_L_TB - 1 downto 0);

	signal CtrlAck_tb	: std_logic;

begin

	DUT: ddr2_phy_col_ctrl generic map (
		BURST_LENGTH_L => BURST_LENGTH_L_TB,
		BANK_NUM => BANK_NUM_TB,
		COL_L => COL_L_TB
	)
	port map (
		clk => clk_tb,
		rst => rst_tb,

		-- Bank Controller
		BankActiveVec => BankActiveVec_tb,
		ZeroOutstandingBurstsVec => ZeroOutstandingBurstsVec_tb,

		EndDataPhaseVec => EndDataPhaseVec_tb,
		ReadBurstOut => ReadBurstOut_tb,

		-- Arbitrer
		CmdAck => CmdAck_tb,

		ColMemOut => ColMemOut_tb,
		BankMemOut => BankMemOut_tb,
		CmdOut => CmdOut_tb,
		CmdReq => CmdReq_tb,

		-- Controller
		CtrlReq => CtrlReq_tb,
		ColMemIn => ColMemIn_tb,
		BankMemIn => BankMemIn_tb,
		ReadBurstIn => ReadBurstIn_tb,
		BurstLength => BurstLength_tb,

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

		procedure test_param(variable num_bursts : out integer; variable cols: out int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1)); variable read_burst, last_burst: out bool_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1)); variable bl, cmd_delay, cmd_act_delay, cmd_ack_ack_delay, bank: out int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1)); variable seed1, seed2: inout positive) is
			variable rand_val	: real;
			variable num_bursts_int	: integer;
			variable col_int	: integer;
			variable bl_int		: integer;
		begin
			num_bursts_int := 0;
			while (num_bursts_int = 0) loop
				uniform(seed1, seed2, rand_val);
				num_bursts_int := integer(rand_val*real(MAX_OUTSTANDING_BURSTS_TB));
			end loop;
			num_bursts := num_bursts_int;

			for i in 0 to (num_bursts_int - 1) loop
				uniform(seed1, seed2, rand_val);
				col_int := integer(rand_val*(2.0**(real(COL_L_TB)) - 1.0));
				cols(i) := col_int;
				bl_int := 0;
				while (bl_int = 0) loop
					uniform(seed1, seed2, rand_val);
					bl_int := integer(rand_val*(2.0**(real(COL_L_TB)) - (real(col_int)) - 1.0));
				end loop;
				bl(i) := bl_int;
				uniform(seed1, seed2, rand_val);
				bank(i) := integer(rand_val*(real(BANK_NUM_TB)));
				uniform(seed1, seed2, rand_val);
				cmd_delay(i) := integer(rand_val*real(MAX_BURST_DELAY));
				uniform(seed1, seed2, rand_val);
				cmd_ack_ack_delay(i) := integer(rand_val*real(MAX_CMD_ACK_ACK_DELAY));
				uniform(seed1, seed2, rand_val);
				cmd_act_delay(i) := integer(rand_val*real(MAX_BURST_DELAY));
				uniform(seed1, seed2, rand_val);
				read_burst(i) := rand_bool(rand_val);
				uniform(seed1, seed2, rand_val);
				last_burst(i) := rand_bool(rand_val);
			end loop;
			for i in num_bursts to (MAX_OUTSTANDING_BURSTS_TB - 1) loop
				cols(i) := int_arr_def;
				bl(i) := int_arr_def;
				bank(i) := int_arr_def;
				cmd_delay(i) := int_arr_def;
				cmd_act_delay(i) := int_arr_def;
				cmd_ack_ack_delay(i) := int_arr_def;
				read_burst(i) := false;
				last_burst(i) := false;
			end loop;
		end procedure test_param;

		procedure run_col_ctrl (variable num_bursts_exp: in integer; variable cmd_ack_ack_delay_arr, cmd_delay_arr, cmd_act_delay_arr, cols_arr, bl_arr_exp, bank_arr_exp : in int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1)); variable read_arr_exp, last_burst : in bool_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1)); variable num_bursts_rtl : out integer; variable read_arr_rtl : out bool_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1)); variable err_arr, bl_arr_rtl, bank_arr_rtl, col_err_arr : out int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1)); variable col_err_arr_exp, col_err_arr_rtl : out int_arr_2d(0 to (MAX_OUTSTANDING_BURSTS_TB - 1), 0 to (integer(2.0**(real(BURST_LENGTH_L_TB)) - 1.0)))) is
			variable col_cmd_cnt		: integer;
			variable cmd_delay		: integer;
			variable cmd_act_cnt		: integer;
			variable cmd_act_delay		: integer;
			variable cmd_ack_ack_cnt	: integer;
			variable cmd_ack_ack_delay	: integer;
			variable data_phase_cnt		: integer;
			variable data_phase_burst_num	: integer;
			variable num_bursts_rtl_int	: integer;
			variable col_exp		: integer;
			variable col_rtl		: integer;
			variable err_arr_int		: integer;
			variable col_err		: integer;
			variable ctrl_req		: boolean;
			variable act_req		: boolean;
			variable col			: integer;
			variable bl			: integer;
			variable bank			: integer;
			variable col_next		: integer;
			variable bl_next		: integer;
			variable bank_next		: integer;
			variable bl_accepted		: integer;
		begin
			num_bursts_rtl_int := 0;
			data_phase_burst_num := 0;
			col_cmd_cnt := 0;
			cmd_act_cnt := 0;
			cmd_ack_ack_cnt := 0;
			data_phase_cnt := 0;

			ReadBurstIn_tb <= '0';
			BankActiveVec_tb <= (others => '0');
			CmdAck_tb <= '0';
			CtrlReq_tb <= '0';
			ctrl_req := false;
			act_req := false;

			err_arr_int := 0;
			col_err := 0;

			col_exp := 0;
			col_rtl := 0;

			bl_accepted := 0;

			bl_next := 0;
			bank_next := 0;
			col_next := 0;

			ColMemIn_tb <= (others => '0');
			BankMemIn_tb <= (others => '0');
			BurstLength_tb <= (others => '0');
			ZeroOutstandingBurstsVec_tb <= (others => '0');
			col := cols_arr(num_bursts_rtl_int);
			bl := bl_arr_exp(num_bursts_rtl_int);
			bank := bank_arr_exp(num_bursts_rtl_int);
			cmd_delay := cmd_delay_arr(num_bursts_rtl_int);
			cmd_act_delay := cmd_act_delay_arr(num_bursts_rtl_int);
			cmd_ack_ack_delay := cmd_ack_ack_delay_arr(num_bursts_rtl_int);

			col_loop: loop

				exit col_loop when ((num_bursts_rtl_int = num_bursts_exp) and (data_phase_burst_num = num_bursts_exp));

				CmdAck_tb <= '0';

				if (ctrl_req = false) then
					for i in col_cmd_cnt to cmd_delay loop
						wait until ((clk_tb = '1') and (clk_tb'event));
						if (i = cmd_delay) then
							ReadBurstIn_tb <= bool_to_std_logic(read_arr_exp(num_bursts_rtl_int));
							CtrlReq_tb <= '1';
							ctrl_req := true;
							ColMemIn_tb <= std_logic_vector(to_unsigned(col, COL_L_TB - to_integer(unsigned(BURST_LENGTH))));
							BurstLength_tb <= std_logic_vector(to_unsigned(bl-1, BURST_LENGTH_L_TB));
							BankMemIn_tb <= std_logic_vector(to_unsigned(bank, int_to_bit_num(BANK_NUM_TB)));
							col_cmd_cnt := 0;
						end if;
					end loop;
				end if;

				if (act_req = false) then
					for i in cmd_act_cnt to cmd_act_delay loop
						wait until ((clk_tb = '1') and (clk_tb'event));
						if (CmdReq_tb = '1') then
							err_arr_int := err_arr_int + 1;
						end if;
						if (CmdAck_tb = '1') then
							err_arr_int := err_arr_int + 1;
						end if;
					end loop;
				end if;

				act_req := true;
				BankActiveVec_tb <= std_logic_vector(to_unsigned(integer(2.0**(real(bank))), BANK_NUM_TB));
				--wait until ((clk_tb = '1') and (clk_tb'event));
				wait until (CtrlAck_tb = '1');

				CtrlReq_tb <= '0'; 
				ctrl_req := false;
				act_req := false;

				cmd_ack_ack_delay := cmd_ack_ack_delay_arr(num_bursts_rtl_int);
				num_bursts_rtl_int := num_bursts_rtl_int + 1;
				col_next := cols_arr(num_bursts_rtl_int);
				bl_next := bl_arr_exp(num_bursts_rtl_int);
				bank_next := bank_arr_exp(num_bursts_rtl_int);
				cmd_delay := cmd_delay_arr(num_bursts_rtl_int);
				cmd_act_delay := cmd_act_delay_arr(num_bursts_rtl_int);

				if (last_burst(data_phase_burst_num) = true) then
					ZeroOutstandingBurstsVec_tb <= std_logic_vector(to_unsigned(integer(2.0**(real(bank))), BANK_NUM_TB));
				else
					ZeroOutstandingBurstsVec_tb <= (others => '0');
				end if;

				burst_loop: loop

					exit burst_loop when (EndDataPhaseVec_tb(bank) = '1');

					wait until ((clk_tb = '1') and (clk_tb'event));
					wait for 1 ps;

					if (CmdReq_tb = '1') then
						report "burst " & integer'image(num_bursts_rtl_int) & " out of " & integer'image(num_bursts_exp);
						report "ack to ack " & integer'image(cmd_ack_ack_delay);
						report "ack to ack cnt " & integer'image(cmd_ack_ack_cnt);
						report "bl cnt " & integer'image(bl_accepted) & " out of " & integer'image(bl);
						if (cmd_ack_ack_cnt = cmd_ack_ack_delay) then
							CmdAck_tb <= '1';
							cmd_ack_ack_cnt := 0;
							bl_accepted := bl_accepted + 1;
							col_rtl := to_integer(unsigned(ColMemOut_tb));
							col_exp := integer(real(col + bl_accepted) * (2.0**(real(to_integer(unsigned(BURST_LENGTH))))));
							if (col_rtl /= col_exp) then
								col_err_arr_rtl(data_phase_burst_num, col_err) := col_rtl;
								col_err_arr_exp(data_phase_burst_num, col_err) := col_exp;
								col_err := col_err + 1;
							end if;
						else
							CmdAck_tb <= '0';
							cmd_ack_ack_cnt := cmd_ack_ack_cnt + 1;
						end if;
					else
						CmdAck_tb <= '0';
					end if;

					if (ctrl_req = false) then

						report "cmd delay " & integer'image(cmd_delay);
						if (col_cmd_cnt = cmd_delay) then
							ReadBurstIn_tb <= bool_to_std_logic(read_arr_exp(num_bursts_rtl_int));
							CtrlReq_tb <= '1';
							ctrl_req := true;
							ColMemIn_tb <= std_logic_vector(to_unsigned(col_next, COL_L_TB - to_integer(unsigned(BURST_LENGTH))));
							BurstLength_tb <= std_logic_vector(to_unsigned(bl_next-1, BURST_LENGTH_L_TB));
							BankMemIn_tb <= std_logic_vector(to_unsigned(bank_next, int_to_bit_num(BANK_NUM_TB)));
							col_cmd_cnt := 0;
						else
							col_cmd_cnt := col_cmd_cnt + 1;
						end if;
					else
						report "cmd act delay " & integer'image(cmd_act_delay);
						if (CtrlAck_tb = '1') then
							err_arr_int := err_arr_int + 1;
						end if;
						if (act_req = false) then
							if (cmd_act_cnt = cmd_act_delay) then
								BankActiveVec_tb <= std_logic_vector(to_unsigned(integer((2.0**(real(bank))) + (2.0**(real(bank_next)))), BANK_NUM_TB));
								cmd_act_cnt := 0;
								act_req := true;
							else
								cmd_act_cnt := cmd_act_cnt + 1;
							end if;
						end if;
					end if;

				end loop;

				read_arr_rtl(data_phase_burst_num) := std_logic_to_bool(ReadBurstOut_tb);
				bank_arr_rtl(data_phase_burst_num) := to_integer(unsigned(BankMemOut_tb));
				err_arr(data_phase_burst_num) := err_arr_int;
				err_arr_int := 0;
				col_err_arr(data_phase_burst_num) := col_err;
				col_err := 0;
				cmd_ack_ack_cnt := 0;
				col := col_next;
				bank := bank_next;
				bl := bl_next;
				data_phase_burst_num := data_phase_burst_num + 1;

			end loop;

			num_bursts_rtl := num_bursts_rtl_int;

		end procedure run_col_ctrl;

		procedure verify(variable num_bursts_exp, num_bursts_rtl: in integer; variable err_arr, col_err_arr : in int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1)); variable col_err_arr_exp, col_err_arr_rtl : in int_arr_2d(0 to (MAX_OUTSTANDING_BURSTS_TB - 1), 0 to (integer(2.0**(real(BURST_LENGTH_L_TB)) - 1.0))); variable bank_arr_exp, bank_arr_rtl, bl_arr_exp, bl_arr_rtl : in int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1)); variable read_arr_exp, read_arr_rtl : in bool_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1)); file file_pointer : text; variable pass: out integer) is
			variable match_cols		: boolean;
			variable match_banks		: boolean;
			variable match_bl		: boolean;
			variable match_read_burst	: boolean;
			variable no_errors		: boolean;
			variable file_line		: line;
		begin

			write(file_line, string'( "PHY Column Controller: Number of bursts: exp " & integer'image(num_bursts_exp) & " rtl " & integer'image(num_bursts_rtl)));
			writeline(file_pointer, file_line);

			no_errors := compare_int_arr(reset_int_arr(0, num_bursts_exp), err_arr, num_bursts_exp);
			match_cols := compare_int_arr(reset_int_arr(0, num_bursts_exp), col_err_arr, num_bursts_exp);
			match_banks := compare_int_arr(bank_arr_exp, bank_arr_rtl, num_bursts_exp);
			match_read_burst := compare_bool_arr(read_arr_exp, read_arr_rtl, num_bursts_exp);
			match_bl := compare_int_arr(bl_arr_exp, bl_arr_rtl, num_bursts_exp);

			if ((match_bl = true) and (match_read_burst = true) and (match_banks = true) and (match_cols = true) and (no_errors = true) and (num_bursts_exp = num_bursts_rtl)) then
				write(file_line, string'( "PHY Column Controller: PASS"));
				writeline(file_pointer, file_line);
				pass := 1;
			elsif (match_bl = false) then
				write(file_line, string'( "PHY Column Controller: FAIL (Burst Length mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_bursts_exp - 1) loop
					write(file_line, string'( "PHY Column Controller: Burst #" & integer'image(i) & " exp " & integer'image(bl_arr_exp(i)) & " vs rtl " & integer'image(bl_arr_rtl(i))));
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
					write(file_line, string'( "======================================================================================================================================================="));
					writeline(file_pointer, file_line);
					for j in 0 to (col_err_arr(i) - 1) loop
						write(file_line, string'( "PHY Column Controller: Burst #" & integer'image(i) & " exp " & integer'image(col_err_arr_exp(i, j)) & " vs rtl " & integer'image(col_err_arr_rtl(i, j))));
						writeline(file_pointer, file_line);
					end loop;
				end loop;
				write(file_line, string'( "======================================================================================================================================================="));
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

		variable cols_arr	: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));
		variable col_err_arr	: int_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));

		variable read_arr_exp	: bool_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));
		variable read_arr_rtl	: bool_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));
		variable last_arr	: bool_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1));

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

		variable pass	: integer;
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

			run_col_ctrl(num_bursts_exp, cmd_ack_ack_delay_arr, cmd_delay_arr, cmd_act_delay_arr, cols_arr, bl_arr_exp, bank_arr_exp, read_arr_exp, last_arr, num_bursts_rtl, read_arr_rtl, err_arr, bl_arr_rtl, bank_arr_rtl, col_err_arr, col_err_arr_exp, col_err_arr_rtl);

			verify(num_bursts_exp, num_bursts_rtl, err_arr, col_err_arr, col_err_arr_exp, col_err_arr_rtl, bank_arr_exp, bank_arr_rtl, bl_arr_exp, bl_arr_rtl, read_arr_exp, read_arr_rtl, file_pointer, pass);

			num_pass := num_pass + pass;

			wait until ((clk_tb'event) and (clk_tb = '1'));
		end loop;

		if (NUM_EXTRA_TEST > 0) then

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
