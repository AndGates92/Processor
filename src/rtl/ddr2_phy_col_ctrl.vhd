library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;
use work.ddr2_mrs_pkg.all;
use work.ddr2_timing_pkg.all;
use work.ddr2_phy_pkg.all;
use work.ddr2_phy_col_ctrl_pkg.all;

entity ddr2_phy_col_ctrl is
generic (
	COL_LSB			: positive := 2;
	BURST_LENGTH_L		: positive := 5;
	BANK_NUM		: positive := 8;
	COL_L			: positive := 10
);
port (

	rst		: in std_logic;
	clk		: in std_logic;

	-- Bank Controller
	EndDataPhaseVec			: in std_logic_vector(BANK_NUM - 1 downto 0);
	BankActiveVec			: in std_logic_vector(BANK_NUM - 1 downto 0);
	ZeroOutstandingBurstsVec	: in std_logic_vector(BANK_NUM - 1 downto 0);

	ReadBurstOut			: out std_logic;

	-- Arbitrer
	CmdAck		: in std_logic;

	ColMemOut	: out std_logic_vector(COL_L - 1 downto 0);
	BankMemOut	: out std_logic_vector(int_to_bit_num(BANK_NUM) - 1 downto 0);
	CmdOut		: out std_logic_vector(MEM_CMD_L - 1 downto 0);
	CmdReq		: out std_logic;

	-- Controller
	CtrlReq			: in std_logic;
	ReadBurstIn		: in std_logic;
	ColMemIn		: in std_logic_vector(COL_L - COL_LSB - 1 downto 0);
	BankMemIn		: in std_logic_vector(int_to_bit_num(BANK_NUM) - 1 downto 0);
	BurstLength		: in std_logic_vector(BURST_LENGTH_L - 1 downto 0);

	CtrlAck			: out std_logic

);
end entity ddr2_phy_col_ctrl;

architecture rtl of ddr2_phy_col_ctrl is

	constant zero_cnt_col_ctrl_value	: unsigned(CNT_COL_CTRL_L - 1 downto 0) := (others => '0'); 
	constant decr_cnt_col_ctrl_value	: unsigned(CNT_COL_CTRL_L - 1 downto 0) := to_unsigned(1, CNT_COL_CTRL_L); 
	constant zero_burstr_length_value	: unsigned(BURST_LENGTH_L - 1 downto 0) := to_unsigned(0, BURST_LENGTH_L); 
	constant decr_burstr_length_value	: unsigned(BURST_LENGTH_L - 1 downto 0) := to_unsigned(1, BURST_LENGTH_L); 
	constant incr_col_value			: unsigned(COL_L - COL_LSB - 1 downto 0) := to_unsigned(1, COL_L - COL_LSB);
	constant col_lsb			: unsigned(COL_LSB - 1 downto 0) := to_unsigned(0, COL_LSB);

	signal ColMemN, ColMemC				: std_logic_vector(COL_L - 1 downto 0);
	signal ReadBurstN, ReadBurstC			: std_logic;
	signal BankMemN, BankMemC			: std_logic_vector(int_to_bit_num(BANK_NUM) - 1 downto 0);
	signal Cmd_comb				: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal CmdReqN, CmdReqC				: std_logic;

	signal BurstLengthN, BurstLengthC		: unsigned(BURST_LENGTH_L - 1 downto 0);

	signal CntColCtrlN, CntColCtrlC			: unsigned(CNT_COL_CTRL_L - 1 downto 0);
	signal ColCtrlCntInitValue			: unsigned(CNT_COL_CTRL_L - 1 downto 0);
	signal SetColCtrlCnt				: std_logic;
	signal ColCtrlCntEnC, ColCtrlCntEnN		: std_logic;
	signal ZeroColCtrlCnt				: std_logic;

	signal CntBeatN, CntBeatC			: std_logic_vector(CNT_COL_CTRL_L - 1 downto 0);

	signal StateN, StateC				: std_logic_vector(STATE_COL_CTRL_L - 1 downto 0);

	signal EndDataPhase				: std_logic;

	signal CommandSel				: std_logic_vector(2 downto 0);

begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then
			CtrlAckC <= '0';

			ColMemC <= (others => '0');
			BankMemC <= (others => '0');
			ReadBurstC <= (others => '0');
			CmdReqC <= (others => '0');

			BurstLengthC <= (others => '0');

			StateC <= COL_CTRL_IDLE;

			CntColCtrlC <= (others => '0');
			CntBeatC <= (others => '0');

		elsif ((clk'event) and (clk = '1')) then
			CtrlAckC <= CtrlAckN;

			ColMemC <= ColMemN;
			ReadBurstC <= ReadBurstN;
			BankMemC <= BankMemN;
			CmdReqC <= CmdReqC;

			BurstLengthC <= BurstLengthN;

			StateC <= StateN;

			CntColCtrlC <= CntColCtrlN;
			CntBeatC <= CntBeatN;

		end if;
	end process reg;

	ColMemOut <= ColMemC;
	ReadBurstOut <= ReadBurstC;
	BankMemOut <= BankMemC;
	CmdOut <= Cmd_comb;
	CmdReq <= CmdReqC;
	EndDataPhaseVec <= EndDataPhaseVec_comb;

	CmdReqN <= '1' when ((StateC = DATA_PHASE) or ((ZeroColCtrlCnt = '1') and ((StateC = CHANGE_OP) or (CtrlAckN)))) else '0'; -- Send a Command Request if in DATA_PHASE state or moving into

	CtrlAck <= CtrlAckC;
	CtrlAckN <= CtrlReq and BankActive(BankMemIn) when ((StateC = COL_CTRL_IDLE) or ((StateC = DATA_PHASE) and (EndDataPhase = '1'))) else '0'; -- accept request if bank is active

	BankMemN <= BankMemIn when (CtrlReq = 1) and (CtrlAckC = '1') else BankMemC;

	ColMemN <=	unsigned(ColMemIn) & col_lsb					when ((CtrlReq = '1') and (CtrlAckC = '1')) else
			(ColMemC(COL_L - 1 downto COL_LSB) + incr_col_value) & col_lsb	when ((CmdReqC = '1') and (CmdAck = '1')) else
			ColMemC;

	BurstLengthN <=	unsigned(BurstLength)			when ((CtrlReq = 1) and (CtrlAckC = '1')) else
			BurstLengthC - decr_burst_length_value	when ((CmdReqC = '1') and (CmdAck = '1')) else
			BurstLengthC;

	ReadBurstN <= ReadBurstIn when (CtrlReq = 1) and (CtrlAckC = '1') else ReadBurstC;

	NotSameOpIn <= (ReadBurstC xor ReadBurstIn); -- change burst operation
	ChangeOp <= CtrlReq and NotSameOpIn; -- valid change burst operation
	SameOp <= CtrlReq and not NotSameOpIn; -- valid same burst operation

	CommandSel <= ReadBurstC & EndDataPhase & ZeroOutstandingBurstsVec(BankMemC);

	with CommandSel select
		Cmd_comb <=	CMD_READ_PRECHARGE	when "111",
				CMD_READ		when "100" | "101" | "110",
				CMD_WRITE_PRECHARGE	when "011",
				CMD_WRITE		when others;

	NoOutstandingBurst <= '1' when (BurstLengthC = zero_burst_length_value) else '0';
	EndDataPhase <= NoOutstandingBurst;

	EndDataPhaseVec_gen : for i in 0 to (EndDataPhaseVecN'length - 1) generate
		EndDataPhaseVec_comb(i) <= EndDataPhase when (BankMemC = i) else '0';
	end generate;

	CntColCtrlN <=	CntColCtrlInitValue			when (SetColCtrlCnt = '1') else
			(CntColCtrlC - decr_col_ctrl_cnt_value)	when ((ColCtrlCntEnC = '1') and (ZeroColCtrlCnt = '0')) else
			CntColCtrlC;
	ZeroColCtrlCnt <= '1' when (CntColCtrlC = zero_cnt_col_ctrl_value) else '0';
	ColCtrlCntInitValue <= to_unsigned(T_RTW_tat - 1, CNT_COL_CTRL_L) when (ReadBurstC = '1') else to_unsigned(T_WTR_tat - 1, CNT_COL_CTRL_L);
	SetCntCtrlCnt <= EndDataPhase;
	ColCtrlCntEnN <=	'1' when (((ChangeOp = '1') or (CtrlReq = '0')) and (StateC = DATA_PHASE) and (EndDataPhase = '1')) else	-- enable counter if diff op next or no outstanding request
				'0' when ((SameOp = '1') and (StateC = DATA_PHASE) and (EndDataPhase = '1')) else	-- disable counter if same op next
				CntColCtrlEnC;

	state_det: process(StateC)
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
					StateC = CHANGE_BURST_OP;
				elsif ((BankActive(BankMemIn) = '0') or (CtrlReq = '0')) then
					StateC = COL_CTRL_IDLE;
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


