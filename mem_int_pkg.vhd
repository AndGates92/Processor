library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;

package mem_int_pkg is 

	constant BANK_NUM	: positive := 8;
	constant BANK_L		: positive := positive(int_to_bit_num(BANK_NUM));

	constant COL_L		: positive := 10;
	constant ROW_L		: positive := 13;

	constant ADDR_MEM_L	: positive := 13;
	constant ADDR_L		: positive := ROW_L + COL_L + BANK_L;

	constant DATA_L		: positive := 16;

	constant STATE_MEM_L	: positive := 4;

	constant IDLE			: std_logic_vector(STATE_MEM_L - 1 downto 0) := std_logic_vector(to_unsigned(0, STATE_MEM_L));
	constant OUTPUT			: std_logic_vector(STATE_MEM_L - 1 downto 0) := std_logic_vector(to_unsigned(1, STATE_MEM_L));
	constant RESET			: std_logic_vector(STATE_MEM_L - 1 downto 0) := std_logic_vector(to_unsigned(2, STATE_MEM_L));
	constant WRITE			: std_logic_vector(STATE_MEM_L - 1 downto 0) := std_logic_vector(to_unsigned(3, STATE_MEM_L));
	constant READ			: std_logic_vector(STATE_MEM_L - 1 downto 0) := std_logic_vector(to_unsigned(4, STATE_MEM_L));
	constant WRITE_PRECHARGE	: std_logic_vector(STATE_MEM_L - 1 downto 0) := std_logic_vector(to_unsigned(5, STATE_MEM_L));
	constant READ_PRECHARGE		: std_logic_vector(STATE_MEM_L - 1 downto 0) := std_logic_vector(to_unsigned(6, STATE_MEM_L));
	constant SELF_REFRESH		: std_logic_vector(STATE_MEM_L - 1 downto 0) := std_logic_vector(to_unsigned(7, STATE_MEM_L));
	constant AUTO_REFRESH		: std_logic_vector(STATE_MEM_L - 1 downto 0) := std_logic_vector(to_unsigned(8, STATE_MEM_L));
	constant MRS			: std_logic_vector(STATE_MEM_L - 1 downto 0) := std_logic_vector(to_unsigned(9, STATE_MEM_L));
	constant EMRS_1			: std_logic_vector(STATE_MEM_L - 1 downto 0) := std_logic_vector(to_unsigned(10, STATE_MEM_L));
	constant EMRS_2			: std_logic_vector(STATE_MEM_L - 1 downto 0) := std_logic_vector(to_unsigned(11, STATE_MEM_L));

	constant CMD_MEM_INT_L	: positive := 5;

	constant CMD_IDLE			: std_logic_vector(CMD_MEM_INT_L - 1 downto 0) := std_logic_vector(to_unsigned(0, CMD_MEM_INT_L));
	constant CMD_POWER_UP			: std_logic_vector(CMD_MEM_INT_L - 1 downto 0) := std_logic_vector(to_unsigned(1, CMD_MEM_INT_L));
	constant CMD_NOP			: std_logic_vector(CMD_MEM_INT_L - 1 downto 0) := std_logic_vector(to_unsigned(2, CMD_MEM_INT_L));
	constant CMD_DESEL			: std_logic_vector(CMD_MEM_INT_L - 1 downto 0) := std_logic_vector(to_unsigned(3, CMD_MEM_INT_L));
	constant CMD_MODE_REG_SET		: std_logic_vector(CMD_MEM_INT_L - 1 downto 0) := std_logic_vector(to_unsigned(4, CMD_MEM_INT_L));
	constant CMD_EXT_MODE_REG_SET_1		: std_logic_vector(CMD_MEM_INT_L - 1 downto 0) := std_logic_vector(to_unsigned(5, CMD_MEM_INT_L));
	constant CMD_EXT_MODE_REG_SET_2		: std_logic_vector(CMD_MEM_INT_L - 1 downto 0) := std_logic_vector(to_unsigned(6, CMD_MEM_INT_L));
	constant CMD_AUTO_REF			: std_logic_vector(CMD_MEM_INT_L - 1 downto 0) := std_logic_vector(to_unsigned(7, CMD_MEM_INT_L));
	constant CMD_SELF_REF_ENTRY_1		: std_logic_vector(CMD_MEM_INT_L - 1 downto 0) := std_logic_vector(to_unsigned(8, CMD_MEM_INT_L));
	constant CMD_SELF_REF_ENTRY_2		: std_logic_vector(CMD_MEM_INT_L - 1 downto 0) := std_logic_vector(to_unsigned(9, CMD_MEM_INT_L));
	constant CMD_SELF_REF_EXIT_1		: std_logic_vector(CMD_MEM_INT_L - 1 downto 0) := std_logic_vector(to_unsigned(10, CMD_MEM_INT_L));
	constant CMD_SELF_REF_EXIT_2		: std_logic_vector(CMD_MEM_INT_L - 1 downto 0) := std_logic_vector(to_unsigned(11, CMD_MEM_INT_L));
	constant CMD_BANK_PRECHARGE		: std_logic_vector(CMD_MEM_INT_L - 1 downto 0) := std_logic_vector(to_unsigned(12, CMD_MEM_INT_L));
	constant CMD_ALL_BANKS_PRECHARGE	: std_logic_vector(CMD_MEM_INT_L - 1 downto 0) := std_logic_vector(to_unsigned(13, CMD_MEM_INT_L));
	constant CMD_BANK_ACTIV			: std_logic_vector(CMD_MEM_INT_L - 1 downto 0) := std_logic_vector(to_unsigned(14, CMD_MEM_INT_L));
	constant CMD_WRITE			: std_logic_vector(CMD_MEM_INT_L - 1 downto 0) := std_logic_vector(to_unsigned(15, CMD_MEM_INT_L));
	constant CMD_READ			: std_logic_vector(CMD_MEM_INT_L - 1 downto 0) := std_logic_vector(to_unsigned(16, CMD_MEM_INT_L));
	constant CMD_WRITE_PRECHARGE		: std_logic_vector(CMD_MEM_INT_L - 1 downto 0) := std_logic_vector(to_unsigned(17, CMD_MEM_INT_L));
	constant CMD_READ_PRECHARGE		: std_logic_vector(CMD_MEM_INT_L - 1 downto 0) := std_logic_vector(to_unsigned(18, CMD_MEM_INT_L));
	constant CMD_POWER_DOWN_ENTRY_1		: std_logic_vector(CMD_MEM_INT_L - 1 downto 0) := std_logic_vector(to_unsigned(19, CMD_MEM_INT_L));
	constant CMD_POWER_DOWN_ENTRY_2		: std_logic_vector(CMD_MEM_INT_L - 1 downto 0) := std_logic_vector(to_unsigned(20, CMD_MEM_INT_L));
	constant CMD_POWER_DOWN_EXIT_1		: std_logic_vector(CMD_MEM_INT_L - 1 downto 0) := std_logic_vector(to_unsigned(21, CMD_MEM_INT_L));
	constant CMD_POWER_DOWN_EXIT_2		: std_logic_vector(CMD_MEM_INT_L - 1 downto 0) := std_logic_vector(to_unsigned(22, CMD_MEM_INT_L));


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

end package mem_int_pkg;
