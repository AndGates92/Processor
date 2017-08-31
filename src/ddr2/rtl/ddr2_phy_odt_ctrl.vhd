library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;
use work.ddr2_gen_ac_timing_pkg.all;
use work.ddr2_phy_pkg.all;
use work.ddr2_phy_odt_ctrl_pkg.all;

entity ddr2_phy_odt_ctrl is
generic (

);
port (

	rst			: in std_logic;
	clk			: in std_logic;

	-- Command sent to memory
	Cmd			: in std_logic_vector(MEM_CMD_L - 1 downto 0);

	-- MRS Controller
	MRSCtrlReq		: in std_logic;
	MRSUpdateCompleted	: in std_logic;

	MRSCtrlAck		: out std_logic;

	-- Refresh Controller
	RefCtrlReq		: in std_logic;

	RefCtrlAck		: out std_logic;

	-- Stop Arbiter
	PauseArbiter		: out std_logic;

	-- ODT
	ODT			: out std_logic
);
end entity ddr2_phy_odt_ctrl;

architecture rtl of ddr2_phy_odt_ctrl is

