library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.mem_pkg.all;

package mem_phy_init_pkg is 

	-- Timing parameter (in ns)
	constant T_INIT_STARTUP_ns	: real := 2e5;
	constant T_NOP_INIT_ns		: real := 4e2;

	-- Timing parameter (in nCK)
	constant T_INIT_STARTUP	: integer := integer(ceil(T_INIT_STARTUP_ns/(CLK_PERIOD*CLK_RATIO)));
	constant T_NOP_INIT	: integer := integer(ceil(T_NOP_INIT_ns/(CLK_PERIOD*CLK_RATIO)));
	constant T_DLL_RESET	: integer := 200;

	constant DLL_CNT_L	: integer := int_to_bit_num(T:DLL_RESET);
	constant INIT_CNT_L	: integer := int_to_bit_num(max_int(T_INIT_STARTUP, max_int(T_RFC, max_int(T_RP, max_int(T_MRD, T_NOP_INIT)))));

	constant STATE_PHY_INIT_L	: positive := 4;

	constant START_INIT		: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0) := std_logic_vector(to_unsigned(0, STATE_PHY_INIT_L));
	constant CMD_NOP_400_1		: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0) := std_logic_vector(to_unsigned(1, STATE_PHY_INIT_L));
	constant CMD_PREA_A10_0		: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0) := std_logic_vector(to_unsigned(2, STATE_PHY_INIT_L));
	constant CMD_NOP_400_2		: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0) := std_logic_vector(to_unsigned(3, STATE_PHY_INIT_L));
	constant CMD_EMSR3		: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0) := std_logic_vector(to_unsigned(4, STATE_PHY_INIT_L));
	constant CMD_EMSR2		: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0) := std_logic_vector(to_unsigned(5, STATE_PHY_INIT_L));
	constant CMD_EMRS1		: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0) := std_logic_vector(to_unsigned(6, STATE_PHY_INIT_L));
	constant CMD_MRS_A8_1		: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0) := std_logic_vector(to_unsigned(7, STATE_PHY_INIT_L));
	constant CMD_PREA		: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0) := std_logic_vector(to_unsigned(8, STATE_PHY_INIT_L));
	constant CMD_AUTO_REF_1		: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0) := std_logic_vector(to_unsigned(9, STATE_PHY_INIT_L));
	constant CMD_AUTO_REF_2		: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0) := std_logic_vector(to_unsigned(10, STATE_PHY_INIT_L));
	constant CMD_MRS_A8_0		: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0) := std_logic_vector(to_unsigned(11, STATE_PHY_INIT_L));
	constant CMD_EMSR1_A987_1	: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0) := std_logic_vector(to_unsigned(12, STATE_PHY_INIT_L));
	constant CMD_EMSR1_A987_0	: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0) := std_logic_vector(to_unsigned(13, STATE_PHY_INIT_L));
	constant INIT_COMPLETE		: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0) := std_logic_vector(to_unsigned(14, STATE_PHY_INIT_L));

end package mem_phy_init_pkg;
