library work;
library cpu_rtl;

configuration config_alu_tb of alu_tb is
	for bench
		for DUT: alu
			use entity cpu_rtl.alu(rtl);
		end for;
	end for;
end config_alu_tb;
