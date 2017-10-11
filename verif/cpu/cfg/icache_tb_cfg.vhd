library work;
library cpu_rtl;

configuration config_icache_tb of icache_tb is
	for bench
		for DUT: icache
			use configuration cpu_rtl.config_icache;
		end for;
	end for;
end config_icache_tb;
