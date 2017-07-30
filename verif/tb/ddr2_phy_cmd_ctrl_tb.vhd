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
	constant MAX_CMD_DELAY		: integer := 20;
	constant MAX_BANK_CMD_WAIT	: integer := 5;
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
	signal ColCtrlBurstLength_tb	: std_logic_vector(BURST_LENGTH_L_TB - 1 downto 0);

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
	signal BankIdleVec_tb		: std_logic_vector(BANK_NUM_TB - 1 downto 0);

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
		ColCtrlCmdAck => ColCtrlCmdAck_tb,

		ColCtrlColMemOut => ColCtrlColMemOut_tb,
		ColCtrlBankMemOut => ColCtrlBankMemOut_tb,
		ColCtrlCmdOut => ColCtrlCmdOut_tb,
		ColCtrlCmdReq => ColCtrlCmdReq_tb,

		-- Controller
		ColCtrlCtrlReq => ColCtrlCtrlReq_tb,
		ColCtrlReadBurstIn => ColCtrlReadBurstIn_tb,
		ColCtrlColMemIn => ColCtrlColMemIn_tb,
		ColCtrlBankMemIn => ColCtrlBankMemIn_tb,
		ColCtrlBurstLength => ColCtrlBurstLength_tb,

		ColCtrlCtrlAck => ColCtrlCtrlAck_tb,

		-- Bank Controllers
		-- Arbitrer
		BankCtrlCmdAck => BankCtrlCmdAck_tb,

		BankCtrlRowMemOut => BankCtrlRowMemOut_tb,
		BankCtrlCmdOut => BankCtrlCmdOut_tb,
		BankCtrlCmdReq => BankCtrlCmdReq_tb,

		-- Transaction Controller
		BankCtrlRowMemIn => BankCtrlRowMemIn_tb,
		BankCtrlCtrlReq => BankCtrlCtrlReq_tb,

		BankCtrlCtrlAck => BankCtrlCtrlAck_tb,

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
			num_bursts_arr_int := reset_int_arr(0, BANK_NUM_TB);
			for i in 0 to (BANK_NUM_TB - 1) loop
				while (num_bursts_arr_int(i) = 0) loop
					uniform(seed1, seed2, rand_val);
					num_bursts_arr_int(i) := integer(rand_val*real(MAX_OUTSTANDING_BURSTS_TB));
				end loop;
				num_bursts_int := num_bursts_int + num_bursts_arr_int(i);
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
				end loop;
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
				bl(i) := bl_int;

				uniform(seed1, seed2, rand_val);
				rows(i) := integer(rand_val*(2.0**(real(ROW_L_TB)) - 1.0));

				uniform(seed1, seed2, rand_val);
				cmd_delay(i) := integer(rand_val*real(MAX_CMD_DELAY));

				uniform(seed1, seed2, rand_val);
				ctrl_delay(i) := integer(rand_val*real(MAX_BURST_DELAY));

				uniform(seed1, seed2, rand_val);
				read_burst(i) := rand_bool(rand_val);

--report "Col " & integer'image(col_int) & " BL " & integer'image(bl_int) & " Bank " & integer'image(bank_int);

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

		procedure run_cmd_ctrl (variable num_bursts_exp : in integer; variable bank_arr_exp, cols_arr, rows_arr_exp : in int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable read_bursts_arr_exp : in bool_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable bl_arr_exp, cmd_delay_arr, ctrl_delay_arr : in int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable num_bursts_rtl : out integer; variable read_bursts_arr_rtl : out bool_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable bank_ctrl_err_arr, col_ctrl_err_arr, bl_arr_rtl, row_arr_rtl, bank_arr_rtl, start_col_arr_exp : out int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable col_err_arr_exp, col_err_arr_rtl : out int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1), 0 to (integer(2.0**(real(BURST_LENGTH_L_TB)) - 1.0))); variable seed1, seed2 : inout positive) is

			variable rand_val			: real;
			variable num_bursts_rtl_int		: integer;
			variable data_phase_num_ctrl_int	: integer;
			variable data_phase_num_cmd_int		: integer;

			variable bank_ctrl_err_int	: integer;
			variable col_ctrl_err_int	: integer;

			variable bank_ctrl_req		: boolean;
			variable bank_cmd_ack		: boolean;
			variable col_ctrl_req		: boolean;

			variable bank_ctrl_handshake	: boolean;

			variable bank_ctrl_cnt			: integer;
			variable bank_ctrl_cmd_wait_cnt		: integer;
			variable col_ctrl_cnt			: integer;
			variable col_cmd_cnt			: integer;

			variable bank_ctrl_bank_int	: integer;
			variable row_int		: integer;
			variable bank_ctrl_delay	: integer;
			variable bank_cmd_delay		: integer;

			variable col_ctrl_bank_int	: integer;
			variable bl_ctrl_int		: integer;
			variable col_ctrl_int		: integer;
			variable read_burst_int		: boolean;
			variable col_ctrl_delay		: integer;

			variable col_cmd_bank_int	: integer;
			variable col_cmd_int		: integer;
			variable bl_cmd_int		: integer;
			variable col_cmd_delay		: integer;

			variable bl_accepted		: integer;

			variable col_err		: integer;

			variable col_rtl		: integer;
			variable col_exp		: integer;

		begin

			num_bursts_rtl_int := 0;
			data_phase_num_cmd_int := 0;
			data_phase_num_ctrl_int := 0;

			bank_ctrl_req := false;
			bank_cmd_ack := false;
			col_ctrl_req := false;

			bank_ctrl_handshake := false;

			bank_ctrl_cnt := 0;
			bank_ctrl_cmd_wait_cnt := 0;
			col_ctrl_cnt := 0;
			col_cmd_cnt := 0;

			bank_ctrl_bank_int := bank_arr_exp(num_bursts_rtl_int);
			row_int := rows_arr_exp(num_bursts_rtl_int);
			bank_cmd_delay := cmd_delay_arr(num_bursts_rtl_int);
			bank_ctrl_delay := ctrl_delay_arr(num_bursts_rtl_int);

			col_ctrl_bank_int := bank_arr_exp(data_phase_num_ctrl_int);
			col_ctrl_int := cols_arr(data_phase_num_ctrl_int);
			bl_ctrl_int := bl_arr_exp(data_phase_num_ctrl_int);
			read_burst_int := read_bursts_arr_exp(data_phase_num_ctrl_int);
			col_ctrl_delay := ctrl_delay_arr(data_phase_num_ctrl_int);

			col_cmd_bank_int := bank_arr_exp(data_phase_num_cmd_int);
			col_cmd_int := cols_arr(data_phase_num_cmd_int);
			bl_cmd_int := bl_arr_exp(data_phase_num_cmd_int);
			col_cmd_delay := cmd_delay_arr(data_phase_num_cmd_int);

			bank_ctrl_err_int := 0;
			col_ctrl_err_int := 0;

			bl_accepted := 0;

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

			col_err := 0;
			col_rtl := 0;
			col_exp := 0;

			cmd_loop: loop

				wait until ((clk_tb = '1') and (clk_tb'event));

				exit cmd_loop when ((num_bursts_rtl_int = num_bursts_exp) and (data_phase_num_cmd_int = num_bursts_exp) and (data_phase_num_ctrl_int = num_bursts_exp));
				if (bank_ctrl_handshake = true) then -- Emulate Register BankCtrlCtrlReq
					BankCtrlCtrlReq_tb <= (others => '0');
				end if;

				wait for 1 ps;

report "Burst cnt: exp " & integer'image(num_bursts_exp) & " rtl " & integer'image(num_bursts_rtl_int) & " col ctrl data phase: ctrl " & integer'image(data_phase_num_ctrl_int) & " cmd " & integer'image(data_phase_num_cmd_int);
report "bank ctrl req: " & bool_to_str(bank_ctrl_req) & " bank cmd ack: " & bool_to_str(bank_cmd_ack) & " col ctrl req: " & bool_to_str(col_ctrl_req);

				if (num_bursts_rtl_int < num_bursts_exp) then
					bank_ctrl_bank_int := bank_arr_exp(num_bursts_rtl_int);
					row_int := rows_arr_exp(num_bursts_rtl_int);

					bank_cmd_delay := cmd_delay_arr(num_bursts_rtl_int);
					bank_ctrl_delay := ctrl_delay_arr(num_bursts_rtl_int);

					if (bank_ctrl_req = false) then

						bank_ctrl_handshake := false;

--report "Bank Ctrl: Bank " & integer'image(bank_ctrl_bank_int) & " Row " & integer'image(row_int);
						-- Arbitrer
						BankCtrlCmdAck_tb <= (others => '0');
						if (bank_ctrl_cnt = bank_ctrl_delay) then
							-- Transaction Controller
							for i in 0 to (BANK_NUM_TB - 1) loop
								if (i = bank_ctrl_bank_int) then
									BankCtrlRowMemIn_tb(((i+1)*ROW_L_TB - 1) downto i*ROW_L_TB) <= std_logic_vector(to_unsigned(row_int, ROW_L_TB));
								else
									BankCtrlRowMemIn_tb(((i+1)*ROW_L_TB - 1) downto i*ROW_L_TB) <= (others => '0');
								end if;
							end loop;
							BankCtrlCtrlReq_tb <= std_logic_vector(to_unsigned(integer(2.0**(real(bank_ctrl_bank_int))), BANK_NUM_TB));
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

						wait for 1 ps;

						if (BankCtrlCtrlAck_tb(bank_ctrl_bank_int) = '1') then
							if (BankCtrlCtrlReq_tb(bank_ctrl_bank_int) = '1') then 
								bank_ctrl_handshake := true;
--								BankCtrlCtrlReq_tb <= (others => '0');
							else
								bank_ctrl_err_int := bank_ctrl_err_int + 1;
							end if; 
						else
							if ((BankCtrlCtrlAck_tb /= ZERO_BANK_VEC) and (BankCtrlCtrlReq_tb = ZERO_BANK_VEC)) then
								bank_ctrl_err_int := bank_ctrl_err_int + 1;
							end if;
						end if;

					else
						if (BankCtrlCtrlAck_tb(bank_ctrl_bank_int) = '1') then
							if (BankCtrlCtrlReq_tb(bank_ctrl_bank_int) = '1') then 
								bank_ctrl_handshake := true;
--								BankCtrlCtrlReq_tb <= (others => '0');
							else
								bank_ctrl_err_int := bank_ctrl_err_int + 1;
							end if; 
						else
							if ((BankCtrlCtrlAck_tb /= ZERO_BANK_VEC) and (BankCtrlCtrlReq_tb = ZERO_BANK_VEC)) then
								bank_ctrl_err_int := bank_ctrl_err_int + 1;
							end if;
						end if;

						if (BankCtrlCmdReq_tb(bank_ctrl_bank_int) = '1') then
							if (bank_ctrl_cnt = bank_cmd_delay) then
								row_arr_rtl(num_bursts_rtl_int) := to_integer(unsigned(BankCtrlRowMemOut_tb));
								BankCtrlCmdAck_tb <= std_logic_vector(to_unsigned(integer(2.0**(real(bank_ctrl_bank_int))), BANK_NUM_TB));

								bank_ctrl_req := false;
								bank_ctrl_cnt := 0;
								bank_ctrl_cmd_wait_cnt := 0;

								bank_ctrl_err_arr(num_bursts_rtl_int) := bank_ctrl_err_int;

								num_bursts_rtl_int := num_bursts_rtl_int + 1;

							else
								bank_ctrl_cnt := bank_ctrl_cnt + 1;
								BankCtrlCmdAck_tb <= (others => '0');
							end if;
						else
report "Wait CmdReq: cnt" & integer'image(bank_ctrl_cmd_wait_cnt);
							if (bank_ctrl_handshake = true) then
								if (bank_ctrl_cmd_wait_cnt = MAX_BANK_CMD_WAIT) then
report "Cnt reached";
									bank_ctrl_cnt := 0;
									row_arr_rtl(num_bursts_rtl_int) := to_integer(unsigned(BankCtrlRowMemOut_tb));

									bank_ctrl_req := false;
									bank_ctrl_cnt := 0;
									bank_ctrl_cmd_wait_cnt := 0;

									bank_ctrl_err_arr(num_bursts_rtl_int) := bank_ctrl_err_int;

									num_bursts_rtl_int := num_bursts_rtl_int + 1;
								else
									bank_ctrl_cmd_wait_cnt := bank_ctrl_cmd_wait_cnt + 1;
								end if;
							end if;

							BankCtrlCmdAck_tb <= (others => '0');
						end if;
					end if;
				else
					BankCtrlCmdAck_tb <= (others => '0');
				end if;

				if ((data_phase_num_ctrl_int < num_bursts_rtl_int) and (data_phase_num_ctrl_int < num_bursts_exp)) then

					col_ctrl_delay := ctrl_delay_arr(data_phase_num_ctrl_int);

					if (col_ctrl_req = false) then
						col_ctrl_bank_int := bank_arr_exp(data_phase_num_ctrl_int);
						col_ctrl_int := integer(real(cols_arr(data_phase_num_ctrl_int)) * BURST_LENGTH_MRS);
						bl_ctrl_int := bl_arr_exp(data_phase_num_ctrl_int);
						read_burst_int := read_bursts_arr_exp(data_phase_num_ctrl_int);
						col_ctrl_delay := ctrl_delay_arr(data_phase_num_ctrl_int);

--report " Col Ctrl Col " & integer'image(cols_arr(data_phase_num_ctrl_int)) & " BL " & integer'image(bl_ctrl_int);

						if (col_ctrl_cnt = col_ctrl_delay) then
							-- Transaction Controller
							ColCtrlBurstLength_tb <= std_logic_vector(to_unsigned(bl_ctrl_int-1, BURST_LENGTH_L_TB));
							ColCtrlBankMemIn_tb <= std_logic_vector(to_unsigned(col_ctrl_bank_int, int_to_bit_num(BANK_NUM_TB)));
							ColCtrlColMemIn_tb <= std_logic_vector(to_unsigned(cols_arr(data_phase_num_ctrl_int), (COL_L_TB - to_integer(unsigned(BURST_LENGTH)))));
							ColCtrlReadBurstIn_tb <= bool_to_std_logic(read_burst_int);
							ColCtrlCtrlReq_tb <= '1';

							start_col_arr_exp(num_bursts_rtl_int) := col_ctrl_int;

							col_ctrl_cnt := 0;
							col_ctrl_req := true;
						else
							-- Transaction Controller
							ColCtrlColMemIn_tb <= (others => '0');
							ColCtrlCtrlReq_tb <= '0';
							col_ctrl_cnt := col_ctrl_cnt + 1;
						end if;

					else
						if (ColCtrlCtrlAck_tb = '1') then
							ColCtrlCtrlReq_tb <= '0';
							col_ctrl_req := false;
							data_phase_num_ctrl_int := data_phase_num_ctrl_int + 1;
						end if;
					end if;
				else
					ColCtrlCtrlReq_tb <= '0';
				end if;

				if ((data_phase_num_cmd_int < num_bursts_rtl_int) and (data_phase_num_cmd_int < num_bursts_exp)) then
					if (ColCtrlCmdReq_tb = '1') then
						col_cmd_bank_int := bank_arr_exp(data_phase_num_cmd_int);
						col_cmd_int := integer(real(cols_arr(data_phase_num_cmd_int) + bl_accepted) * BURST_LENGTH_MRS);
						bl_cmd_int := bl_arr_exp(data_phase_num_cmd_int);
						col_cmd_delay := cmd_delay_arr(data_phase_num_cmd_int);

						if (col_cmd_cnt = col_cmd_delay) then
							ColCtrlCmdAck_tb <= '1';
							col_rtl := to_integer(unsigned(ColCtrlColMemOut_tb));
							col_exp := integer(real(cols_arr(data_phase_num_cmd_int) + bl_accepted) * BURST_LENGTH_MRS);
							if (col_rtl /= col_exp) then
								col_err_arr_rtl(data_phase_num_cmd_int, col_err) := col_rtl;
								col_err_arr_exp(data_phase_num_cmd_int, col_err) := col_exp;
								col_err := col_err + 1;
							end if;

							col_cmd_cnt := 0;

							bl_accepted := bl_accepted + 1;
--report "bl " & integer'image(bl_accepted) & " out of " & integer'image(bl_cmd_int);

							if (bl_accepted = bl_cmd_int) then
								bank_arr_rtl(data_phase_num_cmd_int) := to_integer(unsigned(ColCtrlBankMemOut_tb));
								bl_arr_rtl(data_phase_num_cmd_int) := bl_accepted;
								col_ctrl_err_arr(data_phase_num_cmd_int) := col_err;
								col_err := 0;
								bl_accepted := 0;
								data_phase_num_cmd_int := data_phase_num_cmd_int + 1;
							end if;
						else
							ColCtrlCmdAck_tb <= '0';
							col_cmd_cnt := col_cmd_cnt + 1;
						end if;

					else
						ColCtrlCmdAck_tb <= '0';
					end if;
				else
					ColCtrlCmdAck_tb <= '0';
				end if;

			end loop;

			num_bursts_rtl := num_bursts_rtl_int;
		end procedure run_cmd_ctrl;

		procedure verify (variable num_bursts_exp, num_bursts_rtl : in integer; variable num_bursts_arr : in int_arr(0 to (BANK_NUM_TB - 1)); variable bank_arr_exp, bank_arr_rtl, rows_arr_exp, rows_arr_rtl, bl_arr_exp, bl_arr_rtl, bank_ctrl_err_arr, col_ctrl_err_arr, start_col_arr_exp : in int_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable read_bursts_arr_exp, read_bursts_arr_rtl : in bool_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1)); variable col_err_arr_exp, col_err_arr_rtl : in int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1), 0 to (integer(2.0**(real(BURST_LENGTH_L_TB)) - 1.0))); file file_pointer : text; variable pass: out integer) is

			variable match_banks		: boolean;
			variable match_bl		: boolean;
			variable match_read_burst	: boolean;
			variable match_rows		: boolean;
			variable bank_ctrl_no_errors	: boolean;
			variable col_ctrl_no_errors	: boolean;
			variable file_line		: line;
		begin

			write(file_line, string'( "PHY Command Controller: Number of bursts: " & integer'image(num_bursts_exp)));
			writeline(file_pointer, file_line);
			for i in 0 to (BANK_NUM_TB - 1) loop
				write(file_line, string'( "PHY Command Controller: Bank #" & integer'image(i) & ": Number of bursts " & integer'image(num_bursts_arr(i))));
				writeline(file_pointer, file_line);
			end loop;

			bank_ctrl_no_errors := compare_int_arr(reset_int_arr(0, num_bursts_exp), bank_ctrl_err_arr, num_bursts_exp);
			col_ctrl_no_errors := compare_int_arr(reset_int_arr(0, num_bursts_exp), col_ctrl_err_arr, num_bursts_exp);
			match_rows := compare_int_arr(rows_arr_exp, rows_arr_rtl, num_bursts_exp);
			match_banks := compare_int_arr(bank_arr_exp, bank_arr_rtl, num_bursts_exp);
			match_read_burst := compare_bool_arr(read_bursts_arr_exp, read_bursts_arr_rtl, num_bursts_exp);
			match_bl := compare_int_arr(bl_arr_exp, bl_arr_rtl, num_bursts_exp);

			if ((match_bl = true) and (match_read_burst = true) and (match_banks = true) and (match_rows = true) and (bank_ctrl_no_errors = true) and (col_ctrl_no_errors = true) and (num_bursts_exp = num_bursts_rtl)) then
				for i in 0 to (num_bursts_exp - 1) loop
					write(file_line, string'( "PHY Command Controller: Burst #" & integer'image(i) & " details: Bank " & integer'image(bank_arr_exp(i)) & "  " & integer'image(rows_arr_exp(i)) & " Start Col " & integer'image(start_col_arr_exp(i)) & " Read Burst " & bool_to_str(read_bursts_arr_exp(i)) & " Burst Length " & integer'image(bl_arr_exp(i))));
					writeline(file_pointer, file_line);
				end loop;
				write(file_line, string'( "PHY Command Controller: PASS"));
				writeline(file_pointer, file_line);
				pass := 1;
			elsif (match_rows = false) then
				write(file_line, string'( "PHY Command Controller: FAIL (Rows mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_bursts_exp - 1) loop
					write(file_line, string'( "PHY Command Controller: Burst #" & integer'image(i) & " Beats: exp " & integer'image(rows_arr_exp(i)) & " vs rtl " & integer'image(rows_arr_rtl(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (match_bl = false) then
				write(file_line, string'( "PHY Command Controller: FAIL (Burst Length mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_bursts_exp - 1) loop
					write(file_line, string'( "PHY Command Controller: Burst #" & integer'image(i) & " Beats: exp " & integer'image(bl_arr_exp(i)) & " vs rtl " & integer'image(bl_arr_rtl(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (match_read_burst = false) then
				write(file_line, string'( "PHY Command Controller: FAIL (Read Burst count mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_bursts_exp - 1) loop
					write(file_line, string'( "PHY Command Controller: Read Burst #" & integer'image(i) & " exp " & bool_to_str(read_bursts_arr_exp(i)) & " vs rtl " & bool_to_str(read_bursts_arr_rtl(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (col_ctrl_no_errors = false) then
				write(file_line, string'( "PHY Command Controller: FAIL (Col mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_bursts_exp - 1) loop
					write(file_line, string'( "========================================================================================"));
					writeline(file_pointer, file_line);
					write(file_line, string'( "PHY Command Controller: Burst #" & integer'image(i) & " details: Start Col " & integer'image(start_col_arr_exp(i)) & " Burst Length " & integer'image(bl_arr_exp(i))));
					writeline(file_pointer, file_line);
					for j in 0 to (col_ctrl_err_arr(i) - 1) loop
						write(file_line, string'( "PHY Command Controller: Burst #" & integer'image(i) & " exp " & integer'image(col_err_arr_exp(i, j)) & " vs rtl " & integer'image(col_err_arr_rtl(i, j))));
						writeline(file_pointer, file_line);
					end loop;
				end loop;
				write(file_line, string'( "========================================================================================"));
				writeline(file_pointer, file_line);
				pass := 0;
			elsif (bank_ctrl_no_errors = false) then
				write(file_line, string'( "PHY Command Controller: FAIL (Bank Controller Handshake Error)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_bursts_exp - 1) loop
					writeline(file_pointer, file_line);
					write(file_line, string'( "PHY Command Controller: Burst #" & integer'image(i) & " Errors " & integer'image(bank_ctrl_err_arr(i)) & " Burst Length " & integer'image(bl_arr_exp(i))));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			elsif (num_bursts_exp /= num_bursts_rtl) then
				write(file_line, string'( "PHY Command Controller: FAIL (Number bursts mismatch): exp " & integer'image(num_bursts_exp) & " vs rtl " & integer'image(num_bursts_rtl)));
				writeline(file_pointer, file_line);
				pass := 0;
			elsif (match_banks = false) then
				write(file_line, string'( "PHY Command Controller: FAIL (Bank mismatch)"));
				writeline(file_pointer, file_line);
				for i in 0 to (num_bursts_exp - 1) loop
					write(file_line, string'( "PHY Command Controller: Burst #" & integer'image(i) & " exp " & integer'image(bank_arr_exp(i))) & " vs rtl " & integer'image(bank_arr_rtl(i)));
					writeline(file_pointer, file_line);
				end loop;
				pass := 0;
			else
				write(file_line, string'( "PHY Command Controller: FAIL (Unknown error)"));
				writeline(file_pointer, file_line);
				pass := 0;
			end if;


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

		variable read_bursts_arr_exp	: bool_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));
		variable read_bursts_arr_rtl	: bool_arr(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1));

		variable col_err_arr_exp	: int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1), 0 to (integer(2.0**(real(BURST_LENGTH_L_TB)) - 1.0)));
		variable col_err_arr_rtl	: int_arr_2d(0 to (BANK_NUM_TB*MAX_OUTSTANDING_BURSTS_TB - 1), 0 to (integer(2.0**(real(BURST_LENGTH_L_TB)) - 1.0)));

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

			test_param(num_bursts_exp, num_bursts_arr, bank_arr_exp, col_arr, rows_arr_exp, read_bursts_arr_exp, bl_arr_exp, cmd_delay_arr, ctrl_delay_arr, seed1, seed2);

report "test #" & integer'image(i) & " out of " & integer'image(NUM_TEST) & " num burst " & integer'image(num_bursts_exp);

			run_cmd_ctrl (num_bursts_exp,  bank_arr_exp, col_arr, rows_arr_exp, read_bursts_arr_exp, bl_arr_exp, cmd_delay_arr, ctrl_delay_arr, num_bursts_rtl, read_bursts_arr_rtl, bank_ctrl_err_arr, col_ctrl_err_arr, bl_arr_rtl, rows_arr_rtl, bank_arr_rtl, start_col_arr_exp, col_err_arr_exp, col_err_arr_rtl, seed1, seed2);

			verify (num_bursts_exp, num_bursts_rtl, num_bursts_arr, bank_arr_exp, bank_arr_rtl, rows_arr_exp, rows_arr_rtl, bl_arr_exp, bl_arr_rtl, bank_ctrl_err_arr, col_ctrl_err_arr, start_col_arr_exp, read_bursts_arr_exp, read_bursts_arr_rtl, col_err_arr_exp, col_err_arr_rtl, file_pointer, pass);

			num_pass := num_pass + pass;

			wait until ((clk_tb'event) and (clk_tb = '1'));

		end loop;


		if (NUM_EXTRA_TEST > 0) then

		end if;

		file_close(file_pointer);

		file_open(file_pointer, summary_file, append_mode);
		write(file_line, string'( "PHY Command Controller => PASSES: " & integer'image(num_pass) & " out of " & integer'image(TOT_NUM_TEST)));
		writeline(file_pointer, file_line);

		if (num_pass = TOT_NUM_TEST) then
			write(file_line, string'( "PHY Command Controller: TEST PASSED"));
		else
			write(file_line, string'( "PHY Command Controller: TEST FAILED: " & integer'image(TOT_NUM_TEST-num_pass) & " failures"));
		end if;
		writeline(file_pointer, file_line);

		file_close(file_pointer);
		stop <= true;

	end process test;

end bench;
