library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;
use work.fifo_2clk_pkg.all;
use work.type_conversion_pkg.all;
use work.shared_tb_pkg.all;
use work.common_tb_pkg.all;
use work.functions_tb_pkg.all;
use work.common_log_pkg.all;
use work.fifo_pkg_tb.all;

entity fifo_2clk_tb is
end entity fifo_2clk_tb;

architecture bench of fifo_2clk_tb is

	constant CLK_WR_PERIOD	: time := COMMON_CLK_PERIOD * 1 ns;
	constant CLK_RD_PERIOD	: time := COMMON_CLK_PERIOD * 1 ns;
	constant CLK_WR_PHASE	: time := 0 ns;
	constant CLK_RD_PHASE	: time := 1 ns;
	constant MAX_PERIOD	: time := max_time(CLK_WR_PERIOD, CLK_RD_PERIOD);
	constant WAIT_TIME	: time := 10 ps;
	constant NUM_TEST	: integer := 100;

	constant FIFO_2CLK_DATA_L_TB		: integer := 32;
	constant FIFO_2CLK_SIZE_TB	: positive := 16;

	constant CDC		: boolean := ((CLK_WR_PERIOD /= CLK_RD_PERIOD) or (CLK_WR_PHASE /= CLK_RD_PHASE));

	signal clk_wr_tb	: std_logic := '0';
	signal rst_wr_tb	: std_logic;
	signal clk_rd_tb	: std_logic := '0';
	signal rst_rd_tb	: std_logic;

	signal stop		: boolean := false;

	signal DataOut_tb	: std_logic_vector(FIFO_2CLK_DATA_L_TB - 1 downto 0);
	signal En_rd_tb		: std_logic;
	signal empty_tb		: std_logic;

	signal DataIn_tb	: std_logic_vector(FIFO_2CLK_DATA_L_TB - 1 downto 0);
	signal En_wr_tb		: std_logic;
	signal full_tb		: std_logic;

	signal ValidOut_tb	: std_logic;
	signal EndRst_tb	: std_logic;

	type fifo_t is array (0 to FIFO_2CLK_SIZE_TB - 1) of integer;
	type bool_del_t is array (0 to NUM_STAGES - 1) of boolean;
	type int_del_t is array (0 to NUM_STAGES - 1) of integer;

begin

	DUT: fifo_2clk generic map (
		DATA_L => FIFO_2CLK_DATA_L_TB,
		FIFO_SIZE => FIFO_2CLK_SIZE_TB
	)
	port map (
		rst_rd => rst_rd_tb,
		clk_rd => clk_rd_tb,
		DataOut => DataOut_tb,
		En_rd => En_rd_tb,
		empty => empty_tb,

		rst_wr => rst_wr_tb,
		clk_wr => clk_wr_tb,
		DataIn => DataIn_tb,
		En_wr => En_wr_tb,
		full => full_tb,

		ValidOut => ValidOut_tb,
		EndRst => EndRst_tb

	);

	clk_gen(CLK_WR_PERIOD, CLK_WR_PHASE, stop, clk_wr_tb);

	ONE_CLK: if (not CDC) generate
		clk_rd_tb <= clk_wr_tb;
	end generate ONE_CLK;

	RD_CLK_GEN: if (CDC) generate
		clk_gen(CLK_RD_PERIOD, CLK_RD_PHASE, stop, clk_rd_tb);
	end generate RD_CLK_GEN;

	test: process

		procedure reset (variable RdPtrOut : out integer; variable emptyOut_bool : out boolean; variable En_rd_bool : out bool_del_t; variable FifoOut_mem : out fifo_t; variable WrPtrOut : out integer; variable fullOut_bool : out boolean; variable DataIn_int : out int_del_t; En_wr_bool : out bool_del_t) is
		begin
			rst_rd_tb <= '0';
			rst_wr_tb <= '0';

			if (not CDC) then -- no clock domain crossing
				wait until ((clk_wr_tb'event) and (clk_wr_tb = '1'));
				rst_rd_tb <= '1';
				emptyOut_bool := True;
				En_rd_bool := (others => False);
				RdPtrOut := 0;
				En_rd_tb <= '0';

				rst_wr_tb <= '1';
				DataIn_tb <= (others => '0');
				FifoOut_mem := (others => 0);
				DataIn_int := (others => 0);
				fullOut_bool := False;
				WrPtrOut := 0;
				En_wr_tb <= '0';

				wait until ((clk_wr_tb'event) and (clk_wr_tb = '1'));
				rst_wr_tb <= '0';
				rst_rd_tb <= '0';

				wait on EndRst_tb;
				wait until ((clk_wr_tb'event) and (clk_wr_tb = '1'));
			else
				wait until ((clk_rd_tb'event) and (clk_rd_tb = '1'));
				rst_rd_tb <= '1';
				emptyOut_bool := True;
				En_rd_bool := (others => False);
				RdPtrOut := 0;
				En_rd_tb <= '0';

				wait until ((clk_wr_tb'event) and (clk_wr_tb = '1'));
				rst_wr_tb <= '1';
				DataIn_tb <= (others => '0');
				FifoOut_mem := (others => 0);
				DataIn_int := (others => 0);
				fullOut_bool := False;
				WrPtrOut := 0;
				En_wr_tb <= '0';

				wait until ((clk_rd_tb'event) and (clk_rd_tb = '1'));
				rst_wr_tb <= '0';
				rst_rd_tb <= '0';

				wait on EndRst_tb;
				wait until ((clk_wr_tb'event) and (clk_wr_tb = '1'));
			end if;
		end procedure reset;

		procedure push_op(variable DataIn_int : out integer; variable En_wr_bool, En_rd_bool : out boolean; variable seed1, seed2 : inout positive) is
			variable DataIn_in	: integer;
			variable rand_val	: real;
			variable En_wr_in, En_rd_in	: boolean;

		begin

			uniform(seed1, seed2, rand_val);
			DataIn_in := integer(rand_val*(2.0**(real(FIFO_2CLK_DATA_L_TB)) - 1.0));
			DataIn_tb <= std_logic_vector(to_unsigned(DataIn_in, FIFO_2CLK_DATA_L_TB));
			DataIn_int := DataIn_in;

			if (full_tb = '0') then
				uniform(seed1, seed2, rand_val);
				En_wr_in := rand_bool(rand_val, 0.5);
				En_wr_tb <= bool_to_std_logic(En_wr_in), '0' after CLK_WR_PERIOD;
				En_wr_bool := En_wr_in;
			else
				En_wr_bool := False;
				En_wr_tb <= '0';
			end if;

			if (empty_tb = '0') then
				uniform(seed1, seed2, rand_val);
				En_rd_in := rand_bool(rand_val, 0.5);
				En_rd_tb <= bool_to_std_logic(En_rd_in), '0' after CLK_RD_PERIOD;
				En_rd_bool := En_rd_in;
			else
				En_rd_bool := False;
				En_rd_tb <= '0';
			end if;

			wait for MAX_PERIOD;

		end procedure push_op;

		procedure fifo_ref(variable DataIn_int : in integer; variable En_wr_bool, En_rd_bool : in boolean; variable DataInIn_int : in int_del_t; variable DataInOut_int : out int_del_t; variable DataOut_int : out integer; variable En_wrIn_bool, En_rdIn_bool : in bool_del_t; variable En_wrOut_bool, En_rdOut_bool : out bool_del_t; variable fullIn_bool, emptyIn_bool : in boolean; variable fullOut_bool, emptyOut_bool : out boolean; variable FifoIn_mem : in fifo_t; variable FifoOut_mem : out fifo_t; variable WrPtrIn, RdPtrIn : in integer; variable WrPtrOut, RdPtrOut : out integer) is

			variable WrPtrNext, RdPtrNext	: integer;
			variable full_tmp, empty_tmp	: boolean;

		begin

			for i in 1 to (NUM_STAGES - 1) loop
				En_wrOut_bool(i) := En_wrIn_bool(i-1);
				En_rdOut_bool(i) := En_rdIn_bool(i-1);

				DataInOut_int(i) := DataInIn_int(i-1);

			end loop;

			WrPtrOut := WrPtrIn;
			RdPtrOut := RdPtrIn;

			if (En_rd_bool = True) and (En_wr_bool = False) and (WrPtrIn = RdPtrNext) then
				empty_tmp := True;
			elsif (RdPtrIn = WrPtrIn) and (En_wrIn_bool(NUM_STAGES - 1) = True) then
				empty_tmp := False;
			else
				empty_tmp := emptyIn_bool;
			end if;

			emptyOut_bool := empty_tmp;

			if (En_wrIn_bool(NUM_STAGES - 1) = True) and (En_rdIn_bool(NUM_STAGES - 1) = False) and (RdPtrIn = WrPtrNext) then
				full_tmp := True;
			elsif (RdPtrIn = WrPtrIn)  and (En_rdIn_bool(NUM_STAGES - 1) = True)then
				full_tmp := False;
			else
				full_tmp := fullIn_bool;
			end if;

			fullOut_bool := full_tmp;

			if (full_tmp = False) then
				En_wrOut_bool(0) := En_wr_bool;
			else
				En_wrOut_bool(0) := False;
			end if;

			if (empty_tmp = False) then
				En_rdOut_bool(0) := En_rd_bool;
			else
				En_rdOut_bool(0) := False;
			end if;

			DataInOut_int(0) := DataIn_int;

			FifoOut_mem := FifoIn_mem;

			-- next address generation
			if (WrPtrIn = FIFO_2CLK_SIZE_TB - 1) then
				WrPtrNext := 0;
			else
				WrPtrNext := WrPtrIn + 1;
			end if;

			if (RdPtrIn = FIFO_2CLK_SIZE_TB - 1) then
				RdPtrNext := 0;
			else
				RdPtrNext := RdPtrIn + 1;
			end if;

			if (En_rdIn_bool(NUM_STAGES - 2) = True) then
				RdPtrOut := RdPtrNext;
				DataOut_int := FifoIn_mem(RdPtrIn);
			else
				RdPtrOut := RdPtrIn;
				DataOut_int := 0;
			end if;

			if (En_wrIn_bool(NUM_STAGES - 1) = True) and (fullIn_bool = False) then
				FifoOut_mem(WrPtrIn) := DataInIn_int(NUM_STAGES - 1);
				WrPtrOut := WrPtrNext;
			else
				WrPtrOut := WrPtrIn;
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

		variable En_wrOut_array, En_wrIn_array	: bool_del_t;
		variable En_rdOut_array, En_rdIn_array	: bool_del_t;

		variable WrPtrOut_int, WrPtrIn_int	: integer;
		variable RdPtrOut_int, RdPtrIn_int	: integer;

		variable DataOut_rtl, DataOut_ideal	: integer;
		variable DataInIn_int, DataInOut_int	: int_del_t;
		variable DataIn_int			: integer;

		variable seed1, seed2			: positive;

		variable pass				: integer;
		variable num_pass			: integer;

		file file_pointer			: text;
		variable file_line			: line;

	begin

		wait for 1 ns;

		num_pass := 0;

		file_open(file_pointer, fifo_2clk_log_file, append_mode);

		write(file_line, string'( "FIFO 2 clocks Test"));
		writeline(file_pointer, file_line);

		reset(RdPtrOut_int, emptyOut_bool, En_rdOut_array, FifoOut_mem, WrPtrOut_int, fullOut_bool, DataInOut_int, En_wrOut_array);
		write(file_line, string'( "Read reset successful"));
		writeline(file_pointer, file_line);

		write(file_line, string'( "Write reset successful"));
		writeline(file_pointer, file_line);


		for i in 0 to NUM_TEST-1 loop

			FifoIn_mem := FifoOut_mem;

			WrPtrIn_int := WrPtrOut_int;
			RdPtrIn_int := RdPtrOut_int;

			fullIn_bool := fullOut_bool;
			emptyIn_bool := emptyOut_bool;

			En_wrIn_array := En_wrOut_array;
			En_rdIn_array := En_rdOut_array;

			DataInIn_int := DataInOut_int;

			push_op(DataIn_int, En_wr_bool, En_rd_bool, seed1, seed2);

			fifo_ref(DataIn_int, En_wr_bool, En_rd_bool, DataInIn_int, DataInOut_int, DataOut_ideal, En_wrIn_array, En_rdIn_array, En_wrOut_array, En_rdOut_array, fullIn_bool, emptyIn_bool, fullOut_bool, emptyOut_bool, FifoIn_mem, FifoOut_mem, WrPtrIn_int, RdPtrIn_int, WrPtrOut_int, RdPtrOut_int);

			En_wr_bool := En_wrOut_array(NUM_STAGES - 1);
			En_rd_bool := En_rdOut_array(NUM_STAGES - 1);

			if (En_rd_bool = True) and (emptyOut_bool = False) then
				if (ValidOut_tb = '0') then
					wait on ValidOut_tb;
				else
					wait until ((clk_rd_tb'event) and (clk_rd_tb = '1'));
				end if;
			end if;

			fullRtl_bool := std_logic_to_bool(full_tb);
			emptyRtl_bool := std_logic_to_bool(empty_tb);

			DataOut_rtl := to_integer(unsigned(DataOut_tb));

			verify (DataIn_int, En_wr_bool, En_rd_bool, DataOut_ideal, DataOut_rtl, fullOut_bool, fullRtl_bool,  emptyOut_bool, emptyRtl_bool, file_pointer, pass);
			num_pass := num_pass + pass;

--			wait for WAIT_TIME;

		end loop;

		file_close(file_pointer);

		file_open(file_pointer, summary_file, append_mode);
		write(file_line, string'( "FIFO 2 CLOCKS => PASSES: " & integer'image(num_pass) & " out of " & integer'image(NUM_TEST)));
		writeline(file_pointer, file_line);

		if (num_pass = NUM_TEST) then
			write(file_line, string'( "FIFO 2 CLOCKS: TEST PASSED"));
		else
			write(file_line, string'( "FIFO 2 CLOCKS: TEST FAILED: " & integer'image(NUM_TEST-num_pass) & " failures"));
		end if;
		writeline(file_pointer, file_line);

		file_close(file_pointer);
		stop <= true;

		wait;

	end process test;

end bench;
