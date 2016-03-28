library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.alu_pkg.all;
use work.pipeline_pkg.all;
use work.ctrl_pkg.all;
use work.proc_pkg.all;

entity ctrl is
generic (
	OP1_L		: positive := 32;
	OP2_L		: positive := 32;
	INSTR_L		: positive := 32;
	REG_NUM		: positive := 16;
	ADDR_L		: positive := 16;
	REG_L		: positive := 32;
	STAT_REG_L	: positive := 8;
	EN_REG_FILE_L	: positive := 3;
	OUT_NUM		: positive := 2
);
port (

	rst		: in std_logic;
	clk		: in std_logic;

	Immediate	: in std_logic_vector(REG_L - 1 downto 0);

	EndDecoding	: in std_logic;

	Ctrl	: in std_logic_vector(CTRL_L - 1 downto 0);

	CmdALU_In	: in std_logic_vector(CMD_ALU_L - 1 downto 0);

	AddressRegFileIn_In	: in std_logic_vector(count_length(REG_NUM) - 1 downto 0);
	AddressRegFileOut1_In	: in std_logic_vector(count_length(REG_NUM) - 1 downto 0);
	AddressRegFileOut2_In	: in std_logic_vector(count_length(REG_NUM) - 1 downto 0);
	Enable_reg_file_In	: in std_logic_vector(EN_REG_FILE_L - 1 downto 0);

	-- ALU
	DoneALU	: in std_logic;
	EnableALU	: out std_logic;
	Op1ALU	: out std_logic_vector(OP1_L - 1 downto 0);
	Op2ALU	: out std_logic_vector(OP2_L - 1 downto 0);
	ResALU	: in std_logic_vector(OP1_L - 1 downto 0);
	CmdALU	: out std_logic_vector(CMD_ALU_L - 1 downto 0);

	-- Multiplier
	DoneMul	: in std_logic;
	EnableMul	: out std_logic;
	Op1Mul	: out std_logic_vector(OP1_L - 1 downto 0);
	Op2Mul	: out std_logic_vector(OP2_L - 1 downto 0);
	ResMul	: in std_logic_vector(OP1_L + OP2_L - 1 downto 0);

	-- Divider
	DoneDiv	: in std_logic;
	EnableDiv	: out std_logic;
	Op1Div	: out std_logic_vector(OP1_L - 1 downto 0);
	Op2Div	: out std_logic_vector(OP2_L - 1 downto 0);
	ResDiv	: in std_logic_vector(OP1_L - 1 downto 0);

	-- Memory access
	DoneMemory	: in std_logic;
	ReadMem		: out std_logic;
	EnableMemory	: out std_logic;
	DataMemIn	: out std_logic_vector(REG_L - 1 downto 0);
	AddressMem	: out std_logic_vector(ADDR_L - 1 downto 0);
	DataMemOut	: in std_logic_vector(REG_L - 1 downto 0);

	-- Register File
	DoneRegFile	: in std_logic;
	DoneReadStatus	: in std_logic_vector(OUT_NUM - 1 downto 0);
	DataRegIn		: out std_logic_vector(REG_L - 1 downto 0);
	DataRegOut1	: in std_logic_vector(REG_L - 1 downto 0);
	DataRegOut2	: in std_logic_vector(REG_L - 1 downto 0);
	AddressRegFileIn	: out std_logic_vector(count_length(REG_NUM) - 1 downto 0);
	AddressRegFileOut1	: out std_logic_vector(count_length(REG_NUM) - 1 downto 0);
	AddressRegFileOut2	: out std_logic_vector(count_length(REG_NUM) - 1 downto 0);
	EnableRegFile	: out std_logic_vector(EN_REG_FILE_L - 1 downto 0)
);

architecture rtl of ctrl is

	signal ImmediateN, ImmediateC	: std_logic_vector(REG_L - 1 downto 0);
	signal CtrlN, CtrlC	: std_logic_vector(CTRL_L - 1 downto 0);

	-- ALU
	signal CmdALUN, CmdALUC		: std_logic_vector(CMD_ALU_L - 1 downto 0);

	-- Register File
	signal AddressRegFileInN, AddressRegFileInC	: std_logic_vector(count_length(REG_NUM) - 1 downto 0);
	signal AddressRegFileOut1N, AddressRegFileOut1C	: std_logic_vector(count_length(REG_NUM) - 1 downto 0);
	signal AddressRegFileOut2N, AddressRegFileOut2C	: std_logic_vector(count_length(REG_NUM) - 1 downto 0);
	signal EnableRegFileN, EnableRegFileC	: std_logic_vector(EN_REG_FILE_L - 1 downto 0);

	signal StateC, StateN	: std_logic_vector(STATE_L - 1 downto 0);
	signal NextStateC, NextStateN	: std_logic_vector(STATE_L - 1 downto 0);

begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then
			StateC <= IDLE;
			NextStateC <= IDLE;

			ImmediateC <= (others => '0');
			CtrlC <= (others => '0');

			-- ALU
			CmdALUC <= CMD_DISABLE;

			-- Register File
			AddressRegFileInC <= (others => '0');
			AddressRegFileOut1C <= (others => '0');
			AddressRegFileOut2C <= (others => '0');
			EnableRegFileC <= (others => '0');

		elsif (rising_edge(clk)) then
			StateC <= StateN;
			NextStateC <= NextStateN;

			ImmediateC <= ImmediateN;
			CtrlC <= CtrlN;

			-- ALU
			CmdALUC <= CmdALUN;

			-- Register File
			AddressRegFileInC <= AddressRegFileInN;
			AddressRegFileOut1C <= AddressRegFileOut1N;
			AddressRegFileOut2C <= AddressOut2N;
			EnableRegFileC <= EnableRegFileN;
		end if;
	end process reg;

	state_det: process(StateC, NextStateC, CtrlC, Ctrl, Enable_reg_file_In, DoneDiv, DoneMul, DoneALU, DoneRegFile, DoneMemory, EndDecoding)
		variable State_tmp	: std_logic_vector(STATE_L - 1 downto 0);
	begin
		StateN <= StateC; -- avoid latches
		NextStateN <= NextStateC;
		State_tmp := StateC;
		if (StateC = IDLE) then
			if (EndDecoding = '1') then
				if (Ctrl = CTRL_ALU) or  (Ctrl = CTRL_WR_S) or (Ctrl = CTRL_WR_M) or ((Ctrl = CTRL_MOV) and Enable_reg_file_In(1) = '1') then
					StateN <= REG_FILE_READ;
					NextStateN <= REG_FILE_READ;
				elsif (Ctrl = CTRL_RD_S) or (Ctrl = CTRL_RD_M) then
					StateN <= MEMORY_ACCESS;
					NextStateN <= MEMORY_ACCESS;
				elsif ((Ctrl = CTRL_MOV) and Enable_reg_file_In(1) = '0') then
					StateN <= REG_FILE_WRITE;
					NextStateN <= REG_FILE_WRITE;
				else
					StateN <= StateC;
					NextStateN <= NextStateC;
				end if;
			end if;
		elsif (StateC = ALU_OP) then
			if (DoneALU = '1') then
				StateN <= REG_FILE_WRITE;
				NextStateN <= NextStateC;
			else
				StateN <= StateC;
				NextStateN <= REG_FILE_WRITE;
			end if;
		elsif (StateC = MULTIPLICATION) then
			if (DoneMul = '1') then
				StateN <= REG_FILE_WRITE;
				NextStateN <= NextStateC;
			else
				StateN <= StateC;
				NextStateN <= REG_FILE_WRITE;
			end if;
		elsif (StateC = DIVISION) then
			if (DoneDiv = '1') then
				StateN <= REG_FILE_WRITE;
				NextStateN <= NextStateC;
			else
				StateN <= StateC;
				NextStateN <= REG_FILE_WRITE;
			end if;
		elsif (StateC = REG_FILE_WRITE) then
			if (DoneRegFile = '1') then
				StateN <= IDLE;
				NextStateN <= IDLE;
			end if;
		elsif (StateC = REG_FILE_READ) then
			if (CtrlC = CTRL_ALU) then
				if (CmdALUC = CMD_MUL)
					State_tmp := MULTIPLICATION;
				elsif (CmdALUC = CMD_DIV)
					State_tmp := DIVISION;
				else
					State_tmp := ALU_OP;
			elsif (CtrlC = CTRL_WR_S) or (Ctrl = CTRL_WR_M) then
				State_tmp := MEMORY_ACCESS;
			elsif (CtrlC = CTRL_CTRL_MOV) and (Enable_reg_file(1) = '1') then
				State_tmp := REG_FILE_WRITE;
			else
				State_tmp := StateC;
			end if;
			if (DoneRegFile = '1') then
				StateN <= State_tmp;
				NextStateN <= NextStateC;
			else
				NextStateN <= State_tmp;
				StateN <= StateC;
			end if;
		elsif (StateC = MEMORY_ACCESS) then
				if (Ctrl = CTRL_WR_S) or (Ctrl = CTRL_WR_M) then
					State_tmp := REG_FILE_STR;
				elsif (Ctrl = CTRL_MOV) then
					State_tmp := IDLE;
				else
					State_tmp := StateC;
				end if;

			if (DoneMemmory = '1') then
				StateN <= State_tmp;
				NextStateN <= NextStateC;
			else
				NextStateN <= State_tmp;
				StateN <= StateC;
			end if;
		else
			StateN <= StateC;
		end case;
	end process state_det;

	ImmediateN <= Immediate when (EndDecoding = '1') else ImmediateC;
	CmdALUN <= CmdALU_In when (EndDecoding = '1') else CmdALUC;
	CtrlN <= Ctrl when (EndDecoding = '1') else CtrlC;
	AddressRegFileInN <= AddressRegFileIn_In when (EndDecoding = '1') else AddressRegFileInC;
	AddressRegFileOut1N <= AddressRegFileOut1_In when (EndDecoding = '1') else AddressRegFileOut1C;
	AddressRegFileOut2N <= AddressRegFileOut2_In when (EndDecoding = '1') else AddressRegFileOut2C;
	EnableRegFileN <= EnableRegFile_In when (EndDecoding = '1') else EnableRegFileC;

	-- ALU
--	Op1ALUN <=	DataOut1	when ((DoneRegFile = '1') and NextStateC = ALU_OP) else
--			Op1ALUC		when (StateC = ALU_OP) else
--			(others => '0');

	Op1ALU <= DataRegOut1;
	Op2ALU <= DataRegOut2 when (DoneReadStatus(2) = '1') else ImmediateC;
	EnableALU <= '1' when ((DoneRegFile = '1') and (NextStateC = ALU_OP)) else '0';
	CmdALU <= CmdALUC;

	-- Multiplication
	Op1Mul <= DataRegOut1;
	Op2Mul <= DataRegOut2 when (EnableRegFileC(2) = '1') else ImmediateC;
	EnableMul <= when ((DoneRegFile = '1') and (NextStateC = MUL)) else '0';

	-- Division
	Op1Div <= DataRegOut1;
	Op2Div <= DataRegOut2 when (EnableRegFileC(2) = '1') else ImmediateC;
	EnableDiv <= '1' when ((DoneRegFile = '1') and (NextStateC = DIV)) else '0';

	-- Register File
	AddressRegFileOut1 <= AddressRegFileOut1C;
	AddressRegFileOut2 <= AddressRegFileOut2C;
	AddressRegFileIn <= AddressRegFileInC;
	DataRegIn <=	DataMemOut when ((DoneMem = '1') and (StateC = MEMORY_ACCESS)) else
			ResALU when ((DoneALU = '1') and (StateC = ALU_OP)) else
			ResMul when ((DoneMul = '1') and (StateC = MUL)) else
			ResDiv when ((DoneDiv = '1') and (StateC = DIV)) else
			ImmediateC;

	EnableRegFile <=	(EnableRegFileC(EN_REG_FILE_L - 1 downto 1) & "0") when (NextStateC = REG_FILE_READ) else -- read data
				("00" & EnableRegFileC(0)) when (((DoneALU = '1') or (DoneMul = '1') or (DoneDiv = '1') or (DoneMem = '1') or ((CtrlC = CTRL_MOV) and (EnableRegFileC(1) = '0'))) and (NextStateC = REG_FILE_WRITE)) else -- store data (result of an operation or a memory access or an immediate to a register)
				(others => '0');

	-- Memory access
	DataMemIn <= DataRegOut1;
	AddressMem <= (ImmediateC + BASE_STACK) when ((CtrlC = CTRL_RD_S) or (CtrlC = CTRL_WR_S)) else ImmediateC;
	ReadMem <= '1' when ((CtrlC = CTRL_RD_S) or (CtrlC = CTRL_RD_M)) else '0';
	EnableMem <= '1' when (((CtrlC = CTRL_RD_S) or (CtrlC = CTRL_RD_M) or (DoneRegFile = '1')) and (NextStateC = MEMORY_ACCESS)) else '0';

end rtl;
