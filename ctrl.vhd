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
	EN_REG_FILE_L	: positive := 3
);
port (

	rst		: in std_logic;
	clk		: in std_logic;

	Immediate	: in std_logic_vector(REG_L - 1 downto 0);

	EndDecoding	: in std_logic;

	Ctrl	: in std_logic_vector(CTRL_L - 1 downto 0);

	CmdALU_In	: in std_logic_vector(CMD_ALU_L - 1 downto 0);

	AddressIn_In	: in std_logic_vector(count_length(REG_NUM) - 1 downto 0);
	AddressOut1_In	: in std_logic_vector(count_length(REG_NUM) - 1 downto 0);
	AddressOut2_In	: in std_logic_vector(count_length(REG_NUM) - 1 downto 0);
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
	EnableMemory	: out std_logic;
	DataIn	: out std_logic_vector(REG_L - 1 downto 0);
	AddressMem	: out std_logic_vector(ADDR_L - 1 downto 0);
	DataOut	: in std_logic_vector(REG_L - 1 downto 0);

	-- Register File
	DoneRegFile	: in std_logic;
	DataIn		: out std_logic_vector(REG_L - 1 downto 0);
	AddressIn	: out std_logic_vector(count_length(REG_NUM) - 1 downto 0);
	AddressOut1	: out std_logic_vector(count_length(REG_NUM) - 1 downto 0);
	AddressOut2	: out std_logic_vector(count_length(REG_NUM) - 1 downto 0);
	EnableRegFile	: out std_logic_vector(EN_REG_FILE_L - 1 downto 0)
);

architecture rtl of ctrl is

	signal ImmediateN, ImmediateC	: std_logic_vector(REG_L - 1 downto 0);
	signal CtrlN, CtrlC	: std_logic_vector(CTRL_L - 1 downto 0);

	-- ALU
	signal EnableALUN, EnableALUC	: std_logic;
	signal CmdALUN, CmdALUC		: std_logic_vector(CMD_ALU_L - 1 downto 0);
	signal Op1ALUN, Op1ALUC		: std_logic_vector(OP1_L - 1 downto 0);
	signal Op2ALUN, Op2ALUC		: std_logic_vector(OP2_L - 1 downto 0);
	signal DoneALUN, DoneALUC	: std_logic;
	signal ResALUN, ResALUC		: std_logic_vector(OP1_L - 1 downto 0);

	-- Multiplier
	signal EnableMulN, EnableMulC	: std_logic;
	signal Op1MulN, Op1MulC		: std_logic_vector(OP1_L - 1 downto 0);
	signal Op2MulN, Op2MulC		: std_logic_vector(OP2_L - 1 downto 0);
	signal DoneMulN, DoneMulC	: std_logic;
	signal ResMulN, ResMulC		: std_logic_vector(OP1_L + OP2_L - 1 downto 0);

	-- Divider
	signal EnableDivN, EnableDivC	: std_logic;
	signal Op1DivN, Op1DivC		: std_logic_vector(OP1_L - 1 downto 0);
	signal Op2DivN, Op2DivC		: std_logic_vector(OP2_L - 1 downto 0);
	signal DoneDivN, DoneDivC	: std_logic;
	signal ResDivN, ResDivC		: std_logic_vector(OP1_L - 1 downto 0);

	-- Memory access
	signal DoneMemoryN, DoneMemoryC	: std_logic;
	signal EnableMemoryN, EnableMemoryC	: std_logic;
	signal DataInN, DataInC	: std_logic_vector(REG_L - 1 downto 0);
	signal DataOutN, DataOutC	: std_logic_vector(REG_L - 1 downto 0);
	signal AddressMemN, AddressMemC	: std_logic_vector(ADDR_L - 1 downto 0);

	-- Register File
	signal DoneRegFileN , DoneRegFileC	: std_logic;
	signal DataInN, DataInC	: std_logic_vector(REG_L - 1 downto 0);
	signal DataOut1N, DataOut1C	: std_logic_vector(REG_L - 1 downto 0);
	signal DataOut2N, DataOut2C	: std_logic_vector(REG_L - 1 downto 0);
	signal AddressInN, AddressInC	: std_logic_vector(count_length(REG_NUM) - 1 downto 0);
	signal AddressOut1N, AddressOut1C	: std_logic_vector(count_length(REG_NUM) - 1 downto 0);
	signal AddressOut2N, AddressOut2C	: std_logic_vector(count_length(REG_NUM) - 1 downto 0);
	signal EnableRegFileN, EnableRegFileC	: std_logic_vector(EN_REG_FILE_L - 1 downto 0);

	type state_list is (IDLE, ALU_OP, MUL, DIV, REG_FILE_READ, REG_FILE_WRITE, MEMORY_ACCESS, OUTPUT);
	signal StateC, StateN	: std_logic_vector(STATE_L - 1 downto 0);

begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then
			StateC <= IDLE;
			ImmediateC <= (others => '0');
			CtrlC <= (others => '0');

			DataInC <= (others => '0');

			-- ALU
			Op1ALUC <= (others => '0');
			Op2ALUC <= (others => '0');
			ResALUC <= (others => '0');
			CmdALUC <= (others => '0');
			EnableALUC <= '0';
			DoneALUC <= '0';

			-- Multiplier
			Op1MulC <= (others => '0');
			Op2MulC <= (others => '0');
			ResMulC <= (others => '0');
			EnableMulC <= '0';
			DoneMulC <= '0';

			-- Divider
			Op1DivC <= (others => '0');
			Op2DivC <= (others => '0');
			ResDivC <= (others => '0');
			EnableDivC <= '0';
			DoneDivC <= '0';

			-- Memory access
			DataOutC <= (others => '0');
			AddressMemC <= (others => '0');
			EnableMemoryC <= '0';
			DoneMemoryC <= '0';

			-- Register File
			DataInC <= (others => '0');
			DataOut1C <= (others => '0');
			DataOut2C <= (others => '0');
			AddressInC <= (others => '0');
			AddressOut1C <= (others => '0');
			AddressOut2C <= (others => '0');
			EnableRegFileC <= (others => '0');
			DoneRegFileC <= '0';

		elsif (rising_edge(clk)) then
			StateC <= StateN;
			ImmediateC <= ImmediateN;
			CtrlC <= CtrlN;

			DataInC <= DataInN;

			-- ALU
			Op1ALUC <= Op1ALUN;
			Op2ALUC <= Op2ALUN;
			ResALUC <= ResALUN;
			CmdALUC <= CmdALUN;
			EnableALUC <= EnableALUN;
			DoneALUC <= DoneALUN;

			-- Multiplier
			Op1MulC <= Op1MulN;
			Op2MulC <= Op2MulN;
			ResMulC <= ResMulN;
			EnableMulC <= EnableMulN;
			DoneMulC <= DoneMulN;

			-- Divider
			Op1DivC <= Op1DivN;
			Op2DivC <= Op2DivN;
			ResDivC <= ResDivN;
			EnableDivC <= EnableDivN;
			DoneDivC <= DoneDivN;

			-- Memory access
			DataOutC <= DataOutN;
			AddressMemC <= AddressMemN;
			EnableMemoryC <= EnableMemoryN;
			DoneMemoryC <= DoneMemoryN;

			-- Register File
			DataOut1C <= DataOut1N;
			DataOut2C <= DataOut2N;
			AddressInC <= AddressInN;
			AddressOut1C <= AddressOut1N;
			AddressOut2C <= AddressOut2N;
			EnableRegFileC <= EnableRegFileN;
			DoneRegFileC <= DoneRegFileC;;
		end if;
	end process reg;

	state_det: process(StateC, Start, CtrlC, Ctrl, Enable_reg_file_In, DoneDivN, DoneMulN, DoneALUN, DoneRegFileN, DoneMemoryN, EndDecoding)
	begin
		StateN <= StateC; -- avoid latches
		if (StateC = IDLE) then
			if (EndDecoding = '1') then
				if (Ctrl = CTRL_ALU) or  (Ctrl = CTRL_WR_S) or (Ctrl = CTRL_WR_M) or ((Ctrl = CTRL_MOV) and Enable_reg_file_In(1) = '1') then
					StateN <= REG_FILE_READ;
				elsif (Ctrl = CTRL_RD_S) or (Ctrl = CTRL_RD_M) then
					StateN <= MEMORY_ACCESS;
				elsif ((Ctrl = CTRL_MOV) and Enable_reg_file_In(1) = '1') then
					StateN <= REG_FILE_WRITE;
			end if;
		else
			StateN <= StateC;
		end case;
	end process state_det;

end rtl;
