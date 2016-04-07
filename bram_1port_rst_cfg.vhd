configuration config_bram_1port_rst of icache is
	for rtl_bram_1port
		for BRAM_1PORT_RST_I: bram_rst
			use entity work.bram_rst(rtl_bram_1port);
		end for;
	end for;
end config_bram_1port_rst;
