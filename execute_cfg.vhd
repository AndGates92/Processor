configuration config_mul of execute_stage is
	for rtl
		for MUL_I: mul 
			use entity work.mul(booth_radix4);
		end for;
	end for;
end config_mul;
