use work.mem_model_pkg.all;

configuration config_execute of execute_tb is
	for bench
		for DUT: execute_stage
			use entity work.execute_stage(rtl);
			for rtl 
				for MUL_I: mul
					use entity work.mul(booth_radix4);
				end for;
				for MEM_INT_I: mem_model
					use entity work.mem_model(dummy);
				end for;
			end for;
		end for;
	end for;
end config_execute;