library work;
library ddr2_ctrl_rtl;

configuration config_ddr2_ctrl_init_top of ddr2_ctrl_init_top is
	for rtl
		for CTRL_TOP_I: ddr2_ctrl_top
			use configuration ddr2_ctrl_rtl.config_ddr2_ctrl_top;
		end for;

		for INIT_I: ddr2_ctrl_init
			use entity ddr2_ctrl_rtl.ddr2_ctrl_init(rtl);
		end for;
	end for;
end config_ddr2_ctrl_init_top;
