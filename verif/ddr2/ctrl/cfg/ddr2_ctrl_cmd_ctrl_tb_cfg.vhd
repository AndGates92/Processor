library work;
library ddr2_ctrl_rtl;

configuration config_ddr2_ctrl_cmd_ctrl_tb of ddr2_ctrl_cmd_ctrl_tb is
	for bench
		for DUT: ddr2_ctrl_cmd_ctrl
			use configuration ddr2_ctrl_rtl.config_ddr2_ctrl_cmd_ctrl;
		end for;
	end for;
end config_ddr2_ctrl_cmd_ctrl_tb;
