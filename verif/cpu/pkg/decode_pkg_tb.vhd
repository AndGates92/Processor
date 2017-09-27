library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ctrl_pkg.all;
use work.decode_pkg.all;
use work.proc_pkg.all;
use work.cpu_tb_pkg.all;
use work.cpu_log_pkg.all;

package decode_pkg_tb is 

	procedure decode_ref(variable OpCode: in std_logic_vector(OP_CODE_L - 1 downto 0); variable ImmediateIn : in integer; variable PCIn, PCCallIn : in integer; variable StatReg : in std_logic_vector(STAT_REG_L_TB - 1 downto 0);variable ImmediateOut : out integer; variable PCOut, PCCallOut : out integer; variable CtrlOut : out integer; variable EndOfProg : out boolean);

	function op_code_std_vect_to_txt(OpCode: std_logic_vector(OP_CODE_L-1 downto 0)) return string;

end package decode_pkg_tb;

package body decode_pkg_tb is

	procedure decode_ref(variable OpCode: in std_logic_vector(OP_CODE_L - 1 downto 0); variable ImmediateIn : in integer; variable PCIn, PCCallIn : in integer; variable StatReg : in std_logic_vector(STAT_REG_L_TB - 1 downto 0);variable ImmediateOut : out integer; variable PCOut, PCCallOut : out integer; variable CtrlOut : out integer; variable EndOfProg : out boolean) is
	begin
		if (OpCode = OP_CODE_SET) then
			ImmediateOut := integer(2.0**(real(INSTR_L)) - 1.0);
		elsif (OpCode = OP_CODE_CLR) or (OpCode = OP_CODE_BRE) or  (OpCode = OP_CODE_BRNE) or  (OpCode = OP_CODE_BRG) or (OpCode = OP_CODE_BRL) or (OpCode = OP_CODE_JUMP) or (OpCode = OP_CODE_CALL) then 
			ImmediateOut := 0;
		else
			ImmediateOut := ImmediateIn;
		end if;

		if (OpCode = OP_CODE_JUMP) then
			PCOut := PCIn + ImmediateIn;
		elsif ((OpCode = OP_CODE_BRE) and (StatReg(0) = '1')) or ((OpCode = OP_CODE_BRNE) and (StatReg(0) = '0')) or ((OpCode = OP_CODE_BRG) and (StatReg(3) = '0')) or ((OpCode = OP_CODE_BRL) and (StatReg(3) = '1')) or (OpCode = OP_CODE_CALL) then
			PCOut := ImmediateIn;
		elsif (OpCode = OP_CODE_RET) then
			PCOut := PCCallIn;
		else
			PCOut := PCIn;
		end if;

		if (OpCode = OP_CODE_CALL) then
			PCCallOut := PCIn + INCR_PC;
		elsif (OpCode = OP_CODE_RET) then
			PCCallOut := 0;
		else
			PCCallOut := PCCallIn;
		end if;

		if (OpCode = OP_CODE_ALU_R) or (OpCode = OP_CODE_ALU_I) then
			CtrlOut := to_integer(unsigned(CTRL_CMD_ALU));
		elsif (OpCode = OP_CODE_WR_M) then
			CtrlOut := to_integer(unsigned(CTRL_CMD_WR_M));
		elsif (OpCode = OP_CODE_RD_M) then
			CtrlOut := to_integer(unsigned(CTRL_CMD_RD_M));
		elsif (OpCode = OP_CODE_WR_S) then
			CtrlOut := to_integer(unsigned(CTRL_CMD_WR_S));
		elsif (OpCode = OP_CODE_RD_S) then
			CtrlOut := to_integer(unsigned(CTRL_CMD_RD_S));
		elsif (OpCode = OP_CODE_MOV_R) or (OpCode = OP_CODE_MOV_I) or (OpCode = OP_CODE_SET) or (OpCode = OP_CODE_CLR) then
			CtrlOut := to_integer(unsigned(CTRL_CMD_MOV));
		else
			CtrlOut := to_integer(unsigned(CTRL_CMD_DISABLE));
		end if;

		if (OpCode = OP_CODE_EOP) then
			EndOfProg := True;
		else
			EndOfProg := False;
		end if;

	end procedure decode_ref;

	function op_code_std_vect_to_txt(OpCode: std_logic_vector(OP_CODE_L-1 downto 0)) return string is
		variable Op_Code_txt : string(1 to 4);
	begin
		if (OpCode = OP_CODE_MOV_R) then
			Op_Code_txt := "MOVR";
		elsif (OpCode = OP_CODE_MOV_I) then
			Op_Code_txt := "MOVI";
		elsif (OpCode = OP_CODE_ALU_R) then
			Op_Code_txt := "ALUR";
		elsif (OpCode = OP_CODE_ALU_I) then
			Op_Code_txt := "ALUI";
		elsif (OpCode = OP_CODE_BRE) then
			Op_Code_txt := "BRE ";
		elsif (OpCode = OP_CODE_BRNE) then
			Op_Code_txt := "BRNE";
		elsif (OpCode = OP_CODE_BRG) then
			Op_Code_txt := "BRG ";
		elsif (OpCode = OP_CODE_BRL) then
			Op_Code_txt := "BRL ";
		elsif (OpCode = OP_CODE_JUMP) then
			Op_Code_txt := "JUMP";
		elsif (OpCode = OP_CODE_CALL) then
			Op_Code_txt := "CALL";
		elsif (OpCode = OP_CODE_RD_S) then
			Op_Code_txt := "RD_S";
		elsif (OpCode = OP_CODE_WR_S) then
			Op_Code_txt := "WR_S";
		elsif (OpCode = OP_CODE_RD_M) then
			Op_Code_txt := "RD_M";
		elsif (OpCode = OP_CODE_WR_M) then
			Op_Code_txt := "WR_M";
		elsif (OpCode = OP_CODE_CLR) then
			Op_Code_txt := "CLR ";
		elsif (OpCode = OP_CODE_SET) then
			Op_Code_txt := "SET ";
		elsif (OpCode = OP_CODE_RET) then
			Op_Code_txt := "RET ";
		elsif (OpCode = OP_CODE_NOP) then
			Op_Code_txt := "NOP ";
		elsif (OpCode = OP_CODE_EOP) then
			Op_Code_txt := "EOP ";
		else
			Op_Code_txt := "UOPC";
		end if;

		return Op_Code_txt;

	end;

end package body decode_pkg_tb;
