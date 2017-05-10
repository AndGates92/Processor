library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ddr2_pkg.all;
use work.ddr2_phy_pkg.all;
use work.ddr2_phy_bank_ctrl_pkg.all;

entity ddr2_phy_bank_ctrl is
port (

	rst		: in std_logic;
	clk		: in std_logic;

	-- User Interface
	ColMemIn	: in std_logic_vector(COL_L - 1 downto 0);
	RowMemIn	: in std_logic_vector(ROW_L - 1 downto 0);
	ReadMem		: in std_logic;
	UIReq		: in std_logic;

	UIAck		: out std_logic;

	-- Arbitrer
	ColMemOut		: out std_logic_vector(COL_L - 1 downto 0);
	RowMemOut		: out std_logic_vector(ROW_L - 1 downto 0);
	CmdOut			: out std_logic_vector(CMD_MEM_L - 1 downto 0);
	CmdReq			: out std_logic;

	CmdAck			: in std_logic;

);
end entity ddr2_phy_bank_ctrl;

architecture rtl of ddr2_phy_bank_ctrl is

	signal BankActiveC, BankActiveN		: std_logic;

	signal StateC, StateN			: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0);

begin

end rtl;
