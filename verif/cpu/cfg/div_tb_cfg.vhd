library work;
library cpu_rtl;

configuration config_div_tb of div_tb is
	for bench
		for DUT: div 
			use entity cpu_rtl.div(non_restoring);
		end for;
	end for;
end config_div_tb;
