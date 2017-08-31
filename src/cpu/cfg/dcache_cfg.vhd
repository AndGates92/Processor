library work;
use work.bram_pkg.all;

configuration config_dcache of dcache_tb is
	for bench
		for DUT: dcache
			use entity work.dcache(rtl_bram_1port);
--			for rtl_bram_2port
--				for BRAM_2PORT_RST_I: bram_rst
--					use entity work.bram_rst(rtl_bram_2port);
--				end for;
--			end for;
			for rtl_bram_1port
				for BRAM_1PORT_RST_I: bram_rst
					use entity work.bram_rst(rtl_bram_1port);
				end for;
			end for;
		end for;
	end for;
end config_dcache;
