library work;
library ddr2_rtl;

configuration config_ddr2_phy_cmd_ctrl_tb of ddr2_phy_cmd_ctrl_tb is
	for bench
		for DUT: ddr2_phy_cmd_ctrl
			use configuration ddr2_rtl.config_ddr2_phy_cmd_ctrl;
		end for;
	end for;
end config_ddr2_phy_cmd_ctrl_tb;
