library work;
library cpu_rtl;

configuration config_ctrl_tb of ctrl_tb is
	for bench
		for DUT: ctrl
			use entity cpu_rtl.ctrl(rtl);
		end for;
	end for;
end config_ctrl_tb;
