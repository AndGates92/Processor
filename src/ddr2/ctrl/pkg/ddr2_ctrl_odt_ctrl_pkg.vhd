library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library common_rtl_pkg;
use common_rtl_pkg.functions_pkg.all;
library ddr2_ctrl_rtl_pkg;
use ddr2_ctrl_rtl_pkg.ddr2_ctrl_pkg.all;
use ddr2_ctrl_rtl_pkg.ddr2_odt_ac_timing_pkg.all;

package ddr2_ctrl_odt_ctrl_pkg is 

	constant CNT_ODT_CTRL_L		: integer := int_to_bit_num(max_int(T_AOFD, T_AOND_max));

	constant STATE_ODT_CTRL_L	: positive := 3;

	constant ODT_CTRL_IDLE			: std_logic_vector(STATE_ODT_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(0, STATE_ODT_CTRL_L));
	constant ODT_CTRL_TURN_OFF_REF		: std_logic_vector(STATE_ODT_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(1, STATE_ODT_CTRL_L));
	constant ODT_CTRL_TURN_OFF_MRS		: std_logic_vector(STATE_ODT_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(2, STATE_ODT_CTRL_L));
	constant ODT_CTRL_REF_REQ		: std_logic_vector(STATE_ODT_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(3, STATE_ODT_CTRL_L));
	constant ODT_CTRL_MRS_UPD		: std_logic_vector(STATE_ODT_CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(4, STATE_ODT_CTRL_L));

	component ddr2_ctrl_odt_ctrl is
--	generic (

--	);
	port (

		rst			: in std_logic;
		clk			: in std_logic;

		-- Command sent to memory
		Cmd			: in std_logic_vector(MEM_CMD_L - 1 downto 0);

		NoBankColCmd		: in std_logic;

		-- MRS Controller
		MRSCmdAccepted		: in std_logic;
		MRSCtrlReq		: in std_logic;
		MRSCmd			: in std_logic_vector(MEM_CMD_L - 1 downto 0);
		MRSUpdateCompleted	: in std_logic;
		LastMRSCmd		: in std_logic;

		MRSCtrlAck		: out std_logic;

		-- Refresh Controller
		RefCmdAccepted		: in std_logic;
		RefCtrlReq		: in std_logic;
		RefCmd			: in std_logic_vector(MEM_CMD_L - 1 downto 0);

		RefCtrlAck		: out std_logic;

		-- Stop Arbiter
		PauseArbiter		: out std_logic;

		-- ODT
		ODT			: out std_logic
	);
	end component;


end package ddr2_ctrl_odt_ctrl_pkg;
