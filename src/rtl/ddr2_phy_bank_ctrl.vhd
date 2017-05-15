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
	CmdAck			: in std_logic;

	RowMemOut		: out std_logic_vector(ROW_L - 1 downto 0);
	CmdOut			: out std_logic_vector(CMD_MEM_L - 1 downto 0);
	CmdReq			: out std_logic;

	-- Controller
	EndDataPhase		: in std_logic;
	ReadBurst		: in std_logic;

	ZeroOutstandingBursts	: out std_logic;
	BankIdle		: out std_logic;
	BankActive		: out std_logic

);
end entity ddr2_phy_bank_ctrl;

architecture rtl of ddr2_phy_bank_ctrl is
	constant zero_delay_cnt_value	: unsigned(CNT_DELAY_L - 1 downto 0) := (others => '0'); 
	constant decr_delay_cnt_value	: unsigned(CNT_DELAY_L - 1 downto 0) := to_unsigned)1, CNT_DELAY_L); 

	constant zero_outstanding_bursts_value	: unsigned(MAX_OUTSTANDING_BURSTS_L - 1 downto 0) := (others => '0'); 
	constant decr_outstanding_bursts_value	: unsigned(MAX_OUTSTANDING_BURSTS_L - 1 downto 0) := to_unsigned)1, MAX_OUTSTANDING_BURSTS_L);
	constant incr_outstanding_bursts_value	: unsigned(MAX_OUTSTANDING_BURSTS_L - 1 downto 0) := to_unsigned)1, MAX_OUTSTANDING_BURSTS_L);

	signal RowMemN, RowMemC	: std_logic_vector(ROW_L - 1 downto 0);

	signal BankIdleC, BankIdleN	: std_logic;
	signal BankActiveC, BankActiveN	: std_logic;

	signal TActColReached		: std_logic;
	signal TRASReached		: std_logic;
	signal TRCReached		: std_logic;

	signal ExitDataPhase		: std_logic;

	signal CntBankCtrlC, CntBankCtrlN	: unsigned(CNT_BANK_CTRL_L - 1 downto 0);
	signal BankCtrlCntEnC, BankCtrlCntEnN	: std_logic;
	signal ResetBankCtrlCnt			: std_logic;

	signal CntDelayC, CntDelayN		: unsigned(CNT_DELAY_L - 1 downto 0);
	signal DelayCntInitValue		: unsigned(INIT_CNT_L - 1 downto 0);
	signal SetDelayCnt			: std_logic;
	signal DelayCntEnC, DelayCntEnN		: std_logic;
	signal ZeroDelayCnt			: std_logic;

	signal OutstandingBurstsC, OutstandingBurstsN	: unsigned(MAX_OUTSTANDING_BURSTS_L - 1 downto 0);
	signal ZeroOutstandingBursts_comb		: std_logic;

	signal StateC, StateN			: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0);

	signal CmdReqC, CmdReqN		: std_logic;

begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then

			RowMemC <= (others => '0');

			BankActiveC <= '0';
			BankIdleC <= '0';

			CntDelayC <= (others => '0');
			DelayCntEnC <= '0';

			CntBankCtrlC <= (others => '0');
			BankCtrlEnC <= '0';

			OutstandingBurstC <= (others => '0');

			StateC <= IDLE;

			CmdReqC <= '0';

		elsif ((clk'event) and (clk = '1')) then

			RowMemC <= RowMemN;

			BankActiveC <= BankActiveN;
			BankIdleC <= BankIdleN;

			CntDelayC <= CntDelayN;
			DelayCntEnC <= DelayCntEnN;

			CntBankCtrlC <= CntBankCtrlN;
			BankCtrlEnC <= BankCtrlEnN;

			OutstandingBurstC <= OutstandingBurstN;

			StateC <= StateN;

			CmdReqC <= CmdReqN;

		end if;
	end process reg;

	OutstandingBursts <= std_logic_vector(OutstandingBurstsC);
	BankActive <= BankActiveC;
	BankIdle <= BankIdleC;
	CmdOut <= CMD_BANK_ACT;
	CmdReq <= CmdReqC;
	RowMemOut <= RowMemC;
	ZeroOutstandingBursts <= ZeroOutstandingBursts_comb;
	CtrlAck <= CmdAck when (State = WAIT_ACT_ACK) else DataPhase; -- return ack only when arbitrer gives the ack or during the data phase

	RowMemN <= RowMemIn;

	DataPhase <= ((StateC = ELAPSE_T_ACT_COL) or ((BankActiveC = '1') and  (ExitDataPhase = '0')));

	CmdReqN <=	'1' when ((StateC = IDLE) and (CtrlReq = '1')) else
			'0' when ((StateC = WAIT_ACT_ACK) and (CmdAck = '1')) else
			CmdReqC;

	BankActiveN <=	'1' when (TActColReached = '1') else
			'0' when (ExitDataPhase = '1') else
			BankActiveC;

	TActColReached <= '0' when (CntBankCtrlC < to_unsigned(T_ACT_COL - 1)) else '1';
	TRASReached <= '0' when (CntBankCtrlC < to_unsigned(T_RAS - 1)) else '1';
	TRCReached <= '0' when (CntBankCtrlC < to_unsigned(T_RC - 1)) else '1';

	OutstandingBurstsN <=	(OutstandingBurstsC - decr_outstanding_bursts_value)	when (EndDataPhase = '1') else
				(OutstandingBurstsC + incr_outstanding_bursts_value)	when ((DataPhase = '1') and (CmdReq = '1')) else
				OutstandingBurstsC;

	ZeroOutstandingBursts_comb <= '1' when (OutstandingBurstsC = zero_outstanding_bursts_value) else '0';

	ExitDataPhase <= (EndDataPhase and ZeroOutstandingBursts_comb);

	CntDelayN <=	DelayCntInitValue			when (SetDelayCnt = '1') else
			(CntDelayC - decr_delay_cnt_value)	when ((DelayCntEnC = '1') and (ZeroDelayCnt = '1')) else
			CntDelayC;

	ZeroDelayCnt <= '1' when (CntDelay = zero_delay_cnt_value) else '0';

	SetDelayCnt <= '1' when ((ExitDataPhase = '1') or (StartPrecharge = '1')) else '0';

	StartPrecharge <= '1' when ((TRASReached = '1') and ((StateC = ELAPSE_T_RAS) or ((StateC = PROCESS_COL_CMD) and (ZeroDelayCnt = '1')))) else '0';

	DelayCntInitValue <=	to_unsigned(T_READ_PRE, CNT_DELAY_L) when ((ExitDataPhase = '1') and (ReadBurst = '1')) else
				to_unsigned(T_WRITE_PRE, CNT_DELAY_L) when ((ExitDataPhase = '1') and (ReadBurst = '0')) else
				to_unsigned(T_RP, CNT_DELAY_L)

	DelayCntEnN <= '1' when ((SetDelayCnt = '1') or (StateC = PROCESS_COL_CMD) or (StateC = ELAPSE_T_RP)) else '0';

	CntBankCtrlN <=	(others => '0')					when (ResetBankCtrlCnt = '1') else
			(CntBankCtrlC - decr_bank_ctrl_cnt_value)	when ((BankCtrlCntEnC = '1') and (TRCExceeded = '0')) else
			CntBankCtrlC;

	BankCtrlCntEnN <=	'1' when ((CtrlReq = '1') and (CtrlAck = '1')) else
				'0' when ((StateC = ELAPSE_T_RP) and (ZeroDelayCnt = '1') and (TRCReached = '1')) else
				BankCtrlCntEnC;

	BankIdleN <= not BankCtrlCntEnN;

	ResetBankCtrlCnt <= '1' when ((CtrlReq = '1') and (CtrlAck = '1') and (StateC = WAIT_ACT_ACK)) else '0';

	state_det: process(StateC, CtrlReq, CmdAck, TActColReached, EndDataPhase, OutstandingBurstsC, TRASReached, TRCReached, ZeroDelayCnt)
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
			if (ZeroDelayCnt = '1') begin
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
			if ((ZeroDelayCnt = '1') and (TRCReached = '1')) begin
				if (CmdReq = '1') then
					StateN <= WAIT_ACT_ACK;
				else
					StateN <= IDLE;
				end if;
			end if;
		end if;
	end process state_det;
	
end rtl;
