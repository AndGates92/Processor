library work;
library ddr2_ctrl_rtl;

configuration config_ddr2_ctrl_ref_ctrl_tb of ddr2_ctrl_ref_ctrl_tb is
	for bench
		for DUT: ddr2_ctrl_ref_ctrl
			use entity ddr2_ctrl_rtl.ddr2_ctrl_ref_ctrl(rtl);
		end for;
	end for;
end config_ddr2_ctrl_ref_ctrl_tb;
