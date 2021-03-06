library work;
library ddr2_ctrl_rtl;

configuration config_ddr2_ctrl_top of ddr2_ctrl_top is
	for rtl
		for CTRL_CTRL_TOP_I: ddr2_ctrl_ctrl_top
			use configuration ddr2_ctrl_rtl.config_ddr2_ctrl_ctrl_top;
		end for;

		for REGS_I: ddr2_ctrl_regs
			use entity ddr2_ctrl_rtl.ddr2_ctrl_regs(rtl);
		end for;
	end for;
end config_ddr2_ctrl_top;
