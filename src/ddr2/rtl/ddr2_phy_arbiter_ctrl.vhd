library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library common_rtl_pkg;
use common_rtl_pkg.types_pkg.all;
library ddr2_rtl_pkg;
use ddr2_rtl_pkg.ddr2_phy_pkg.all;
use ddr2_rtl_pkg.ddr2_phy_arbiter_ctrl_pkg.all;
use ddr2_rtl_pkg.ddr2_gen_ac_timing_pkg.all;

entity ddr2_phy_arbiter_ctrl is
--generic (

--);
port (

	rst		: in std_logic;
	clk		: in std_logic;

	ODTCtrlPauseArbiter	: in std_logic;
	BankActOut		: in std_logic;

	PauseArbiter		: out std_logic;
	AllowBankActivate	: out std_logic
);
end entity ddr2_phy_arbiter_ctrl;

architecture rtl of ddr2_phy_arbiter_ctrl is

	signal CountC, CountN	: arb_ctrl_unsigned_arr(WINDOW_L - 1 downto 0);

begin

end rtl;
