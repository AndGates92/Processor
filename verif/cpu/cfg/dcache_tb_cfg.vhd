library work;
library cpu_rtl;

configuration config_dcache_tb of dcache_tb is
	for bench
		for DUT: dcache
			use configuration cpu_rtl.config_dcache;
		end for;
	end for;
end config_dcache_tb;
