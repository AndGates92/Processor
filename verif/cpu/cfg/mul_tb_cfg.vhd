library work;
library cpu_rtl;

configuration config_mul_tb of mul_tb is
	for bench
		for DUT: mul
			use entity cpu_rtl.mul(booth_radix2);
		end for;
	end for;
end config_mul_tb;
