library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.mem_pkg.all;

package mem_phy_pkg is 

	constant STATE_PHY_L	: positive := 4;

	constant IDLE_MEM		: std_logic_vector(STATE_PHY_L - 1 downto 0) := std_logic_vector(to_unsigned(0, STATE_PHY_L));
	constant OUTPUT_MEM		: std_logic_vector(STATE_PHY_L - 1 downto 0) := std_logic_vector(to_unsigned(1, STATE_PHY_L));
	constant RESET			: std_logic_vector(STATE_PHY_L - 1 downto 0) := std_logic_vector(to_unsigned(2, STATE_PHY_L));
	constant WRITE			: std_logic_vector(STATE_PHY_L - 1 downto 0) := std_logic_vector(to_unsigned(3, STATE_PHY_L));
	constant READ			: std_logic_vector(STATE_PHY_L - 1 downto 0) := std_logic_vector(to_unsigned(4, STATE_PHY_L));
	constant PRECHARGE_ALL		: std_logic_vector(STATE_PHY_L - 1 downto 0) := std_logic_vector(to_unsigned(5, STATE_PHY_L));
	constant WRITE_PRECHARGE	: std_logic_vector(STATE_PHY_L - 1 downto 0) := std_logic_vector(to_unsigned(6, STATE_PHY_L));
	constant READ_PRECHARGE		: std_logic_vector(STATE_PHY_L - 1 downto 0) := std_logic_vector(to_unsigned(7, STATE_PHY_L));
	constant SELF_REFRESH		: std_logic_vector(STATE_PHY_L - 1 downto 0) := std_logic_vector(to_unsigned(8, STATE_PHY_L));
	constant AUTO_REFRESH		: std_logic_vector(STATE_PHY_L - 1 downto 0) := std_logic_vector(to_unsigned(9, STATE_PHY_L));
	constant SET_REG		: std_logic_vector(STATE_PHY_L - 1 downto 0) := std_logic_vector(to_unsigned(10, STATE_PHY_L));

	constant MEM_CMD_L	: positive := 5;

	constant CMD_NOP			: std_logic_vector(MEM_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(0, MEM_CMD_L));
	constant CMD_DESEL			: std_logic_vector(MEM_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(1, MEM_CMD_L));
	constant CMD_BANK_ACTIV			: std_logic_vector(MEM_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(2, MEM_CMD_L));
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

	constant PHY_CNT_L	: integer := int_to_bit_num(max_int(T_RCD, max_int(T_RFC, max_int(T_RP, max_int(T_AOFD, max_int(T_MOD_max, max_int(T_XARD, max_int(T_RC, max_int(T_RAP, max_int(T_RAS_max, max_int(T_RRD, max_int(T_FAW, max_int(T_WR, max_int(T_REFI_highT, max_int(T_CCD, max_int(T_MRD, max_int(max_XP, max_int(T_AOFD, max_int(T_XSRD, max_int(T_XP, max_int(T_REFI_lowT, max_int(T_XSNR, T_XARDS_max))))))))))))))))))))));

	component mem_int is
	port (

		rst		: in std_logic;
		clk		: in std_logic;

		-- Memory access
		AddressMem		: out std_logic_vector(ADDR_MEM_L - 1 downto 0);
		BankSelMem		: out std_logic_vector(BANK_L - 1 downto 0);
		DataMem			: inout std_logic_vector(DATA_L - 1 downto 0);
		DataStrobeNMem		: inout std_logic;
		DataStrobePMem		: inout std_logic;
		UpDataStrobeNMem	: inout std_logic;
		UpDataStrobePMem	: inout std_logic;
		LowDataStrobeNMem	: inout std_logic;
		LowDataStrobePMem	: inout std_logic;
		ReadDataStrobeNMem	: inout std_logic;
		ReadDataStrobePMem	: inout std_logic;
		ChipSelect		: out std_logic;
		ReadEnable		: out std_logic;
		ColAccessStrobe		: out std_logic;
		RowAccessStrobe		: out std_logic;
		ClkEnable		: out std_logic;
		ClkPMem			: out std_logic;
		ClkNMem			: out std_logic;
		WriteDataMask		: out std_logic;
		UpWriteDataMask		: out std_logic;
		LowWriteDataMask	: out std_logic;
		OnDieTermination	: out std_logic;
		

		-- Memory interface
		DoneMemory	: out std_logic;
		EndRst		: out std_logic;
		ReadMem		: in std_logic;
		Precharge	: in std_logic;
		EnableMemoryInt	: in std_logic;
		DataMemIntIn	: in std_logic_vector(DATA_L - 1 downto 0);
		AddressMemInt	: in std_logic_vector(ADDR_L - 1 downto 0);
		DataMemIntOut	: out std_logic_vector(DATA_L - 1 downto 0);

	);
	end component;

end package mem_phy_pkg;
