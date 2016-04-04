library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;
use work.ctrl_pkg.all;
use work.alu_pkg.all;

package decode_pkg is 

	constant OP_CODE_L	: positive := 5;

	constant OP_CODE_ALU_R	: std_logic_vector(OP_CODE_L - 1 downto 0) := std_logic_vector(to_unsigned(0, OP_CODE_L));
	constant OP_CODE_ALU_I	: std_logic_vector(OP_CODE_L - 1 downto 0) := std_logic_vector(to_unsigned(1, OP_CODE_L));
	constant OP_CODE_BRE	: std_logic_vector(OP_CODE_L - 1 downto 0) := std_logic_vector(to_unsigned(2, OP_CODE_L));
	constant OP_CODE_BRNE	: std_logic_vector(OP_CODE_L - 1 downto 0) := std_logic_vector(to_unsigned(3, OP_CODE_L));
	constant OP_CODE_BRG	: std_logic_vector(OP_CODE_L - 1 downto 0) := std_logic_vector(to_unsigned(4, OP_CODE_L));
	constant OP_CODE_BRL	: std_logic_vector(OP_CODE_L - 1 downto 0) := std_logic_vector(to_unsigned(5, OP_CODE_L));
	constant OP_CODE_JUMP	: std_logic_vector(OP_CODE_L - 1 downto 0) := std_logic_vector(to_unsigned(6, OP_CODE_L));
	constant OP_CODE_CALL	: std_logic_vector(OP_CODE_L - 1 downto 0) := std_logic_vector(to_unsigned(7, OP_CODE_L));
	constant OP_CODE_RD_M	: std_logic_vector(OP_CODE_L - 1 downto 0) := std_logic_vector(to_unsigned(8, OP_CODE_L));
	constant OP_CODE_WR_M	: std_logic_vector(OP_CODE_L - 1 downto 0) := std_logic_vector(to_unsigned(9, OP_CODE_L));
	constant OP_CODE_CLR	: std_logic_vector(OP_CODE_L - 1 downto 0) := std_logic_vector(to_unsigned(10, OP_CODE_L));
	constant OP_CODE_SET	: std_logic_vector(OP_CODE_L - 1 downto 0) := std_logic_vector(to_unsigned(11, OP_CODE_L));
	constant OP_CODE_WR_S	: std_logic_vector(OP_CODE_L - 1 downto 0) := std_logic_vector(to_unsigned(12, OP_CODE_L));
	constant OP_CODE_RD_S	: std_logic_vector(OP_CODE_L - 1 downto 0) := std_logic_vector(to_unsigned(13, OP_CODE_L));
	constant OP_CODE_MOV_I	: std_logic_vector(OP_CODE_L - 1 downto 0) := std_logic_vector(to_unsigned(14, OP_CODE_L));
	constant OP_CODE_MOV_R	: std_logic_vector(OP_CODE_L - 1 downto 0) := std_logic_vector(to_unsigned(15, OP_CODE_L));
	constant OP_CODE_RET	: std_logic_vector(OP_CODE_L - 1 downto 0) := std_logic_vector(to_unsigned(16, OP_CODE_L));
	constant OP_CODE_NOP	: std_logic_vector(OP_CODE_L - 1 downto 0) := std_logic_vector(to_unsigned(17, OP_CODE_L));
	constant OP_CODE_EOP	: std_logic_vector(OP_CODE_L - 1 downto 0) := std_logic_vector(to_unsigned(18, OP_CODE_L));

	constant DECODE	: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(2, STATE_L));

	component decode_stage
	generic (
		REG_NUM		: positive := 16;
		REG_L		: positive := 32;
		PC_L		: positive := 32;
		STAT_REG_L	: positive := 8;
		INCR_PC		: positive := 4;
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
		Immediate	: out std_logic_vector(REG_L - 1 downto 0);
		EnableRegFile	: out std_logic_vector(EN_REG_FILE_L - 1 downto 0);

		Done		: out std_logic;

		CmdALU		: out std_logic_vector(CMD_ALU_L - 1 downto 0);
		Ctrl	: out std_logic_vector(CTRL_CMD_L - 1 downto 0);

		PCOut		: out std_logic_vector(PC_L - 1 downto 0);

		EndOfProg	: out std_logic
	);
	end component;

end package decode_pkg;
