library work;
library ddr2_rtl;

configuration config_ddr2_phy_regs_tb of ddr2_phy_regs_tb is
	for bench
		for DUT: ddr2_phy_regs
			use entity ddr2_rtl.ddr2_phy_regs(rtl);
		end for;
	end for;
end config_ddr2_phy_regs_tb;
