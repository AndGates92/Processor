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

	constant OUTSTANDING_REF_CNT_L	: positive := int_to_bit_num(MAX_OUTSTANDING_REF);
	constant zero_outstanding_ref_cnt_value		: unsigned(OUTSTANDING_REF_CNT_L - 1 downto 0) := (others => '0'); 
	constant decr_outstanding_ref_cnt_value		: unsigned(OUTSTANDING_REF_CNT_L - 1 downto 0) := (to_unsigned(1, OUTSTANDING_REF_CNT_L));
	constant incr_outstanding_ref_cnt_value		: unsigned(OUTSTANDING_REF_CNT_L - 1 downto 0) := (to_unsigned(1, OUTSTANDING_REF_CNT_L));

	signal CntOutstandingRefN, CntOutstandingRefC		: unsigned(OUTSTANDING_REF_CNT_L - 1 downto 0);
	signal OutstandingRefCntEnN, OutstandingRefCntEnC	: std_logic;
	signal IncrOutstandingRefCnt				: std_logic;
	signal DecrOutstandingRefCnt				: std_logic;
	signal ZeroOutstandingRefCnt				: std_logic;

	signal CntAutoRefN, CntAutoRefC		: unsigned(AUTO_REF_CNT_L - 1 downto 0);
	signal AutoRefCntEnN, AutoRefCntEnC	: std_logic;
	signal CntAutoRefInitValue		: unsigned(AUTO_REF_CNT_L - 1 downto 0);
	signal SetAutoRefCnt			: std_logic;
	signal ZeroAutoRefCnt			: std_logic;

	signal StateN, StateC			: std_logic_vector(STATE_REF_CTRL_L - 1 downto 0);

begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then

			-- Initialize at T_REFI - 2 because count down until 0 and enable signal is registered out
			CntAutoRefC <= to_unsigned(AUTO_REF_TIME - 2, AUTO_REF_CNT_L);
			AutoRefCntEnC <= '0';

			StateC <= REF_CTRL_IDLE;

		elsif ((clk'event) and (clk = '1')) then

			AutoRefCntC <= AutoRefCntN;
			AutoRefCntEnC <= AutoRefCntEnN;

			StateC <= StateN;

		end if;
	end process reg;

	-- Free running counter
	AutoRefCntEnN <= PhyInitCompleted;
	CntAutoRefN <=	to_unsigned(AUTO_REF_TIME - 1, AUTO_REF_CNT_L) when (SetAutoRefCnt = '1') else
			CntAutoRefC - decr_auto_ref_cnt_value when (AutoRefCntEnC = '1') else
			CntAutoRefC;
	ZeroAutoRefCnt <= '1' when (CntAutoRefC = zero_auto_ref_cnt_value) else '0';
	SetAutoRefCnt <= ZeroAutoRefCnt;

	state_det: process(StateC)
	begin
		StateN <= StateC; -- avoid latches
		if (StateC = REF_CTRL_IDLE) then

		else
			StateN <= StateC;
		end if;
	end process state_det;


end rtl;
