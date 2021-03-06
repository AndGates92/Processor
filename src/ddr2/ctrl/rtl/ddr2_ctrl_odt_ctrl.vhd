library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library common_rtl_pkg;
use common_rtl_pkg.functions_pkg.all;
library ddr2_ctrl_rtl_pkg;
use ddr2_ctrl_rtl_pkg.ddr2_ctrl_pkg.all;
use ddr2_ctrl_rtl_pkg.ddr2_ctrl_odt_ctrl_pkg.all;
use ddr2_ctrl_rtl_pkg.ddr2_odt_ac_timing_pkg.all;

entity ddr2_ctrl_odt_ctrl is
--generic (

--);
port (

	rst			: in std_logic;
	clk			: in std_logic;

	-- Command sent to memory
	Cmd			: in std_logic_vector(MEM_CMD_L - 1 downto 0);

	NoBankColCmd		: in std_logic;

	-- MRS Controller
	MRSCmdAccepted		: in std_logic;
	MRSCtrlReq		: in std_logic;
	MRSCmd			: in std_logic_vector(MEM_CMD_L - 1 downto 0);
	MRSUpdateCompleted	: in std_logic;
	LastMRSCmd		: in std_logic;

	MRSCtrlAck		: out std_logic;

	-- Refresh Controller
	RefCmdAccepted		: in std_logic;
	RefCtrlReq		: in std_logic;
	RefCmd			: in std_logic_vector(MEM_CMD_L - 1 downto 0);

	RefCtrlAck		: out std_logic;

	-- Stop Arbiter
	PauseArbiter		: out std_logic;

	-- ODT
	ODT			: out std_logic
);
end entity ddr2_ctrl_odt_ctrl;

architecture rtl of ddr2_ctrl_odt_ctrl is

	constant zero_delay_cnt_value	: unsigned(CNT_ODT_CTRL_L - 1 downto 0) := (others => '0'); 
	constant decr_delay_cnt_value	: unsigned(CNT_ODT_CTRL_L - 1 downto 0) := to_unsigned(1, CNT_ODT_CTRL_L);

	signal StateC, StateN		: std_logic_vector(STATE_ODT_CTRL_L - 1 downto 0);

	signal DelayCntC, DelayCntN	: unsigned(CNT_ODT_CTRL_L - 1 downto 0);
	signal DelayCntEnC, DelayCntEnN	: std_logic;
	signal SetDelayCnt		: std_logic;
	signal DelayCntInitValue	: unsigned(CNT_ODT_CTRL_L - 1 downto 0);
	signal ZeroDelayCnt		: std_logic;
	signal MRSCmdIn			: std_logic;
	signal RefEntryCmdIn		: std_logic;
	signal RefExitCmdIn		: std_logic;

begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then

			StateC <= ODT_CTRL_IDLE;

			DelayCntC <= (others => '0');
			DelayCntEnC <= '0';

		elsif ((clk'event) and (clk = '1')) then

			StateC <= StateN;

			DelayCntC <= DelayCntN;
			DelayCntEnC <= DelayCntEnN;

		end if;
	end process reg;

	-- pause arbiter when updating MRS registers, waiting MRS turn off register or Refresh controller request
	PauseArbiter <= '1' when (((StateC = ODT_CTRL_MRS_UPD) and (MRSUpdateCompleted = '0') and (LastMRSCmd = '1')) or ((StateC = ODT_CTRL_REF_REQ) and (RefCtrlReq = '0'))) else '0';

	-- Ack MRS controller request after delay has expired
	MRSCtrlAck <=	(ZeroDelayCnt and MRSCtrlReq)		when (StateC = ODT_CTRL_TURN_OFF_MRS) else
 			(MRSCtrlReq and MRSUpdateCompleted)	when (StateC = ODT_CTRL_MRS_UPD) else
			'0';

	-- Ack Refresh controller request after delay has expired
	RefCtrlAck <= (ZeroDelayCnt and RefCtrlReq) when ((StateC = ODT_CTRL_TURN_OFF_REF) or (StateC = ODT_CTRL_REF_REQ)) else '0';

	-- ODT is brought low if:
	-- Read command and valid Bank/Col command (NoBankColCmd = 0)
	-- MRS controller requests and invalid Bank/Col command (NoBankColCmd = 1)
	-- Refresh controller requests and invalid Bank/Col command (NoBankColCmd = 1)
	ODT <= '0' when (((StateC = ODT_CTRL_IDLE) and (((NoBankColCmd = '0') and ((Cmd = CMD_READ_PRECHARGE) or (Cmd = CMD_READ))) or ((NoBankColCmd = '1') and ((MRSCtrlReq = '1') or (RefCtrlReq = '1'))))) or (StateC = ODT_CTRL_TURN_OFF_MRS) or (StateC = ODT_CTRL_TURN_OFF_REF) or ((StateC = ODT_CTRL_MRS_UPD) and (MRSUpdateCompleted = '0')) or ((StateC = ODT_CTRL_REF_REQ) and (RefCtrlReq = '0'))) else '1';

	ZeroDelayCnt <= '1' when (DelayCntC = zero_delay_cnt_value) else '0';

	DelayCntN <=	DelayCntInitValue			when (SetDelayCnt = '1') else
			DelayCntC - decr_delay_cnt_value	when ((DelayCntEnC = '1') and (ZeroDelayCnt = '0')) else
			DelayCntC;

	-- Count
	DelayCntEnN <=	((MRSCtrlReq or RefCtrlReq) and NoBankColCmd)		when (StateC = ODT_CTRL_IDLE) else
			not ZeroDelayCnt					when ((StateC = ODT_CTRL_TURN_OFF_REF) or (StateC = ODT_CTRL_TURN_OFF_MRS)) else
			RefCtrlReq and (not ZeroDelayCnt)			when (StateC = ODT_CTRL_REF_REQ) else
			DelayCntEnC;

	MRSCmdIn <= '1' when ((MRSCmd = CMD_MODE_REG_SET) or (MRSCmd = CMD_EXT_MODE_REG_SET_1) or (MRSCmd = CMD_EXT_MODE_REG_SET_2) or (MRSCmd = CMD_EXT_MODE_REG_SET_3)) else '0';
	RefEntryCmdIn <= '1' when ((RefCmd = CMD_SELF_REF_ENTRY)) else '0';
	RefExitCmdIn <= '1' when ((RefCmd = CMD_SELF_REF_EXIT)) else '0';

	-- Set delay counter when toggling ODT signal
	SetDelayCnt <=	NoBankColCmd and ((MRSCtrlReq and MRSCmdIn) or (RefCtrlReq and RefEntryCmdIn))	when (StateC = ODT_CTRL_IDLE) else
			(ZeroDelayCnt and RefCmdAccepted)						when (StateC = ODT_CTRL_TURN_OFF_REF) else -- Refresh Exit
			'0';

	DelayCntInitValue <= to_unsigned(T_AOFD, CNT_ODT_CTRL_L) when (StateC = ODT_CTRL_IDLE) else to_unsigned(T_AOND_max, CNT_ODT_CTRL_L);

	state_det : process(StateC, MRSCtrlReq, MRSUpdateCompleted, RefCtrlReq, RefEntryCmdIn, MRSCmdIn, RefExitCmdIn, ZeroDelayCnt, MRSCmdAccepted, RefCmdAccepted, NoBankColCmd)
	begin

		-- avoid latches
		StateN <= StateC;

		if (StateC = ODT_CTRL_IDLE) then
			if (NoBankColCmd = '1') then
				if ((MRSCmdIn = '1') and (MRSCtrlReq = '1')) then
						StateN <= ODT_CTRL_TURN_OFF_MRS;
				elsif ((RefEntryCmdIn = '1') and (RefCtrlReq = '1')) then
					StateN <= ODT_CTRL_TURN_OFF_REF;
				end if;
			end if;
		elsif (StateC = ODT_CTRL_TURN_OFF_MRS) then
			if (ZeroDelayCnt = '1') then
				if (MRSCmdAccepted = '1') then
					StateN <= ODT_CTRL_MRS_UPD;
				end if;
			end if;
		elsif (StateC = ODT_CTRL_TURN_OFF_REF) then
			if (ZeroDelayCnt = '1') then
				if (RefCmdAccepted = '1') then
					StateN <= ODT_CTRL_REF_REQ;
				end if;
			end if;
		elsif (StateC = ODT_CTRL_MRS_UPD) then
			if ((MRSUpdateCompleted = '1') and (MRSCtrlReq = '1')) then
				StateN <= ODT_CTRL_IDLE;
			end if;
		elsif (StateC = ODT_CTRL_REF_REQ) then
			if ((ZeroDelayCnt = '1') and (RefCtrlReq = '1') and (RefExitCmdIn = '1')) then
				StateN <= ODT_CTRL_IDLE;
			end if;
		end if;

	end process state_det;

end rtl;
