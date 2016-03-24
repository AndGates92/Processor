library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;

library work;
use work.alu_pkg.all;
use work.pipeline_pkg.all;

package tb_pkg is 

	function rand_num return real;
	function rand_sign(sign_val : real) return real;
	function std_logic_to_int(val : std_logic) return integer;
	function alu_cmd_std_vect_to_txt (Cmd: std_logic_vector(CMD_ALU_L-1 downto 0)) return string;
	function op_code_std_vect_to_txt(OpCode: std_logic_vector(OP_CODE_L-1 downto 0)) return string;

end package tb_pkg;

package body tb_pkg is

	function rand_num return real is
		variable seed1, seed2	: positive;
		variable rand_val	: real;
	begin
		uniform(seed1, seed2, rand_val);
		return rand_val;
	end function;

	function rand_sign(sign_val : real) return real is
		variable sign 	: real;
		variable rand_val	: real;
	begin
		if (sign_val > 0.5) then
			sign := -1.0;
		else
			sign := 1.0;
		end if;

		return sign;
	end function;

	function std_logic_to_int(val : std_logic) return integer is
		variable val_conv	: integer;
	begin
		if val = '1' then
			val_conv := 1;
		else
			val_conv := 0;
		end if;

		return val_conv;
	end;

	function alu_cmd_std_vect_to_txt(Cmd: std_logic_vector(CMD_ALU_L-1 downto 0)) return string is
		variable Cmd_txt : string(1 to 4);
	begin
		if (Cmd = CMD_USUM) then
			Cmd_txt := "USUM";
		elsif (Cmd = CMD_SSUM) then
			Cmd_txt := "SSUM";
		elsif (Cmd = CMD_USUB) then
			Cmd_txt := "USUB";
		elsif (Cmd = CMD_SSUB) then
			Cmd_txt := "SSUB";
		elsif (Cmd = CMD_UCMP) then
			Cmd_txt := "UCMP";
		elsif (Cmd = CMD_SCMP) then
			Cmd_txt := "SCMP";
		elsif (Cmd = CMD_AND) then
			Cmd_txt := "BAND";
		elsif (Cmd = CMD_OR) then
			Cmd_txt := "B_OR";
		elsif (Cmd = CMD_XOR) then
			Cmd_txt := "BXOR";
		elsif (Cmd = CMD_NOT) then
			Cmd_txt := "BNOT";
		else
			Cmd_txt := "UCMD";
		end if;

		return Cmd_txt;

	end;

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
		elsif (OpCode = OP_CODE_STR_S) then
			Op_Code_txt := "STRS";
		elsif (OpCode = OP_CODE_LD_S) then
			Op_Code_txt := "LD_S";
		elsif (OpCode = OP_CODE_STR_M) then
			Op_Code_txt := "STRM";
		elsif (OpCode = OP_CODE_LD_M) then
			Op_Code_txt := "LD_M";
		elsif (OpCode = OP_CODE_CLR) then
			Op_Code_txt := "CLR ";
		elsif (OpCode = OP_CODE_SET) then
			Op_Code_txt := "SET ";
		elsif (OpCode = OP_CODE_RET) then
			Op_Code_txt := "RET ";
		elsif (OpCode = OP_CODE_NOP) then
			Op_Code_txt := "NOP ";
		else
			Op_Code_txt := "UOPC";
		end if;

		return Op_Code_txt;

	end;



end package body tb_pkg;
