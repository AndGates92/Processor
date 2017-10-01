library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ddr2_phy_pkg.all;
use work.ddr2_gen_ac_timing_pkg.all;
use work.ddr2_phy_init_pkg.all;

entity ddr2_phy_init is
generic (
	BANK_L		: positive := 3;
	ADDR_MEM_L	: positive := 13
);
port (

	rst		: in std_logic;
	clk		: in std_logic;

	-- Command Decoder
	MRSCmd			: out std_logic_vector(ADDR_MEM_L - 1 downto 0);
	Cmd			: out std_logic_vector(MEM_CMD_L - 1 downto 0);

	-- Memory interface
	InitializationCompleted	: out std_logic

);
end entity ddr2_phy_init;

architecture rtl of ddr2_phy_init is
	constant zero_clk_cnt_value	: unsigned(INIT_CNT_L - 1 downto 0) := (others => '0'); 
	constant decr_clk_cnt_value	: unsigned(INIT_CNT_L - 1 downto 0) := to_unsigned(1, INIT_CNT_L);

	constant zero_dll_cnt_value	: unsigned(DLL_CNT_L - 1 downto 0) := (others => '0'); 
	constant decr_dll_cnt_value	: unsigned(DLL_CNT_L - 1 downto 0) := to_unsigned(1, DLL_CNT_L);

	signal ClkCycleCntC, ClkCycleCntN	: unsigned(INIT_CNT_L - 1 downto 0);
	signal ClkCntInitValue			: unsigned(INIT_CNT_L - 1 downto 0);
	signal SetClkCnt			: std_logic;
	signal ClkCntEnC, ClkCntEnN		: std_logic;
	signal ZeroClkCnt			: std_logic;

	signal DLLResetCntC, DLLResetCntN	: unsigned(DLL_CNT_L - 1 downto 0);
	signal SetDLLCnt			: std_logic;
	signal DLLCntEnC, DLLCntEnN		: std_logic;
	signal ZeroDLLCnt			: std_logic;

	signal StateC, StateN			: std_logic_vector(STATE_PHY_INIT_L - 1 downto 0);

	signal InitializationCompletedC, InitializationCompletedN	: std_logic;

	signal MRSCmdC, MRSCmdN			: std_logic_vector(ADDR_MEM_L - 1 downto 0);
	signal CmdC, CmdN			: std_logic_vector(MEM_CMD_L - 1 downto 0);

begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then

			InitializationCompletedC <= '0';

			StateC <= START_INIT;

			DLLResetCntC <= to_unsigned(T_DLL_RESET-1, DLLResetCntC'length);
			DLLCntEnC <= '0';

			ClkCycleCntC <= to_unsigned(T_INIT_STARTUP-1, ClkCycleCntC'length);
			ClkCntEnC <= '0';

			MRSCmdC <= (others => '0');
			CmdC <= CMD_NOP;

		elsif ((clk'event) and (clk = '1')) then

			InitializationCompletedC <= InitializationCompletedN;

			StateC <= StateN;

			DLLResetCntC <= DLLResetCntN;
			DLLCntEnC <= DLLCntEnN;

			ClkCycleCntC <= ClkCycleCntN;
			ClkCntEnC <= ClkCntEnN;

			MRSCmdC <= MRSCmdN;
			CmdC <= CmdN;

		end if;
	end process reg;


	InitializationCompleted <= InitializationCompletedC;
	InitializationCompletedN <= '1' when ((StateC = INIT_COMPLETE) or ((ZeroClkCnt = '1') and (StateC = APPLY_SETTING))) else '0';

	DLLResetCntN <=	to_unsigned(T_DLL_RESET, DLLResetCntN'length)	when (SetDLLCnt = '1') else
			(DLLResetCntC - decr_dll_cnt_value)		when ((DLLCntEnC = '1') and (ZeroDLLCnt = '0')) else
			DLLResetCntC;

	SetDLLCnt <= '1' when (ZeroClkCnt = '1') and (StateC = CMD_EMRS1) else '0';
	DLLCntEnN <= '1' when (StateC = CMD_MRS_A8_1) or (StateC = CMD_PREA) or (StateC = CMD_AUTO_REF_1) or (StateC = CMD_AUTO_REF_2) or (StateC = CMD_MRS_A8_0) else '0';
	ZeroDLLCnt <= '1' when (DLLResetCntC = zero_dll_cnt_value) else '0';

	ClkCycleCntN <=	ClkCntInitValue				when (SetClkCnt = '1') else
			(ClkCycleCntC - decr_clk_cnt_value)	when ((ClkCntEnC = '1') and (ZeroClkCnt = '0')) else
			ClkCycleCntC;

	ClkCntEnN <= not InitializationCompletedN;
	SetClkCnt <= ZeroClkCnt when ((ZeroDLLCnt = '1') or not (StateC = CMD_MRS_A8_0)) else '0';
	ZeroClkCnt <= '1' when (ClkCycleCntC = zero_clk_cnt_value) else '0';

	ClkCntInitValue <=	to_unsigned(T_NOP_INIT-1, ClkCntInitValue'length)	when ((ZeroClkCnt = '1') and (StateC = START_INIT)) else
				to_unsigned(T_RP-1, ClkCntInitValue'length)		when ((ZeroClkCnt = '1') and ((StateC = CMD_NOP_400) or (StateC = CMD_MRS_A8_1))) else
				to_unsigned(T_RFC-1, ClkCntInitValue'length)		when ((ZeroClkCnt = '1') and ((StateC = CMD_PREA) or (StateC = CMD_AUTO_REF_1))) else
				to_unsigned(T_MOD_max-1, ClkCntInitValue'length)	when ((ZeroClkCnt = '1') and (StateC = CMD_EMRS1_A987_0)) else
				to_unsigned(T_MRD-1, ClkCntInitValue'length);

	MRSCmd <= MRSCmdC;
	MRSCmdN <=	(7 => HITEMP_REF, others => '0')																									when ((StateC = CMD_PREA_A10_0) and (ZeroClkCnt = '1')) else
			(8 => '1', others => '0')																										when ((StateC = CMD_EMRS1) and (ZeroClkCnt = '1')) else
			(12 => POWER_DOWN_EXIT, 11 => WRITE_REC(2), 10 => WRITE_REC(1), 9 => WRITE_REC(0), 6 => CAS(2), 5 => CAS(1), 4 => CAS(0), 3 => BURST_TYPE, 2 => BURST_LENGTH(2), 1 => BURST_LENGTH(1), 0 => BURST_LENGTH(0),  others => '0')		when ((StateC = CMD_AUTO_REF_2) and (ZeroClkCnt = '1')) else
			(9 => '1', 8 => '1', 7 => '1', others => '0')														when ((StateC = CMD_MRS_A8_0) and (ZeroClkCnt = '1')) else
			(12 => OUT_BUFFER, 11 => RDQS, 10 => nDQS, 6 => ODT(1), 2 => ODT(0), 5 => AL(2), 4 => AL(1), 3 => AL(0), 1 => DRIVING_STRENGTH, 0 => nDLL,  others => '0')	when ((StateC = CMD_EMRS1_A987_1) and (ZeroClkCnt = '1')) else
			(others => '0');

	Cmd <= CmdC;
	CmdN <=	CMD_ALL_BANK_PRECHARGE	when (((StateC = CMD_NOP_400) or (StateC = CMD_MRS_A8_1)) and (ZeroClkCnt = '1')) else
		CMD_AUTO_REF		when (((StateC = CMD_PREA) or (StateC = CMD_AUTO_REF_1)) and (ZeroClkCnt = '1')) else
		CMD_MODE_REG_SET	when (((StateC = CMD_EMRS1) or (StateC = CMD_AUTO_REF_2)) and (ZeroClkCnt = '1')) else
		CMD_EXT_MODE_REG_SET_1	when (((StateC = CMD_EMRS3) or (StateC = CMD_EMRS1_A987_1) or (StateC = CMD_MRS_A8_0)) and (ZeroClkCnt = '1')) else
		CMD_EXT_MODE_REG_SET_2	when ((StateC = CMD_PREA_A10_0) and (ZeroClkCnt = '1')) else
		CMD_EXT_MODE_REG_SET_3	when ((StateC = CMD_EMRS2) and (ZeroClkCnt = '1')) else
		CMD_NOP;

	state_det: process(StateC, ZeroDLLCnt, ZeroClkCnt)
	begin
		StateN <= StateC; -- avoid latched
		if (StateC = START_INIT) then
			if (ZeroClkCnt = '1') then
				StateN <= CMD_NOP_400;
			end if;
		elsif (StateC = CMD_NOP_400) then
			if (ZeroClkCnt = '1') then
				StateN <= CMD_PREA_A10_0;
			end if;
		elsif (StateC = CMD_PREA_A10_0) then
			if (ZeroClkCnt = '1') then
				StateN <= CMD_EMRS2;
			end if;
		elsif (StateC = CMD_EMRS2) then
			if (ZeroClkCnt = '1') then
				StateN <= CMD_EMRS3;
			end if;
		elsif (StateC = CMD_EMRS3) then
			if (ZeroClkCnt = '1') then
				StateN <= CMD_EMRS1;
			end if;
		elsif (StateC = CMD_EMRS1) then
			if (ZeroClkCnt = '1') then
				StateN <= CMD_MRS_A8_1;
			end if;
		elsif (StateC = CMD_MRS_A8_1) then
			if (ZeroClkCnt = '1') then
				StateN <= CMD_PREA;
			end if;
		elsif (StateC = CMD_PREA) then
			if (ZeroClkCnt = '1') then
				StateN <= CMD_AUTO_REF_1;
			end if;
		elsif (StateC = CMD_AUTO_REF_1) then
			if (ZeroClkCnt = '1') then
				StateN <= CMD_AUTO_REF_2;
			end if;
		elsif (StateC = CMD_AUTO_REF_2) then
			if (ZeroClkCnt = '1') then
				StateN <= CMD_MRS_A8_0;
			end if;
		elsif (StateC = CMD_MRS_A8_0) then
			if ((ZeroClkCnt = '1') and (ZeroDLLCnt = '1')) then
				StateN <=  CMD_EMRS1_A987_1;
			end if;
		elsif (StateC = CMD_EMRS1_A987_1) then
			if (ZeroClkCnt = '1') then
				StateN <= CMD_EMRS1_A987_0;
			end if;
		elsif (StateC = CMD_EMRS1_A987_0) then
			if (ZeroClkCnt = '1') then
				StateN <= APPLY_SETTING;
			end if;
		elsif (StateC = APPLY_SETTING) then
			if (ZeroClkCnt = '1') then
				StateN <= INIT_COMPLETE;
			end if;
		end if;
	end process state_det;

end rtl;
