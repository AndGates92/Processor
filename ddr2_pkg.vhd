library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;

package mem_pkg is 

	constant CLK_RATIO	: positive := 4;

	constant BANK_NUM	: positive := 8;
	constant BANK_L		: positive := positive(int_to_bit_num(BANK_NUM));

	constant COL_L		: positive := 10;
	constant ROW_L		: positive := 13;

	constant ADDR_MEM_L	: positive := 13;
	constant ADDR_L		: positive := ROW_L + COL_L + BANK_L;

	constant DATA_L		: positive := 16;

	-- Timing parameter (in ns)
	constant T_RCD_ns		: real := 12.5;
	constant T_RP_ns		: real := 12.5;
	constant T_RC_ns		: real := 57.5;
	constant T_RAP_ns		: real := T_RCD_ns;
	constant T_RAS_ns_min		: real := 45;
	constant T_RAS_ns_max		: real := 7e4;
	constant T_RRD_ns		: real := 10;
	constant T_FAW_ns		: real := 45;
	constant T_WR_ns		: real := 15;
	constant T_RFC_ns		: real := 127.5;
	constant T_XSNR_ns		: real := T_RFC_ns + 10;
	constant T_MOD_ns_min		: real := 0;
	constant T_MOD_ns_max		: real := 12;
	constant T_REFI_ns_lowT		: real := 7.8e3;
	constant T_REFI_ns_highT	: real := 3.9e3;

	-- Timing parameter (in nCK)
	constant T_MRD		: positive := 2;
	constant T_CCD		: positive := 2;
	constant T_XSRD		: positive := 200;
	constant T_XP		: positive := 2;
	constant T_XARD		: positive := 2;
	constant T_XARDS_max	: positive := 8;
	constant T_AOFD		: positive := integer(ceil(2.5));
	constant T_RCD		: integer := integer(ceil(T_RCD_ns/(CLK_PERIOD*CLK_RATIO)));
	constant T_RP		: integer := integer(ceil(T_RP_ns/(CLK_PERIOD*CLK_RATIO)));
	constant T_RC		: integer := integer(ceil(T_RC_ns/(CLK_PERIOD*CLK_RATIO)));
	constant T_RAP		: integer := integer(ceil(T_RAP_ns/(CLK_PERIOD*CLK_RATIO)));
	constant T_RAS_min	: integer := integer(ceil(T_RAS_ns_min/(CLK_PERIOD*CLK_RATIO)));
	constant T_RAS_max	: integer := integer(ceil(T_RAS_ns_max/(CLK_PERIOD*CLK_RATIO)));
	constant T_RRD		: integer := integer(ceil(T_RRD_ns/(CLK_PERIOD*CLK_RATIO)));
	constant T_FAW		: integer := integer(ceil(T_FAW_ns/(CLK_PERIOD*CLK_RATIO)));
	constant T_WR		: integer := integer(ceil(T_WR_ns/(CLK_PERIOD*CLK_RATIO)));
	constant T_RFC		: integer := integer(ceil(T_RFC_ns/(CLK_PERIOD*CLK_RATIO)));
	constant T_XSNR		: integer := integer(ceil(T_XSNR_ns/(CLK_PERIOD*CLK_RATIO)));
	constant T_MOD_min	: integer := integer(ceil(T_MOD_ns_min/(CLK_PERIOD*CLK_RATIO)));
	constant T_MOD_max	: integer := integer(ceil(T_MOD_ns_max/(CLK_PERIOD*CLK_RATIO)));
	constant T_REFI_lowT	: integer := integer(ceil(T_REFI_ns_lowT/(CLK_PERIOD*CLK_RATIO)));
	constant T_REFI_highT	: integer := integer(ceil(T_REFI_ns_highT/(CLK_PERIOD*CLK_RATIO)));

	-- ODT parameter
	constant DISABLED	: std_logic_vector(1 downto 0) := std_logic_vector(to_unsigned(0, 2));
	constant 75OHM		: std_logic_vector(1 downto 0) := std_logic_vector(to_unsigned(1, 2));
	constant 150OHM		: std_logic_vector(1 downto 0) := std_logic_vector(to_unsigned(2, 2));
	constant 50OMH		: std_logic_vector(1 downto 0) := std_logic_vector(to_unsigned(3, 2));
	constant ODT		: std_logic_vector(1 downto 0) := 50OHM;

	-- nDQS enable
	constant nDQS_ENABLE	: std_logic := '0';
	constant nDQS_DISABLE	: std_logic := '1';
	constant nDQS		: std_logic := nDQS_ENABLE;

	-- RDQS enable
	constant RDQS_DISABLE	: std_logic := '0';
	constant RDQS_ENABLE	: std_logic := '1';
	constant RDQS		: std_logic := RDQS_ENABLE;

	-- MSR mode
	constant MSR		: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(0, 3));
	constant EMSR1		: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(1, 3));
	constant EMSR2		: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(2, 3));
	constant EMSR3		: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(3, 3));

	-- High temp refresh enable
	constant HITEMP_REF_DISABLE	: std_logic := '0';
	constant HITEMP_REF_ENABLE	: std_logic := '1';
	constant HITEMP_REF		: std_logic := HITEMP_REF_ENABLE;

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
	constant CAS		: std_logic_vector(2 downto 0) := CAS5;

	-- Burst type
	constant SEQ_BURST	: std_logic := '0';
	constant INTL_BURST	: std_logic := '1';
	constant BURST_TYPE		: std_logic := SEQ_BURST;

	-- Burst length
	constant BL4		: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(2, 3));
	constant BL8		: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(3, 3));
	constant BURST_LENGTH	: std_logic_vector(2 downto 0) := BL4;

	-- Power down exit
	constant FAST_POWER_DOWN_EXIT	: std_logic := '0';
	constant SLOW_POWER_DOWN_EXIT	: std_logic := '1';
	constant POWER_DOWN_EXIT	: std_logic := SLOW_POWER_DOWN_EXIT;

	-- Additive latency
	constant AL0		: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(0, 3));
	constant AL1		: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(1, 3));
	constant AL2		: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(2, 3));
	constant AL3		: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(3, 3));
	constant AL4		: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(4, 3));
	constant AL5		: std_logic_vector(2 downto 0) := std_logic_vector(to_unsigned(5, 3));
	constant AL		: std_logic_vector(2 downto 0) := AL5;

	-- Output buffer
	constant OUT_BUF_DISABLE	: std_logic := '0';
	constant OUT_BUF_ENABLE		: std_logic := '1';
	constant OUT_BUFFER		: std_logic := OUT_BUF_ENABLE;

	-- DLL
	constant nDLL_ENABLE	: std_logic := '0';
	constant nDLL_DISABLE	: std_logic := '1';
	constant nDLL		: std_logic := nDLL_ENABLE;

	-- Driving strength
	constant NORMAL			: std_logic := '0';
	constant WEAK			: std_logic := '1';
	constant DRIVING_STRENGTH	: std_logic := nDLL_ENABLE;
end package mem_pkg;
