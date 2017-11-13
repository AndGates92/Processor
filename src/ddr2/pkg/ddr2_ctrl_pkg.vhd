library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library common_rtl_pkg;
use common_rtl_pkg.functions_pkg.all;

package ddr2_ctrl_pkg is 

	constant MEM_CMD_L	: positive := 5;

	constant CMD_NOP			: std_logic_vector(MEM_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(0, MEM_CMD_L));
	constant CMD_DESEL			: std_logic_vector(MEM_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(1, MEM_CMD_L));
	constant CMD_BANK_ACT			: std_logic_vector(MEM_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(2, MEM_CMD_L));
	constant CMD_MODE_REG_SET		: std_logic_vector(MEM_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(3, MEM_CMD_L));
	constant CMD_EXT_MODE_REG_SET_1		: std_logic_vector(MEM_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(4, MEM_CMD_L));
	constant CMD_EXT_MODE_REG_SET_2		: std_logic_vector(MEM_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(5, MEM_CMD_L));
	constant CMD_EXT_MODE_REG_SET_3		: std_logic_vector(MEM_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(6, MEM_CMD_L));
	constant CMD_AUTO_REF			: std_logic_vector(MEM_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(7, MEM_CMD_L));
	constant CMD_SELF_REF_ENTRY		: std_logic_vector(MEM_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(8, MEM_CMD_L));
	constant CMD_SELF_REF_EXIT		: std_logic_vector(MEM_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(9, MEM_CMD_L));
	constant CMD_POWER_DOWN_ENTRY		: std_logic_vector(MEM_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(10, MEM_CMD_L));
	constant CMD_POWER_DOWN_EXIT		: std_logic_vector(MEM_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(11, MEM_CMD_L));
	constant CMD_BANK_PRECHARGE		: std_logic_vector(MEM_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(12, MEM_CMD_L));
	constant CMD_ALL_BANK_PRECHARGE		: std_logic_vector(MEM_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(13, MEM_CMD_L));
	constant CMD_WRITE			: std_logic_vector(MEM_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(14, MEM_CMD_L));
	constant CMD_READ			: std_logic_vector(MEM_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(15, MEM_CMD_L));
	constant CMD_WRITE_PRECHARGE		: std_logic_vector(MEM_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(16, MEM_CMD_L));
	constant CMD_READ_PRECHARGE		: std_logic_vector(MEM_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(17, MEM_CMD_L));

	constant MAX_MEM_CMD_ID	: positive := max_int(to_integer(unsigned(CMD_NOP)), max_int(to_integer(unsigned(CMD_DESEL)), max_int(to_integer(unsigned(CMD_BANK_ACT)), max_int(to_integer(unsigned(CMD_MODE_REG_SET)), max_int(to_integer(unsigned(CMD_EXT_MODE_REG_SET_1)), max_int(to_integer(unsigned(CMD_EXT_MODE_REG_SET_2)), max_int(to_integer(unsigned(CMD_EXT_MODE_REG_SET_3)), max_int(to_integer(unsigned(CMD_AUTO_REF)), max_int(to_integer(unsigned(CMD_SELF_REF_ENTRY)), max_int(to_integer(unsigned(CMD_SELF_REF_EXIT)), max_int(to_integer(unsigned(CMD_POWER_DOWN_ENTRY)), max_int(to_integer(unsigned(CMD_POWER_DOWN_EXIT)), max_int(to_integer(unsigned(CMD_BANK_PRECHARGE)), max_int(to_integer(unsigned(CMD_ALL_BANK_PRECHARGE)), max_int(to_integer(unsigned(CMD_WRITE)), max_int(to_integer(unsigned(CMD_READ)), max_int(to_integer(unsigned(CMD_WRITE_PRECHARGE)), to_integer(unsigned(CMD_READ_PRECHARGE)))))))))))))))))));

end package ddr2_ctrl_pkg;
