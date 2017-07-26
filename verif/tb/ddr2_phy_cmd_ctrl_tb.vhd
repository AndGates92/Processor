library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;
use work.ddr2_phy_pkg.all;
use work.ddr2_mrs_pkg.all;
use work.ddr2_gen_ac_timing_pkg.all;
use work.ddr2_phy_cmd_ctrl_pkg.all;
use work.type_conversion_pkg.all;
use work.tb_pkg.all;
use work.proc_pkg.all;
use work.ddr2_pkg_tb.all;

entity ddr2_phy_cmd_ctrl_tb is
end entity ddr2_phy_cmd_ctrl_tb;

architecture bench of ddr2_phy_cmd_ctrl_tb is

	constant CLK_PERIOD		: time := DDR2_CLK_PERIOD * 1 ns;
	constant NUM_TEST		: integer := 1000;
	constant NUM_EXTRA_TEST		: integer := 2;
	constant TOT_NUM_TEST		: integer := NUM_TEST + NUM_EXTRA_TEST;
	constant MAX_ATTEMPTS		: integer := 20;

	constant BURST_LENGTH_MRS	: real := (2.0**(real(to_integer(unsigned(BURST_LENGTH)))));

	constant ZERO_BANK_VEC		: std_logic_vector(BANK_NUM_TB - 1 downto 0) := (others => '0');

	constant MAX_BURST_DELAY	: integer := 20;
	constant MAX_CMD_ACK_ACK_DELAY	: integer := 4;

	constant BURST_LENGTH_L_TB	: integer := COL_L_TB;

	signal clk_tb	: std_logic := '0';
	signal stop	: boolean := false;
	signal rst_tb	: std_logic;

	-- Column Controller
	-- Arbitrer
	signal ColCtrlCmdAck_tb		: std_logic;

	signal ColCtrlColMemOut_tb	: std_logic_vector(COL_L_TB - 1 downto 0);
	signal ColCtrlBankMemOut_tb	: std_logic_vector(int_to_bit_num(BANK_NUM_TB) - 1 downto 0);
	signal ColCtrlCmdOut_tb		: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal ColCtrlCmdReq_tb		: std_logic;

	-- Controller
	signal ColCtrlCtrlReq_tb	: std_logic;
	signal ColCtrlReadBurstIn_tb	: std_logic;
	signal ColCtrlColMemIn_tb	: std_logic_vector(COL_L_TB - to_integer(unsigned(BURST_LENGTH)) - 1 downto 0);
	signal ColCtrlBankMemIn_tb	: std_logic_vector(int_to_bit_num(BANK_NUM_TB) - 1 downto 0);
	signal ColCtrlBurstLength_tb	: std_logic_vector(BURST_LENGTH_L - 1 downto 0);

	signal ColCtrlCtrlAck_tb	: std_logic;

	-- Bank Controllers
	-- Arbitrer
	signal BankCtrlCmdAck_tb	: std_logic_vector(BANK_NUM_TB - 1 downto 0);

	signal BankCtrlRowMemOut_tb	: std_logic_vector(BANK_NUM_TB*ROW_L_TB - 1 downto 0);
	signal BankCtrlCmdOut_tb	: std_logic_vector(BANK_NUM_TB*MEM_CMD_L - 1 downto 0);
	signal BankCtrlCmdReq_tb	: std_logic_vector(BANK_NUM_TB - 1 downto 0);

	-- Transaction Controller
	signal BankCtrlRowMemIn_tb	: std_logic_vector(BANK_NUM_TB*ROW_L_TB - 1 downto 0);
	signal BankCtrlCtrlReq_tb	: std_logic_vector(BANK_NUM_TB - 1 downto 0);

	signal BankCtrlCtrlAck_tb	: std_logic_vector(BANK_NUM_TB - 1 downto 0);

	-- Status
	signal BankIdleVec_tb		: std_logic_vector(BANK_NUM_TB - 1 downto 0)

begin

	DUT: ddr2_phy_cmd_ctrl generic map (
		BURST_LENGTH_L => BURST_LENGTH_L_TB,
		BANK_NUM => BANK_NUM_TB,
		COL_L => COL_L_TB,
		ROW_L => ROW_L_TB,
		MAX_OUTSTANDING_BURSTS => MAX_OUTSTANDING_BURSTS_TB
	)
	port map (
		clk => clk_tb,
		rst => rst_tb,

		-- Column Controller
		-- Arbitrer
		ColCtrlCmdAck => ColCtrlCmdAck_tb

		ColCtrlColMemOut => ColCtrlColMemOut_tb
		ColCtrlBankMemOut => ColCtrlBankMemOut_tb
		ColCtrlCmdOut => ColCtrlCmdOut_tb
		ColCtrlCmdReq => ColCtrlCmdReq_tb

		-- Controller
		ColCtrlCtrlReq => ColCtrlCtrlReq_tb
		ColCtrlReadBurstIn => ColCtrlReadBurstIn_tb
		ColCtrlColMemIn => ColCtrlColMemIn_tb
		ColCtrlBankMemIn => ColCtrlBankMemIn_tb
		ColCtrlBurstLength => ColCtrlBurstLength_tb

		ColCtrlCtrlAck => ColCtrlCtrlAck_tb

		-- Bank Controllers
		-- Arbitrer
		BankCtrlCmdAck => BankCtrlCmdAck_tb

		BankCtrlRowMemOut => BankCtrlRowMemOut_tb
		BankCtrlCmdOut => BankCtrlCmdOut_tb
		BankCtrlCmdReq => BankCtrlCmdReq_tb

		-- Transaction Controller
		BankCtrlRowMemIn => BankCtrlRowMemIn_tb
		BankCtrlCtrlReq => BankCtrlCtrlReq_tb

		BankCtrlCtrlAck => BankCtrlCtrlAck_tb

		-- Status
		BankIdleVec => BankIdleVec_tb

	);

	clk_gen(CLK_PERIOD, 0 ns, stop, clk_tb);

	test: process

		procedure reset is
		begin
			rst_tb <= '0';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_tb <= '1';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_tb <= '0';
		end procedure reset;

		procedure test_param(variable num_bursts : out integer; variable num_bursts_arr : out int_arr(0 to (BANK_NUM_TB - 1)); variable bank, cols, rows : out int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable read_burst : out bool_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable bl, cmd_delay, ctrl_delay : out int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable seed1, seed2 : inout positive) is
			variable rand_val		: real;
			variable num_bursts_arr_int	: int_arr(0 to (BANK_NUM_TB - 1));
			variable num_bursts_int		: integer;
			variable bl_int			: integer;
			variable col_int		: integer;
			variable bank_int		: integer;
			variable attempt_num		: integer;
		begin
			num_bursts_int := 0;
			num_burst_arr := reset_int_arr(0, BANK_NUM_TB);
			for i in 0 to (BANK_NUM_TB - 1) loop
				while (num_bursts_arr(i) = 0) loop
					uniform(seed1, seed2, rand_val);
					num_bursts_arr(i) := integer(rand_val*real(MAX_OUTSTANDING_BURSTS_TB));
				end loop;
				num_bursts_int := num_bursts_int + num_bursts_arr(i);
			end loop;
			num_bursts := num_bursts_int;
			num_bursts_arr := num_bursts_arr_int;

			for i in 0 to (num_bursts_int - 1) loop
				-- select bank
				uniform(seed1, seed2, rand_val);
				bank_int := integer(rand_val*real(BANK_NUM_TB - 1));
				while (num_bursts_arr_int(bank_int) = 0) loop
					uniform(seed1, seed2, rand_val);
					bank_int := integer(rand_val*real(BANK_NUM_TB - 1));
				end if;
				bank(i) := bank_int;
				num_bursts_arr_int(bank_int) := num_bursts_arr_int(bank_int) - 1;

				uniform(seed1, seed2, rand_val);
				col_int := integer(rand_val*(2.0**(real(COL_L_TB - to_integer(unsigned(BURST_LENGTH)))) - 1.0));
				cols(i) := col_int;
				bl_int := 0;
				attempt_num := 0;
				while ((bl_int <= 0) and (attempt_num < MAX_ATTEMPTS)) loop
					uniform(seed1, seed2, rand_val);
					bl_int := round(rand_val*((2.0**(real(COL_L_TB - to_integer(unsigned(BURST_LENGTH))))) - real(col_int) - 1.0));
					attempt_num := attempt_num + 1;
				end loop;
				if (attempt_num = MAX_ATTEMPTS) then
					bl_int := 1;
				end if;

				uniform(seed1, seed2, rand_val);
				rows(i) := integer(rand_val*(2.0**(real(ROW_L_TB)) - 1.0));

				uniform(seed1, seed2, rand_val);
				cmd_delay(i) := integer(rand_val*real(MAX_DELAY));

				uniform(seed1, seed2, rand_val);
				ctrl_delay(i) := integer(rand_val*real(MAX_DELAY));

				uniform(seed1, seed2, rand_val);
				read_burst(i) := rand_bool(rand_val);

			end loop;

			for i in num_bursts_int to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1) loop

				bank(i) := int_arr_def;
				rows(i) := int_arr_def;
				cols(i) := int_arr_def;
				bl(i) := int_arr_def;

				cmd_delay(i) := int_arr_def;
				ctrl_delay(i) := int_arr_def;
				read_burst(i) := false;

			end loop;

		end procedure test_param;

		procedure run_cmd_ctrl (variable num_bursts_exp : in integer; variable bank_arr_exp, cols_arr, rows_arr_exp : in int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable read_arr_exp : in bool_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable bl_arr_exp, cmd_delay_arr, ctrl_delay_arr : in int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable num_bursts_rtl : out integer; variable read_arr_rtl : out bool_arr(0 to (MAX_OUTSTANDING_BURSTS_TB - 1)); variable bank_ctrl_err_arr, col_ctrl_err_arr, bl_arr_rtl, row_arr_rtl, bank_arr_rtl, start_col_arr_exp : out int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable col_err_arr_exp, col_err_arr_rtl : out int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1), 0 to (integer(2.0**(real(BURST_LENGTH_L_TB)) - 1.0))); variable seed1, seed2 : inout positive)

			variable rand_val		: real;
			variable num_bursts_rtl_int	: integer;
			variable data_phase_num_int	: integer;

			variable bank_ctrl_err_int	: integer;
			variable col_ctrl_err_int	: integer;

			variable bank_ctrl_req		: boolean;
			variable bank_cmd_ack		: boolean;
			variable col_ctrl_req		: boolean;
			variable col_cmd_ack		: boolean;

			variable bank_ctrl_cnt		: integer;
			variable col_ctrl_cnt		: integer;

			variable col_ctrl_bank		: integer;
			variable bank_ctrl_bank		: integer;
			variable col			: integer;
			variable row			: integer;

			variable bl			: integer;
			variable ctrl_delay		: integer;
			variable cmd_delay		: integer;

			variable read_burst		: boolean;

			variable col_ctrl_bank_int	: integer;
			variable bank_ctrl_bank_int	: integer;
			variable col_int		: integer;
			variable row_int		: integer;

			variable bl_int			: integer;

			variable read_burst_int		: boolean;

		begin

			bl_int := 0;

			read_burst_int := false;

			num_bursts_rtl_int := 0;
			data_phase_num_int := 0;

			bank_ctrl_req := false;
			col_ctrl_req := false;
			col_cmd_ack := false;

			bank_ctrl_cnt := 0;
			col_ctrl_cnt := 0;

			bank_ctrl_bank := bank_arr_exp(num_bursts_rtl_int);
			col_ctrl_bank := bank_arr_exp(data_phase_num_int);
			col := cols_arr(data_phase_num_int);
			row := rows_arr_exp(num_bursts_rtl_int);

			bl := bl_arr_exp(data_phase_num_int);
			cmd_delay := cmd_delay_arr(num_bursts_rtl_int);
			ctrl_delay := ctrl_delay_arr(num_bursts_rtl_int);

			read_burst := read_bursts_exp(data_phase_nun_int);

			col_ctrl_bank_int := 0;
			bank_ctrl_bank_int := 0;
			col_int := 0;;
			row_int := 0;;

			bank_ctrl_err_int := 0; 
			col_ctrl_err_int := 0; 

			-- Column Controller
			-- Arbitrer
			ColCtrlCmdAck_tb <= '0';

			-- Controller
			ColCtrlCtrlReq_tb <= '0';
			ColCtrlReadBurstIn_tb <= '0';
			ColCtrlColMemIn_tb <= (others => '0');
			ColCtrlBankMemIn_tb <= (others => '0');
			ColCtrlBurstLength_tb <= (others => '0');

			-- Bank Controllers
			-- Arbitrer
			BankCtrlCmdAck_tb <= (others => '0');

			-- Transaction Controller
			BankCtrlRowMemIn_tb <= (others => '0');
			BankCtrlCtrlReq_tb <= (others => '0');

			cmd_loop: loop

				wait until ((clk_tb = '1') and (clk_tb'event));

				exit cmd_loop when ((num_bursts_rtl_int = num_bursts_exp) and (data_phase_burst_num = num_bursts_exp));

				if (num_bursts_rtl_int < num_bursts_exp) then
					bank_ctrl_bank := bank_arr_exp(num_bursts_rtl_int);
					row := rows_arr_exp(num_bursts_rtl_int);

					cmd_delay := cmd_delay_arr(num_bursts_rtl_int);
					ctrl_delay := ctrl_delay_arr(num_bursts_rtl_int);

					if (bank_ctrl_req = false) then
						-- Arbitrer
						BankCtrlCmdAck_tb <= (others => '0');
						if (bank_ctrl_cnt = ctrl_delay) then
							-- Transaction Controller
							BankCtrlRowMemIn_tb <= std_logic_vector(to_unsigned(row, BANK_NUM_TB));
							BankCtrlCtrlReq_tb <= std_logic_vector(to_unsigned(integer(2.0**(real(bank_ctrl_bank))), BANK_NUM_TB));
							bank_ctrl_cnt := 0;
							bank_ctrl_req := true;
						else
							-- Transaction Controller
							BankCtrlRowMemIn_tb <= (others => '0');
							BankCtrlCtrlReq_tb <= (others => '0');
							bank_ctrl_cnt := bank_ctrl_cnt + 1;
						end if;

						if (BankCtrlCmdReq_tb /= ZERO_BANK_VEC) then
							bank_ctrl_err_int := bank_ctrl_err_int + 1;
						end if;
					else
						if (BankCtrlCtrlAck_tb(bank_ctrl_bank) = '1') then
							if (BankCtrlCtrlReq_tb(bank_ctrl_bank) = '1') then 
								BankCtrlCtrlReq_tb <= (others => '0');
							else
								bank_ctrl_err_int := bank_ctrl_err_int + 1;
							end if; 
						else
							if ((BankCtrlCtrlAck_tb /= ZERO_BANK_VEC) and (BankCtrlCtrlReq_tb = ZERO_BANK_VEC)) then
								bank_ctrl_err_int := bank_ctrl_err_int + 1;
							end if;
						end if;

						if (BankCtrlCmdReq_tb(bank_ctrl_bank) = '1') then
							if (bank_ctrl_cnt = cmd_delay) then
								bank_ctrl_cnt := 0;
								row_arr_rtl(num_bursts_rtl_int) := to_integer(to_unsigned(BankCtrlRowMemOut_tb));
								BankCtrlCmdAck_tb <= std_logic_vector(to_unsigned(integer(2.0**(real(bank_ctrl_bank))), BANK_NUM_TB));

								bank_ctrl_req := false;
								bank_ctrl_cnt := 0;

								bank_ctrl_err_arr(num_bursts_rtl_int) := bank_ctrl_err_int;

								num_bursts_rtl_int := num_bursts_rtl_int + 1;

							else
								bank_ctrl_cnt := bank_ctrl_cnt + 1;
								BankCtrlCmdAck_tb <= (others => '0');
							end if;
						else
							BankCtrlCmdAck_tb <= (others => '0');
						end if;
					end if;
				end if;

				if (data_phase_num_int < num_bursts_rtl_int) then
					if (col_ctrl_req = false) then
						-- Arbitrer
						ColCtrlCmdAck_tb <= (others => '0');
						if (col_ctrl_cnt = ctrl_delay) then
							-- Transaction Controller
							ColCtrlRowMemIn_tb <= std_logic_vector(to_unsigned(row, BANK_NUM_TB));
							ColCtrlCtrlReq_tb <= std_logic_vector(to_unsigned(integer(2.0**(real(col_ctrl_bank))), BANK_NUM_TB));
							col_ctrl_cnt := 0;
							col_ctrl_req := true;
						else
							-- Transaction Controller
							ColCtrlRowMemIn_tb <= (others => '0');
							ColCtrlCtrlReq_tb <= (others => '0');
							col_ctrl_cnt := col_ctrl_cnt + 1;
						end if;

						if (BankCtrlCmdReq_tb /= ZERO_BANK_VEC) then
							col_ctrl_err_int := col_ctrl_err_int + 1;
						end if;
					else

					

				end if;

			end loop;

			num_bursts_rtl := num_bursts_rtl_int;
		end procedure run_cmd_ctrl;

		procedure verify (variable num_bursts_exp, num_bursts_rtl : in integer; variable num_bursts_arr : in int_arr(0 to (BANK_NUM_TB - 1)); variable bank_arr_exp, bank_arr_rtl, rows_arr_exp, rows_arr_rtl, bl_arr_exp, bl_arr_rtl, bank_ctrl_err_arr, col_ctrl_err_arr, start_col_arr_exp : in int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable read_arr_exp, read_arr_rtl : in bool_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable col_err_arr_exp, col_err_arr_rtl : in int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1), 0 to (integer(2.0**(real(BURST_LENGTH_L_TB)) - 1.0)); file file_pointer : text; variable pass: out integer)

			variable file_line		: line;
		begin

			write(file_line, string'( "PHY Command Controller: Number of bursts: " & integer'image(num_bursts_exp)));
			writeline(file_pointer, file_line);

		end procedure verify;

		variable seed1, seed2	: positive;

		variable num_bursts_exp	: integer;
		variable num_bursts_arr	: int_arr(0 to (BANK_NUM_TB - 1));
		variable num_bursts_rtl	: integer;

		variable bank_arr_exp		: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable bank_arr_rtl		: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable rows_arr_exp		: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable rows_arr_rtl		: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable bl_arr_exp		: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable bl_arr_rtl		: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable bank_ctrl_err_arr	: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable col_ctrl_err_arr	: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable start_col_arr_exp	: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable col_arr		: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable cmd_delay_arr		: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable ctrl_delay_arr		: int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));

		variable read_arr_exp	: bool_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable read_arr_rtl	: bool_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));

		variable col_err_arr_exp	: int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1), 0 to (integer(2.0**(real(BURST_LENGTH_L_TB)) - 1.0));
		variable col_err_arr_rtl	: int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1), 0 to (integer(2.0**(real(BURST_LENGTH_L_TB)) - 1.0));

		variable pass		: integer;
		variable num_pass	: integer;

		file file_pointer	: text;
		variable file_line	: line;

	begin

		wait for 1 ns;

		num_pass := 0;

		reset;
		file_open(file_pointer, log_file, append_mode);

		write(file_line, string'( "PHY Command Controller Test"));
		writeline(file_pointer, file_line);

		for i in 0 to NUM_TEST-1 loop

			test_param(num_bursts_exp, num_bursts_arr, bank_arr_exp, col_arr, rows_arr_exp, read_bursts_exp, bl_arr_exp, cmd_delay_arr, ctrl_delay_arr, seed1, seed2);

			run_cmd_ctrl (num_bursts_exp,  bank_arr_exp, cols_arr, rows_arr_exp, read_arr_exp, bl_arr_exp, cmd_delay_arr, ctrl_delay_arr, num_bursts_rtl, read_arr_rtl, bank_ctrl_err_arr, col_ctrl_err_arr, bl_arr_rtl, row_arr_rtl, bank_arr_rtl, start_col_arr_exp, col_err_arr_exp, col_err_arr_rtl, seed1, seed2);

			verify (num_bursts_exp, num_bursts_rtl, num_bursts_arr, bank_arr_exp, bank_arr_rtl, rows_arr_exp, rows_arr_rtl, bl_arr_exp, bl_arr_rtl, bank_ctrl_err_arr, col_ctrl_err_arr, start_col_arr_exp, read_arr_exp, read_arr_rtl, col_err_arr_exp, col_err_arr_rtl, file_pointer, pass);

			num_pass := num_pass + pass;

			wait until ((clk_tb'event) and (clk_tb = '1'));

		end loop;


		if (NUM_EXTRA_TEST > 0) then

		end if;

		file_close(file_pointer);

		file_open(file_pointer, summary_file, append_mode);
		write(file_line, string'( "PHY Column Controller => PASSES: " & integer'image(num_pass) & " out of " & integer'image(TOT_NUM_TEST)));
		writeline(file_pointer, file_line);

		if (num_pass = TOT_NUM_TEST) then
			write(file_line, string'( "PHY Column Controller: TEST PASSED"));
		else
			write(file_line, string'( "PHY Column Controller: TEST FAILED: " & integer'image(TOT_NUM_TEST-num_pass) & " failures"));
		end if;
		writeline(file_pointer, file_line);

		file_close(file_pointer);
		stop <= true;

	end process test;

end bench;
