library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;
use work.ddr2_phy_pkg.all;
use work.ddr2_mrs_pkg.all;
use work.ddr2_phy_cmd_dec_pkg.all;
use work.type_conversion_pkg.all;
use work.tb_pkg.all;
use work.proc_pkg.all;
use work.ddr2_pkg_tb.all;

entity ddr2_phy_cmd_dec_tb is
end entity ddr2_phy_cmd_dec_tb;

architecture bench of ddr2_phy_cmd_dec_tb is

	constant CLK_PERIOD	: time := DDR2_CLK_PERIOD * 1 ns;
	constant NUM_TEST	: integer := 50;
	constant NUM_EXTRA_TEST	: integer := 0;
	constant TOT_NUM_TEST	: integer := NUM_TEST + NUM_EXTRA_TEST;

	constant MAX_COMMANDS_PER_TEST		: integer := 50;
	constant MAX_SELF_REFRESH_TIME		: integer := 2*AUTO_REF_TIME;
	constant MAX_CMD_REQ_ACK_DELAY		: integer := 20;
	constant MAX_ODT_CMD_REQ_ACK_DELAY	: integer := 20;
	constant MAX_BANK_IDLE_DELAY		: integer := AUTO_REF_TIME;

	constant MAX_PHY_COMPLETED_DELAY	: integer := 100;

	signal clk_tb	: std_logic := '0';
	signal stop	: boolean := false;
	signal rst_tb	: std_logic;

	signal ColIn_tb			: std_logic_vector(COL_L_TB - 1 downto 0);
	signal RowIn_tb			: std_logic_vector(ROW_L_TB - 1 downto 0);
	signal BankIn_tb		: std_logic_vector(int_to_bit_num(BANK_NUM_TB) - 1 downto 0);
	signal CmdIn_tb			: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal MRSCmd_tb		: std_logic_vector(ADDR_MEM_L_TB - 1 downto 0);

	signal ClkEnable_tb		: std_logic;
	signal nChipSelect		: std_logic;
	signal nRowAccessStrobe		: std_logic;
	signal nColAccessStrobe		: std_logic;
	signal nWriteEnable		: std_logic;
	signal BankOut_tb		: std_logic_vector(int_to_bit_num(BANK_NUM_TB) - 1 downto 0);
	signal Address_tb		: std_logic_vector(ADDR_MEM_L_TB - 1 downto 0);

begin

	DUT: ddr2_phy_cmd_dec generic map (
		BANK_NUM => BANK_NUM_TB,
		COL_L => COL_L_TB,
		ROW_L => ROW_L_TB,
		ADDR_L => ADDR_MEM_L_TB
	)
	port map (
		clk => clk_tb,
		rst => rst_tb,

		ColIn => ColIn_tb,
		RowIn => RowIn_tb,
		BankIn => BankIn_tb,
		CmdIn => CmdIn_tb,
		MRSCmd => MRSCmd_tb,

		ClkEnable => ClkEnable_tb,
		nChipSelect => nChipSelect_tb,
		nRowAccessStrobe => nRowAccessStrobe_tb,
		nColAccessStrobe => nColAccessStrobe_tb,
		nWriteEnable => nWriteEnable_tb,
		BankOut => BankOut_tb,
		Address => Address_tb

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

		procedure test_param(variable num_commands : out integer; variable col, row, bank, cmd, mrs_cmd : out int_arr(0 to (MAX_COMMANDS_PER_TEST - 1)); variable seed1, seed2 : inout positive) is
			variable rand_val		: real;
			variable num_commands_int	: integer;
		begin

			num_commands_int := 0;
			while (num_commands_int = 0) loop
				uniform(seed1, seed2, rand_val);
				num_commands_int := integer(rand_val*real(MAX_COMMANDS_PER_TEST));
			end loop;
			num_commands := num_commands_int;

			for i in 0 to (num_commands_int - 1) loop
				uniform(seed1, seed2, rand_val);
				col(i) := integer(rand_val*real(2.0**(real(COL_L_TB))));
				uniform(seed1, seed2, rand_val);
				row(i) := integer(rand_val*real(2.0**(real(ROW_L_TB))));
				uniform(seed1, seed2, rand_val);
				bank(i) := integer(rand_val*real(BANK_NUM));
				uniform(seed1, seed2, rand_val);
				cmd(i) := integer(rand_val*real(2.0**(real(MEM_CMD_L))));
				uniform(seed1, seed2, rand_val);
				mrs_cmd(i) := integer(rand_val*real(2.0**(real(ADDR_MEM_L_TB))));
			end loop;
			for i in num_commands_int to (MAX_COMMANDS_PER_TEST - 1) loop
				col(i) := int_arr_def;
				row(i) := int_arr_def;
				bank(i) := int_arr_def;
				cmd(i) := int_arr_def;
				mrs_cmd(i) := int_arr_def;
			end loop;

		end procedure test_param;

		procedure run_cmd_dec(variable num_commands_exp : in integer; variable col_exp, row_exp, bank_exp, cmd, mrs_cmd : in int_arr(0 to (MAX_COMMANDS_PER_TEST - 1)); variable num_commands_rtl : out integer; variable clk_enable, chip_sel_n, ras_n, cas_n, wr_en_n : out bool_arr(0 to (MAX_COMMANDS_PER_TEST - 1)); variable bank_rtl, address_rtl : out int_arr(0 to (MAX_COMMANDS_PER_TEST - 1))) is

			variable num_commands_rtl_int		: integer;
			variable num_dec_commands_rtl_int	: integer;

			variable cmd_sent	: boolean;

		begin
			num_commands_rtl_int := 0;
			num_dec_commands_rtl_int := 0;

			cmd_sent := false;

			ref_loop: loop

				exit ref_loop when ((num_commands_rtl_int = num_commands_exp) or (num_dec_commands_rtl_int = num_commands_exp));

				if (cmd_sent = true) then
					if (num_commands_rtl_int < num_commands_exp) then
						clk_enable(num_dec_commands_rtl_int) := std_logic_to_bool(ClkEnable_tb);
						chip_sel_n(num_dec_commands_rtl_int) := std_logic_to_bool(nChipSelect_tb);
						ras_n(num_dec_commands_rtl_int) := std_logic_to_bool(nRowAccessStrobe_tb);
						cas_n(num_dec_commands_rtl_int) := std_logic_to_bool(nColAccessStrobe_tb);
						wr_en_n(num_dec_commands_rtl_int) := std_logic_to_bool(nWriteEnable_tb);
						bank_rtl(num_dec_commands_rtl_int) := to_integer(unsigned(BankOut_tb));
						address_rtl(num_dec_commands_rtl_int) := to_integer(unsigned(Address_tb));
						num_dec_commands_rtl_int := num_dec_commands_rtl_int + 1;
					end if;
				end if;

				if (num_commands_rtl_int < num_commands_exp) then
					ColIn_tb <= std_logic_vector(to_unsigned(col_exp(num_commands_rtl_int), COL_L_TB)));
					RowIn_tb <= std_logic_vector(to_unsigned(row_exp(num_commands_rtl_int), ROW_L_TB)));
					BankIn_tb <= std_logic_vector(to_unsigned(bank_exp(num_commands_rtl_int), int_to_bit_num(BANK_NUM))));
					CmdIn_tb <= std_logic_vector(to_unsigned(cmd(num_commands_rtl_int), MEM_CMD_L)));
					MRSCmd_tb <= std_logic_vector(to_unsigned(mrs_cmd(num_commands_rtl_int), ADDR_MEM_L_TB)));
					num_commands_rtl_int := num_commands_rtl_int + 1;
				end if;
			end loop;

			num_commands_rtl := num_commands_rtl_int;

		end procedure run_cmd_dec;

		procedure verify(variable num_commands_exp, num_commands_rtl : in integer; variable odt_cmd_arr_rtl, odt_cmd_arr_exp : in bool_arr_2d(0 to (MAX_COMMANDS_PER_TEST - 1), 0 to 1); variable cmd_arr_rtl, cmd_arr_exp : in int_arr_2d(0 to (MAX_COMMANDS_PER_TEST - 1), 0 to 1); variable ctrl_err_arr, cmd_err_arr, odt_err_arr : in int_arr(0 to (MAX_COMMANDS_PER_TEST - 1)); file file_pointer : text; variable pass: out integer) is
			variable file_line	: line;

			variable no_cmd_err	: boolean;
			variable no_ctrl_err	: boolean;
			variable no_odt_cmd_err	: boolean;

			variable odt_cmd_match	: boolean;
			variable cmd_match	: boolean;
		begin

			write(file_line, string'( "PHY Refresh Controller: Number of commands: " & integer'image(num_commands_exp)));
			writeline(file_pointer, file_line);

			no_cmd_err := compare_int_arr(reset_int_arr(0, num_commands_exp), cmd_err_arr, num_commands_exp);
			no_odt_cmd_err := compare_int_arr(reset_int_arr(0, num_commands_exp), odt_err_arr, num_commands_exp);
			no_ctrl_err := compare_int_arr(reset_int_arr(0, num_commands_exp), ctrl_err_arr, num_commands_exp);

			cmd_match := compare_int_arr_2d(cmd_arr_rtl, cmd_arr_exp, num_commands_exp, 2);
			odt_cmd_match := compare_bool_arr_2d(odt_cmd_arr_rtl, odt_cmd_arr_exp, num_commands_exp, 2);

			if ((num_commands_exp = num_commands_rtl) and (no_cmd_err = true)  and (no_odt_cmd_err = true) and (no_ctrl_err = true) and (odt_cmd_match = true) and (cmd_match = true)) then
				write(file_line, string'( "PHY Refresh Controller: PASS"));
				writeline(file_pointer, file_line);
				pass := 1;
			elsif (no_cmd_err = false) then
				write(file_line, string'( "PHY Refresh Controller: FAIL (Command Handshake Error)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_commands_exp - 1) loop
					write(file_line, string'( "PHY Refresh Controller: Request #" & integer'image(i) & ": " & integer'image(cmd_err_arr(i)) & " Error(s)"));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (no_odt_cmd_err = false) then
				write(file_line, string'( "PHY Refresh Controller: FAIL (ODT Command Handshake Error)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_commands_exp - 1) loop
					write(file_line, string'( "PHY Refresh Controller: Request #" & integer'image(i) & ": " & integer'image(odt_err_arr(i)) & " Error(s)"));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (no_ctrl_err = false) then
				write(file_line, string'( "PHY Refresh Controller: FAIL (Controller Handshake Error)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_commands_exp - 1) loop
					write(file_line, string'( "PHY Refresh Controller: Request #" & integer'image(i) & ": " & integer'image(ctrl_err_arr(i)) & " Error(s)"));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (num_commands_exp /= num_commands_rtl) then
				write(file_line, string'( "PHY Refresh Controller: FAIL (Number commands mismatch): exp " & integer'image(num_commands_exp) & " vs rtl " & integer'image(num_commands_rtl)));
				writeline(file_pointer, file_line);
				pass := 0;
			elsif (cmd_match = false) then
				write(file_line, string'( "PHY Refresh Controller: FAIL (Command mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_commands_exp - 1) loop
					for j in 0 to 1 loop
						write(file_line, string'( "PHY Refresh Controller: Request #" & integer'image(i) & " Command # " & integer'image(j) & ": exp " & integer'image(cmd_arr_exp(i, j)) & " vs rtl " & integer'image(cmd_arr_rtl(i, j))));
						writeline(file_pointer, file_line);
					end loop;
				end loop;
				pass := 0;
			elsif (odt_cmd_match = false) then
				write(file_line, string'( "PHY Refresh Controller: FAIL (ODT Command mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_commands_exp - 1) loop
					for j in 0 to 1 loop
						write(file_line, string'( "PHY Refresh Controller: Request #" & integer'image(i) & " Command # " & integer'image(j) & ": exp " & bool_to_str(odt_cmd_arr_exp(i, j)) & " vs rtl " & bool_to_str(odt_cmd_arr_rtl(i, j))));
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

		variable num_commands_exp		: integer;
		variable num_commands_rtl		: integer;

		variable self_refresh_arr		: bool_arr(0 to (MAX_COMMANDS_PER_TEST-1));
		variable phy_completed_delay_arr	: int_arr(0 to (MAX_COMMANDS_PER_TEST - 1));
		variable cmd_req_ack_delay_arr		: int_arr(0 to (MAX_COMMANDS_PER_TEST - 1));
		variable odt_cmd_req_ack_delay_arr	: int_arr(0 to (MAX_COMMANDS_PER_TEST - 1));
		variable self_refresh_time_arr		: int_arr(0 to (MAX_COMMANDS_PER_TEST - 1));
		variable bank_idle_delay_arr		: int_arr(0 to (MAX_COMMANDS_PER_TEST - 1));

		variable odt_cmd_arr_rtl		: bool_arr_2d(0 to (MAX_COMMANDS_PER_TEST - 1), 0 to 1);
		variable odt_cmd_arr_exp		: bool_arr_2d(0 to (MAX_COMMANDS_PER_TEST - 1), 0 to 1);
		variable cmd_arr_rtl			: int_arr_2d(0 to (MAX_COMMANDS_PER_TEST - 1), 0 to 1);
		variable cmd_arr_exp			: int_arr_2d(0 to (MAX_COMMANDS_PER_TEST - 1), 0 to 1);

		variable ctrl_err_arr			: int_arr(0 to (MAX_COMMANDS_PER_TEST - 1));
		variable cmd_err_arr			: int_arr(0 to (MAX_COMMANDS_PER_TEST - 1));
		variable odt_err_arr			: int_arr(0 to (MAX_COMMANDS_PER_TEST - 1));

		variable pass		: integer;
		variable num_pass	: integer;

		file file_pointer	: text;
		variable file_line	: line;

	begin

		wait for 1 ns;

		num_pass := 0;

		reset;
		file_open(file_pointer, log_file, append_mode);

		write(file_line, string'( "PHY Refresh Controller Test"));
		writeline(file_pointer, file_line);

		for i in 0 to NUM_TEST-1 loop

			test_param(num_commands_exp, self_refresh_arr, phy_completed_delay_arr, cmd_req_ack_delay_arr, odt_cmd_req_ack_delay_arr, self_refresh_time_arr, bank_idle_delay_arr, seed1, seed2);

			run_cmd_dec(num_commands_exp, self_refresh_arr, phy_completed_delay_arr, cmd_req_ack_delay_arr, odt_cmd_req_ack_delay_arr, self_refresh_time_arr, bank_idle_delay_arr, num_commands_rtl, odt_cmd_arr_rtl, odt_cmd_arr_exp, cmd_arr_rtl, cmd_arr_exp, ctrl_err_arr, cmd_err_arr, odt_err_arr);

			verify(num_commands_exp, num_commands_rtl, odt_cmd_arr_rtl, odt_cmd_arr_exp, cmd_arr_rtl, cmd_arr_exp, ctrl_err_arr, cmd_err_arr, odt_err_arr, file_pointer, pass);

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

	end process test;

end bench;
