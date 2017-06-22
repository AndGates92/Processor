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
	BURST_LENGTH_L	: positive := 5;
	BANK_NUM	: positive := 13;
	COL_L		: positive := 10
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
	ColMemIn		: in std_logic_vector(COL_L - 1 downto 0);
	BankMemIn		: in std_logic_vector(int_to_bit_num(BANK_NUM) - 1 downto 0);
	BurstLength		: in std_logic_vector(BURST_LENGTH_L - 1 downto 0);

	CtrlAck			: out std_logic

);
end entity ddr2_phy_col_ctrl;

architecture rtl of ddr2_phy_col_ctrl is

	constant zero_cnt_col_ctrl_value	: unsigned(CNT_COL_CTRL_L - 1 downto 0) := (others => '0'); 
	constant decr_cnt_col_ctrl_value	: unsigned(CNT_COL_CTRL_L - 1 downto 0) := to_unsigned(1, CNT_COL_CTRL_L); 

	signal ColMemN, ColMemC				: std_logic_vector(COL_L - 1 downto 0);
	signal ReadBurstN, ReadBurstC			: std_logic;
	signal BankMemN, BankMemC			: std_logic_vector(int_to_bit_num(BANK_NUM) - 1 downto 0);
	signal CmdN, CmdC				: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal CmdReqN, CmdReqC				: std_logic;

	signal BurstLengthN, BurstLengthC		: unsigned(BURST_LENGTH_L - 1 downto 0);

	signal CntColCtrlN, CntColCtrlC			: unsigned(CNT_COL_CTRL_L - 1 downto 0);
	signal CntColCtrlInitValue			: unsigned(CNT_COL_CTRL_L - 1 downto 0);
	signal SetCntColCtrl				: std_logic;
	signal CntColCtrlEnC, CntColCtrlEnN		: std_logic;
	signal ZeroCntColCtrl				: std_logic;

	signal CntBeatN, CntBeatC			: std_logic_vector(CNT_COL_CTRL_L - 1 downto 0);

	signal StateN, StateC				: std_logic_vector(STATE_COL_CTRL_L - 1 downto 0);

	signal EndDataPhaseVecN, EndDataPhaseVecC	: std_logic_vector(BANK_NUM - 1 downto 0); 
	signal EndDataPhase				: std_logic;

begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then

			ColMemC <= (others => '0');
			BankMemC <= (others => '0');
			ReadBurstC <= (others => '0');
			CmdC <= (others => '0');
			CmdReqC <= (others => '0');

			BurstLengthC <= (others => '0');

			StateC <= COL_CTRL_IDLE;

			CntColCtrlC <= (others => '0');
			CntBeatC <= (others => '0');

			EndDataPhaseVecC <= (others => '0');

		elsif ((clk'event) and (clk = '1')) then

			ColMemC <= ColMemN;
			ReadBurstC <= ReadBurstN;
			BankMemC <= BankMemN;
			CmdC <= CmdN;
			CmdReqC <= CmdReqC;

			BurstLengthC <= BurstLengthN;

			StateC <= StateN;

			CntColCtrlC <= CntColCtrlN;
			CntBeatC <= CntBeatN;

			EndDataPhaseVecC <= EndDataPhaseVecN;

		end if;
	end process reg;

	ColMemOut <= ColMemC;
	ReadBurstOut <= ReadBurstC;
	BankMemOut <= BankMemC;
	CmdOut <= CmdC;
	CmdReq <= CmdReqC;

	CmdReqN <= CtrlReq and BankActive(BankMemIn) when ((StateC = COL_CTRL_IDLE) or ((StateC = DATA_PHASE) and (EndDataPhase = '1'))) else '0';

	CtrlAck <= CtrlAck_comb;
	CtrlAck_comb <= CmdAck;

	BankMemN <= BankMemIn when (CtrlReq = 1) and (CtrlAck_comb = '1') else BankMemC;
	ColMemN <= ColMemIn when (CtrlReq = 1) and (CtrlAck_comb = '1') else ColMemC;
	BurstLengthN <= unsigned(BurstLength) when (CtrlReq = 1) and (CtrlAck_comb = '1') else BurstLengthC;
	ReadBurstN <= ReadBurstIn when (CtrlReq = 1) and (CtrlAck_comb = '1') else ReadBurstC;

	ChangeOp <= (ReadBurstC xor ReadBurstIn);

	EndDataPhaseVec_gen : for i in 0 to (EndDataPhaseVecN'length - 1) generate
		EndDataPhaseVecN(i) <= EndDataPhase when (BankMemC = i) else '0';
	end generate;

	CntColCtrlN <=	CntColCtrlInitValue			when (SetCntColCtrlCnt = '1') else
			(CntColCtrlC - decr_delay_cnt_value)	when ((CntColCtrlCntEnC = '1') and (ZeroCntColCtrlCnt = '0')) else
			CntColCtrlC;
	ZeroCntColCtrlCnt <= '1' when (CntColCtrlC = zero_cnt_col_ctrl_value) else '0';
	CntColCtrlInitValue <= to_unsigned(T_RTW_tat - 1, CNT_COL_CTRL_L) when (ReadBurstC = '1') else to_unsigned(T_WTR_tat - 1, CNT_COL_CTRL_L);
	SetCntCtrlCnt <= EndDataPhase;
	CntColCtrlEnN <=	'1' when (((ChangeOp = '1') or (CtrlReq = '0')) and (StateC = DATA_PHASE)) else
				'0' when (((ChangeOp = '0') and (CtrlReq = '1')) and (StateC = DATA_PHASE))
				CntColCtrlEnC;

	state_det: process(StateC)
	begin
		StateN <= StateC; -- avoid latches
		if (StateC = COL_CTRL_IDLE) then
			if ((CmdReqC = '1') and (CmdAck = '1')) then
				StateN <= WAIT_DATA_PHASE;
			end if;
		elsif (StateC = DATA_PHASE) then
			if (EndDataPhase = '1') then
				if (CtrlReq = '1') then
					if (ChangeOp = '1') then -- next burst has a different operation: read - write or write - read transition
						StateC = CHANGE_BURST_OP;
					elsif (BankActive(BankMemIn) = '0') then
						StateC = COL_CTRL_IDLE;
					end if;
				else
					StateC = COL_CTRL_IDLE;
				end if;
		elsif (StateC = CHANGE_BURST_OP) then
			if (
		else
			StateN <= StateC;
		end if;
	end process state_det;


