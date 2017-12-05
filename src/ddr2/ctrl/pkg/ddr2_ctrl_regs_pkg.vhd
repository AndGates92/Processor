library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ddr2_ctrl_rtl_pkg;
use ddr2_ctrl_rtl_pkg.ddr2_ctrl_pkg.all;

package ddr2_ctrl_regs_pkg is 

	component ddr2_ctrl_regs is
	generic (
		REG_NUM		: positive := 4;
		REG_L		: positive := 14

	);
	port (

		rst		: in std_logic;
		clk		: in std_logic;

		-- Command Decoder
		MRSCmd		: in std_logic_vector(REG_L - 1 downto 0);
		Cmd		: in std_logic_vector(MEM_CMD_L - 1 downto 0);

		-- Register Values
		DDR2ODT				: out std_logic_vector(1 downto 0);
		DDR2DataStrobesEnable		: out std_logic;
		DDR2ReadDataStrobesEnable	: out std_logic;
		DDR2HighTemperature		: out std_logic;
		DDR2DLLReset			: out std_logic;
		DDR2CASLatency			: out std_logic_vector(2 downto 0);
		DDR2BurstType			: out std_logic;
		DDR2BurstLength			: out std_logic_vector(2 downto 0);
		DDR2PowerDownExitMode		: out std_logic;
		DDR2AdditiveLatency		: out std_logic_vector(2 downto 0);
		DDR2OutBufferEnable		: out std_logic;
		DDR2DLLEnable			: out std_logic;
		DDR2DrivingStrength		: out std_logic;
		DDR2WriteRecovery		: out std_logic_vector(2 downto 0)
	);
	end component;

end package ddr2_ctrl_regs_pkg;
