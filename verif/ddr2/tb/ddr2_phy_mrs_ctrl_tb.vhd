library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;
use work.proc_pkg.all;
use work.ddr2_define_pkg.all;
use work.ddr2_phy_pkg.all;
use work.ddr2_phy_odt_ctrl_pkg.all;
use work.type_conversion_pkg.all;
use work.tb_pkg.all;
use work.ddr2_pkg_tb.all;

entity ddr2_phy_odt_ctrl_tb is
end entity ddr2_phy_odt_ctrl_tb;

architecture bench of ddr2_phy_odt_ctrl_tb is

	constant CLK_PERIOD	: time := DDR2_CLK_PERIOD * 1 ns;
	constant NUM_TESTS	: integer := 10000;
	constant TOT_NUM_TESTS	: integer := NUM_TESTS;

	constant MAX_REQUESTS_PER_TEST	: integer := 500;
	constant MAX_BURST_DELAY	: integer := 20;

	constant MRS_REG_L_TB	: positive := 13;

	signal clk_tb	: std_logic := '0';
	signal stop	: boolean := false;
	signal rst_tb	: std_logic;

	-- Transaction Controller
	signal CtrlReq_tb	: std_logic;
	signal CtrlCmd_tb	: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal CtrlData_tb	: std_logic_vector(MRS_REG_L - 1 downto 0);

	signal CtrlAck_tb	: std_logic;

	-- Commands
	signal CmdAck_tb	: std_logic;

	signal CmdReq_tb	: std_logic;
	signal Cmd_tb		: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal Data_tb		: std_logic_vector(MRS_REG_L - 1 downto 0);

	-- ODT Controller
	signal ODTCtrlAck_tb	: std_logic;

	signal ODTCtrlReq_tb	: std_logic;

	-- Turn ODT signal on after MRS command(s)
	signal MRSUpdateCompleted_tb	: std_logic;


