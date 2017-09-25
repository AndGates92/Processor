library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.functions_pkg.all;
use work.ddr2_phy_pkg.all;
use work.ddr2_mrs_pkg.all;

package ddr2_phy_cmd_dec_pkg is

	component ddr2_phy_cmd_dec is
	generic (
		BANK_NUM	: positive := 8;
		COL_L		: positive := 10;
		ROW_L		: positive := 13;
		ADDR_L		: positive := 13
	);
	port (
		rst	: in std_logic;
		clk	: in std_logic;

		ColIn	: in std_logic_vector(COL_L - 1 downto 0);
		RowIn	: in std_logic_vector(ROW_L - 1 downto 0);
		BankIn	: in std_logic_vector(int_to_bit_num(BANK_NUM) - 1 downto 0);
		CmdIn	: in std_logic_vector(MEM_CMD_L - 1 downto 0);
		MRSCmd	: in std_logic_vector(ADDR_L - 1 downto 0);

		ClkEnable		: out std_logic;
		nChipSelect		: out std_logic;
		nRowAccessStrobe	: out std_logic;
		nColAccessStrobe	: out std_logic;
		nWriteEnable		: out std_logic;
		BankOut			: out std_logic_vector(int_to_bit_num(BANK_NUM) - 1 downto 0);
		Address			: out std_logic_vector(ADDR_L - 1 downto 0)
	);
	end component;


end package ddr2_phy_cmd_dec_pkg;
