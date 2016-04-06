library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;
use work.icache_pkg.all;
use work.proc_pkg.all;
use work.tb_pkg.all;

entity icache_tb is
end entity icache_tb;

architecture bench of decode_stage_tb is

	constant CLK_PERIOD	: time := 10 ns;
	constant NUM_TEST	: integer := 10000;

	signal clk_tb	: std_logic := '0';
	signal stop	: boolean := false;
	signal rst_tb	: std_logic;

	constant ADDR_MEM_L_TB	: positive := 32;

	signal Hit_tb	: std_logic;
	signal EndRst_tb	: std_logic;

	signal Start_tb		: std_logic;
	signal Done_tb		: std_logic;
	signal Instr_tb		: std_logic_vector(INSTR_L - 1 downto 0);
	signal Address_tb	: std_logic_vector(ADDR_MEM_L - 1 downto 0);

	-- Memory access
	signal DoneMemory_tb	: std_logic;
	signal EnableMemory_tb	: std_logic;
	signal AddressMem_tb	: std_logic_vector(ADDR_MEM_L - 1 downto 0);
	signal InstrOut_tb	: std_logic_vector(INSTR_L - 1 downto 0);

	type icache_t is array (CACHE_LINE - 1 downto 0) of integer;

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
		EnableMemory => EnavleMemory_tb,
		AddressMem => AddressMem_tb,
		InstrOut => InstrOut_tb
	);

	clk_tb <= not clk_tb after CLK_PERIOD/2 when not stop;

	test: process

		procedure reset(variable ICacheOut_mem : out icache_t) is
		begin
			rst_tb <= '0';
			wait until rising_edge(clk_tb);
			rst_tb <= '1';
			Address_tb <= (others => '0');
			InstrOut_tb <= (others => '0');
			DoneMemory_tb <= '0';
			Start_tb <= '0';
			wait until rising_edge(clk_tb);
			rst_tb <= '0';
			wait on EndRst_tb;
		end procedure reset;

		procedure push_op(variable address_bram : out integer; variable seed1, seed2 : inout positive) is
			variable address_full		: integer;
			variable address_full_vec	: std_logic_vector(ADDR_MEM_L_TB - 1 downto 0);
			variable address_bram_vec	: std_logic_vector(ADDR_BRAM_L - 1 downto 0);
		begin

			address_full := integer(2.0**(real(ADDR_MEM_L_TB)) - 1.0);
			address_full_vec := std_logic_vector(to_unsigned(address_full, ADDR_MEM_L_TB));
			Address_tb <= address_full_vec(ADDR_BRAM_L - 1 downto 0);
			address_bram_vec := address_full_vec(ADDR_BRAM_L - 1 downto 0);
			address_bram := to_integer(unsigned(address_bram_vec));

			Start_tb <= '1';

			wait until rising_edge(clk_tb);
			Start_tb <= '0';
		end procedure push_op;

		procedure icache_ref(variable address : in integer; variable Hit : out integer; variable Instr_int : out integer; variable ICacheIn_mem :in icahce_t; variable ICacheOut_mem : out icache_t;  variable seed1, seed2 : inout positive) is
		begin
			

		end procedure icache_ref;

		procedure verify() is
		begin


		end procedure verify;

	begin



	end process test;
end bench;
