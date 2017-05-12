library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ddr2_pkg.all;
use work.ddr2_phy_pkg.all;
use work.ddr2_phy_bank_ctrl_pkg.all;

entity ddr2_phy_bank_ctrl is
port (

	rst		: in std_logic;
	clk		: in std_logic;

	-- User Interface
	RowMemIn	: in std_logic_vector(ROW_L - 1 downto 0);
	CtrlReq		: in std_logic;

	CtrlAck		: out std_logic;

	-- Arbitrer
	RowMemOut		: out std_logic_vector(ROW_L - 1 downto 0);
	CmdOut			: out std_logic_vector(CMD_MEM_L - 1 downto 0);
	CmdReq			: out std_logic;

	CmdAck			: in std_logic;

	-- Controller
	OutstandingBursts	: out std_logic_vector(MAX_OUTSTANDING_BURSTS_L - 1 downto 0);
	BankActive		: out std_logic;

	EndDataPhase		: in std_logic;
	ReadBurst		: in std_logic;
	LastBurstBeat		: in std_logic

);
end entity ddr2_phy_bank_ctrl;

architecture rtl of ddr2_phy_bank_ctrl is
	constant zero_clk_delay	: unsigned(CNT_DELAY_L - 1 downto 0) := (others => '0'); 
	constant zero_clk_delay	: unsigned(MAX_OUTSTANDING_BURSTS_L - 1 downto 0) := (others => '0'); 

	signal BankActiveC, BankActiveN	: std_logic;

	signal TActColReached		: std_logic;
	signal TRASReached		: std_logic;
	signal TRCReached		: std_logic;

	signal DelayElapsed		: std_logic;

	signal ExitDataPhase		: std_logic;

	signal CntBankCtrlC, CntBankCtrlN		: unsigned(CNT_BANK_CTRL_L - 1 downto 0);
	signal CntDelayC, CntDelayN			: unsigned(CNT_DELAY_L - 1 downto 0);
	signal OutstandingBurstsC, OutstandingBurstsN	: unsigned(MAX_OUTSTANDING_BURSTS_L - 1 downto 0);

	signal StateC, StateN			: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0);

	signal CmdReqC, CmdReqN		: std_logic;

begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then
			BankActiveC <= '0';

			CntDelayC <= (others => '0');
			CntBankCtrlC <= (others => '0');
			OutstandingBurstC <= (others => '0');

			StateC <= IDLE;

			CmdReqC <= '0';

		elsif ((clk'event) and (clk = '1')) then
			BankActiveC <= BankActiveN;

			CntDelayC <= CntDelayN;
			CntBankCtrlC <= CntBankCtrlN;
			OutstandingBurstC <= OutstandingBurstN;

			StateC <= StateN;

			CmdReqC <= CmdReqN;

		end if;
	end process reg;

	OutstandingBursts <= std_logic_vector(OutstandingBurstsC);
	BankActive <= std_logic_vector(BankActiveC);
	CmdOut <= CMD_BANK_ACT;
	CmdReq <= CmdReqC;
	CtrlAck <=	CmdAck when (State = WAIT_ACT_ACK) else -- return ack only when arbitrer gives the ack
			'1' when ((StateC = ELAPSE_T_ACT_COL) or ((BankActiveC = '1') and  (ExitDataPhase = '0'))) else -- accept immediately the request because the bank is already active or about ot be
			'0';

	CmdReqN <=	'1' when ((StateC = IDLE) and (CtrlReq = '1')) else
			'0' when ((StateC = WAIT_ACT_ACK) and (CmdAck = '1')) else
			CmdReqC;

	BankActiveN <=	'1' when (TActColReached = '1') else
			'0' when (ExitDataPhase = '1') else
			BankActiveC;

	TActColReached <= '0' when (CntBankCtrlC < to_unsigned(T_ACT_COL - 1)) else '1';
	TRASReached <= '0' when (CntBankCtrlC < to_unsigned(T_RAS - 1)) else '1';
	TRCReached <= '0' when (CntBankCtrlC < to_unsigned(T_RC - 1)) else '1';

	DelayElapsed <= '1' when (CntDelayC = zero_clk_delay) else '0';
	NoOutstandingBurstsC <= '1' when (OutstandingBurstsC = zero_outstanding_bursts) else '0';

	ExitDataPhase <= (EndDataPhase = '1') and (NoOutstandingBursts = '1');

	state_det: process(StateC, CtrlReq, CmdAck, TActColReached, EndDataPhase, OutstandingBurstsC, TRASReached, TRCReached, DelayElapsed)
	begin
		StateN <= StateC; -- avoid latched
		if (StateC = IDLE) then
			if (CtrlReq = '1') then
				StateN <= WAIT_ACT_ACK;
			end if;
		elsif (StateC = WAIT_ACT_ACK) then
			if (CmdAck = '1') begin
				StateN <= ELAPSE_T_ACT_COL;
			end if;
		elsif (StateC = ELAPSE_T_ACT_ROW) then
			if (TActColReached = '1') begin
				StateN <= DATA_PHASE;
			end if;
		elsif (StateC = DATA_PHASE) then
			if (ExitDataPhase = '1') begin
				StateN <= PROCESS_COL_CMD;
			end if;
		elsif (StateC = PROCESS_COL_CMD) then
			if (DelayElapsed = '1') begin
				if (TRASReached = '1') begin
					StateN <= ELAPSE_T_RP;
				else
					StateN <= ELAPSE_T_RAS;
				end if;
			end if;
		elsif (StateC = ELAPSE_T_RAS) then
			if (TRASReached = '1') begin
				StateN <= ELAPSE_T_RP;
			end if;
		elsif (StateC = ELAPSE_T_RP) then
			if ((DelayElapsed = '1') and (TRCReached = '1')) begin
				StateN <= PROCESS_COL_CMD;
			end if;
		end if;
	end process state_det;
	
end rtl;
