configuration config_div of div_tb is
	for bench
		for DUT: div 
			use entity work.div(non_restoring);
		end for;
	end for;
end config_div;
