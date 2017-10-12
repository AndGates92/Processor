library work;
library cpu_rtl;

configuration config_reg_file_tb of reg_file_tb is
	for bench
		for DUT: reg_file
			use entity cpu_rtl.reg_file(rtl);
		end for;
	end for;
end config_reg_file_tb;
