library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;
use work.dcache_pkg.all;
use work.proc_pkg.all;
use work.tb_pkg.all;

entity dcache_tb is
end entity dcache_tb;

architecture bench of dcache_tb is

	constant CLK_PERIOD	: time := PROC_CLK_PERIOD * 1 ns;
	constant NUM_TEST	: integer := 10000;

	signal clk_tb	: std_logic := '0';
	signal stop	: boolean := false;
	signal rst_tb	: std_logic;

--	constant ADDR_MEM_L_TB	: positive := 20;
	constant ADDR_MEM_L_TB	: positive := int_to_bit_num(PROGRAM_MEMORY)+INCR_PC_L;

	signal Hit_tb		: std_logic;
	signal EnDRst_tb	: std_logic;

	signal Start_tb		: std_logic;
	signal Done_tb		: std_logic;
	signal DataOut_tb	: std_logic_vector(DATA_L - 1 downto 0);
	signal DataIn_tb	: std_logic_vector(DATA_L - 1 downto 0);
	signal Read_tb		: std_logic;
	signal Address_tb	: std_logic_vector(ADDR_MEM_L_TB - 1 downto 0);

	-- Memory access
	signal DoneMemory_tb	: std_logic;
	signal EnableMemory_tb	: std_logic;
	signal AddressMem_tb	: std_logic_vector(ADDR_MEM_L_TB - 1 downto 0);
	signal DataMemOut_tb	: std_logic_vector(DATA_L - 1 downto 0);
	signal DataMemIn_tb	: std_logic_vector(DATA_L - 1 downto 0);
	signal ReadMem_tb	: std_logic;

	type dcache_t is array (DCACHE_LINE - 1 downto 0) of integer;

begin

	DUT: dcache generic map(
		ADDR_MEM_L => ADDR_MEM_L_TB
	)
	port map (
		rst => rst_tb,
		clk => clk_tb,

		Hit => Hit_tb,
		EndRst => EndRst_tb,

		Start => Start_tb,
		Done => Done_tb,
		Read => Read_tb,
		Address => Address_tb,
		DataOut => DataOut_tb,
		DataIn => DataIn_tb,

		-- Memory access
		DoneMemory => DoneMemory_tb,
		EnableMemory => EnableMemory_tb,
		AddressMem => AddressMem_tb,
		DataMemIn => DataMemIn_tb,
		ReadMem => ReadMem_tb,
		DataMemOut => DataMemOut_tb
	);

	clk_gen(CLK_PERIOD, 0 ns, stop, clk_tb);

	test: process

		procedure reset(variable DCacheOut_mem, DAddrCacheOut_mem, DValidCacheOut_mem, DDirtyCacheOut_mem : out dcache_t) is
		begin
			rst_tb <= '0';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_tb <= '1';
			Address_tb <= (others => '0');
			DataIn_tb <= (others => '0');
			Read_tb <= '0';
			ReadMem_tb <= '0';
			DataMemOut_tb <= (others => '0');
			DoneMemory_tb <= '0';
			DCacheOut_mem := (others => 0);
			DDirtyCacheOut_mem := (others => 0);
			DAddrCacheOut_mem := (others => 0);
			DValidCacheOut_mem := (others => 0);
			Start_tb <= '0';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_tb <= '0';

			wait on EndRst_tb;

			wait until ((clk_tb'event) and (clk_tb = '1'));
		end procedure reset;

		procedure push_op(variable address_bram : out integer; variable address_int : out integer; variable read_bool : out boolean; variable data_in_int : out integer; variable seed1, seed2 : inout positive) is
			variable address_full		: integer;
			variable address_full_vec	: std_logic_vector(ADDR_MEM_L_TB - 1 downto 0);
			variable address_bram_vec	: std_logic_vector(ADDR_BRAM_L - 1 downto 0);
			variable data_in_in		: integer;
			variable read_in		: boolean;
			variable rand_val	: real;
		begin

			uniform(seed1, seed2, rand_val);
			address_full := integer(rand_val*(2.0**(real(ADDR_MEM_L_TB)) - 1.0));
			address_full_vec := std_logic_vector(to_unsigned(address_full, ADDR_MEM_L_TB));
			Address_tb <= std_logic_vector(to_unsigned(address_full, ADDR_MEM_L_TB));
			address_int := to_integer(unsigned(address_full_vec(int_to_bit_num(DATA_MEMORY) - 1 downto 0)));
			address_bram_vec := address_full_vec(ADDR_BRAM_L + INCR_PC_L - 1 downto INCR_PC_L);
			address_bram := to_integer(unsigned(address_bram_vec));

			uniform(seed1, seed2, rand_val);
			data_in_in := integer(rand_val*(2.0**(real(DATA_L)) - 1.0));
			data_in_int := data_in_in;
			DataIn_tb <= std_logic_vector(to_unsigned(data_in_in, DATA_L));

			uniform(seed1, seed2, rand_val);
			read_in := rand_bool(rand_val);
			read_bool := read_in;
			Read_tb <= bool_to_std_logic(read_in);

			ReadMem_tb <= '0';
			DoneMemory_tb <= '0';
			DataMemOut_tb <= (others => '0');

			Start_tb <= '1';

			wait until ((clk_tb'event) and (clk_tb = '1'));
			Start_tb <= '0';
		end procedure push_op;

		procedure dcache_ref(variable read_bool : in boolean; variable DataIn_int : in integer; variable address_bram, address_full : in integer; variable Hit : out boolean; variable Data_int : out integer; variable DCacheIn_mem : in dcache_t; variable DCacheOut_mem : out dcache_t; variable DDirtyCacheIn_mem : in dcache_t; variable DDirtyCacheOut_mem : out dcache_t; variable DAddrCacheIn_mem : in dcache_t; variable DAddrCacheOut_mem : out dcache_t;  variable DValidCacheIn_mem : in dcache_t; variable DValidCacheOut_mem : out dcache_t; variable seed1, seed2 : inout positive) is
			variable DirtyBit, ValidBit, AddressFullBRAM, DataBRAM : integer;
			variable DataMem	: integer;
			variable rand_val	: real;
		begin

			uniform(seed1, seed2, rand_val);
			DValidCacheOut_mem := DValidCacheIn_mem;
			DAddrCacheOut_mem := DAddrCacheIn_mem;
			DDirtyCacheOut_mem := DDirtyCacheIn_mem;
			DCacheOut_mem := DCacheIn_mem;

			DirtyBit := DDirtyCacheIn_mem(address_bram);
			ValidBit := DValidCacheIn_mem(address_bram);
			AddressFullBRAM := DAddrCacheIn_mem(address_bram);
			DataBRAM := DCacheIn_mem(address_bram);

			if (ValidBit = 1) and (AddressFullBRAM = address_full) then
				Hit := True;
			else
				Hit := False;
			end if;

			if (read_bool = True) then
				if (ValidBit = 1) and (AddressFullBRAM = address_full) then
					Data_int := DataBRAM;
				else
					wait on EnableMemory_tb;
					DataMem := integer(rand_val*(2.0**(real(DATA_L)) - 1.0));
					Data_int := DataMem;
					DataMemOut_tb <= std_logic_vector(to_unsigned(DataMem, DATA_L));
					DoneMemory_tb <= '1';
					wait until ((clk_tb'event) and (clk_tb = '1'));
					DoneMemory_tb <= '0';
					DCacheOut_mem(address_bram) := DataMem;
					DAddrCacheOut_mem(address_bram) := address_full;
					DValidCacheOut_mem(address_bram) := 1;
					DDirtyCacheOut_mem(address_bram) := 0;
				end if;
			else
				Data_int := 0;
				DDirtyCacheOut_mem(address_bram) := 1;
				DValidCacheOut_mem(address_bram) := 1;
				DAddrCacheOut_mem(address_bram) := address_full;
				DCacheOut_mem(address_bram) := DataIn_int;
				if (AddressFullBRAM /= address_full) or ((AddressFullBRAM = address_full) and (DirtyBit = 1)) then
					wait on EnableMemory_tb;
					DataMemOut_tb <= std_logic_vector(to_unsigned(0, DATA_L));
					DoneMemory_tb <= '1';
					wait until ((clk_tb'event) and (clk_tb = '1'));
					DoneMemory_tb <= '0';
				end if;

			end if;
		end procedure dcache_ref;

		procedure verify(variable Hit_ideal, Hit_rtl, read_bool : in boolean; variable address_int, address_bram, Data_ideal, Data_rtl : integer; file file_pointer : text; variable pass: out integer) is
			variable file_line	: line;
		begin

			write(file_line, string'( "Data Cache: address requested " & integer'image(address_int) & " and accessing cache at " & integer'image(address_bram) & " Read Operation " & bool_to_str(read_bool)));
			writeline(file_pointer, file_line);

			if (Hit_rtl = Hit_ideal) and (Data_ideal = Data_rtl) then
				write(file_line, string'("PASS Data " & integer'image(Data_ideal) & " Hit " & bool_to_str(Hit_ideal)));
				pass := 1;
			elsif (Data_ideal /= Data_rtl) and (Hit_rtl = Hit_ideal) then
				write(file_line, string'("FAIL (Wrong Data) Ideal " & integer'image(Data_ideal) & " and RTL " & integer'image(Data_rtl)));
				pass := 0;
			elsif (Hit_rtl /= Hit_ideal) and (Data_ideal = Data_rtl) then
				write(file_line, string'("FAIL (Wrong hit) Ideal " & bool_to_str(Hit_ideal) & " and RTL " & bool_to_str(Hit_rtl)));
				pass := 0;
			else
				write(file_line, string'("FAIL (Wrong hit and data) Data => Ideal " & integer'image(Data_ideal) & " and RTL " & integer'image(Data_rtl) & " Hit => Ideal " & bool_to_str(Hit_ideal) & " and RTL " & bool_to_str(Hit_rtl)));
				pass := 0;
			end if;
			writeline(file_pointer, file_line);

		end procedure verify;

		variable DCacheOut_mem	: dcache_t;
		variable DCacheIn_mem	: dcache_t;

		variable DDirtyCacheOut_mem	: dcache_t;
		variable DDirtyCacheIn_mem	: dcache_t;

		variable DAddrCacheOut_mem	: dcache_t;
		variable DAddrCacheIn_mem	: dcache_t;

		variable DValidCacheOut_mem	: dcache_t;
		variable DValidCacheIn_mem	: dcache_t;

		variable address_bram		: integer; 
		variable address_int		: integer;

		variable Data_rtl, Data_ideal	: integer;
		variable Hit_rtl, Hit_ideal	: boolean;

		variable seed1, seed2		: positive;

		variable pass			: integer;
		variable num_pass		: integer;

		variable read_int		: boolean;
		variable DataIn_int		: integer;

		file file_pointer		: text;
		variable file_line		: line;

	begin

		wait for 1 ns;

		num_pass := 0;

		reset(DCacheOut_mem, DAddrCacheOut_mem, DValidCacheOut_mem, DDirtyCacheOut_mem);

		file_open(file_pointer, log_file, append_mode);

		write(file_line, string'( "Data cache Test"));
		writeline(file_pointer, file_line);

		write(file_line, string'( "Reset successful"));
		writeline(file_pointer, file_line);

		for i in 0 to NUM_TEST-1 loop

			DValidCacheIn_mem := DValidCacheOut_mem;
			DAddrCacheIn_mem := DAddrCacheOut_mem;
			DDirtyCacheIn_mem := DDirtyCacheOut_mem;
			DCacheIn_mem := DCacheOut_mem;

			push_op(address_bram, address_int, read_int, DataIn_int, seed1, seed2);

			dcache_ref(read_int, DataIn_int, address_bram, address_int, Hit_ideal, Data_ideal, DCacheIn_mem, DCacheOut_mem, DDirtyCacheIn_mem, DDirtyCacheOut_mem, DAddrCacheIn_mem, DAddrCacheOut_mem, DValidCacheIn_mem, DValidCacheOut_mem, seed1, seed2);

			wait on Done_tb;

			Hit_rtl := std_logic_to_bool(Hit_tb);

			Data_rtl := to_integer(unsigned(DataOut_tb));

			verify (Hit_ideal, Hit_rtl, read_int, address_int, address_bram, Data_ideal, Data_rtl, file_pointer, pass);

			num_pass := num_pass + pass;

			wait until ((clk_tb'event) and (clk_tb = '1'));
		end loop;

		file_close(file_pointer);

		file_open(file_pointer, summary_file, append_mode);
		write(file_line, string'( "DATA CACHE => PASSES: " & integer'image(num_pass) & " out of " & integer'image(NUM_TEST)));
		writeline(file_pointer, file_line);

		if (num_pass = NUM_TEST) then
			write(file_line, string'( "DATA CACHE: TEST PASSED"));
		else
			write(file_line, string'( "DATA CACHE: TEST FAILED: " & integer'image(NUM_TEST-num_pass) & " failures"));
		end if;
		writeline(file_pointer, file_line);

		file_close(file_pointer);
		stop <= true;

	end process test;

end bench;
