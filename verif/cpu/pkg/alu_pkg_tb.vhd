library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
library common_rtl_pkg;
use common_rtl_pkg.functions_pkg.all;
library common_tb_pkg;
use common_tb_pkg.functions_pkg_tb.all;
use common_tb_pkg.shared_pkg_tb.all;
library cpu_rtl_pkg;
use cpu_rtl_pkg.alu_pkg.all;
library cpu_tb_pkg;
use cpu_tb_pkg.cpu_pkg_tb.all;
use cpu_tb_pkg.cpu_log_pkg.all;

package alu_pkg_tb is 

	procedure alu_ref(variable Op1_int : in integer; variable Op2_int: in integer; variable Cmd: in std_logic_vector(CMD_ALU_L-1 downto 0); variable Res_ideal: out integer; variable Ovfl_ideal : out boolean; variable Unfl_ideal : out boolean);

	function alu_cmd_std_vect_to_txt (Cmd: std_logic_vector(CMD_ALU_L-1 downto 0)) return string;
	function full_alu_cmd_std_vect_to_txt (Cmd: std_logic_vector(CMD_ALU_L-1 downto 0)) return string;

end package alu_pkg_tb;

package body alu_pkg_tb is

	procedure alu_ref(variable Op1_int : in integer; variable Op2_int: in integer; variable Cmd: in std_logic_vector(CMD_ALU_L-1 downto 0); variable Res_ideal: out integer; variable Ovfl_ideal : out boolean; variable Unfl_ideal : out boolean) is
		variable tmp_op1	: std_logic_vector(OP1_L_TB-1 downto 0);
		variable tmp_op2	: std_logic_vector(OP2_L_TB-1 downto 0);
		variable tmp_res	: std_logic_vector(OP1_L_TB-1 downto 0);
		variable Res_tmp	: integer;
	begin
		Ovfl_ideal := False;
		Unfl_ideal := False;
		if (Cmd = CMD_ALU_USUM) then
			Res_tmp := Op1_int + Op2_int;
			Res_ideal := Res_tmp;
			if (Res_tmp > (2**(OP1_L_TB) - 1)) then
				Ovfl_ideal := True;
				Res_ideal := Res_tmp - 2**(OP1_L_TB);
			end if;
		elsif (Cmd = CMD_ALU_SSUM) then
			Res_tmp := Op1_int + Op2_int;
			Res_ideal := Res_tmp;
			if (Res_tmp > (2**(OP1_L_TB-1) - 1)) then
				Ovfl_ideal := True;
				Res_ideal := -2*(2**(OP1_L_TB-1)) + Res_tmp;
			elsif (Res_tmp < (-(2**(OP1_L_TB-1)))) then
				Unfl_ideal := True;
				Res_ideal := 2*(2**(OP1_L_TB-1)) + Res_tmp;
			end if;
		elsif (Cmd = CMD_ALU_USUB) then
			Res_tmp := Op1_int - Op2_int;
			Res_ideal := Res_tmp;
			if (Res_tmp < 0) then
				Unfl_ideal := True;
				Res_ideal := 2**(OP1_L_TB) + Res_tmp;
			end if;
		elsif (Cmd = CMD_ALU_SSUB) then
			Res_tmp := Op1_int - Op2_int;
			Res_ideal := Res_tmp;
			if (Res_tmp > (2**(OP1_L_TB-1) - 1)) then
				Ovfl_ideal := True;
				Res_ideal := -2*(2**(OP1_L_TB-1)) + Res_tmp;
			elsif (Res_tmp < (-(2**(OP1_L_TB-1)))) then
				Unfl_ideal := True;
				Res_ideal := 2*(2**(OP1_L_TB-1)) + Res_tmp;
			end if;
		elsif (Cmd = CMD_ALU_UCMP) then
			if (Op1_int = Op2_int) then
				Res_ideal := 0;
			elsif (Op1_int > Op2_int) then
				Res_ideal := 1;
			else
				Res_ideal := (2**(OP1_L_TB)) - 1;
			end if;
		elsif (Cmd = CMD_ALU_SCMP) then
			if (Op1_int = Op2_int) then
				Res_ideal := 0;
			elsif (Op1_int > Op2_int) then
				Res_ideal := 1;
			else
				Res_ideal := - 1;
			end if;
		elsif (Cmd = CMD_ALU_AND) then
			tmp_op1 := std_logic_vector(to_signed(Op1_int, OP1_L_TB));
			tmp_op2 := std_logic_vector(to_signed(Op2_int, OP2_L_TB));
			for i in 0 to OP1_L_TB-1 loop
				tmp_res(i) := tmp_op1(i) and tmp_op2(i);
			end loop;
			Res_ideal := to_integer(unsigned(tmp_res));
		elsif (Cmd = CMD_ALU_OR) then
			tmp_op1 := std_logic_vector(to_signed(Op1_int, OP1_L_TB));
			tmp_op2 := std_logic_vector(to_signed(Op2_int, OP2_L_TB));
			for i in 0 to OP1_L_TB-1 loop
				tmp_res(i) := tmp_op1(i) or tmp_op2(i);
			end loop;
			Res_ideal := to_integer(unsigned(tmp_res));
		elsif (Cmd = CMD_ALU_XOR) then
			tmp_op1 := std_logic_vector(to_signed(Op1_int, OP1_L_TB));
			tmp_op2 := std_logic_vector(to_signed(Op2_int, OP2_L_TB));
			for i in 0 to OP1_L_TB-1 loop
				tmp_res(i) := tmp_op1(i) xor tmp_op2(i);
			end loop;
			Res_ideal := to_integer(unsigned(tmp_res));
		elsif (Cmd = CMD_ALU_NOT) then
			tmp_op1 := std_logic_vector(to_signed(Op1_int, OP1_L_TB));
			for i in 0 to OP1_L_TB-1 loop
				tmp_res(i) := not tmp_op1(i);
			end loop;
			Res_ideal := to_integer(unsigned(tmp_res));
		else
			Res_ideal := 0;
		end if;
	end procedure alu_ref;

	function alu_cmd_std_vect_to_txt(Cmd: std_logic_vector(CMD_ALU_L-1 downto 0)) return string is
		variable Cmd_txt : string(1 to 4);
	begin
		if (Cmd = CMD_ALU_USUM) then
			Cmd_txt := "USUM";
		elsif (Cmd = CMD_ALU_SSUM) then
			Cmd_txt := "SSUM";
		elsif (Cmd = CMD_ALU_USUB) then
			Cmd_txt := "USUB";
		elsif (Cmd = CMD_ALU_SSUB) then
			Cmd_txt := "SSUB";
		elsif (Cmd = CMD_ALU_UCMP) then
			Cmd_txt := "UCMP";
		elsif (Cmd = CMD_ALU_SCMP) then
			Cmd_txt := "SCMP";
		elsif (Cmd = CMD_ALU_AND) then
			Cmd_txt := "BAND";
		elsif (Cmd = CMD_ALU_OR) then
			Cmd_txt := "B_OR";
		elsif (Cmd = CMD_ALU_XOR) then
			Cmd_txt := "BXOR";
		elsif (Cmd = CMD_ALU_NOT) then
			Cmd_txt := "BNOT";
		elsif (Cmd = CMD_ALU_SHIFT) then
			Cmd_txt := "SHFT";
		elsif (Cmd = CMD_ALU_DISABLE) then
			Cmd_txt := "DISA";
		else
			Cmd_txt := "UCMD";
		end if;

		return Cmd_txt;

	end;

	function full_alu_cmd_std_vect_to_txt(Cmd: std_logic_vector(CMD_ALU_L-1 downto 0)) return string is
		variable Cmd_txt : string(1 to 4);
	begin
		if (Cmd = CMD_ALU_MUL) then
			Cmd_txt := "MULT";
		elsif (Cmd = CMD_ALU_DIV) then
			Cmd_txt := "DIVI";
		else
			Cmd_txt := alu_cmd_std_vect_to_txt(Cmd);
		end if;

		return Cmd_txt;

	end;

end package body alu_pkg_tb;
