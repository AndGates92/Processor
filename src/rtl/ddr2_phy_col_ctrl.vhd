library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;
use work.ddr2_phy_pkg.all;
use work.ddr2_mrs_pkg.all;
use work.ddr2_timing_pkg.all;
use work.ddr2_phy_col_ctrl_pkg.all;

entity ddr2_phy_col_ctrl is
generic (
	BURST_LENGTH_L		: positive := 5;
	BANK_NUM		: positive := 8;
	COL_L			: positive := 10
);
port (

	rst		: in std_logic;
	clk		: in std_logic;

	-- Bank Controller
	BankActiveVec			: in std_logic_vector(BANK_NUM - 1 downto 0);
	ZeroOutstandingBurstsVec	: in std_logic_vector(BANK_NUM - 1 downto 0);

	EndDataPhaseVec			: out std_logic_vector(BANK_NUM - 1 downto 0);
	ReadBurstOut			: out std_logic;

	-- Arbitrer
	CmdAck		: in std_logic;

	ColMemOut	: out std_logic_vector(COL_L - 1 downto 0);
	BankMemOut	: out std_logic_vector(int_to_bit_num(BANK_NUM) - 1 downto 0);
	CmdOut		: out std_logic_vector(MEM_CMD_L - 1 downto 0);
	CmdReq		: out std_logic;

	-- Controller
	CtrlReq		: in std_logic;
	ReadBurstIn	: in std_logic;
	ColMemIn	: in std_logic_vector(COL_L - to_integer(unsigned(BURST_LENGTH)) - 1 downto 0);
	BankMemIn	: in std_logic_vector(int_to_bit_num(BANK_NUM) - 1 downto 0);
	BurstLength	: in std_logic_vector(BURST_LENGTH_L - 1 downto 0);

	CtrlAck		: out std_logic

);
end entity ddr2_phy_col_ctrl;

architecture rtl of ddr2_phy_col_ctrl is

	constant zero_cnt_col_to_col_value	: unsigned(CNT_COL_TO_COL_L - 1 downto 0) := (others => '0'); 
	constant decr_cnt_col_to_col_value	: unsigned(CNT_COL_TO_COL_L - 1 downto 0) := to_unsigned(1, CNT_COL_TO_COL_L);
	constant zero_cnt_col_ctrl_value	: unsigned(CNT_COL_CTRL_L - 1 downto 0) := (others => '0'); 
	constant decr_cnt_col_ctrl_value	: unsigned(CNT_COL_CTRL_L - 1 downto 0) := to_unsigned(1, CNT_COL_CTRL_L);
	constant zero_burst_length_value	: unsigned(BURST_LENGTH_L - 1 downto 0) := to_unsigned(0, BURST_LENGTH_L);
	constant decr_burst_length_value	: unsigned(BURST_LENGTH_L - 1 downto 0) := to_unsigned(1, BURST_LENGTH_L);
	constant incr_col_value			: unsigned(COL_L - to_integer(unsigned(BURST_LENGTH)) - 1 downto 0) := to_unsigned(1, COL_L - to_integer(unsigned(BURST_LENGTH)));
	constant zero_col_lsb			: unsigned(to_integer(unsigned(BURST_LENGTH)) - 1 downto 0) := to_unsigned(0, to_integer(unsigned(BURST_LENGTH)));

	signal CtrlAckN, CtrlAckC		: std_logic;
	signal ColMemN, ColMemC			: unsigned(COL_L - to_integer(unsigned(BURST_LENGTH)) - 1 downto 0);
	signal ReadBurstN, ReadBurstC		: std_logic;
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

		end if;
	end process reg;

	ColMemOut <= std_logic_vector(ColMemC & zero_col_lsb);
	ReadBurstOut <= ReadBurstC;
	BankMemOut <= BankMemC;
	CmdOut <= Cmd_comb;
	CmdReq <= CmdReqC;
	EndDataPhaseVec <= EndDataPhaseVec_comb;

	CmdReqN <= ZeroColToColCnt when ((StateC = DATA_PHASE) or ((StateC = CHANGE_BURST_OP) or (CtrlAckN = '1'))) else '0'; -- Send a Command Request if in DATA_PHASE state or moving into it

	CtrlAck <= CtrlAckC;
	CtrlAckN <= CtrlReq and BankActiveMuxed when ((StateC = COL_CTRL_IDLE) or ((StateC = DATA_PHASE) and (EndDataPhase = '1'))) else '0'; -- accept request if bank is active

	BankMemN <= BankMemIn when ((CtrlReq = '1') and (CtrlAckC = '1')) else BankMemC;

	ColMemN <=	unsigned(ColMemIn)		when ((CtrlReq = '1') and (CtrlAckC = '1')) else
			(ColMemC + incr_col_value) 	when ((CmdReqC = '1') and (CmdAck = '1')) else
			ColMemC;

	BurstLengthN <=	unsigned(BurstLength)				when ((CtrlReq = '1') and (CtrlAckC = '1')) else
			(BurstLengthC - decr_burst_length_value)	when ((CmdReqC = '1') and (CmdAck = '1')) else
			BurstLengthC;

	ReadBurstN <= ReadBurstIn when (CtrlReq = '1') and (CtrlAckC = '1') else ReadBurstC;

	NotSameOpIn <= (ReadBurstC xor ReadBurstIn); -- change burst operation
	ChangeOp <= CtrlReq and NotSameOpIn; -- valid change burst operation
	SameOp <= CtrlReq and not NotSameOpIn; -- valid same burst operation

	CommandSel <= ReadBurstC & EndDataPhase & ZeroOutstandingBurstsMuxed;

	with CommandSel select
		Cmd_comb <=	CMD_READ_PRECHARGE	when "111",
				CMD_READ		when "100" | "101" | "110",
				CMD_WRITE_PRECHARGE	when "011",
				CMD_WRITE		when others;

	NoOutstandingBurst <= '1' when (BurstLengthC = zero_burst_length_value) else '0';
	EndDataPhase <= NoOutstandingBurst;

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

	CntColCtrlN <=	ColCtrlCntInitValue			when (SetColCtrlCnt = '1') else
			(CntColCtrlC - decr_cnt_col_ctrl_value)	when ((ColCtrlCntEnC = '1') and (ZeroColCtrlCnt = '0')) else
			CntColCtrlC;
	ZeroColCtrlCnt <= '1' when (CntColCtrlC = zero_cnt_col_ctrl_value) else '0';
	ColCtrlCntInitValue <= to_unsigned(T_RTW_tat - 1, CNT_COL_CTRL_L) when (ReadBurstC = '1') else to_unsigned(T_WTR_tat - 1, CNT_COL_CTRL_L);
	SetColCtrlCnt <= EndDataPhase;
	ColCtrlCntEnN <=	'1' when (((ChangeOp = '1') or (CtrlReq = '0')) and (StateC = DATA_PHASE) and (EndDataPhase = '1')) else	-- enable counter if diff op next or no outstanding request
				'0' when ((SameOp = '1') and (StateC = DATA_PHASE) and (EndDataPhase = '1')) else	-- disable counter if same op next
				ColCtrlCntEnC;

	CntColToColN <=	ColToColCntInitValue				when (SetColToColCnt = '1') else
			(CntColToColC - decr_cnt_col_to_col_value)	when ((ColToColCntEn = '1') and (ZeroColToColCnt = '0')) else
			CntColToColC;
	ZeroColToColCnt <= '1' when (CntColToColC = zero_cnt_col_to_col_value) else '0';
	ColToColCntInitValue <= to_unsigned(T_COL_COL - 1, CNT_COL_TO_COL_L);
	SetColToColCnt <= CmdReqC and CmdAck;	-- reset when beginning a new data phase
	ColToColCntEn <= '1';	-- free running counter

	state_det: process(StateC, CtrlReq, CtrlAckC, EndDataPhase, ChangeOp, ZeroColCtrlCnt)
	begin
		StateN <= StateC; -- avoid latches
		if (StateC = COL_CTRL_IDLE) then
			if ((CtrlReq = '1') and (CtrlAckC = '1')) then
				if (ZeroColCtrlCnt = '1') then
					StateN <= DATA_PHASE;
				else
					StateN <= CHANGE_BURST_OP;
				end if;
			end if;
		elsif (StateC = DATA_PHASE) then
			if (EndDataPhase = '1') then
				if (ChangeOp = '1') then -- next burst has a different operation: read - write or write - read transition
					StateN <= CHANGE_BURST_OP;
				elsif ((BankActiveMuxed = '0') or (CtrlReq = '0')) then
					StateN <= COL_CTRL_IDLE;
				end if;
			end if;
		elsif (StateC = CHANGE_BURST_OP) then
			if (ZeroColCtrlCnt = '1') then
				StateN <= DATA_PHASE;
			end if;
		else
			StateN <= StateC;
		end if;
	end process state_det;

end rtl;
