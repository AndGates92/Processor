library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ctrl_pkg.all;
use work.proc_pkg.all;
use work.tb_pkg.all;

package ctrl_pkg_tb is 

	function ctrl_cmd_std_vect_to_txt(Cmd: std_logic_vector(CTRL_CMD_L-1 downto 0)) return string;

end package ctrl_pkg_tb;

package body ctrl_pkg_tb is

	function ctrl_cmd_std_vect_to_txt(Cmd: std_logic_vector(CTRL_CMD_L-1 downto 0)) return string is
		variable Cmd_txt : string(1 to 4);
	begin
		if (Cmd = CTRL_CMD_DISABLE) then
			Cmd_txt := "DIS ";
		elsif (Cmd = CTRL_CMD_ALU) then
			Cmd_txt := "ALU ";
		elsif (Cmd = CTRL_CMD_RD_M) then
			Cmd_txt := "RD_M";
		elsif (Cmd = CTRL_CMD_RD_S) then
			Cmd_txt := "RD_S";
		elsif (Cmd = CTRL_CMD_WR_M) then
			Cmd_txt := "WR_S";
		elsif (Cmd = CTRL_CMD_WR_S) then
			Cmd_txt := "WR_S";
		elsif (Cmd = CTRL_CMD_MOV) then
			Cmd_txt := "MOV ";
		else
			Cmd_txt := "UCMD";
		end if;

		return Cmd_txt;

	end;

end package body ctrl_pkg_tb;
