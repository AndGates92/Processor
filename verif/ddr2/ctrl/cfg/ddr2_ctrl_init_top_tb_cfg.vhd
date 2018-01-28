library work;
library ddr2_ctrl_rtl;

configuration config_ddr2_ctrl_init_top_tb of ddr2_ctrl_init_top_tb is
	for bench
		for DUT: ddr2_ctrl_init_top
			use configuration ddr2_ctrl_rtl.config_ddr2_ctrl_init_top;
		end for;
	end for;
end config_ddr2_ctrl_init_top_tb;
