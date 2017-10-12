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
library cpu_rtl_pkg;
use cpu_rtl_pkg.reg_file_pkg.all;
use cpu_rtl_pkg.proc_pkg.all;
library cpu_tb_pkg;
use cpu_tb_pkg.cpu_pkg_tb.all;
use cpu_tb_pkg.cpu_log_pkg.all;
use cpu_tb_pkg.reg_file_pkg_tb.all;

entity reg_file_tb is
end entity reg_file_tb;

architecture bench of reg_file_tb is

	constant CLK_PERIOD	: time := PROC_CLK_PERIOD * 1 ns;
	constant NUM_TEST	: integer := 10000;

	constant OUT_NUM_TB	: positive := 2;

	signal rst_tb	: std_logic;
	signal stop	: boolean := false;
	signal clk_tb	: std_logic := '0';

	signal DataIn_tb	: std_logic_vector(DATA_L - 1 downto 0);
	signal AddressIn_tb	: std_logic_vector(int_to_bit_num(REG_NUM_TB) - 1 downto 0);
	signal AddressOut1_tb	: std_logic_vector(int_to_bit_num(REG_NUM_TB) - 1 downto 0);
	signal AddressOut2_tb	: std_logic_vector(int_to_bit_num(REG_NUM_TB) - 1 downto 0);
	signal Enable_tb	: std_logic_vector(EN_REG_FILE_L_TB-1 downto 0);
	signal Done_tb		: std_logic_vector(OUT_NUM_TB-1 downto 0);
	signal DataOut1_tb	: std_logic_vector(DATA_L-1 downto 0);
	signal DataOut2_tb	: std_logic_vector(DATA_L-1 downto 0);
	signal End_LS_tb	: std_logic;


begin

	DUT: reg_file generic map(
		REG_NUM => REG_NUM_TB,
		EN_L => EN_REG_FILE_L_TB,
		OUT_NUM => OUT_NUM_TB
	)
	port map(
		clk => clk_tb,
		rst => rst_tb,
		DataIn => DataIn_tb,
		DataOut1 => DataOut1_tb,
		DataOut2 => DataOut2_tb,
		AddressIn => AddressIn_tb,
		AddressOut1 => AddressOut1_tb,
		AddressOut2 => AddressOut2_tb,
		Enable => Enable_tb,
		End_LS => End_LS_tb,
		Done => Done_tb
	);

	clk_gen(CLK_PERIOD, 0 ns, stop, clk_tb);

	test: process
		procedure reset(variable RegFileOut_int : out reg_file_array) is
		begin
			rst_tb <= '0';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_tb <= '1';
			DataIn_tb <= (others => '0');
			AddressIn_tb <= (others => '0');
			AddressOut1_tb <= (others => '0');
			AddressOut2_tb <= (others => '0');
			Enable_tb <= (others => '0');
			RegFileOut_int := (others => 0);
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_tb <= '0';
		end procedure reset;

		procedure push_op(variable DataIn_int : out integer; variable AddressIn_int: out integer; variable AddressOut1_int : out integer; variable AddressOut2_int: out integer; variable Enable_int: out integer; variable seed1, seed2: inout positive) is
			variable DataIn_in, AddressIn_in	: integer;
			variable AddressOut1_in, AddressOut2_in	: integer;
			variable Enable_in	: integer;
			variable rand_val	: real;
		begin
			Enable_in := 0;

			uniform(seed1, seed2, rand_val);
			DataIn_in := integer(rand_val*(2.0**(real(DATA_L)) - 1.0));
			DataIn_tb <= std_logic_vector(to_unsigned(DataIn_in, DATA_L));
			DataIn_int := DataIn_in;

			uniform(seed1, seed2, rand_val);
			AddressIn_in := integer(rand_val*(2.0**(real(int_to_bit_num(REG_NUM_TB))) - 1.0));
			AddressIn_tb <= std_logic_vector(to_unsigned(AddressIn_in, int_to_bit_num(REG_NUM_TB)));
			AddressIn_int := AddressIn_in;

			uniform(seed1, seed2, rand_val);
			AddressOut1_in := integer(rand_val*(2.0**(real(int_to_bit_num(REG_NUM_TB))) - 1.0));
			AddressOut1_tb <= std_logic_vector(to_unsigned(AddressOut1_in, int_to_bit_num(REG_NUM_TB)));
			AddressOut1_int := AddressOut1_in;

			uniform(seed1, seed2, rand_val);
			AddressOut2_in := integer(rand_val*(2.0**(real(int_to_bit_num(REG_NUM_TB))) - 1.0));
			AddressOut2_tb <= std_logic_vector(to_unsigned(AddressOut2_in, int_to_bit_num(REG_NUM_TB)));
			AddressOut2_int := AddressOut2_in;

			while (Enable_in = 0) loop
				uniform(seed1, seed2, rand_val);
				Enable_in := integer(rand_val*(2.0**(real(EN_REG_FILE_L_TB)) - 1.0));
			end loop;

			Enable_tb <= std_logic_vector(to_unsigned(Enable_in, EN_REG_FILE_L_TB));
			Enable_int := Enable_in;

			wait until ((clk_tb'event) and (clk_tb = '1'));

			Enable_tb <= (others => '0');

		end procedure push_op;

		procedure verify(variable DataIn_int : in integer; variable DataOut1_ideal, DataOut2_ideal, Done_ideal : in integer; variable DataOut1_rtl, DataOut2_rtl, Done_rtl : in integer; file file_pointer : text; variable pass : out integer) is
			variable file_line	: line;
		begin
			if (DataOut1_ideal = DataOut1_rtl) and (DataOut2_ideal = DataOut2_rtl) and (Done_ideal = Done_rtl) then
				write(file_line, string'("Register File: Stored " & integer'image(DataIn_int) & " Read RTL Out1 " & integer'image(DataOut1_rtl) & " Out2 " & integer'image(DataOut2_rtl) & " Done_rtl "  & integer'image(Done_rtl) & " Ideal Out1 " & integer'image(DataOut1_ideal) & " Out2 " & integer'image(DataOut2_ideal) & " Done_ideal "  & integer'image(Done_ideal) & ": PASS"));
				pass := 1;
			elsif (DataOut1_ideal /= DataOut1_rtl) and (DataOut2_ideal = DataOut2_rtl) and (Done_ideal = Done_rtl) then
				write(file_line, string'("Register File: Stored " & integer'image(DataIn_int) & " Read RTL Out1 " & integer'image(DataOut1_rtl) & " Out2 " & integer'image(DataOut2_rtl) & " Done_rtl "  & integer'image(Done_rtl) & " Ideal Out1 " & integer'image(DataOut1_ideal) & " Out2 " & integer'image(DataOut2_ideal) & " Done_ideal "  & integer'image(Done_ideal) & ": FAIL (Data Out 1)"));
				pass := 0;
			elsif (DataOut1_ideal = DataOut1_rtl) and (DataOut2_ideal /= DataOut2_rtl) and (Done_ideal = Done_rtl) then
				write(file_line, string'("Register File: Stored " & integer'image(DataIn_int) & " Read RTL Out1 " & integer'image(DataOut1_rtl) & " Out2 " & integer'image(DataOut2_rtl) & " Done_rtl "  & integer'image(Done_rtl) & " Ideal Out1 " & integer'image(DataOut1_ideal) & " Out2 " & integer'image(DataOut2_ideal) & " Done_ideal "  & integer'image(Done_ideal) & ": FAIL (Data Out 2)"));
				pass := 0;
			elsif (DataOut1_ideal = DataOut1_rtl) and (DataOut2_ideal = DataOut2_rtl) and (Done_ideal /= Done_rtl) then
				write(file_line, string'("Register File: Stored " & integer'image(DataIn_int) & " Read RTL Out1 " & integer'image(DataOut1_rtl) & " Out2 " & integer'image(DataOut2_rtl) & " Done_rtl "  & integer'image(Done_rtl) & " Ideal Out1 " & integer'image(DataOut1_ideal) & " Out2 " & integer'image(DataOut2_ideal) & " Done_ideal "  & integer'image(Done_ideal) & ": FAIL (Done signal)"));
				pass := 0;
			elsif (DataOut1_ideal /= DataOut1_rtl) and (DataOut2_ideal /= DataOut2_rtl) and (Done_ideal = Done_rtl) then
				write(file_line, string'("Register File: Stored " & integer'image(DataIn_int) & " Read RTL Out1 " & integer'image(DataOut1_rtl) & " Out2 " & integer'image(DataOut2_rtl) & " Done_rtl "  & integer'image(Done_rtl) & " Ideal Out1 " & integer'image(DataOut1_ideal) & " Out2 " & integer'image(DataOut2_ideal) & " Done_ideal "  & integer'image(Done_ideal) & ": FAIL (Data Out 1 and Out 2)"));
				pass := 0;
			elsif (DataOut1_ideal /= DataOut1_rtl) and (DataOut2_ideal = DataOut2_rtl) and (Done_ideal /= Done_rtl) then
				write(file_line, string'("Register File: Stored " & integer'image(DataIn_int) & " Read RTL Out1 " & integer'image(DataOut1_rtl) & " Out2 " & integer'image(DataOut2_rtl) & " Done_rtl "  & integer'image(Done_rtl) & " Ideal Out1 " & integer'image(DataOut1_ideal) & " Out2 " & integer'image(DataOut2_ideal) & " Done_ideal "  & integer'image(Done_ideal) & ": FAIL (Data Out 1 and Done signal)"));
				pass := 0;
			elsif (DataOut1_ideal = DataOut1_rtl) and (DataOut2_ideal /= DataOut2_rtl) and (Done_ideal /= Done_rtl) then
				write(file_line, string'("Register File: Stored " & integer'image(DataIn_int) & " Read RTL Out1 " & integer'image(DataOut1_rtl) & " Out2 " & integer'image(DataOut2_rtl) & " Done_rtl "  & integer'image(Done_rtl) & " Ideal Out1 " & integer'image(DataOut1_ideal) & " Out2 " & integer'image(DataOut2_ideal) & " Done_ideal "  & integer'image(Done_ideal) & ": FAIL (Data Out 2 and Done signal)"));
				pass := 0;
			else
				write(file_line, string'("Register File: Stored " & integer'image(DataIn_int) & " Read RTL Out1 " & integer'image(DataOut1_rtl) & " Out2 " & integer'image(DataOut2_rtl) & " Done_rtl "  & integer'image(Done_rtl) & " Ideal Out1 " & integer'image(DataOut1_ideal) & " Out2 " & integer'image(DataOut2_ideal) & " Done_ideal "  & integer'image(Done_ideal) & ": FAIL (Data Out 1 and Out 2 and Done signal)"));
				pass := 0;
			end if;
			writeline(file_pointer, file_line);
		end procedure verify;

		variable RegFileOut, RegFileIn	: reg_file_array;
		variable DataIn, AddressIn, AddressOut1, AddressOut2, Enable	: integer;
		variable Done_rtl, DataOut1_rtl, DataOut2_rtl	: integer;
		variable Done_ideal, DataOut1_ideal, DataOut2_ideal	: integer;
		variable seed1, seed2	: positive;
		variable pass	: integer;
		variable num_pass	: integer;

		file file_pointer	: text;
		variable file_line	: line;

	begin

		wait for 1 ns;

		num_pass := 0;

		reset(RegFileOut);
		file_open(file_pointer, reg_file_log_file, append_mode);

		write(file_line, string'( "Register File Test"));
		writeline(file_pointer, file_line);

		for i in 0 to NUM_TEST-1 loop
			RegFileIn := RegFileOut;

			push_op(DataIn, AddressIn, AddressOut1, AddressOut2, Enable, seed1, seed2);

			wait on End_LS_tb;

			DataOut1_rtl := to_integer(unsigned(DataOut1_tb));
			DataOut2_rtl := to_integer(unsigned(DataOut2_tb));
			Done_rtl := to_integer(unsigned(Done_tb));

			reg_file_ref(RegFileIn, DataIn, AddressIn, AddressOut1, AddressOut2, Enable, Done_ideal, DataOut1_ideal, DataOut2_ideal, RegFileOut);

			verify(DataIn, DataOut1_ideal, DataOut2_ideal, Done_ideal, DataOut1_rtl, DataOut2_rtl, Done_rtl, file_pointer, pass);

			num_pass := num_pass + pass;

			wait until ((clk_tb'event) and (clk_tb = '1'));
		end loop;

		file_close(file_pointer);

		file_open(file_pointer, summary_file, append_mode);
		write(file_line, string'("REGISTER FILE => PASSES: " & integer'image(num_pass) & " out of " & integer'image(NUM_TEST)));
		writeline(file_pointer, file_line);

		if (num_pass = NUM_TEST) then
			write(file_line, string'( "REGISTER FILE: TEST PASSED"));
		else
			write(file_line, string'( "REGISTER FILE: TEST FAILED: " & integer'image(NUM_TEST-num_pass) & " failures"));
		end if;
		writeline(file_pointer, file_line);

		file_close(file_pointer);
		stop <= true;

		wait;

	end process test;

end bench;
