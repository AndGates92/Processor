library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;
use work.ddr2_pkg.all;
use work.ddr2_phy_bank_ctrl_pkg.all;
use work.tb_pkg.all;
use work.ddr2_phy_bank_ctrl_pkg_tb.all;

entity ddr2_phy_bank_ctrl_tb is
end entity ddr2_phy_bank_ctrl_tb;

architecture bench of ddr2_phy_bank_ctrl_tb is

	constant CLK_PERIOD	: time := DDR2_CLK_PERIOD * 1 ns;
	constant NUM_TEST	: integer := 100;

	signal clk_tb	: std_logic := '0';
	signal stop	: boolean := false;
	signal rst_tb	: std_logic;

	-- User Interface
	signal RowMemIn_tb	: std_logic_vector(ROW_L - 1 downto 0);
	signal CtrlReq_tb	: std_logic;

	signal CtrlAck_tb	: std_logic;

	signal -- Arbitrer
	signal RowMemOut_tb	: std_logic_vector(ROW_L - 1 downto 0);
	signal CmdOut_tb	: std_logic_vector(CMD_MEM_L - 1 downto 0);
	signal CmdReq_tb	: std_logic;

	signal CmdAck_tb	: std_logic;

	signal -- Controller
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

		procedure test_param(variable num_bursts : out integer; variable rows: out int_arr_ddr2_phy_bank_ctrl; variable seed1, seed2: inout positive) is
			variable rand_val	: real;
		begin
			uniform(seed1, seed2, rand_val);
			num_bursts := integer(rand_val*MAX_OUTSTANDING_BURSTS);

			for i in 0 to (num_bursts - 1) loop
				uniform(seed1, seed2, rand_val);
				rows(i) := integer(rand_val*(2.0**(real(ROW_L)) - 1.0));
			end loop;
			for i in num_bursts to (MAX_OUTSTANDING_BURSTS - 1) loop
				rows(i) := int_arr_ddr2_phy_bank_ctrl_def;
			end loop;
		end procedure push_op;


		procedure verify(file file_pointer : text; variable pass: out integer) is
			variable match_rows	: boolean;
			variable file_line	: line;
		begin

			write(file_line, string'( "PHY Bank Controller Status: Bank Idle: " & bool_to_str(std_logic_to_bool(BankIdle_tb)) & " Bank Active: " & bool_to_str(std_logic_to_bool(BankActive_tb)) & " Number of bursts: exp " & integer'image(num_bursts_exp) & " rtl " & integer'image(num_bursts_rtl) & "No outstanding burst: " & bool_to_str(std_logic_to_bool(ZeroOutstandingBursts)));

			match_rows = compare_int_arr_ddr2_phy_bank_ctrl(row_arr_exp, row_arr_rtl, num_bursts_exp);

			if ((BankActive_tb = '0') and (ZeroOutstandingBursts_tb = '1') and (BankIdle_tb = '1') and (match_rows = true) and (num_bursts_exp = num_burst_rtl)) then
				write(file_line, string'( "PHY Bank Controller: PASS"));
				pass := 1;
			elsif (BankIdle_tb = '0') then
				write(file_line, string'( "PHY Bank Controller: FAIL (Bank not in the idle)"));
				pass := 0;
			elsif (BankActive_tb = '1') then
				write(file_line, string'( "PHY Bank Controller: FAIL (Bank was not precharged after use)"));
				pass := 0;
			elsif (ZeroOutstandingBursts_tb = '0') then
				write(file_line, string'( "PHY Bank Controller: FAIL (Outstanding bursts)"));
				pass := 0;
			elsif (num_bursts_exp /= num_bursts_rtl) then
				write(file_line, string'( "PHY Bank Controller: FAIL (Number bursts mismatch: exp " & integer'image(num_bursts_exp) " rtl " & integer'image(num_bursts_rtl)));
				pass := 0;
			elsif (match_rows = false) then
				write(file_line, string'( "PHY Bank Controller: FAIL (Row mismatch)"));
				pass := 0;
			else
				write(file_line, string'( "PHY Bank Controller: FAIL (Unknown error)"));
				pass := 0;
			end if;
			writeline(file_pointer, file_line);
		end procedure verify;

		variable num_bursts_exp	: integer;
		variable rows_arr_exp	: integer;

		variable num_bursts_rtl	: integer;
		variable rows_arr_rtl	: integer;

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

			test_param(num_bursts_exp, rows_arr_exp, seed1, seed2);

			verify(file_pointer, pass);

			num_pass := num_pass + pass;

			for j in 0 to i loop
				wait until ((clk_tb'event) and (clk_tb = '1'));
			end loop;
		end loop;

		file_close(file_pointer);

		file_open(file_pointer, summary_file, append_mode);
		write(file_line, string'( "PHY Bank Controller => PASSES: " & integer'image(num_pass) & " out of " & integer'image(NUM_TEST)));
		writeline(file_pointer, file_line);

		if (num_pass = NUM_TEST) then
			write(file_line, string'( "PHY Bank Controller: TEST PASSED"));
		else
			write(file_line, string'( "PHY Bank Controller: TEST FAILED: " & integer'image(NUM_TEST-num_pass) & " failures"));
		end if;
		writeline(file_pointer, file_line);

		file_close(file_pointer);
		stop <= true;

	end process test;

end bench;
