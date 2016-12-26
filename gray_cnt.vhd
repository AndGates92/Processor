library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.fifo_2clk_pkg.all;

entity gray_cnt is
generic (
	DATA_L		: positive := 32;
	BIN_RST_VAL	: natural := 0
);
port (
	rst		: in std_logic;
	sync_rst	: in std_logic;
	clk		: in std_logic;

	gray_cnt_out	: out std_logic_vector(DATA_L - 1 downto 0);

	bin_rst_flag	: out std_logic

);
end entity gray_cnt;

architecture rtl of gray_cnt is

	constant GRAY_RST_VAL : positive := bin_to_gray((BIN_RST_VAL+1), DATA_L);

	signal bin_cnt, bin_cnt_next : unsigned(DATA_L - 1 downto 0);
	signal gray_cnt, gray_cnt_next : unsigned(DATA_L - 1 downto 0);

begin

	-- Register
	reg: process(rst, clk)
	begin
		if (rst = '1') then
			bin_cnt <= to_unsigned(BIN_RST_VAL, DATA_L);
			gray_cnt <= to_unsigned(GRAY_RST_VAL, DATA_L);
		elsif ((clk'event) and (clk = '1')) then
			if (sync_rst = '1') then
				bin_cnt <= to_unsigned(BIN_RST_VAL, DATA_L);
				gray_cnt <= to_unsigned(GRAY_RST_VAL, DATA_L);
			else
				bin_cnt <= bin_cnt_next;
				gray_cnt <= gray_cnt_next;
			end if;
		end if;
	end process reg;

	bin_cnt_next <= bin_cnt + 1;

	bin_to_gray_gen: for i in 0 to DATA_L generate
		LAST_BIT : if (i = (DATA_L - 1)) generate
			gray_cnt_next(i) <= bin_cnt(DATA_L-1);
		end generate LAST_BIT;

		OTHER_BITS : if (i /= (DATA_L - 1)) generate
			gray_cnt_next(i) <= bin_cnt(i) xor bin_cnt(i+1);
		end generate OTHER_BITS;
	end generate bin_to_gray_gen;

	gray_cnt_out <= std_logic_vector(gray_cnt);
	bin_rst_flag <= '1' when (bin_cnt = BIN_RST_VAL) else '0';

end rtl;
