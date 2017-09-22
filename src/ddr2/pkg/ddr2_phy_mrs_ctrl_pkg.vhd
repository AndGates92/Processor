library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;
use work.ddr2_phy_pkg.all;

package ddr2_phy_mrs_ctrl_pkg is 

	constant CNT_MRS_CTRL_L		: integer := int_to_bit_num(T_MOD_ns_max);

	constant STATE_MRS_CTRL_L	: positive := 3;

	constant MRS_CTRL_IDLE			: std_logic_vector(STATE_MRS_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(0, STATE_MRS_CTRL_L));
	constant MRS_CTRL_ODT_TURN_OFF		: std_logic_vector(STATE_MRS_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(1, STATE_MRS_CTRL_L));
	constant MRS_CTRL_SEND_CMD		: std_logic_vector(STATE_MRS_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(2, STATE_MRS_CTRL_L));
	constant MRS_CTRL_REG_UPD		: std_logic_vector(STATE_MRS_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(3, STATE_MRS_CTRL_L));
	constant MRS_CTRL_ODT_TURN_ON		: std_logic_vector(STATE_MRS_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(4, STATE_MRS_CTRL_L));

	component ddr2_phy_mrs_ctrl is
	--generic (

	--);
	port (

		rst			: in std_logic;
		clk			: in std_logic;

		-- Transaction Controller
		CtrlReq			: out std_logic;
		CtrlCmd			: out std_logic_vector(MEM_CMD_L - 1 downto 0);

		CtrlAck			: in std_logic;

		-- Commands
		CmdAck			: in std_logic;

		CmdReq			: out std_logic;
		Cmd			: out std_logic_vector(MEM_CMD_L - 1 downto 0);

		-- ODT Controller
		ODTCtrlAck		: in std_logic;

		ODTCtrlReq		: out std_logic;

		-- Turn ODT signal on after MRS command(s)
		MRSUpdateCompleted	: out std_logic
	);
	end component;


end package ddr2_phy_mrs_ctrl_pkg;