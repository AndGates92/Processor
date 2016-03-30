library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;
use work.alu_pkg.all;
use work.decode_pkg.all;
use work.ctrl_pkg.all;
use work.proc_pkg.all;
use work.tb_pkg.all;

entity decode_stage_tb is
end entity decode_stage_tb;

architecture bench of decode_stage_tb is

	constant CLK_PERIOD	: time := 10 ns;
	constant NUM_TEST	: integer := 1000;

	signal clk_tb	: std_logic := '0';
	signal stop	: boolean := false;
	signal rst_tb	: std_logic;

	signal INSTR_L_TB	: positive := 28;
	signal REG_NUM_TB	: positive := 16;
	signal REG_L_TB		: positive := 28;
	signal PC_L_TB		: positive := 28;
	signal STAT_REG_L_TB	: positive := 8;
	signal INCR_PC_TB	: positive := 4;
	signal EN_REG_FILE_L_TB	: positive := 3;

	signal NewInstr_tb	: std_logic;
	signal Instr_tb		: std_logic_vector(INSTR_L_TB - 1 downto 0);

	signal PCIn_tb		: std_logic_vector(PC_L_TB - 1 downto 0);
	signal StatusRegIn_tb	: std_logic_vector(STAT_REG_L_TB - 1 downto 0);

	signal AddressIn_tb	: std_logic_vector(count_length(REG_NUM_TB) - 1 downto 0);
	signal AddressOut1_tb	: std_logic_vector(count_length(REG_NUM_TB) - 1 downto 0);
	signal AddressOut2_tb	: std_logic_vector(count_length(REG_NUM_TB) - 1 downto 0);
	signal Immediate_tb	: std_logic_vector(REG_L_TB - 1 downto 0);
	signal EnableRegFile_tb	: std_logic_vector(EN_REG_FILE_L_TB - 1 downto 0);

	signal Done_tb		: std_logic;

	signal CmdALU_tb	: std_logic_vector(ALU_CMD_L - 1 downto 0);
	signal Ctrl_tb		: std_logic_vector(CTRL_CMD_L - 1 downto 0);

	signal PCOut_tb		: std_logic_vector(PC_L_TB - 1 downto 0);

	signal EndOfProg_tb	: std_logic;

begin

	DUT: decode_stage generic map (
		INSTR_L => INSTR_L_TB,
		REG_NUM => REG_NUM_TB,
		REG_L => REG_L_TB,
		PC_L => PC_L_TB,
		STAT_REG_L => STAT_REG_L_TB,
		INCR_PC => INCR_PC_TB,
		EN_REG_FILE_L => EN_REG_FILE_L_TB
	)
	port map (
		rst => rst_tb,
		clk => clk_tb,

		NewInstr => NewInstr_tb,
		Instr => Instr_tb,

		PCIn => PCin_tb,
		StatusRegIn => StatusRegIn_tb,

		AddressIn => AddressIn_tb,
		AddressOut1 => AddressOut1_tb,
		AddressOut2 => AddressOut2_tb,
		Immediate => Immediate_tb,
		EnableRegFile => EnableRegFile_tb,

		Done => Done_tb,

		CmdALU => CmdALU_tb,
		Ctrl => Ctrl_tb,

		PCOut => PCOut_tb,

		EndOfProg => EndOfProg_tb
	);

	clk_tb <= not clk_tb after CLK_PERIOD/2 when not stop;

	test: process

		procedure reset is
		begin
			rst_tb <= '0';
			wait until rising_edge(clk_tb);
			rst_tb <= '1';
			Instr_tb <= (others => '0');
			PCIn_tb <= (others => '0');
			StatusRegIn_tb <= (others => '0');
			NewInstr_tb <= '0';
			wait until rising_edge(clk_tb);
			rst_tb <= '0';
		end procedure reset;

		procedure push_op(variable ALU_func : out std_logic_vector(ALU_CMD_L - 1 downto 0); variable Immediate_int : out integer; variable OpCode: out std_logic_vector(OP_CODE_L - 1 downto 0); variable AddressIn_int, AddressOut1_int, AddressOut2_int : out integer; variable PCIn_int : out integer; variable StatusReg: out std_logic_vector(STAT_REG_L_TB-1 downto 0); variable EnableRegFile_int: out integer; variable seed1, seed2: inout positive) is
			variable Immediate_in, AddressIn_in, AddressOut1_in, AddressOut2_in, OpCode_in, ALU_func_in, PCIn_in, StatusReg_in	: integer;
			variable rand_val	: real;
			variable OpCode_vec	: std_logic_vector(OP_CODE_L - 1 downto 0);
			variable Immediate_vec	: std_logic_vector(REG_L_TB - 1 downto 0);
			variable AddressIn_vec	: std_logic_vector(count_length(REG_NUM_TB) - 1 downto 0);
			variable AddressOut1_vec	: std_logic_vector(count_length(REG_NUM_TB) - 1 downto 0);
			variable AddressOut2_vec	: std_logic_vector(count_length(REG_NUM_TB) - 1 downto 0);
			variable Instr_vec	: std_logic_vector(INSTR_L_TB - 1 downto 0);
			variable ALU_func_vec	: std_logic_vector(ALU_CMD_L - 1 downto 0);
		begin
			uniform(seed1, seed2, rand_val);
			StatusReg_in := integer(rand_val*(2.0**(real(STAT_REG_L_TB)) - 1.0));
			StatusRegIn_tb <= std_logic_vector(to_unsigned(StatusReg_in, STAT_REG_L_TB));
			StatusReg := std_logic_vector(to_unsigned(StatusReg_in, STAT_REG_L_TB));

			uniform(seed1, seed2, rand_val);
			PCIn_in := integer(rand_val*(2.0**(real(PC_L_TB)) - 1.0));
			PCIn_tb <= std_logic_vector(to_unsigned(PCIn_in, PC_L_TB));
			PCIn_int := PCIn_in;

			uniform(seed1, seed2, rand_val);
			OpCode_in := integer(rand_val*(2.0**(real(OP_CODE_L)) - 1.0));
			OpCode_vec := std_logic_vector(to_unsigned(OpCode_in, OP_CODE_L));
			OpCode := std_logic_vector(to_unsigned(OpCode_in, OP_CODE_L));

			uniform(seed1, seed2, rand_val);
			AddressIn_in := integer(rand_val*(2.0**(real(count_length(REG_NUM_TB)))- 1.0));
			AddressIn_vec := std_logic_vector(to_unsigned(AddressIn_in, count_length(REG_NUM_TB)));
			AddressIn_int := AddressIn_in;

			uniform(seed1, seed2, rand_val);
			AddressOut1_in := integer(rand_val*(2.0**(real(count_length(REG_NUM_TB)))- 1.0));
			AddressOut1_vec := std_logic_vector(to_unsigned(AddressOut1_in, count_length(REG_NUM_TB)));
			AddressOut1_int := AddressOut1_in;

			uniform(seed1, seed2, rand_val);
			AddressOut2_in := integer(rand_val*(2.0**(real(count_length(REG_NUM_TB)))- 1.0));
			AddressOut2_vec := std_logic_vector(to_unsigned(AddressOut2_in, count_length(REG_NUM_TB)));
			AddressOut2_int := AddressOut2_in;

			uniform(seed1, seed2, rand_val);
			ALU_func_in := integer(rand_val*(2.0**(real(ALU_CMD_L))- 1.0));
			ALU_func_vec := std_logic_vector(to_unsigned(ALU_func_in, ALU_CMD_L));
			ALU_func := ALU_func_vec;

			if ((OpCode_vec = OP_CODE_MOV_I) or (OpCode_vec = OP_CODE_RD_S) or (OpCode_vec = OP_CODE_RD_M)) then
				uniform(seed1, seed2, rand_val);
				Immediate_in := integer(rand_val*(2.0**(real(INSTR_L_TB - OP_CODE_L - count_length(REG_NUM_TB))) - 1.0));
				Immediate_vec := std_logic_vector(to_unsigned(Immediate_in, REG_L_TB));
				Immediate_int := Immediate_in;
				Instr_tb <= OpCode_vec & AddressIn_vec & Immediate_vec((INSTR_L_TB - OP_CODE_L - count_length(REG_NUM_TB) - 1) downto 0);
				AddressOut1_int := 0;
				AddressOut2_int := 0;
				ALU_func := std_logic_vector(to_unsigned(0, ALU_CMD_L));
				EnableRegFile_int := 1;
			elsif (OpCode_vec = OP_CODE_JUMP) or (OpCode_vec = OP_CODE_CALL) or (OpCode_vec = OP_CODE_BRE) or (OpCode_vec = OP_CODE_BRL) or (OpCode_vec = OP_CODE_BRG) or (OpCode_vec = OP_CODE_BRNE) then
				uniform(seed1, seed2, rand_val);
				Immediate_in := integer(rand_val*(2.0**(real(INSTR_L_TB - OP_CODE_L)) - 1.0));
				Immediate_vec := std_logic_vector(to_unsigned(Immediate_in, REG_L_TB));
				Immediate_int := Immediate_in;
				Instr_tb <= OpCode_vec & Immediate_vec((INSTR_L_TB - OP_CODE_L - 1) downto 0);
				AddressIn_int := 0;
				AddressOut1_int := 0;
				AddressOut2_int := 0;
				ALU_func := std_logic_vector(to_unsigned(0, ALU_CMD_L));
				EnableRegFile_int := 0;
			elsif (OpCode_vec = OP_CODE_WR_S) or (OpCode_vec = OP_CODE_WR_M) then
				uniform(seed1, seed2, rand_val);
				Immediate_in := integer(rand_val*(2.0**(real(INSTR_L_TB - OP_CODE_L - count_length(REG_NUM_TB))) - 1.0));
				Immediate_vec := std_logic_vector(to_unsigned(Immediate_in, REG_L_TB));
				Immediate_int := Immediate_in;
				Instr_tb <= OpCode_vec & AddressOut1_vec & Immediate_vec((INSTR_L_TB - OP_CODE_L - count_length(REG_NUM_TB) - 1) downto 0);
				AddressIn_int := 0;
				AddressOut2_int := 0;
				ALU_func := std_logic_vector(to_unsigned(0, ALU_CMD_L));
				EnableRegFile_int := 2;
			elsif (OpCode_vec = OP_CODE_MOV_R) then
				Immediate_in := 0;
				Instr_tb <= OpCode_vec & AddressIn_vec & AddressOut1_vec & std_logic_vector(to_unsigned(Immediate_in, (INSTR_L_TB - OP_CODE_L - 2*count_length(REG_NUM_TB))));
				Immediate_int := Immediate_in;
				AddressOut2_int := 0;
				ALU_func := std_logic_vector(to_unsigned(0, ALU_CMD_L));
				EnableRegFile_int := 2 + 1;
			elsif (OpCode_vec = OP_CODE_SET) or (OpCode_vec = OP_CODE_CLR) then
				Immediate_in := 0;
				Instr_tb <= OpCode_vec & AddressIn_vec & std_logic_vector(to_unsigned(Immediate_in, (INSTR_L_TB - OP_CODE_L - count_length(REG_NUM_TB))));
				Immediate_int := Immediate_in;
				AddressOut1_int := 0;
				AddressOut2_int := 0;
				ALU_func := std_logic_vector(to_unsigned(0, ALU_CMD_L));
				EnableRegFile_int := 1;
			elsif (OpCode_vec = OP_CODE_ALU_I) then
				uniform(seed1, seed2, rand_val);
				Immediate_in := integer(rand_val*(2.0**(real(INSTR_L_TB - OP_CODE_L - 2*count_length(REG_NUM_TB) - ALU_CMD_L)) - 1.0));
				Immediate_vec := std_logic_vector(to_unsigned(Immediate_in, REG_L_TB));
				Immediate_int := Immediate_in;
				Instr_tb <= OpCode_vec & AddressIn_vec & AddressOut1_vec & Immediate_vec((INSTR_L_TB - OP_CODE_L - 2*count_length(REG_NUM_TB) -ALU_CMD_L - 1) downto 0) & ALU_func_vec;
				AddressOut2_int := 0;
				EnableRegFile_int := 2 + 1;
			elsif (OpCode_vec = OP_CODE_ALU_R) then
				uniform(seed1, seed2, rand_val);
				Immediate_in := integer(rand_val*(2.0**(real(INSTR_L_TB - OP_CODE_L - 3*count_length(REG_NUM_TB) - ALU_CMD_L)) - 1.0));
				Immediate_vec := std_logic_vector(to_unsigned(Immediate_in, REG_L_TB));
				Immediate_int := Immediate_in;
				Instr_tb <= OpCode_vec & AddressIn_vec & AddressOut1_vec &  AddressOut2_vec & Immediate_vec((INSTR_L_TB - OP_CODE_L - 3*count_length(REG_NUM_TB) -ALU_CMD_L - 1) downto 0) & ALU_func_vec;
				EnableRegFile_int := 4 + 2 + 1;
			elsif (OpCode_vec = OP_CODE_RET) or (OpCode_vec = OP_CODE_NOP) then
				Immediate_in := 0;
				Instr_tb <= OpCode_vec & std_logic_vector(to_unsigned(Immediate_in, (INSTR_L_TB - OP_CODE_L)));
				Immediate_int := Immediate_in;
				AddressIn_int := 0;
				AddressOut1_int := 0;
				AddressOut2_int := 0;
				ALU_func := std_logic_vector(to_unsigned(0, ALU_CMD_L));
				EnableRegFile_int := 0;
			elsif (OpCode_vec = OP_CODE_EOP) then
				Immediate_in := 0;
				Immediate_vec := std_logic_vector(to_unsigned(Immediate_in, REG_L_TB));
				Instr_tb <= OpCode_vec & Immediate_vec((INSTR_L_TB - OP_CODE_L - 1) downto 0);
				AddressIn_int := 0;
				AddressOut1_int := 0;
				AddressOut2_int := 0;
				ALU_func := std_logic_vector(to_unsigned(0, ALU_CMD_L));
				Immediate_int := Immediate_in;
				EnableRegFile_int := 0;
			else
				Instr_tb <= std_logic_vector(to_unsigned(integer(2.0**(real(INSTR_L_TB)) - 1.0), INSTR_L_TB));
				AddressIn_int := 0;
				AddressOut1_int := 0;
				AddressOut2_int := 0;
				ALU_func := std_logic_vector(to_unsigned(0, ALU_CMD_L));
				Immediate_int := 0;
				EnableRegFile_int := 0;
			end if;

			NewInstr_tb <= '1';

			wait until rising_edge(clk_tb);
			NewInstr_tb <= '0';
		end procedure push_op;

		procedure reference(variable OpCode: in std_logic_vector(OP_CODE_L - 1 downto 0); variable ImmediateIn : in integer; variable PCIn, PCCallIn : in integer; variable StatReg : in std_logic_vector(STAT_REG_L_TB - 1 downto 0);variable ImmediateOut : out integer; variable PCOut, PCCallOut : out integer; variable CtrlOut : out integer; variable EndOfProg : out integer) is
		begin
			if (OpCode = OP_CODE_SET) then
				ImmediateOut := integer(2.0**(real(INSTR_L_TB)) - 1.0);
			elsif (OpCode = OP_CODE_CLR) or (OpCode = OP_CODE_BRE) or  (OpCode = OP_CODE_BRNE) or  (OpCode = OP_CODE_BRG) or (OpCode = OP_CODE_BRL) or (OpCode = OP_CODE_JUMP) or (OpCode = OP_CODE_CALL) then 
				ImmediateOut := 0;
			else
				ImmediateOut := ImmediateIn;
			end if;

			if (OpCode = OP_CODE_JUMP) then
				PCOut := PCIn + ImmediateIn;
			elsif ((OpCode = OP_CODE_BRE) and (StatReg(0) = '1')) or ((OpCode = OP_CODE_BRNE) and (StatReg(0) = '0')) or ((OpCode = OP_CODE_BRG) and (StatReg(4) = '0')) or ((OpCode = OP_CODE_BRL) and (StatReg(4) = '1')) or (OpCode = OP_CODE_CALL) then
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

		end procedure reference;

		procedure verify(variable ALU_func_ideal, ALU_func_rtl : in std_logic_vector(ALU_CMD_L - 1 downto 0); variable Immediate_ideal, Immediate_rtl : in integer; variable OpCode: in std_logic_vector(OP_CODE_L - 1 downto 0); variable OpCode_str: in string; variable AddressIn_ideal, AddressOut1_ideal, AddressOut2_ideal : in integer; variable AddressIn_rtl, AddressOut1_rtl, AddressOut2_rtl : in integer; variable PCOut_ideal, PCOut_rtl : in integer; variable CtrlOut_ideal, CtrlOut_rtl : in integer; variable EnableRegFile_ideal, EnableRegFile_rtl : in integer; variable EndOfProg_ideal, EndOfPRog_rtl : in integer; variable PCIn: in integer; file file_pointer : text; variable pass : out integer) is
			variable file_line	: line;
		begin

			write(file_line, "DECODE STAGE: Op code " & OpCode_str & " PC Input " & integer'image(PCIn)  &" decoding:");
			writeline(file_pointer, file_line);
			if (OpCode = OP_CODE_ALU_R) or (OpCode = OP_CODE_ALU_I) then
				write(file_line, "RTL => Immediate " & integer'image(Immediate_rtl) & " ALU function " & alu_cmd_std_vect_to_txt(ALU_func_rtl) & " AddressIn " & integer'image(AddressIn_rtl) & " AddressOut1 " & integer'image(AddressOut1_rtl) & " AddressOut2 " & integer'image(AddressOut2_rtl) & " PCOut " & integer'image(PCOut_rtl) &  " Ctrl " & integer'image(CtrlOut_rtl) & " Enable Reg File " & integer'image(EnableRegFile_rtl) & " End of program " & integer'image(EndOfProg_rtl));
				writeline(file_pointer, file_line);
				write(file_line, "Reference => Immediate " & integer'image(Immediate_ideal) & " ALU function " & alu_cmd_std_vect_to_txt(ALU_func_ideal) & " AddressIn " & integer'image(AddressIn_ideal) & " AddressOut1 " & integer'image(AddressOut1_ideal) & " AddressOut2 " & integer'image(AddressOut2_ideal) & " PCOut " & integer'image(PCOut_ideal) & " Ctrl " & integer'image(CtrlOut_ideal) & " Enable Reg File " & integer'image(EnableRegFile_ideal) & " End of program " & integer'image(EndOfProg_ideal));
				writeline(file_pointer, file_line);
			else
				write(file_line, "RTL => Immediate " & integer'image(Immediate_rtl) & " ALU function " & integer'image(to_integer(unsigned(ALU_func_rtl))) & " AddressIn " & integer'image(AddressIn_rtl) & " AddressOut1 " & integer'image(AddressOut1_rtl) & " AddressOut2 " & integer'image(AddressOut2_rtl) & " PCOut " & integer'image(PCOut_rtl) & " Ctrl " & integer'image(CtrlOut_rtl) & " Enable Reg File " & integer'image(EnableRegFile_rtl) & " End of program " & integer'image(EndOfProg_ideal));
				writeline(file_pointer, file_line);
				write(file_line, "Reference => Immediate " & integer'image(Immediate_ideal) & " ALU function " & integer'image(to_integer(unsigned(ALU_func_ideal))) & " AddressIn " & integer'image(AddressIn_ideal) & " AddressOut1 " & integer'image(AddressOut1_ideal) & " AddressOut2 " & integer'image(AddressOut2_ideal) & " PCOut " & integer'image(PCOut_ideal) & " Ctrl " & integer'image(CtrlOut_ideal) & " Enable Reg File " & integer'image(EnableRegFile_ideal) & " End of program " & integer'image(EndOfProg_ideal));
				writeline(file_pointer, file_line);
			end if;

			if (ALU_func_ideal = ALU_func_rtl) and (Immediate_ideal = Immediate_rtl) and (AddressIn_ideal = AddressIn_rtl) and (AddressOut1_ideal = AddressOut1_rtl) and (AddressOut2_ideal = AddressOut2_rtl) and (PCOut_ideal = PCOut_rtl)  and (CtrlOut_ideal = CtrlOut_rtl) and (EnableRegFile_ideal = EnableRegFile_rtl) then
				write(file_line, string'("PASS"));
				pass := 1;
			elsif (ALU_func_ideal /= ALU_func_rtl) then
				write(file_line, string'("FAIL (ALU function)"));
				pass := 0;
			elsif (Immediate_ideal /= Immediate_rtl) then
				write(file_line, string'("FAIL (Immediate)"));
				pass := 0;
			elsif (AddressIn_ideal /= AddressIn_rtl) then
				write(file_line, string'("FAIL (Address In)"));
				pass := 0;
			elsif (AddressOut1_ideal /= AddressOut1_rtl) then
				write(file_line, string'("FAIL (Address Out1)"));
				pass := 0;
			elsif (AddressOut2_ideal /= AddressOut2_rtl) then
				write(file_line, string'("FAIL (Address Out2)"));
				pass := 0;
			elsif (PCOut_ideal /= PCOut_rtl) then
				write(file_line, string'("FAIL (PC)"));
				pass := 0;
			elsif (CtrlOut_ideal /= CtrlOut_rtl) then
				write(file_line, string'("FAIL (Ctrl)"));
				pass := 0;
			elsif (EnableRegFile_ideal /= EnableRegFile_rtl) then
				write(file_line, string'("FAIL (Enable Reg File)"));
				pass := 0;
			elsif (EndOfProg_ideal /= EndOfProg_rtl) then
				write(file_line, string'("FAIL (End of program)"));
				pass := 0;
			else
				write(file_line, string'("FAIL (Unknown error)"));
				pass := 0;
			end if;
			writeline(file_pointer, file_line);
		end procedure verify;

		variable OpCode : std_logic_vector(OP_CODE_L - 1 downto 0);
		variable ALU_func_ideal : std_logic_vector(ALU_CMD_L - 1 downto 0);
		variable StatusReg: std_logic_vector(STAT_REG_L_TB-1 downto 0);
		variable Immediate_int_ideal, Immediate_int : integer;
		variable AddressIn_int_ideal, AddressOut1_int_ideal, AddressOut2_int_ideal : integer;
		variable Immediate_int_rtl : integer;
		variable ALU_func_rtl : std_logic_vector(ALU_CMD_L - 1 downto 0);
		variable AddressIn_int_rtl, AddressOut1_int_rtl, AddressOut2_int_rtl : integer;
		variable PCIn_int	: integer;
		variable PCOut_int_ideal,PCOut_int_rtl	: integer;
		variable CtrlOut_ideal,CtrlOut_rtl	: integer;
		variable PCCallIn,PCCallOut	: integer;
		variable EnRegFile_int_rtl, EnRegFile_int_ideal	: integer;
		variable EndOfProg_ideal,EndOfProg_rtl	: integer;
		variable seed1, seed2	: positive;
		variable pass	: integer;
		variable num_pass	: integer;

		file file_pointer	: text;
		variable file_line	: line;

	begin

		wait for 1 ns;

		num_pass := 0;

		reset;

		PCCallIn := 0;
		file_open(file_pointer, log_file, append_mode);

		write(file_line, string'( "Decode stage Test"));
		writeline(file_pointer, file_line);

		for i in 0 to NUM_TEST-1 loop
			push_op(ALU_func_ideal, Immediate_int, OpCode, AddressIn_int_ideal, AddressOut1_int_ideal, AddressOut2_int_ideal, PCIn_int, StatusReg, EnRegFile_int_ideal, seed1, seed2);

			wait on Done_tb;

			ALU_func_rtl := CmdALU_tb;
			AddressIn_int_rtl := to_integer(unsigned(AddressIn_tb));
			AddressOut1_int_rtl := to_integer(unsigned(AddressOut1_tb));
			AddressOut2_int_rtl := to_integer(unsigned(AddressOut2_tb));
			Immediate_int_rtl := to_integer(unsigned(Immediate_tb));
			EnRegFile_int_rtl := to_integer(unsigned(EnableRegFile_tb));
			PCOut_int_rtl := to_integer(unsigned(PCOut_tb));
			CtrlOut_rtl := to_integer(unsigned(Ctrl_tb));
			EndOfProg_rtl := std_logic_to_int(EndOfProg_tb);

			reference(OpCode, Immediate_int, PCIn_int, PCCallIn, StatusReg, Immediate_int_ideal, PCOut_int_ideal, PCCallOut, CtrlOut_ideal, EndOfProg_ideal);

			verify(ALU_func_ideal, ALU_func_rtl, Immediate_int_ideal, Immediate_int_rtl, OpCode, op_code_std_vect_to_txt(OpCode), AddressIn_int_ideal, AddressOut1_int_ideal, AddressOut2_int_ideal, AddressIn_int_rtl, AddressOut1_int_rtl, AddressOut2_int_rtl, PCOut_int_ideal, PCOut_int_rtl, CtrlOut_ideal, CtrlOut_rtl, EnRegFile_int_ideal, EnRegFile_int_rtl, EndOfProg_ideal, EndOfProg_rtl, PCIn_int, file_pointer, pass);

			PCCallIn := PCCallOut;

			num_pass := num_pass + pass;

			wait until rising_edge(clk_tb);
		end loop;

		file_close(file_pointer);

		file_open(file_pointer, summary_file, append_mode);
		write(file_line, "DECODE STAGE => PASSES: " & integer'image(num_pass) & " out of " & integer'image(NUM_TEST));
		writeline(file_pointer, file_line);
		file_close(file_pointer);

		stop <= true;

	end process test;
end bench;
