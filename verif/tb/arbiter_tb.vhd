library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;
use work.proc_pkg.all;
use work.arbiter_pkg.all;
use work.tb_pkg.all;

entity arbiter_tb is
end entity arbiter_tb;

architecture bench of arbiter_tb is

	constant CLK_PERIOD	: time := DDR2_CLK_PERIOD * 1 ns;
	constant NUM_TESTS	: integer := 1000;
	constant TOT_NUM_TESTS	: integer := NUM_TESTS;

	constant NUM_REQ_TB	: integer := 8;
	constant DATA_L_TB	: integer := 32;

	constant MAX_REQUESTS_PER_TEST		: integer := 500;
	constant MAX_DELAY_PER_REQUEST		: integer := 20;

	signal clk_tb	: std_logic := '0';
	signal stop	: boolean := false;
	signal rst_tb	: std_logic;

	-- Request Set
	signal ReqIn_tb		: std_logic_vector(NUM_REQ_TB - 1 downto 0);
	signal DataIn_tb	: std_logic_vector(DATA_L_TB*NUM_REQ_TB - 1 downto 0);

	signal AckIn_tb		: std_logic;

	-- Request
	signal ReqOut_tb	: std_logic;
	signal DataOut_tb	: std_logic_vector(DATA_L_TB - 1 downto 0);

	signal AckOut_tb	: std_logic_vector(NUM_REQ_TB - 1 downto 0);

	-- Arbiter External Control
	signal StopArb_tb	: std_logic;

begin

	DUT: arbitrer generic map (
		NUM_REQ => NUM_REQ_TB,
		DATA_L => DATA_L_TB
	)
	port map (
		clk => clk_tb,
		rst => rst_tb,

		ReqIn => ReqIn_tb,
		DataIn => DataIn_tb,

		AckIn => AckIn_tb,

		ReqOut => ReqOut_tb,
		DataOut => DataOut_tb,

		AckOut => AckOut_tb,

		StopArb => StopArb_tb
	);

	clk_gen(CLK_PERIOD, 0 ns, stop, clk_tb);

	test: process

		procedure reset is
		begin
			AllowBankActivate_tb <= '0';
			BankCtrlCmdReq_tb <= (others => '0');
			ColCtrlCmdReq_tb <= (others => '0');
			RefCtrlCmdReq_tb <= (others => '0');

			rst_tb <= '0';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_tb <= '1';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_tb <= '0';
		end procedure reset;

		procedure test_param(variable num_requests : out integer; variable req_delay, data_arr, ack_delay : out int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (NUM_REQ_TB - 1)); variable stop_arb : out bool_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (NUM_REQ_TB - 1)); variable seed1, seed2: inout positive) is
			variable rand_val		: real;
			variable num_requests_int	: integer;
		begin

			num_requests_int := 0;
			while (num_requests_int = 0) loop
				uniform(seed1, seed2, rand_val);
				num_requests_int := integer(rand_val*real(MAX_REQUESTS_PER_TEST));
			end loop;
			num_requests := num_requests_int;

			for i in 0 to (num_requests_int - 1) loop
				for j in 0 to (NUM_REQ_TB - 1) loop
					uniform(seed1, seed2, rand_val);
					req_delay(i, j) := integer(rand_val*real(MAX_DELAY_PER_REQUEST - 1));
					uniform(seed1, seed2, rand_val);
					data_arr(i, j) := integer(rand_val*real(2.0**(real(ROW_L_TB) - 1.0)));
					uniform(seed1, seed2, rand_val);
					ack_delay(i, j) := integer(rand_val*real(MAX_DELAY_PER_REQUEST - 1));
					uniform(seed1, seed2, rand_val);
					stop_arb(i, j) := rand_bool(rand_val, 0.5);
				end loop;
			end loop;

		end procedure test_param;


