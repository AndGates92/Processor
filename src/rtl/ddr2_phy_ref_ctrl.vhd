library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;
use work.ddr2_phy_pkg.all;
use work.ddr2_mrs_pkg.all;
use work.ddr2_timing_pkg.all;
use work.ddr2_phy_ref_ctrl_pkg.all;

entity ddr2_phy_ref_ctrl is
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
end entity ddr2_phy_ref_ctrl;

architecture rtl of ddr2_phy_ref_ctrl is

	signal StateN, StateC			: std_logic_vector(STATE_REF_CTRL_L - 1 downto 0);

begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then
			StateC <= REF_CTRL_IDLE;
		elsif ((clk'event) and (clk = '1')) then
			StateC <= StateN;
		end if;
	end process reg;

	state_det: process(StateC)
	begin
		StateN <= StateC; -- avoid latches
		if (StateC = REF_CTRL_IDLE) then

		else
			StateN <= StateC;
		end if;
	end process state_det;

end rtl;
