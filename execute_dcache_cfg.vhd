library work;
use work.bram_pkg.all;
use work.mem_int_pkg.all;
use work.dcache_pkg.all;

configuration config_execute_dcache of execute_dcache_tb is
	for bench
		for DUT: execute_dcache
			use entity work.execute_dcache(rtl);
			for rtl 
				for MUL_I: mul
					use entity work.mul(booth_radix4);
				end for;
				for MEM_INT_I: mem_int
					use entity work.mem_int(dummy);
				end for;
				for DCACHE_I: dcache
					use entity work.dcache(rtl_bram_1port);
		--			for rtl_bram_2port
		--				for BRAM_2PORT_RST_I: bram_rst
		--					use entity work.bram_rst(rtl_bram_2port);
		--				end for;
		--			end for;
					for rtl_bram_1port
						for BRAM_1PORT_RST_I: bram_rst
							use entity work.bram_rst(rtl_bram_1port);
						end for;
					end for;
				end for;
			end for;
		end for;
	end for;
end config_execute_dcache;
