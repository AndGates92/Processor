library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.reg_file_pkg.all;
use work.proc_pkg.all;
use work.tb_pkg.all;

entity reg_file_tb is
end entity reg_file_tb;

architecture bench of reg_file_tb is

	constant CLK_PERIOD	: time := 10 ns;
	constant NUM_TEST	: integer := 1000;

	constant REG_L_TB	: positive := 16;
	constant REG_NUM_TB	: positive := 16;
	constant EN_L_TB	: positive := 3;
	constant OUT_NUM_TB	: positive := 2;

	signal rst_tb	: std_logic;
	signal stop	: boolean := false;
	signal clk_tb	: std_logic := '0';

	signal DataIn_tb	: std_logic_vector(REG_L_TB - 1 downto 0);
	signal AddressIn_tb	: std_logic_vector(count_length(REG_NUM_TB) - 1 downto 0);
	signal AddressOut1_tb	: std_logic_vector(count_length(REG_NUM_TB) - 1 downto 0);
	signal AddressOut2_tb	: std_logic_vector(count_length(REG_NUM_TB) - 1 downto 0);
	signal Enable_tb	: std_logic_vector(EN_L_TB-1 downto 0);
	signal Done_tb		: std_logic_vector(OUT_NUM_TB-1 downto 0);
	signal DataOut1_tb	: std_logic_vector(REG_L_TB-1 downto 0);
	signal DataOut2_tb	: std_logic_vector(REG_L_TB-1 downto 0);
	signal End_LS_tb	: std_logic;

	type reg_file_tb is array(0 to REG_NUM_TB) of integer;

begin

	DUT: reg_file generic map(
		REG_L => REG_L_TB,
		REG_NUM => REG_NUM_TB,
		EN_L => EN_L_TB,
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

	clk_tb <= not clk_tb after CLK_PERIOD/2 when not stop;

	test: process
		procedure reset(variable RegFileOut_int : out reg_file_tb) is
		begin
			rst_tb <= '0';
			wait until rising_edge(clk_tb);
			rst_tb <= '1';
			DataIn_tb <= (others => '0');
			AddressIn_tb <= (others => '0');
			AddressOut1_tb <= (others => '0');
			AddressOut2_tb <= (others => '0');
			Enable_tb <= (others => '0');
			RegFileOut_int := (others => 0);
			wait until rising_edge(clk_tb);
			rst_tb <= '0';
		end procedure reset;

		procedure push_op(variable DataIn_int : out integer; variable AddressIn_int: out integer; variable AddressOut1_int : out integer; variable AddressOut2_int: out integer; variable Enable_int: out integer; variable seed1, seed2: inout positive) is
			variable DataIn_in, AddressIn_in	: integer;
			variable AddressOut1_in, AddressOut2_in	: integer;
			variable Enable_in	: integer;
			variable rand_val, sign_val	: real;
		begin
			Enable_in := 0;

			uniform(seed1, seed2, rand_val);
			DataIn_in := integer(rand_val*(2.0**(real(REG_L_TB)) - 1.0));
			DataIn_tb <= std_logic_vector(to_unsigned(DataIn_in, REG_L_TB));
			DataIn_int := DataIn_in;

			uniform(seed1, seed2, rand_val);
			AddressIn_in := integer(rand_val*(2.0**(real(count_length(REG_NUM_TB))) - 1.0));
			AddressIn_tb <= std_logic_vector(to_unsigned(AddressIn_in, count_length(REG_NUM_TB)));
			AddressIn_int := AddressIn_in;

			uniform(seed1, seed2, rand_val);
			AddressOut1_in := integer(rand_val*(2.0**(real(count_length(REG_NUM_TB))) - 1.0));
			AddressOut1_tb <= std_logic_vector(to_unsigned(AddressOut1_in, count_length(REG_NUM_TB)));
			AddressOut1_int := AddressOut1_in;

			uniform(seed1, seed2, rand_val);
			AddressOut2_in := integer(rand_val*(2.0**(real(count_length(REG_NUM_TB))) - 1.0));
			AddressOut2_tb <= std_logic_vector(to_unsigned(AddressOut2_in, count_length(REG_NUM_TB)));
			AddressOut2_int := AddressOut2_in;

			while (Enable_in = 0) loop
				uniform(seed1, seed2, rand_val);
				Enable_in := integer(rand_val*(2.0**(real(EN_L_TB)) - 1.0));
			end loop;

			Enable_tb <= std_logic_vector(to_unsigned(Enable_in, EN_L_TB));
			Enable_int := Enable_in;

			wait until rising_edge(clk_tb);

			Enable_tb <= (others => '0');

		end procedure push_op;

		procedure reference(variable RegFileIn_int: in reg_file_tb; variable DataIn_int : in integer; variable AddressIn_int: in integer; variable AddressOut1_int : in integer; variable AddressOut2_int: in integer; variable Enable_int: in integer; variable Done_int: out integer; variable DataOut1_int: out integer; variable DataOut2_int : out integer; variable RegFileOut_int: out reg_file_tb) is
			variable Enable_vec	: std_logic_vector(EN_L_TB - 1 downto 0);
			variable Done_tmp	: integer;
		begin

			Done_tmp := 0;
			RegFileOut_int := RegFileIn_int;
			Enable_vec := std_logic_vector(to_unsigned(Enable_int,EN_L_TB));

			if (Enable_vec(0) = '1') then
				RegFileOut_int(AddressIn_int) := DataIn_int;
			end if;

			if (Enable_vec(1) = '1') then
				DataOut1_int := RegFileIn_int(AddressOut1_int);
				Done_tmp := Done_tmp + 1;
			else
				DataOut1_int := 0;
			end if;

			if (Enable_vec(2) = '1') then
				DataOut2_int := RegFileIn_int(AddressOut2_int);
				Done_tmp := Done_tmp + 2;
			else
				DataOut2_int := 0;
			end if;

			Done_int := Done_tmp;

		end procedure reference;

		procedure verify(variable DataIn_int : in integer; variable DataOut1_ideal, DataOut2_ideal, Done_ideal : in integer; variable DataOut1_rtl, DataOut2_rtl, Done_rtl : in integer; variable pass : out integer) is
		begin
			if (DataOut1_ideal = DataOut1_rtl) and (DataOut2_ideal = DataOut2_rtl) and (Done_ideal = Done_rtl) then
				report "Register File: Stored " & integer'image(DataIn_int) & " Read RTL Out1 " & integer'image(DataOut1_rtl) & " Out2 " & integer'image(DataOut2_rtl) & " Done_rtl "  & integer'image(Done_rtl) & " Ideal Out1 " & integer'image(DataOut1_ideal) & " Out2 " & integer'image(DataOut2_ideal) & " Done_ideal "  & integer'image(Done_ideal) & ": PASSED";
				pass := 1;
			elsif (DataOut1_ideal /= DataOut1_rtl) and (DataOut2_ideal = DataOut2_rtl) and (Done_ideal = Done_rtl) then
				report "Register File: Stored " & integer'image(DataIn_int) & " Read RTL Out1 " & integer'image(DataOut1_rtl) & " Out2 " & integer'image(DataOut2_rtl) & " Done_rtl "  & integer'image(Done_rtl) & " Ideal Out1 " & integer'image(DataOut1_ideal) & " Out2 " & integer'image(DataOut2_ideal) & " Done_ideal "  & integer'image(Done_ideal) & ": FAILED (Data Out 1)";
				pass := 0;
			elsif (DataOut1_ideal = DataOut1_rtl) and (DataOut2_ideal /= DataOut2_rtl) and (Done_ideal = Done_rtl) then
				report "Register File: Stored " & integer'image(DataIn_int) & " Read RTL Out1 " & integer'image(DataOut1_rtl) & " Out2 " & integer'image(DataOut2_rtl) & " Done_rtl "  & integer'image(Done_rtl) & " Ideal Out1 " & integer'image(DataOut1_ideal) & " Out2 " & integer'image(DataOut2_ideal) & " Done_ideal "  & integer'image(Done_ideal) & ": FAILED (Data Out 2)";
				pass := 0;
			elsif (DataOut1_ideal = DataOut1_rtl) and (DataOut2_ideal = DataOut2_rtl) and (Done_ideal /= Done_rtl) then
				report "Register File: Stored " & integer'image(DataIn_int) & " Read RTL Out1 " & integer'image(DataOut1_rtl) & " Out2 " & integer'image(DataOut2_rtl) & " Done_rtl "  & integer'image(Done_rtl) & " Ideal Out1 " & integer'image(DataOut1_ideal) & " Out2 " & integer'image(DataOut2_ideal) & " Done_ideal "  & integer'image(Done_ideal) & ": FAILED (Done signal)";
				pass := 0;
			elsif (DataOut1_ideal /= DataOut1_rtl) and (DataOut2_ideal /= DataOut2_rtl) and (Done_ideal = Done_rtl) then
				report "Register File: Stored " & integer'image(DataIn_int) & " Read RTL Out1 " & integer'image(DataOut1_rtl) & " Out2 " & integer'image(DataOut2_rtl) & " Done_rtl "  & integer'image(Done_rtl) & " Ideal Out1 " & integer'image(DataOut1_ideal) & " Out2 " & integer'image(DataOut2_ideal) & " Done_ideal "  & integer'image(Done_ideal) & ": FAILED (Data Out 1 and Out 2)";
				pass := 0;
			elsif (DataOut1_ideal /= DataOut1_rtl) and (DataOut2_ideal = DataOut2_rtl) and (Done_ideal /= Done_rtl) then
				report "Register File: Stored " & integer'image(DataIn_int) & " Read RTL Out1 " & integer'image(DataOut1_rtl) & " Out2 " & integer'image(DataOut2_rtl) & " Done_rtl "  & integer'image(Done_rtl) & " Ideal Out1 " & integer'image(DataOut1_ideal) & " Out2 " & integer'image(DataOut2_ideal) & " Done_ideal "  & integer'image(Done_ideal) & ": FAILED (Data Out 1 and Done signal)";
				pass := 0;
			elsif (DataOut1_ideal = DataOut1_rtl) and (DataOut2_ideal /= DataOut2_rtl) and (Done_ideal /= Done_rtl) then
				report "Register File: Stored " & integer'image(DataIn_int) & " Read RTL Out1 " & integer'image(DataOut1_rtl) & " Out2 " & integer'image(DataOut2_rtl) & " Done_rtl "  & integer'image(Done_rtl) & " Ideal Out1 " & integer'image(DataOut1_ideal) & " Out2 " & integer'image(DataOut2_ideal) & " Done_ideal "  & integer'image(Done_ideal) & ": FAILED (Data Out 2 and Done signal)";
				pass := 0;
			else
				report "Register File: Stored " & integer'image(DataIn_int) & " Read RTL Out1 " & integer'image(DataOut1_rtl) & " Out2 " & integer'image(DataOut2_rtl) & " Done_rtl "  & integer'image(Done_rtl) & " Ideal Out1 " & integer'image(DataOut1_ideal) & " Out2 " & integer'image(DataOut2_ideal) & " Done_ideal "  & integer'image(Done_ideal) & ": FAILED (Data Out 1 and Out 2 and Done signal)";
				pass := 0;
			end if;
		end procedure verify;

		variable RegFileOut, RegFileIn	: reg_file_tb;
		variable DataIn, AddressIn, AddressOut1, AddressOut2, Enable	: integer;
		variable Done_rtl, DataOut1_rtl, DataOut2_rtl	: integer;
		variable Done_ideal, DataOut1_ideal, DataOut2_ideal	: integer;
		variable seed1, seed2	: positive;
		variable pass	: integer;
		variable num_pass	: integer;

	begin

		wait for 1 ns;

		num_pass := 0;

		reset(RegFileOut);

		for i in 0 to NUM_TEST-1 loop
			RegFileIn := RegFileOut;

			push_op(DataIn, AddressIn, AddressOut1, AddressOut2, Enable, seed1, seed2);

			wait on End_LS_tb;

			DataOut1_rtl := to_integer(unsigned(DataOut1_tb));
			DataOut2_rtl := to_integer(unsigned(DataOut2_tb));
			Done_rtl := to_integer(unsigned(Done_tb));

			reference(RegFileIn, DataIn, AddressIn, AddressOut1, AddressOut2, Enable, Done_ideal, DataOut1_ideal, DataOut2_ideal, RegFileOut);

			verify(DataIn, DataOut1_ideal, DataOut2_ideal, Done_ideal, DataOut1_rtl, DataOut2_rtl, Done_rtl, pass);

			num_pass := num_pass + pass;

			wait until rising_edge(clk_tb);
		end loop;

		report "PASSED: " & integer'image(num_pass) & " out of " & integer'image(NUM_TEST);

		stop <= true;

	end process test;

end bench;
