library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;
use work.ddr2_phy_pkg.all;

package ddr2_pkg_tb is 

	constant CLK_RATIO_TB		: positive := 4;

	constant BANK_NUM_TB	: positive := 8;
	constant BANK_L_TB	: positive := positive(int_to_bit_num(BANK_NUM_TB));

	constant BANK_CTRL_NUM_TB	: positive := BANK_NUM_TB;
	constant COL_CTRL_NUM_TB	: positive := 1;
	constant REF_CTRL_NUM_TB	: positive := 1;

	constant COL_L_TB	: positive := 10;
	constant ROW_L_TB	: positive := 14;

	constant ADDR_MEM_L_TB	: positive := 14;
	constant DDR2_ADDR_L_TB	: positive := ROW_L_TB + COL_L_TB + BANK_L_TB;

	constant DDR2_DATA_L_TB	: positive := 16;

	constant MAX_OUTSTANDING_BURSTS_TB		: positive := 10;
	constant MAX_OUTSTANDING_BURSTS_L_TB		: positive := int_to_bit_num(MAX_OUTSTANDING_BURSTS_TB);

	function ddr2_cmd_std_logic_vector_to_txt (Cmd: std_logic_vector(MEM_CMD_L-1 downto 0)) return string;

end package ddr2_pkg_tb;

package body ddr2_pkg_tb is

	function ddr2_cmd_std_logic_vector_to_txt(Cmd: std_logic_vector(MEM_CMD_L-1 downto 0)) return string is
		variable Cmd_txt : string(1 to 18);
	begin
		if (Cmd = CMD_NOP) then
			Cmd_txt := "   NO OPERATION   ";
		elsif (Cmd = CMD_DESEL) then
			Cmd_txt := " DEVICE DESELECT  ";
		elsif (Cmd = CMD_BANK_ACT) then
			Cmd_txt := "  BANK ACTIVATE   ";
		elsif (Cmd = CMD_MODE_REG_SET) then
			Cmd_txt := "       MRS        ";
		elsif (Cmd = CMD_EXT_MODE_REG_SET_1) then
			Cmd_txt := "       MRS1       ";
		elsif (Cmd = CMD_EXT_MODE_REG_SET_2) then
			Cmd_txt := "       MRS2       ";
		elsif (Cmd = CMD_EXT_MODE_REG_SET_3) then
			Cmd_txt := "       MRS3       ";
		elsif (Cmd = CMD_AUTO_REF) then
			Cmd_txt := "   AUTO REFRESH   ";
		elsif (Cmd = CMD_SELF_REF_ENTRY) then
			Cmd_txt := "  SELF REF ENTRY  ";
		elsif (Cmd = CMD_SELF_REF_EXIT) then
			Cmd_txt := "  SELF REF EXIT   ";
		elsif (Cmd = CMD_POWER_DOWN_ENTRY) then
			Cmd_txt := " POWER DOWN ENTRY ";
		elsif (Cmd = CMD_POWER_DOWN_EXIT) then
			Cmd_txt := " POWER DOWN EXIT  ";
		elsif (Cmd = CMD_BANK_PRECHARGE) then
			Cmd_txt := "  BANK PRECHARGE  ";
		elsif (Cmd = CMD_ALL_BANK_PRECHARGE) then
			Cmd_txt := "ALL BANK PRECHARGE";
		elsif (Cmd = CMD_WRITE) then
			Cmd_txt := "      WRITE       ";
		elsif (Cmd = CMD_WRITE_PRECHARGE) then
			Cmd_txt := "WRITE & PRECHARGE ";
		elsif (Cmd = CMD_READ) then
			Cmd_txt := "      READ        ";
		elsif (Cmd = CMD_READ_PRECHARGE) then
			Cmd_txt := " READ & PRECHARGE ";
		else
			Cmd_txt := "  Unknown Command ";
		end if;

		return Cmd_txt;

	end;

end package body ddr2_pkg_tb;
