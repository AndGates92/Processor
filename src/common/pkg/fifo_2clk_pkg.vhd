library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package fifo_2clk_pkg is 

	component fifo_2clk
	generic (
		DATA_L		: positive := 32;
		FIFO_SIZE	: positive := 16
	);
	port (
		rst_rd		: in std_logic;
		clk_rd		: in std_logic;
		DataOut		: out std_logic_vector(DATA_L - 1 downto 0);
		En_rd		: in std_logic;
		empty		: out std_logic;
		rst_wr		: in std_logic;
		clk_wr		: in std_logic;
		DataIn		: in std_logic_vector(DATA_L - 1 downto 0);
		En_wr		: in std_logic;
		full		: out std_logic;
		ValidOut	: out std_logic;
		EndRst		: out std_logic

	);
	end component;

	component gray_cnt
	generic (
		DATA_L		: positive := 32;
		BIN_RST_VAL	: natural := 0
	);
	port (
		rst		: in std_logic;
		sync_rst	: in std_logic;
		clk		: in std_logic;

		En		: in std_logic;

		gray_cnt_out	: out std_logic_vector(DATA_L - 1 downto 0);

		bin_rst_flag	: out std_logic

	);
	end component;

	component fifo_ctrl
	generic (
		RST_VAL		: natural := 0;
		ADDR_L		: positive := 16
	);
	port (
		rst	: in std_logic;
		clk	: in std_logic;
		Ptr	: in std_logic_vector(ADDR_L - 1 downto 0);
		PtrP1	: in std_logic_vector(ADDR_L - 1 downto 0);
		Ptr2	: in std_logic_vector(ADDR_L - 1 downto 0);
		En	: in std_logic;
		flag	: out std_logic;
		nflag	: out std_logic

	);
	end component;

	constant NUM_STAGES	: positive := 2;

	function bin_to_gray (bin_rst : natural; addr_l : positive) return natural;

end package fifo_2clk_pkg;

package body fifo_2clk_pkg is

	function bin_to_gray (bin_rst : natural; addr_l : positive) return natural is
		variable gray_rst : natural;
	begin
		gray_rst := natural(to_integer(to_unsigned(bin_rst, addr_l) xor to_unsigned((bin_rst/2), addr_l)));
		return gray_rst;
	end bin_to_gray;

end package body fifo_2clk_pkg;
