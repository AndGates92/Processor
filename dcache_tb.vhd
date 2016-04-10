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

	constant CLK_PERIOD	: time := 10 ns;
	constant NUM_TEST	: integer := 10000;

	signal clk_tb	: std_logic := '0';
	signal stop	: boolean := false;
	signal rst_tb	: std_logic;

	constant ADDR_MEM_L_TB	: positive := 20;
	constant DATA_L_TB	: positive := 32;
	constant INCR_PC_L_TB	: positive := 2;

	signal Hit_tb		: std_logic;
	signal EnDRst_tb	: std_logic;

	signal Start_tb		: std_logic;
	signal Done_tb		: std_logic;
	signal DataOut_tb	: std_logic_vector(DATA_L_TB - 1 downto 0);
	signal DataIn_tb	: std_logic_vector(DATA_L_TB - 1 downto 0);
	signal Read		: std_logic;
	signal Address_tb	: std_logic_vector(ADDR_MEM_L_TB - 1 downto 0);

	-- Memory access
	signal DoneMemory_tb	: std_logic;
	signal EnableMemory_tb	: std_logic;
	signal AddressMem_tb	: std_logic_vector(ADDR_MEM_L_TB - 1 downto 0);
	signal DataMemOut_tb	: std_logic_vector(DATA_L_TB - 1 downto 0);
	signal DataMemIn_tb	: std_logic_vector(DATA_L_TB - 1 downto 0;
	signal ReadMem_tb	: std_logic;

begin

	DUT: dcache generic map(
		ADDR_MEM_L => ADDR_MEM_L_TB,
		DATA_L => DATA_L_TB,
		INCR_PC_L => INCR_PC_L_TB
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

	clk_tb <= not clk_tb after CLK_PERIOD/2 when not stop;

	test: process

		procedure reset(variable DCacheOut_mem, DAddrCacheOut_mem, DValidCacheOut_mem, DDirtyCacheOut_mem : out dcache_t) is
		begin
			rst_tb <= '0';
			wait until rising_edge(clk_tb);
			rst_tb <= '1';
			Address_tb <= (others => '0');
			DataIn_tb <= (others => '0');
			Read_tb <= '0';
			DataMemOut_tb <= (others => '0');
			DoneMemory_tb <= '0';
			DCacheOut_mem := (others => 0);
			DDirtyCacheOut_mem := (others => 0);
			DAddrCacheOut_mem := (others => 0);
			DValidCacheOut_mem := (others => 0);
			Start_tb <= '0';
			wait until rising_edge(clk_tb);
			rst_tb <= '0';

			wait on EndRst_tb;

			wait until rising_edge(clk_tb);
		end procedure reset;

		procedure push_op(variable address_bram : out integer; variable address_int : out integer; variable Read_int : out integer; variable data_in_int : out integer; variable seed1, seed2 : inout positive) is
			variable address_full		: integer;
			variable address_full_vec	: std_logic_vector(ADDR_MEM_L_TB - 1 downto 0);
			variable address_bram_vec	: std_logic_vector(ADDR_BRAM_L - 1 downto 0);
			variable data_in_in		: integer;
			variable read_in		: integer;
			variable rand_val	: real;
		begin

			uniform(seed1, seed2, rand_val);
			address_full := integer(rand_val*(2.0**(real(ADDR_MEM_L_TB)) - 1.0));
			address_int := address_full;
			address_full_vec := std_logic_vector(to_unsigned(address_full, ADDR_MEM_L_TB));
			Address_tb <= std_logic_vector(to_unsigned(address_full, ADDR_MEM_L_TB));
			address_bram_vec := address_full_vec(ADDR_BRAM_L + INCR_PC_L_TB - 1 downto INCR_PC_L_TB);
			address_bram := to_integer(unsigned(address_bram_vec));

			uniform(seed1, seed2, rand_val);
			data_in_in := integer(rand_val*(2.0**(real(DATA_L_TB)) - 1.0));
			data_in_int := data_in_int;
			DataIn_tb <= std_logic_vector(to_unsigned(data_in_in, DATA_L_TB));

			uniform(seed1, seed2, rand_val);
			read_in := integer(rand_bin(rand_val));
			read_int := read_in;
			Read_tb <= int_to_std_logic(read_in);

			DoneMemory_tb <= '0';
			DataMemOut_tb <= (others => '0');

			Start_tb <= '1';

			wait until rising_edge(clk_tb);
			Start_tb <= '0';
		end procedure push_op;

		procedure dcache_ref(variable Read_int : in integer, variable address_bram, address_full : in integer; variable Hit : out integer; variable Instr_int : out integer; variable DCacheIn_mem : in dcache_t; variable DCacheOut_mem : out dcache_t; variable DDirtyCacheIn_mem : in dcache_t; variable DDirtyCacheOut_mem : out dcache_t; variable DAddrCacheIn_mem : in dcache_t; variable DAddrCacheOut_mem : out dcache_t;  variable DValidCacheIn_mem : in dcache_t; variable DValidCacheOut_mem : out dcache_t; variable seed1, seed2 : inout positive) is
			variable DirtyBit, ValidBit, AddressFullBRAM, InstrBRAM : integer;
			variable InstrMem	: integer;
			variable rand_val	: real;
		begin

			uniform(seed1, seed2, rand_val);
			DValidCacheOut_mem := DValidCacheIn_mem;
			DAddrCacheOut_mem := DAddrCacheIn_mem;
			DDirtyCacheOut_mem := DDirtyCacheOut_mem;
			DCacheOut_mem := DCacheIn_mem;

			DirtyBit := DDirtyCacheIn_mem(address_bram);
			ValidBit := DValidCacheIn_mem(address_bram);
			AddressFullBRAM := DAddrCacheIn_mem(address_bram);
			InstrBRAM := DCacheIn_mem(address_bram);

			if (Read_int = 1) then
				if (ValidBit = 1) and (AddressFullBRAM = address_full) then
					Instr_int := InstrBRAM;
					Hit := 1;
				else
					wait on EnableMemory_tb;
					InstrMem := integer(rand_val*(2.0**(real(DATA_L_TB)) - 1.0));
					Instr_int := InstrMem;
					DataMemOut_tb <= std_logic_vector(to_unsigned(InstrMem, DATA_L_TB));
					DoneMemory_tb <= '1';
					wait until rising_edge(clk_tb);
					DoneMemory_tb <= '0';
					Hit := 0;
					DCacheOut_mem(address_bram) := InstrMem;
					DAddrCacheOut_mem(address_bram) := address_full;
					DValidCacheOut_mem(address_bram) := 1;
					DDirtyCacheOut_mem(address_bram) := 0;
				end if;
			else
				if (ValidBit = 1) and (AddressFullBRAM = address_full) then
					
		end procedure dcache_ref;

		procedure verify(variable address_int, address_bram, Hit_ideal, Hit_rtl, Instr_ideal, Instr_rtl : integer; file file_pointer : text; variable pass: out integer) is
			variable file_line	: line;
		begin

			write(file_line, string'( "Instruction Cache: address requested " & integer'image(address_int) & " and accessing cache at " & integer'image(address_bram)));
			writeline(file_pointer, file_line);

			if (Hit_rtl = Hit_ideal) and (Instr_ideal = Instr_rtl) then
				write(file_line, string'("PASS Instruction " & integer'image(Instr_ideal) & " Hit " & integer'image(Hit_ideal)));
				pass := 1;
			elsif (Instr_ideal /= Instr_rtl) and (Hit_rtl = Hit_ideal) then
				write(file_line, string'("FAIL (Wrong Instruction) Ideal " & integer'image(Instr_ideal) & " and RTL " & integer'image(Instr_rtl)));
				pass := 0;
			elsif (Hit_rtl /= Hit_ideal) and (Instr_ideal = Instr_rtl) then
				write(file_line, string'("FAIL (Wrong hit) Ideal " & integer'image(Hit_ideal) & " and RTL " & integer'image(Hit_rtl)));
				pass := 0;
			else
				write(file_line, string'("FAIL (Wrong hit and instruction) Instruction => Ideal " & integer'image(Instr_ideal) & " and RTL " & integer'image(Instr_rtl) & " Hit => Ideal " & integer'image(Hit_ideal) & " and RTL " & integer'image(Hit_rtl)));
				pass := 0;
			end if;
			writeline(file_pointer, file_line);

		end procedure verify;

		variable DCacheOut_mem	: dcache_t;
		variable DCacheIn_mem	: dcache_t;

		variable DAddrCacheOut_mem	: dcache_t;
		variable DAddrCacheIn_mem	: dcache_t;

		variable DValidCacheOut_mem	: dcache_t;
		variable DValidCacheIn_mem	: dcache_t;

		variable address_bram		: integer; 
		variable address_int		: integer;

		variable Instr_rtl, Instr_ideal	: integer;
		variable Hit_rtl, Hit_ideal	: integer;

		variable seed1, seed2		: positive;

		variable pass			: integer;
		variable num_pass		: integer;

		file file_pointer		: text;
		variable file_line		: line;

	begin

		wait for 1 ns;

		num_pass := 0;

		reset(DCacheOut_mem, DAddrCacheOut_mem, DValidCacheOut_mem);

		file_open(file_pointer, log_file, append_mode);

		write(file_line, string'( "Instruction cache Test"));
		writeline(file_pointer, file_line);

		write(file_line, string'( "Reset successfull"));
		writeline(file_pointer, file_line);

		for i in 0 to NUM_TEST-1 loop

			DValidCacheIn_mem := DValidCacheOut_mem;
			DAddrCacheIn_mem := DAddrCacheOut_mem;
			DCacheIn_mem := DCacheOut_mem;

			push_op(address_bram, address_int, seed1, seed2);

			dcache_ref(address_bram, address_int, Hit_ideal, Instr_ideal, DCacheIn_mem, DCacheOut_mem, DAddrCacheIn_mem, DAddrCacheOut_mem, DValidCacheIn_mem, DValidCacheOut_mem, seed1, seed2);

			wait on Done_tb;

			Hit_rtl := std_logic_to_int(Hit_tb);

			Instr_rtl := to_integer(unsigned(DataMemOut_tb));

			verify (address_int, address_bram, Hit_ideal, Hit_rtl, Instr_ideal, Instr_rtl, file_pointer, pass);

			num_pass := num_pass + pass;

			wait until rising_edge(clk_tb);
		end loop;

		file_close(file_pointer);

		file_open(file_pointer, summary_file, append_mode);
		write(file_line, string'( "INSTRUCTION CACHE => PASSES: " & integer'image(num_pass) & " out of " & integer'image(NUM_TEST)));
		writeline(file_pointer, file_line);

		file_close(file_pointer);
		stop <= true;

	end process test;

end bench;
