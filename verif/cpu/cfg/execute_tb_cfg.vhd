library work;
library cpu_rtl;

configuration config_execute_tb of execute_tb is
	for bench
		for DUT: execute_stage
			use configuration cpu_rtl.config_execute;
		end for;
	end for;
end config_execute_tb;
