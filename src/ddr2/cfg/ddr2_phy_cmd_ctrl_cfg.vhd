library work;
library ddr2_rtl;

configuration config_ddr2_phy_cmd_ctrl of ddr2_phy_cmd_ctrl is
	for rtl
		for COL_CTRL_I: col_ctrl
			use entity ddr2_rtl.ddr2_phy_col_ctrl(rtl);
		end for;
		for BANK_CTRL_I: bank_ctrl
			use entity ddr2_rtl.ddr2_phy_bank_ctrl(rtl);
		end for;
	end for;
end config_ddr2_phy_cmd_ctrl;
