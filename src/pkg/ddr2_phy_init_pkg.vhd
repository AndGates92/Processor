library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;
use work.ddr2_mrs_pkg.all;
use work.ddr2_timing_pkg.all;

package ddr2_phy_init_pkg is 

	-- Timing parameter (in ns)
	constant T_INIT_STARTUP_ns	: real := 2.0e5;
	constant T_NOP_INIT_ns		: real := 4.0e2;

	-- Timing parameter (in nCK)
	constant T_INIT_STARTUP	: positive := integer(ceil(T_INIT_STARTUP_ns/(real(DDR2_CLK_PERIOD))));
	constant T_NOP_INIT	: positive := integer(ceil(T_NOP_INIT_ns/(real(DDR2_CLK_PERIOD))));
	constant T_DLL_RESET	: positive := 200;

	constant DLL_CNT_L	: integer := int_to_bit_num(T_DLL_RESET);
	constant INIT_CNT_L	: integer := int_to_bit_num(max_int(T_INIT_STARTUP-1, max_int(T_RFC-1, max_int(T_RP-1, max_int(T_MRD-1, max_int(T_NOP_INIT-1, T_MOD_max-1))))));

	constant STATE_PHY_INIT_L	: positive := 4;

	constant START_INIT		: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0) := std_logic_vector(to_unsigned(0, STATE_PHY_INIT_L));
	constant CMD_NOP_400_1		: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0) := std_logic_vector(to_unsigned(1, STATE_PHY_INIT_L));
	constant CMD_PREA_A10_0		: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0) := std_logic_vector(to_unsigned(2, STATE_PHY_INIT_L));
	constant CMD_NOP_400_2		: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0) := std_logic_vector(to_unsigned(3, STATE_PHY_INIT_L));
	constant CMD_EMRS3		: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0) := std_logic_vector(to_unsigned(4, STATE_PHY_INIT_L));
	constant CMD_EMRS2		: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0) := std_logic_vector(to_unsigned(5, STATE_PHY_INIT_L));
	constant CMD_EMRS1		: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0) := std_logic_vector(to_unsigned(6, STATE_PHY_INIT_L));
	constant CMD_MRS_A8_1		: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0) := std_logic_vector(to_unsigned(7, STATE_PHY_INIT_L));
	constant CMD_PREA		: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0) := std_logic_vector(to_unsigned(8, STATE_PHY_INIT_L));
	constant CMD_AUTO_REF_1		: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0) := std_logic_vector(to_unsigned(9, STATE_PHY_INIT_L));
	constant CMD_AUTO_REF_2		: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0) := std_logic_vector(to_unsigned(10, STATE_PHY_INIT_L));
	constant CMD_MRS_A8_0		: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0) := std_logic_vector(to_unsigned(11, STATE_PHY_INIT_L));
	constant CMD_EMRS1_A987_1	: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0) := std_logic_vector(to_unsigned(12, STATE_PHY_INIT_L));
	constant CMD_EMRS1_A987_0	: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0) := std_logic_vector(to_unsigned(13, STATE_PHY_INIT_L));
	constant APPLY_SETTING		: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0) := std_logic_vector(to_unsigned(14, STATE_PHY_INIT_L));
	constant INIT_COMPLETE		: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0) := std_logic_vector(to_unsigned(15, STATE_PHY_INIT_L));

	component ddr2_phy_init 
	generic (
		BANK_L		: positive := 3;
		ADDR_MEM_L	: positive := 13
	);
	port (

		rst		: in std_logic;
		clk		: in std_logic;

		-- Memory access
		AddressMem		: out std_logic_vector(ADDR_MEM_L - 1 downto 0);
		BankSelMem		: out std_logic_vector(BANK_L - 1 downto 0);
		nChipSelect		: out std_logic;
		ReadEnable		: out std_logic;
		nColAccessStrobe	: out std_logic;
		nRowAccessStrobe	: out std_logic;
		ClkEnable		: out std_logic;
		OnDieTermination	: out std_logic;

		-- Memory interface
		InitializationCompleted	: out std_logic

	);
	end component;

end package ddr2_phy_init_pkg;
