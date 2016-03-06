library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.alu_pkg.all;
use work.tb_pkg.all;

entity mul_tb is
end entity mul_tb;

architecture bench of mul_tb is

	constant CLK_PERIOD	: time := 10 ns;
	constant NUM_TEST	: integer := 100;

	signal clk_tb	: std_logic := '0';
	signal stop	: boolean := false;
	signal rst_tb	: std_logic;

	constant OP1_L_TB	: integer := 16;
	constant OP2_L_TB	: integer := 16;

	signal Op1_tb	: std_logic_vector(OP1_L_TB - 1 downto 0);
	signal Op2_tb	: std_logic_vector(OP2_L_TB - 1 downto 0);

	signal Start_tb	: std_logic;
	signal Done_tb	: std_logic;

	signal Res_tb	: std_logic_vector(OP1_L_TB+OP2_L_TB - 1 downto 0);

	type int_arr is array(0 to 2) of integer;

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

		procedure verify(variable Op1_int, Op2_int, Res_rtl: in integer; variable pass: out integer) is
			variable Res_ideal	: integer;
		begin
			Res_ideal := Op1_int*Op2_int;
			if (Res_rtl = Res_ideal) then
				report "Multiplication of " & integer'image(Op1_int) & " and " & integer'image(Op2_int) & " gives: RTL " & integer'image(Res_rtl) & " and reference " & integer'image(Res_ideal) & ": PASSED";
				pass := 1;
			else
				report "Multiplication of " & integer'image(Op1_int) & " and " & integer'image(Op2_int) & " gives: RTL " & integer'image(Res_rtl) & " and reference " & integer'image(Res_ideal) & ": FAILED" severity warning;
				pass := 0;
			end if;
		end procedure verify;

		variable Res_rtl	: integer;
		variable Op1_int, Op2_int	: integer;
		variable seed1, seed2	: positive;
		variable pass	: integer;
		variable num_pass	: integer;
		variable mpnd	: int_arr := (0, 0, 0);
		variable mptr	: int_arr := (0, 0, 0);

	begin

		wait for 1 ns;

		num_pass := 0;
		mptr := (10, 0, 0);
		mpnd := (0, 10, 0);

		reset;

		for i in 0 to NUM_TEST-1 loop
			push_op(Op1_int, Op2_int, seed1, seed2);

			wait on Done_tb;

			Res_rtl := to_integer(signed(Res_tb));
			verify(Op1_int, Op2_int, Res_rtl, pass);

			num_pass := num_pass + pass;

			wait until rising_edge(clk_tb);
		end loop;

		for i in 0 to int_arr'high loop
			push_op_fix(Op1_int, Op2_int, mpnd(i), mptr(i));

			wait on Done_tb;

			Res_rtl := to_integer(signed(Res_tb));
			verify(Op1_int, Op2_int, Res_rtl, pass);

			num_pass := num_pass + pass;

			wait until rising_edge(clk_tb);
		end loop;

		report "PASSED: " & integer'image(num_pass) & " out of " & integer'image(NUM_TEST + (int_arr'high + 1));

		stop <= true;

	end process test;

end bench;
