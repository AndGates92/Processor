library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

package ddr2_mrs_pkg is 

	-- ODT parameter
	constant ODT_DISABLED	: std_logic_vector(1 downto 0) := std_logic_vector(to_unsigned(0, 2));
	constant ODT_75OHM	: std_logic_vector(1 downto 0) := std_logic_vector(to_unsigned(1, 2));
	constant ODT_150OHM	: std_logic_vector(1 downto 0) := std_logic_vector(to_unsigned(2, 2));
	constant ODT_50OHM	: std_logic_vector(1 downto 0) := std_logic_vector(to_unsigned(3, 2));

	-- nDQS enable
	constant nDQS_ENABLE	: std_logic := '0';
	constant nDQS_DISABLE	: std_logic := '1';

	-- RDQS enable
	constant RDQS_DISABLE	: std_logic := '0';
	constant RDQS_ENABLE	: std_logic := '1';

	-- MSR mode
	constant MSR		: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(0, 3));
	constant EMSR1		: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(1, 3));
	constant EMSR2		: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(2, 3));
	constant EMSR3		: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(3, 3));

	-- High temp refresh enable
	constant HITEMP_REF_DISABLE	: std_logic := '0';
	constant HITEMP_REF_ENABLE	: std_logic := '1';

	-- Write recovery
	constant WRITE_REC_400_2	: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(2, 3));
	constant WRITE_REC_400_3	: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(3, 3));
	constant WRITE_REC_533		: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(4, 3));
	constant WRITE_REC_667		: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(5, 3));
	constant WRITE_REC_800		: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(6, 3));
	constant WRITE_REC		: std_logic_vector(2 downto 0) := WRITE_REC_800;

	-- CAS latency
	constant CAS3		: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(3, 3));
	constant CAS4		: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(4, 3));
	constant CAS5		: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(5, 3));
	constant CAS6		: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(6, 3));

	-- Burst type
	constant SEQ_BURST	: std_logic := '0';
	constant INTL_BURST	: std_logic := '1';

	-- Burst length
	constant BL4		: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(2, 3));
	constant BL8		: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(3, 3));

	-- Power down exit
	constant FAST_POWER_DOWN_EXIT	: std_logic := '0';
	constant SLOW_POWER_DOWN_EXIT	: std_logic := '1';

	-- Additive latency
	constant AL0		: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(0, 3));
	constant AL1		: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(1, 3));
	constant AL2		: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(2, 3));
	constant AL3		: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(3, 3));
	constant AL4		: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(4, 3));
	constant AL5		: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(5, 3));

	-- Output buffer
	constant OUT_BUF_DISABLE	: std_logic := '0';
	constant OUT_BUF_ENABLE		: std_logic := '1';

	-- DLL
	constant nDLL_ENABLE	: std_logic := '0';
	constant nDLL_DISABLE	: std_logic := '1';

	-- Driving strength
	constant NORMAL			: std_logic := '0';
	constant WEAK			: std_logic := '1';

	-- Derived parameters
	constant READ_LATENCY	: positive := to_integer(unsigned(CAS)) + to_integer(unsigned(AL));
	constant WRITE_LATENCY	: positive := READ_LATENCY - 1;

end package ddr2_mrs_pkg;
