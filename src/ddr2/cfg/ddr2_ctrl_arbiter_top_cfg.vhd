library work;
library ddr2_rtl;

configuration config_ddr2_ctrl_arbiter_top of ddr2_ctrl_arbiter_top is
	for rtl
		for ARB_I: ddr2_ctrl_arbiter
			use entity ddr2_rtl.ddr2_ctrl_arbiter(rtl);
		end for;
		for ARB_CTRL_I: ddr2_ctrl_arbiter_ctrl
			use entity ddr2_rtl.ddr2_ctrl_arbiter_ctrl(rtl);
		end for;
	end for;
end config_ddr2_ctrl_arbiter_top;
