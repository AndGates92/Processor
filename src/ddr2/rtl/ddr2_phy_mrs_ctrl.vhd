library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;
use work.ddr2_phy_pkg.all;
use work.ddr2_gen_ac_timing_pkg.all;
use work.ddr2_phy_mrs_ctrl_pkg.all;

entity ddr2_phy_mrs_ctrl is
generic (
	MRS_REG_L	: positive := 13
);
port (

	rst			: in std_logic;
	clk			: in std_logic;

	-- Transaction Controller
	CtrlReq			: in std_logic;
	CtrlCmd			: in std_logic_vector(MEM_CMD_L - 1 downto 0);
	CtrlData		: in std_logic_vector(MRS_REG_L - 1 downto 0);

	CtrlAck			: out std_logic;

	-- Commands
	CmdAck			: in std_logic;

	CmdReq			: out std_logic;
	Cmd			: out std_logic_vector(MEM_CMD_L - 1 downto 0);
	Data			: out std_logic_vector(MRS_REG_L - 1 downto 0);

	-- ODT Controller
	ODTCtrlAck		: in std_logic;

	ODTCtrlReq		: out std_logic;

	-- Turn ODT signal on after MRS command(s)
	MRSUpdateCompleted	: out std_logic
);
end entity ddr2_phy_mrs_ctrl;

architecture rtl of ddr2_phy_mrs_ctrl is

	constant zero_delay_cnt_value	: unsigned(CNT_MRS_CTRL_L - 1 downto 0) := (others => '0'); 
	constant decr_delay_cnt_value	: unsigned(CNT_MRS_CTRL_L - 1 downto 0) := to_unsigned(1, CNT_MRS_CTRL_L);

	signal StateC, StateN		: std_logic_vector(STATE_MRS_CTRL_L - 1 downto 0);

	signal ODTCtrlReqC, ODTCtrlReqN	: std_logic;

	signal CtrlAckC, CtrlAckN	: std_logic;

	signal MRSUpdateCompletedC, MRSUpdateCompletedN	: std_logic;

	signal CmdReqC, CmdReqN		: std_logic;
	signal CmdC, CmdN		: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal DataC, DataN		: std_logic_vector(MRS_REG_L - 1 downto 0);

	signal DelayCntC, DelayCntN	: unsigned(CNT_MRS_CTRL_L - 1 downto 0);
	signal DelayCntEnC, DelayCntEnN	: std_logic;
	signal SetDelayCnt		: std_logic;
	signal DelayCntInitValue	: unsigned(CNT_MRS_CTRL_L - 1 downto 0);
	signal ZeroDelayCnt		: std_logic;

begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then

			StateC <= MRS_CTRL_IDLE;

			DelayCntC <= (others => '0');
			DelayCntEnC <= '0';

			ODTCtrlReqC <= '0';

			CtrlAckC <= '0';

			CmdReqC <= '0';
			CmdC <= (others => '0');
			DataC <= (others => '0');

			MRSUpdateCompletedC <= '0';

		elsif ((clk'event) and (clk = '1')) then

			StateC <= StateN;

			DelayCntC <= DelayCntN;
			DelayCntEnC <= DelayCntEnN;

			ODTCtrlReqC <= ODTCtrlReqN;

			CtrlAckC <= CtrlAckN;

			CmdReqC <= CmdReqN;
			CmdC <= CmdN;
			DataC <= DataN;

			MRSUpdateCompletedC <= MRSUpdateCompletedN;

		end if;
	end process reg;

	-- Assign outputs
	MRSUpdateCompleted <= MRSUpdateCompletedC;
	CtrlAck <= CtrlAckC;
	CmdReq <= CmdReqC;
	Cmd <= CmdC;
	Data <= DataC;
	ODTCtrlReq <= ODTCtrlReqC;

	-- Request ODT turn off before sending MRS commands
	ODTCtrlReqN <=	CtrlReq		when (StateC = MRS_CTRL_IDLE) else
			not ODTCtrlAck	when (StateC = MRS_CTRL_ODT_TURN_OFF) else
			ODTCtrlReqC;

	-- Assert command request on the way in to MRS_CTRL_SEND_CMD
	CmdReqN <=	not CmdAck			when (StateC = MRS_CTRL_SEND_CMD) else
			ODTCtrlAck			when (StateC = MRS_CTRL_ODT_TURN_OFF) else
			(ZeroDelayCnt and CtrlReq)	when (StateC = MRS_CTRL_REG_UPD) else
			CmdReqC;

	-- Ack command when idle or after updating MRS register
	CtrlAckN <=	CtrlReq				when (StateC = MRS_CTRL_IDLE) else
			(ZeroDelayCnt and CtrlReq)	when (StateC = MRS_CTRL_REG_UPD) else
			 '0';

	CmdN <= CtrlCmd when ((StateC = MRS_CTRL_IDLE) or ((StateC = MRS_CTRL_REG_UPD) and (ZeroDelayCnt = '1') and (CtrlReq = '1'))) else CmdC;
	DataN <= CtrlData when ((StateC = MRS_CTRL_IDLE) or ((StateC = MRS_CTRL_REG_UPD) and (ZeroDelayCnt = '1') and (CtrlReq = '1'))) else DataC;

	ZeroDelayCnt <= '1' when (DelayCntC = zero_delay_cnt_value) else '0';

	DelayCntN <=	DelayCntInitValue			when (SetDelayCnt = '1') else
			DelayCntC - decr_delay_cnt_value	when ((DelayCntEnC = '1') and (ZeroDelayCnt = '0')) else
			DelayCntC;

	-- Count
	DelayCntEnN <=	CmdAck			when (StateC = MRS_CTRL_SEND_CMD) else
			not ZeroDelayCnt	when (StateC = MRS_CTRL_REG_UPD) else
			DelayCntEnC;

	-- Set delay counter after sending MRS command
	SetDelayCnt <=	CmdAck when (StateC = MRS_CTRL_SEND_CMD) else '0';

	DelayCntInitValue <= to_unsigned(T_MOD_max, CNT_MRS_CTRL_L);

	-- Complete MRS update if no outstanding requests
	MRSUpdateCompletedN <=	(ZeroDelayCnt and not CtrlReq)	when(StateC = MRS_CTRL_REG_UPD) else
				(not ODTCtrlAck)		when (StateC = MRS_CTRL_ODT_TURN_ON) else
				MRSUpdateCompletedC;

	state_det : process(StateC, CtrlReq, CtrlCmd, CtrlData, ODTCtrlAck, ZeroDelayCnt, CmdAck)
	begin

		-- avoid latches
		StateN <= StateC;

		if (StateC = MRS_CTRL_IDLE) then
			if (CtrlReq = '1') then
				StateN <= MRS_CTRL_ODT_TURN_OFF;
			end if;
		elsif (StateC = MRS_CTRL_ODT_TURN_OFF) then
			if (ODTCtrlAck = '1') then
				StateN <= MRS_CTRL_SEND_CMD;
			end if;
		elsif (StateC = MRS_CTRL_SEND_CMD) then
			if (CmdAck = '1') then
				StateN <= MRS_CTRL_REG_UPD;
			end if;
		elsif (StateC = MRS_CTRL_REG_UPD) then
			if (ZeroDelayCnt = '1') then
				if (CtrlReq = '1') then
					StateN <= MRS_CTRL_SEND_CMD;
				else
					StateN <= MRS_CTRL_ODT_TURN_ON;
				end if;
			end if;
		elsif (StateC = MRS_CTRL_ODT_TURN_ON) then
			if (ODTCtrlAck = '1') then
				StateN <= MRS_CTRL_IDLE;
			end if;
		end if;

	end process state_det;

end rtl;
