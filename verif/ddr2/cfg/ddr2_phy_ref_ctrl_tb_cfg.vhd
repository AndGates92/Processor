library work;
library ddr2_rtl;

configuration config_ddr2_phy_ref_ctrl_tb of ddr2_phy_ref_ctrl_tb is
	for bench
		for DUT: ddr2_phy_ref_ctrl
			use entity ddr2_rtl.ddr2_phy_ref_ctrl(rtl);
		end for;
	end for;
end config_ddr2_phy_ref_ctrl_tb;
