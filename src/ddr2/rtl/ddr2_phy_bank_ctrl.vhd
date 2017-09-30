library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.functions_pkg.all;
use work.ddr2_gen_ac_timing_pkg.all;
use work.ddr2_mrs_max_pkg.all;
use work.ddr2_phy_pkg.all;
use work.ddr2_phy_bank_ctrl_pkg.all;

entity ddr2_phy_bank_ctrl is
generic (
	ROW_L			: positive := 13;
	BANK_ID			: integer := 0;
	BANK_NUM		: positive := 8;
	MAX_OUTSTANDING_BURSTS	: positive := 10
);
port (

	rst		: in std_logic;
	clk		: in std_logic;

	-- MRS configuration
	DDR2BurstLength		: in std_logic_vector(int_to_bit_num(BURST_LENGTH_MAX_VALUE) - 1 downto 0);
	DDR2AdditiveLatency	: in std_logic_vector(int_to_bit_num(AL_MAX_VALUE) - 1 downto 0);
	DDR2WriteLatency	: in std_logic_vector(int_to_bit_num(WRITE_LATENCY_MAX_VALUE) - 1 downto 0);

	-- Arbitrer
	CmdAck		: in std_logic;

	RowMemOut	: out std_logic_vector(ROW_L - 1 downto 0);
	BankMemOut	: out std_logic_vector(int_to_bit_num(BANK_NUM) - 1 downto 0);
	CmdOut		: out std_logic_vector(MEM_CMD_L - 1 downto 0);
	CmdReq		: out std_logic;

	-- Transaction Controller
	RowMemIn	: in std_logic_vector(ROW_L - 1 downto 0);
	CtrlReq		: in std_logic;

	CtrlAck		: out std_logic;

	-- Column Controller
	EndDataPhase		: in std_logic;
	ReadBurst		: in std_logic;

	-- Bank Status
	ZeroOutstandingBursts	: out std_logic;
	BankIdle		: out std_logic;
	BankActive		: out std_logic

);
end entity ddr2_phy_bank_ctrl;

architecture rtl of ddr2_phy_bank_ctrl is
	constant zero_delay_cnt_value	: unsigned(CNT_DELAY_L - 1 downto 0) := (others => '0'); 
	constant decr_delay_cnt_value	: unsigned(CNT_DELAY_L - 1 downto 0) := to_unsigned(1, CNT_DELAY_L); 

	constant incr_bank_ctrl_cnt_value	: unsigned(CNT_BANK_CTRL_L - 1 downto 0) := to_unsigned(1, CNT_BANK_CTRL_L); 

	constant zero_outstanding_bursts_value	: unsigned(int_to_bit_num(MAX_OUTSTANDING_BURSTS) - 1 downto 0) := (others => '0'); 
	constant decr_outstanding_bursts_value	: unsigned(int_to_bit_num(MAX_OUTSTANDING_BURSTS) - 1 downto 0) := to_unsigned(1, int_to_bit_num(MAX_OUTSTANDING_BURSTS));
	constant incr_outstanding_bursts_value	: unsigned(int_to_bit_num(MAX_OUTSTANDING_BURSTS) - 1 downto 0) := to_unsigned(1, int_to_bit_num(MAX_OUTSTANDING_BURSTS));

	constant al_zero_padding_bank_cnt	: std_logic_vector(CNT_BANK_CTRL_L - AL_MAX_VALUE - 1 downto 0) := (others => '0');

	constant al_zero_padding_delay_cnt	: std_logic_vector(CNT_DELAY_L - AL_MAX_VALUE - 1 downto 0) := (others => '0');
	constant bl_zero_padding		: std_logic_vector(CNT_DELAY_L - BURST_LENGTH_MAX_VALUE - 1 downto 0) := (others => '0');
	constant wl_zero_padding		: std_logic_vector(CNT_DELAY_L - WRITE_LATENCY_MAX_VALUE - 1 downto 0) := (others => '0');

	signal MaxBurst			: std_logic_vector(BURST_LENGTH_MAX_VALUE - 1 downto 0);

	signal DecrOutstandingBurstsCnt	: std_logic;
	signal IncrOutstandingBurstsCnt	: std_logic;

	signal RowMemN, RowMemC		: std_logic_vector(ROW_L - 1 downto 0);

	signal BankIdleC, BankIdleN	: std_logic;
	signal BankActiveC, BankActiveN	: std_logic;

	signal ReqInPrechargeC, ReqInPrechargeN	: std_logic;

	signal TActColReached		: std_logic;
	signal TRASReached		: std_logic;
	signal TRCReached		: std_logic;

	signal ReqActSameRow		: std_logic;
	signal StartPrecharge		: std_logic;

	signal DataPhase		: std_logic;
	signal ExitDataPhase		: std_logic;

	signal CtrlAckC, CtrlAckN	: std_logic;

	signal TReadPre			: unsigned(CNT_DELAY_L - 1 downto 0);
	signal TWritePre		: unsigned(CNT_DELAY_L - 1 downto 0);
	signal TActColCmd		: unsigned(CNT_BANK_CTRL_L - 1 downto 0);

	signal CntBankCtrlC, CntBankCtrlN	: unsigned(CNT_BANK_CTRL_L - 1 downto 0);
	signal BankCtrlCntEnC, BankCtrlCntEnN	: std_logic;
	signal ResetBankCtrlCnt			: std_logic;

	signal CntDelayC, CntDelayN		: unsigned(CNT_DELAY_L - 1 downto 0);
	signal DelayCntInitValue		: unsigned(CNT_DELAY_L - 1 downto 0);
	signal SetDelayCnt			: std_logic;
	signal DelayCntEnC, DelayCntEnN		: std_logic;
	signal ZeroDelayCnt			: std_logic;

	signal OutstandingBurstsC, OutstandingBurstsN	: unsigned(int_to_bit_num(MAX_OUTSTANDING_BURSTS) - 1 downto 0);
	signal ZeroOutstandingBursts_comb		: std_logic;

	signal StateC, StateN			: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0);

	signal CmdReqC, CmdReqN		: std_logic;

begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then

			RowMemC <= (others => '0');

			ReqInPrechargeC <= '0';

			BankActiveC <= '0';
			BankIdleC <= '1';

			CntDelayC <= (others => '0');
			DelayCntEnC <= '0';

			CntBankCtrlC <= (others => '0');
			BankCtrlCntEnC <= '0';

			OutstandingBurstsC <= (others => '0');

			StateC <= BANK_CTRL_IDLE;

			CmdReqC <= '0';

			CtrlAckC <= '0';

		elsif ((clk'event) and (clk = '1')) then

			RowMemC <= RowMemN;

			ReqInPrechargeC <= ReqInPrechargeN;

			BankActiveC <= BankActiveN;
			BankIdleC <= BankIdleN;

			CntDelayC <= CntDelayN;
			DelayCntEnC <= DelayCntEnN;

			CntBankCtrlC <= CntBankCtrlN;
			BankCtrlCntEnC <= BankCtrlCntEnN;

			OutstandingBurstsC <= OutstandingBurstsN;

			StateC <= StateN;

			CmdReqC <= CmdReqN;

			CtrlAckC <= CtrlAckN;

		end if;
	end process reg;

	BankMemOut <= std_logic_vector(to_unsigned(BANK_ID, int_to_bit_num(BANK_NUM)));
	BankActive <= BankActiveC;
	BankIdle <= BankIdleC;
	CmdOut <= CMD_BANK_ACT;
	CmdReq <= CmdReqC;
	RowMemOut <= RowMemC;
	CtrlAck <= CtrlAckC;
	ZeroOutstandingBursts <= ZeroOutstandingBursts_comb;
	CtrlAckN <=	CtrlReq				when (StateC = BANK_CTRL_IDLE) else
			(CtrlReq and ReqInPrechargeC)	when (StateC = WAIT_ACT_ACK) else
			(DataPhase and ReqActSameRow); -- return ack only when arbitrer gives the ack or during the data phase

	-- If same row is requested to be activate, accept immediately the request
	ReqActSameRow <= '1' when ((RowMemC = RowMemIn) and (CtrlReq = '1')) else '0';

	-- Store Row open for future comparison
	RowMemN <= RowMemIn when (((StateC = BANK_CTRL_IDLE) or ((StateC = WAIT_ACT_ACK) and (ReqInPrechargeC = '1'))) and (CtrlAckN = '1')) else RowMemC;

	-- Bank in data phase
	DataPhase <= '1' when ((StateC = ELAPSE_T_ACT_COL) or ((BankActiveC = '1') and  (ExitDataPhase = '0'))) else '0';

	CmdReqN <=	'1'	when ((((StateC = WAIT_ACT_ACK) and (ReqInPrechargeC = '1')) or (StateC = BANK_CTRL_IDLE)) and (CtrlAckN = '1')) else
			'0'	when ((StateC = WAIT_ACT_ACK) and (CmdAck = '1')) else
			CmdReqC;

	-- Bank active after time between activate and column command is elapsed
	BankActiveN <=	'1' when ((StateC = ELAPSE_T_ACT_COL) and (TActColReached = '1')) else
			'0' when ((StateC = BANK_CTRL_DATA_PHASE) and (ExitDataPhase = '1')) else
			BankActiveC;

	TActColCmd <= to_unsigned((T_RCD - 1), CNT_BANK_CTRL_L) - unsigned(al_zero_padding_bank_cnt & DDR2AdditiveLatency);

	-- Reached flag
	TActColReached <= '0' when (CntBankCtrlC < TActColCmd) else '1';
	TRASReached <= '0' when (CntBankCtrlC < to_unsigned((T_RAS_min - 1), CNT_BANK_CTRL_L)) else '1';
	TRCReached <= '0' when (CntBankCtrlC < to_unsigned((T_RC - 1), CNT_BANK_CTRL_L)) else '1';

	-- Outstanding burst ctrl
	DecrOutstandingBurstsCnt <= EndDataPhase and (not ZeroOutstandingBursts_comb);
	IncrOutstandingBurstsCnt <= (DataPhase and ReqActSameRow);

	OutstandingBurstsN <=	(OutstandingBurstsC - decr_outstanding_bursts_value)	when ((DecrOutstandingBurstsCnt = '1') and (IncrOutstandingBurstsCnt = '0')) else
				(OutstandingBurstsC + incr_outstanding_bursts_value)	when ((DecrOutstandingBurstsCnt = '0') and (IncrOutstandingBurstsCnt = '1')) else
				OutstandingBurstsC;

	ZeroOutstandingBursts_comb <= '1' when (OutstandingBurstsC = zero_outstanding_bursts_value) else '0';

	-- End data phase when no outstanding bursts
	ExitDataPhase <= (EndDataPhase and ZeroOutstandingBursts_comb);

	-- Column command to precharge time
	CntDelayN <=	DelayCntInitValue			when (SetDelayCnt = '1') else
			(CntDelayC - decr_delay_cnt_value)	when ((DelayCntEnC = '1') and (ZeroDelayCnt = '0')) else
			CntDelayC;

	ZeroDelayCnt <= '1' when (CntDelayC = zero_delay_cnt_value) else '0';

	SetDelayCnt <= '1' when (((StateC = BANK_CTRL_DATA_PHASE) and (ExitDataPhase = '1')) or (StartPrecharge = '1')) else '0';

	StartPrecharge <= '1' when ((TRASReached = '1') and ((StateC = ELAPSE_T_RAS) or ((StateC = PROCESS_COL_CMD) and (ZeroDelayCnt = '1')))) else '0';

	MAX_BURST_CNT: for i in MaxBurst'range generate
		max_burst_bit: process(DDR2BurstLength) begin
			if (i < unsigned(DDR2BurstLength)) then
				MaxBurst(i) <= '1';
			else
				MaxBurst(i) <= '0';
			end if;
		end process max_burst_bit;
	end generate MAX_BURST_CNT;

	TReadPre <= unsigned(al_zero_padding_delay_cnt & DDR2AdditiveLatency) + unsigned(bl_zero_padding & "0" & MaxBurst(BURST_LENGTH_MAX_VALUE - 1 downto 1)) + to_unsigned(max_int((T_RTP - 1), 1), CNT_DELAY_L);
	TWritePre <= unsigned(wl_zero_padding & DDR2WriteLatency) + unsigned(bl_zero_padding & MaxBurst) + to_unsigned(T_WR, CNT_DELAY_L);

	DelayCntInitValue <=	TReadPre			when ((ExitDataPhase = '1') and (ReadBurst = '1')) else
				TWritePre			when ((ExitDataPhase = '1') and (ReadBurst = '0')) else
				to_unsigned(T_RP, CNT_DELAY_L);

	DelayCntEnN <= '1' when ((SetDelayCnt = '1') or (StateC = PROCESS_COL_CMD) or (StateC = ELAPSE_T_RP)) else '0';

	CntBankCtrlN <=	(others => '0')					when (ResetBankCtrlCnt = '1') else
			(CntBankCtrlC + incr_bank_ctrl_cnt_value)	when ((BankCtrlCntEnC = '1') and (TRCReached = '0')) else
			CntBankCtrlC;

	BankCtrlCntEnN <=	'1'	when ((CmdReqC = '1') and (CmdAck = '1')) else
				'0'	when ((StateC = ELAPSE_T_RP) and (ZeroDelayCnt = '1') and (TRCReached = '1')) else
				BankCtrlCntEnC;

	BankIdleN <= not BankCtrlCntEnN;

	ResetBankCtrlCnt <= '1' when ((CmdReqC = '1') and (CmdAck = '1') and (StateC = WAIT_ACT_ACK)) else '0';

	ReqInPrechargeN <= 	CtrlReq	when (StateC = ELAPSE_T_RP) else
				'0'	when ((StateC = WAIT_ACT_ACK) and (CtrlAckN = '1')) else
				ReqInPrechargeC;

	state_det: process(StateC, CtrlReq, CmdAck, TActColReached, ExitDataPhase, TRASReached, TRCReached, ZeroDelayCnt)
	begin
		StateN <= StateC; -- avoid latched
		if (StateC = BANK_CTRL_IDLE) then
			if (CtrlReq = '1') then
				StateN <= WAIT_ACT_ACK;
			end if;
		elsif (StateC = WAIT_ACT_ACK) then
			if (CmdAck = '1') then
				StateN <= ELAPSE_T_ACT_COL;
			end if;
		elsif (StateC = ELAPSE_T_ACT_COL) then
			if (TActColReached = '1') then
				StateN <= BANK_CTRL_DATA_PHASE;
			end if;
		elsif (StateC = BANK_CTRL_DATA_PHASE) then
			if (ExitDataPhase = '1') then
				StateN <= PROCESS_COL_CMD;
			end if;
		elsif (StateC = PROCESS_COL_CMD) then
			if (ZeroDelayCnt = '1') then
				if (TRASReached = '1') then
					StateN <= ELAPSE_T_RP;
				else
					StateN <= ELAPSE_T_RAS;
				end if;
			end if;
		elsif (StateC = ELAPSE_T_RAS) then
			if (TRASReached = '1') then
				StateN <= ELAPSE_T_RP;
			end if;
		elsif (StateC = ELAPSE_T_RP) then
			if ((ZeroDelayCnt = '1') and (TRCReached = '1')) then
				if (CtrlReq = '1') then
					StateN <= WAIT_ACT_ACK;
				else
					StateN <= BANK_CTRL_IDLE;
				end if;
			end if;
		end if;
	end process state_det;
	
end rtl;
