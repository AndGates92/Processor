library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;
use work.ddr2_phy_pkg.all;
use work.ddr2_mrs_max_pkg.all;
use work.ddr2_phy_regs_pkg.all;
use work.ddr2_log_pkg.all;

entity ddr2_phy_regs_tb is
end entity ddr2_phy_regs_tb;

architecture bench of ddr2_phy_regs_tb is

	constant CLK_PERIOD	: time := DDR2_CLK_PERIOD * 1 ns;
	constant NUM_TESTS	: integer := 1000;
	constant TOT_NUM_TESTS	: integer := NUM_TESTS;

	constant MAX_REQUESTS_PER_TEST		: integer := 500;

	constant REG_NUM_TB	: positive := 4;
	constant REG_L_TB	: positive := 14;

	signal clk_tb	: std_logic := '0';
	signal stop	: boolean := false;
	signal rst_tb	: std_logic;

	-- Command Decoder
	signal MRSCmd_tb	: out std_logic_vector(REG_L - 1 downto 0);
	signal Cmd_tb		: out std_logic_vector(MEM_CMD_L - 1 downto 0);

	-- Register Values
	signal DDR2ODT_tb			: std_logic_vector(1 downto 0);
	signal DDR2DataStrobesEnable_tb		: std_logic;
	signal DDR2ReadDataStrobesEnable_tb	: std_logic;
	signal DDR2HighTemperature_tb		: std_logic;
	signal DDR2DLLReset_tb			: std_logic;
	signal DDR2CASLatency_tb		: std_logic_vector(2 downto 0);
	signal DDR2BurstType_tb			: std_logic;
	signal DDR2BurstLength_tb		: std_logic_vector(2 downto 0);
	signal DR2PowerDownExitMode_tb		: std_logic;
	signal DDR2AdditiveLatency_tb		: std_logic_vector(2 downto 0);
	signal DDR2OutBufferEnable_tb		: std_logic;
	signal DDR2DLLEnable_tb			: std_logic;
	signal DDR2DrivingStrength_tb		: std_logic;
	signal DDR2WriteRecovery_tb		: std_logic_vector(2 downto 0);

begin

	DUT: ddr2_phy_regs generic map (
		REG_NUM => REG_NUM_TB,
		REG_L => REG_L_TB
	)
	port map (
		clk => clk_tb,
		rst => rst_tb,

	-- Command Decoder
		MRSCmd => MRSCmd_tb,
		Cmd => Cmd_tb,

	-- Register Values
		DDR2ODT => DDR2ODT_tb,
		DDR2DataStrobesEnable => DDR2DataStrobesEnable_tb,
		DDR2ReadDataStrobesEnable => DDR2ReadDataStrobesEnable_tb,
		DDR2HighTemperature => DDR2HighTemperature_tb,
		DDR2DLLReset => DDR2DLLReset_tb,
		DDR2CASLatency => DDR2CASLatency_tb,
		DDR2BurstType => DDR2BurstType_tb,
		DDR2BurstLength => DDR2BurstLength_tb,
		DR2PowerDownExitMode => DR2PowerDownExitMode_tb,
		DDR2AdditiveLatency => DDR2AdditiveLatency_tb,
		DDR2OutBufferEnable => DDR2OutBufferEnable_tb,
		DDR2DLLEnable => DDR2DLLEnable_tb,
		DDR2DrivingStrength => DDR2DrivingStrength_tb,
		DDR2WriteRecovery => DDR2WriteRecovery_tb

	);

	clk_gen(CLK_PERIOD, 0 ns, stop, clk_tb);

	test: process

		procedure reset is
		begin
			MRSCmd_tb <= (others => '0');
			Cmd_tb <= (others => '0');

			rst_tb <= '0';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_tb <= '1';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_tb <= '0';
		end procedure reset;

		procedure test_param(variable num_requests : out integer; variable cmd, odt, cas_latency, additive_latency, write_recovery : out int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable bl4, data_strb, rd_data_strb, high_temp, dll_rst, burst_type, power_down_exit, out_buffer_en, dll_enable, driving_strength : out bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable seed1, seed2: inout positive) is
			variable rand_val		: real;
			variable num_requests_int	: integer;

			variable cmd_int		: integer;

		begin

			num_requests_int := 0;
			while (num_requests_int = 0) loop
				uniform(seed1, seed2, rand_val);
				num_requests_int := integer(rand_val*real(MAX_REQUESTS_PER_TEST));
			end loop;
			num_requests := num_requests_int;

			for i in 0 to (num_requests_int - 1) loop
				uniform(seed1, seed2, rand_val);
				cmd_int := round(rand_val*real(REG_NUM_TB));
				if (cmd_int == 0) then
					cmd(i) = to_integer(unsigned(CMD_MODE_REG_SET));
				elsif (cmd_int == 1) then
					cmd(i) = to_integer(unsigned(CMD_EXT_MODE_REG_SET_1));
				elsif (cmd_int == 2) then
					cmd(i) = to_integer(unsigned(CMD_EXT_MODE_REG_SET_2));
				elsif (cmd_int == 3) then
					cmd(i) = to_integer(unsigned(CMD_EXT_MODE_REG_SET_3));
				else
					uniform(seed1, seed2, rand_val);
					cmd(i) := integer(rand_val*real(2.0**(real(MEM_CMD_L))));
				end if;
				uniform(seed1, seed2, rand_val);
				odt := round(rand_val*real(ODT_MAX_VALUE));
				uniform(seed1, seed2, rand_val);
				cas_latency := round(rand_val*real(CAS_LATENCY_MAX_VALUE));
				uniform(seed1, seed2, rand_val);
				additive_latency := round(rand_val*real(ADDITIVE_LATENCY_MAX_VALUE));
				uniform(seed1, seed2, rand_val);
				write_recovery := round(rand_val*real(WRITE_REC_MAX_VALUE));
				uniform(seed1, seed2, rand_val);
				bl4 := rand_bool(rand_val, 0.5);
				uniform(seed1, seed2, rand_val);
				data_strb := rand_bool(rand_val, 0.5);
				uniform(seed1, seed2, rand_val);
				rd_data_strb := rand_bool(rand_val, 0.5);
				uniform(seed1, seed2, rand_val);
				high_temp := rand_bool(rand_val, 0.5);
				uniform(seed1, seed2, rand_val);
				dll_rst := rand_bool(rand_val, 0.5);
				uniform(seed1, seed2, rand_val);
				burst_type := rand_bool(rand_val, 0.5);
				uniform(seed1, seed2, rand_val);
				power_down_exit := rand_bool(rand_val, 0.5);
				uniform(seed1, seed2, rand_val);
				out_buffer_en := rand_bool(rand_val, 0.5);
				uniform(seed1, seed2, rand_val);
				dll_enable := rand_bool(rand_val, 0.5);
				uniform(seed1, seed2, rand_val);
				driving_strength := rand_bool(rand_val, 0.5);

			end loop;

		end procedure test_param;


