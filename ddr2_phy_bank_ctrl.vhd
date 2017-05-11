library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ddr2_pkg.all;
use work.ddr2_phy_pkg.all;
use work.ddr2_phy_bank_ctrl_pkg.all;

entity ddr2_phy_bank_ctrl is
port (

	rst		: in std_logic;
	clk		: in std_logic;

	-- User Interface
	ColMemIn	: in std_logic_vector(COL_L - 1 downto 0);
	RowMemIn	: in std_logic_vector(ROW_L - 1 downto 0);
	ReadMem		: in std_logic;
	LastBurst	: in std_logic;
	UIReq		: in std_logic;

	UIAck		: out std_logic;

	-- Arbitrer
	ColMemOut		: out std_logic_vector(COL_L - 1 downto 0);
	RowMemOut		: out std_logic_vector(ROW_L - 1 downto 0);
	CmdOut			: out std_logic_vector(CMD_MEM_L - 1 downto 0);
	CmdReq			: out std_logic;

	CmdAck			: in std_logic;

);
end entity ddr2_phy_bank_ctrl;

architecture rtl of ddr2_phy_bank_ctrl is

	signal BankActiveC, BankActiveN		: std_logic;

	signal TActColExceeded		: std_logic;
	signal TRASExceeded		: std_logic;
	signal TRPExceeded		: std_logic;
	signal TRCExceeded		: std_logic;
	signal TWrPREExceeded		: std_logic;
	signal TRdPREExceeded		: std_logic;
	signal TColColExceeded		: std_logic;
	signal CntBankCtrlC, CntBankCtrlN	: unsigned(CNT_BANK_CTRL_L - 1 downto 0);
	signal CntDelayC, CntDelayN		: unsigned(CNT_DELAY_L - 1 downto 0);

	signal StateC, StateN			: std_logic_vector(STATE_BANK_CTRL_L - 1 downto 0);

begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then

			StateC <= START_INIT;

		elsif ((clk'event) and (clk = '1')) then

			StateC <= StateN;

		end if;
	end process reg;



	TActColExceeded <= not (CntBankCtrlC < to_unsigned(T_ACT_COL));
	TRASExceeded <= not (CntBankCtrlC < to_unsigned(T_RAS));
	TRCExceeded <= not (CntBankCtrlC < to_unsigned(T_RC));
	TWrPREExceeded <= not (CntBankCtrlC < to_unsigned(T_WRITE_PRE));
	TRdPREExceeded <= not (CntBankCtrlC < to_unsigned(T_READ_PRE));

	TRPExceeded <= not (CntDelayC < to_unsigned(T_RP));
	TColColExceeded <= not (CntDelayC < to_unsigned(T_COL_COL));

	state_det: process(StateC, UIReq)
	begin
		StateN <= StateC; -- avoid latched
		if (StateC = IDLE) then
			if (UIReq = '1') then
				StateN <= WAIT_ACT_ACK;
			end if;
		elsif (StateC = WAIT_ACT_ACK) then
		end if;
	end process state_det;
	
end rtl;
