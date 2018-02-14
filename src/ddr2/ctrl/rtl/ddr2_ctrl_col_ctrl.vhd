library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library common_rtl_pkg;
use common_rtl_pkg.functions_pkg.all;
library ddr2_ctrl_rtl_pkg;
use ddr2_ctrl_rtl_pkg.ddr2_ctrl_pkg.all;
use ddr2_ctrl_rtl_pkg.ddr2_mrs_max_pkg.all;
use ddr2_ctrl_rtl_pkg.ddr2_ctrl_col_ctrl_pkg.all;
use ddr2_ctrl_rtl_pkg.ddr2_gen_ac_timing_pkg.all;

entity ddr2_ctrl_col_ctrl is
generic (
	BURST_LENGTH_L		: positive := 5;
	BANK_NUM		: positive := 8;
	COL_L			: positive := 10
);
port (

	rst		: in std_logic;
	clk		: in std_logic;

	-- MRS configuration
	DDR2CASLatency		: in std_logic_vector(int_to_bit_num(CAS_LATENCY_MAX_VALUE) - 1 downto 0);
	DDR2BurstLength	: in std_logic_vector(int_to_bit_num(BURST_LENGTH_MAX_VALUE) - 1 downto 0);

	-- Bank Controller
	BankActiveVec			: in std_logic_vector(BANK_NUM - 1 downto 0);
	ZeroOutstandingBurstsVec	: in std_logic_vector(BANK_NUM - 1 downto 0);

	EndDataPhaseVec			: out std_logic_vector(BANK_NUM - 1 downto 0);
	ReadBurstVec			: out std_logic_vector(BANK_NUM - 1 downto 0);

	-- Arbitrer
	CmdAck		: in std_logic;

	ColMemOut	: out std_logic_vector(COL_L - 1 downto 0);
	BankMemOut	: out std_logic_vector(int_to_bit_num(BANK_NUM) - 1 downto 0);
	CmdOut		: out std_logic_vector(MEM_CMD_L - 1 downto 0);
	CmdReq		: out std_logic;

	-- Transaction Controller
	CtrlReq		: in std_logic;
	ReadBurstIn	: in std_logic;
	ColMemIn	: in std_logic_vector(COL_L - 1 downto 0);
	BankMemIn	: in std_logic_vector(int_to_bit_num(BANK_NUM) - 1 downto 0);
	BurstLength	: in std_logic_vector(BURST_LENGTH_L - 1 downto 0);

	CtrlAck		: out std_logic

);
end entity ddr2_ctrl_col_ctrl;

architecture rtl of ddr2_ctrl_col_ctrl is

	constant col_to_col_cnt_zero_padding	: std_logic_vector(CNT_COL_TO_COL_L - BURST_LENGTH_MAX_VALUE - 1 downto 0) := (others => '0');
	constant zero_cnt_col_to_col_value	: unsigned(CNT_COL_TO_COL_L - 1 downto 0) := (others => '0'); 
	constant decr_cnt_col_to_col_value	: unsigned(CNT_COL_TO_COL_L - 1 downto 0) := to_unsigned(1, CNT_COL_TO_COL_L);

	constant col_incr_zero_padding		: std_logic_vector(COL_L - (BURST_LENGTH_MAX_VALUE + 1) - 1 downto 0) := (others => '0');

	constant bl_zero_padding_col_ctrl_cnt	: std_logic_vector(CNT_COL_CTRL_L - BURST_LENGTH_MAX_VALUE - 1 downto 0) := (others => '0');
	constant cas_zero_padding_col_ctrl_cnt	: std_logic_vector(CNT_COL_CTRL_L - int_to_bit_num(CAS_LATENCY_MAX_VALUE) - 1 downto 0) := (others => '0');

	constant zero_cnt_col_ctrl_value	: unsigned(CNT_COL_CTRL_L - 1 downto 0) := (others => '0'); 
	constant decr_cnt_col_ctrl_value	: unsigned(CNT_COL_CTRL_L - 1 downto 0) := to_unsigned(1, CNT_COL_CTRL_L);
	constant one_cnt_col_ctrl_value		: unsigned(CNT_COL_CTRL_L - 1 downto 0) := to_unsigned(1, CNT_COL_CTRL_L);
	constant zero_burst_length_value	: unsigned(BURST_LENGTH_L - 1 downto 0) := to_unsigned(0, BURST_LENGTH_L);
	constant decr_burst_length_value	: unsigned(BURST_LENGTH_L - 1 downto 0) := to_unsigned(1, BURST_LENGTH_L);

	signal MaxBurst				: std_logic_vector(BURST_LENGTH_MAX_VALUE downto 0);

	signal ColToColCntMaxBurstPadded	: std_logic_vector(BURST_LENGTH_MAX_VALUE - 1 downto 0);
	signal MaxColToColCntValue		: unsigned(BURST_LENGTH_MAX_VALUE - 1 downto 0);

	signal CtrlCntMaxBurstPadded		: std_logic_vector(CNT_COL_CTRL_L - 1 downto 0);
	signal CtrlCntCASLatencyPadded			: std_logic_vector(CNT_COL_CTRL_L - 1 downto 0);
	signal TRTW_tat				: std_logic_vector(CNT_COL_CTRL_L - 1 downto 0);
	signal TWTR_tat				: std_logic_vector(CNT_COL_CTRL_L - 1 downto 0);

	signal CtrlAckN, CtrlAckC		: std_logic;
	signal ColMemN, ColMemC			: unsigned(COL_L - 1 downto 0);

	signal ReadBurstN, ReadBurstC		: std_logic;
	signal ReadBurstVec_comb		: std_logic_vector(BANK_NUM - 1 downto 0);

	signal BankActiveMuxed			: std_logic;
	signal BankMemN, BankMemC		: std_logic_vector(int_to_bit_num(BANK_NUM) - 1 downto 0);
	signal Cmd_comb				: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal CmdReqN, CmdReqC			: std_logic;

	signal BurstLengthN, BurstLengthC	: unsigned(BURST_LENGTH_L - 1 downto 0);

	signal CntColToColN, CntColToColC	: unsigned(CNT_COL_TO_COL_L - 1 downto 0);
	signal ColToColCntInitValue		: unsigned(CNT_COL_TO_COL_L - 1 downto 0);
	signal SetColToColCnt			: std_logic;
	signal ColToColCntEn			: std_logic;
	signal ZeroColToColCnt			: std_logic;
	signal ZeroColToColCnt_comb		: std_logic;

	signal CntColCtrlN, CntColCtrlC		: unsigned(CNT_COL_CTRL_L - 1 downto 0);
	signal ColCtrlCntInitValue		: unsigned(CNT_COL_CTRL_L - 1 downto 0);
	signal SetColCtrlCnt			: std_logic;
	signal ColCtrlCntEnC, ColCtrlCntEnN	: std_logic;
	signal ZeroColCtrlCnt			: std_logic;

	signal StateN, StateC			: std_logic_vector(STATE_COL_CTRL_L - 1 downto 0);

	signal EndDataPhase			: std_logic;
	signal EndDataPhaseVec_comb		: std_logic_vector(BANK_NUM - 1 downto 0);

	signal CommandSel			: std_logic_vector(2 downto 0);

	signal NotSameOpIn			: std_logic;
	signal ChangeOp				: std_logic;
	signal SameOp				: std_logic;

	signal ZeroOutstandingBurstsMuxed	: std_logic;
	signal NoOutstandingBurst		: std_logic;

	signal CmdReqValid			: std_logic;
	signal CtrlReqValid			: std_logic;

	signal SingleBurstN, SingleBurstC	: std_logic;
	signal ZeroBurstCnt			: std_logic;

begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then
			CtrlAckC <= '0';

			ColMemC <= (others => '0');
			BankMemC <= (others => '0');
			ReadBurstC <= '0';
			CmdReqC <= '0';

			BurstLengthC <= (others => '0');

			StateC <= COL_CTRL_IDLE;

			CntColCtrlC <= (others => '0');
			ColCtrlCntEnC <= '0';

			CntColToColC <= (others => '0');

			SingleBurstC <= '0';

		elsif ((clk'event) and (clk = '1')) then
			CtrlAckC <= CtrlAckN;

			ColMemC <= ColMemN;
			ReadBurstC <= ReadBurstN;
			BankMemC <= BankMemN;
			CmdReqC <= CmdReqN;

			BurstLengthC <= BurstLengthN;

			StateC <= StateN;

			CntColCtrlC <= CntColCtrlN;
			ColCtrlCntEnC <= ColCtrlCntEnN;

			CntColToColC <= CntColToColN;

			SingleBurstC <= SingleBurstN;

		end if;
	end process reg;

	ColMemOut <= std_logic_vector(ColMemC);
	ReadBurstVec <= ReadBurstVec_comb;
	BankMemOut <= BankMemC;
	CmdOut <= Cmd_comb;
	CmdReq <= CmdReqC;
	EndDataPhaseVec <= EndDataPhaseVec_comb;

	CtrlAck <= CtrlAckC;
	CtrlAckN <= 	(CtrlReqValid and (ZeroColCtrlCnt or SameOp))	when (StateC = COL_CTRL_IDLE) else
			(CtrlReqValid and ZeroColCtrlCnt)		when (StateC = CHANGE_BURST_OP) else
			(CtrlReqValid and EndDataPhase and SameOp)	when (StateC = COL_CTRL_DATA_PHASE) else 
			'0'; -- accept request if bank is active

	CtrlReqValid <= CtrlReq and BankActiveMuxed;

	BankMemN <= BankMemIn when (CtrlAckN = '1') else BankMemC;

	ColMemN <=	unsigned(ColMemIn)					when (CtrlAckN = '1') else
			(ColMemC + unsigned(col_incr_zero_padding & MaxBurst))	when ((CmdReqC = '1') and (CmdAck = '1')) else
			ColMemC;

	BurstLengthN <=	unsigned(BurstLength) 				when (CtrlAckN = '1') else
			(BurstLengthC - decr_burst_length_value)	when ((CmdReqC = '1') and (CmdAck = '1') and (ZeroBurstCnt = '0')) else
			BurstLengthC;

	ZeroBurstCnt <= '1' when (BurstLengthC = zero_burst_length_value) else '0';

	SingleBurstN <=	'1' when ((BurstLength = std_logic_vector(zero_burst_length_value)) and (CtrlAckN = '1')) else
			'0' when ((CmdReqC = '1') and (CmdAck = '1')) else
			SingleBurstC;

	ReadBurstN <= ReadBurstIn when (CtrlAckN = '1') else ReadBurstC;

	NotSameOpIn <= (ReadBurstC xor ReadBurstIn); -- change burst operation
	ChangeOp <= CtrlReq and NotSameOpIn; -- valid change burst operation
	SameOp <= CtrlReq and not NotSameOpIn; -- valid same burst operation

	CommandSel <= ReadBurstC & EndDataPhase & ZeroOutstandingBurstsMuxed;

	with CommandSel select
		Cmd_comb <=	CMD_READ_PRECHARGE	when "111",
				CMD_READ		when "100" | "101" | "110",
				CMD_WRITE_PRECHARGE	when "011",
				CMD_WRITE		when others;

	NoOutstandingBurst <= CmdReqC and CmdAck and (SingleBurstC or ZeroBurstCnt);

	EndDataPhase <= NoOutstandingBurst when (StateC = COL_CTRL_DATA_PHASE) else '0';

	ReadBurstVec_gen : for i in 0 to integer(ReadBurstVec_comb'length - 1) generate
		ReadBurstVec_comb(i) <= ReadBurstC when (BankMemC = std_logic_vector(to_unsigned(i, int_to_bit_num(BANK_NUM)))) else '0';
	end generate;

	EndDataPhaseVec_gen : for i in 0 to integer(EndDataPhaseVec_comb'length - 1) generate
		EndDataPhaseVec_comb(i) <= EndDataPhase when (BankMemC = std_logic_vector(to_unsigned(i, int_to_bit_num(BANK_NUM)))) else '0';
	end generate;

	zero_outstanding_burst_mux: process(ZeroOutstandingBurstsVec, BankMemC)
	begin
		ZeroOutstandingBurstsMuxed <= '0';
		for i in 0 to integer(ZeroOutstandingBurstsVec'length - 1) loop
			if (BankMemC = std_logic_vector(to_unsigned(i, BankMemC'length))) then
				ZeroOutstandingBurstsMuxed <= ZeroOutstandingBurstsVec(i);
			end if;
		end loop;
	end process zero_outstanding_burst_mux;

	bank_active_mux: process(BankActiveVec, BankMemIn)
	begin
		BankActiveMuxed <= '0';
		for i in 0 to integer(BankActiveVec'length - 1) loop
			if (BankMemIn = std_logic_vector(to_unsigned(i, BankMemIn'length))) then
				BankActiveMuxed <= BankActiveVec(i);
			end if;
		end loop;
	end process bank_active_mux;

	CTRL_CNT_MAX_BURST_NO_PADDING: if (CNT_COL_CTRL_L = (BURST_LENGTH_MAX_VALUE - 1)) generate
		CtrlCntMaxBurstPadded <= MaxBurst(BURST_LENGTH_MAX_VALUE downto 1);
	end generate CTRL_CNT_MAX_BURST_NO_PADDING;

	CTRL_CNT_MAX_BURST_PADDING: if (CNT_COL_CTRL_L /= (BURST_LENGTH_MAX_VALUE - 1)) generate
		CtrlCntMaxBurstPadded <= bl_zero_padding_col_ctrl_cnt & MaxBurst(BURST_LENGTH_MAX_VALUE downto 1);
	end generate CTRL_CNT_MAX_BURST_PADDING;

	CTRL_CNT_CAS_LATENCY_NO_PADDING: if (CNT_COL_CTRL_L = (BURST_LENGTH_MAX_VALUE - 1)) generate
		CtrlCntCASLatencyPadded <= DDR2CASLatency;
	end generate CTRL_CNT_CAS_LATENCY_NO_PADDING;

	CTRL_CNT_CAS_LATENCY_PADDING: if (CNT_COL_CTRL_L /= (BURST_LENGTH_MAX_VALUE - 1)) generate
		CtrlCntCASLatencyPadded <= cas_zero_padding_col_ctrl_cnt & DDR2CASLatency;
	end generate CTRL_CNT_CAS_LATENCY_PADDING;

	TRTW_tat <= std_logic_vector(unsigned(CtrlCntMaxBurstPadded) + one_cnt_col_ctrl_value);
	TWTR_tat <= std_logic_vector(unsigned(CtrlCntMaxBurstPadded) + unsigned(CtrlCntCASLatencyPadded) + to_unsigned((T_WTR - 2), CNT_COL_CTRL_L));

	CntColCtrlN <=	ColCtrlCntInitValue			when (SetColCtrlCnt = '1') else
			(CntColCtrlC - decr_cnt_col_ctrl_value)	when ((ColCtrlCntEnC = '1') and (ZeroColCtrlCnt = '0')) else
			CntColCtrlC;
	ZeroColCtrlCnt <= '1' when (CntColCtrlC = zero_cnt_col_ctrl_value) else '0';
	ColCtrlCntInitValue <= unsigned(TRTW_tat) when (ReadBurstC = '1') else unsigned(TWTR_tat);
	SetColCtrlCnt <= EndDataPhase;
	ColCtrlCntEnN <=	EndDataPhase and (ChangeOp or not CtrlReq) when (StateC = COL_CTRL_DATA_PHASE) else	-- enable counter if diff op next or no outstanding request
				ColCtrlCntEnC;

	CmdReqValid <=	CtrlAckN									when (StateC = COL_CTRL_IDLE) else
			ZeroColCtrlCnt and CtrlReqValid							when (StateC = CHANGE_BURST_OP) else
			(not EndDataPhase) or ChangeOp or (not (BankActiveMuxed and CtrlReq))		when (StateC = COL_CTRL_DATA_PHASE) else
			'0';

	MAX_BURST_CNT: for i in MaxBurst'range generate
		max_burst_bit: process(DDR2BurstLength) begin
			if (i = unsigned(DDR2BurstLength)) then
				MaxBurst(i) <= '1';
			else
				MaxBurst(i) <= '0';
			end if;
		end process max_burst_bit;
	end generate MAX_BURST_CNT;

	CmdReqN <= ZeroColToColCnt_comb when (CmdReqValid = '1') else '0'; -- Send a Command Request if in COL_CTRL_DATA_PHASE state or moving into it

	CntColToColN <=	ColToColCntInitValue				when (SetColToColCnt = '1') else
			(CntColToColC - decr_cnt_col_to_col_value)	when ((ColToColCntEn = '1') and (ZeroColToColCnt = '0')) else
			CntColToColC;
	ZeroColToColCnt <= '1' when (CntColToColC = zero_cnt_col_to_col_value) else '0';
	ZeroColToColCnt_comb <= '1' when (CntColToColN = zero_cnt_col_to_col_value) else '0';

	COL_TO_COL_CNT_INIT_VALUE_NO_PADDING: if (CNT_COL_TO_COL_L = (BURST_LENGTH_MAX_VALUE - 1)) generate
		ColToColCntMaxBurstPadded <= MaxBurst(BURST_LENGTH_MAX_VALUE downto 1);
		MaxColToColCntValue <= unsigned(ColToColCntMaxBurstPadded) - decr_cnt_col_to_col_value;
		ColToColCntInitValue <= MaxColToColCntValue(CNT_COL_TO_COL_L - 1 downto 0);
	end generate COL_TO_COL_CNT_INIT_VALUE_NO_PADDING;

	COL_TO_COL_CNT_INIT_VALUE_PADDING: if (CNT_COL_TO_COL_L /= (BURST_LENGTH_MAX_VALUE - 1)) generate
		ColToColCntInitValue <= unsigned(col_to_col_cnt_zero_padding & MaxBurst(BURST_LENGTH_MAX_VALUE downto 1)) - decr_cnt_col_to_col_value;
	end generate COL_TO_COL_CNT_INIT_VALUE_PADDING;

	SetColToColCnt <= CmdReqC and CmdAck;	-- reset when beginning a new data phase
	ColToColCntEn <= '1';	-- free running counter

	state_det: process(StateC, CtrlReq,  CtrlAckN, EndDataPhase, ChangeOp, BankActiveMuxed, ZeroColCtrlCnt)
	begin
		StateN <= StateC; -- avoid latches
		if (StateC = COL_CTRL_IDLE) then
			if (CtrlAckN = '1') then
				StateN <= COL_CTRL_DATA_PHASE;
			elsif ((CtrlReq = '1') and (ChangeOp = '1') and (ZeroColCtrlCnt = '0')) then
				StateN <= CHANGE_BURST_OP;
			end if;
		elsif (StateC = COL_CTRL_DATA_PHASE) then
			if (EndDataPhase = '1') then
				if (ChangeOp = '1') then -- next burst has a different operation: read - write or write - read transition
					StateN <= CHANGE_BURST_OP;
				elsif ((BankActiveMuxed = '0') or (CtrlReq = '0')) then
					StateN <= COL_CTRL_IDLE;
				end if;
			end if;
		elsif (StateC = CHANGE_BURST_OP) then
			if (ZeroColCtrlCnt = '1') then
				if (BankActiveMuxed = '1') then
					StateN <= COL_CTRL_DATA_PHASE;
				else
					StateN <= Col_CTRL_IDLE;
				end if;
			end if;
		else
			StateN <= StateC;
		end if;
	end process state_det;

end rtl;
