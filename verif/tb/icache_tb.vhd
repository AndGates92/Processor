library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;
use work.icache_pkg.all;
use work.proc_pkg.all;
use work.type_conversion_pkg.all;
use work.tb_pkg.all;

entity icache_tb is
end entity icache_tb;

architecture bench of icache_tb is

	constant CLK_PERIOD	: time := PROC_CLK_PERIOD * 1 ns;
	constant NUM_TEST	: integer := 10000;

	signal clk_tb	: std_logic := '0';
	signal stop	: boolean := false;
	signal rst_tb	: std_logic;

--	constant ADDR_MEM_L_TB	: positive := 20;
	constant ADDR_MEM_L_TB	: positive := int_to_bit_num(PROGRAM_MEMORY)+INCR_PC_L;

	signal Hit_tb	: std_logic;
	signal EnDRst_tb	: std_logic;

	signal Start_tb		: std_logic;
	signal Done_tb		: std_logic;
	signal Instr_tb		: std_logic_vector(INSTR_L - 1 downto 0);
	signal Address_tb	: std_logic_vector(ADDR_MEM_L_TB - 1 downto 0);

	-- Memory access
	signal DoneMemory_tb	: std_logic;
	signal EnableMemory_tb	: std_logic;
	signal AddressMem_tb	: std_logic_vector(ADDR_MEM_L_TB - 1 downto 0);
	signal InstrMemOut_tb	: std_logic_vector(INSTR_L - 1 downto 0);

	type icache_t is array (ICACHE_LINE - 1 downto 0) of integer;

begin

	DUT: icache generic map(
		ADDR_MEM_L => ADDR_MEM_L_TB
	)
	port map (
		rst => rst_tb,
		clk => clk_tb,

		Hit => Hit_tb,
		EndRst => EndRst_tb,

		Start => Start_tb,
		Done => Done_tb,
		Instr => Instr_tb,
		Address => Address_tb,

		DoneMemory => DoneMemory_tb,
		EnableMemory => EnableMemory_tb,
		AddressMem => AddressMem_tb,
		InstrMemOut => InstrMemOut_tb
	);

	clk_gen(CLK_PERIOD, 0 ns, stop, clk_tb);

	test: process

		procedure reset(variable ICacheOut_mem, IAddrCacheOut_mem, IValidCacheOut_mem : out icache_t) is
		begin
			rst_tb <= '0';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_tb <= '1';
			Address_tb <= (others => '0');
			InstrMemOut_tb <= (others => '0');
			DoneMemory_tb <= '0';
			ICacheOut_mem := (others => 0);
			IAddrCacheOut_mem := (others => 0);
			IValidCacheOut_mem := (others => 0);
			Start_tb <= '0';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_tb <= '0';

			wait on EndRst_tb;

			wait until ((clk_tb'event) and (clk_tb = '1'));
		end procedure reset;

		procedure push_op(variable address_bram : out integer; variable address_int : out integer; variable seed1, seed2 : inout positive) is
			variable address_full		: integer;
			variable address_full_vec	: std_logic_vector(ADDR_MEM_L_TB - 1 downto 0);
			variable address_bram_vec	: std_logic_vector(ADDR_BRAM_L - 1 downto 0);
			variable rand_val	: real;
		begin

			uniform(seed1, seed2, rand_val);
			address_full := integer(rand_val*(2.0**(real(ADDR_MEM_L_TB)) - 1.0));
			address_full_vec := std_logic_vector(to_unsigned(address_full, ADDR_MEM_L_TB));
			Address_tb <= std_logic_vector(to_unsigned(address_full, ADDR_MEM_L_TB));
			address_int := to_integer(unsigned(address_full_vec(int_to_bit_num(PROGRAM_MEMORY) - 1 downto 0)));
			address_bram_vec := address_full_vec(ADDR_BRAM_L + INCR_PC_L - 1 downto INCR_PC_L);
			address_bram := to_integer(unsigned(address_bram_vec));

			DoneMemory_tb <= '0';
			InstrMemOut_tb <= (others => '0');

			Start_tb <= '1';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			Start_tb <= '0';
		end procedure push_op;

		procedure icache_ref(variable address_bram, address_full : in integer; variable Hit : out boolean; variable Instr_int : out integer; variable ICacheIn_mem : in icache_t; variable ICacheOut_mem : out icache_t; variable IAddrCacheIn_mem : in icache_t; variable IAddrCacheOut_mem : out icache_t;  variable IValidCacheIn_mem : in icache_t; variable IValidCacheOut_mem : out icache_t; variable seed1, seed2 : inout positive) is
			variable ValidBit, AddressFullBRAM, InstrBRAM : integer;
			variable InstrMem	: integer;
			variable rand_val	: real;
		begin

			uniform(seed1, seed2, rand_val);
			IValidCacheOut_mem := IValidCacheIn_mem;
			IAddrCacheOut_mem := IAddrCacheIn_mem;
			ICacheOut_mem := ICacheIn_mem;

			ValidBit := IValidCacheIn_mem(address_bram);
			AddressFullBRAM := IAddrCacheIn_mem(address_bram);
			InstrBRAM := ICacheIn_mem(address_bram);

			if (ValidBit = 1) and (AddressFullBRAM = address_full) then
				Instr_int := InstrBRAM;
				Hit := True;
			else
				wait on EnableMemory_tb;
				InstrMem := integer(rand_val*(2.0**(real(INSTR_L)) - 1.0));
				Instr_int := InstrMem;
				InstrMemOut_tb <= std_logic_vector(to_unsigned(InstrMem, INSTR_L));
				DoneMemory_tb <= '1';
				wait until ((clk_tb'event) and (clk_tb = '1'));
				DoneMemory_tb <= '0';
				Hit := False;
				ICacheOut_mem(address_bram) := InstrMem;
				IAddrCacheOut_mem(address_bram) := address_full;
				IValidCacheOut_mem(address_bram) := 1;
			end if;
		end procedure icache_ref;

		procedure verify(variable Hit_ideal, Hit_rtl : boolean; variable address_int, address_bram, Instr_ideal, Instr_rtl : integer; file file_pointer : text; variable pass: out integer) is
			variable file_line	: line;
		begin

			write(file_line, string'( "Instruction Cache: address requested " & integer'image(address_int) & " and accessing cache at " & integer'image(address_bram)));
			writeline(file_pointer, file_line);

			if (Hit_rtl = Hit_ideal) and (Instr_ideal = Instr_rtl) then
				write(file_line, string'("PASS Instruction " & integer'image(Instr_ideal) & " Hit " & bool_to_str(Hit_ideal)));
				pass := 1;
			elsif (Instr_ideal /= Instr_rtl) and (Hit_rtl = Hit_ideal) then
				write(file_line, string'("FAIL (Wrong Instruction) Ideal " & integer'image(Instr_ideal) & " and RTL " & integer'image(Instr_rtl)));
				pass := 0;
			elsif (Hit_rtl /= Hit_ideal) and (Instr_ideal = Instr_rtl) then
				write(file_line, string'("FAIL (Wrong hit) Ideal " & bool_to_str(Hit_ideal) & " and RTL " & bool_to_str(Hit_rtl)));
				pass := 0;
			else
				write(file_line, string'("FAIL (Wrong hit and instruction) Instruction => Ideal " & integer'image(Instr_ideal) & " and RTL " & integer'image(Instr_rtl) & " Hit => Ideal " & bool_to_str(Hit_ideal) & " and RTL " & bool_to_str(Hit_rtl)));
				pass := 0;
			end if;
			writeline(file_pointer, file_line);

		end procedure verify;

		variable ICacheOut_mem	: icache_t;
		variable ICacheIn_mem	: icache_t;

		variable IAddrCacheOut_mem	: icache_t;
		variable IAddrCacheIn_mem	: icache_t;

		variable IValidCacheOut_mem	: icache_t;
		variable IValidCacheIn_mem	: icache_t;

		variable address_bram		: integer; 
		variable address_int		: integer;

		variable Instr_rtl, Instr_ideal	: integer;
		variable Hit_rtl, Hit_ideal	: boolean;

		variable seed1, seed2		: positive;

		variable pass			: integer;
		variable num_pass		: integer;

		file file_pointer		: text;
		variable file_line		: line;

	begin

		wait for 1 ns;

		num_pass := 0;

		reset(ICacheOut_mem, IAddrCacheOut_mem, IValidCacheOut_mem);

		file_open(file_pointer, icache_log_file, append_mode);

		write(file_line, string'( "Instruction cache Test"));
		writeline(file_pointer, file_line);

		write(file_line, string'( "Reset successfull"));
		writeline(file_pointer, file_line);

		for i in 0 to NUM_TEST-1 loop

			IValidCacheIn_mem := IValidCacheOut_mem;
			IAddrCacheIn_mem := IAddrCacheOut_mem;
			ICacheIn_mem := ICacheOut_mem;

			push_op(address_bram, address_int, seed1, seed2);

			icache_ref(address_bram, address_int, Hit_ideal, Instr_ideal, ICacheIn_mem, ICacheOut_mem, IAddrCacheIn_mem, IAddrCacheOut_mem, IValidCacheIn_mem, IValidCacheOut_mem, seed1, seed2);

			wait on Done_tb;

			Hit_rtl := std_logic_to_bool(Hit_tb);

			Instr_rtl := to_integer(unsigned(Instr_tb));

			verify (Hit_ideal, Hit_rtl, address_int, address_bram, Instr_ideal, Instr_rtl, file_pointer, pass);

			num_pass := num_pass + pass;

			wait until ((clk_tb'event) and (clk_tb = '1'));
		end loop;

		file_close(file_pointer);

		file_open(file_pointer, summary_file, append_mode);
		write(file_line, string'( "INSTRUCTION CACHE => PASSES: " & integer'image(num_pass) & " out of " & integer'image(NUM_TEST)));
		writeline(file_pointer, file_line);

		if (num_pass = NUM_TEST) then
			write(file_line, string'( "INSTRUCTION CACHE: TEST PASSED"));
		else
			write(file_line, string'( "INSTRUCTION CACHE: TEST FAILED: " & integer'image(NUM_TEST-num_pass) & " failures"));
		end if;
		writeline(file_pointer, file_line);

		file_close(file_pointer);
		stop <= true;

		wait;

	end process test;

end bench;
