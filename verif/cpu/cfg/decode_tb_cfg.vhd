library work;
library cpu_rtl;

configuration config_decode_tb of decode_tb is
	for bench
		for DUT: decode
			use entity cpu_rtl.decode(rtl);
		end for;
	end for;
end config_decode_tb;
