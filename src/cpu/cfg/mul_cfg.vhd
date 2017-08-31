configuration config_mul of mul_tb is
	for bench
		for DUT: mul
			use entity work.mul(booth_radix2);
		end for;
	end for;
end config_mul;
