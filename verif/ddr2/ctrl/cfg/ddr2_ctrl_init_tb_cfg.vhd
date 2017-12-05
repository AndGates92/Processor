library work;
library ddr2_rtl;

configuration config_ddr2_ctrl_init_tb of ddr2_ctrl_init_tb is
	for bench
		for DUT: ddr2_ctrl_init
			use entity ddr2_rtl.ddr2_ctrl_init(rtl);
		end for;
	end for;
end config_ddr2_ctrl_init_tb;
