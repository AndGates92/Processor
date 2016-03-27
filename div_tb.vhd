library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;
use work.alu_pkg.all;
use work.tb_pkg.all;

entity div_tb is
end entity div_tb;

architecture bench of div_tb is

	constant CLK_PERIOD	: time := 10 ns;
	constant NUM_TEST	: integer := 100;

	signal clk_tb	: std_logic := '0';
	signal stop	: boolean := false;
	signal rst_tb	: std_logic;

	constant OP1_L_TB	: integer := 30;
	constant OP2_L_TB	: integer := 30;

	signal Op1_tb	: std_logic_vector(OP1_L_TB - 1 downto 0);
	signal Op2_tb	: std_logic_vector(OP2_L_TB - 1 downto 0);

	signal Start_tb	: std_logic;
	signal Done_tb	: std_logic;

	signal Quot_tb	: std_logic_vector(OP1_L_TB - 1 downto 0);
	signal Rem_tb	: std_logic_vector(OP2_L_TB - 1 downto 0);

	type int_arr is array(0 to 3) of integer;

	component div
	generic (
		OP1_L	: positive := 16;
		OP2_L	: positive := 16
	);
	port (
		rst		: in std_logic;
		clk		: in std_logic;
		Dividend	: in std_logic_vector(OP1_L - 1 downto 0);
		Divisor		: in std_logic_vector(OP2_L - 1 downto 0);
		Start		: in std_logic;
		Done		: out std_logic;
		Quotient	: out std_logic_vector(OP1_L-1 downto 0);
		Remainder	: out std_logic_vector(OP2_L - 1 downto 0)
	);
	end component;

begin

	DUT: div generic map(
		OP1_L => OP1_L_TB,
		OP2_L => OP2_L_TB
	)
	port map (
		rst => rst_tb,
		clk => clk_tb,
		Dividend => Op1_tb,
		Divisor => Op2_tb,
		Start => Start_tb,
		Done => Done_tb,
		Quotient => Quot_tb,
		Remainder => Rem_tb
	);

	clk_tb <= not clk_tb after CLK_PERIOD/2 when not stop;

	test: process

		procedure reset is
		begin
			rst_tb <= '0';
			wait until rising_edge(clk_tb);
			rst_tb <= '1';
			Op1_tb <= (others => '0');
			Op2_tb <= (others => '0');
			Start_tb <= '0';
			wait until rising_edge(clk_tb);
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

			wait until rising_edge(clk_tb);
			Start_tb <= '0';
		end procedure push_op;

		procedure push_op_fix(variable Op1_int : out integer; variable Op2_int: out integer; variable Op1_in : in integer; variable Op2_in: in integer) is
		begin
			Op1_tb <= std_logic_vector(to_signed(Op1_in, OP1_L_TB));
			Op2_tb <= std_logic_vector(to_signed(Op2_in, OP2_L_TB));

			Op1_int := Op1_in;
			Op2_int := Op2_in;

			Start_tb <= '1';

			wait until rising_edge(clk_tb);
			Start_tb <= '0';
		end procedure push_op_fix;

		procedure verify(variable Op1_int, Op2_int, Quot_rtl, Rem_rtl: in integer; file file_pointer : text; variable pass: out integer) is
			variable Rem_ideal, Quot_ideal	: integer;
			variable file_line	: line;
		begin
			if (Op1_int /= 0) and (Op2_int /= 0) then
				Quot_ideal := integer(Op1_int/Op2_int);
				Rem_ideal := integer(Op1_int rem Op2_int);
			elsif (Op1_int = 0) and (Op2_int = 0) then
				Quot_ideal := - 1;
				Rem_ideal := 0;
			elsif (Op2_int = 0) and (Op1_int > 0) then
				Quot_ideal := (2**(OP1_L_TB - 1)) - 1;
				Rem_ideal := 0;
			elsif (Op2_int = 0) and (Op1_int < 0) then
				Quot_ideal := -((2**(OP1_L_TB - 1)) - 1);
				Rem_ideal := 0;
			elsif (Op1_int = 0) then
				Quot_ideal := 0;
				Rem_ideal := 0;
			else
				Quot_ideal := 0;
				Rem_ideal := 0;
			end if;

			if (Rem_rtl = Rem_ideal) and (Quot_ideal = Quot_rtl) then
				write(file_line, string'( "Division of " & integer'image(Op1_int) & " and " & integer'image(Op2_int) & " gives: RTL Quotient " & integer'image(Quot_rtl) & " Remainder " & integer'image(Rem_rtl) & " and reference Quotient " & integer'image(Quot_ideal) & " Remainder " & integer'image(Rem_ideal) & ": PASS"));
				writeline(file_pointer, file_line);
				pass := 1;
			elsif (Rem_rtl = Rem_ideal) then
				write(file_line, string'( "Division of " & integer'image(Op1_int) & " and " & integer'image(Op2_int) & " gives: RTL Quotient " & integer'image(Quot_rtl) & " Remainder " & integer'image(Rem_rtl) & " and reference Quotient " & integer'image(Quot_ideal) & " Remainder " & integer'image(Rem_ideal) & ": FAIL (Quotient wrong)"));
				writeline(file_pointer, file_line);
				pass := 0;
			elsif (Quot_rtl = Quot_ideal) then
				write(file_line, string'( "Division of " & integer'image(Op1_int) & " and " & integer'image(Op2_int) & " gives: RTL Quotient " & integer'image(Quot_rtl) & " Remainder " & integer'image(Rem_rtl) & " and reference Quotient " & integer'image(Quot_ideal) & " Remainder " & integer'image(Rem_ideal) & ": FAIL (Remainder wrong)"));
				writeline(file_pointer, file_line);
				pass := 0;
			else
				write(file_line, string'( "Division of " & integer'image(Op1_int) & " and " & integer'image(Op2_int) & " gives: RTL Quotient " & integer'image(Quot_rtl) & " Remainder " & integer'image(Rem_rtl) & " and reference Quotient " & integer'image(Quot_ideal) & " Remainder " & integer'image(Rem_ideal) & ": FAIL (Quotient and remainder wrong)"));
				writeline(file_pointer, file_line);
				pass := 0;
			end if;
		end procedure verify;

		variable Quot_rtl, Rem_rtl	: integer;
		variable Op1_int, Op2_int	: integer;
		variable seed1, seed2	: positive;
		variable pass	: integer;
		variable num_pass	: integer;
		variable dvd	: int_arr := (0, 10, -10, 0);
		variable dvs	: int_arr := (10, 0, 0, 0);

		file file_pointer	: text;
		variable file_line	: line;

	begin

		wait for 1 ns;

		num_pass := 0;
		dvs := (10, 0, 0, 0);
		dvd := (0, 10, -10, 0);

		reset;
		file_open(file_pointer, log_file, append_mode);

		write(file_line, string'( "Divider Test"));
		writeline(file_pointer, file_line);

		for i in 0 to NUM_TEST-1 loop
			push_op(Op1_int, Op2_int, seed1, seed2);

			wait on Done_tb;

			Quot_rtl := to_integer(signed(Quot_tb));
			Rem_rtl := to_integer(signed(Rem_tb));
			verify(Op1_int, Op2_int, Quot_rtl, Rem_rtl, file_pointer, pass);

			num_pass := num_pass + pass;

			wait until rising_edge(clk_tb);
		end loop;

		for i in 0 to int_arr'high loop
			push_op_fix(Op1_int, Op2_int, dvd(i), dvs(i));

			wait on Done_tb;

			Quot_rtl := to_integer(signed(Quot_tb));
			Rem_rtl := to_integer(signed(Rem_tb));
			verify(Op1_int, Op2_int, Quot_rtl, Rem_rtl, file_pointer, pass);

			num_pass := num_pass + pass;

			wait until rising_edge(clk_tb);
		end loop;

		file_close(file_pointer);

		file_open(file_pointer, summary_file, append_mode);
		write(file_line, string'( "DIVISION => PASSES: " & integer'image(num_pass) & " out of " & integer'image(NUM_TEST + (int_arr'high + 1))));
		writeline(file_pointer, file_line);

		file_close(file_pointer);
		stop <= true;

	end process test;

end bench;
