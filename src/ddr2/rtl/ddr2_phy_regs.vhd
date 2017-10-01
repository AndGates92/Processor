library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.functions_pkg.all;
use work.ddr2_phy_pkg.all;
use work.ddr2_phy_arbiter_pkg.all;

entity ddr2_phy_regs is
generic (
	REG_NUM		: positive := 4;
	REG_L		: positive := 14

);
port (

	rst		: in std_logic;
	clk		: in std_logic;

	-- Command Decoder
	MRSCmd		: out std_logic_vector(REG_L - 1 downto 0);
	Cmd		: out std_logic_vector(MEM_CMD_L - 1 downto 0);

	-- Register Values
	DDR2ODT				: out std_logic_vector(1 downto 0);
	DDR2DataStrobesEnable		: out std_logic;
	DDR2ReadDataStrobesEnable	: out std_logic;
	DDR2HighTemperature		: out std_logic;
	DDR2CAS				: out std_logic_vector(2 downto 0);
	DDR2BurstType			: out std_logic;
	DDR2BurstLength			: out std_logic_vector(2 downto 0);
	DDR2PowerDownExitMode		: out std_logic;
	DDR2AdditiveLatency		: out std_logic_vector(2 downto 0);
	DDR2OutBufferEnable		: out std_logic;
	DDR2DLLEnable			: out std_logic;
	DDR2DrivingStrength		: out std_logic;
	DDR2WriteRecoery		: out std_logic_vector(2 downto 0)
);
end entity ddr2_phy_regs;

architecture rtl of ddr2_phy_init is

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
	DDR2PhyRegsN(0) <= MRSCmd when (Cmd = CMD_MODE_REG_SET) else DDR2PhyRegsC(0);
	DDR2PhyRegsN(1) <= MRSCmd when (Cmd = CMD_EXT_MODE_REG_SET_1) else DDR2PhyRegsC(1);
	DDR2PhyRegsN(2) <= MRSCmd when (Cmd = CMD_EXT_MODE_REG_SET_2) else DDR2PhyRegsC(2);
	DDR2PhyRegsN(3) <= MRSCmd when (Cmd = CMD_EXT_MODE_REG_SET_3) else DDR2PhyRegsC(3);

	DDR2OutBufferEnable <= DDR2PhyRegs(1)(12);
	DDR2HighTemperature <= DDR2PhyRegs(2)(7);
