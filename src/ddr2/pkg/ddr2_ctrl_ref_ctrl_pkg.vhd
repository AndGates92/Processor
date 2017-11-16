library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library common_rtl_pkg;
use common_rtl_pkg.functions_pkg.all;
use common_rtl_pkg.type_conversion_pkg.all;
library ddr2_rtl_pkg;
use ddr2_rtl_pkg.ddr2_ctrl_pkg.all;
use ddr2_rtl_pkg.ddr2_mrs_max_pkg.all;
use ddr2_rtl_pkg.ddr2_gen_ac_timing_pkg.all;

package ddr2_ctrl_ref_ctrl_pkg is 

	constant STATE_REF_CTRL_L	: positive := 4;

	constant REF_CTRL_IDLE			: std_logic_vector(STATE_REF_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(0, STATE_REF_CTRL_L));
	constant FINISH_OUTSTANDING_TX		: std_logic_vector(STATE_REF_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(1, STATE_REF_CTRL_L));
	constant AUTO_REF_REQUEST		: std_logic_vector(STATE_REF_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(2, STATE_REF_CTRL_L));
	constant ODT_DISABLE			: std_logic_vector(STATE_REF_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(3, STATE_REF_CTRL_L));
	constant SELF_REF_ENTRY_REQUEST		: std_logic_vector(STATE_REF_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(4, STATE_REF_CTRL_L));
	constant SELF_REF			: std_logic_vector(STATE_REF_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(5, STATE_REF_CTRL_L));
	constant SELF_REF_EXIT_REQUEST		: std_logic_vector(STATE_REF_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(6, STATE_REF_CTRL_L));
	constant ENABLE_OP			: std_logic_vector(STATE_REF_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(7, STATE_REF_CTRL_L));
	constant ODT_ENABLE			: std_logic_vector(STATE_REF_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(8, STATE_REF_CTRL_L));

	constant AUTO_REFRESH_EXIT_TIME	: integer := T_RFC;
	constant SELF_REFRESH_EXIT_TIME	: integer := max_int(T_XSRD, T_XSNR);
	constant ENABLE_OP_CNT_L	: integer := int_to_bit_num(max_int(SELF_REFRESH_EXIT_TIME, AUTO_REFRESH_EXIT_TIME));

	constant MAX_OUTSTANDING_REF	: positive := 8;

	constant OUTSTANDING_REF_CNT_L	: positive := int_to_bit_num(MAX_OUTSTANDING_REF);

	constant AUTO_REF_CNT_L		: integer := int_to_bit_num(max_int(T_REFI_lowT, T_REFI_highT));

	component ddr2_ctrl_ref_ctrl is
	generic (
		BANK_NUM		: positive := 8
	);
	port (

		rst			: in std_logic;
		clk			: in std_logic;

		-- High Temperature Refresh
		DDR2HighTemperatureRefresh	: in std_logic;

		-- Transaction Controller
		RefreshReq		: out std_logic;
		NonReadOpEnable		: out std_logic;
		ReadOpEnable		: out std_logic;

		-- PHY Init
		PhyInitCompleted	: in std_logic;

		-- Bank Controller
		BankIdle		: in std_logic_vector(BANK_NUM - 1 downto 0);

		-- ODT Controller
		ODTCtrlAck		: in std_logic;

		RefCmdAccepted		: out std_logic;
		ODTCtrlReq		: out std_logic;
		ODTCmd			: out std_logic_vector(MEM_CMD_L - 1 downto 0);

		-- Arbitrer
		CmdAck			: in std_logic;

		CmdOut			: out std_logic_vector(MEM_CMD_L - 1 downto 0);
		CmdReq			: out std_logic;

		-- Controller
		CtrlReq			: in std_logic;

		CtrlAck			: out std_logic

	);
	end component;


end package ddr2_ctrl_ref_ctrl_pkg;
