library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;
use work.ddr2_pkg.all;

package ddr2_phy_pkg is 

	constant MAX_OUTSTANDING_BURSTS		: positive := 10;
	constant MAX_OUTSTANDING_BURSTS_L	: positive := int_to_bit_num(MAX_OUTSTANDING_BURSTS);

	constant STATE_PHY_L	: positive := 4;

	constant IDLE_MEM		: std_logic_vector(STATE_PHY_L - 1 downto 0) := std_logic_vector(to_unsigned(0, STATE_PHY_L));
	constant OUTPUT_MEM		: std_logic_vector(STATE_PHY_L - 1 downto 0) := std_logic_vector(to_unsigned(1, STATE_PHY_L));
	constant RESET			: std_logic_vector(STATE_PHY_L - 1 downto 0) := std_logic_vector(to_unsigned(2, STATE_PHY_L));
	constant WRITE_BURST		: std_logic_vector(STATE_PHY_L - 1 downto 0) := std_logic_vector(to_unsigned(3, STATE_PHY_L));
	constant READ_BURST		: std_logic_vector(STATE_PHY_L - 1 downto 0) := std_logic_vector(to_unsigned(4, STATE_PHY_L));
	constant PRECHARGE_ALL		: std_logic_vector(STATE_PHY_L - 1 downto 0) := std_logic_vector(to_unsigned(5, STATE_PHY_L));
	constant WRITE_PRECHARGE	: std_logic_vector(STATE_PHY_L - 1 downto 0) := std_logic_vector(to_unsigned(6, STATE_PHY_L));
	constant READ_PRECHARGE		: std_logic_vector(STATE_PHY_L - 1 downto 0) := std_logic_vector(to_unsigned(7, STATE_PHY_L));
	constant SELF_REFRESH		: std_logic_vector(STATE_PHY_L - 1 downto 0) := std_logic_vector(to_unsigned(8, STATE_PHY_L));
	constant AUTO_REFRESH		: std_logic_vector(STATE_PHY_L - 1 downto 0) := std_logic_vector(to_unsigned(9, STATE_PHY_L));
	constant SET_REG		: std_logic_vector(STATE_PHY_L - 1 downto 0) := std_logic_vector(to_unsigned(10, STATE_PHY_L));

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
	constant CMD_SELF_REF_EXIT2		: std_logic_vector(MEM_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(9, MEM_CMD_L));
	constant CMD_POWER_DOWN_ENTRY		: std_logic_vector(MEM_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(10, MEM_CMD_L));
	constant CMD_POWER_DOWN_EXIT		: std_logic_vector(MEM_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(11, MEM_CMD_L));
	constant CMD_BANK_PRECHARGE		: std_logic_vector(MEM_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(12, MEM_CMD_L));
	constant CMD_ALL_BANKS_PRECHARGE	: std_logic_vector(MEM_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(13, MEM_CMD_L));
	constant CMD_WRITE			: std_logic_vector(MEM_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(14, MEM_CMD_L));
	constant CMD_READ			: std_logic_vector(MEM_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(15, MEM_CMD_L));
	constant CMD_WRITE_PRECHARGE		: std_logic_vector(MEM_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(16, MEM_CMD_L));
	constant CMD_READ_PRECHARGE		: std_logic_vector(MEM_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(17, MEM_CMD_L));

end package ddr2_phy_pkg;
