library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;

library common_tb_pkg;
use common_tb_pkg.shared_pkg_tb.all;
use common_tb_pkg.common_pkg_tb.all;
use common_tb_pkg.functions_pkg_tb.all;
use common_tb_pkg.common_log_pkg.all;
use common_tb_pkg.fifo_pkg_tb.all;

library common_rtl_pkg;
use common_rtl_pkg.type_conversion_pkg.all;
use common_rtl_pkg.fifo_1clk_pkg.all;

entity fifo_1clk_tb is
end entity fifo_1clk_tb;

architecture bench of fifo_1clk_tb is

	constant CLK_PERIOD	: time := COMMON_CLK_PERIOD * 1 ns;
	constant NUM_TEST	: integer := 10000;

	constant FIFO_1CLK_DATA_L_TB	: integer := 30;
	constant FIFO_1CLK_SIZE_TB	: positive := 16;

	signal clk_tb		: std_logic := '0';
	signal rst_wr_tb	: std_logic;
	signal rst_rd_tb	: std_logic;

	signal stop		: boolean := false;

	signal DataOut_tb	: std_logic_vector(FIFO_1CLK_DATA_L_TB - 1 downto 0);
	signal En_rd_tb		: std_logic;
	signal empty_tb		: std_logic;

	signal DataIn_tb	: std_logic_vector(FIFO_1CLK_DATA_L_TB - 1 downto 0);
	signal En_wr_tb		: std_logic;
	signal full_tb		: std_logic;

	signal ValidOut_tb	: std_logic;
	signal EndRst_tb	: std_logic;

	type fifo_t is array (FIFO_1CLK_SIZE_TB - 1 downto 0) of integer;

begin

	DUT: fifo_1clk generic map (
		DATA_L => FIFO_1CLK_DATA_L_TB,
		FIFO_SIZE => FIFO_1CLK_SIZE_TB
	)
	port map (
		clk => clk_tb,

		rst_rd => rst_rd_tb,
		DataOut => DataOut_tb,
		En_rd => En_rd_tb,
		empty => empty_tb,

		rst_wr => rst_wr_tb,
		DataIn => DataIn_tb,
		En_wr => En_wr_tb,
		full => full_tb,

		ValidOut => ValidOut_tb,
		EndRst => EndRst_tb

	);

	clk_gen(CLK_PERIOD, 0 ns, stop, clk_tb);

	test: process

		procedure reset_rd (variable RdPtrOut : out integer; variable emptyOut_bool : out boolean) is
		begin
			rst_rd_tb <= '0';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_rd_tb <= '1';
			emptyOut_bool := True;
			RdPtrOut := 0;
			En_rd_tb <= '0';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_rd_tb <= '0';
		end procedure reset_rd;

		procedure reset_wr(variable FifoOut_mem : out fifo_t; variable WrPtrOut : out integer; variable fullOut_bool : out boolean) is
		begin
			rst_wr_tb <= '0';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_wr_tb <= '1';
			DataIn_tb <= (others => '0');
			FifoOut_mem := (others => 0);
			fullOut_bool := False;
			WrPtrOut := 0;
			En_wr_tb <= '0';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_wr_tb <= '0';

			wait on EndRst_tb;
			wait until ((clk_tb'event) and (clk_tb = '1'));

		end procedure reset_wr;

		procedure push_op(variable DataIn_int : out integer; variable En_wr_bool, En_rd_bool : out boolean; variable seed1, seed2 : inout positive) is
			variable DataIn_in	: integer;
			variable rand_val	: real;
			variable En_wr_in, En_rd_in	: boolean;

		begin

			uniform(seed1, seed2, rand_val);
			DataIn_in := integer(rand_val*(2.0**(real(FIFO_1CLK_DATA_L_TB)) - 1.0));
			DataIn_tb <= std_logic_vector(to_unsigned(DataIn_in, FIFO_1CLK_DATA_L_TB));
			DataIn_int := DataIn_in;

			uniform(seed1, seed2, rand_val);
			En_wr_in := rand_bool(rand_val, 0.5);
			En_wr_tb <= bool_to_std_logic(En_wr_in);
			En_wr_bool := En_wr_in;

			uniform(seed1, seed2, rand_val);
			En_rd_in := rand_bool(rand_val, 0.5);
			En_rd_tb <= bool_to_std_logic(En_rd_in);
			En_rd_bool := En_rd_in;

			wait until ((clk_tb'event) and (clk_tb = '1'));
			En_wr_tb <= '0';
			En_rd_tb <= '0';

		end procedure push_op;

		procedure fifo_ref(variable DataIn_int : in integer; variable DataOut_int : out integer; variable En_wr_bool, En_rd_bool : in boolean; variable fullIn_bool, emptyIn_bool : in boolean; variable fullOut_bool, emptyOut_bool : out boolean; variable FifoIn_mem : in fifo_t; variable FifoOut_mem : out fifo_t; variable WrPtrIn, RdPtrIn : in integer; variable WrPtrOut, RdPtrOut : out integer) is

			variable WrPtrNext, RdPtrNext	: integer;

		begin
			FifoOut_mem := FifoIn_mem;
			WrPtrOut := WrPtrIn;
			RdPtrOut := RdPtrIn;

			fullOut_bool := fullIn_bool;
			emptyOut_bool := emptyIn_bool;

			if (WrPtrIn = FIFO_1CLK_SIZE_TB - 1) then
				WrPtrNext := 0;
			else
				WrPtrNext := WrPtrIn + 1;
			end if;

			if (RdPtrIn = FIFO_1CLK_SIZE_TB - 1) then
				RdPtrNext := 0;
			else
				RdPtrNext := RdPtrIn + 1;
			end if;

			if (En_rd_bool = True) and (emptyIn_bool = False) then
				RdPtrOut := RdPtrNext;
				DataOut_int := FifoIn_mem(RdPtrIn);
			else
				DataOut_int := 0;
			end if;

			if (En_wr_bool = True) and (fullIn_bool = False) then
				FifoOut_mem(WrPtrIn) := DataIn_int;
				WrPtrOut := WrPtrNext;
			end if;

			if (En_rd_bool = True) and (En_wr_bool = False) and (WrPtrIn = RdPtrNext) then
				emptyOut_bool := True;
			elsif (RdPtrIn = WrPtrIn) and (En_wr_bool = True) then
				emptyOut_bool := False;
			end if;

			if (En_wr_bool = True) and (En_rd_bool = False) and (RdPtrIn = WrPtrNext) then
				fullOut_bool := True;
			elsif (RdPtrIn = WrPtrIn)  and (En_rd_bool = True)then
				fullOut_bool := False;
			end if;
		end procedure fifo_ref;

		procedure verify(variable DataIn_int : in integer; variable En_wr_bool, En_rd_bool : in boolean; variable DataOut_ideal, DataOut_rtl : in integer; variable fullOut_ideal, fullOut_rtl : in boolean; variable emptyOut_ideal, emptyOut_rtl : in boolean; file file_pointer : text; variable pass: out integer) is
			variable file_line	: line;
		begin

			write(file_line, string'( "FIFO: Data In " & integer'image(DataIn_int) & " write enable " & bool_to_str(En_wr_bool) & " and read enable " & bool_to_str(En_rd_bool)));
			writeline(file_pointer, file_line);

			if (DataOut_ideal = DataOut_rtl) and (fullOut_ideal = fullOut_rtl) and (emptyOut_ideal = emptyOut_rtl) then
				write(file_line, string'("PASS Data Out " & integer'image(DataOut_ideal) & " Full " & bool_to_str(fullOut_ideal)  & " Empty " & bool_to_str(emptyOut_ideal)));
				pass := 1;
			elsif (fullOut_ideal /= fullOut_rtl) then
				write(file_line, string'("FAIL Full rtl " & bool_to_str(fullOut_rtl) & " ideal " & bool_to_str(fullOut_ideal)));
				pass := 0;
			elsif (DataOut_ideal /= DataOut_rtl) then
				write(file_line, string'("FAIL Data Out rtl " & integer'image(DataOut_rtl) & " ideal " & integer'image(DataOut_ideal)));
				pass := 0;
			else
				write(file_line, string'("FAIL Empty rtl " & bool_to_str(emptyOut_rtl) & " ideal " & bool_to_str(emptyOut_ideal)));
				pass := 0;
			end if;
			writeline(file_pointer, file_line);

		end procedure verify;

		variable FifoIn_mem, FifoOut_mem	: fifo_t;

		variable fullOut_bool, fullIn_bool	: boolean;
		variable emptyOut_bool, emptyIn_bool	: boolean;

		variable fullRtl_bool			: boolean;
		variable emptyRtl_bool			: boolean;

		variable En_wr_bool			: boolean;
		variable En_rd_bool			: boolean;

		variable WrPtrOut_int, WrPtrIn_int	: integer;
		variable RdPtrOut_int, RdPtrIn_int	: integer;

		variable DataOut_rtl, DataOut_ideal	: integer;
		variable DataIn_int			: integer;

		variable seed1, seed2			: positive;

		variable pass				: integer;
		variable num_pass			: integer;

		file file_pointer			: text;
		variable file_line			: line;

	begin

		wait for 1 ns;

		num_pass := 0;

		file_open(file_pointer, fifo_1clk_log_file, append_mode);

		reset_rd(RdPtrOut_int, emptyOut_bool);

		write(file_line, string'( "FIFO 1 clock Test"));
		writeline(file_pointer, file_line);

		write(file_line, string'( "Read reset successful"));
		writeline(file_pointer, file_line);

		reset_wr(FifoOut_mem, WrPtrOut_int, fullOut_bool);
		write(file_line, string'( "Write reset successful"));
		writeline(file_pointer, file_line);


		for i in 0 to NUM_TEST-1 loop

			FifoIn_mem := FifoOut_mem;

			WrPtrIn_int := WrPtrOut_int;
			RdPtrIn_int := RdPtrOut_int;

			fullIn_bool := fullOut_bool;
			emptyIn_bool := emptyOut_bool;

			push_op(DataIn_int, En_wr_bool, En_rd_bool, seed1, seed2);

			fifo_ref(DataIn_int, DataOut_ideal, En_wr_bool, En_rd_bool, fullIn_bool, emptyIn_bool, fullOut_bool, emptyOut_bool, FifoIn_mem, FifoOut_mem, WrPtrIn_int, RdPtrIn_int, WrPtrOut_int, RdPtrOut_int);

			if (En_rd_bool = True) and (emptyIn_bool = False) then
				if (ValidOut_tb = '0') then
					wait on ValidOut_tb;
					wait for 1 ps;
				else
					wait until ((clk_tb'event) and (clk_tb = '1'));
				end if;
			else
				wait for 1 ps;
			end if;

			fullRtl_bool := std_logic_to_bool(full_tb);
			emptyRtl_bool := std_logic_to_bool(empty_tb);
			DataOut_rtl := to_integer(unsigned(DataOut_tb));

			verify (DataIn_int, En_wr_bool, En_rd_bool, DataOut_ideal, DataOut_rtl, fullOut_bool, fullRtl_bool,  emptyOut_bool, emptyRtl_bool, file_pointer, pass);
			num_pass := num_pass + pass;

		end loop;

		file_close(file_pointer);

		file_open(file_pointer, summary_file, append_mode);
		write(file_line, string'( "FIFO 1 CLOCK => PASSES: " & integer'image(num_pass) & " out of " & integer'image(NUM_TEST)));
		writeline(file_pointer, file_line);

		if (num_pass = NUM_TEST) then
			write(file_line, string'( "FIFO 1 CLOCK: TEST PASSED"));
		else
			write(file_line, string'( "FIFO 1 CLOCK: TEST FAILED: " & integer'image(NUM_TEST-num_pass) & " failures"));
		end if;
		writeline(file_pointer, file_line);

		file_close(file_pointer);
		stop <= true;

		wait;

	end process test;

end bench;
