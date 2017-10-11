library work;
library cpu_rtl;
library common_rtl;

configuration config_execute_dcache of execute_dcache is
	for rtl
		for MUL_I: mul
			use entity cpu_rtl.mul(booth_radix4);
		end for;
		for MEM_INT_I: mem_model
			use entity common_rtl.mem_model(dummy);
		end for;
		for DCACHE_I: dcache
			use configuration cpu_rtl.config_dcache;
		end for;
	end for;
end config_execute_dcache;
