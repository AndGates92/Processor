library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.alu_pkg.all;
use work.ctrl_pkg.all;
use work.cpu_tb_pkg.all;
use work.cpu_log_pkg.all;
use work.alu_pkg_tb.all;
use work.reg_file_pkg_tb.all;

package execute_pkg_tb is 

	procedure execute_ref(variable AddressIn_int, AddressOut1_int, AddressOut2_int : in integer; variable Immediate_int: in integer; variable CmdALU: in std_logic_vector(CMD_ALU_L-1 downto 0); variable CtrlCmd: in std_logic_vector(CTRL_CMD_L-1 downto 0); variable EnableRegFile_vec: in std_logic_vector(EN_REG_FILE_L_TB-1 downto 0); variable RegFileIn_int : in reg_file_array; variable RegFileOut_int : out reg_file_array; variable Op1, Op2 : out integer; variable StatusRegIn_int : in integer; variable StatusRegOut_int : out integer; variable ResOp_ideal: out integer);

end package execute_pkg_tb;

package body execute_pkg_tb is

	procedure execute_ref(variable AddressIn_int, AddressOut1_int, AddressOut2_int : in integer; variable Immediate_int: in integer; variable CmdALU: in std_logic_vector(CMD_ALU_L-1 downto 0); variable CtrlCmd: in std_logic_vector(CTRL_CMD_L-1 downto 0); variable EnableRegFile_vec: in std_logic_vector(EN_REG_FILE_L_TB-1 downto 0); variable RegFileIn_int : in reg_file_array; variable RegFileOut_int : out reg_file_array; variable Op1, Op2 : out integer; variable StatusRegIn_int : in integer; variable StatusRegOut_int : out integer; variable ResOp_ideal: out integer) is
		variable Done_int	: integer;
		variable Enable_int	: integer;
		variable DataOut1_int, DataOut2_int	: integer;
		variable Op1_int, Op2_int, ResOp	: integer;
		variable Ovfl_ideal, Unfl_ideal	: boolean;
		variable StatusReg_in	: integer;
		variable RegFileOut_op1_int	: reg_file_array;
		variable ResOp_vec	: std_logic_vector(OP1_L_TB + OP2_L_TB - 1 downto 0);
	begin
		ResOp := 0;
		Ovfl_ideal := False;
		Unfl_ideal := False;
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

			if (Unfl_ideal = True) then
				StatusReg_in := StatusReg_in + integer(2.0**(2.0));
			end if;
			if (Ovfl_ideal = True) then
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

end package body execute_pkg_tb;
