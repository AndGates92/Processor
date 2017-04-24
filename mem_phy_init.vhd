library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.mem_int_pkg.all;

entity mem_phy_init is
port (

	rst		: in std_logic;
	clk		: in std_logic;

	-- Memory access
	AddressMem		: out std_logic_vector(ADDR_MEM_L - 1 downto 0);
	BankSelMem		: out std_logic_vector(BANK_L - 1 downto 0);
	nChipSelect		: out std_logic;
	ReadEnable		: out std_logic;
	nColAccessStrobe	: out std_logic;
	nRowAccessStrobe	: out std_logic;
	ClkEnable		: out std_logic;
	OnDieTermination	: out std_logic;
	

	-- Memory interface
	InitializationCompleted	: out std_logic

);
end entity mem_phy_init;

architecture rtl of mem_phy_init is
	constant zero_cnt_value	: unsigned(INIT_CNT_L - 1 downto 0) = (others => '0'); 
	constant decr_value	: unsigned(INIT_CNT_L - 1 downto 0) = to_unsigned(1, INIT_CNT_L);

	constant zero_dll_cnt_value	: unsigned(DLL_CNT_L - 1 downto 0) = (others => '0'); 
	constant decr_dll_cnt_value	: unsigned(DLL_CNT_L - 1 downto 0) = to_unsigned(1, DLL_CNT_L);

	signal ClkCycleCntC, ClkCycleCntN	: unsigned(INIT_CNT_L - 1 downto 0);
	signal SetClkCntC, SetClkCntN		: std_logic;
	signal ClkCntEnC, ClkCntEnN		: std_logic;
	signal ZeroDLLCnt			: std_logic;

	signal DLLResetCntC, DLLResetCntN	: unsigned(DLL_CNT_L - 1 downto 0);
	signal SetDLLCntC, SetDLLCntN		: std_logic;
	signal CntDLLEnC, CntDLLEnN		: std_logic;
	signal ZeroDLLCnt			: std_logic;

	signal StateC, StateN			: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0);

	signal InitializationCompletedC, InitializationCompletedN	: std_logic;

	signal nChipSelectC, nChipSelectN		: std_logic;
	signal nColAccessStrobeC, nColAccessStrobeN	: std_logic;
	signal nRowAccessStrobeC, nRowAccessStrobeN	: std_logic;
	signal ClkEnableC, ClkEnableN			: std_logic;
	signal ReadEnableC, ReadEnableN			: std_logic;
	signal AddressMemC, AddressMemN			: std_logic_vector(ADDR_MEM_L - 1 downto 0);
	signal BankSelMemC, BankSelMemN			: std_logic_vector(BANK_L - 1 downto 0);
begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then

			InitializationCompletedC <= '0';

			StateC <= START_INIT;

			ClkCycleCntC <= to_unsigned(T_INIT_STARTUP, INIT_CNT_L);
			SetCntC <= '0';
			CntEnC <= '0';

			nChipSelectC <= '0';
			nColAccessStrobeC <= '0';
			nRowAccessStrobeC <= '0';
			ClkEnableC <= '0';
			ReadEnableC <= '0';
			AddressMemC <= (others => '0');
			BankSelMemC <= (others => '0');

		elsif ((clk'event) and (clk = '1')) then

			InitializationCompletedC <= InitializationCompletedN;

			StateC <= StateN;

			DLLResetCntC <= DLLResetCntN;
			SetDLLCntC <= SetDLLCntN;
			DLLCntEnC <= DLLCntEnN;

			ClkCycleCntC <= ClkCycleCntN;
			SetCntC <= SetCntN;
			CntEnC <= CntEnN;

			nChipSelectC <= nChipSelectN;
			nColAccessStrobeC <= nColAccessStrobeN;
			nRowAccessStrobeC <= nRowAccessStrobeN;
			ClkEnableC <= ClkEnableN;
			ReadEnableC <= ReadEnableN;
			AddressMemC <= AddressMemN;
			BankSelMemC <= BankSelMemN;

		end if;
	end process reg;


	OnDieTermination <= '0';

	InitializationCompleted <= InitializationCompletedC;
	InitializationCompletedN <= '1' when (StateC = INIT_COMPLETE) else '0';

	DLLResetCntN <=	to_unsigned(T_DLL_RESET, DLLResetCnt'length)	when SetDLLCnt else
			(DLLResetCntC - decr_dll_cnt_value)		when DLLCntEnC and not ZeroDLLCnt else
			DLLResetCntC;

	SetDLLCntN <= '1' when ZeroClkCnt and (StateC = CMD_EMRS1) else '0';
	DLLCntEnN <= '1' when (StateC = CMD_MSR_A8_1) or (StateC = CMD_PREA) or (StateC = CMD_AUTO_REF_1) or (StateC = CMD_AUTO_REF_2) or (StateC = CMD_MSR_A8_0) else '0';

	ClkCycleCntN <=	CntInitValue				when SetClkCntC else
			(ClkCycleCntC - decr_clk_cnt_value)	when ClkCntEnC and not ZeroClkCnt else
			ClkCycleCntC;

	ClkCntEnN <= not InitializationCompletedN;
	SetClkCntN <= ZeroClkCnt when (ZeroDLLCnt or not (StateC = CMD_MSR_A8_0)) else '0';
	ZeroClkCnt <= '1' when (ClkCycleCntN = zero_cnt_value) else '0';

	CntInitValue <=	to_unsigned(T_NOP_INIT, INIT_CNT_L)	when ((StateC = CMD_NOP_400_1) or (StateC = CMD_NOP_400_2)) else
			to_unsigned(T_RP, INIT_CNT_L)		when ((StateC = CMD_PREA_A10_0) or (StateC = CMD_PREA)) else
			to_unsigned(T_MRD, INIT_CNT_L)		when ((StateC = CMD_EMSR3) or (StateC = CMD_EMSR2) or (StateC = CMD_EMSR1) or (StateC = CMD_MSR_A8_1) or (StateC = CMD_MSR_A8_0) or (StateC = CMD_EMSR1_A987_1) or (StateC = CMD_EMSR1_A987_0)) else
			to_unsigned(T_RFC, INIT_CNT_L);

	nChipSelect <=	nChipSelectC;
	nChipSelectN <=	'0';

	nColAccessStrobe <= nColAccessStrobeC;
	nColAccessStrobeN <= '0' when (ZeroClkCnt and not((StateC = START_INIT) or (StateC = CMD_PREA_A10_0) or (StateC = CMD_MSR_A8_1) or (StateC = CMD_NOP_400_1) or (StateC = CMD_EMSR1_A987_0))) else '1';

	nRowAccessStrobe <= nRowAccessStrobeC;
	nRowAccessStrobeN <= '0' when (ZeroClkCnt and not((StateC = START_INIT) or (StateC = CMD_PREA_A10_0) or (StateC = CMD_EMSR1_A987_0))) else '1';

	ClkEnable <= ClkEnableC;
	ClkEnableN <= '0' when ((StateC = START_INIT) and (not ZeroClkCnt)) else '1';

	ReadEnable <= ReadEnableC;
	ReadEnableN <= '0' when (ZeroClkCnt and not((StateC = CMD_PREA) or (StateC = CMD_AUTO_REF_1) or (StateC = START_INIT) or (StateC = CMD_PREA_A10_0) or (StateC = CMD_EMSR1_A987_0))) else '1';

	AddressMem <= AddressMemC;
	AddressMemN <=	(10 => '1', others => '0')															when ((StateC = CMD_NOP_400_1) and ZeroClkCnt) else
			(7 => HITEMP_REF, others => '0')														when ((StateC = CMD_NOP_400_2) and ZeroClkCnt) else
			(8 => '1', others => '0')															when ((StateC = CMD_EMRS1) and ZeroClkCnt) else
			(12 => POWER_DOWN_EXIT, (11 downto 9) => WRITE_REC, (6 downto 4) => CAS, 3 => BURST_TYPE, (2 downto 0) => BURST_LENGTH,  others => '0')		when ((StateC = CMD_AUTO_REF_2) and ZeroClkCnt) else
			((9 downto 7) => "111", others => '0')														when ((StateC = CMD_MRS_A8_0) and ZeroClkCnt) else
			(12 => OUT_BUFFER, 11 => RDQS, 10 => nDQS, 6 => ODT(1), 2 => ODT(0), (5 downto 3) => AL, 1 => DRIVING_STRENGTH, 0 => nDLL,  others => '0')	when ((StateC = CMD_EMSR1_A987_0) and ZeroClkCnt) else
			(others => '0');

	BankSelMem <= BankSelMemC;
	BankSelMemN <=	(0 => '0', 1 => '1', 2 => '0', others => '0')	when ((StateC = CMD_NOP_400_2) and ZeroClkCnt) else
			(0 => '0', 1 => '1', 2 => '1', others => '0')	when ((StateC = CMD_EMSR2) and ZeroClkCnt) else
			(0 => '1', 1 => '0', 2 => '0', others => '0')	when (((ZeroDLLCnt and (StateC = CMD_MSR_A8_0)) or (StateC = CMD_EMSR1_A987_1) or (StateC = CMD_EMSR3)) and ZeroClkCnt) else
			(others => '0');


	state_det: process(StateC, ClkCycleCntC)
	begin
		StateN <= StateC; -- avoid latched
		if (StateC = START_INIT) then
			if ZeroClkCnt then
				StateN <= CMD_NOP_400_1;
			end if;
		elsif (StateC = CMD_NOP_400_1) then
			if ZeroClkCnt then
				StateN <= CMD_PREA_A10_0;
			end if;
		elsif (StateC = CMD_PREA_A10_0) then
			if ZeroClkCnt then
				StateN <= CMD_NOP_400_2;
			end if;
		elsif (StateC = CMD_NOP_400_2) then
			if ZeroClkCnt then
				StateN <= CMD_EMSR2;
			end if;
		elsif (StateC = CMD_EMSR2) then
			if ZeroClkCnt then
				StateN <= CMD_EMSR3;
			end if;
		elsif (StateC = CMD_EMSR3) then
			if ZeroClkCnt then
				StateN <= CMD_EMSR1;
			end if;
		elsif (StateC = CMD_EMSR1) then
			if ZeroClkCnt then
				StateN <= CMD_MSR_A8_1;
			end if;
		elsif (StateC = CMD_MSR_A8_1) then
			if ZeroClkCnt then
				StateN <= CMD_PREA;
			end if;
		elsif (StateC = CMD_PREA) then
			if ZeroClkCnt then
				StateN <= CMD_AUTO_REF_1;
			end if;
		elsif (StateC = CMD_AUTO_REF_1) then
			if ZeroClkCnt then
				StateN <= CMD_AUTO_REF_2;
			end if;
		elsif (StateC = CMD_AUTO_REF_2) then
			if ZeroClkCnt then
				StateN <= CMD_MSR_A8_0;
			end if;
		elsif (StateC = CMD_MSR_A8_0) then
			if ZeroClkCnt and ZeroDLLCnt then
				StateN <=  CMD_EMSR1_A987_1;
			end if;
		elsif (StateC = CMD_EMSR1_A987_1) then
			if ZeroClkCnt then
				StateN <= CMD_EMSR1_A987_0;
			end if;
		elsif (StateC = CMD_EMSR1_A987_0) then
			if ZeroClkCnt then
				StateN <= INIT_COMPLETE;
			end if;
		end if;
	end process state_det;

end rtl;
