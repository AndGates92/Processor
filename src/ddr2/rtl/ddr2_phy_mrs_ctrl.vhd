library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;
use work.ddr2_phy_pkg.all;
use work.ddr2_phy_mrs_ctrl_pkg.all;

entity ddr2_phy_mrs_ctrl is
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

	-- Stop Arbiter
	MRSUpdateCompleted	: out std_logic
);
end entity ddr2_phy_mrs_ctrl;

architecture rtl of ddr2_phy_mrs_ctrl is


begin

end rtl;
