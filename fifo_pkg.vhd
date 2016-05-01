library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;

package fifo_pkg is 

	component fifo
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

end package fifo_pkg;
