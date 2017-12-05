library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library common_rtl_pkg;
use common_rtl_pkg.functions_pkg.all;
library ddr2_ctrl_rtl_pkg;
use ddr2_ctrl_rtl_pkg.ddr2_ctrl_pkg.all;
use ddr2_ctrl_rtl_pkg.ddr2_mrs_max_pkg.all;
use ddr2_ctrl_rtl_pkg.ddr2_gen_ac_timing_pkg.all;

package ddr2_ctrl_bank_ctrl_pkg is 

	constant T_ACT_COL_MAX_VALUE	: positive := T_RCD; -- max value is when additive latency is 0. Actual value: T_RCD - AL
	constant T_WRITE_PRE_MAX_VALUE	: positive := WRITE_LATENCY_MAX_VALUE + T_WR + positive(2**(BURST_LENGTH_MAX_VALUE) - 1);
	constant T_WRITE_ACT_MAX_VALUE	: positive := T_RP + T_WRITE_PRE_MAX_VALUE;
	constant T_READ_PRE_MAX_VALUE	: positive := AL_MAX_VALUE + (2**(BURST_LENGTH_MAX_VALUE - 1)) + max_int(T_RTP, 2) - 2;
	constant T_READ_ACT_MAX_VALUE	: positive := T_RP + T_READ_PRE_MAX_VALUE;

	constant CNT_BANK_CTRL_L	: integer := int_to_bit_num(max_int(T_RAS_min, max_int(T_RC, T_ACT_COL_MAX_VALUE)));
	constant CNT_DELAY_L		: integer := int_to_bit_num(max_int(T_READ_PRE_MAX_VALUE, max_int(T_WRITE_PRE_MAX_VALUE, T_RP)));

	constant STATE_BANK_CTRL_L	: positive := 3;

	constant BANK_CTRL_IDLE			: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(0, STATE_BANK_CTRL_L));
	constant WAIT_ACT_ACK			: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(1, STATE_BANK_CTRL_L));
	constant ELAPSE_T_ACT_COL		: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(2, STATE_BANK_CTRL_L));
	constant BANK_CTRL_DATA_PHASE		: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(3, STATE_BANK_CTRL_L));
	constant PROCESS_COL_CMD		: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(4, STATE_BANK_CTRL_L));
	constant ELAPSE_T_RAS			: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(5, STATE_BANK_CTRL_L));
	constant ELAPSE_T_RP			: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(6, STATE_BANK_CTRL_L));

	component ddr2_ctrl_bank_ctrl
	generic (
		ROW_L			: positive := 13;
		BANK_ID			: integer := 0;
		BANK_NUM		: positive := 8;
		MAX_OUTSTANDING_BURSTS	: positive := 10
	);
	port (

		rst		: in std_logic;
		clk		: in std_logic;

		-- MRS configuration
		DDR2BurstLength		: in std_logic_vector(int_to_bit_num(BURST_LENGTH_MAX_VALUE) - 1 downto 0);
		DDR2AdditiveLatency	: in std_logic_vector(int_to_bit_num(AL_MAX_VALUE) - 1 downto 0);
		DDR2WriteLatency		: in std_logic_vector(int_to_bit_num(WRITE_LATENCY_MAX_VALUE) - 1 downto 0);

		-- Arbitrer
		CmdAck		: in std_logic;

		RowMemOut	: out std_logic_vector(ROW_L - 1 downto 0);
		BankMemOut	: out std_logic_vector(int_to_bit_num(BANK_NUM) - 1 downto 0);
		CmdOut		: out std_logic_vector(MEM_CMD_L - 1 downto 0);
		CmdReq		: out std_logic;

		-- Transaction Controller
		RowMemIn	: in std_logic_vector(ROW_L - 1 downto 0);
		CtrlReq		: in std_logic;

		CtrlAck		: out std_logic;

		-- Column Controller
		EndDataPhase		: in std_logic;
		ReadBurst		: in std_logic;

		-- Bank Status
		ZeroOutstandingBursts	: out std_logic;
		BankIdle		: out std_logic;
		BankActive		: out std_logic
	);
	end component;

end package ddr2_ctrl_bank_ctrl_pkg;
