library work;
library ddr2_ctrl_rtl;

configuration config_ddr2_ctrl_init_top_tb of ddr2_ctrl_init_top_tb is
	for bench
		for DUT: ddr2_ctrl_init_top
			use entity ddr2_ctrl_rtl.ddr2_ctrl_init_top(rtl);
		end for;
	end for;
end config_ddr2_ctrl_init_top_tb;
