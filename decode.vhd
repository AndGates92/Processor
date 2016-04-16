library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.alu_pkg.all;
use work.decode_pkg.all;
use work.ctrl_pkg.all;
use work.proc_pkg.all;

entity decode_stage is
generic (
	REG_NUM		: positive := 16;
	PC_L		: positive := 32;
	STAT_REG_L	: positive := 8;
	EN_REG_FILE_L	: positive := 3
);
port (
	rst		: in std_logic;
	clk		: in std_logic;

	NewInstr	: in std_logic;
	Instr		: in std_logic_vector(INSTR_L - 1 downto 0);

	PCIn		: in std_logic_vector(PC_L - 1 downto 0);
	StatusRegIn	: in std_logic_vector(STAT_REG_L - 1 downto 0);

	AddressIn	: out std_logic_vector(int_to_bit_num(REG_NUM) - 1 downto 0);
	AddressOut1	: out std_logic_vector(int_to_bit_num(REG_NUM) - 1 downto 0);
	AddressOut2	: out std_logic_vector(int_to_bit_num(REG_NUM) - 1 downto 0);
	Immediate	: out std_logic_vector(DATA_L - 1 downto 0);
	EnableRegFile	: out std_logic_vector(EN_REG_FILE_L - 1 downto 0);

	Done	: out std_logic;

	CmdALU	: out std_logic_vector(CMD_ALU_L - 1 downto 0);
	Ctrl	: out std_logic_vector(CTRL_CMD_L - 1 downto 0);

	PCOut	: out std_logic_vector(PC_L - 1 downto 0);

	EndOfProg	: out std_logic
);
end entity decode_stage;

architecture rtl of decode_stage is

	constant ZERO_VEC	: std_logic_vector(DATA_L - 1 downto 0) := (others => '0');

	signal StateC, StateN	: std_logic_vector(STATE_L - 1 downto 0);

	signal InstrN, InstrC	: std_logic_vector(INSTR_L - 1 downto 0);

	signal AddressOut1C, AddressOut1N	: std_logic_vector(int_to_bit_num(REG_NUM) - 1 downto 0);
	signal AddressOut2C, AddressOut2N	: std_logic_vector(int_to_bit_num(REG_NUM) - 1 downto 0);
	signal AddressInC, AddressInN		: std_logic_vector(int_to_bit_num(REG_NUM) - 1 downto 0);
	signal DataInC, DataInN			: std_logic_vector(DATA_L - 1 downto 0);

	signal ImmediateC, ImmediateN	: std_logic_vector(DATA_L - 1 downto 0);
	signal CmdALUC, CmdALUN		: std_logic_vector(CMD_ALU_L - 1 downto 0);

	signal PCC, PCN		: unsigned(PC_L - 1 downto 0);
	signal PCCallC, PCCallN	: unsigned(PC_L - 1 downto 0);
	signal CtrlC, CtrlN	: std_logic_vector(CTRL_CMD_L - 1 downto 0);

	signal RegInC, RegInN		: std_logic;
	signal RegOut1C, RegOut1N	: std_logic;
	signal RegOut2C, RegOut2N	: std_logic;

	signal EndOfProgC, EndOfProgN	: std_logic;

begin

	state_det: process(StateC, NewInstr)
	begin
		StateN <= StateC; -- avoid latches
		if (StateC = IDLE) then
			if (NewInstr = '0') then
				StateN <= IDLE;
			else
				StateN <= DECODE;
			end if;
		elsif (StateC = DECODE) then
			StateN <= OUTPUT;
		elsif (StateC = OUTPUT) then
			StateN <= IDLE;
		else
			StateN <= StateC;
		end if;
	end process state_det;

	InstrN <= Instr when StateC = IDLE else InstrC;

	RegInN <=	'1' when (StateC = DECODE) and ((InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_MOV_I) or (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_MOV_R) or (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_ALU_I) or (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_ALU_R) or (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_RD_S) or (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_RD_M) or (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_CLR) or  (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_SET)) else 
			'0' when (StateC = IDLE) else
			RegInC;

	RegOut1N <=	'1' when (StateC = DECODE) and ((InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_WR_M) or (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_WR_S) or (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_ALU_I) or (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_ALU_R)  or (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_MOV_R)) else 
			'0' when (StateC = IDLE) else
			RegOut1C;

	RegOut2N <=	'1' when (StateC = DECODE) and (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_ALU_R) else 
			'0'  when (StateC = IDLE) else
			RegOut2C;

	AddressInN <=	(InstrC(INSTR_L - OP_CODE_L - 1 downto INSTR_L - OP_CODE_L - int_to_bit_num(REG_NUM))) when (StateC = DECODE) and ((InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_MOV_I) or (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_MOV_R) or (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_ALU_I) or (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_ALU_R) or (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_RD_M) or  (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_RD_S) or (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_CLR) or  (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_SET)) else 
			(others => '0') when (StateC = IDLE) else
			AddressInC;

	AddressOut1N <=	(InstrC(INSTR_L - OP_CODE_L - 1 downto INSTR_L - OP_CODE_L - int_to_bit_num(REG_NUM))) when (StateC = DECODE) and ((InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_WR_M) or (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_WR_S)) else 
			(InstrC(INSTR_L - OP_CODE_L - int_to_bit_num(REG_NUM) - 1 downto INSTR_L - OP_CODE_L - 2*int_to_bit_num(REG_NUM))) when (StateC = DECODE) and ((InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_ALU_R) or (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_ALU_I) or (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_MOV_R)) else
			(others => '0') when (StateC = IDLE) else
			AddressOut1C;

	AddressOut2N <=	(InstrC(INSTR_L - OP_CODE_L - 2*int_to_bit_num(REG_NUM) - 1 downto INSTR_L - OP_CODE_L - 3*int_to_bit_num(REG_NUM))) when (StateC = DECODE) and (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_ALU_R) else
			(others => '0')  when (StateC = IDLE) else
			AddressOut2C;

	ImmediateN <=	ZERO_VEC(OP_CODE_L + 3*int_to_bit_num(REG_NUM) + CMD_ALU_L - 1 downto 0) & (InstrC(INSTR_L - OP_CODE_L - 3*int_to_bit_num(REG_NUM) - 1 downto CMD_ALU_L)) when (StateC = DECODE) and (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_ALU_R) else
			ZERO_VEC(OP_CODE_L + 2*int_to_bit_num(REG_NUM) + CMD_ALU_L - 1 downto 0) & (InstrC(INSTR_L - OP_CODE_L - 2*int_to_bit_num(REG_NUM) - 1 downto CMD_ALU_L)) when (StateC = DECODE) and (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_ALU_I) else
			ZERO_VEC(OP_CODE_L + int_to_bit_num(REG_NUM) - 1 downto 0) & (InstrC(INSTR_L - OP_CODE_L - int_to_bit_num(REG_NUM) - 1 downto 0)) when (StateC = DECODE) and ((InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_RD_M) or (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_MOV_I) or (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_WR_M) or (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_RD_S) or  (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_WR_S)) else
			(others => '1') when ((StateC = DECODE) and (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_SET)) else
			(others => '0') when (StateC = IDLE) or ((StateC = DECODE) and (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_CLR)) else
			ImmediateC;

	CmdALUN <=	InstrC(CMD_ALU_L - 1 downto 0) when (StateC = DECODE) and ((InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_ALU_I) or (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_ALU_R)) else
			(others => '0') when (StateC = IDLE) else
			CmdALUC;

	PCCallN <=	unsigned(PCIn) + INCR_PC when (StateC = DECODE) and (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_CALL) else
			(others => '0') when (StateC = DECODE) and (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_RET) else
			PCCallC;

	PCN <=	unsigned(PCIn) when (StateC = IDLE) else
		PCC + unsigned(ZERO_VEC(PC_L - (INSTR_L - OP_CODE_L) - 1 downto 0) & (InstrC(INSTR_L - OP_CODE_L - 1 downto 0))) when (StateC = DECODE) and (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_JUMP) else
		unsigned(ZERO_VEC(PC_L - (INSTR_L - OP_CODE_L) - 1 downto 0) & (InstrC(INSTR_L - OP_CODE_L - 1 downto 0))) when (StateC = DECODE) and (((InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_BRE) and (StatusRegIn(0) = '1')) or ((InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_BRNE) and (StatusRegIn(0) = '0')) or ((InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_BRL) and (StatusRegIn(3) = '1')) or ((InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_BRG) and (StatusRegIn(3) = '0'))  or (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_CALL)) else
		PCCallC when (StateC = DECODE) and (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_RET) else
		(others => '0') when (StateC = IDLE) else
		PCC;

	EndOfProgN <=	'1' when (StateC = DECODE) and (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_EOP) else
			'0' when (StateC = IDLE) else
			EndOfProgC;

	CtrlN <=	CTRL_CMD_ALU when (StateC = DECODE) and ((InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_ALU_R) or (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_ALU_I)) else
			CTRL_CMD_WR_M when (StateC = DECODE) and (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_WR_M) else
			CTRL_CMD_RD_M when (StateC = DECODE) and (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_RD_M) else
			CTRL_CMD_WR_S when (StateC = DECODE) and (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_WR_S) else
			CTRL_CMD_RD_S when (StateC = DECODE) and (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_RD_S) else
			CTRL_CMD_MOV when (StateC = DECODE) and ((InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_MOV_R) or (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_MOV_I) or (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_SET) or (InstrC(INSTR_L - 1 downto INSTR_L - OP_CODE_L) = OP_CODE_CLR)) else
			CTRL_CMD_DISABLE;

	EnableRegFile <= RegOut2C & RegOut1C & RegInC when (StateC = OUTPUT) else (others => '0');
	AddressIn <= AddressInC when (StateC = OUTPUT) else (others => '0');
	AddressOut1 <= AddressOut1C when (StateC = OUTPUT) else (others => '0');
	AddressOut2 <= AddressOut2C when (StateC = OUTPUT) else (others => '0');
	Immediate <= ImmediateC when (StateC = OUTPUT) else (others => '0');
	AddressIn <= AddressInC when (StateC = OUTPUT) else (others => '0');
	CmdALU <= CmdALUC when (StateC = OUTPUT) else (others => '0');
	PCOut <= std_logic_vector(PCC) when (StateC = OUTPUT) else (others => '0');
	Done <= '1' when (StateC = OUTPUT) else '0';
	EndOfProg <= EndOfProgC when (StateC = OUTPUT) else '0';
	Ctrl <= CtrlC when (StateC = OUTPUT) else (others => '0');


	reg: process(rst, clk)
	begin
		if (rst = '1') then
			AddressInC <= (others => '0');
			AddressOut1C <= (others => '0');
			AddressOut2C <= (others => '0');
			ImmediateC <= (others => '0');
			StateC <= IDLE;
			InstrC <= (others => '0');
			RegInC <= '0';
			RegOut1C <= '0';
			RegOut2C <= '0';
			CtrlC <= (others => '0');
			CmdALUC <= (others => '0');
			PCC <= (others => '0');
			PCCallC <= (others => '0');
			EndOfProgC <= '0';
		elsif (rising_edge(clk)) then
			AddressInC <= AddressInN;
			AddressOut1C <= AddressOut1N;
			AddressOut2C <= AddressOut2N;
			ImmediateC <= ImmediateN;
			StateC <= StateN;
			InstrC <= InstrN;
			RegInC <= RegInN;
			RegOut1C <= RegOut1N;
			RegOut2C <= RegOut2N;
			CtrlC <= CtrlN;
			CmdALUC <= CmdALUN;
			PCC <= PCN;
			PCCallC <= PCCallN;
			EndOfProgC <= EndOfProgN;
		end if;
	end process reg;



end rtl;
