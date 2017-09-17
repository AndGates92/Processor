library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;
use work.ddr2_gen_ac_timing_pkg.all;
use work.ddr2_phy_pkg.all;
use work.ddr2_phy_odt_ctrl_pkg.all;

entity ddr2_phy_odt_ctrl is
--generic (

--);
port (

	rst			: in std_logic;
	clk			: in std_logic;

	-- Command sent to memory
	Cmd			: in std_logic_vector(MEM_CMD_L - 1 downto 0);

	-- MRS Controller
	MRSCtrlReq		: in std_logic;
	MRSUpdateCompleted	: in std_logic;

	MRSCtrlAck		: out std_logic;

	-- Refresh Controller
	RefCtrlReq		: in std_logic;

	RefCtrlAck		: out std_logic;

	-- Stop Arbiter
	PauseArbiter		: out std_logic;

	-- ODT
	ODT			: out std_logic
);
end entity ddr2_phy_odt_ctrl;

architecture rtl of ddr2_phy_odt_ctrl is

	constant zero_delay_cnt_value	: unsigned(CNT_ODT_CTRL_L - 1 downto 0) := (others => '0'); 
	constant decr_delay_cnt_value	: unsigned(CNT_ODT_CTRL_L - 1 downto 0) := to_unsigned(1, CNT_ODT_CTRL_L);

	signal StateC, StateN		: std_logic_vector(STATE_ODT_CTRL_L - 1 downto 0);

	signal DelayCntC, DelayCntN	: unsigned(CNT_ODT_CTRL_L - 1 downto 0);
	signal DelayCntEnC, DelayCntEnN	: std_logic;
	signal SetDelayCnt		: std_logic;
	signal DelayCntInitValue	: unsigned(CNT_ODT_CTRL_L - 1 downto 0);
	signal ZeroDelayCnt		: std_logic;

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
	PauseArbiter <= '1' when ((StateC = ODT_TURN_OFF) or ((StateC = ODT_MRS_UPD) and (MRSUpdateCompleted = '0')) or ((StateC = ODT_REF_REQ) and (RefCtrlReq = '0'))) else '0';

	-- Ack MRS controller request after delay has expired
	MRSCtrlAck <= (ZeroDelayCnt and MRSCtrlReq) when (StateC = ODT_TURN_OFF) else '0';

	-- Ack Refresh controller request after delay has expired
	RefCtrlAck <= (ZeroDelayCnt and RefCtrlReq) when ((StateC = ODT_TURN_OFF) or (StateC = ODT_REF_REQ)) else '0';

	-- ODT is brought low if:
	-- Read command
	-- MRS controller requests
	-- Refresh controller requests
	ODT <= '0' when (((StateC = ODT_CTRL_IDLE) and ((Cmd = CMD_READ_PRECHARGE) or (Cmd = CMD_READ) or (MRSCtrlReq = '1') or (RefCtrlReq = '1'))) or (StateC = ODT_TURN_OFF) or ((StateC = ODT_MRS_UPD) and (MRSUpdateCompleted = '0')) or ((StateC = ODT_REF_REQ) and (RefCtrlReq = '0'))) else '1';

	ZeroDelayCnt <= '1' when (DelayCntC = zero_delay_cnt_value) else '0';

	DelayCntN <=	DelayCntInitValue			when (SetDelayCnt = '1') else
			DelayCntC - decr_delay_cnt_value	when ((DelayCntEnC = '1') and (ZeroDelayCnt = '0')) else
			DelayCntC;

	-- Count
	DelayCntEnN <=	(MRSCtrlReq or RefCtrlReq)		when (StateC = ODT_CTRL_IDLE) else
			not ZeroDelayCnt			when (StateC = ODT_TURN_OFF) else
			RefCtrlReq and (not ZeroDelayCnt)	when (StateC = ODT_REF_REQ) else
			DelayCntEnC;

	-- Set delay counter when toggling ODT signal
	SetDelayCnt <=	(MRSCtrlReq or RefCtrlReq)	when (StateC = ODT_CTRL_IDLE) else
			(ZeroDelayCnt and RefCtrlReq)	when (StateC = ODT_TURN_OFF) else
			'0';

	DelayCntInitValue <= to_unsigned(T_AOFD, CNT_ODT_CTRL_L) when (StateC = ODT_CTRL_IDLE) else to_unsigned(T_AOND, CNT_ODT_CTRL_L);

	state_det : process(StateC, MRSCtrlReq, MRSUpdateCompleted, RefCtrlReq)
	begin

		-- avoid latches
		StateN <= StateC;

		if (StateC = ODT_CTRL_IDLE) then
			if (((MRSCtrlReq = '1') or (RefCtrlReq = '1')) and (Cmd /= CMD_READ_PRECHARGE) and (Cmd /= CMD_READ) and (Cmd /= CMD_READ_PRECHARGE) and (Cmd /= CMD_READ) and (Cmd /= CMD_BANK_ACTIVATE)) then
				StateN <= ODT_TURN_OFF;
			end if;
		elsif (StateC = ODT_TURN_OFF) then
			if (ZeroDelayCnt = '1') then
				if (MRSCtrlReq = '1') then
					StateN <= ODT_MRS_UPD;
				elsif (RefCtrlReq = '1') then
					StateN <= ODT_REF_REQ;
				end if;
			end if;
		elsif (StateC = ODT_MRS_UPD) then
			if (MRSUpdateCompleted = '1') then
				StateN <= ODT_CTRL_IDLE;
			end if;
		elsif (StateC = ODT_REF_REQ) then
			if ((ZeroDelayCnt = '1') and (RefCtrlReq = '1')) then
				StateN <= ODT_CTRL_IDLE;
			end if;
		end if;

	end process reg;

end rtl;
