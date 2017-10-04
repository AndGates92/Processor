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

		procedure test_param(variable num_cmd : out integer; variable cmd, odt, cas_latency, additive_latency, write_recovery : out int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable bl4, data_strb, rd_data_strb, high_temp, dll_rst, burst_type, power_down_exit, out_buffer_en, dll_enable, driving_strength : out bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable seed1, seed2: inout positive) is
			variable rand_val		: real;
			variable num_cmd_int	: integer;

			variable cmd_int		: integer;

		begin

			num_cmd_int := 0;
			while (num_cmd_int = 0) loop
				uniform(seed1, seed2, rand_val);
				num_cmd_int := integer(rand_val*real(MAX_REQUESTS_PER_TEST));
			end loop;
			num_cmd := num_cmd_int;

			for i in 0 to (num_cmd_int - 1) loop
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

		procedure run_phy_regs(variable num_cmd_exp : in integer; variable cmd_arr, odt_arr, cas_latency_arr, additive_latency_arr, write_recovery_arr : in int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable bl4_arr, data_strb_arr, rd_data_strb_arr, high_temp_arr, dll_rst_arr, burst_type_arr, power_down_exit_arr, out_buffer_en_arr, dll_enable_arr, driving_strength_arr : in bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable num_cmd_rtl : out integer; variable cmd_arr_exp, odt_arr_exp, cas_latency_arr_exp, additive_latency_arr_exp, write_recovery_arr_exp : out int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable bl4_arr_exp, data_strb_arr_exp, rd_data_strb_arr_exp, high_temp_arr_exp, dll_rst_arr_exp, burst_type_arr_exp, power_down_exit_arr_exp, out_buffer_en_arr_exp, dll_enable_arr_exp, driving_strength_arr_exp : out bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable cmd_arr_rtl, odt_arr_rtl, cas_latency_arr_rtl, additive_latency_arr_rtl, write_recovery_arr_rtl : out int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable bl4_arr_rtl, data_strb_arr_rtl, rd_data_strb_arr_rtl, high_temp_arr_rtl, dll_rst_arr_rtl, burst_type_arr_rtl, power_down_exit_arr_rtl, out_buffer_en_arr_rtl, dll_enable_arr_rtl, driving_strength_arr_rtl : out bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1))) is

			variable num_cmd_sent_rtl_int	: integer;
			variable num_cmd_stored_rtl_int	: integer;

			variable cmd_int		: integer;
			variable odt_int		: integer;
			variable cas_latency_int	: integer;
			variable additive_latency_int	: integer;
			variable write_recovery_int	: integer;

			variable bl4_int		: boolean;
			variable data_strb_int		: boolean;
			variable rd_data_strb_int	: boolean;
			variable high_temp_int		: boolean;
			variable dll_rst_int		: boolean;
			variable burst_type_int		: boolean;
			variable power_down_exit_int	: boolean;
			variable out_buffer_en_int	: boolean;
			variable dll_enable_int		: boolean;
			variable driving_strength_int	: boolean;

			variable cmd_sent	: boolean;

			variable vec1	: std_logic_vector(2 downto 0);
			variable vec2	: std_logic_vector(2 downto 0);
			variable vec3	: std_logic_vector(2 downto 0);

		begin

			num_cmd_sent_rtl_int := 0;
			num_cmd_stored_rtl_int := 0;

			cmd_int := 0;
			odt_int := 0;
			cas_latency_int := 0;
			additive_latency_int := 0;
			write_recovery_int := 0;

			bl4_int := false;
			data_strb_int := false;
			rd_data_strb_int := false;
			high_temp_int := false;
			dll_rst_int := false;
			burst_type_int := false;
			power_down_exit_int := false;
			out_buffer_en_int := false;
			dll_enable_int := false;
			driving_strength_int := false;

			cmd_arr_exp := reset_int_arr(0, MAX_REQUESTS_PER_TEST);
			odt_arr_exp := reset_int_arr(0, MAX_REQUESTS_PER_TEST);
			cas_latency_arr_exp := reset_int_arr(0, MAX_REQUESTS_PER_TEST);
			additive_latency_arr_exp := reset_int_arr(0, MAX_REQUESTS_PER_TEST);
			write_recovery_arr_exp := reset_int_arr(0, MAX_REQUESTS_PER_TEST);

			bl4_arr_exp := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);
			data_strb_arr_exp := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);
			rd_data_strb_arr_exp := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);
			high_temp_arr_exp := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);
			dll_rst_arr_exp := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);
			burst_type_arr_exp := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);
			power_down_exit_arr_exp := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);
			out_buffer_en_arr_exp := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);
			dll_enable_arr_exp := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);
			driving_strength_arr_exp := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);

			cmd_arr_rtl := reset_int_arr(0, MAX_REQUESTS_PER_TEST);
			odt_arr_rtl := reset_int_arr(0, MAX_REQUESTS_PER_TEST);
			cas_latency_arr_rtl := reset_int_arr(0, MAX_REQUESTS_PER_TEST);
			additive_latency_arr_rtl := reset_int_arr(0, MAX_REQUESTS_PER_TEST);
			write_recovery_arr_rtl := reset_int_arr(0, MAX_REQUESTS_PER_TEST);

			bl4_arr_rtl := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);
			data_strb_arr_rtl := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);
			rd_data_strb_arr_rtl := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);
			high_temp_arr_rtl := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);
			dll_rst_arr_rtl := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);
			burst_type_arr_rtl := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);
			power_down_exit_arr_rtl := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);
			out_buffer_en_arr_rtl := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);
			dll_enable_arr_rtl := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);
			driving_strength_arr_rtl := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);

			cmd_sent := false;

			regs_loop: loop

				wait until ((clk_tb = '1') and (clk_tb'event));

				exit regs_loop when ((num_cmd_sent_rtl_int = num_cmd_exp) and (num_cmd_stored_rtl_int = num_cmd_exp));

				wait for 1 ps;

				if (cmd_sent = true) then

				end if;

				if (num_cmd_sent_rtl_int < num_cmd_exp) then

					Cmd_tb <= std_logic_vector(to_unsigned(cmd_arr(num_cmd_sent_rtl_int), MEM_CMD_L));

					if (cmd_arr(num_cmd_sent_rtl_int) = to_integer(unsigned(CMD_MODE_REG_SET))) then

						MRSCmd_tb <= (12 => bool_to_std_logic(power_down_exit_arr(num_cmd_sent_rtl_int)), 11 downto 9 => std_logic_vector(to_unsigned(write_recovery_arr(num_cmd_sent_rtl_int), int_to_bit_num(WRITE_REC_MAX_VALUE))), 8 => bool_to_std_logic(dll_rst_arr(num_cmd_sent_rtl_int)), 6 downto 4 => std_logic_vector(to_unsigned(write_recovery_arr(num_cmd_sent_rtl_int), int_to_bit_num(WRITE_REC_MAX_VALUE))), 3 => bool_to_std_logic(burst_type_arr(num_cmd_sent_rtl_int)), 2 downto 0 => std_logic_vector(to_unsigned(write_recovery_arr(num_cmd_sent_rtl_int), int_to_bit_num(BURST_LENGTH_MAX_VALUE))),  others => '0');

					elsif (cmd_arr(num_cmd_sent_rtl_int) = to_integer(unsigned(CMD_EXT_MODE_REG_SET_1))) then

						MRSCmd_tb <= (12 => bool_to_std_logic(out_buffer_en_arr(num_cmd_sent_rtl_int)), 11 => bool_to_std_logic(rd_data_strb_arr(num_cmd_sent_rtl_int)),  10 => bool_to_std_logic(data_strb_arr(num_cmd_sent_rtl_int)), 5 downto 3 => std_logic_vector(to_unsigned(additive_latency_arr(num_cmd_sent_rtl_int), int_to_bit_num(AL_MAX_VALUE))), 1 => bool_to_std_logic(driver_strength_arr(num_cmd_sent_rtl_int)),  0 => bool_to_std_logic(dll_enable_arr(num_cmd_sent_rtl_int)), others => '0');
