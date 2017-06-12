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


	signal ColMemN, ColMemC			: std_logic_vector(COL_L - 1 downto 0);
	signal ReadBurstN, ReadBurstC		: std_logic;
	signal BankMemN, BankMemC		: std_logic_vector(int_to_bit_num(BANK_NUM) - 1 downto 0);
	signal CmdN, CmdC			: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal CmdReqN, CmdReqC			: std_logic;

	signal BurstLengthN, BurstLengthC	: std_logic_vector(BURST_LENGTH_L - 1 downto 0);

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

		elsif ((clk'event) and (clk = '1')) then

			ColMemC <= ColMemN;
			ReadBurstC <= ReadBurstN;
			BankMemC <= BankMemN;
			CmdC <= CmdN;
			CmdReqC <= CmdReqC;

			BurstLengthC <= BurstLengthN;

		end if;
	end process reg;

	ColMemOut <= ColMemC;
	ReadBurstOut <= ReadBurstC;
	BankMemOut <= BankMemC;
	CmdOut <= CmdC;
	CmdReq <= CmdReqC;
