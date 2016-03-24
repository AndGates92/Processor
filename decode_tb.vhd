library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.alu_pkg.all;
use work.pipeline_pkg.all;
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

	signal INSTR_L_TB	: positive := 32;
	signal REG_NUM_TB	: positive := 16;
	signal REG_L_TB		: positive := 32;
	signal PC_L_TB		: positive := 32;
	signal STAT_REG_L_TB	: positive := 8;
	signal INCR_PC_TB	: positive := 4;
	signal CTRL_L_TB	: positive := 3;
	signal EN_REG_FILE_L_TB	: positive := 3;

	signal NewInstr_tb	: std_logic;
	signal Instr_tb		: std_logic_vector(INSTR_L_TB - 1 downto 0);

	signal PCIn_tb		: std_logic_vector(PC_L_TB - 1 downto 0);
	signal StatusRegIn_tb	: std_logic_vector(STAT_REG_L_TB - 1 downto 0);

	signal AddressIn_tb	: std_logic_vector(count_length(REG_NUM_TB) - 1 downto 0);
	signal AddressOut1_tb	: std_logic_vector(count_length(REG_NUM_TB) - 1 downto 0);
	signal AddressOut2_tb	: std_logic_vector(count_length(REG_NUM_TB) - 1 downto 0);
	signal Immediate_tb	: std_logic_vector(REG_L_TB - 1 downto 0);
	signal Enable_reg_file_tb	: std_logic_vector(EN_REG_FILE_L_TB - 1 downto 0);

	signal Done_tb		: std_logic;

	signal CmdALU_tb	: std_logic_vector(CMD_L - 1 downto 0);
	signal Ctrl_tb		: std_logic_vector(CTRL_L_TB - 1 downto 0);

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
		CTRL_L => CTRL_L_TB,
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
		Enable_reg_file => Enable_reg_file_tb,

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
			StatusRegIn <= (others => '0');
			NewInstr_tb <= '0';
			wait until rising_edge(clk_tb);
			rst_tb <= '0';
		end procedure reset;

		procedure push_op(variable ALU_func : out std_logic_vector(CMD_ALU_L - 1 downto 0); variable Immediate_int : out integer; variable OpCode: out std_logic_vector(OP_CODE_L); variable RegIn_int, RegOut1_int, RegOut2_int : out integer; variable PCIn_int : out integer; variable StatusReg: out std_logic_vector(STATUS_REG_L_TB-1 downto 0); variable seed1, seed2: inout positive) is
			variable Immediate_in, RegIn_in, RegOut1_in, RegOut2_in, OpCode_in, ALU_func_in, PCIn_in, StatusReg_in	: integer;
			variable rand_val	: real;
			variable OpCode_vec	: std_logic_vector(OP_CODE_L - 1 downto 0);
			variable Immediate_vec	: std_logic_vector(REG_L_TB - 1 downto 0);
			variable RegIn_vec	: std_logic_vector(count_length(REG_NUM_TB) - 1 downto 0);
			variable RegOut1_vec	: std_logic_vector(count_length(REG_NUM_TB) - 1 downto 0);
			variable RegOut2_vec	: std_logic_vector(count_length(REG_NUM_TB) - 1 downto 0);
			variable Instr_vec	: std_logic_vector(INSTR_L_TB - 1 downto 0);
			variable ALU_func_vec	: std_logic_vector(CMD_ALU_L - 1 downto 0);
		begin
			uniform(seed1, seed2, rand_val);
			StatusReg_in := integer(rand_val*(2.0**(real(STAT_REG_L_TB)) - 1.0));
			StatusReg_tb <= std_logic_vector(to_unsigned(StatReg_in, STAT_REG_L_TB));
			StatusReg := std_logic_vector(to_unsigned(StatReg_in_in, STAT_REG_L_TB));

			uniform(seed1, seed2, rand_val);
			PCIn_in := integer(rand_val*(2.0**(real(PC_L_TB)) - 1.0));
			PCIn_tb <= std_logic_vector(to_unsigned(StatReg_in, PC_L_TB));
			PCIn_int := PCIn_in;

			uniform(seed1, seed2, rand_val);
			OpCode_in := integer(rand_val*(2.0**(real(STAT_REG_L_TB)) - 1.0));
			OpCode_vec := std_logic_vector(to_unsigned(OpCode_in, OP_CODE_L));
			OpCode := std_logic_vector(to_unsigned(OpCode_in, OP_CODE_L));

			uniform(seed1, seed2, rand_val);
			OpCode_in := integer(rand_val*(2.0**(real(OP_CODE_L)) - 1.0));
			OpCode_vec := std_logic_vector(to_unsigned(OpCode_in, OP_CODE_L));
			OpCode := std_logic_vector(to_unsigned(OpCode_in, OP_CODE_L));

			uniform(seed1, seed2, rand_val);
			RegIn_in := integer(rand_val*(2.0**(real(count_length(REG_NUM)))- 1.0));
			RegIn_vec := std_logic_vector(to_unsigned(RegIn_in, count_length(REG_NUM)));
			RegIn_int := RegIn_in;

			uniform(seed1, seed2, rand_val);
			RegOut1_in := integer(rand_val*(2.0**(real(count_length(REG_NUM)))- 1.0));
			RegOut1_vec := std_logic_vector(to_unsigned(RegOut1_in, count_length(REG_NUM)));
			RegOut1_int := RegOut1_in;

			uniform(seed1, seed2, rand_val);
			RegOut2_in := integer(rand_val*(2.0**(real(count_length(REG_NUM)))- 1.0));
			RegOut2_vec := std_logic_vector(to_unsigned(RegOut2_in, count_length(REG_NUM)));
			RegOut2_int := RegOut2_in;

			uniform(seed1, seed2, rand_val);
			ALU_func_in := integer(rand_val*(2.0**(real(CMD_ALU_L))- 1.0));
			ALU_func_vec := std_logic_vector(to_unsigned(ALU_func_in, CMD_ALU_L));
			ALU_func := ALU_func_vec;

			if (OpCode_int = OP_CODE_MOV_I) or OpCode_int = OP_CODE_STR_S) or (OpCode_int = OP_CODE_STR_M) then
				uniform(seed1, seed2, rand_val);
				Immediate_in := integer(rand_val*(2.0**(real(INSTR_L_TB - OP_CODE_L - count_length(REG_NUM))) - 1.0));
				Immediate_vec := std_logic_vector(to_unsigned(Immediate_in, REG_L_TB));
				Immediate_int := Immediate_in;
				Instr_tb <= OpCode_vec & RegIn_vec & Immediate_vec((INSTR_L_TB - OP_CODE_L - count_length(REG_NUM) - 1) downto 0);
				RegOut1_int := 0;
				RegOut2_int := 0;
				ALU_func := (others => 0);
			elsif (OpCode_int = OP_CODE_JUMP) or OpCode_int = OP_CODE_CALL) or (OpCode_int = OP_CODE_BRE) or (OpCode_int = OP_CODE_BRL) or OpCode_int = OP_CODE_BRG) or (OpCode_int = OP_CODE_BRNE) then
				uniform(seed1, seed2, rand_val);
				Immediate_in := integer(rand_val*(2.0**(real(INSTR_L_TB - OP_CODE_L)) - 1.0));
				Immediate_vec := std_logic_vector(to_unsigned(Immediate_in, REG_L_TB));
				Immediate_int := Immediate_in;
				Instr_tb <= OpCode_vec & Immediate_vec((INSTR_L_TB - OP_CODE_L - 1) downto 0);
				RegIn_int := 0;
				RegOut1_int := 0;
				RegOut2_int := 0;
				ALU_func := (others => 0);
			elsif (OpCode_int = OP_CODE_LD_S) or (OpCode_int = OP_CODE_LD_M) then
				uniform(seed1, seed2, rand_val);
				Immediate_in := integer(rand_val*(2.0**(real(INSTR_L_TB - OP_CODE_L - count_length(REG_NUM))) - 1.0));
				Immediate_vec := std_logic_vector(to_unsigned(Immediate_in, REG_L_TB));
				Immediate_int := Immediate_in;
				Instr_tb <= OpCode_vec & RegOut1_vec & Immediate_vec((INSTR_L_TB - OP_CODE_L - count_length(REG_NUM) - 1) downto 0);
				RegIn_int := 0;
				RegOut2_int := 0;
				ALU_func := (others => 0);
			elsif (OpCode_int = OP_CODE_MOV_R) then
				Immediate_int := 0;
				Instr_tb <= OpCode_vec & RegIn_vec & RegOut1_vec & std_logic_vector(to_unsigned(Immediate_in, (INSTR_L_TB - OP_CODE_L - 2*count_length(REG_NUM))));
				RegOut2_int := 0;
				ALU_func :=(others =>  0);
			elsif (OpCode_int = OP_CODE_SET) or (OpCode_int = OP_CODE_CLR) then
				Immediate_int := 0;
				Instr_tb <= OpCode_vec & RegOut1_vec & std_logic_vector(to_unsigned(Immediate_in, (INSTR_L_TB - OP_CODE_L - count_length(REG_NUM))));
				RegIn_int := 0;
				RegOut2_int := 0;
				ALU_func := (others => 0);
			elsif (OpCode_int = OP_CODE_ALU_I) then
				uniform(seed1, seed2, rand_val);
				Immediate_in := integer(rand_val*(2.0**(real(INSTR_L_TB - OP_CODE_L - 2*count_length(REG_NUM) - CMD_ALU_L)) - 1.0));
				Immediate_vec := std_logic_vector(to_unsigned(Immediate_in, REG_L_TB));
				Immediate_int := Immediate_in;
				Instr_tb <= OpCode_vec & RegIn_vec & RegOut1_vec & Immediate_vec((INSTR_L_TB - OP_CODE_L - 2*count_length(REG_NUM) -CMD_ALU_L - 1) downto 0) & ALU_func_vec;
				RegOut2_int := 0;
			elsif (OpCode_int = OP_CODE_ALU_R) then
				uniform(seed1, seed2, rand_val);
				Immediate_in := integer(rand_val*(2.0**(real(INSTR_L_TB - OP_CODE_L - 3*count_length(REG_NUM) - CMD_ALU_L)) - 1.0));
				Immediate_vec := std_logic_vector(to_unsigned(Immediate_in, REG_L_TB));
				Immediate_int := Immediate_in;
				Instr_tb <= OpCode_vec & RegIn_vec & RegOut1_vec &  RegOut2_vec & Immediate_vec((INSTR_L_TB - OP_CODE_L - 3*count_length(REG_NUM) -CMD_ALU_L - 1) downto 0) & ALU_func_vec;
			elsif (OpCode_int = OP_CODE_RET) or (OpCode_int = OP_CODE_NOP) then
				Immediate_int := 0;
				Instr_tb <= OpCode_vec & std_logic_vector(to_unsigned(Immediate_in, (INSTR_L_TB - OP_CODE_L)));
				RegIn_int := 0;
				RegOut1_int := 0;
				RegOut2_int := 0;
				ALU_func := (others => 0);
			else
				Instr_tb <= (others => '1');
				RegIn_int := 0;
				RegOut1_int := 0;
				RegOut2_int := 0;
				ALU_func := (others => 0);
				Immediate_int := 0;
			end if;

			NewInstr_tb <= '1';

			wait until rising_edge(clk_tb);
			NewInstr_tb <= '0';
		end procedure push_op;

		procedure reference(variable OpCode: in std_logic_vector(OP_CODE_L - 1 downto 0); variable ImmediateIn : in integer; variable PCIn, PCCallIn : in integer; variable StatReg : in std_logic_vector(STAT_REG_L_TB - 1 downto 0);variable ImmediateOut : out integer; variable PCOut, PCCallOut : out integer) is
		begin
			ImmediateOut <=	(2.0**(real(INSTR_L_TB - OP_CODE_L - count_length(REG_NUM))) - 1.0) when OpCode = OP_CODE_SET else
					0 when (OpCode = OP_CODE_CLR) or (OpCode = OP_CODE_BRE) or  (OpCode = OP_CODE_BRNE) or  (OpCode = OP_CODE_BRG) or (OpCode = OP_CODE_BRL) or (OpCode = OP_CODE_JUMP) or (OpCode = OP_CODE_CALL) else
					ImmediateIn;

			PCOut <=	PCIn + ImmediateIn	when OpCode = OP_CODE_JUMP else
					ImmediateIn		when ((OpCode = OP_CODE_BRE) and (StatReg(0) = '1')) or ((OpCode = OP_CODE_BRNE) and (StatReg(0) = '0')) or  ((OpCode = OP_CODE_BRG) and (StatReg(4) = '0')) or ((OpCode = OP_CODE_BRL) or (OpCode = OP_CODE_CALL) and (StatReg(4) = '1')) else
					PCCallIn		when OpCode = OP_CODE_RET else
					0;

			PCCallOut <=	PCIn + INCR_PC_TB	when OpCode = OP_CODE_CALL else
					0			when OpCode = OP_CODE_RET else
					PCCallIn;
		end procedure reference;

		procedure verify(variable ALU_func_ideal, ALU_func_rtl : out std_logic_vector(CMD_ALU_L - 1 downto 0); variable Immediate_ideal, Immediate_rtl : in integer; variable OpCode: in string; variable RegIn_ideal, RegOut1_ideal, RegOut2_ideal : in integer; variable RegIn_ideal, RegOut1_ideal, RegOut2_rtl : in integer; variable PCOut_ideal, PCOut_rtl : in integer; variable pass : out integer) is
		begin
			if (ALU_func_ideal = ALU_func_rtl) and (Immediate_ideal = Immediate_rtl) and (RegIn_ideal = RegIn_rtl) and (RegOut1_ideal = RegOut1_rtl) and (RegOut2_ideal = RegOut2_rtl) and (PCOut_ideal = PCOut_rtl) then
				if (OpCode = OP_CODE_ALU_R) or (OpCode = OP_CODE_ALU_I) then
					report "Op code " & OpCode & " decoding: RTL => Immediate" & integer'image(Immediate_rtl) & " ALU function " & alu_cmd_std_vect_to_txt(ALU_func_rtl) & " RegIn " & integer'image(RegIn_rtl) & " RegOut1 " & integer'image(RegOut1_rtl) & " RegOut2 " & integer'image(RegOut2_rtl) & " PCOut1 " & integer'image(PCOut_rtl) & "reference => Immediate" & integer'image(Immediate_rtl) & " ALU function " & alu_cmd_std_vect_to_txt(ALU_func_ideal) & " RegIn " & integer'image(RegIn_ideal) & " RegOut1 " & integer'image(RegOut1_ideal) & " RegOut2 " & integer'image(RegOut2_ideal) & " PCOut1 " & integer'image(PCOut_ideal) & ": PASSED";
				else
					report "Op code " & OpCode & " decoding: RTL => Immediate" & integer'image(Immediate_rtl) & " ALU function " & integer'image(to_integer(unsigned(ALU_func_rtl))) & " RegIn " & integer'image(RegIn_rtl) & " RegOut1 " & integer'image(RegOut1_rtl) & " RegOut2 " & integer'image(RegOut2_rtl) & " PCOut1 " & integer'image(PCOut_rtl) & "reference => Immediate" & integer'image(Immediate_rtl) & " ALU function " & integer'image(to_integer(unsigned(ALU_func_ideal))) & " RegIn " & integer'image(RegIn_ideal) & " RegOut1 " & integer'image(RegOut1_ideal) & " RegOut2 " & integer'image(RegOut2_ideal) & " PCOut1 " & integer'image(PCOut_ideal) & ": PASSED";
				end if;
				pass := 1;
			elsif (ALU_func_ideal /= ALU_func_rtl) then
				if (OpCode = OP_CODE_ALU_R) or (OpCode = OP_CODE_ALU_I) then
					report "Op code " & OpCode & " decoding: RTL => Immediate" & integer'image(Immediate_rtl) & " ALU function " & alu_cmd_std_vect_to_txt(ALU_func_rtl) & " RegIn " & integer'image(RegIn_rtl) & " RegOut1 " & integer'image(RegOut1_rtl) & " RegOut2 " & integer'image(RegOut2_rtl) & " PCOut1 " & integer'image(PCOut_rtl) & "reference => Immediate" & integer'image(Immediate_rtl) & " ALU function " & alu_cmd_std_vect_to_txt(ALU_func_ideal) & " RegIn " & integer'image(RegIn_ideal) & " RegOut1 " & integer'image(RegOut1_ideal) & " RegOut2 " & integer'image(RegOut2_ideal) & " PCOut1 " & integer'image(PCOut_ideal) & ": FAILED (ALU function)" severity warning;
				else
					report "Op code " & OpCode & " decoding: RTL => Immediate" & integer'image(Immediate_rtl) & " ALU function " & integer'image(to_integer(unsigned(ALU_func_rtl))) & " RegIn " & integer'image(RegIn_rtl) & " RegOut1 " & integer'image(RegOut1_rtl) & " RegOut2 " & integer'image(RegOut2_rtl) & " PCOut1 " & integer'image(PCOut_rtl) & "reference => Immediate" & integer'image(Immediate_rtl) & " ALU function " & integer'image(to_integer(unsigned(ALU_func_ideal))) & " RegIn " & integer'image(RegIn_ideal) & " RegOut1 " & integer'image(RegOut1_ideal) & " RegOut2 " & integer'image(RegOut2_ideal) & " PCOut1 " & integer'image(PCOut_ideal) & ": FAILED (ALU function)" severity warning;
				end if;
				pass := 0;
			elsif (Immediate_ideal /= Immediate_rtl) then
				if (OpCode = OP_CODE_ALU_R) or (OpCode = OP_CODE_ALU_I) then
					report "Op code " & OpCode & " decoding: RTL => Immediate" & integer'image(Immediate_rtl) & " ALU function " & alu_cmd_std_vect_to_txt(ALU_func_rtl) & " RegIn " & integer'image(RegIn_rtl) & " RegOut1 " & integer'image(RegOut1_rtl) & " RegOut2 " & integer'image(RegOut2_rtl) & " PCOut1 " & integer'image(PCOut_rtl) & "reference => Immediate" & integer'image(Immediate_rtl) & " ALU function " & alu_cmd_std_vect_to_txt(ALU_func_ideal) & " RegIn " & integer'image(RegIn_ideal) & " RegOut1 " & integer'image(RegOut1_ideal) & " RegOut2 " & integer'image(RegOut2_ideal) & " PCOut1 " & integer'image(PCOut_ideal) & ": FAILED (Immediate)" severity warning;
				else
					report "Op code " & OpCode & " decoding: RTL => Immediate" & integer'image(Immediate_rtl) & " ALU function " & integer'image(to_integer(unsigned(ALU_func_rtl))) & " RegIn " & integer'image(RegIn_rtl) & " RegOut1 " & integer'image(RegOut1_rtl) & " RegOut2 " & integer'image(RegOut2_rtl) & " PCOut1 " & integer'image(PCOut_rtl) & "reference => Immediate" & integer'image(Immediate_rtl) & " ALU function " & integer'image(to_integer(unsigned(ALU_func_ideal))) & " RegIn " & integer'image(RegIn_ideal) & " RegOut1 " & integer'image(RegOut1_ideal) & " RegOut2 " & integer'image(RegOut2_ideal) & " PCOut1 " & integer'image(PCOut_ideal) & ": FAILED (Immediate)" severity warning;
				end if;
				pass := 0;
			elsif (RegIn_ideal /= RegIn_rtl) then
				if (OpCode = OP_CODE_ALU_R) or (OpCode = OP_CODE_ALU_I) then
					report "Op code " & OpCode & " decoding: RTL => Immediate" & integer'image(Immediate_rtl) & " ALU function " & alu_cmd_std_vect_to_txt(ALU_func_rtl) & " RegIn " & integer'image(RegIn_rtl) & " RegOut1 " & integer'image(RegOut1_rtl) & " RegOut2 " & integer'image(RegOut2_rtl) & " PCOut1 " & integer'image(PCOut_rtl) & "reference => Immediate" & integer'image(Immediate_rtl) & " ALU function " & alu_cmd_std_vect_to_txt(ALU_func_ideal) & " RegIn " & integer'image(RegIn_ideal) & " RegOut1 " & integer'image(RegOut1_ideal) & " RegOut2 " & integer'image(RegOut2_ideal) & " PCOut1 " & integer'image(PCOut_ideal) & ": FAILED (Register In)" severity warning;
				else
					report "Op code " & OpCode & " decoding: RTL => Immediate" & integer'image(Immediate_rtl) & " ALU function " & integer'image(to_integer(unsigned(ALU_func_rtl))) & " RegIn " & integer'image(RegIn_rtl) & " RegOut1 " & integer'image(RegOut1_rtl) & " RegOut2 " & integer'image(RegOut2_rtl) & " PCOut1 " & integer'image(PCOut_rtl) & "reference => Immediate" & integer'image(Immediate_rtl) & " ALU function " & integer'image(to_integer(unsigned(ALU_func_ideal))) & " RegIn " & integer'image(RegIn_ideal) & " RegOut1 " & integer'image(RegOut1_ideal) & " RegOut2 " & integer'image(RegOut2_ideal) & " PCOut1 " & integer'image(PCOut_ideal) & ": FAILED (Register In)" severity warning;
				end if;
				pass := 0;
			elsif (RegOut1_ideal /= RegOut1_rtl) then
				if (OpCode = OP_CODE_ALU_R) or (OpCode = OP_CODE_ALU_I) then
					report "Op code " & OpCode & " decoding: RTL => Immediate" & integer'image(Immediate_rtl) & " ALU function " & alu_cmd_std_vect_to_txt(ALU_func_rtl) & " RegIn " & integer'image(RegIn_rtl) & " RegOut1 " & integer'image(RegOut1_rtl) & " RegOut2 " & integer'image(RegOut2_rtl) & " PCOut1 " & integer'image(PCOut_rtl) & "reference => Immediate" & integer'image(Immediate_rtl) & " ALU function " & alu_cmd_std_vect_to_txt(ALU_func_ideal) & " RegIn " & integer'image(RegIn_ideal) & " RegOut1 " & integer'image(RegOut1_ideal) & " RegOut2 " & integer'image(RegOut2_ideal) & " PCOut1 " & integer'image(PCOut_ideal) & ": FAILED (Register Out1)" severity warning;
				else
					report "Op code " & OpCode & " decoding: RTL => Immediate" & integer'image(Immediate_rtl) & " ALU function " & integer'image(to_integer(unsigned(ALU_func_rtl))) & " RegIn " & integer'image(RegIn_rtl) & " RegOut1 " & integer'image(RegOut1_rtl) & " RegOut2 " & integer'image(RegOut2_rtl) & " PCOut1 " & integer'image(PCOut_rtl) & "reference => Immediate" & integer'image(Immediate_rtl) & " ALU function " & integer'image(to_integer(unsigned(ALU_func_ideal))) & " RegIn " & integer'image(RegIn_ideal) & " RegOut1 " & integer'image(RegOut1_ideal) & " RegOut2 " & integer'image(RegOut2_ideal) & " PCOut1 " & integer'image(PCOut_ideal) & ": FAILED (Register Out1)" severity warning;
				end if;
				pass := 0;
			elsif (RegOut2_ideal /= RegOut2_rtl) then
				if (OpCode = OP_CODE_ALU_R) or (OpCode = OP_CODE_ALU_I) then
					report "Op code " & OpCode & " decoding: RTL => Immediate" & integer'image(Immediate_rtl) & " ALU function " & alu_cmd_std_vect_to_txt(ALU_func_rtl) & " RegIn " & integer'image(RegIn_rtl) & " RegOut1 " & integer'image(RegOut1_rtl) & " RegOut2 " & integer'image(RegOut2_rtl) & " PCOut1 " & integer'image(PCOut_rtl) & "reference => Immediate" & integer'image(Immediate_rtl) & " ALU function " & alu_cmd_std_vect_to_txt(ALU_func_ideal) & " RegIn " & integer'image(RegIn_ideal) & " RegOut1 " & integer'image(RegOut1_ideal) & " RegOut2 " & integer'image(RegOut2_ideal) & " PCOut1 " & integer'image(PCOut_ideal) & ": FAILED (Register Out2)" severity warning;
				else
					report "Op code " & OpCode & " decoding: RTL => Immediate" & integer'image(Immediate_rtl) & " ALU function " & integer'image(to_integer(unsigned(ALU_func_rtl))) & " RegIn " & integer'image(RegIn_rtl) & " RegOut1 " & integer'image(RegOut1_rtl) & " RegOut2 " & integer'image(RegOut2_rtl) & " PCOut1 " & integer'image(PCOut_rtl) & "reference => Immediate" & integer'image(Immediate_rtl) & " ALU function " & integer'image(to_integer(unsigned(ALU_func_ideal))) & " RegIn " & integer'image(RegIn_ideal) & " RegOut1 " & integer'image(RegOut1_ideal) & " RegOut2 " & integer'image(RegOut2_ideal) & " PCOut1 " & integer'image(PCOut_ideal) & ": FAILED (Register Out2)" severity warning;
				end if;
				pass := 0;
			elsif (PCOut_ideal /= PCOut_rtl) then
				if (OpCode = OP_CODE_ALU_R) or (OpCode = OP_CODE_ALU_I) then
					report "Op code " & OpCode & " decoding: RTL => Immediate" & integer'image(Immediate_rtl) & " ALU function " & alu_cmd_std_vect_to_txt(ALU_func_rtl) & " RegIn " & integer'image(RegIn_rtl) & " RegOut1 " & integer'image(RegOut1_rtl) & " RegOut2 " & integer'image(RegOut2_rtl) & " PCOut1 " & integer'image(PCOut_rtl) & "reference => Immediate" & integer'image(Immediate_rtl) & " ALU function " & alu_cmd_std_vect_to_txt(ALU_func_ideal) & " RegIn " & integer'image(RegIn_ideal) & " RegOut1 " & integer'image(RegOut1_ideal) & " RegOut2 " & integer'image(RegOut2_ideal) & " PCOut1 " & integer'image(PCOut_ideal) & ": FAILED (PC)" severity warning;
				else
					report "Op code " & OpCode & " decoding: RTL => Immediate" & integer'image(Immediate_rtl) & " ALU function " & integer'image(to_integer(unsigned(ALU_func_rtl))) & " RegIn " & integer'image(RegIn_rtl) & " RegOut1 " & integer'image(RegOut1_rtl) & " RegOut2 " & integer'image(RegOut2_rtl) & " PCOut1 " & integer'image(PCOut_rtl) & "reference => Immediate" & integer'image(Immediate_rtl) & " ALU function " & integer'image(to_integer(unsigned(ALU_func_ideal))) & " RegIn " & integer'image(RegIn_ideal) & " RegOut1 " & integer'image(RegOut1_ideal) & " RegOut2 " & integer'image(RegOut2_ideal) & " PCOut1 " & integer'image(PCOut_ideal) & ": FAILED (PC)" severity warning;
				end if;
				pass := 0;
			end if;
		end procedure verify;
end bench;
