library work;
library common_rtl;

configuration config_dcache of dcache is
--	for rtl_bram_2port
--		for BRAM_2PORT_RST_I: bram_rst
--			use entity work.bram_rst(rtl_bram_2port);
--		end for;
--	end for;
	for rtl_bram_1port
		for BRAM_1PORT_RST_I: bram_rst
			use entity common_rtl.bram_rst(rtl_bram_1port);
		end for;
		for BRAM_1PORT_I: bram_1port
			use entity common_rtl.bram_1port(rtl);
		end for;
	end for;
end config_dcache;
