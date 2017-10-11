library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;

library common_tb_pkg;
use common_tb_pkg.shared_pkg_tb.all;
use common_tb_pkg.common_pkg_tb.all;
use common_tb_pkg.functions_pkg_tb.all;
use common_tb_pkg.common_log_pkg.all;

library common_rtl_pkg;
use common_rtl_pkg.arbiter_pkg.all;
use common_rtl_pkg.type_conversion_pkg.all;

entity arbiter_tb is
end entity arbiter_tb;

architecture bench of arbiter_tb is

	constant CLK_PERIOD	: time := COMMON_CLK_PERIOD * 1 ns;
	constant NUM_TESTS	: integer := 1000;
	constant TOT_NUM_TESTS	: integer := NUM_TESTS;

	constant NUM_REQ_TB	: integer := 8;
	constant ARB_DATA_L_TB	: integer := 32;

	constant MAX_REQUESTS_PER_TEST		: integer := 500;
	constant MAX_DELAY_PER_REQUEST		: integer := 20;

	constant MAX_VALUE_PRIORITY_TB		: integer := (NUM_REQ_TB - 1);

	constant ZERO_REQ_ACK_VEC	: std_logic_vector(NUM_REQ_TB - 1 downto 0) := (others => '0');

	signal clk_tb	: std_logic := '0';
	signal stop	: boolean := false;
	signal rst_tb	: std_logic;

	-- Request Set
	signal ReqIn_tb		: std_logic_vector(NUM_REQ_TB - 1 downto 0);
	signal DataIn_tb	: std_logic_vector(ARB_DATA_L_TB*NUM_REQ_TB - 1 downto 0);

	signal AckIn_tb		: std_logic;

	-- Request
	signal ReqOut_tb	: std_logic;
	signal DataOut_tb	: std_logic_vector(ARB_DATA_L_TB - 1 downto 0);

	signal AckOut_tb	: std_logic_vector(NUM_REQ_TB - 1 downto 0);

	-- Arbiter External Control
	signal StopArb_tb	: std_logic;

begin

	DUT: arbiter generic map (
		NUM_REQ => NUM_REQ_TB,
		DATA_L => ARB_DATA_L_TB
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
			StopArb_tb <= '1';

			ReqIn_tb <= (others => '0');
			DataIn_tb <= (others => '0');

			AckIn_tb <= '0';

			rst_tb <= '0';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_tb <= '1';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_tb <= '0';
		end procedure reset;

		procedure test_param(variable num_requests : out integer; variable req_delay : out int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable data_arr, ack_delay : out int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (NUM_REQ_TB - 1)); variable req : out bool_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (NUM_REQ_TB - 1)); variable stop_arb : out bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable seed1, seed2: inout positive) is
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
				uniform(seed1, seed2, rand_val);
				req_delay(i) := integer(rand_val*real(MAX_DELAY_PER_REQUEST - 1));
				uniform(seed1, seed2, rand_val);
				stop_arb(i) := rand_bool(rand_val, 0.5);
				for j in 0 to (NUM_REQ_TB - 1) loop
					uniform(seed1, seed2, rand_val);
					req(i, j) := rand_bool(rand_val, 0.5);
					uniform(seed1, seed2, rand_val);
					data_arr(i, j) := integer(rand_val*real(2.0**(real(ARB_DATA_L_TB) - 1.0)));
					uniform(seed1, seed2, rand_val);
					ack_delay(i, j) := integer(rand_val*real(MAX_DELAY_PER_REQUEST - 1));
				end loop;
			end loop;

		end procedure test_param;

		procedure run_arbiter(variable num_requests_exp : in integer; variable req_delay_arr : in int_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable data_arr, ack_delay_arr : in int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (NUM_REQ_TB - 1)); variable req_arr : in bool_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (NUM_REQ_TB - 1)); variable stop_arb_arr : in bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); variable num_requests_rtl : out integer; variable data_arr_exp, data_arr_rtl : out int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (NUM_REQ_TB - 1)); variable ack_err_arr, req_err_arr : out bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1))) is
			variable num_requests_rtl_int	: integer;

			variable priority		: integer;

			variable req_delay		: integer;
			variable ack_delay		: integer;
			variable stop_arb		: boolean;

			variable ack_err		: boolean;
			variable req_err		: boolean;

			variable req_arr_int		: bool_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (NUM_REQ_TB - 1));

		begin

			num_requests_rtl_int := 0;

			priority := 0;

			data_arr_exp := reset_int_arr_2d(0, MAX_REQUESTS_PER_TEST, NUM_REQ_TB);
			data_arr_rtl := reset_int_arr_2d(0, MAX_REQUESTS_PER_TEST, NUM_REQ_TB);

			req_err_arr := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);
			ack_err_arr := reset_bool_arr(false, MAX_REQUESTS_PER_TEST);

			req_arr_int := req_arr;

			ReqIn_tb <= (others => '0');
			AckIn_tb <= '0';
			StopArb_tb <= '1';
			DataIn_tb <= (others => '0');

			arb_loop: loop

				exit arb_loop when (num_requests_rtl_int = num_requests_exp);

				req_delay := req_delay_arr(num_requests_rtl_int);
				stop_arb := stop_arb_arr(num_requests_rtl_int);

				req_err := false;
				ack_err := false;

				StopArb_tb <= '1';

				ReqIn_tb <= (others => '0');
				DataIn_tb <= (others => '0');

				AckIn_tb <= '0';

				for i in 0 to req_delay loop
					wait until ((clk_tb = '1') and (clk_tb'event));
					if (i = req_delay) then

						StopArb_tb <= bool_to_std_logic(stop_arb);

						for j in 0 to (NUM_REQ_TB - 1) loop
							ReqIn_tb(j) <= bool_to_std_logic(req_arr_int(num_requests_rtl_int, j));
							DataIn_tb((j+1)*ARB_DATA_L_TB - 1 downto j*ARB_DATA_L_TB) <= std_logic_vector(to_unsigned(data_arr(num_requests_rtl_int, j), ARB_DATA_L_TB));
						end loop;
					else
						if (AckOut_tb /= ZERO_REQ_ACK_VEC) then
							ack_err := true;
						end if;
						if (ReqOut_tb = '1') then
							req_err := true;
						end if;
					end if;
				end loop;

				wait until ((clk_tb = '0') and (clk_tb'event));

				for i in 0 to (NUM_REQ_TB - 1) loop
					ack_delay := ack_delay_arr(num_requests_rtl_int, i);
					data_arr_rtl(num_requests_rtl_int, i) := to_integer(unsigned(DataOut_tb));
					data_arr_exp(num_requests_rtl_int, i) := data_arr(num_requests_rtl_int, priority);
					if (req_arr_int(num_requests_rtl_int, priority) = true) then
						if (ReqOut_tb = '0') then
							req_err := true;
						end if;

						if (ack_delay > 0) then
							for j in 0 to ack_delay loop
								if (j = ack_delay) then
									AckIn_tb <= '1';
								else
									AckIn_tb <= '0';
								end if;

								wait until ((clk_tb = '1') and (clk_tb'event));
							end loop;

							if (AckOut_tb(priority) = '0') then
								ack_err := true;
							end if;

							wait until ((clk_tb = '0') and (clk_tb'event));

						else
							AckIn_tb <= '1';

							wait until ((clk_tb = '1') and (clk_tb'event));

							if (AckOut_tb(priority) = '0') then
								ack_err := true;
							end if;

							wait until ((clk_tb = '0') and (clk_tb'event));

						end if;

					else
						AckIn_tb <= '0';
						wait until ((clk_tb = '0') and (clk_tb'event));
					end if;

					if ((stop_arb = false) and ((AckIn_tb = '1') or (req_arr_int(num_requests_rtl_int, priority) = false))) then

						ReqIn_tb(priority)  <= '0';

						req_arr_int(num_requests_rtl_int, priority) := false;

						if (priority = (MAX_VALUE_PRIORITY_TB - 1)) then
							priority := 0;
						else
							priority := priority + 1;
						end if;
					end if;

				end loop;

				ReqIn_tb <= (others => '0');

				req_err_arr(num_requests_rtl_int) := req_err;
				ack_err_arr(num_requests_rtl_int) := ack_err;

				num_requests_rtl_int := num_requests_rtl_int + 1;

			end loop;

			num_requests_rtl := num_requests_rtl_int;

		end procedure run_arbiter;

		procedure verify (variable num_requests_exp, num_requests_rtl : in integer; variable req_arr : in bool_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (NUM_REQ_TB - 1)); variable data_in : in int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (NUM_REQ_TB - 1)); variable data_arr_exp, data_arr_rtl : in int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (NUM_REQ_TB - 1)); variable stop_arb_arr,  ack_err_arr, req_err_arr : in bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1)); file file_pointer : text; variable pass: out integer) is

			variable match_data	: boolean;
			variable no_req_err	: boolean;
			variable no_ack_err	: boolean;

			variable file_line	: line;

		begin

			match_data := compare_int_arr_2d(data_arr_exp, data_arr_rtl, num_requests_exp, NUM_REQ_TB);

			no_req_err := compare_bool_arr(reset_bool_arr(false, num_requests_exp), req_err_arr, num_requests_exp);
			no_ack_err := compare_bool_arr(reset_bool_arr(false, num_requests_exp), ack_err_arr, num_requests_exp);

			for i in 0 to (num_requests_exp - 1) loop
				write(file_line, string'( "Arbiter: Request #" & integer'image(i) & ": Stop Arbiter " & bool_to_str(stop_arb_arr(i))));
				writeline(file_pointer, file_line);
				for j in 0 to (NUM_REQ_TB - 1) loop
					write(file_line, string'( "Arbiter: Request #" & integer'image(i) & " Port #" & integer'image(j) & ": Req " & bool_to_str(req_arr(i, j)) & " Data " & integer'image(data_in(i, j))));
					writeline(file_pointer, file_line);
				end loop;
			end loop;

			if ((num_requests_exp = num_requests_rtl) and (match_data = true) and (no_req_err = true) and (no_ack_err = true)) then
				write(file_line, string'( "Arbiter: PASS"));
				writeline(file_pointer, file_line);
				pass := 1;
			elsif (num_requests_exp /= num_requests_rtl) then
				write(file_line, string'( "Arbiter: FAIL (Burst number mismatch)"));
				writeline(file_pointer, file_line);
				pass := 0;
			elsif (match_data = false) then
				write(file_line, string'( "Arbiter: FAIL (Data mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_requests_exp - 1) loop
					for j in 0 to (NUM_REQ_TB - 1) loop
						if (data_arr_exp(i, j) /= data_arr_rtl(i, j)) then
							write(file_line, string'( "Arbiter: Request #" & integer'image(i) & " Port #" & integer'image(j) & " Data exp " & integer'image(data_arr_exp(i, j)) & " vs rtl " & integer'image(data_arr_rtl(i, j))));
						writeline(file_pointer, file_line);
						end if;
					end loop;
				end loop;
				pass := 0;
			elsif (no_req_err = false) then
				write(file_line, string'( "Arbiter: FAIL (Request Error)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_requests_exp - 1) loop
					write(file_line, string'( "Arbiter: Request #" & integer'image(i) & " Request Error: " & bool_to_str(req_err_arr(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (no_ack_err = false) then
				write(file_line, string'( "Arbiter: FAIL (Acknoledge Error)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_requests_exp - 1) loop
					write(file_line, string'( "Arbiter: Request #" & integer'image(i) & " Acknowledge Error: " & bool_to_str(ack_err_arr(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			else
				write(file_line, string'( "Arbiter: FAIL (Unknown Error)"));
				writeline(file_pointer, file_line);
				pass := 0;
			end if;

		end procedure verify;

		variable seed1, seed2	: positive;

		variable num_requests_exp	: integer;
		variable num_requests_rtl	: integer;

		variable req_delay_arr		: int_arr(0 to (MAX_REQUESTS_PER_TEST - 1));

		variable data_arr		: int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (NUM_REQ_TB - 1));
		variable ack_delay_arr		: int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (NUM_REQ_TB - 1));

		variable req_arr		: bool_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (NUM_REQ_TB - 1));
		variable stop_arb_arr		: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));

		variable data_arr_exp		: int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (NUM_REQ_TB - 1));
		variable data_arr_rtl		: int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (NUM_REQ_TB - 1));

		variable ack_err_arr		: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));
		variable req_err_arr		: bool_arr(0 to (MAX_REQUESTS_PER_TEST - 1));

		variable pass		: integer;
		variable num_pass	: integer;

		file file_pointer	: text;
		variable file_line	: line;


	begin

		wait for 1 ns;

		num_pass := 0;

		file_open(file_pointer, arbiter_log_file, append_mode);

		write(file_line, string'( "Arbiter Test"));
		writeline(file_pointer, file_line);

		for i in 0 to NUM_TESTS-1 loop

			reset;

			test_param(num_requests_exp, req_delay_arr, data_arr, ack_delay_arr, req_arr, stop_arb_arr, seed1, seed2);

			run_arbiter(num_requests_exp, req_delay_arr, data_arr, ack_delay_arr, req_arr, stop_arb_arr, num_requests_rtl, data_arr_exp, data_arr_rtl, ack_err_arr, req_err_arr);

			verify (num_requests_exp, num_requests_rtl, req_arr, data_arr, data_arr_exp, data_arr_rtl, stop_arb_arr, ack_err_arr, req_err_arr, file_pointer, pass);

			num_pass := num_pass + pass;

			wait until ((clk_tb'event) and (clk_tb = '1'));

		end loop;

		file_close(file_pointer);

		file_open(file_pointer, summary_file, append_mode);
		write(file_line, string'( "ARBITER => PASSES: " & integer'image(num_pass) & " out of " & integer'image(TOT_NUM_TESTS)));
		writeline(file_pointer, file_line);

		if (num_pass = TOT_NUM_TESTS) then
			write(file_line, string'( "ARBITER: TEST PASSED"));
		else
			write(file_line, string'( "ARBITER: TEST FAILED: " & integer'image(TOT_NUM_TESTS-num_pass) & " failures"));
		end if;
		writeline(file_pointer, file_line);

		file_close(file_pointer);
		stop <= true;

		wait;

	end process test;

end bench;
