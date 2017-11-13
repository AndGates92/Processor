library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;
library common_rtl_pkg;
use common_rtl_pkg.type_conversion_pkg.all;
library common_tb_pkg;
use common_tb_pkg.shared_pkg_tb.all;
library ddr2_rtl_pkg;
use ddr2_rtl_pkg.ddr2_define_pkg.all;
use ddr2_rtl_pkg.ddr2_ctrl_pkg.all;
use ddr2_rtl_pkg.ddr2_ctrl_init_pkg.all;
use ddr2_rtl_pkg.ddr2_gen_ac_timing_pkg.all;
library ddr2_tb_pkg;
use ddr2_tb_pkg.ddr2_pkg_tb.all;
use ddr2_tb_pkg.ddr2_log_pkg.all;

entity ddr2_ctrl_init_tb is
end entity ddr2_ctrl_init_tb;

architecture bench of ddr2_ctrl_init_tb is

	constant CLK_PERIOD	: time := DDR2_CLK_PERIOD * 1 ns;
	constant NUM_TEST	: integer := 20;

	constant MAX_INIT_DELAY_TB	: integer := 100;

	signal clk_tb	: std_logic := '0';
	signal stop	: boolean := false;
	signal rst_tb	: std_logic;

	-- Memory access
	signal MRSCmd_tb	: std_logic_vector(ADDR_MEM_L_TB - 1 downto 0);
	signal Cmd_tb		: std_logic_vector(MEM_CMD_L - 1 downto 0);

	-- Memory interface
	signal InitializationCompleted_tb	: std_logic;

begin

	DUT: ddr2_ctrl_init generic map (
		BANK_L => BANK_L_TB,
		ADDR_MEM_L => ADDR_MEM_L_TB
	)
	port map (
		clk => clk_tb,
		rst => rst_tb,

		MRSCmd => MRSCmd_tb,
		Cmd => Cmd_tb,

		InitializationCompleted => InitializationCompleted_tb
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

		procedure test_param(variable delay: out integer; variable seed1, seed2: inout positive) is
			variable rand_val	: real;
		begin

			uniform(seed1, seed2, rand_val);
			delay := integer(rand_val*real(MAX_INIT_DELAY_TB));

		end procedure test_param;

		procedure verify(file file_pointer : text; variable pass: out integer) is
			variable file_line	: line;
		begin
			write(file_line, string'( "PHY Init completed: PASS"));

			pass := 1;

			writeline(file_pointer, file_line);

		end procedure verify;

		variable seed1, seed2	: positive;

		variable delay		: integer;

		variable pass		: integer;
		variable num_pass	: integer;

		file file_pointer	: text;
		variable file_line	: line;

	begin

		wait for 1 ns;

		num_pass := 0;

		file_open(file_pointer, ddr2_ctrl_init_log_file, append_mode);

		write(file_line, string'( "PHY Init Test"));
		writeline(file_pointer, file_line);

		for i in 0 to NUM_TEST-1 loop

			reset;

			test_param(delay, seed1, seed2);

			wait on InitializationCompleted_tb;

			verify(file_pointer, pass);

			num_pass := num_pass + pass;

			for j in 0 to delay loop
				wait until ((clk_tb'event) and (clk_tb = '1'));
			end loop;
		end loop;

		file_close(file_pointer);

		file_open(file_pointer, summary_file, append_mode);
		write(file_line, string'( "PHY Init => PASSES: " & integer'image(num_pass) & " out of " & integer'image(NUM_TEST)));
		writeline(file_pointer, file_line);

		if (num_pass = NUM_TEST) then
			write(file_line, string'( "PHY Init: TEST PASSED"));
		else
			write(file_line, string'( "PHY Init: TEST FAILED: " & integer'image(NUM_TEST-num_pass) & " failures"));
		end if;
		writeline(file_pointer, file_line);

		file_close(file_pointer);
		stop <= true;

		wait;

	end process test;

end bench;
