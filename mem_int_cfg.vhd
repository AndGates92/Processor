configuration config_mem_int of mem_int_tb is
	for bench
		for DUT: mem_int 
			use entity work.mem_int(dummy);
		end for;
	end for;
end config_mem_int;
