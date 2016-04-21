library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.mem_int_pkg.all;

entity mem_int is
port (

	rst		: in std_logic;
	clk		: in std_logic;

	-- Memory access
	AddressMem		: out std_logic_vector(ADDR_MEM_L - 1 downto 0);
	BankSelMem		: out std_logic_vector(BANK_L - 1 downto 0);
	DataMem			: inout std_logic_vector(DATA_L - 1 downto 0);
	nDataStrobeMem		: inout std_logic;
	pDataStrobeMem		: inout std_logic;
	nUpDataStrobeMem	: inout std_logic;
	pUpDataStrobeMem	: inout std_logic;
	nLowDataStrobeMem	: inout std_logic;
	pLowDataStrobeMem	: inout std_logic;
	nReadDataStrobeMem	: inout std_logic;
	pReadDataStrobeMem	: inout std_logic;
	nChipSelect		: out std_logic;
	ReadEnable		: out std_logic;
	nColAccessStrobe	: out std_logic;
	nRowAccessStrobe	: out std_logic;
	ClkEnable		: out std_logic;
	pClkMem			: out std_logic;
	nClkMem			: out std_logic;
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
	DataMemIntOut	: out std_logic_vector(DATA_L - 1 downto 0)

);
end entity mem_int;

architecture rtl of mem_int is

	signal StateC, StateN		: std_logic_vector(STATE_MEM_L - 1 downto 0);
	signal CommandC, Command	: std_logic_vector(CMD_MEM_INT_L - 1 downto 0);

	signal CountC, CountN		: std_logic_vector(COUNTER_L - 1 downto 0);

	signal ColC, ColN		: std_logic_vector(COL_L - 1 downto 0);
	signal RowC, RowN		: std_logic_vector(ROW_L - 1 downto 0);

	signal AddressMemC, AddressMemN			: std_logic_vector(ADDR_MEM_L - 1 downto 0);
	signal BankSelMemC, BankSelMemN			: std_logic_vector(BANK_L - 1 downto 0);
	signal DataMemC, DataMemN			: std_logic_vector(DATA_L - 1 downto 0);
	signal nDataStrobeMemC, nDataStrobeMemN		: std_logic;
	signal pDataStrobeMemC, pDataStrobeMemN		: std_logic;
	signal nUpDataStrobeMemC, nUpDataStrobeMemN	: std_logic;
	signal pUpDataStrobeMemC, pUpDataStrobeMemN	: std_logic;
	signal nLowDataStrobeMemC, nLowDataStrobeMemN	: std_logic;
	signal pLowDataStrobeMemC, pLowDataStrobeMemN	: std_logic;
	signal nReadDataStrobeMemC, nReadDataStrobeMemN	: std_logic;
	signal pReadDataStrobeMemC, pReadDataStrobeMemN	: std_logic;
	signal nChipSelectC, nChipSelectN		: std_logic;
	signal ReadEnableC, ReadEnableN			: std_logic;
	signal nColAccessStrobeC, nColAccessStrobeN	: std_logic;
	signal nRowAccessStrobeC, nRowAccessStrobeN	: std_logic;
	signal ClkEnableC, ClkEnableN			: std_logic;
	signal pClkMemC, pClkMemN			: std_logic;
	signal nClkMemC, nClkMemN			: std_logic;
	signal WriteDataMaskC, WriteDataMaskN		: std_logic;
	signal UpWriteDataMaskC, UpWriteDataMaskN	: std_logic;
	signal LowWriteDataMaskC, LowWriteDataMaskN	: std_logic;
	signal OnDieTerminationC, OnDieTerminationN	: std_logic;

begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then

			StateC <= IDLE;
			CommandC <= CMD_IDLE;

			CountC <= (others => '0');

			AddressMemC <= (others => '0');
			BankSelMemC <= (others => '0');
			DataMemC <= (others => '0');
			DataStrobeNMemC <= '0';
			DataStrobePMemC <= '1';
			UpDataStrobeNMemC <= '0';
			UpDataStrobePMemC <= '1';
			LowDataStrobeNMemC <= '0';
			LowDataStrobePMemC <= '1';
			ReadDataStrobeNMemC <= '0';
			ReadDataStrobePMemC <= '1';
			ChipSelectC <= '1';
			ReadEnableC <= '0';
			ColAccessStrobeC <= '1';
			RowAccessStrobeC <= '1';
			ClkEnableC <= '0';
			ClkPMemC <= '1';
			ClkNMemC <= '0';
			WriteDataMaskC <= '0';
			UpWriteDataMaskC <= '0';
			LowWriteDataMaskC <= '0';
			OnDieTerminationC <= '0';

		elsif (rising_edge(clk)) then

			StateC <= StateN;
			CommandC <= CommandN;

			CountC <= CountN;

			AddressMemC <= AddressMemN;
			BankSelMemC <= BankSelMemN;
			DataMemC <= DataMemN;
			DataStrobeNMemC <= DataStrobeNMemN;
			DataStrobePMemC <= DataStrobePMemN;
			UpDataStrobeNMemC <= UpDataStrobeNMemN;
			UpDataStrobePMemC <= UpDataStrobePMemN;
			LowDataStrobeNMemC <= LowDataStrobeNMemN;
			LowDataStrobePMemC <= LowDataStrobePMemN;
			ReadDataStrobeNMemC <= ReadDataStrobeNMemN;
			ReadDataStrobePMemC <= ReadDataStrobePMemN;
			ChipSelectC <= ChipSelectN;
			ReadEnableC <= ReadEnableN;
			ColAccessStrobeC <= ColAccessStrobeN;
			RowAccessStrobeC <= RowAccessStrobeN;
			ClkEnableC <= ClkEnableN;
			ClkPMemC <= ClkPMemN;
			ClkNMemC <= ClkNMemN;
			WriteDataMaskC <= WriteDataMaskN;
			UpWriteDataMaskC <= UpWriteDataMaskN;
			LowWriteDataMaskC <= LowWriteDataMaskN;
			OnDieTerminationC <= OnDieTerminationN;

		end if;
	end process reg;

	state_det: process(StateC, EnableMemoryInt, Precharge, ReadMem, rst)
	begin
		StateN <= StateC; -- avoid latches
		if (StateC = IDLE) then
			if (rst = '1') then
				StateN <= RESET;
			elsif (EnableMemoryInt = '1') and (Precharge = '1') and (ReadMem = '1') then
				StateN <= READ_PRECHARGE;
			elsif (EnableMemoryInt = '1') and (Precharge = '0') and (ReadMem = '1') then
				StateN <= READ;
			elsif (EnableMemoryInt = '1') and (Precharge = '1') and (ReadMem = '0') then
				StateN <= WRITE_PRECHARGE;
			elsif (EnableMemoryInt = '1') and (Precharge = '0') and (ReadMem = '0') then
				StateN <= WRITE;
			else
				StateN <= StateC;
			end if;
		elsif (StateC = RESET) then
			StateN <= OUTPUT;
		elsif (StateC = WRITE) then
			StateN <= OUTPUT;
		elsif (StateC = READ) then
			StateN <= OUTPUT;
		elsif (StateC = WRITE_PRECHARGE) then
			StateN <= OUTPUT;
		elsif (StateC = READ_PRECHARGE) then
			StateN <= OUTPUT;
		elsif (StateC = SELF_REFRESH) then
			StateN <= IDLE;
		elsif (StateC = AUTO_REFRESH) then
			StateN <= IDLE;
		elsif (StateC = MRS) then
			StateN <= IDLE;
		elsif (StateC = EMRS_1) then
			StateN <= IDLE;
		elsif (StateC = EMRS_2) then
			StateN <= IDLE;
		elsif (StateC = OUTPUT) then
			StateN <= IDLE;
		else
			StateN <= IDLE;
		end if;
	end process state_det;

	cmd_det: process(CmmandC, EnableMemoryInt, Precharge, ReadMem, rst)
	begin
		CommandN <= CommandC; -- avoid latches
		if (CommandC = CMD_IDLE) then
			if (rst = '1') then
				CommandN <= CMD_POWER_UP;
			elsif (EnableMemoryInt = '1') then
				CommandN <= CMD_BANK_ACTIV;
			else
				CommandN <= CommandC;
			end if;
		elsif (CommandC = CMD_POWER_UP) then
			CommandN <= CMD_IDLE;
		elsif (CommandC = CMD_NOP) then
			CommandN <= CMD_IDLE;
		elsif (CommandC = CMD_DESEL) then
			CommandN <= CMD_IDLE;
		elsif (CommandC = CMD_MODE_REG_SET) then
			CoomandN <= CMD_IDLE;
		elsif (CommandC = CMD_EXT_MODE_REG_SET_1) then
			CoomandN <= CMD_IDLE;
		elsif (CommandC = CMD_EXT_MODE_REG_SET_2) then
			CoomandN <= CMD_IDLE;
		elsif (CommandC = CMD_AUTO_REF) then
			CommandN <= CMD_IDLE;
		elsif (CommandC = CMD_SELF_REF_ENTRY_1) then
			CommandN <= CMD_IDLE;
		elsif (CommandC = CMD_SELF_REF_ENTRY_2) then
			CommandN <= CMD_IDLE;
		elsif (CommandC = CMD_SELF_REF_EXIT_1) then
			CommandN <= CMD_IDLE;
		elsif (CommandC = CMD_SELF_REF_EXIT_2) then
			CommandN <= CMD_IDLE;
		elsif (CommandC = CMD_BANK_PRECHARGE) then
			CommandN <= CMD_IDLE;
		elsif (CommandC = CMD_ALL_BANKS_PRECHARGE) then
			CommandN <= CMD_IDLE;
		elsif (CommandC = CMD_BANK_ACTIV) then
			if (ClkEnableC = '0') then
				CommandN <= CMD_POWER_DOWN_ENTRY_1;
			elsif (StateC = WRITE) then
				CommandN <= CMD_WRITE;
			elsif (StateC = WRITE_PRECHARGE) then
				CommandN <= CMD_WRITE_PRECHARGE;
			elsif (StateC = READ) then
				CommandN <= CMD_READ;
			elsif (StateC = READ_PRECHARGE) then
				CommandN <= CMD_READ_PRECHARGE;
			else
				CommandN <= CommandC;
			end if;
		elsif (CommandC = CMD_WRITE) then
			if (StateC = WRITE_PRECHARGE) then
				CommandN <= CMD_WRITE_PRECHARGE;
			elsif (StateC = READ) then
				CommandN <= CMD_READ;
			elsif (StateC = READ_PRECHARGE) then
				CommandN <= CMD_READ_PRECHARGE;
			elsif (StateC = OUTPUT) then
				CommandN <= CMD_ALL_BANKS_PRECHARGE;
			else
				CommandN <= CommandC;
			end if;
		elsif (CommandC = CMD_READ) then
			if (StateC = WRITE) then
				CommandN <= CMD_WRITE;
			elsif (StateC = WRITE_PRECHARGE) then
				CommandN <= CMD_WRITE_PRECHARGE;
			elsif (StateC = READ_PRECHARGE) then
				CommandN <= CMD_READ_PRECHARGE;
			elsif (StateC = OUTPUT) then
				CommandN <= CMD_ALL_BANKS_PRECHARGE;
			else
				CommandN <= CommandC;
			end if;
		elsif (CommandC = CMD_WRITE_PRECHARGE) then
			if (StateC = WRITE) then
				CommandN <= CMD_WRITE;
			elsif (StateC = READ) then
				CommandN <= CMD_READ;
			elsif (StateC = READ_PRECHARGE) then
				CommandN <= CMD_READ_PRECHARGE;
			elsif (StateC = OUTPUT) then
				CommandN <= CMD_ALL_BANKS_PRECHARGE;
			else
				CommandN <= CommandC;
			end if;
		elsif (CommandC = CMD_READ_PRECHARGE) then
			if (StateC = WRITE) then
				CommandN <= CMD_WRITE;
			elsif (StateC = WRITE_PRECHARGE) then
				CommandN <= CMD_WRITE_PRECHARGE;
			elsif (StateC = READ) then
				CommandN <= CMD_READ;
			elsif (StateC = OUTPUT) then
				CommandN <= CMD_ALL_BANKS_PRECHARGE;
			else
				CommandN <= CommandC;
			end if;
		elsif (CommandC = CMD_POWER_DOWN_ENTRY_1) then
			CommandN <= CMD_POWER_DOWN_ENtRY_2;
		elsif (CommandC = CMD_POWER_DOWN_EXIT_1) then
			CommandN <= CMD_POWER_DOWN_;
		elsif (CommandC = CMD_POWER_DOWN_ENTRY_2) then
			CommandN <= CMD_POWER_DOWN_EXIT_1;
		elsif (CommandC = CMD_POWER_DOWN_EXIT_2) then
			if (ClkEnableC = '1') and (StateC = PRECHARGE_POWER_DOWN) then
				CommandN <= CMD_IDLE;
			elsif (ClkEnableC = '1') and ((StateC = WRITE) or (StateC = READ) or (StateC = READ_PRECHARGE) or (StateC = WRITE_PRECHARGE)) then
				CommandN <= CMD_BANK_PRECHARGE;
			else
				CommandN <= CommandC;
			end if;
		else
			CommandN <= CommandC;
		end if;
	end process cmd_det;

	ClkEnableN <= '0' when (CommandC = CMD_SELF_REF_EXIT_1) or (CommandC = CMD_SELF_REF_ENTRY_2) or (CommandC = CMD_POWER_DOWN_EXIT_1) or (CommandC = CMD_POWER_DOWN_ENTRY_2) else '1';

	nChipSelectN <= '1' when (CommandC = CMD_DESEL) else '0';

	nRowAccessStrobeN <= '0' when (CommandC = CMD_MODE_REG_SET) or (CommandC = CMD_EXT_MODE_REG_SET_1) or (CommandC = CMD_EXT_MODE_REG_SET_2) or (CommandC = CMD_AUTO_REF) or (CommandC = CMD_SELF_REF_ENTRY_1) or (CommandC = CMD_SELF_REF_ENTRY_2) or (CommandC = CMD_BANK_PRECHARGE) or (CommandC = CMD_ALL_BANKS_PRECHARGE) or (CommandC = CMD_BANK_ACTIV) else '1';

	nColAccessStrobeN <= '0' when (CommandC = CMD_MODE_REG_SET) or (CommandC = CMD_EXT_MODE_REG_SET_1) or (CommandC = CMD_EXT_MODE_REG_SET_2) or (CommandC = CMD_AUTO_REF) or (CommandC = CMD_SELF_REF_ENTRY_1) or (CommandC = CMD_SELF_REF_ENTRY_2) or (CommandC = CMD_WRITE_PRECHARGE) or (CommandC = CMD_READ_PRECHARGE) or (CommandC = CMD_WRITE) or (CommandC = CMD_READ) else '1';

	nWriteEnableN <= '0' when (CommandC = CMD_MODE_REG_SET) or (CommandC = CMD_EXT_MODE_REG_SET_1) or (CommandC = CMD_EXT_MODE_REG_SET_2) or (CommandC = CMD_BANK_PRECHARGE) or (CommandC = CMD_ALL_BANKS_PRECHARGE) or (CommandC = CMD_WRITE) or (CommandC = CMD_WRITE_PRECHARGE) else '1';

	BankSelMemN <=	(others => '0') when (CommandC = CMD_MODE_REG_SET) else
			(1 => '1', others => '0') when (CommandC = CMD_EXT_MODE_REG_SET_1) else
			(2 => '1', others => '0') when (CommandC = CMD_EXT_MODE_REG_SET_2) else
			AddressMemInt(ADDR_L - 1 downto ADDR_L - BANK_L) when (CommandC = CMD_IDLE) else
			BankSelMemC;

	AddressMemN <=	(10 => '1', others => '0') when (CommandC = CMD_ALL_BANKS_PRECHARGE) else
			RowC when (CommandC = CMD_BANK_ACTIV) else
			((PrechargeC & ColC) => (COL_L downto 0), others => '0') when (CommandC = CMD_WRITE) or (CommandC = CMD_WRITE_PRECHARGE) or (CommandC = CMD_READ) or (CommandC = CMD_READ_PRECHARGE) else
			(others => '0') when (CommandC = CMD_IDLE) or (CommandC = CMD_BANK_PRECHARGE) else
			AddressMemC;

	
