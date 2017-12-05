library work;
library ddr2_ctrl_rtl;

configuration config_ddr2_ctrl_ctrl_top of ddr2_ctrl_ctrl_top is
	for rtl
		for REF_CTRL_I: ddr2_ctrl_ref_ctrl
			use entity ddr2_ctrl_rtl.ddr2_ctrl_ref_ctrl(rtl);
		end for;

		for ODT_CTRL_I: ddr2_ctrl_odt_ctrl
			use entity ddr2_ctrl_rtl.ddr2_ctrl_odt_ctrl(rtl);
		end for;

		for MRS_CTRL_I: ddr2_ctrl_mrs_ctrl
			use entity ddr2_ctrl_rtl.ddr2_ctrl_mrs_ctrl(rtl);
		end for;

		for CMD_CTRL_I: ddr2_ctrl_cmd_ctrl
			use configuration ddr2_ctrl_rtl.config_ddr2_ctrl_cmd_ctrl;
		end for;

		for ARB_I: ddr2_ctrl_arbiter_top
			use configuration ddr2_ctrl_rtl.config_ddr2_ctrl_arbiter_top;
		end for;
	end for;
end config_ddr2_ctrl_ctrl_top;
