library work;
library cpu_rtl;

configuration config_execute_dcache_tb of execute_dcache_tb is
	for bench
		for DUT: execute_dcache
			use configuration cpu_rtl.config_execute_dcache;
		end for;
	end for;
end config_execute_dcache_tb;
