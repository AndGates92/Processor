library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ctrl_pkg.all;
use work.alu_pkg.all;
use work.proc_pkg.all;

package execute_pkg is 

	component execute_stage
	generic (
		BASE_STACK	: positive := 16#8000#;
		OP1_L		: positive := 32;
		OP2_L		: positive := 16;
		INSTR_L		: positive := 32;
		REG_NUM		: positive := 16;
		REG_L		: positive := 32;
		ADDR_L		: positive := 16;
		STAT_REG_L	: positive := 8;
		EN_REG_FILE_L	: positive := 3;
		OUT_REG_FILE_NUM	: positive := 2
	);
	port (
		rst		: in std_logic;
		clk		: in std_logic;

		Start	: in std_logic;

		AddressRegFileIn_In	: in std_logic_vector(count_length(REG_NUM) - 1 downto 0);
		AddressRegFileOut1_In	: in std_logic_vector(count_length(REG_NUM) - 1 downto 0);
		AddressRegFileOut2_In	: in std_logic_vector(count_length(REG_NUM) - 1 downto 0);
		Immediate	: in std_logic_vector(REG_L - 1 downto 0);
		EnableRegFile_In	: in std_logic_vector(EN_REG_FILE_L - 1 downto 0);

		CmdALU_In	: in std_logic_vector(CMD_ALU_L - 1 downto 0);
		CtrlCmd	: in std_logic_vector(CTRL_CMD_L - 1 downto 0);

		StatusRegOut	: out std_logic_vector(STAT_REG_L - 1 downto 0);
		ResDbg	: out std_logic_vector(OP1_L - 1 downto 0); -- debug signal
		Done	: out std_logic
	);
	end component;

end package execute_pkg;
