configuration config_icache of icache_tb is
	for bench
		for DUT: icache
			use entity work.icache(rtl_bram_2port);
		end for;
	end for;
end config_icache;
