library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;
use work.ddr2_pkg.all;

package ddr2_phy_bank_ctrl_pkg is 

	constant T_ACT_COL	: positive := T_RCD - to_integer(unsigned(AL)); 
	constant T_WRITE_PRE	: positive := WRITE_LATENCY + to_integer(unsigned(T_WR)) + (2**(to_integer(unsigned(BL)) - 1));
	constant T_WRITE_ACT	: positive := T_RP + T_WRITE_PRE;
	constant T_READ_PRE	: positive := to_integer(unsigned(AL)) + (2**(to_integer(unsigned(BL)) - 1));
	constant T_READ_ACT	: positive := T_RP + T_READ_PRE;

	constant CNT_BANK_CTRL_L	: integer := int_to_bit_num(max_int(T_RAS, max_int(T_RC, T_ACT_COL)));
	constant CNT_DELAY_L		: integer := int_to_bit_num(max_int(T_READ_PRE, max_int(T_WRITE_PRE, T_RP)));

	constant STATE_BANK_CTRL_L	: positive := 3;

	constant IDLE				: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(0, STATE_BANK_CTRL_L));
	constant WAIT_ACT_ACK			: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(1, STATE_BANK_CTRL_L));
	constant ELAPSE_T_ACT_COL		: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(2, STATE_BANK_CTRL_L));
	constant DATA_PHASE			: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(3, STATE_BANK_CTRL_L));
	constant PROCESS_COL_CMD		: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(4, STATE_BANK_CTRL_L));
	constant ELAPSE_T_RAS			: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(5, STATE_BANK_CTRL_L));
	constant ELAPSE_T_RP			: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(6, STATE_BANK_CTRL_L));

	component ddr2_phy_bank_ctrl
	port (

		rst		: in std_logic;
		clk		: in std_logic;

		-- User Interface
		ColMemIn	: in std_logic_vector(COL_L - 1 downto 0);
		RowMemIn	: in std_logic_vector(ROW_L - 1 downto 0);
		ReadMem		: in std_logic;
		LastBurst	: in std_logic;
		UIReq		: in std_logic;

		UIAck		: out std_logic;

		-- Arbitrer
		ColMemOut		: out std_logic_vector(COL_L - 1 downto 0);
		RowMemOut		: out std_logic_vector(ROW_L - 1 downto 0);
		CmdOut			: out std_logic_vector(CMD_MEM_L - 1 downto 0);
		CmdReq			: out std_logic;

		CmdAck			: in std_logic;

	);
	end component;

end package ddr2_phy_bank_ctrl_pkg;
