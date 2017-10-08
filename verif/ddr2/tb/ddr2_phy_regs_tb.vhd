library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;
use work.ddr2_define_pkg.all;
use work.functions_pkg.all;
use work.functions_tb_pkg.all;
use work.shared_tb_pkg.all;
use work.type_conversion_pkg.all;
use work.ddr2_pkg_tb.all;
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
	signal MRSCmd_tb	: std_logic_vector(REG_L_TB - 1 downto 0);
	signal Cmd_tb		: std_logic_vector(MEM_CMD_L - 1 downto 0);

	-- Register Values
	signal DDR2ODT_tb			: std_logic_vector(1 downto 0);
	signal DDR2DataStrobesEnable_tb		: std_logic;
	signal DDR2ReadDataStrobesEnable_tb	: std_logic;
	signal DDR2HighTemperature_tb		: std_logic;
	signal DDR2DLLReset_tb			: std_logic;
	signal DDR2CASLatency_tb		: std_logic_vector(2 downto 0);
	signal DDR2BurstType_tb			: std_logic;
	signal DDR2BurstLength_tb		: std_logic_vector(2 downto 0);
	signal DDR2PowerDownExitMode_tb		: std_logic;
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
		DDR2PowerDownExitMode => DDR2PowerDownExitMode_tb,
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
				if (cmd_int = 0) then
					cmd(i) := to_integer(unsigned(CMD_MODE_REG_SET));
				elsif (cmd_int = 1) then
					cmd(i) := to_integer(unsigned(CMD_EXT_MODE_REG_SET_1));
				elsif (cmd_int = 2) then
					cmd(i) := to_integer(unsigned(CMD_EXT_MODE_REG_SET_2));
				elsif (cmd_int = 3) then
					cmd(i) := to_integer(unsigned(CMD_EXT_MODE_REG_SET_3));
				else
					uniform(seed1, seed2, rand_val);
					cmd(i) := integer(rand_val*real(2.0**(real(MEM_CMD_L))));
				end if;
				uniform(seed1, seed2, rand_val);
				odt(i) := round(rand_val*real(ODT_MAX_VALUE));
				uniform(seed1, seed2, rand_val);
				cas_latency(i) := round(rand_val*real(CAS_LATENCY_MAX_VALUE));
				uniform(seed1, seed2, rand_val);
				additive_latency(i) := round(rand_val*real(AL_MAX_VALUE));
				uniform(seed1, seed2, rand_val);
				write_recovery(i) := round(rand_val*real(WRITE_REC_MAX_VALUE));
				uniform(seed1, seed2, rand_val);
				bl4(i) := rand_bool(rand_val, 0.5);
				uniform(seed1, seed2, rand_val);
				data_strb(i) := rand_bool(rand_val, 0.5);
				uniform(seed1, seed2, rand_val);
				rd_data_strb(i) := rand_bool(rand_val, 0.5);
				uniform(seed1, seed2, rand_val);
				high_temp(i) := rand_bool(rand_val, 0.5);
				uniform(seed1, seed2, rand_val);
				dll_rst(i) := rand_bool(rand_val, 0.5);
				uniform(seed1, seed2, rand_val);
				burst_type(i) := rand_bool(rand_val, 0.5);
				uniform(seed1, seed2, rand_val);
				power_down_exit(i) := rand_bool(rand_val, 0.5);
				uniform(seed1, seed2, rand_val);
				out_buffer_en(i) := rand_bool(rand_val, 0.5);
				uniform(seed1, seed2, rand_val);
				dll_enable(i) := rand_bool(rand_val, 0.5);
				uniform(seed1, seed2, rand_val);
				driving_strength(i) := rand_bool(rand_val, 0.5);

			end loop;

		end procedure test_param;

		procedure run_phy_regs(variable num_cmd_exp : in integer; variable cmd_arr, odt_arr, cas_latency_arr, additive_latency_arr, write_recovery_arr : in int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable bl4_arr, data_strb_arr, rd_data_strb_arr, high_temp_arr, dll_rst_arr, burst_type_arr, power_down_exit_arr, out_buffer_en_arr, dll_enable_arr, driving_strength_arr : in bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable num_cmd_rtl : out integer; variable odt_arr_exp, cas_latency_arr_exp, additive_latency_arr_exp, write_recovery_arr_exp : out int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable bl4_arr_exp, data_strb_arr_exp, rd_data_strb_arr_exp, high_temp_arr_exp, dll_rst_arr_exp, burst_type_arr_exp, power_down_exit_arr_exp, out_buffer_en_arr_exp, dll_enable_arr_exp, driving_strength_arr_exp : out bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable odt_arr_rtl, cas_latency_arr_rtl, additive_latency_arr_rtl, write_recovery_arr_rtl : out int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable bl4_arr_rtl, data_strb_arr_rtl, rd_data_strb_arr_rtl, high_temp_arr_rtl, dll_rst_arr_rtl, burst_type_arr_rtl, power_down_exit_arr_rtl, out_buffer_en_arr_rtl, dll_enable_arr_rtl, driving_strength_arr_rtl : out bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1))) is

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

			variable vec1	: std_logic_vector(int_to_bit_num(MAX_MRS_FIELD) - 1 downto 0);
			variable vec2	: std_logic_vector(int_to_bit_num(MAX_MRS_FIELD) - 1 downto 0);
			variable vec3	: std_logic_vector(int_to_bit_num(MAX_MRS_FIELD) - 1 downto 0);

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

					if (num_cmd_stored_rtl_int < num_cmd_exp) then

						if (cmd_arr(num_cmd_stored_rtl_int) = to_integer(unsigned(CMD_MODE_REG_SET))) then

							odt_arr_rtl(num_cmd_stored_rtl_int) := 0;
							cas_latency_arr_rtl(num_cmd_stored_rtl_int) := to_integer(unsigned(DDR2CASLatency_tb));
							additive_latency_arr_rtl(num_cmd_stored_rtl_int) := 0;
							write_recovery_arr_rtl(num_cmd_stored_rtl_int) := to_integer(unsigned(DDR2WriteRecovery_tb));

							if (to_integer(unsigned(DDR2BurstLength_tb)) = 2) then
								bl4_arr_rtl(num_cmd_stored_rtl_int) := true;
							else
								bl4_arr_rtl(num_cmd_stored_rtl_int) := false;
							end if;
							data_strb_arr_rtl(num_cmd_stored_rtl_int) := false;
							rd_data_strb_arr_rtl(num_cmd_stored_rtl_int) := false;
							high_temp_arr_rtl(num_cmd_stored_rtl_int) := false;
							dll_rst_arr_rtl(num_cmd_stored_rtl_int) := std_logic_to_bool(DDR2DLLReset_tb);
							burst_type_arr_rtl(num_cmd_stored_rtl_int) := std_logic_to_bool(DDR2BurstType_tb);
							power_down_exit_arr_rtl(num_cmd_stored_rtl_int) := std_logic_to_bool(DDR2PowerDownExitMode_tb);
							out_buffer_en_arr_rtl(num_cmd_stored_rtl_int) := false;
							dll_enable_arr_rtl(num_cmd_stored_rtl_int) := false;
							driving_strength_arr_rtl(num_cmd_stored_rtl_int) := false;

						elsif (cmd_arr(num_cmd_stored_rtl_int) = to_integer(unsigned(CMD_EXT_MODE_REG_SET_1))) then

							odt_arr_rtl(num_cmd_stored_rtl_int) := to_integer(unsigned(DDR2ODT_tb));
							cas_latency_arr_rtl(num_cmd_stored_rtl_int) := 0;
							additive_latency_arr_rtl(num_cmd_stored_rtl_int) := to_integer(unsigned(DDR2AdditiveLatency_tb));
							write_recovery_arr_rtl(num_cmd_stored_rtl_int) := 0;

							bl4_arr_rtl(num_cmd_stored_rtl_int) := false;
							data_strb_arr_rtl(num_cmd_stored_rtl_int) :=  std_logic_to_bool(DDR2DataStrobesEnable_tb);
							rd_data_strb_arr_rtl(num_cmd_stored_rtl_int) := std_logic_to_bool(DDR2ReadDataStrobesEnable_tb);
							high_temp_arr_rtl(num_cmd_stored_rtl_int) := false;
							dll_rst_arr_rtl(num_cmd_stored_rtl_int) := false;
							burst_type_arr_rtl(num_cmd_stored_rtl_int) := false;
							power_down_exit_arr_rtl(num_cmd_stored_rtl_int) := false;
							out_buffer_en_arr_rtl(num_cmd_stored_rtl_int) := std_logic_to_bool(DDR2OutBufferEnable_tb);
							dll_enable_arr_rtl(num_cmd_stored_rtl_int) := std_logic_to_bool(DDR2DLLEnable_tb);
							driving_strength_arr_rtl(num_cmd_stored_rtl_int) := std_logic_to_bool(DDR2DrivingStrength_tb);

						elsif (cmd_arr(num_cmd_stored_rtl_int) = to_integer(unsigned(CMD_EXT_MODE_REG_SET_2))) then

							odt_arr_rtl(num_cmd_stored_rtl_int) := 0;
							cas_latency_arr_rtl(num_cmd_stored_rtl_int) := 0;
							additive_latency_arr_rtl(num_cmd_stored_rtl_int) := 0;
							write_recovery_arr_rtl(num_cmd_stored_rtl_int) := 0;

							bl4_arr_rtl(num_cmd_stored_rtl_int) := false;
							data_strb_arr_rtl(num_cmd_stored_rtl_int) := false;
							rd_data_strb_arr_rtl(num_cmd_stored_rtl_int) := false;
							high_temp_arr_rtl(num_cmd_stored_rtl_int) := std_logic_to_bool(DDR2HighTemperature_tb);
							dll_rst_arr_rtl(num_cmd_stored_rtl_int) := false;
							burst_type_arr_rtl(num_cmd_stored_rtl_int) := false;
							power_down_exit_arr_rtl(num_cmd_stored_rtl_int) := false;
							out_buffer_en_arr_rtl(num_cmd_stored_rtl_int) := false;
							dll_enable_arr_rtl(num_cmd_stored_rtl_int) := false;
							driving_strength_arr_rtl(num_cmd_stored_rtl_int) := false;

						else -- EMRS3 or any other command

							odt_arr_rtl(num_cmd_stored_rtl_int) := 0;
							cas_latency_arr_rtl(num_cmd_stored_rtl_int) := 0;
							additive_latency_arr_rtl(num_cmd_stored_rtl_int) := 0;
							write_recovery_arr_rtl(num_cmd_stored_rtl_int) := 0;

							bl4_arr_rtl(num_cmd_stored_rtl_int) := false;
							data_strb_arr_rtl(num_cmd_stored_rtl_int) := false;
							rd_data_strb_arr_rtl(num_cmd_stored_rtl_int) := false;
							high_temp_arr_rtl(num_cmd_stored_rtl_int) := false;
							dll_rst_arr_rtl(num_cmd_stored_rtl_int) := false;
							burst_type_arr_rtl(num_cmd_stored_rtl_int) := false;
							power_down_exit_arr_rtl(num_cmd_stored_rtl_int) := false;
							out_buffer_en_arr_rtl(num_cmd_stored_rtl_int) := false;
							dll_enable_arr_rtl(num_cmd_stored_rtl_int) := false;
							driving_strength_arr_rtl(num_cmd_stored_rtl_int) := false;

						end if;

						num_cmd_stored_rtl_int := num_cmd_stored_rtl_int + 1;

					end if;

				end if;

				if (num_cmd_sent_rtl_int < num_cmd_exp) then

					Cmd_tb <= std_logic_vector(to_unsigned(cmd_arr(num_cmd_sent_rtl_int), MEM_CMD_L));
					cmd_sent := true;

					if (cmd_arr(num_cmd_sent_rtl_int) = to_integer(unsigned(CMD_MODE_REG_SET))) then

						odt_arr_exp(num_cmd_sent_rtl_int) := 0;
						cas_latency_arr_exp(num_cmd_sent_rtl_int) := cas_latency_arr(num_cmd_sent_rtl_int);
						additive_latency_arr_exp(num_cmd_sent_rtl_int) := 0;
						write_recovery_arr_exp(num_cmd_sent_rtl_int) := write_recovery_arr(num_cmd_sent_rtl_int);

						bl4_arr_exp(num_cmd_sent_rtl_int) := bl4_arr(num_cmd_sent_rtl_int);
						data_strb_arr_exp(num_cmd_sent_rtl_int) := false;
						rd_data_strb_arr_exp(num_cmd_sent_rtl_int) := false;
						high_temp_arr_exp(num_cmd_sent_rtl_int) := false;
						dll_rst_arr_exp(num_cmd_sent_rtl_int) := dll_rst_arr(num_cmd_sent_rtl_int);
						burst_type_arr_exp(num_cmd_sent_rtl_int) := burst_type_arr(num_cmd_sent_rtl_int);
						power_down_exit_arr_exp(num_cmd_sent_rtl_int) := power_down_exit_arr(num_cmd_sent_rtl_int);
						out_buffer_en_arr_exp(num_cmd_sent_rtl_int) := false;
						dll_enable_arr_exp(num_cmd_sent_rtl_int) := false;
						driving_strength_arr_exp(num_cmd_sent_rtl_int) := false;

						vec1 := std_logic_vector(to_unsigned(write_recovery_arr(num_cmd_sent_rtl_int), int_to_bit_num(MAX_MRS_FIELD)));
						vec2 := std_logic_vector(to_unsigned(cas_latency_arr(num_cmd_sent_rtl_int), int_to_bit_num(MAX_MRS_FIELD)));
						if (bl4_arr(num_cmd_sent_rtl_int) = true) then
							vec3 := std_logic_vector(to_unsigned(2, int_to_bit_num(MAX_MRS_FIELD)));
						else
							vec3 := std_logic_vector(to_unsigned(3, int_to_bit_num(MAX_MRS_FIELD)));
						end if;

						MRSCmd_tb <= (12 => bool_to_std_logic(power_down_exit_arr(num_cmd_sent_rtl_int)), 11 => vec1(2), 10 => vec1(1), 9 => vec1(0), 8 => bool_to_std_logic(dll_rst_arr(num_cmd_sent_rtl_int)), 6 => vec2(2), 5 => vec1(1), 4 => vec1(0), 3 => bool_to_std_logic(burst_type_arr(num_cmd_sent_rtl_int)), 1 => vec3(1), 0 => vec3(0),  others => '0');

					elsif (cmd_arr(num_cmd_sent_rtl_int) = to_integer(unsigned(CMD_EXT_MODE_REG_SET_1))) then

						odt_arr_exp(num_cmd_sent_rtl_int) := odt_arr(num_cmd_sent_rtl_int);
						cas_latency_arr_exp(num_cmd_sent_rtl_int) := 0;
						additive_latency_arr_exp(num_cmd_sent_rtl_int) := additive_latency_arr(num_cmd_sent_rtl_int);
						write_recovery_arr_exp(num_cmd_sent_rtl_int) := 0;

						bl4_arr_exp(num_cmd_sent_rtl_int) := false;
						data_strb_arr_exp(num_cmd_sent_rtl_int) := data_strb_arr(num_cmd_sent_rtl_int);
						rd_data_strb_arr_exp(num_cmd_sent_rtl_int) := rd_data_strb_arr(num_cmd_sent_rtl_int);
						high_temp_arr_exp(num_cmd_sent_rtl_int) := false;
						dll_rst_arr_exp(num_cmd_sent_rtl_int) := false;
						burst_type_arr_exp(num_cmd_sent_rtl_int) := false;
						power_down_exit_arr_exp(num_cmd_sent_rtl_int) := false;
						out_buffer_en_arr_exp(num_cmd_sent_rtl_int) := out_buffer_en_arr(num_cmd_sent_rtl_int);
						dll_enable_arr_exp(num_cmd_sent_rtl_int) := dll_enable_arr(num_cmd_sent_rtl_int);
						driving_strength_arr_exp(num_cmd_sent_rtl_int) := driving_strength_arr(num_cmd_sent_rtl_int);

						vec1 := std_logic_vector(to_unsigned(odt_arr(num_cmd_sent_rtl_int), int_to_bit_num(MAX_MRS_FIELD)));
						vec2 := std_logic_vector(to_unsigned(additive_latency_arr(num_cmd_sent_rtl_int), int_to_bit_num(MAX_MRS_FIELD)));

						MRSCmd_tb <= (12 => bool_to_std_logic(out_buffer_en_arr(num_cmd_sent_rtl_int)), 11 => bool_to_std_logic(rd_data_strb_arr(num_cmd_sent_rtl_int)),  10 => bool_to_std_logic(data_strb_arr(num_cmd_sent_rtl_int)), 6 => vec1(1), 5 => vec2(2), 4 => vec2(1), 3 => vec2(0), 2 => vec1(0), 1 => bool_to_std_logic(driving_strength_arr(num_cmd_sent_rtl_int)),  0 => bool_to_std_logic(dll_enable_arr(num_cmd_sent_rtl_int)), others => '0');

					elsif (cmd_arr(num_cmd_sent_rtl_int) = to_integer(unsigned(CMD_EXT_MODE_REG_SET_2))) then

						odt_arr_exp(num_cmd_sent_rtl_int) := 0;
						cas_latency_arr_exp(num_cmd_sent_rtl_int) := 0;
						additive_latency_arr_exp(num_cmd_sent_rtl_int) := 0;
						write_recovery_arr_exp(num_cmd_sent_rtl_int) := 0;

						bl4_arr_exp(num_cmd_sent_rtl_int) := false;
						data_strb_arr_exp(num_cmd_sent_rtl_int) := false;
						rd_data_strb_arr_exp(num_cmd_sent_rtl_int) := false;
						high_temp_arr_exp(num_cmd_sent_rtl_int) := high_temp_arr(num_cmd_sent_rtl_int);
						dll_rst_arr_exp(num_cmd_sent_rtl_int) := false;
						burst_type_arr_exp(num_cmd_sent_rtl_int) := false;
						power_down_exit_arr_exp(num_cmd_sent_rtl_int) := false;
						out_buffer_en_arr_exp(num_cmd_sent_rtl_int) := false;
						dll_enable_arr_exp(num_cmd_sent_rtl_int) := false;
						driving_strength_arr_exp(num_cmd_sent_rtl_int) := false;

						MRSCmd_tb <= (7 => bool_to_std_logic(high_temp_arr(num_cmd_sent_rtl_int)), others => '0');

					else -- EMRS3 or any other command

						odt_arr_exp(num_cmd_sent_rtl_int) := 0;
						cas_latency_arr_exp(num_cmd_sent_rtl_int) := 0;
						additive_latency_arr_exp(num_cmd_sent_rtl_int) := 0;
						write_recovery_arr_exp(num_cmd_sent_rtl_int) := 0;

						bl4_arr_exp(num_cmd_sent_rtl_int) := false;
						data_strb_arr_exp(num_cmd_sent_rtl_int) := false;
						rd_data_strb_arr_exp(num_cmd_sent_rtl_int) := false;
						high_temp_arr_exp(num_cmd_sent_rtl_int) := false;
						dll_rst_arr_exp(num_cmd_sent_rtl_int) := false;
						burst_type_arr_exp(num_cmd_sent_rtl_int) := false;
						power_down_exit_arr_exp(num_cmd_sent_rtl_int) := false;
						out_buffer_en_arr_exp(num_cmd_sent_rtl_int) := false;
						dll_enable_arr_exp(num_cmd_sent_rtl_int) := false;
						driving_strength_arr_exp(num_cmd_sent_rtl_int) := false;

						MRSCmd_tb <= (others => '0');

					end if;

					num_cmd_sent_rtl_int := num_cmd_sent_rtl_int + 1;

				end if;

			end loop;

		end procedure run_phy_regs;


		procedure verify(variable num_cmd_exp, num_cmd_rtl : in integer; variable cmd_arr : in int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable odt_arr_exp, cas_latency_arr_exp, additive_latency_arr_exp, write_recovery_arr_exp : in int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable bl4_arr_exp, data_strb_arr_exp, rd_data_strb_arr_exp, high_temp_arr_exp, dll_rst_arr_exp, burst_type_arr_exp, power_down_exit_arr_exp, out_buffer_en_arr_exp, dll_enable_arr_exp, driving_strength_arr_exp : in bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable odt_arr_rtl, cas_latency_arr_rtl, additive_latency_arr_rtl, write_recovery_arr_rtl : in int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable bl4_arr_rtl, data_strb_arr_rtl, rd_data_strb_arr_rtl, high_temp_arr_rtl, dll_rst_arr_rtl, burst_type_arr_rtl, power_down_exit_arr_rtl, out_buffer_en_arr_rtl, dll_enable_arr_rtl, driving_strength_arr_rtl : in bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); file file_pointer : text; variable pass: out integer) is

			variable match_odt		: boolean;
			variable match_cas_latency	: boolean;
			variable match_additive_latency	: boolean;
			variable match_write_recovery	: boolean;
			variable match_burst_type	: boolean;
			variable match_bl4		: boolean;
			variable match_data_strb	: boolean;
			variable match_rd_data_strb	: boolean;
			variable match_high_temp	: boolean;
			variable match_dll_rst		: boolean;
			variable match_dll_enable	: boolean;
			variable match_power_down_exit	: boolean;
			variable match_out_buffer_en	: boolean;
			variable match_driving_strength	: boolean;

			variable file_line		: line;

		begin

			write(file_line, string'( "PHY Registers: Number of commands: " & integer'image(num_cmd_exp)));
			writeline(file_pointer, file_line);

			match_odt := compare_int_arr(odt_arr_exp, odt_arr_rtl, num_cmd_exp);
			match_cas_latency := compare_int_arr(cas_latency_arr_exp, cas_latency_arr_rtl, num_cmd_exp);
			match_additive_latency := compare_int_arr(additive_latency_arr_exp, additive_latency_arr_rtl, num_cmd_exp);
			match_write_recovery := compare_int_arr(write_recovery_arr_exp, write_recovery_arr_rtl, num_cmd_exp);
			match_burst_type := compare_bool_arr(burst_type_arr_exp, burst_type_arr_rtl, num_cmd_exp);
			match_bl4 := compare_bool_arr(bl4_arr_exp, bl4_arr_rtl, num_cmd_exp);
			match_data_strb := compare_bool_arr(data_strb_arr_exp, data_strb_arr_rtl, num_cmd_exp);
			match_rd_data_strb := compare_bool_arr(rd_data_strb_arr_exp, rd_data_strb_arr_rtl, num_cmd_exp);
			match_high_temp := compare_bool_arr(high_temp_arr_exp, high_temp_arr_rtl, num_cmd_exp);
			match_dll_rst := compare_bool_arr(dll_rst_arr_exp, dll_rst_arr_rtl, num_cmd_exp);
			match_dll_enable := compare_bool_arr(dll_enable_arr_exp, dll_enable_arr_rtl, num_cmd_exp);
			match_power_down_exit := compare_bool_arr(power_down_exit_arr_exp, power_down_exit_arr_rtl, num_cmd_exp);
			match_out_buffer_en := compare_bool_arr(out_buffer_en_arr_exp, out_buffer_en_arr_rtl, num_cmd_exp);
			match_driving_strength := compare_bool_arr(driving_strength_arr_exp, driving_strength_arr_rtl, num_cmd_exp);

			if((match_odt = true) and (match_cas_latency = true) and (match_additive_latency = true) and (match_write_recovery = true) and (match_burst_type = true) and (match_bl4 = true) and (match_data_strb = true) and (match_rd_data_strb = true) and (match_high_temp = true) and (match_dll_rst = true) and (match_dll_enable = true) and (match_power_down_exit = true) and (match_out_buffer_en = true) and (match_driving_strength = true) and (num_cmd_exp = num_cmd_rtl)) then
				for i in 0 to (num_cmd_exp - 1) loop
					write(file_line, string'( "PHY Registers: Command #" & integer'image(i) & " details: Command " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(cmd_arr(i), MEM_CMD_L)))));
					writeline(file_pointer, file_line);
					if (cmd_arr(i) = to_integer(unsigned(CMD_MODE_REG_SET))) then
						write(file_line, string'( "PHY Registers: CAS Latency" & integer'image(cas_latency_arr_exp(i)) & " Write Recovery " & integer'image(write_recovery_arr_exp(i)) & " BL4 " & bool_to_str(bl4_arr_exp(i)) & " DLL Reset " & bool_to_str(dll_rst_arr_exp(i)) & " Burst Type " & bool_to_str(burst_type_arr_exp(i)) & " Power Down Exit " & bool_to_str(power_down_exit_arr_exp(i))));
					elsif (cmd_arr(i) = to_integer(unsigned(CMD_EXT_MODE_REG_SET_1))) then
						write(file_line, string'( "PHY Registers: ODT" & integer'image(odt_arr_exp(i)) & " Additive Latency " & integer'image(additive_latency_arr_exp(i)) & " Data Strobes " & bool_to_str(data_strb_arr_exp(i)) & " Read Data Strobes " & bool_to_str(rd_data_strb_arr_exp(i)) & " Output Buffer Enable " & bool_to_str(out_buffer_en_arr_exp(i)) & " DLL Enable " & bool_to_str(dll_enable_arr_exp(i)) & " Driving Strength " & bool_to_str(driving_strength_arr_exp(i))));
					elsif (cmd_arr(i) = to_integer(unsigned(CMD_EXT_MODE_REG_SET_2))) then
						write(file_line, string'( "PHY Registers: High Temperature Auto-Refresh Time " & bool_to_str(high_temp_arr_exp(i))));
					else -- EMRS3 or any other command
						write(file_line, string'( "PHY Registers: No MRS configuration"));
					end if;
					writeline(file_pointer, file_line);
				end loop;
				write(file_line, string'( "PHY Registers: PASS"));
				writeline(file_pointer, file_line);
				pass := 1;
			elsif (match_odt = false) then
				write(file_line, string'( "PHY Registers: FAIL (ODT Resistance mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_cmd_exp - 1) loop
					write(file_line, string'( "PHY Registers: Command #" & integer'image(i) & " Command " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(cmd_arr(i), MEM_CMD_L))) & " ODT resistance: exp " & integer'image(odt_arr_exp(i)) & " rtl " & integer'image(odt_arr_rtl(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (match_cas_latency = false) then
				write(file_line, string'( "PHY Registers: FAIL (CAS Latency mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_cmd_exp - 1) loop
					write(file_line, string'( "PHY Registers: Command #" & integer'image(i) & " Command " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(cmd_arr(i), MEM_CMD_L))) & " CAS Latency: exp " & integer'image(cas_latency_arr_exp(i)) & " rtl " & integer'image(cas_latency_arr_rtl(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (match_additive_latency = false) then
				write(file_line, string'( "PHY Registers: FAIL (Additive Latency mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_cmd_exp - 1) loop
					write(file_line, string'( "PHY Registers: Command #" & integer'image(i) & " Command " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(cmd_arr(i), MEM_CMD_L))) & " Additive Latency: exp " & integer'image(additive_latency_arr_exp(i)) & " rtl " & integer'image(additive_latency_arr_rtl(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (match_write_recovery = false) then
				write(file_line, string'( "PHY Registers: FAIL (Write Recovery mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_cmd_exp - 1) loop
					write(file_line, string'( "PHY Registers: Command #" & integer'image(i) & " Command " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(cmd_arr(i), MEM_CMD_L))) & " Write Recovery: exp " & integer'image(write_recovery_arr_exp(i)) & " rtl " & integer'image(write_recovery_arr_rtl(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (match_bl4 = false) then
				write(file_line, string'( "PHY Registers: FAIL (Burst Length mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_cmd_exp - 1) loop
					write(file_line, string'( "PHY Registers: Command #" & integer'image(i) & " Command " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(cmd_arr(i), MEM_CMD_L))) & " BL4: exp " & bool_to_str(bl4_arr_exp(i)) & " rtl " & bool_to_str(bl4_arr_rtl(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (match_burst_type = false) then
				write(file_line, string'( "PHY Registers: FAIL (Burst Type mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_cmd_exp - 1) loop
					write(file_line, string'( "PHY Registers: Command #" & integer'image(i) & " Command " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(cmd_arr(i), MEM_CMD_L))) & " Burst Type: exp " & bool_to_str(burst_type_arr_exp(i)) & " rtl " & bool_to_str(burst_type_arr_rtl(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (match_data_strb = false) then
				write(file_line, string'( "PHY Registers: FAIL (Data Strobe Enable mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_cmd_exp - 1) loop
					write(file_line, string'( "PHY Registers: Command #" & integer'image(i) & " Command " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(cmd_arr(i), MEM_CMD_L))) & " Data Strobe Enable: exp " & bool_to_str(data_strb_arr_exp(i)) & " rtl " & bool_to_str(data_strb_arr_rtl(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (match_rd_data_strb = false) then
				write(file_line, string'( "PHY Registers: FAIL (Read Data Strobe Enable mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_cmd_exp - 1) loop
					write(file_line, string'( "PHY Registers: Command #" & integer'image(i) & " Command " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(cmd_arr(i), MEM_CMD_L))) & " Read Data Strobe Enable: exp " & bool_to_str(rd_data_strb_arr_exp(i)) & " rtl " & bool_to_str(rd_data_strb_arr_rtl(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (match_dll_rst = false) then
				write(file_line, string'( "PHY Registers: FAIL (DLL Reset mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_cmd_exp - 1) loop
					write(file_line, string'( "PHY Registers: Command #" & integer'image(i) & " Command " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(cmd_arr(i), MEM_CMD_L))) & " DLL Reset: exp " & bool_to_str(dll_rst_arr_exp(i)) & " rtl " & bool_to_str(dll_rst_arr_rtl(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (match_dll_enable = false) then
				write(file_line, string'( "PHY Registers: FAIL (DLL Enable mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_cmd_exp - 1) loop
					write(file_line, string'( "PHY Registers: Command #" & integer'image(i) & " Command " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(cmd_arr(i), MEM_CMD_L))) & " DLL Enable: exp " & bool_to_str(dll_enable_arr_exp(i)) & " rtl " & bool_to_str(dll_enable_arr_rtl(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (match_high_temp = false) then
				write(file_line, string'( "PHY Registers: FAIL (High Temperature Auto-Refresh Time mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_cmd_exp - 1) loop
					write(file_line, string'( "PHY Registers: Command #" & integer'image(i) & " Command " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(cmd_arr(i), MEM_CMD_L))) & " High Temperature Auto-Refresh Time: exp " & bool_to_str(high_temp_arr_exp(i)) & " rtl " & bool_to_str(high_temp_arr_rtl(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (match_out_buffer_en = false) then
				write(file_line, string'( "PHY Registers: FAIL (Output Buffer Enable mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_cmd_exp - 1) loop
					write(file_line, string'( "PHY Registers: Command #" & integer'image(i) & " Command " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(cmd_arr(i), MEM_CMD_L))) & " Output Buffer Enable: exp " & bool_to_str(out_buffer_en_arr_exp(i)) & " rtl " & bool_to_str(out_buffer_en_arr_rtl(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (match_driving_strength = false) then
				write(file_line, string'( "PHY Registers: FAIL (Driving Strength mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_cmd_exp - 1) loop
					write(file_line, string'( "PHY Registers: Command #" & integer'image(i) & " Command " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(cmd_arr(i), MEM_CMD_L))) & " Driving Strength: exp " & bool_to_str(driving_strength_arr_exp(i)) & " rtl " & bool_to_str(driving_strength_arr_rtl(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (match_power_down_exit = false) then
				write(file_line, string'( "PHY Registers: FAIL (Power Down Exit mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_cmd_exp - 1) loop
					write(file_line, string'( "PHY Registers: Command #" & integer'image(i) & " Command " & ddr2_cmd_std_logic_vector_to_txt(std_logic_vector(to_unsigned(cmd_arr(i), MEM_CMD_L))) & " Power Down Exit: exp " & bool_to_str(power_down_exit_arr_exp(i)) & " rtl " & bool_to_str(power_down_exit_arr_rtl(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			else
				write(file_line, string'( "PHY Registers: FAIL (Unknown error)"));
				writeline(file_pointer, file_line);
				pass := 0;
			end if;
		end procedure verify;

		variable seed1, seed2	: positive;

		variable num_cmd_exp	: integer;
		variable num_cmd_rtl	: integer;

		variable cmd_arr	: int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));

		variable odt_arr			: int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable cas_latency_arr		: int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable additive_latency_arr		: int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable write_recovery_arr		: int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));

		variable bl4_arr			: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable data_strb_arr			: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable rd_data_strb_arr		: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable high_temp_arr			: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable dll_rst_arr			: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable burst_type_arr			: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable power_down_exit_arr		: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable out_buffer_en_arr		: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable dll_enable_arr			: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable driving_strength_arr		: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));

		variable odt_arr_exp			: int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable cas_latency_arr_exp		: int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable additive_latency_arr_exp	: int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable write_recovery_arr_exp		: int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));

		variable bl4_arr_exp			: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable data_strb_arr_exp		: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable rd_data_strb_arr_exp		: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable high_temp_arr_exp		: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable dll_rst_arr_exp		: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable burst_type_arr_exp		: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable power_down_exit_arr_exp	: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable out_buffer_en_arr_exp		: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable dll_enable_arr_exp		: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable driving_strength_arr_exp	: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));

		variable odt_arr_rtl			: int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable cas_latency_arr_rtl		: int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable additive_latency_arr_rtl	: int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable write_recovery_arr_rtl		: int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));

		variable bl4_arr_rtl			: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable data_strb_arr_rtl		: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable rd_data_strb_arr_rtl		: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable high_temp_arr_rtl		: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable dll_rst_arr_rtl		: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable burst_type_arr_rtl		: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable power_down_exit_arr_rtl	: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable out_buffer_en_arr_rtl		: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable dll_enable_arr_rtl		: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable driving_strength_arr_rtl	: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));

		variable pass		: integer;
		variable num_pass	: integer;

		file file_pointer	: text;
		variable file_line	: line;

	begin

		wait for 1 ns;

		num_pass := 0;

		file_open(file_pointer, ddr2_phy_regs_log_file, append_mode);

		write(file_line, string'( "PHY Registers Test"));
		writeline(file_pointer, file_line);

		for i in 0 to NUM_TESTS-1 loop

			reset;

			test_param(num_cmd_exp, cmd_arr, odt_arr, cas_latency_arr, additive_latency_arr, write_recovery_arr, bl4_arr, data_strb_arr, rd_data_strb_arr, high_temp_arr, dll_rst_arr, burst_type_arr, power_down_exit_arr, out_buffer_en_arr, dll_enable_arr, driving_strength_arr, seed1, seed2);

			run_phy_regs(num_cmd_exp, cmd_arr, odt_arr, cas_latency_arr, additive_latency_arr, write_recovery_arr, bl4_arr, data_strb_arr, rd_data_strb_arr, high_temp_arr, dll_rst_arr, burst_type_arr, power_down_exit_arr, out_buffer_en_arr, dll_enable_arr, driving_strength_arr, num_cmd_rtl, odt_arr_exp, cas_latency_arr_exp, additive_latency_arr_exp, write_recovery_arr_exp, bl4_arr_exp, data_strb_arr_exp, rd_data_strb_arr_exp, high_temp_arr_exp, dll_rst_arr_exp, burst_type_arr_exp, power_down_exit_arr_exp, out_buffer_en_arr_exp, dll_enable_arr_exp, driving_strength_arr_exp, odt_arr_rtl, cas_latency_arr_rtl, additive_latency_arr_rtl, write_recovery_arr_rtl, bl4_arr_rtl, data_strb_arr_rtl, rd_data_strb_arr_rtl, high_temp_arr_rtl, dll_rst_arr_rtl, burst_type_arr_rtl, power_down_exit_arr_rtl, out_buffer_en_arr_rtl, dll_enable_arr_rtl, driving_strength_arr_rtl);

			verify(num_cmd_exp, num_cmd_rtl, cmd_arr, odt_arr_exp, cas_latency_arr_exp, additive_latency_arr_exp, write_recovery_arr_exp, bl4_arr_exp, data_strb_arr_exp, rd_data_strb_arr_exp, high_temp_arr_exp, dll_rst_arr_exp, burst_type_arr_exp, power_down_exit_arr_exp, out_buffer_en_arr_exp, dll_enable_arr_exp, driving_strength_arr_exp, odt_arr_rtl, cas_latency_arr_rtl, additive_latency_arr_rtl, write_recovery_arr_rtl, bl4_arr_rtl, data_strb_arr_rtl, rd_data_strb_arr_rtl, high_temp_arr_rtl, dll_rst_arr_rtl, burst_type_arr_rtl, power_down_exit_arr_rtl, out_buffer_en_arr_rtl, dll_enable_arr_rtl, driving_strength_arr_rtl, file_pointer, pass);

			num_pass := num_pass + pass;

			wait until ((clk_tb'event) and (clk_tb = '1'));

		end loop;

		file_close(file_pointer);

		file_open(file_pointer, summary_file, append_mode);
		write(file_line, string'( "PHY Registers => PASSES: " & integer'image(num_pass) & " out of " & integer'image(TOT_NUM_TESTS)));
		writeline(file_pointer, file_line);

		if (num_pass = TOT_NUM_TESTS) then
			write(file_line, string'( "PHY Registers: TEST PASSED"));
		else
			write(file_line, string'( "PHY Registers: TEST FAILED: " & integer'image(TOT_NUM_TESTS-num_pass) & " failures"));
		end if;
		writeline(file_pointer, file_line);

		file_close(file_pointer);
		stop <= true;

		wait;

	end process test;

end bench;
