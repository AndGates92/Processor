configuration config_bram_2port_rst of icache is
	for rtl_bram_2port
		for BRAM_2PORT_RST_I: bram_rst
			use entity work.bram_rst(rtl_bram_2port);
		end for;
	end for;
end config_bram_2port_rst;
