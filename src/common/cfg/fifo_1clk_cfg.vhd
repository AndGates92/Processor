library work;
library common_rtl;

configuration config_fifo_1clk of fifo_1clk is
	for rtl
		for FIFO_RST_I: bram_rst
			use entity common_rtl.bram_rst(rtl_bram_1port);
		end for;
		for FIFO_2PORT_I: bram_2port
			use entity common_rtl.bram_2port(rtl);
		end for;
	end for;
end config_fifo_1clk;
