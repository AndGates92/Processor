library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.alu_pkg.all;
use work.decode_pkg.all;
use work.ctrl_pkg.all;
use work.proc_pkg.all;

entity ctrl is
generic (
	OP1_L		: positive := 32;
	OP2_L		: positive := 32;
	REG_NUM		: positive := 16;
	ADDR_L		: positive := 16;
	STAT_REG_L	: positive := 8;
	EN_REG_FILE_L	: positive := 3;
	BASE_STACK	: positive := 16#8000#;
	OUT_NUM		: positive := 2
);
port (

	rst		: in std_logic;
	clk		: in std_logic;

	EndExecution	: out std_logic;

	-- Decode Stage
	Immediate	: in std_logic_vector(DATA_L - 1 downto 0);
	EndDecoding	: in std_logic;
	CtrlCmd		: in std_logic_vector(CTRL_CMD_L - 1 downto 0);
	CmdALU_In	: in std_logic_vector(CMD_ALU_L - 1 downto 0);
	AddressRegFileIn_In	: in std_logic_vector(int_to_bit_num(REG_NUM) - 1 downto 0);
	AddressRegFileOut1_In	: in std_logic_vector(int_to_bit_num(REG_NUM) - 1 downto 0);
	AddressRegFileOut2_In	: in std_logic_vector(int_to_bit_num(REG_NUM) - 1 downto 0);
	EnableRegFile_In	: in std_logic_vector(EN_REG_FILE_L - 1 downto 0);

	Op1	: out std_logic_vector(OP1_L - 1 downto 0);
	Op2	: out std_logic_vector(OP2_L - 1 downto 0);

	-- ALU
	DoneALU	: in std_logic;
	EnableALU	: out std_logic;
	ResALU	: in std_logic_vector(OP1_L - 1 downto 0);
	CmdALU	: out std_logic_vector(CMD_ALU_L - 1 downto 0);

	-- Multiplier
	DoneMul	: in std_logic;
	EnableMul	: out std_logic;
	ResMul	: in std_logic_vector(OP1_L + OP2_L - 1 downto 0);

	-- Divider
	DoneDiv	: in std_logic;
	EnableDiv	: out std_logic;
	ResDiv	: in std_logic_vector(OP1_L - 1 downto 0);

	-- Memory access
	DoneMemory	: in std_logic;
	ReadMem		: out std_logic;
	EnableMemory	: out std_logic;
	DataMemIn	: out std_logic_vector(DATA_L - 1 downto 0);
	AddressMem	: out std_logic_vector(ADDR_L - 1 downto 0);
	DataMemOut	: in std_logic_vector(DATA_L - 1 downto 0);

	-- Register File
	-- Current register file has 1 write port and 2 read ports
	DoneRegFile	: in std_logic;
	DoneReadStatus	: in std_logic_vector(OUT_NUM - 1 downto 0);
	DataRegIn	: out std_logic_vector(DATA_L - 1 downto 0);
	DataRegOut1	: in std_logic_vector(DATA_L - 1 downto 0);
	DataRegOut2	: in std_logic_vector(DATA_L - 1 downto 0);
	AddressRegFileIn	: out std_logic_vector(int_to_bit_num(REG_NUM) - 1 downto 0);
	AddressRegFileOut1	: out std_logic_vector(int_to_bit_num(REG_NUM) - 1 downto 0);
	AddressRegFileOut2	: out std_logic_vector(int_to_bit_num(REG_NUM) - 1 downto 0);
	EnableRegFile	: out std_logic_vector(EN_REG_FILE_L - 1 downto 0)
);
end entity ctrl;

architecture rtl of ctrl is

	constant ZERO_OP	: std_logic_vector(DATA_L - 1 downto 0) := (others => '0');

	constant BaseStackAddr	: std_logic_vector(DATA_L - 1 downto 0) := std_logic_vector(to_unsigned(BASE_STACK, DATA_L));

	signal DataRegOut1N, DataRegOut1C	: std_logic_vector(DATA_L - 1 downto 0);
	signal ImmediateN, ImmediateC		: std_logic_vector(DATA_L - 1 downto 0);
	signal CtrlCmdN, CtrlCmdC		: std_logic_vector(CTRL_CMD_L - 1 downto 0);

	signal AddressMemFull	: std_logic_vector(DATA_L - 1 downto 0);

	-- ALU
	signal Op2Internal	: std_logic_vector(OP2_L - 1 downto 0);
	signal CmdALUN, CmdALUC	: std_logic_vector(CMD_ALU_L - 1 downto 0);

	-- Register File
	signal AddressRegFileInN, AddressRegFileInC	: std_logic_vector(int_to_bit_num(REG_NUM) - 1 downto 0);
	signal AddressRegFileOut1N, AddressRegFileOut1C	: std_logic_vector(int_to_bit_num(REG_NUM) - 1 downto 0);
	signal AddressRegFileOut2N, AddressRegFileOut2C	: std_logic_vector(int_to_bit_num(REG_NUM) - 1 downto 0);
	signal EnableRegFileN, EnableRegFileC		: std_logic_vector(EN_REG_FILE_L - 1 downto 0);

	signal ValidCommandC, ValidCommandN	: std_logic;
	signal StateC, StateN			: std_logic_vector(STATE_CTRL_L - 1 downto 0);

begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then
			StateC <= CTRL_IDLE;

			ImmediateC <= (others => '0');
			CtrlCmdC <= (others => '0');

			-- ALU
			CmdALUC <= CMD_ALU_DISABLE;

			-- Register File
			AddressRegFileInC <= (others => '0');
			AddressRegFileOut1C <= (others => '0');
			AddressRegFileOut2C <= (others => '0');
			EnableRegFileC <= (others => '0');

			ValidCommandC <= '0';

		elsif (clk'event) and (clk = '1') then
			StateC <= StateN;

			ImmediateC <= ImmediateN;
			CtrlCmdC <= CtrlCmdN;

			-- ALU
			CmdALUC <= CmdALUN;

			-- Register File
			DataRegOut1C <= DataRegOut1N;
			AddressRegFileInC <= AddressRegFileInN;
			AddressRegFileOut1C <= AddressRegFileOut1N;
			AddressRegFileOut2C <= AddressRegFileOut2N;
			EnableRegFileC <= EnableRegFileN;

			ValidCommandC <= ValidCommandN;
		end if;
	end process reg;

	state_det: process(StateC, CtrlCmdC, EnableRegFileC, DoneDiv, DoneMul, DoneALU, DoneRegFile, DoneMemory, ValidCommandC)
	begin
		StateN <= StateC; -- avoid latches
		if (StateC = CTRL_IDLE) then
			if (ValidCommandC = '1') then
				-- ALU command, Write command or move data from register file
				if (CtrlCmdC = CTRL_CMD_ALU) or (CtrlCmdC = CTRL_CMD_WR_S) or (CtrlCmdC = CTRL_CMD_WR_M) or ((CtrlCmdC = CTRL_CMD_MOV) and (EnableRegFileC(1) = '1')) then
					StateN <= REG_FILE_READ;
				-- Read command
				elsif (CtrlCmdC = CTRL_CMD_RD_S) or (CtrlCmdC = CTRL_CMD_RD_M) then
					StateN <= MEMORY_ACCESS;
				-- Store immediate to register file location
				elsif (CtrlCmdC = CTRL_CMD_MOV) and (EnableRegFileC(1) = '0') then
					StateN <= REG_FILE_WRITE;
				else
					StateN <= UNKNOWN_COMMAND;
				end if;
			end if;
		elsif (StateC = ALU_OP) then
			if (DoneALU = '1') then
				StateN <= REG_FILE_WRITE;
			else
				StateN <= StateC;
			end if;
		elsif (StateC = MULTIPLICATION) then
			if (DoneMul = '1') then
				StateN <= REG_FILE_WRITE;
			else
				StateN <= StateC;
			end if;
		elsif (StateC = DIVISION) then
			if (DoneDiv = '1') then
				StateN <= REG_FILE_WRITE;
			else
				StateN <= StateC;
			end if;
		elsif (StateC = REG_FILE_WRITE) then
			-- Store results
			if (DoneRegFile = '1') then
				StateN <= CTRL_IDLE;
			else
				StateN <= StateC;
			end if;
		elsif (StateC = REG_FILE_READ) then
			-- Retrieve operand from register file
			if (DoneRegFile = '1') then
				if (CtrlCmdC = CTRL_CMD_ALU) then
					if (CmdALUC = CMD_ALU_MUL) then
						StateN <= MULTIPLICATION;
					elsif (CmdALUC = CMD_ALU_DIV) then
						StateN <= DIVISION;
					else
						StateN <= ALU_OP;
					end if;
				elsif (CtrlCmdC = CTRL_CMD_WR_S) or (CtrlCmdC = CTRL_CMD_WR_M) then
					StateN <= MEMORY_ACCESS;
				elsif (CtrlCmdC = CTRL_CMD_MOV) then
					StateN <= REG_FILE_WRITE;
				else
					StateN <= StateC;
				end if;
			else
				StateN <= StateC;
			end if;
		elsif (StateC = MEMORY_ACCESS) then
			if (DoneMemory = '1') then
				if (CtrlCmdC = CTRL_CMD_RD_S) or (CtrlCmdC = CTRL_CMD_RD_M) then
					StateN <= REG_FILE_WRITE;
				elsif (CtrlCmdC = CTRL_CMD_WR_S) or (CtrlCmdC = CTRL_CMD_WR_M)  then
					StateN <= CTRL_IDLE;
				else
					StateN <= StateC;
				end if;
			else
				StateN <= StateC;
			end if;
		elsif (StateC = UNKNOWN_COMMAND) then
			StateN <= CTRL_IDLE;
		else
			StateN <= StateC;
		end if;
	end process state_det;

	EndExecution <= '1' when (StateC = UNKNOWN_COMMAND) or ((StateC = REG_FILE_WRITE) and (DoneRegFile = '1')) or (((CtrlCmdC = CTRL_CMD_WR_S) or (CtrlCmdC = CTRL_CMD_WR_M)) and (StateC = MEMORY_ACCESS) and (DoneMemory = '1')) else '0';

	ImmediateN <= Immediate when (EndDecoding = '1') else ImmediateC;
	CmdALUN <= CmdALU_In when (EndDecoding = '1') else CmdALUC;
	CtrlCmdN <= CtrlCmd when (EndDecoding = '1') else CtrlCmdC;
	AddressRegFileInN <= AddressRegFileIn_In when (EndDecoding = '1') else AddressRegFileInC;
	AddressRegFileOut1N <= AddressRegFileOut1_In when (EndDecoding = '1') else AddressRegFileOut1C;
	AddressRegFileOut2N <= AddressRegFileOut2_In when (EndDecoding = '1') else AddressRegFileOut2C;
	EnableRegFileN <= EnableRegFile_In when (EndDecoding = '1') else EnableRegFileC;

	ValidCommandN <= EndDecoding;

	-- Use data in register file
	Op1 <= DataRegOut1;
	Op2 <= Op2Internal;
	Op2Internal <= DataRegOut2 when (DoneReadStatus(1) = '1') else ImmediateC;

	EnableALU <= '1' when ((DoneRegFile = '1') and (CtrlCmdC = CTRL_CMD_ALU) and (CmdALUC /= CMD_ALU_MUL) and (CmdALUC /= CMD_ALU_DIV)) else '0';
	CmdALU <= CmdALUC;

	-- Multiplication
	EnableMul <= '1' when ((DoneRegFile = '1') and (CtrlCmdC = CTRL_CMD_ALU) and (CmdALUC = CMD_ALU_DIV)) else '0';

	-- Division
	EnableDiv <= '1' when ((DoneRegFile = '1') and (CtrlCmdC = CTRL_CMD_ALU) and (CmdALUC = CMD_ALU_DIV)) else '0';

	-- Register File
	AddressRegFileOut1 <= AddressRegFileOut1C;
	AddressRegFileOut2 <= AddressRegFileOut2C;
	AddressRegFileIn <= AddressRegFileInC;
	DataRegIn <=	DataMemOut when ((DoneMemory = '1') and (StateC = MEMORY_ACCESS)) else
			ResALU when ((DoneALU = '1') and (StateC = ALU_OP)) else
			ResMul(DATA_L - 1 downto 0) when ((DoneMul = '1') and (StateC = MULTIPLICATION)) else
			ResDiv when ((DoneDiv = '1') and (StateC = DIVISION)) else
			DataRegOut1C when ((CtrlCmdC = CTRL_CMD_MOV) and (StateC = REG_FILE_READ)) else
			ImmediateC;

	DataRegOut1N <= DataRegOut1;

	EnableRegFile <=	(EnableRegFileC(EN_REG_FILE_L - 1 downto 1) & "0") when (((StateC = CTRL_IDLE) and (ValidCommandC = '1') and ((CtrlCmdC = CTRL_CMD_ALU) or (CtrlCmdC = CTRL_CMD_WR_S) or (CtrlCmdC = CTRL_CMD_WR_M) or ((CtrlCmdC = CTRL_CMD_MOV) and (EnableRegFileC(1) = '1')))) or ((StateC = REG_FILE_READ) and (DoneRegFile = '0'))) else -- read data
				("00" & EnableRegFileC(0)) when (((DoneALU = '1') and (StateC = ALU_OP)) or ((DoneMul = '1') and (StateC = MULTIPLICATION)) or ((DoneDiv = '1') and (StateC = DIVISION)) or ((DoneMemory = '1') and ((CtrlCmdC = CTRL_CMD_RD_S) or (CtrlCmdC = CTRL_CMD_RD_M)) and (StateC = MEMORY_ACCESS)) or ((CtrlCmdC = CTRL_CMD_MOV) and (((StateC = CTRL_IDLE) and (ValidCommandC = '1') and (EnableRegFileC(1) = '0')) or ((StateC = REG_FILE_READ) and (DoneRegFile = '1')))) or ((StateC = REG_FILE_WRITE) and (DoneRegFile = '0'))) else -- store data (result of an operation or a memory access or an immediate to a register)
				(others => '0');

	-- Memory access
	DataMemIn <= DataRegOut1;
	AddressMemFull <= std_logic_vector(unsigned(ImmediateC) + unsigned(BaseStackAddr)) when ((CtrlCmdC = CTRL_CMD_RD_S) or (CtrlCmdC = CTRL_CMD_WR_S)) else ImmediateC;
	AddressMem <= AddressMemFull(ADDR_L - 1 downto 0);
	ReadMem <= '1' when ((CtrlCmdC = CTRL_CMD_RD_S) or (CtrlCmdC = CTRL_CMD_RD_M)) else '0';
	EnableMemory <= '1' when ((((CtrlCmdC = CTRL_CMD_RD_S) or (CtrlCmdC = CTRL_CMD_RD_M)) and (StateC = CTRL_IDLE) and (ValidCommandC = '1')) or ((StateC = MEMORY_ACCESS) and (DoneMemory = '0')) or ((DoneRegFile = '1') and (StateC = REG_FILE_READ) and ((CtrlCmdC = CTRL_CMD_WR_S) or (CtrlCmdC = CTRL_CMD_WR_M)))) else '0';

end rtl;
