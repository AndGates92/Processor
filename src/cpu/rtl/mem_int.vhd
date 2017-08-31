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
	MemoryReady		: out std_logic;
	InitializationCompleted	: out std_logic;
	ReadMem			: in std_logic;
	EnableMemoryInt		: in std_logic; -- Valid command signal
	DataMemIntIn		: in std_logic_vector(DATA_L - 1 downto 0);
	AddressMemInt		: in std_logic_vector(ADDR_L - 1 downto 0);
	DataMemIntOut		: out std_logic_vector(DATA_L - 1 downto 0)

);
end entity mem_int;

architecture rtl of mem_int is

	signal StateC, StateN		: std_logic_vector(STATE_MEM_L - 1 downto 0);
	signal CommandC, CommandN	: std_logic_vector(CMD_MEM_INT_L - 1 downto 0);
	signal CommandDelC, CommandDelN	: std_logic_vector(CMD_MEM_INT_L - 1 downto 0);

	signal CountC, CountN		: std_logic_vector(COUNTER_L - 1 downto 0);

	signal ColC, ColN		: std_logic_vector(COL_L - 1 downto 0);
	signal RowC, RowN		: std_logic_vector(ROW_L - 1 downto 0);

	signal PrechargeC, PrechargeN		: std_logic;
	signal ReadC, ReadN			: std_logic;
	signal NewBankC, NewBankN, NewBank	: std_logic;
	signal ValidC, ValidN			: std_logic;

	signal InitSecPrechargeC, InitSecPrechargeN	std_logic;

	signal ModeRegC, ModeRegN			: std_logic_vector(ADDR_MEM_L - 1 downto 0);
	signal ExtModeReg1C, ExtModeReg1N		: std_logic_vector(ADDR_MEM_L - 1 downto 0);
	signal ExtModeReg2C, ExtModeReg2N		: std_logic_vector(ADDR_MEM_L - 1 downto 0);
	signal ExtModeReg3C, ExtModeReg3N		: std_logic_vector(ADDR_MEM_L - 1 downto 0);

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

	signal LastCmdRstC, LastCmdRstN			: std_logic;
	signal LastCmdRstC, LastCmdRstN			: std_logic;

	signal ActiveTransC, ActiveTransN		: std_logic_vector(int_to_bit_num(MAX_TRANS_NUM) - 1 downto 0);
	signal CountTransC, CountTransN			: array(0 to MAX_TRANS_NUM - 1) of unsigned(R_W_COUNT_L - 1 downto 0);
	signal ValidTransC, ValidTransN			: std_logic_vector(MAX_TRANS_NUM - 1 downto 0);
	signal ReadTransVecC, ReadTransVecN		: std_logic_vector(MAX_TRANS_NUM - 1 downto 0);

begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then

			StateC <= IDLE;
			CommandC <= CMD_ALL_BANKS_PRECHARGE;
			CommandDelC <= CMD_ALL_BANKS_PRECHARGE;

			ActiveTransC <= (others => '0');
			ValidTransC <= (others => '0');
			ReadTransC <= (others => '0');
			CountTransC <= (others => (others => '0'));

			ColC <= (others => '0');
			RowC <= (others => '0');

			ModeRegC <= (others => '0');
			ExtModeReg1C <= (others => '0');
			ExtModeReg2C <= (others => '0');
			ExtModeReg3C <= (others => '0');

			CountC <= (others => '0');

			ReadC <= '0';
			NewBankC <= '0';
			ValidC <= '0';
			PrechargeC <= '0';

			LastCmdRstC <= '0';

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

			InitSecPrechargeC <= '0';

		elsif ((clk'event) and (clk = '1')) then

			StateC <= StateN;
			CommandC <= CommandN;
			CommandDelC <= CommandDelN;

			ActiveTransC <= ActivetransN;
			ValidTransC <= ValidTransN;
			ReadTransC <= ReadTransN;
			CountTransC <= CountTransN;

			RowC <= RowN;
			ColC <= ColN;

			ModeRegC <= ModeRegN;
			ExtModeReg1C <= ExtModeReg1N;
			ExtModeReg2C <= ExtModeReg2N;
			ExtModeReg3C <= ExtModeReg3N;

			CountC <= CountN;

			ReadC <= ReadN;
			NewBankC <= NewBankN;
			ValidC <= ValidN;
			PrechargeC <= PrechargeN;

			LastCmdRstC <= LastCmdRstN;

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

			InitSecPrechargeC <= InitSecPrechargeN;

		end if;
	end process reg;

	state_det: process(StateC, EnableMemoryInt, Precharge, ReadMem, rst)
	begin
		StateN <= StateC; -- avoid latches
		if (StateC = IDLE) then
			if (rst = '1') then
				StateN <= RESET;
			elsif (EnableMemoryInt = '1') and (PrechargeC = '1') and (ReadMemC = '1') then
				StateN <= READ_PRECHARGE;
			elsif (EnableMemoryInt = '1') and (PrechargeC = '0') and (ReadMemC = '1') then
				StateN <= READ;
			elsif (EnableMemoryInt = '1') and (PrechargeC = '1') and (ReadMemC = '0') then
				StateN <= WRITE_PRECHARGE;
			elsif (EnableMemoryInt = '1') and (PrechargeC = '0') and (ReadMemC = '0') then
				StateN <= WRITE;
			else
				StateN <= StateC;
			end if;
		elsif (StateC = RESET) then
			if (LastCmdRstC = '1') and (CommandC = CMD_ALL_BANKS_PRECHARGE) then
				StateN <= SET_REG;
			else
				StateN <= StateC;
			end if;
		elsif (StateC = WRITE) then
			if (CountC = READ_WRITE_LATENCY - 1) and (PrechargeC = '1') and (ReadMemC = '1') and (ValidC = '1') then
				StateN <= READ_PRECHARGE;
			elsif (CountC = READ_WRITE_LATENCY - 1) and (PrechargeC = '0') and (ReadMemC = '1') and (ValidC = '1') then
				StateN <= READ;
			elsif (CountC = READ_WRITE_LATENCY - 1) and (PrechargeC = '1') and (ReadMemC = '0') and (ValidC = '1') then
				StateN <= WRITE_PRECHARGE;
			elsif (CountC = READ_WRITE_LATENCY - 1) and (PrechargeC = '0') and (ReadMemC = '0') and (ValidC = '1') then
				StateN <= WRITE;
			elsif (CountC = READ_WRITE_LATENCY - 1) and (ValidC = '0') then
				StateN <= OUTPUT_MEM;
			else
				StateN <= StateC;
			end if;
		elsif (StateC = READ) then
			if (CountC = READ_WRITE_LATENCY - 1) and (PrechargeC = '1') and (ReadMemC = '1') and (ValidC = '1') then
				StateN <= READ_PRECHARGE;
			elsif (CountC = READ_WRITE_LATENCY - 1) and (PrechargeC = '0') and (ReadMemC = '1') and (ValidC = '1') then
				StateN <= READ;
			elsif (CountC = READ_WRITE_LATENCY - 1) and (PrechargeC = '1') and (ReadMemC = '0') and (ValidC = '1') then
				StateN <= WRITE_PRECHARGE;
			elsif (CountC = READ_WRITE_LATENCY - 1) and (PrechargeC = '0') and (ReadMemC = '0') and (ValidC = '1') then
				StateN <= WRITE;
			elsif (CountC = READ_WRITE_LATENCY - 1) and (ValidC = '0') then
				StateN <= OUTPUT_MEM;
			else
				StateN <= StateC;
			end if;
		elsif (StateC = WRITE_PRECHARGE) then
			if (CountC = READ_WRITE_LATENCY - 1) and (PrechargeC = '1') and (ReadMemC = '1') and (ValidC = '1') then
				StateN <= READ_PRECHARGE;
			elsif (CountC = READ_WRITE_LATENCY - 1) and (PrechargeC = '0') and (ReadMemC = '1') and (ValidC = '1') then
				StateN <= READ;
			elsif (CountC = READ_WRITE_LATENCY - 1) and (PrechargeC = '1') and (ReadMemC = '0') and (ValidC = '1') then
				StateN <= WRITE_PRECHARGE;
			elsif (CountC = READ_WRITE_LATENCY - 1) and (PrechargeC = '0') and (ReadMemC = '0') and (ValidC = '1') then
				StateN <= WRITE;
			elsif (CountC = READ_WRITE_LATENCY - 1) and (ValidC = '0') then
				StateN <= OUTPUT_MEM;
			else
				StateN <= StateC;
			end if;
		elsif (StateC = READ_PRECHARGE) then
			if (CountC = READ_WRITE_LATENCY - 1) and (PrechargeC = '1') and (ReadMemC = '1') and (ValidC = '1') then
				StateN <= READ_PRECHARGE;
			elsif (CountC = READ_WRITE_LATENCY - 1) and (PrechargeC = '0') and (ReadMemC = '1') and (ValidC = '1') then
				StateN <= READ;
			elsif (CountC = READ_WRITE_LATENCY - 1) and (PrechargeC = '1') and (ReadMemC = '0') and (ValidC = '1') then
				StateN <= WRITE_PRECHARGE;
			elsif (CountC = READ_WRITE_LATENCY - 1) and (PrechargeC = '0') and (ReadMemC = '0') and (ValidC = '1') then
				StateN <= WRITE;
			elsif (CountC = READ_WRITE_LATENCY - 1) and (ValidC = '0') then
				StateN <= OUTPUT_MEM;
			else
				StateN <= StateC;
			end if;
		elsif (StateC = SELF_REFRESH) then
			StateN <= IDLE;
		elsif (StateC = AUTO_REFRESH) then
			StateN <= IDLE;
		elsif (StateC = SET_REG) then
			if (CommandC = CMD_EXT_MODE_REG_SET_3) then
				StateN <= OUTPUT;
			else
				StateN <= StateC;
			end if;
		elsif (StateC = OUTPUT) then
			StateN <= IDLE;
		else
			StateN <= IDLE;
		end if;
	end process state_det;

	cmd_det: process(CmmandC, EnableMemoryInt, Precharge, ReadMem, rst)
	begin
		CommandN <= CommandC; -- avoid latches
		if (CommandC = CMD_ALL_BANKS_PRECHARGE) then
			if (rst = '1') then
				CommandN <= CMD_POWER_UP;
			elsif (StateC = RESET) and (CountC = PRECHARGE_TIME - 1) and (InitSecPrechargeC = '0') then
				CommandN <= CMD_DESEL;
			elsif (StateC = RESET) and (CountC = PRECHARGE_TIME - 1) then
				CommandN <= CMD_AUTO_REF;
			elsif (StateC = SET_REG) then
				CommandN <= CMD_MODE_REG_SET;
			elsif (StateC = WRITE) or (StateC = WRITE_PRECHARGE) or (StateC = READ) or (StateC = READ_PRECHARGE) then
				CommandN <= CMD_BANK_ACTIV;
			else
				CommandN <= CommandC;
			end if;
		elsif (CommandC = CMD_POWER_UP) then
			if (CountC = INIT_CLK - 1) then
				CommandN <= CMD_NOP;
			else
				CommandN <= CommandC;
			end if;
		elsif (CommandC = CMD_NOP) then
			if ((StateC = RESET) and (CountC = INIT_NOP - 1)) or (StateC = OUTPUT_MEM) then
				CommandN <= CMD_ALL_BANKS_PRECHARGE;
			elsif (NewBankC = '1') and (CountC = READ_WRITE_LATENCY) then
				CommandN <= CMD_BANK_PRECHARGE;
			elsif (StateC = WRITE) and (CountC = READ_WRITE_LATENCY) then
				CommandN <= CMD_WRITE;
			elsif (StateC = WRITE_PRECHARGE) and (CountC = READ_WRITE_LATENCY) then
				CommandN <= CMD_WRITE_PRECHARGE;
			elsif (StateC = READ) and (CountC = READ_WRITE_LATENCY) then
				CommandN <= CMD_READ;
			elsif (StateC = WRITE_PRECHARGE) and (CountC = READ_WRITE_LATENCY) then
				CommandN <= CMD_READ_PRECHARGE;
			else
				CommandN <= CommandC;
			end if;
		elsif (CommandC = CMD_DESEL) then
			if (StateC = RESET) and (CountC = INIT_NOP - 1) then
				CommandN <= CMD_EXT_MODE_REG_SET_2;
			elsif (StateC /= RESET) then
				CommandN <= CMD_ALL_BANKS_PRECHARGE;
			else
				CommandN <= CommandC;
			end if;
		elsif (CommandC = CMD_MODE_REG_SET) then
			if i(((StateC = RESET) and (InitSecPrechargeC = '1')) or (StateC = SET_REG)) and (CountC = REG_TIME - 1) then
				CommandN <= CMD_EXT_MODE_REG_SET_1;
			elsif (CountC = REG_TIME - 1) then
				CommandN <= CMD_ALL_BANKS_PRECHARGE;
			else
				CommandN <= CommandC;
			end if;
		elsif (CommandC = CMD_EXT_MODE_REG_SET_1) then
			if (StateC = RESET) and (CountC = REG_TIME - 1) and (InitSecPrechargeC = '0') then
				CommandC <= CMD_MODE_REG_SET;
			elsif (StateC = RESET) and (CountC = 2*REG_TIME - 1) then
				CommandN <= CMD_ALL_BANKS_PRECHARGE;
			elsif (StateC = SET_REG) and (CountC = REG_TIME - 1) then
				CommandN <= CMD_EXT_MODE_REG_SET_2;
			else
				CommandN <= CommandC;
			end if;
		elsif (CommandC = CMD_EXT_MODE_REG_SET_2) then
			if (CountC = REG_TIME - 1) then
				CommandC <= CMD_EXT_MODE_REG_SET_3;
			else
				CommandN <= CommandC;
			end if;
		elsif (CommandC = CMD_EXT_MODE_REG_SET_3) then
			if (StateC = RESET) and (CountC = REG_TIME - 1) then
				CommandC <= CMD_EXT_MODE_REG_SET_1;
			elsif (CountC = REG_TIME - 1) then
				CommandN <= CMD_ALL_BANKS_PRECHARGE;
			else
				CommandN <= CommandC;
			end if;
		elsif (CommandC = CMD_AUTO_REF) then
			if (StateC = RESET) and (CountC = INIT_AUTO_REF - 1) then
				CommandN <= CMD_MODE_REG_SET;
			elsif (CountC = AUTO_REF_TIME - 1) then
				CommandN <= CMD_ALL_BANKS_PRECHARGE;
			else
				CommandN <= CommandC;
			end if;
		elsif (CommandC = CMD_SELF_REF_ENTRY_1) then
			CommandN <= CMD_ALL_BANKS_PRECHARGE;
		elsif (CommandC = CMD_SELF_REF_ENTRY_2) then
			CommandN <= CMD_ALL_BANKS_PRECHARGE;
		elsif (CommandC = CMD_SELF_REF_EXIT_1) then
			CommandN <= CMD_ALL_BANKS_PRECHARGE;
		elsif (CommandC = CMD_SELF_REF_EXIT_2) then
			CommandN <= CMD_ALL_BANKS_PRECHARGE;
		elsif (CommandC = CMD_BANK_PRECHARGE) then
			if (StateC = WRITE) and (CountC = PRECHARGE_TIME - 1) then
				CommandN <= CMD_WRITE;
			elsif (StateC = WRITE_PRECHARGE) and (CountC = PRECHARGE_TIME - 1) then
				CommandN <= CMD_WRITE_PRECHARGE;
			elsif (StateC = READ) and (CountC = PRECHARGE_TIME - 1) then
				CommandN <= CMD_READ;
			elsif (StateC = WRITE_PRECHARGE) and (CountC = PRECHARGE_TIME - 1) then
				CommandN <= CMD_READ_PRECHARGE;
			else
				CommandN <= CommandC;
			end if;
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
			if (StateC = WRITE) then
				CommandN <= CMD_NOP;
			elsif (StateC = OUTPUT) then
				CommandN <= CMD_ALL_BANKS_PRECHARGE;
			else
				CommandN <= CommandC;
			end if;
		elsif (CommandC = CMD_READ) then
			if (StateC = READ) then
				CommandN <= CMD_NOP;
			elsif (StateC = OUTPUT) then
				CommandN <= CMD_ALL_BANKS_PRECHARGE;
			else
				CommandN <= CommandC;
			end if;
		elsif (CommandC = CMD_WRITE_PRECHARGE) then
			if (StateC = WRITE_PRECHARGE) then
				CommandN <= CMD_NOP;
			elsif (StateC = OUTPUT) then
				CommandN <= CMD_ALL_BANKS_PRECHARGE;
			else
				CommandN <= CommandC;
			end if;
		elsif (CommandC = CMD_READ_PRECHARGE) then
			if (StateC = READ_PRECHARGE) then
				CommandN <= CMD_WRITE_PRECHARGE;
			elsif (StateC = OUTPUT) then
				CommandN <= CMD_ALL_BANKS_PRECHARGE;
			else
				CommandN <= CommandC;
			end if;
		elsif (CommandC = CMD_POWER_DOWN_ENTRY_1) then
			CommandN <= CMD_POWER_DOWN_ENTRY_2;
		elsif (CommandC = CMD_POWER_DOWN_EXIT_1) then
			CommandN <= CMD_POWER_DOWN_;
		elsif (CommandC = CMD_POWER_DOWN_ENTRY_2) then
			CommandN <= CMD_POWER_DOWN_EXIT_1;
		elsif (CommandC = CMD_POWER_DOWN_EXIT_2) then
			if (ClkEnableC = '1') and (StateC = PRECHARGE_POWER_DOWN) then
				CommandN <= CMD_ALL_BANKS_PRECHARGE;
			elsif (ClkEnableC = '1') and ((StateC = WRITE) or (StateC = READ) or (StateC = READ_PRECHARGE) or (StateC = WRITE_PRECHARGE)) then
				CommandN <= CMD_BANK_PRECHARGE;
			else
				CommandN <= CommandC;
			end if;
		else
			CommandN <= CommandC;
		end if;
	end process cmd_det;

	CommandDelN <= CommandC;

	ClkEnableN <= '0' when (CommandC = CMD_POWER_UP) or (CommandC = CMD_SELF_REF_EXIT_1) or (CommandC = CMD_SELF_REF_ENTRY_2) or (CommandC = CMD_POWER_DOWN_EXIT_1) or (CommandC = CMD_POWER_DOWN_ENTRY_2) else '1';

	nChipSelectN <= '1' when (CommandC = CMD_DESEL) else '0';

	nRowAccessStrobeN <= '0' when (CommandC = CMD_MODE_REG_SET) or (CommandC = CMD_EXT_MODE_REG_SET_1) or (CommandC = CMD_EXT_MODE_REG_SET_2) or (CommandC = CMD_AUTO_REF) or (CommandC = CMD_SELF_REF_ENTRY_1) or (CommandC = CMD_SELF_REF_ENTRY_2) or (CommandC = CMD_BANK_PRECHARGE) or (CommandC = CMD_ALL_BANKS_PRECHARGE) or (CommandC = CMD_BANK_ACTIV) else '1';

	nColAccessStrobeN <= '0' when (CommandC = CMD_MODE_REG_SET) or (CommandC = CMD_EXT_MODE_REG_SET_1) or (CommandC = CMD_EXT_MODE_REG_SET_2) or (CommandC = CMD_AUTO_REF) or (CommandC = CMD_SELF_REF_ENTRY_1) or (CommandC = CMD_SELF_REF_ENTRY_2) or (CommandC = CMD_WRITE_PRECHARGE) or (CommandC = CMD_READ_PRECHARGE) or (CommandC = CMD_WRITE) or (CommandC = CMD_READ) else '1';

	nWriteEnableN <= '0' when (CommandC = CMD_MODE_REG_SET) or (CommandC = CMD_EXT_MODE_REG_SET_1) or (CommandC = CMD_EXT_MODE_REG_SET_2) or (CommandC = CMD_BANK_PRECHARGE) or (CommandC = CMD_ALL_BANKS_PRECHARGE) or (CommandC = CMD_WRITE) or (CommandC = CMD_WRITE_PRECHARGE) else '1';

	BankSelMemN <=	(others => '0') when (CommandC = CMD_MODE_REG_SET) else
			(0 => '1', others => '0') when (CommandC = CMD_EXT_MODE_REG_SET_1) else
			(1 => '1', others => '0') when (CommandC = CMD_EXT_MODE_REG_SET_2) else
			((1 downto 0) => "11", others => '0') when (CommandC = CMD_EXT_MODE_REG_SET_3) else
			AddressMemInt(ADDR_L - 1 downto ADDR_L - BANK_L) when (EnableMemoryInt = '1') else
			BankSelMemC;

	AddressMemN <=	(10 => '1', others => '0') when (CommandC = CMD_ALL_BANKS_PRECHARGE) else
			RowC when (CommandC = CMD_BANK_ACTIV) else
			((PrechargeC & ColC) => (COL_L downto 0), others => '0') when (CommandC = CMD_WRITE) or (CommandC = CMD_WRITE_PRECHARGE) or (CommandC = CMD_READ) or (CommandC = CMD_READ_PRECHARGE) else
			(others => '0') when (CommandC = CMD_BANK_PRECHARGE) else
			ModeReg when (CommandC = CMD_MODE_REG_SET) else
			ExtModeReg1N when (CommandC = CMD_EXT_MODE_REG_SET_1) else
			ExtModeReg2 when (CommandC = CMD_EXT_MODE_REG_SET_2) else
			ExtModeReg3 when (CommandC = CMD_EXT_MODE_REG_SET_3) else
			AddressMemC;

	ModeReg <=	(others => '0') when (StateC = RESET) and  (InitSecPrechargeC = '0') else
			((11 downto 9) => "101", others => '0') when (StateC = RESET) and  (InitSecPrechargeC = '1') else
			PowerExitSlow & WriteRec & DDLRes & '0' & nCASLatency & BurtsType & BurstLength;

	ExtModeReg1N <=	((9 downto 7) => "111", others => '0') when (StateC = RESET) and (CountC = ZERO_COUNT) and (InitSecPrechargeC = '1') else
			(others => '0') when (StateC = RESET) and (((CountC = REG_TIME - 1) and (InitSecPrechargeC = '1')) or ((CountC = ZERO_COUNT) and (InitSecPrechargeC = '0'))) else
			OutBuffEn & RDQSEn & nDQSEn & "000" & ODTEn(1) & AddLatency & ODTEn(0) & DriverCtrl & DDLEn when (StateC = SET_REG) else
			ExtModeReg1C;

	ExtModeReg2 <= (others => '0') when (StateC = RESET) else (7 => HighTempSelfRefresh, others => '0');
	ExtModeReg3 <= (others => '0');

	CountN <= (others => '0') when (CommandC /= CommandDelC) else CountC + 1;

	-- FIFO signals
	PrechargeN <=	Precharge when (EnableMemoryInt = '1') else PrechargeC;
	ReadN <=	ReadMem when (EnableMemoryInt = '1') else ReadC;

	ValidN <=	'1' when (EnableMemoryInt = '1') else
			'0' when (CommandC = CMD_WRITE) or (CommandC = CMD_WRITE_PRECHARGE) or (CommandC = CMD_READ) or (CommandC = CMD_READ_PRECHARGE) else
			ValidC;

	NewBank <=	'1' when (AddressMemInt(ADDR_L - 1 downto ADDR_L - BANK_L) /= BankSelMemC) and (EnableMemoryInt = '1') else
			'0';
	-- end of FIFO signals

	InitSecPrechargeN <=	'1' when (StateC = RESET) and (CommandC = CMD_ALL_BANKS_PRECHARGE) else
				'0' when (rst = '1') else
				InitSecPrechargeC;

	LastCmdRstN <=	'1' when (AddressMemC(9 downto 7) = "111") else
			'0' when (rst = '1') else
			LastCmdRstC;

	COUNTER_TRANSACTION_GEN: for i in 0 to (MAX_TRANS_NUM - 1) generate
			CountTransN(i) <= CountTransC(i) + 1 when (ValidTransC(i) = '1') else (others => '0');
	end generate COUNTER_TRANSACTION_GEN;

