library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.functions_pkg.all;
use work.ddr2_phy_pkg.all;
use work.ddr2_mrs_pkg.all;
use work.ddr2_gen_ac_timing_pkg.all;

package ddr2_phy_bank_ctrl_pkg is 

	constant T_ACT_COL	: positive := T_RCD - to_integer(unsigned(AL)); 
	constant T_WRITE_PRE	: positive := WRITE_LATENCY + T_WR + positive(2**(to_integer(unsigned(BURST_LENGTH))) - 1);
	constant T_WRITE_ACT	: positive := T_RP + T_WRITE_PRE;
	constant T_READ_PRE	: positive := to_integer(unsigned(AL)) + (2**(to_integer(unsigned(BURST_LENGTH)) - 1)) + max_int(T_RTP, 2) - 2;
	constant T_READ_ACT	: positive := T_RP + T_READ_PRE;

	constant CNT_BANK_CTRL_L	: integer := int_to_bit_num(max_int(T_RAS_min, max_int(T_RC, T_ACT_COL)));
	constant CNT_DELAY_L		: integer := int_to_bit_num(max_int(T_READ_PRE, max_int(T_WRITE_PRE, T_RP)));

	constant STATE_BANK_CTRL_L	: positive := 3;

	constant BANK_CTRL_IDLE			: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(0, STATE_BANK_CTRL_L));
	constant WAIT_ACT_ACK			: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(1, STATE_BANK_CTRL_L));
	constant ELAPSE_T_ACT_COL		: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(2, STATE_BANK_CTRL_L));
	constant BANK_CTRL_DATA_PHASE		: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(3, STATE_BANK_CTRL_L));
	constant PROCESS_COL_CMD		: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(4, STATE_BANK_CTRL_L));
	constant ELAPSE_T_RAS			: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(5, STATE_BANK_CTRL_L));
	constant ELAPSE_T_RP			: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(6, STATE_BANK_CTRL_L));

	component ddr2_phy_bank_ctrl
	generic (
		ROW_L			: positive := 13;
		BANK_ID			: integer := 0;
		BANK_NUM		: positive := 8;
		MAX_OUTSTANDING_BURSTS	: positive := 10
	);
	port (

		rst		: in std_logic;
		clk		: in std_logic;

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

end package ddr2_phy_bank_ctrl_pkg;
