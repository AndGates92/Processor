library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.alu_pkg.all;
use work.ctrl_pkg.all;
use work.decode_pkg.all;
use work.proc_pkg.all;

package tb_pkg is 

	constant log_file	: string := "summary.log";
	constant summary_file	: string := "summary";


	constant STAT_REG_L_TB	: positive := 8;
	constant EN_REG_FILE_L_TB	: positive := 3;
	constant REG_NUM_TB	: positive := 4;
	constant OP1_L_TB	: integer := 16;
	constant OP2_L_TB	: integer := 16;
	constant INCR_PC_TB	: positive := 4;

	type reg_file_array is array(0 to REG_NUM_TB-1) of integer;

	procedure execute_ref(variable AddressIn_int, AddressOut1_int, AddressOut2_int : in integer; variable Immediate_int: in integer; variable CmdALU: in std_logic_vector(CMD_ALU_L-1 downto 0); variable CtrlCmd: in std_logic_vector(CTRL_CMD_L-1 downto 0); variable EnableRegFile_vec: in std_logic_vector(EN_REG_FILE_L_TB-1 downto 0); variable RegFileIn_int : in reg_file_array; variable RegFileOut_int : out reg_file_array; variable Op1, Op2 : out integer; variable StatusRegIn_int : in integer; variable StatusRegOut_int : out integer; variable ResOp_ideal: out integer);
	procedure decode_ref(variable OpCode: in std_logic_vector(OP_CODE_L - 1 downto 0); variable ImmediateIn : in integer; variable PCIn, PCCallIn : in integer; variable StatReg : in std_logic_vector(STAT_REG_L_TB - 1 downto 0);variable ImmediateOut : out integer; variable PCOut, PCCallOut : out integer; variable CtrlOut : out integer; variable EndOfProg : out integer);
	procedure reg_file_ref(variable RegFileIn_int: in reg_file_array; variable DataIn_int : in integer; variable AddressIn_int: in integer; variable AddressOut1_int : in integer; variable AddressOut2_int: in integer; variable Enable_int: in integer; variable Done_int: out integer; variable DataOut1_int: out integer; variable DataOut2_int : out integer; variable RegFileOut_int: out reg_file_array);
	procedure alu_ref(variable Op1_int : in integer; variable Op2_int: in integer; variable Cmd: in std_logic_vector(CMD_ALU_L-1 downto 0); variable Res_ideal: out integer; variable Ovfl_ideal : out integer; variable Unfl_ideal : out integer);

	function rand_num return real;
	function rand_bin(rand_val : real) return real;
	function rand_sign(sign_val : real) return real;
	function std_logic_to_int(val : std_logic) return integer;
	function alu_cmd_std_vect_to_txt (Cmd: std_logic_vector(CMD_ALU_L-1 downto 0)) return string;
	function full_alu_cmd_std_vect_to_txt (Cmd: std_logic_vector(CMD_ALU_L-1 downto 0)) return string;
	function ctrl_cmd_std_vect_to_txt(Cmd: std_logic_vector(CTRL_CMD_L-1 downto 0)) return string;
	function op_code_std_vect_to_txt(OpCode: std_logic_vector(OP_CODE_L-1 downto 0)) return string;

end package tb_pkg;

package body tb_pkg is

	procedure execute_ref(variable AddressIn_int, AddressOut1_int, AddressOut2_int : in integer; variable Immediate_int: in integer; variable CmdALU: in std_logic_vector(CMD_ALU_L-1 downto 0); variable CtrlCmd: in std_logic_vector(CTRL_CMD_L-1 downto 0); variable EnableRegFile_vec: in std_logic_vector(EN_REG_FILE_L_TB-1 downto 0); variable RegFileIn_int : in reg_file_array; variable RegFileOut_int : out reg_file_array; variable Op1, Op2 : out integer; variable StatusRegIn_int : in integer; variable StatusRegOut_int : out integer; variable ResOp_ideal: out integer) is
		variable Done_int	: integer;
		variable Enable_int	: integer;
		variable DataOut1_int, DataOut2_int	: integer;
		variable Op1_int, Op2_int, ResOp	: integer;
		variable Ovfl_ideal, Unfl_ideal	: integer;
		variable StatusReg_in	: integer;
		variable RegFileOut_op1_int	: reg_file_array;
		variable ResOp_vec	: std_logic_vector(OP1_L_TB + OP2_L_TB - 1 downto 0);
	begin
		ResOp := 0;
		Ovfl_ideal := 0;
		Unfl_ideal := 0;
		StatusReg_in := 0;
		Op1_int := 0;
		Op2_int := 0;
		RegFileOut_op1_int := RegFileIn_int;
		ResOp_vec := (others => '0');

		if (CtrlCmd = CTRL_CMD_ALU) then
			Enable_int := to_integer(unsigned(std_logic_vector(EnableRegFile_vec(EN_REG_FILE_L_TB-1 downto 1) & "0")));
			reg_file_ref(RegFileIn_int, Immediate_int, AddressIn_int, AddressOut1_int, AddressOut2_int, Enable_int, Done_int, DataOut1_int, DataOut2_int, RegFileOut_op1_int);
			Op1_int := DataOut1_int;
			if (EnableRegFile_vec(EN_REG_FILE_L_TB-1) = '1') then
				Op2_int := DataOut2_int;
			else
				Op2_int := Immediate_int;
			end if;

			if (CmdALU = CMD_ALU_SSUM) or (CmdALU = CMD_ALU_SSUB) or (CmdALU = CMD_ALU_SCMP) or (CmdALU = CMD_ALU_DIV) or (CmdALU = CMD_ALU_MUL) then
				if (Op1_int > 0) then
					Op1_int := to_integer(signed(to_unsigned(Op1_int, OP1_L_TB)));
				end if;
				if (Op2_int > 0) then
					Op2_int := to_integer(signed(to_unsigned(Op2_int, OP2_L_TB)));
				end if;
			else
				if (Op1_int < 0) then
					Op1_int := to_integer(unsigned(to_signed(Op1_int, OP1_L_TB)));
				end if;
				if (Op2_int < 0) then
					Op2_int := to_integer(unsigned(to_signed(Op2_int, OP2_L_TB)));
				end if;
			end if;


			if (CmdALU = CMD_ALU_MUL) then
				ResOp_vec := std_logic_vector(to_signed(Op1_int * Op2_int, OP1_L_TB+OP2_L_TB));
				ResOp := to_integer(unsigned(ResOp_vec(OP1_L_TB - 1 downto 0)));
			elsif (CmdALU = CMD_ALU_DIV) then
				if (Op1_int /= 0) and (Op2_int /= 0) then
					ResOp := integer(Op1_int/Op2_int);
				elsif (Op1_int = 0) and (Op2_int = 0) then
					ResOp := - 1;
				elsif (Op2_int = 0) and (Op1_int > 0) then
					ResOp := (2**(OP1_L_TB - 1)) - 1;
				elsif (Op2_int = 0) and (Op1_int < 0) then
					ResOp := -((2**(OP1_L_TB - 1)) - 1);
				elsif (Op1_int = 0) then
					ResOp := 0;
				else
					ResOp := 0;
				end if;
			else
				alu_ref(Op1_int, Op2_int, CmdALU, ResOp, Ovfl_ideal, Unfl_ideal);
			end if;
			Enable_int := to_integer(unsigned(std_logic_vector("00" & EnableRegFile_vec(0 downto 0))));
			reg_file_ref(RegFileOut_op1_int, ResOp, AddressIn_int, AddressOut1_int, AddressOut2_int, Enable_int, Done_int, DataOut1_int, DataOut2_int, RegFileOut_int);

			if (Unfl_ideal = 1) then
				StatusReg_in := StatusReg_in + integer(2.0**(2.0));
			end if;
			if (Ovfl_ideal = 1) then
				StatusReg_in := StatusReg_in + integer(2.0**(1.0));
			end if;

		else
			if (CtrlCmd = CTRL_CMD_WR_S) or (CtrlCmd = CTRL_CMD_WR_M) or (CtrlCmd = CTRL_CMD_MOV) then
				Enable_int := to_integer(unsigned(std_logic_vector(EnableRegFile_vec(EN_REG_FILE_L_TB-1 downto 1) & "0")));
				reg_file_ref(RegFileIn_int, Immediate_int, AddressIn_int, AddressOut1_int, AddressOut2_int, Enable_int, Done_int, DataOut1_int, DataOut2_int, RegFileOut_op1_int);
			end if;
			if (EnableRegFile_vec(1) = '1') and (CtrlCmd = CTRL_CMD_MOV) then -- move registers
				Op1_int := DataOut1_int;
			elsif (EnableRegFile_vec(1) = '0') and (CtrlCmd = CTRL_CMD_MOV) then -- store immediate in the register file
				Op1_int := Immediate_int;
			elsif (CtrlCmd = CTRL_CMD_RD_S) or (CtrlCmd = CTRL_CMD_RD_M) then -- read from the memory
				Op1_int := 0;
			else
				Op1_int := 0;
			end if;
			if (CtrlCmd = CTRL_CMD_RD_S) or (CtrlCmd = CTRL_CMD_RD_M) or (CtrlCmd = CTRL_CMD_MOV) then
				Enable_int := to_integer(unsigned(std_logic_vector("00" & EnableRegFile_vec(0 downto 0))));
				reg_file_ref(RegFileOut_op1_int, Op1_int, AddressIn_int, AddressOut1_int, AddressOut2_int, Enable_int, Done_int, DataOut1_int, DataOut2_int, RegFileOut_int);
			else
				RegFileOut_int := RegFileOut_op1_int;
			end if;
		end if;

		if (ResOp = 0) then
			StatusReg_in := StatusReg_in + 1;
		elsif ((ResOp < 0) or (ResOp > integer(2.0**(real(OP1_L_TB - 1))))) and ((CmdALU = CMD_ALU_SSUM) or (CmdALU = CMD_ALU_SSUB) or (CmdALU = CMD_ALU_SCMP) or (CmdALU = CMD_ALU_DIV) or (CmdALU = CMD_ALU_MUL)) then
			StatusReg_in := StatusReg_in + integer(2.0**(3.0));
		end if;

		if (CtrlCmd = CTRL_CMD_ALU) then
			StatusRegOut_int := StatusReg_in;
		else
			StatusRegOut_int := StatusRegIn_int;
		end if;

		if (ResOp < 0) then
			ResOp := to_integer(unsigned(to_signed(ResOp, OP1_L_TB)));
		end if;
		ResOp_ideal := ResOp;
		Op1 := Op1_int;
		Op2 := Op2_int;

	end procedure execute_ref;

	procedure decode_ref(variable OpCode: in std_logic_vector(OP_CODE_L - 1 downto 0); variable ImmediateIn : in integer; variable PCIn, PCCallIn : in integer; variable StatReg : in std_logic_vector(STAT_REG_L_TB - 1 downto 0);variable ImmediateOut : out integer; variable PCOut, PCCallOut : out integer; variable CtrlOut : out integer; variable EndOfProg : out integer) is
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
			PCCallOut := PCIn + INCR_PC_TB;
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
			EndOfProg := 1;
		else
			EndOfProg := 0;
		end if;

	end procedure decode_ref;

	procedure reg_file_ref(variable RegFileIn_int: in reg_file_array; variable DataIn_int : in integer; variable AddressIn_int: in integer; variable AddressOut1_int : in integer; variable AddressOut2_int: in integer; variable Enable_int: in integer; variable Done_int: out integer; variable DataOut1_int: out integer; variable DataOut2_int : out integer; variable RegFileOut_int: out reg_file_array) is
		variable Enable_vec	: std_logic_vector(EN_REG_FILE_L_TB - 1 downto 0);
		variable Done_tmp	: integer;
	begin

		Done_tmp := 0;
		RegFileOut_int := RegFileIn_int;
		Enable_vec := std_logic_vector(to_unsigned(Enable_int,EN_REG_FILE_L_TB));

		if (Enable_vec(1) = '1') then
			DataOut1_int := RegFileIn_int(AddressOut1_int);
			Done_tmp := Done_tmp + 1;
		else
			DataOut1_int := 0;
		end if;

		if (Enable_vec(2) = '1') then
			DataOut2_int := RegFileIn_int(AddressOut2_int);
			Done_tmp := Done_tmp + 2;
		else
			DataOut2_int := 0;
		end if;

		if (Enable_vec(0) = '1') then
			RegFileOut_int(AddressIn_int) := DataIn_int;
		end if;

		Done_int := Done_tmp;

	end procedure reg_file_ref;

	procedure alu_ref(variable Op1_int : in integer; variable Op2_int: in integer; variable Cmd: in std_logic_vector(CMD_ALU_L-1 downto 0); variable Res_ideal: out integer; variable Ovfl_ideal : out integer; variable Unfl_ideal : out integer) is
		variable tmp_op1	: std_logic_vector(OP1_L_TB-1 downto 0);
		variable tmp_op2	: std_logic_vector(OP2_L_TB-1 downto 0);
		variable tmp_res	: std_logic_vector(OP1_L_TB-1 downto 0);
		variable Res_tmp	: integer;
	begin
		Ovfl_ideal := 0;
		Unfl_ideal := 0;
		if (Cmd = CMD_ALU_USUM) then
			Res_tmp := Op1_int + Op2_int;
			Res_ideal := Res_tmp;
			if (Res_tmp > (2**(OP1_L_TB) - 1)) then
				Ovfl_ideal := 1;
				Res_ideal := Res_tmp - 2**(OP1_L_TB);
			end if;
		elsif (Cmd = CMD_ALU_SSUM) then
			Res_tmp := Op1_int + Op2_int;
			Res_ideal := Res_tmp;
			if (Res_tmp > (2**(OP1_L_TB-1) - 1)) then
				Ovfl_ideal := 1;
				Res_ideal := -2*(2**(OP1_L_TB-1)) + Res_tmp;
			elsif (Res_tmp < (-(2**(OP1_L_TB-1)))) then
				Unfl_ideal := 1;
				Res_ideal := 2*(2**(OP1_L_TB-1)) + Res_tmp;
			end if;
		elsif (Cmd = CMD_ALU_USUB) then
			Res_tmp := Op1_int - Op2_int;
			Res_ideal := Res_tmp;
			if (Res_tmp < 0) then
				Unfl_ideal := 1;
				Res_ideal := 2**(OP1_L_TB) + Res_tmp;
			end if;
		elsif (Cmd = CMD_ALU_SSUB) then
			Res_tmp := Op1_int - Op2_int;
			Res_ideal := Res_tmp;
			if (Res_tmp > (2**(OP1_L_TB-1) - 1)) then
				Ovfl_ideal := 1;
				Res_ideal := -2*(2**(OP1_L_TB-1)) + Res_tmp;
			elsif (Res_tmp < (-(2**(OP1_L_TB-1)))) then
				Unfl_ideal := 1;
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


	function rand_num return real is
		variable seed1, seed2	: positive;
		variable rand_val	: real;
	begin
		uniform(seed1, seed2, rand_val);
		return rand_val;
	end function;

	function rand_sign(sign_val : real) return real is
		variable sign 	: real;
	begin
		if (sign_val > 0.5) then
			sign := -1.0;
		else
			sign := 1.0;
		end if;

		return sign;
	end function;

	function rand_bin(rand_val : real) return real is
		variable bin 	: real;
	begin
		if (rand_val > 0.5) then
			bin := 0.0;
		else
			bin := 1.0;
		end if;

		return bin;
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



end package body tb_pkg;
