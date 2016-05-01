library work;
use work.bram_pkg.all;

configuration config_fifo of fifo_tb is
	for bench
		for DUT: fifo
			use entity work.fifo(rtl);
			for rtl
				for FIFO_RST_I: bram_rst
					use entity work.bram_rst(rtl_bram_1port);
				end for;
			end for;
		end for;
	end for;
end config_fifo;
