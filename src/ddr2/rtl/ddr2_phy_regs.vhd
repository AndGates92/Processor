library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ddr2_rtl_pkg;
use ddr2_rtl_pkg.ddr2_phy_pkg.all;
use ddr2_rtl_pkg.ddr2_phy_regs_pkg.all;

entity ddr2_phy_regs is
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
end entity ddr2_phy_regs;

architecture rtl of ddr2_phy_regs is

	type reg_array is array(0 to (REG_NUM - 1)) of std_logic_vector(REG_L - 1 downto 0);
	signal DDR2PhyRegsC, DDR2PhyRegsN	: reg_array;

begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then

			DDR2PhyRegsC <= (others => (others => '0'));

		elsif ((clk'event) and (clk = '1')) then

			DDR2PhyRegsC <= DDR2PhyRegsN;

		end if;
	end process reg;

	-- Store MRS Register value
	-- MRS register:
	-- 12 Power Down Exit Timing (0 Fast, 1 Slow)
	-- 11 down to 9 Write Recovery for Autoprecharge
	-- 8 DLL Reset (0 Disabled, 1 Enabled)
	-- 6 down to 4 CAS Latency
	-- 3 Burst Type (0 Sequential, 1 Interleave)
	-- 2 down to 0 Burst Length (Valid value: 4 and 8)
	DDR2PhyRegsN(0) <= MRSCmd when (Cmd = CMD_MODE_REG_SET) else DDR2PhyRegsC(0);
	-- EMRS1 Register:
	-- 12 Output buffers (0 Disabled, 1 Enabled)
	-- 11 Read Strobes (0 Disabled, 1 Enabled)
	-- 10 Write Strobes (0 Disabled, 1 Enabled)
	-- 6 & 2 ODT (0 Disabled, 1 75 Ohm, 2 150 Ohm, 3 50 Ohm)
	-- 5 down to 3 Additive Latency
	-- 1 Driver Strength Control (0 Weak, 1 Normal)
	-- 0 DLL Enable (0 Disabled, 1 Enabled)
	DDR2PhyRegsN(1) <= (MRSCmd(REG_L - 1 downto 13) & (not MRSCmd(12)) & MRSCmd(11) & (not MRSCmd(10)) & MRSCmd(9 downto 2) & (not MRSCmd(1 downto 0))) when (Cmd = CMD_EXT_MODE_REG_SET_1) else DDR2PhyRegsC(1);
	-- EMRS2 Register:
	-- 7 High Temperature Self Refresh Rate (0 Disabled, 1 Enabled)
	DDR2PhyRegsN(2) <= MRSCmd when (Cmd = CMD_EXT_MODE_REG_SET_2) else DDR2PhyRegsC(2);
	DDR2PhyRegsN(3) <= MRSCmd when (Cmd = CMD_EXT_MODE_REG_SET_3) else DDR2PhyRegsC(3);

	-- MRS Breakdown
	DDR2BurstLength <= DDR2PhyRegsC(0)(2 downto 0);
	DDR2BurstType <= DDR2PhyRegsC(0)(3);
	DDR2CASLatency <= DDR2PhyRegsC(0)(6 downto 4);
	DDR2DLLReset <= DDR2PhyRegsC(0)(8);
	DDR2WriteRecovery <= DDR2PhyRegsC(0)(11 downto 9);
	DDR2PowerDownExitMode <= DDR2PhyRegsC(0)(12);

	-- EMRS1 Breakdown
	DDR2DLLEnable <= DDR2PhyRegsC(1)(0);
	DDR2DrivingStrength <= DDR2PhyRegsC(1)(1);
	DDR2ODT <= DDR2PhyRegsC(1)(6) & DDR2PhyRegsC(1)(2);
	DDR2AdditiveLatency <= DDR2PhyRegsC(1)(5 downto 3);
	DDR2DataStrobesEnable <= DDR2PhyRegsC(1)(10);
	DDR2ReadDataStrobesEnable <= DDR2PhyRegsC(1)(11);
	DDR2OutBufferEnable <= DDR2PhyRegsC(1)(12);

	-- EMRS2 Breakdown
	DDR2HighTemperature <= DDR2PhyRegsC(2)(7);

end rtl;
