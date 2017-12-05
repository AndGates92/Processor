library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library common_rtl_pkg;
use common_rtl_pkg.functions_pkg.all;
library ddr2_ctrl_rtl_pkg;
use ddr2_ctrl_rtl_pkg.ddr2_ctrl_pkg.all;
use ddr2_ctrl_rtl_pkg.ddr2_ctrl_cmd_dec_pkg.all;

entity ddr2_ctrl_cmd_dec is
generic (
	BANK_NUM	: positive := 8;
	COL_L		: positive := 10;
	ROW_L		: positive := 14;
	ADDR_L		: positive := 14
);
port (
	rst	: in std_logic;
	clk	: in std_logic;

	-- Arbiter
	ColIn	: in std_logic_vector(COL_L - 1 downto 0);
	RowIn	: in std_logic_vector(ROW_L - 1 downto 0);
	BankIn	: in std_logic_vector(int_to_bit_num(BANK_NUM) - 1 downto 0);
	CmdIn	: in std_logic_vector(MEM_CMD_L - 1 downto 0);
	MRSCmd	: in std_logic_vector(ADDR_L - 1 downto 0);

	-- Memory
	ClkEnable		: out std_logic;
	nChipSelect		: out std_logic;
	nRowAccessStrobe	: out std_logic;
	nColAccessStrobe	: out std_logic;
	nWriteEnable		: out std_logic;
	BankOut			: out std_logic_vector(int_to_bit_num(BANK_NUM) - 1 downto 0);
	Address			: out std_logic_vector(ADDR_L - 1 downto 0)
);
end entity ddr2_ctrl_cmd_dec;

architecture rtl of ddr2_ctrl_cmd_dec is

	constant MAX_COL_L				: integer := (ADDR_L - 1);

	constant row_cmd_zero_padding			: std_logic_vector(ADDR_L - ROW_L - 1 downto 0) := (others => '0');
	constant col_cmd_zero_padding			: std_logic_vector(MAX_COL_L - COL_L - 1 downto 0) := (others => '0');

	signal ClkEnableN, ClkEnableC			: std_logic;
	signal nChipSelectN, nChipSelectC		: std_logic;
	signal nRowAccessStrobeN, nRowAccessStrobeC	: std_logic;
	signal nColAccessStrobeN, nColAccessStrobeC	: std_logic;
	signal nWriteEnableN, nWriteEnableC		: std_logic;
	signal BankN, BankC				: std_logic_vector(int_to_bit_num(BANK_NUM) - 1 downto 0);
	signal AddressN, AddressC			: std_logic_vector(ADDR_L - 1 downto 0);
	signal ColCmd					: std_logic_vector(ADDR_L - 1 downto 0);
	signal ColExt					: std_logic_vector(MAX_COL_L - 1 downto 0);
	signal ColCmdPrecharge				: std_logic;
	signal RowCmd					: std_logic_vector(ADDR_L - 1 downto 0);

begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then

			ClkEnableC <= '0';
			nChipSelectC <= '0';
			nRowAccessStrobeC <= '0';
			nColAccessStrobeC <= '0';
			nWriteEnableC <= '0';
			BankC <= (others => '0');
			AddressC <= (others => '0');

		elsif ((clk'event) and (clk = '1')) then

			ClkEnableC <= ClkEnableN;
			nChipSelectC <= nChipSelectN;
			nRowAccessStrobeC <= nRowAccessStrobeN;
			nColAccessStrobeC <= nColAccessStrobeN;
			nWriteEnableC <= nWriteEnableN;
			BankC <= BankN;
			AddressC <= AddressN;

		end if;
	end process reg;

	ClkEnable <= ClkEnableC;
	nChipSelect <= nChipSelectC;
	nRowAccessStrobe <= nRowAccessStrobeC;
	nColAccessStrobe <= nColAccessStrobeC;
	nWriteEnable <= nWriteEnableC;
	BankOut <= BankC;
	Address <= AddressC;

	ClkEnableN <= '0' when ((CmdIn = CMD_SELF_REF_ENTRY) or (CmdIn = CMD_POWER_DOWN_ENTRY)) else '1';
	nChipSelectN <= '1' when ((CmdIn = CMD_DESEL) or (CmdIn = CMD_SELF_REF_EXIT) or (CmdIn = CMD_POWER_DOWN_ENTRY) or (CmdIn = CMD_POWER_DOWN_EXIT)) else '0';
	nRowAccessStrobeN <= '1' when ((CmdIn = CMD_WRITE) or (CmdIn = CMD_READ) or (CmdIn = CMD_WRITE_PRECHARGE) or (CmdIn = CMD_READ_PRECHARGE) or (CmdIn = CMD_NOP)) else '0';
	nColAccessStrobeN <= '1' when ((CmdIn = CMD_NOP) or (CmdIn = CMD_BANK_ACT) or (CmdIn = CMD_ALL_BANK_PRECHARGE) or (CmdIn = CMD_BANK_PRECHARGE)) else '0';
	nWriteEnableN <= '1' when ((CmdIn = CMD_NOP) or (CmdIn = CMD_AUTO_REF) or (CmdIn = CMD_SELF_REF_ENTRY) or (CmdIn = CMD_BANK_ACT) or (CmdIn = CMD_READ) or (CmdIn = CMD_READ_PRECHARGE)) else '0';
	BankN <=	(0 => '0', 1 => '1', 2 => '0', others => '0')	when (CmdIn = CMD_EXT_MODE_REG_SET_2) else
			(0 => '1', 1 => '1', 2 => '0', others => '0')	when (CmdIn = CMD_EXT_MODE_REG_SET_3) else
			(0 => '1', 1 => '0', 2 => '0', others => '0')	when (CmdIn = CMD_EXT_MODE_REG_SET_1) else
			(others => '0')					when (CmdIn = CMD_MODE_REG_SET) else
			BankIn;

	AddressN <=	ColCmd		when ((CmdIn = CMD_READ) or (CmdIn = CMD_WRITE) or (CmdIn = CMD_READ_PRECHARGE) or (CmdIn = CMD_WRITE_PRECHARGE)) else
			RowCmd		when (CmdIn = CMD_BANK_ACT) else
			(others => '0')	when (CmdIn = CMD_BANK_PRECHARGE) else
			(others => '1')	when (CmdIn = CMD_ALL_BANK_PRECHARGE) else
			MRSCmd;

	ColCmdPrecharge <= '1' when ((CmdIn = CMD_READ_PRECHARGE) or (CmdIn = CMD_WRITE_PRECHARGE)) else '0';
	ColCmd <= ColExt(MAX_COL_L - 1 downto 10) & ColCmdPrecharge & ColExt(9 downto 0);

	ADDR_L_LARGER_ROW_L : if (ADDR_L > ROW_L) generate
		RowCmd <= row_cmd_zero_padding & RowIn;
	end generate ADDR_L_LARGER_ROW_L;

	ADDR_L_EQUAL_ROW_L : if (ADDR_L = ROW_L) generate
		RowCmd <= RowIn;
	end generate ADDR_L_EQUAL_ROW_L;

	ADDR_L_SMALLER_ROW_L : if (ADDR_L < ROW_L) generate
		RowCmd <= RowIn(ADDR_L - 1 downto 0);
	end generate ADDR_L_SMALLER_ROW_L;

	MAX_COL_L_LARGER_COL_L : if (MAX_COL_L > COL_L) generate
		ColExt <= col_cmd_zero_padding & ColIn;
	end generate MAX_COL_L_LARGER_COL_L;

	MAX_COL_L_EQUAL_COL_L : if (MAX_COL_L = COL_L) generate
		ColExt <= ColIn;
	end generate MAX_COL_L_EQUAL_COL_L;

	MAX_COL_L_SMALLER_COL_L : if (MAX_COL_L < COL_L) generate
		ColExt <= ColIn(MAX_COL_L - 1 downto 0);
	end generate MAX_COL_L_SMALLER_COL_L;

end rtl;
