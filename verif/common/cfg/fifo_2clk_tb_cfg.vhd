library work;
library common_rtl;
library common_rtl_pkg;
use common_rtl_pkg.fifo_2clk_pkg.all;

configuration config_fifo_2clk_tb of fifo_2clk_tb is
	for bench
		for DUT: fifo_2clk
			use configuration common_rtl.config_fifo_2clk;
		end for;
	end for;
end config_fifo_2clk_tb;
