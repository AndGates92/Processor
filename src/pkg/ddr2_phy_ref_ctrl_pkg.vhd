library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;
use work.ddr2_phy_pkg.all;
use work.ddr2_mrs_pkg.all;
use work.ddr2_gen_ac_timing_pkg.all;

package ddr2_phy_ref_ctrl_pkg is 

	constant STATE_REF_CTRL_L	: positive := 3;

	constant REF_CTRL_IDLE			: std_logic_vector(STATE_REF_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(0, STATE_REF_CTRL_L));
	constant FINISH_OUTSTANDING_TX		: std_logic_vector(STATE_REF_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(1, STATE_REF_CTRL_L));
	constant REF_REQUEST			: std_logic_vector(STATE_REF_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(2, STATE_REF_CTRL_L));
	constant ODT_DISABLE			: std_logic_vector(STATE_REF_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(3, STATE_REF_CTRL_L));
	constant ODT_TURN_OFF_DELAY		: std_logic_vector(STATE_REF_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(4, STATE_REF_CTRL_L));
	constant SELF_REF_ENTRY_REQUEST		: std_logic_vector(STATE_REF_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(5, STATE_REF_CTRL_L));
	constant SELF_REF_EXIT_REQUEST		: std_logic_vector(STATE_REF_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(6, STATE_REF_CTRL_L));
	constant SELF_REF			: std_logic_vector(STATE_REF_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(7, STATE_REF_CTRL_L));
	constant SELF_REF_EXIT_REQUEST		: std_logic_vector(STATE_REF_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(8, STATE_REF_CTRL_L));
	constant ENABLE_OP			: std_logic_vector(STATE_REF_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(9, STATE_REF_CTRL_L));

	component ddr2_phy_ref_ctrl is
	generic (
		BANK_NUM		: positive := 8
	);
	port (

		rst		: in std_logic;
		clk		: in std_logic;

		-- Transaction Controller
		RefreshReq	: out std_logic;
		WriteEn		: out std_logic;
		ReadEn		: out std_logic;

		-- Bank Controller
		BankIdle	: in std_logic_vector(BANK_NUM - 1 downto 0);

		-- ODT controller
		ODTDisable	: out std_logic;
		ODTCtrlReq	: out std_logic;

		ODTCtrlAck	: in std_logic;

		-- Arbitrer
		CmdAck		: in std_logic;

		CmdOut		: out std_logic_vector(MEM_CMD_L - 1 downto 0);
		CmdReq		: out std_logic;

		-- Controller
		CtrlReq			: in std_logic;

		CtrlAck			: out std_logic

	);
	end component;


end package ddr2_phy_ref_ctrl_pkg;
