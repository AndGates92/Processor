library work;
use work.bram_pkg.all;

configuration config_fifo_1clk of fifo_1clk_tb is
	for bench
		for DUT: fifo_1clk
			use entity work.fifo_1clk(rtl);
			for rtl
				for FIFO_RST_I: bram_rst
					use entity work.bram_rst(rtl_bram_1port);
				end for;
			end for;
		end for;
	end for;
end config_fifo_1clk;
