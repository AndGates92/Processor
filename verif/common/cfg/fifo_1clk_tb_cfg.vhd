library work;
library common_rtl;

configuration config_fifo_1clk_tb of fifo_1clk_tb is
	for bench
		for DUT: fifo_1clk
			use configuration common_rtl.config_fifo_1clk;
		end for;
	end for;
end config_fifo_1clk_tb;
