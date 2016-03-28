library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;
use work.alu_pkg.all;

package ctrl_pkg is 

	constant CTRL_CMD_L	: positive := 3;

	constant CTRL_CMD_DISABLE	: std_logic_vector(CTRL_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(0, CTRL_CMD_L));
	constant CTRL_CMD_ALU	: std_logic_vector(CTRL_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(1, CTRL_CMD_L));
	constant CTRL_CMD_WR_M	: std_logic_vector(CTRL_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(2, CTRL_CMD_L));
	constant CTRL_CMD_RD_M	: std_logic_vector(CTRL_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(3, CTRL_CMD_L));
	constant CTRL_CMD_WR_S	: std_logic_vector(CTRL_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(4, CTRL_CMD_L));
	constant CTRL_CMD_RD_S	: std_logic_vector(CTRL_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(5, CTRL_CMD_L));
	constant CTRL_CMD_MOV	: std_logic_vector(CTRL_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(6, CTRL_CMD_L));

	constant ALU_OP		: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(1, STATE_L));
	constant MULTIPLICATION	: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(2, STATE_L));
	constant DIVISION	: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(3, STATE_L));
	constant REG_FILE_READ	: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(4, STATE_L));
	constant REG_FILE_WRITE	: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(5, STATE_L));
	constant MEMORY_ACCESS	: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(6, STATE_L));

	component ctrl
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

		-- Decode stage
		Immediate	: in std_logic_vector(REG_L - 1 downto 0);
		EndDecoding	: in std_logic;
		CtrlCmd	: in std_logic_vector(CTRL_CMD_L - 1 downto 0);
		CmdALU_In	: in std_logic_vector(ALU_CMD_L - 1 downto 0);
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
		CmdALU	: out std_logic_vector(ALU_CMD_L - 1 downto 0);

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
	end component;

end package ctrl_pkg;
