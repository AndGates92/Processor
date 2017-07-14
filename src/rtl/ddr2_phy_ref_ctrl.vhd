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
	NonReadEn		: out std_logic;
	ReadEn			: out std_logic;

	-- PHY Init
	PhyInitCompleted	: in std_logic;

	-- Bank Controller
	BankIdle		: in std_logic_vector(BANK_NUM - 1 downto 0);

	-- ODT controller
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

	signal StateN, StateC			: std_logic_vector(STATE_REF_CTRL_L - 1 downto 0);

	signal ReadOpEnableN, ReadOpEnableC		: std_logic;
	signal NonReadOpEnableN, NonReadOpEnableC	: std_logic;

	signal CntEnableOpN, CntEnableOpC				: unsigned(ENABLE_OP_CNT_L - 1 downto 0);
	signal EnableOpCntEnN, EnableOpCntEnC				: std_logic;
	signal CntEnableOpInitMaxValueN, CntEnableOpInitMaxValueC	: unsigned(ENABLE_OP_CNT_L - 1 downto 0);
	signal ResetEnableOpCnt						: std_logic;
	signal MaxEnableOpCnt						: std_logic;



begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then

			-- Initialize at T_REFI - 2 because count down until 0 and enable signal is registered out
			CntAutoRefC <= to_unsigned(AUTO_REF_TIME - 2, AUTO_REF_CNT_L);
			AutoRefCntEnC <= '0';

			CntOutstandingRefC <= (others => '0');

			CntEnableOpC <= (others => '0');
			CntEnableOpInitMaxValueC <= (others => '0');
			EnableOpCntEnC <= '0';

			StateC <= REF_CTRL_IDLE;

		elsif ((clk'event) and (clk = '1')) then

			CntAutoRefC <= CntAutoRefN;
			AutoRefCntEnC <= AutoRefCntEnN;

			CntOutstandingRefC <= CntOutstandingRefN;

			CntEnableOpC <= CntEnableN;
			CntEnableOpInitMaxValueC <= CntEnableOpInitMaxValueN;
			EnableOpCntEnC <= EnableOpCntEnN;

			StateC <= StateN;

		end if;
	end process reg;

	-- Outstanding refresh counter
	select IncrDecrOutstandingRefCntVec with
		CntOutstandingRefN <=	(CntOutstandingRefC + incr_outstanding_ref_cnt_value) when "10"
					(CntOutstandingRefC - decr_outstanding_ref_cnt_value) when "01"
					CntOutstandingRefC;
	IncrDecrOutstandingRefCntVec <= IncrOutstandingRefCnt & DecrOutstandingRefCnt;
	DecrOutstandingRefCnt <= 
	IncrOutstandingRefCnt <= ZeroAutoRefCnt;
	ZeroOutstandingRefCnt <= '1' when (CntOutstandingRefC = zero_outstanding_ref_cnt_value) else '0';

	-- Free running counter
	CntAutoRefN <=	to_unsigned(AUTO_REF_TIME - 1, AUTO_REF_CNT_L) when (SetAutoRefCnt = '1') else
			CntAutoRefC - decr_auto_ref_cnt_value when (AutoRefCntEnC = '1') else
			CntAutoRefC;
	ZeroAutoRefCnt <= '1' when (CntAutoRefC = zero_auto_ref_cnt_value) else '0';
	SetAutoRefCnt <= ZeroAutoRefCnt;
	AutoRefCntEnN <= PhyInitCompleted and not SelfRefresh; -- Disable during power up and when memory is in self refresh

	CntEnableOpN <=	(others => '0') when (ResetEnableOp = '1') else
			CntEnableOpC + incr_enable_op_cnt_value when ((EnableOpCntEnC = '1') and (MaxEnableOpCnt = '1')) else 
			CntEnableOpC;

	CntEnableOpInitMaxValueN <= 	to_unsigned(AUTO_REFRESH_EXIT_MAX_TIME, ENABLE_OP_CNT_L) when (StateC = AUTO_REF_REQUEST) else
					to_unsigned(SELF_REFRESH_EXIT_MAX_TIME, ENABLE_OP_CNT_L) when (StateC = SELF_REF_EXIT_REQUEST) else
					CntEnableOpInitMaxValueC;

	ResetEnableOpCnt <= CmdAck when ((StateC = AUTO_REF_REQUEST) or (StateC = SELF_REF_EXIT_REQUEST)) else '0';

	EnableOpCntEnN <=	CmdAck when ((StateC = AUTO_REF_REQUEST) or (StateC = SELF_REF_EXIT_REQUEST)) else 
				not (ReadOpEnableN and ReadOpEnableN) when (StateC = ENABLE_OP) else
				'0';

	state_det: process(StateC)
	begin
		StateN <= StateC; -- avoid latches
		if (StateC = REF_CTRL_IDLE) then
			if (ZeroOutstandingRefCnt = '0') then
				StateN <= FINISH_OUTSTANDING_TX;
			elsif (CtrlReq = '1') then -- Self Refresh Entry Request
				StateN <= ODT_DISABLE;
			end if;
		elsif (StateC = FINISH_OUTSTANDING_TX) then
			if (BankIdle = all_banks_idle) then
				StateN <= AUTO_REF_REQUEST;
			end if;
		elsif (StateC = AUTO_REF_REQUEST) then
			if (CmdAck = '1') then
				StateN <= ENABLE_OP;
			end if;
		else
			StateN <= StateC;
		end if;
	end process state_det;


end rtl;
