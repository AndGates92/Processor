library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;
use work.alu_pkg.all;
use work.proc_pkg.all;
use work.tb_pkg.all;

entity mul_tb is
end entity mul_tb;

architecture bench of mul_tb is

	constant CLK_PERIOD	: time := PROC_CLK_PERIOD * 1 ns;
	constant NUM_TEST	: integer := 10000;

	signal clk_tb	: std_logic := '0';
	signal stop	: boolean := false;
	signal rst_tb	: std_logic;

	signal Op1_tb	: std_logic_vector(OP1_L_TB - 1 downto 0);
	signal Op2_tb	: std_logic_vector(OP2_L_TB - 1 downto 0);

	signal Start_tb	: std_logic;
	signal Done_tb	: std_logic;

	signal Res_tb	: std_logic_vector(OP1_L_TB+OP2_L_TB - 1 downto 0);

	type int_arr_mul is array(0 to 2) of integer;

	component mul
	generic (
		OP1_L	: positive := 16;
		OP2_L	: positive := 16
	);
	port (
		rst	: in std_logic;
		clk	: in std_logic;
		Op1	: in std_logic_vector(OP1_L - 1 downto 0);
		Op2	: in std_logic_vector(OP2_L - 1 downto 0);
		Start	: in std_logic;
		Done	: out std_logic;
		Res	: out std_logic_vector(OP1_L+OP2_L-1 downto 0)
	);
	end component;

begin

	DUT: mul generic map(
		OP1_L => OP1_L_TB,
		OP2_L => OP2_L_TB
	)
	port map (
		rst => rst_tb,
		clk => clk_tb,
		Op1 => Op1_tb,
		Op2 => Op2_tb,
		Start => Start_tb,
		Done => Done_tb,
		Res => Res_tb
	);

	clk_gen(CLK_PERIOD, 0 ns, stop, clk_tb);

	test: process

		procedure reset is
		begin
			rst_tb <= '0';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_tb <= '1';
			Op1_tb <= (others => '0');
			Op2_tb <= (others => '0');
			Start_tb <= '0';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_tb <= '0';
		end procedure reset;

		procedure push_op(variable Op1_int : out integer; variable Op2_int: out integer; variable seed1, seed2: inout positive) is
			variable Op1_in, Op2_in	: integer;
			variable rand_val, sign_val	: real;
		begin
			uniform(seed1, seed2, rand_val);
			uniform(seed1, seed2, sign_val);
			Op1_in := integer(rand_sign(sign_val)*rand_val*(2.0**(real(OP1_L_TB) - 1.0) - 1.0));
			uniform(seed1, seed2, rand_val);
			uniform(seed1, seed2, sign_val);
			Op2_in := integer(rand_sign(sign_val)*rand_val*(2.0**(real(OP2_L_TB) - 1.0) - 1.0));

			Op1_tb <= std_logic_vector(to_signed(Op1_in, OP1_L_TB));
			Op2_tb <= std_logic_vector(to_signed(Op2_in, OP2_L_TB));

			Op1_int := Op1_in;
			Op2_int := Op2_in;

			Start_tb <= '1';

			wait until ((clk_tb'event) and (clk_tb = '1'));
			Start_tb <= '0';
		end procedure push_op;

		procedure push_op_fix(variable Op1_int : out integer; variable Op2_int: out integer; variable Op1_in : in integer; variable Op2_in: in integer) is
		begin
			Op1_tb <= std_logic_vector(to_signed(Op1_in, OP1_L_TB));
			Op2_tb <= std_logic_vector(to_signed(Op2_in, OP2_L_TB));

			Op1_int := Op1_in;
			Op2_int := Op2_in;

			Start_tb <= '1';

			wait until ((clk_tb'event) and (clk_tb = '1'));
			Start_tb <= '0';
		end procedure push_op_fix;

		procedure verify(variable Op1_int, Op2_int, Res_rtl: in integer; file file_pointer : text; variable pass: out integer) is
			variable Res_ideal	: integer;
			variable file_line	: line;
		begin
			Res_ideal := Op1_int*Op2_int;
			if (Res_rtl = Res_ideal) then
				write(file_line, string'("Multiplication of " & integer'image(Op1_int) & " and " & integer'image(Op2_int) & " gives: RTL " & integer'image(Res_rtl) & " and reference " & integer'image(Res_ideal) & ": PASS"));
				pass := 1;
			else
				write(file_line, string'("Multiplication of " & integer'image(Op1_int) & " and " & integer'image(Op2_int) & " gives: RTL " & integer'image(Res_rtl) & " and reference " & integer'image(Res_ideal) & ": FAIL"));
				pass := 0;
			end if;
			writeline(file_pointer, file_line);
		end procedure verify;

		variable Res_rtl	: integer;
		variable Op1_int, Op2_int	: integer;
		variable seed1, seed2	: positive;
		variable pass	: integer;
		variable num_pass	: integer;
		variable mpnd	: int_arr_mul := (0, 0, 0);
		variable mptr	: int_arr_mul := (0, 0, 0);

		file file_pointer	: text;
		variable file_line	: line;

	begin

		wait for 1 ns;

		num_pass := 0;
		mptr := (10, 0, 0);
		mpnd := (0, 10, 0);

		reset;
		file_open(file_pointer, log_file, append_mode);

		write(file_line, string'( "Multiplier Test"));
		writeline(file_pointer, file_line);

		for i in 0 to NUM_TEST-1 loop
			push_op(Op1_int, Op2_int, seed1, seed2);

			wait on Done_tb;

			Res_rtl := to_integer(signed(Res_tb));
			verify(Op1_int, Op2_int, Res_rtl, file_pointer, pass);

			num_pass := num_pass + pass;

			wait until ((clk_tb'event) and (clk_tb = '1'));
		end loop;

		for i in 0 to int_arr_mul'high loop
			push_op_fix(Op1_int, Op2_int, mpnd(i), mptr(i));

			wait on Done_tb;

			Res_rtl := to_integer(signed(Res_tb));
			verify(Op1_int, Op2_int, Res_rtl, file_pointer, pass);

			num_pass := num_pass + pass;

			wait until ((clk_tb'event) and (clk_tb = '1'));
		end loop;

		file_close(file_pointer);

		file_open(file_pointer, summary_file, append_mode);
		write(file_line, string'("MULTIPLICATION => PASSES: " & integer'image(num_pass) & " out of " & integer'image(NUM_TEST + (int_arr_mul'high + 1))));
		writeline(file_pointer, file_line);

		file_close(file_pointer);
		stop <= true;

	end process test;

end bench;
