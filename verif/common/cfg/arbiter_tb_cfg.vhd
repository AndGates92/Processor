library work;
library common_rtl;

configuration config_arbiter_tb of arbiter_tb is
	for bench
		for DUT: arbiter
			use entity common_rtl.arbiter(rtl);
		end for;
	end for;
end config_arbiter_tb;
