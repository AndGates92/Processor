configuration config_mem_int of execute_stage is
	for rtl
		for MEM_INT_I: mem_int 
			use entity work.mem_int(dummy);
		end for;
	end for;
end config_mem_int;
