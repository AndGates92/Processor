library work;
library cpu_rtl;
library common_rtl;

configuration config_execute_dcache of execute_dcache is
	for rtl
		for MUL_I: mul
			use entity cpu_rtl.mul(booth_radix4);
		end for;
		for DIV_I: div
			use entity cpu_rtl.div(non_restoring);
		end for;
		for REG_FILE_I: reg_file
			use entity cpu_rtl.reg_file(rtl);
		end for;
		for CTRL_I: ctrl
			use entity cpu_rtl.ctrl(rtl);
		end for;
		for ALU_I: alu
			use entity cpu_rtl.alu(rtl);
		end for;
		for MEM_INT_I: mem_model
			use entity common_rtl.mem_model(dummy);
		end for;
		for DCACHE_I: dcache
			use configuration cpu_rtl.config_dcache;
		end for;
	end for;
end config_execute_dcache;
