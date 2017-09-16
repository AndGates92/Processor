library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;
use work.ddr2_phy_pkg.all;
use work.ddr2_mrs_pkg.all;
use work.ddr2_gen_ac_timing_pkg.all;
use work.ddr2_phy_ref_ctrl_pkg.all;

entity ddr2_phy_ref_ctrl is
generic (
	BANK_NUM		: positive := 8
);
port (

	rst			: in std_logic;
	clk			: in std_logic;

	-- Transaction Controller
	RefreshReq		: out std_logic;
	NonReadOpEnable		: out std_logic;
	ReadOpEnable		: out std_logic;

	-- PHY Init
	PhyInitCompleted	: in std_logic;

	-- Bank Controller
	BankIdle		: in std_logic_vector(BANK_NUM - 1 downto 0);

	-- ODT Controller
	ODTCtrlAck		: in std_logic;

	ODTDisable		: out std_logic;
	ODTCtrlReq		: out std_logic;

	-- Arbitrer
	CmdAck			: in std_logic;

	CmdOut			: out std_logic_vector(MEM_CMD_L - 1 downto 0);
	CmdReq			: out std_logic;

	-- Controller
	CtrlReq			: in std_logic;

	CtrlAck			: out std_logic

);
end entity ddr2_phy_ref_ctrl;

architecture rtl of ddr2_phy_ref_ctrl is
	constant zero_auto_ref_cnt_value		: unsigned(AUTO_REF_CNT_L - 1 downto 0) := (others => '0'); 
	constant decr_auto_ref_cnt_value		: unsigned(AUTO_REF_CNT_L - 1 downto 0) := (to_unsigned(1, AUTO_REF_CNT_L));

	constant zero_outstanding_ref_cnt_value		: unsigned(OUTSTANDING_REF_CNT_L - 1 downto 0) := (others => '0'); 
	constant decr_outstanding_ref_cnt_value		: unsigned(OUTSTANDING_REF_CNT_L - 1 downto 0) := (to_unsigned(1, OUTSTANDING_REF_CNT_L));
	constant incr_outstanding_ref_cnt_value		: unsigned(OUTSTANDING_REF_CNT_L - 1 downto 0) := (to_unsigned(1, OUTSTANDING_REF_CNT_L));

	constant incr_enable_op_cnt_value		: unsigned(ENABLE_OP_CNT_L - 1 downto 0) := (to_unsigned(1, ENABLE_OP_CNT_L));

	constant all_banks_idle				: std_logic_vector(BANK_NUM - 1 downto 0) := std_logic_vector(to_unsigned(((2**(BANK_NUM))-1), BANK_NUM));

	signal CntOutstandingRefN, CntOutstandingRefC		: unsigned(OUTSTANDING_REF_CNT_L - 1 downto 0);
	signal IncrOutstandingRefCnt				: std_logic;
	signal DecrOutstandingRefCnt				: std_logic;
	signal ZeroOutstandingRefCnt				: std_logic;
	signal IncrDecrOutstandingRefCntVec			: std_logic_vector(1 downto 0);

	signal CntAutoRefN, CntAutoRefC		: unsigned(AUTO_REF_CNT_L - 1 downto 0);
	signal AutoRefCntEnN, AutoRefCntEnC	: std_logic;
	signal CntAutoRefInitValue		: unsigned(AUTO_REF_CNT_L - 1 downto 0);
	signal SetAutoRefCnt			: std_logic;
	signal ZeroAutoRefCnt			: std_logic;

	signal Cmd_comb				: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal CmdReqN, CmdReqC			: std_logic;

	signal CtrlAckN, CtrlAckC		: std_logic;

	signal StateN, StateC			: std_logic_vector(STATE_REF_CTRL_L - 1 downto 0);

	signal NonReadOpEnableTimeReached		: std_logic;
	signal ReadOpEnableN, ReadOpEnableC		: std_logic;
	signal NonReadOpEnableN, NonReadOpEnableC	: std_logic;

	signal CntEnableOpN, CntEnableOpC			: unsigned(ENABLE_OP_CNT_L - 1 downto 0);
	signal EnableOpCntEnN, EnableOpCntEnC			: std_logic;
	signal CntEnableOpMaxValueN, CntEnableOpMaxValueC	: unsigned(ENABLE_OP_CNT_L - 1 downto 0);
	signal ResetEnableOpCnt					: std_logic;
	signal MaxEnableOpCnt					: std_logic;

	signal SelfRefresh			: std_logic;
	signal SelfRefreshOpN, SelfRefreshOpC	: std_logic;
	signal RefreshReqN, RefreshReqC		: std_logic;

	signal AnyOpForbiddenN, AnyOpForbiddenC	: std_logic;
	signal AllOpEnableN, AllOpEnableC	: std_logic;

	signal ODTCtrlReqN, ODTCtrlReqC		: std_logic;
	signal ODTDisableN, ODTDisableC		: std_logic;

begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then

			StateC <= REF_CTRL_IDLE;

			CntAutoRefC <= to_unsigned(AUTO_REF_TIME - 1, AUTO_REF_CNT_L);
			AutoRefCntEnC <= '0';

			CntOutstandingRefC <= (others => '0');

			CntEnableOpC <= (others => '0');
			CntEnableOpMaxValueC <= (others => '0');
			EnableOpCntEnC <= '0';

			NonReadOpEnableC <= '0';
			ReadOpEnableC <= '0';

			SelfRefreshOpC <= '0';
			AnyOpForbiddenC <= '0';

			AllOpEnableC <= '0';

			ODTCtrlReqC <= '0';
			ODTDisableC <= '0';

			RefreshReqC <= '0';

			CmdReqC <= '0';

			CtrlAckC <= '0';

		elsif ((clk'event) and (clk = '1')) then

			StateC <= StateN;

			CntAutoRefC <= CntAutoRefN;
			AutoRefCntEnC <= AutoRefCntEnN;

			CntOutstandingRefC <= CntOutstandingRefN;

			CntEnableOpC <= CntEnableOpN;
			CntEnableOpMaxValueC <= CntEnableOpMaxValueN;
			EnableOpCntEnC <= EnableOpCntEnN;

			NonReadOpEnableC <= NonReadOpEnableN;
			ReadOpEnableC <= ReadOpEnableN;

			SelfRefreshOpC <= SelfRefreshOpN;
			AnyOpForbiddenC <= AnyOpForbiddenN;

			AllOpEnableC <= AllOpEnableN;

			ODTCtrlReqC <= ODTCtrlReqN;
			ODTDisableC <= ODTDisableN;

			RefreshReqC <= RefreshReqN;

			CmdReqC <= CmdReqN;

			CtrlAckC <= CtrlAckN;

		end if;
	end process reg;

	CtrlAck <= CtrlAckC;

	ODTCtrlReq <= ODTCtrlReqC;
	ODTDisable <= ODTDisableC;

	CmdReq <= CmdReqC;
	CmdOut <= Cmd_comb;

	ReadOpEnable <= ReadOpEnableC;
	NonReadOpEnable <= NonReadOpEnableC;

	RefreshReq <= RefreshReqC;

	-- Outstanding refresh counter
	with IncrDecrOutstandingRefCntVec select
		CntOutstandingRefN <=	(CntOutstandingRefC + incr_outstanding_ref_cnt_value)	when "10",
					(CntOutstandingRefC - decr_outstanding_ref_cnt_value)	when "01",
					CntOutstandingRefC					when others;
	IncrDecrOutstandingRefCntVec <= IncrOutstandingRefCnt & DecrOutstandingRefCnt;
	DecrOutstandingRefCnt <= (not SelfRefreshOpC) and AllOpEnableC when (StateC = ENABLE_OP) else '0';
	IncrOutstandingRefCnt <= ZeroAutoRefCnt;
	ZeroOutstandingRefCnt <= '1' when (CntOutstandingRefC = zero_outstanding_ref_cnt_value) else '0';

	-- Free running counter
	CntAutoRefN <=	CntAutoRefInitValue	when (SetAutoRefCnt = '1') else
			CntAutoRefC - decr_auto_ref_cnt_value		when (AutoRefCntEnC = '1') else
			CntAutoRefC;
	CntAutoRefInitValue <= to_unsigned(AUTO_REF_TIME - 1, AUTO_REF_CNT_L);
	ZeroAutoRefCnt <= '1' when (CntAutoRefC = zero_auto_ref_cnt_value) else '0';
	SetAutoRefCnt <= ZeroAutoRefCnt;
	AutoRefCntEnN <= PhyInitCompleted and not SelfRefresh; -- Disable during power up and when memory is in self refresh

	CntEnableOpN <=	(others => '0')					when (ResetEnableOpCnt = '1') else
			(CntEnableOpC + incr_enable_op_cnt_value)	when ((EnableOpCntEnC = '1') and (MaxEnableOpCnt = '0')) else 
			CntEnableOpC;

	-- Enable operations after refresh
	CntEnableOpMaxValueN <= 	to_unsigned(AUTO_REFRESH_EXIT_MAX_TIME, ENABLE_OP_CNT_L)	when (StateC = AUTO_REF_REQUEST) else
					to_unsigned(SELF_REFRESH_EXIT_MAX_TIME, ENABLE_OP_CNT_L)	when (StateC = SELF_REF_EXIT_REQUEST) else
					CntEnableOpMaxValueC;

	ResetEnableOpCnt <= CmdAck when ((StateC = AUTO_REF_REQUEST) or (StateC = SELF_REF_EXIT_REQUEST)) else '0';

	EnableOpCntEnN <=	CmdAck						when ((StateC = AUTO_REF_REQUEST) or (StateC = SELF_REF_EXIT_REQUEST)) else 
				not (ReadOpEnableN and NonReadOpEnableN)	when (StateC = ENABLE_OP) else
				'0';

	MaxEnableOpCnt <= '1' when (CntEnableOpC = CntEnableOpMaxValueC) else '0';

	AnyOpForbiddenN <=	'1'	when ((StateC = FINISH_OUTSTANDING_TX) and (BankIdle = all_banks_idle)) else
				'0'	when (StateC = ENABLE_OP) else
				AnyOpForbiddenC;

	NonReadOpEnableTimeReached <= '0' when (((CntEnableOpC < to_unsigned(T_XSNR, ENABLE_OP_CNT_L)) and (SelfRefreshOpC = '1')) or ((MaxEnableOpCnt = '0') and (SelfRefreshOpC = '0'))) else '1';

	ReadOpEnableN <= '0' when ((PhyInitCompleted = '0') or (AnyOpForbiddenN = '1') or ((CntEnableOpC < to_unsigned(T_XSRD, ENABLE_OP_CNT_L)) and (SelfRefreshOpC = '1'))) else '1';
	NonReadOpEnableN <= '0' when ((PhyInitCompleted = '0') or (AnyOpForbiddenN = '1') or ((StateC = ENABLE_OP) and (NonReadOpEnableTimeReached = '0'))) else '1';
	AllOpEnableN <= NonReadOpEnableN and ReadOpEnableN;

	Cmd_comb <=	CMD_SELF_REF_ENTRY	when (StateC = SELF_REF_ENTRY_REQUEST) else 
			CMD_SELF_REF_EXIT	when (StateC = SELF_REF_EXIT_REQUEST) else
			CMD_AUTO_REF;

	CmdReqN <=	'1'	when (((StateC = FINISH_OUTSTANDING_TX) and (CtrlReq = '0') and (BankIdle = all_banks_idle)) or ((StateC = ODT_DISABLE) and (ODTCtrlAck = '1')) or ((StateC = SELF_REF) and (CtrlReq = '1'))) else
			'0'	when (((StateC = AUTO_REF_REQUEST) or (StateC = SELF_REF_ENTRY_REQUEST) or (StateC = SELF_REF_EXIT_REQUEST)) and (CmdAck = '1')) else
			CmdReqC;

	CtrlAckN <= CtrlReq when (((StateC = FINISH_OUTSTANDING_TX) and (BankIdle = all_banks_idle)) or (StateC = SELF_REF)) else '0';

	ODTDisableN <=	CtrlReq			when ((StateC = FINISH_OUTSTANDING_TX) and (BankIdle = all_banks_idle)) else
			not AllOpEnableC	when (StateC = ENABLE_OP) else
			ODTDisableC;

	ODTCtrlReqN <=	CtrlReq					when ((StateC = FINISH_OUTSTANDING_TX) and (BankIdle = all_banks_idle)) else
			(AllOpEnableC and SelfRefreshOpC)	when (StateC = ENABLE_OP) else
			not ODTCtrlAck				when ((StateC = ODT_DISABLE) or (StateC = ODT_ENABLE)) else
			ODTCtrlReqC;

	SelfRefresh <= '1' when (StateC = SELF_REF) else '0';
	SelfRefreshOpN <= CtrlReq when ((StateC = FINISH_OUTSTANDING_TX) and (BankIdle = all_banks_idle)) else SelfRefreshOpC;

	RefreshReqN <=	((not ZeroOutstandingRefCnt) or CtrlReq)	when (StateC = REF_CTRL_IDLE) else
			'0'						when (StateC = ENABLE_OP) else
			RefreshReqC;

	state_det: process(StateC, ZeroOutstandingRefCnt, CtrlReq, BankIdle, CmdAck, ODTCtrlAck, AllOpEnableC, SelfRefreshOpC)
	begin
		StateN <= StateC; -- avoid latches
		if (StateC = REF_CTRL_IDLE) then
			if ((ZeroOutstandingRefCnt = '0') or (CtrlReq = '1')) then -- Need to do auto-refresh or self refresh request
				StateN <= FINISH_OUTSTANDING_TX;
			end if;
		elsif (StateC = FINISH_OUTSTANDING_TX) then
			if (BankIdle = all_banks_idle) then
				if (CtrlReq = '1') then -- Self Refresh Entry Request
					StateN <= ODT_DISABLE;
				else
					StateN <= AUTO_REF_REQUEST;
				end if;
			end if;
		elsif (StateC = AUTO_REF_REQUEST) then
			if (CmdAck = '1') then
				StateN <= ENABLE_OP;
			end if;
		elsif (StateC = ODT_DISABLE) then
			if (ODTCtrlAck = '1') then -- Receive ODT Ack after turn off delay
				StateN <= SELF_REF_ENTRY_REQUEST;
			end if;
		elsif (StateC = SELF_REF_ENTRY_REQUEST) then
			if (CmdAck = '1') then
				StateN <= SELF_REF;
			end if;
		elsif (StateC = SELF_REF) then
			if (CtrlReq = '1') then
				StateN <= SELF_REF_EXIT_REQUEST;
			end if;
		elsif (StateC = SELF_REF_EXIT_REQUEST) then
			if (CmdAck = '1') then
				StateN <= ENABLE_OP;
			end if;
		elsif (StateC = ENABLE_OP) then
			if (AllOpEnableC = '1') then
				if (SelfRefreshOpC = '1') then
					StateN <= ODT_ENABLE;
				else
					StateN <= REF_CTRL_IDLE;
				end if;
			end if;
		elsif (StateC = ODT_ENABLE) then
			if (ODTCtrlAck = '1') then
				StateN <= REF_CTRL_IDLE;
			end if;
		else
			StateN <= StateC;
		end if;
	end process state_det;

end rtl;