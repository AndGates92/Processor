library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;
use work.ddr2_pkg.all;

package ddr2_phy_bank_ctrl_pkg is 

	constant T_ACT_COL	: positive := T_RCD - to_integer(unsigned(AL)); 
	constant T_READ_PRE	: positive := to_integer(unsigned(AL)) + (2**(to_integer(unsigned(BL)) - 1));
	constant T_WRITE_PRE	: positive := WRITE_LATENCY + to_integer(unsigned(T_WR)) + (2**(to_integer(unsigned(BL)) - 1));
	constant T_COL_COL	: positive := 2**(to_integer(unsigned(BL)) - 1);

	constant CNT_BANK_CTRL_L	: integer := int_to_bit_num(max_int(T_RAS, max_int(T_RC, max_int(T_ACT_COL, max_int(T_READ_PRE, T_WRITE_PRE)))));
	constant CNT_DELAY_L		: integer := int_to_bit_num(max_int(T_RP, T_COL_COL));

	constant STATE_BANK_CTRL_L	: positive := 4;

	constant IDLE			: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(0, STATE_BANK_CTRL_L));
	constant WAIT_ACT_ACK		: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(1, STATE_BANK_CTRL_L));
	constant WAIT_T_ACT_COL		: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(2, STATE_BANK_CTRL_L));
	constant WAIT_COL_ACK		: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(3, STATE_BANK_CTRL_L));
	constant WAIT_PRE_ACT		: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(4, STATE_BANK_CTRL_L));
	constant WAIT_VALID_DATA	: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(5, STATE_BANK_CTRL_L));

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
