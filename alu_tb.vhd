library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;
use work.alu_pkg.all;
use work.proc_pkg.all;
use work.tb_pkg.all;
use work.alu_pkg_tb.all;

entity alu_tb is
end entity alu_tb;

architecture bench of alu_tb is

	constant CLK_PERIOD	: time := PROC_CLK_PERIOD * 1 ns;
	constant NUM_TEST	: integer := 10000;

	signal clk_tb	: std_logic := '0';
	signal stop	: boolean := false;
	signal rst_tb	: std_logic;

	signal Op1_tb	: std_logic_vector(OP1_L_TB - 1 downto 0);
	signal Op2_tb	: std_logic_vector(OP2_L_TB - 1 downto 0);
	signal Cmd_tb	: std_logic_vector(CMD_ALU_L - 1 downto 0);

	signal Ovfl_tb	: std_logic;
	signal Unfl_tb	: std_logic;
	signal UnCmd_tb	: std_logic;

	signal Start_tb	: std_logic;
	signal Done_tb	: std_logic;

	signal Res_tb	: std_logic_vector(OP1_L_TB - 1 downto 0);

begin

	DUT: alu generic map(
		OP1_L => OP1_L_TB,
		OP2_L => OP2_L_TB
	)
	port map (
		rst => rst_tb,
		clk => clk_tb,
		Op1 => Op1_tb,
		Op2 => Op2_tb,
		Cmd => Cmd_tb,
		Start => Start_tb,
		Done => Done_tb,
		Ovfl => Ovfl_tb,
		Unfl => Unfl_tb,
		UnCmd => UnCmd_tb,
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

		procedure push_op(variable Op1_int : out integer; variable Op2_int: out integer; variable Cmd: out std_logic_vector(CMD_ALU_L-1 downto 0); variable seed1, seed2: inout positive) is
			variable Op1_in, Op2_in, Cmd_in	: integer;
			variable rand_val, sign_val	: real;
			variable Cmd_int: std_logic_vector(CMD_ALU_L-1 downto 0);
		begin
			uniform(seed1, seed2, rand_val);
			Cmd_in := integer(rand_val*(2.0**(real(CMD_ALU_L)) - 1.0));

			Cmd_tb <= std_logic_vector(to_unsigned(Cmd_in, CMD_ALU_L));
			Cmd := std_logic_vector(to_unsigned(Cmd_in, CMD_ALU_L));
			Cmd_int := std_logic_vector(to_unsigned(Cmd_in, CMD_ALU_L));

			if (Cmd_int = CMD_ALU_SSUM) or (Cmd_int = CMD_ALU_SSUB) or (Cmd_int = CMD_ALU_SCMP) then
				uniform(seed1, seed2, rand_val);
				uniform(seed1, seed2, sign_val);
				Op1_in := integer(rand_sign(sign_val)*rand_val*(2.0**(real(OP1_L_TB) - 1.0) - 1.0));
				uniform(seed1, seed2, rand_val);
				uniform(seed1, seed2, sign_val);
				Op2_in := integer(rand_sign(sign_val)*rand_val*(2.0**(real(OP2_L_TB) - 1.0) - 1.0));

				Op1_tb <= std_logic_vector(to_signed(Op1_in, OP1_L_TB));
				Op2_tb <= std_logic_vector(to_signed(Op2_in, OP2_L_TB));
			else
				uniform(seed1, seed2, rand_val);
				Op1_in := integer(rand_val*(2.0**(real(OP1_L_TB)) - 1.0));
				uniform(seed1, seed2, rand_val);
				Op2_in := integer(rand_val*(2.0**(real(OP2_L_TB)) - 1.0));

				Op1_tb <= std_logic_vector(to_unsigned(Op1_in, OP1_L_TB));
				Op2_tb <= std_logic_vector(to_unsigned(Op2_in, OP2_L_TB));
			end if;

			Op1_int := Op1_in;
			Op2_int := Op2_in;

			Start_tb <= '1';

			wait until ((clk_tb'event) and (clk_tb = '1'));
			Start_tb <= '0';
		end procedure push_op;

		procedure verify(variable Op1_int, Op2_int, Res_ideal, Res_rtl : integer; variable Ovfl_ideal, Ovfl_rtl, Unfl_ideal, Unfl_rtl: in boolean; Cmd_txt : in string; file file_pointer : text; variable pass: out integer) is
			variable file_line	: line;
		begin
			if (Res_rtl = Res_ideal) and (Ovfl_ideal = Ovfl_rtl) and (Unfl_ideal = Unfl_rtl) then
				write(file_line, string'( "ALU operation " & Cmd_txt & " of " & integer'image(Op1_int) & " and " & integer'image(Op2_int) & " gives: RTL Result:" & integer'image(Res_rtl) & ", overflow:" & bool_to_str(Ovfl_rtl) & ", underflow:" & bool_to_str(Unfl_rtl) & " and reference: Result " & integer'image(Res_ideal) & ", overflow:" & bool_to_str(Ovfl_ideal) & ", underflow:" & bool_to_str(Unfl_ideal) & ": PASS"));
				pass := 1;
			elsif (Ovfl_ideal = Ovfl_rtl) and (Unfl_ideal = Unfl_rtl) then
				write(file_line, string'( "ALU operation " & Cmd_txt & " of " & integer'image(Op1_int) & " and " & integer'image(Op2_int) & " gives: RTL Result:" & integer'image(Res_rtl) & ", overflow:" & bool_to_str(Ovfl_rtl) & ", underflow:" & bool_to_str(Unfl_rtl) & " and reference: Result " & integer'image(Res_ideal) & ", overflow:" & bool_to_str(Ovfl_ideal) & ", underflow:" & bool_to_str(Unfl_ideal) & ": FAIL (Result)"));
				pass := 0;
			elsif (Res_ideal = Res_rtl) and (Unfl_ideal = Unfl_rtl) then
				write(file_line, string'( "ALU operation " & Cmd_txt & " of " & integer'image(Op1_int) & " and " & integer'image(Op2_int) & " gives: RTL Result:" & integer'image(Res_rtl) & ", overflow:" & bool_to_str(Ovfl_rtl) & ", underflow:" & bool_to_str(Unfl_rtl) & " and reference: Result " & integer'image(Res_ideal) & ", overflow:" & bool_to_str(Ovfl_ideal) & ", underflow:" & bool_to_str(Unfl_ideal) & ": FAIL (Overflow)"));
				pass := 0;
			elsif (Ovfl_ideal = Ovfl_rtl) and (Res_ideal = Res_rtl) then
				write(file_line, string'( "ALU operation " & Cmd_txt & " of " & integer'image(Op1_int) & " and " & integer'image(Op2_int) & " gives: RTL Result:" & integer'image(Res_rtl) & ", overflow:" & bool_to_str(Ovfl_rtl) & ", underflow:" & bool_to_str(Unfl_rtl) & " and reference: Result " & integer'image(Res_ideal) & ", overflow:" & bool_to_str(Ovfl_ideal) & ", underflow:" & bool_to_str(Unfl_ideal) & ": FAIL (Underflow)"));
				pass := 0;
			elsif (Ovfl_ideal = Ovfl_rtl) then
				write(file_line, string'( "ALU operation " & Cmd_txt & " of " & integer'image(Op1_int) & " and " & integer'image(Op2_int) & " gives: RTL Result:" & integer'image(Res_rtl) & ", overflow:" & bool_to_str(Ovfl_rtl) & ", underflow:" & bool_to_str(Unfl_rtl) & " and reference: Result " & integer'image(Res_ideal) & ", overflow:" & bool_to_str(Ovfl_ideal) & ", underflow:" & bool_to_str(Unfl_ideal) & ": FAIL (Result and underflow)"));
				pass := 0;
			elsif (Unfl_ideal = Unfl_rtl) then
				write(file_line, string'( "ALU operation " & Cmd_txt & " of " & integer'image(Op1_int) & " and " & integer'image(Op2_int) & " gives: RTL Result:" & integer'image(Res_rtl) & ", overflow:" & bool_to_str(Ovfl_rtl) & ", underflow:" & bool_to_str(Unfl_rtl) & " and reference: Result " & integer'image(Res_ideal) & ", overflow:" & bool_to_str(Ovfl_ideal) & ", underflow:" & bool_to_str(Unfl_ideal) & ": FAIL (Result and overflow)"));
				pass := 0;
			elsif (Res_ideal = Res_rtl) then
				write(file_line, string'( "ALU operation " & Cmd_txt & " of " & integer'image(Op1_int) & " and " & integer'image(Op2_int) & " gives: RTL Result:" & integer'image(Res_rtl) & ", overflow:" & bool_to_str(Ovfl_rtl) & ", underflow:" & bool_to_str(Unfl_rtl) & " and reference: Result " & integer'image(Res_ideal) & ", overflow:" & bool_to_str(Ovfl_ideal) & ", underflow:" & bool_to_str(Unfl_ideal) & ": FAIL (Underflow and overflow)"));
				pass := 0;
			else
				write(file_line, string'( "ALU operation " & Cmd_txt & " of " & integer'image(Op1_int) & " and " & integer'image(Op2_int) & " gives: RTL Result:" & integer'image(Res_rtl) & ", overflow:" & bool_to_str(Ovfl_rtl) & ", underflow:" & bool_to_str(Unfl_rtl) & " and reference: Result " & integer'image(Res_ideal) & ", overflow:" & bool_to_str(Ovfl_ideal) & ", underflow:" & bool_to_str(Unfl_ideal) & ": FAIL (Result, overflow and underflow)"));
				pass := 0;
			end if;
			writeline(file_pointer, file_line);
		end procedure verify;

		variable Res_rtl, Res_ideal	: integer;
		variable Ovfl_rtl, Ovfl_ideal	: boolean;
		variable Unfl_rtl, Unfl_ideal	: boolean;
		variable Op1_int, Op2_int	: integer;
		variable seed1, seed2	: positive;
		variable Cmd	: std_logic_vector(CMD_ALU_L-1 downto 0);
		variable Cmd_txt	: string(1 to 4);
		variable pass	: integer;
		variable num_pass	: integer;

		file file_pointer	: text;
		variable file_line	: line;

	begin

		wait for 1 ns;

		num_pass := 0;

		reset;
		file_open(file_pointer, log_file, append_mode);

		write(file_line, string'( "ALU Test"));
		writeline(file_pointer, file_line);

		for i in 0 to NUM_TEST-1 loop
			push_op(Op1_int, Op2_int, Cmd, seed1, seed2);

			wait on Done_tb;

			if (Cmd = CMD_ALU_SSUM) or (Cmd = CMD_ALU_SSUB) or (Cmd = CMD_ALU_SCMP) then
				Res_rtl := to_integer(signed(Res_tb));
			else
				Res_rtl := to_integer(unsigned(Res_tb));
			end if;

			Ovfl_rtl := std_logic_to_bool(Ovfl_tb);
			Unfl_rtl := std_logic_to_bool(Unfl_tb);

			Cmd_txt := alu_cmd_std_vect_to_txt(Cmd);
			alu_ref(Op1_int, Op2_int, Cmd, Res_ideal, Ovfl_ideal, Unfl_ideal);
			verify(Op1_int, Op2_int, Res_ideal, Res_rtl, Ovfl_ideal, Ovfl_rtl, Unfl_ideal, Unfl_rtl, Cmd_txt, file_pointer, pass);

			num_pass := num_pass + pass;

			wait until ((clk_tb'event) and (clk_tb = '1'));
		end loop;

		file_close(file_pointer);

		file_open(file_pointer, summary_file, append_mode);
		write(file_line, string'( "ALU => PASSES: " & integer'image(num_pass) & " out of " & integer'image(NUM_TEST)));
		writeline(file_pointer, file_line);

		file_close(file_pointer);
		stop <= true;

	end process test;

end bench;
