library work;
library ddr2_rtl;

configuration config_ddr2_ctrl_cmd_ctrl of ddr2_ctrl_cmd_ctrl is
	for rtl
		for col_ctrl_loop
			for COL_CTRL_I: ddr2_ctrl_col_ctrl
				use entity ddr2_rtl.ddr2_ctrl_col_ctrl(rtl);
			end for;
		end for;
		for bank_ctrl_loop
			for BANK_CTRL_I: ddr2_ctrl_bank_ctrl
				use entity ddr2_rtl.ddr2_ctrl_bank_ctrl(rtl);
			end for;
		end for;
	end for;
end config_ddr2_ctrl_cmd_ctrl;
