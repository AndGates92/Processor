library work;
use work.bram_pkg.all;

configuration config_fifo_2clk of fifo_2clk_tb is
	for bench
		for DUT: fifo_2clk
			use entity work.fifo_2clk(rtl);
			for rtl
				for FIFO_RST_I: bram_rst
					use entity work.bram_rst(rtl_bram_1port);
				end for;
			end for;
		end for;
	end for;
end config_fifo_2clk;
