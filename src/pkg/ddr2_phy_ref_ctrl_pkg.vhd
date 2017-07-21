library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;
use work.ddr2_phy_pkg.all;
use work.ddr2_mrs_pkg.all;
use work.ddr2_gen_ac_timing_pkg.all;
use work.type_conversion_pkg.all;

package ddr2_phy_ref_ctrl_pkg is 

	constant STATE_REF_CTRL_L	: positive := 3;

	constant REF_CTRL_IDLE			: std_logic_vector(STATE_REF_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(0, STATE_REF_CTRL_L));
	constant FINISH_OUTSTANDING_TX		: std_logic_vector(STATE_REF_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(1, STATE_REF_CTRL_L));
	constant AUTO_REF_REQUEST		: std_logic_vector(STATE_REF_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(2, STATE_REF_CTRL_L));
	constant ODT_DISABLE			: std_logic_vector(STATE_REF_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(3, STATE_REF_CTRL_L));
	constant SELF_REF_ENTRY_REQUEST		: std_logic_vector(STATE_REF_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(4, STATE_REF_CTRL_L));
	constant SELF_REF			: std_logic_vector(STATE_REF_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(5, STATE_REF_CTRL_L));
	constant SELF_REF_EXIT_REQUEST		: std_logic_vector(STATE_REF_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(6, STATE_REF_CTRL_L));
	constant ENABLE_OP			: std_logic_vector(STATE_REF_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(7, STATE_REF_CTRL_L));
	constant ODT_ENABLE			: std_logic_vector(STATE_REF_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(8, STATE_REF_CTRL_L));

	constant AUTO_REFRESH_EXIT_MAX_TIME	: integer := T_RFC;
	constant SELF_REFRESH_EXIT_MAX_TIME	: integer := max_int(T_XSRD, T_XSNR);
	constant ENABLE_OP_CNT_L		: integer := int_to_bit_num(max_int(SELF_REFRESH_EXIT_MAX_TIME, AUTO_REFRESH_EXIT_MAX_TIME));

	constant AUTO_REF_CNT_L		: integer;
	constant AUTO_REF_TIME		: integer;

	constant OUTSTANDING_REF_CNT_L	: positive := int_to_bit_num(MAX_OUTSTANDING_REF);

	function sel_param (param_sel_true, param_sel_false : integer; sel : boolean) return integer;

	component ddr2_phy_ref_ctrl is
	generic (
		BANK_NUM		: positive := 8
	);
	port (

		rst			: in std_logic;
		clk			: in std_logic;

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

		ODTDisable		: out std_logic;
		ODTCtrlReq		: out std_logic;

		-- Arbitrer
		CmdAck			: in std_logic;

		CmdOut			: out std_logic_vector(MEM_CMD_L - 1 downto 0);
		CmdReq			: out std_logic;

		-- Controller
		CtrlReq			: in std_logic;

		CtrlAck			: out std_logic

	);
	end component;


end package ddr2_phy_ref_ctrl_pkg;

package body ddr2_phy_ref_ctrl_pkg is

	function sel_param (param_sel_true, param_sel_false : integer; sel : boolean) return integer is
		variable param_out	: integer;
	begin
		if ( sel = true ) then
			param_out := param_sel_true;
		else
			param_out := param_sel_false;
		end if;

		return param_out;

	end function sel_param;

	constant AUTO_REF_CNT_L	: integer := int_to_bit_num(sel_param(T_REFI_highT, T_REFI_lowT, std_logic_to_bool(HITEMP_REF)));
	constant AUTO_REF_TIME	: integer := sel_param(T_REFI_highT, T_REFI_lowT, std_logic_to_bool(HITEMP_REF));

end package body ddr2_phy_ref_ctrl_pkg;
