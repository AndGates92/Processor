library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
library common_rtl_pkg;
use common_rtl_pkg.functions_pkg.all;
library cpu_rtl_pkg;
use cpu_rtl_pkg.proc_pkg.all;
use cpu_rtl_pkg.ctrl_pkg.all;
use cpu_rtl_pkg.alu_pkg.all;

package execute_dcache_pkg is 

	component execute_dcache
	generic (
		BASE_STACK	: positive := 16#8000#;
		OP1_L		: positive := 32;
		OP2_L		: positive := 16;
		REG_NUM		: positive := 16;
		ADDR_L		: positive := 16;
		STAT_REG_L	: positive := 8;
		EN_REG_FILE_L	: positive := 3;
		OUT_REG_FILE_NUM	: positive := 2
	);
	port (
		rst		: in std_logic;
		clk		: in std_logic;

		Start	: in std_logic;
		Endrst	: out std_logic;

		AddressRegFileIn_In	: in std_logic_vector(int_to_bit_num(REG_NUM) - 1 downto 0);
		AddressRegFileOut1_In	: in std_logic_vector(int_to_bit_num(REG_NUM) - 1 downto 0);
		AddressRegFileOut2_In	: in std_logic_vector(int_to_bit_num(REG_NUM) - 1 downto 0);
		Immediate	: in std_logic_vector(DATA_L - 1 downto 0);
		EnableRegFile_In	: in std_logic_vector(EN_REG_FILE_L - 1 downto 0);

		CmdALU_In	: in std_logic_vector(CMD_ALU_L - 1 downto 0);
		CtrlCmd	: in std_logic_vector(CTRL_CMD_L - 1 downto 0);

		StatusRegOut	: out std_logic_vector(STAT_REG_L - 1 downto 0);
		ResDbg	: out std_logic_vector(OP1_L - 1 downto 0); -- debug signal
		Done	: out std_logic
	);
	end component;

end package execute_dcache_pkg;
