library cpu_rtl;
library common_rtl;

configuration config_execute of execute is
	for rtl
		for MUL_I: mul
			use entity cpu_rtl.mul(booth_radix4);
		end for;
		for MEM_INT_I: mem_model
			use entity common_rtl.mem_model(dummy);
		end for;
	end for;
end config_execute;
