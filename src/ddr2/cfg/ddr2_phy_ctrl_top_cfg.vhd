library work;
library ddr2_rtl;

configuration config_ddr2_phy_ctrl_top of ddr2_phy_ctrl_top is
	for rtl
		for REF_CTRL_I: ddr2_phy_ref_ctrl
			use entity ddr2_rtl.ddr2_phy_ref_ctrl(rtl);
		end for;

		for ODT_CTRL_I: ddr2_phy_odt_ctrl
			use entity ddr2_rtl.ddr2_phy_odt_ctrl(rtl);
		end for;

		for MRS_CTRL_I: ddr2_phy_mrs_ctrl
			use entity ddr2_rtl.ddr2_phy_mrs_ctrl(rtl);
		end for;

		for CMD_CTRL_I: ddr2_phy_cmd_ctrl
			use configuration config_ddr2_phy_cmd_ctrl;
		end for;

		for ARBL_I: ddr2_phy_arbiter_top
			use configuration config_ddr2_phy_arbiter_top;
		end for;
	end for;
end config_ddr2_phy_ctrl_top;
