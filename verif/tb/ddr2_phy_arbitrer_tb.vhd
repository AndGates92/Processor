library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;
use work.proc_pkg.all;
use work.ddr2_define_pkg.all;
use work.ddr2_phy_pkg.all;
use work.ddr2_phy_bank_ctrl_pkg.all;
use work.tb_pkg.all;
use work.ddr2_pkg_tb.all;

entity ddr2_phy_bank_ctrl_tb is
end entity ddr2_phy_bank_ctrl_tb;

architecture bench of ddr2_phy_bank_ctrl_tb is

	constant CLK_PERIOD	: time := DDR2_CLK_PERIOD * 1 ns;
	constant NUM_TEST	: integer := 1000;
	constant NUM_EXTRA_TEST	: integer := MAX_OUTSTANDING_BURSTS_TB;
	constant TOT_NUM_TEST	: integer := NUM_TEST + NUM_EXTRA_TEST;

	constant MAX_REQUESTS_PER_TEST		: integer := 50;

	signal clk_tb	: std_logic := '0';
	signal stop	: boolean := false;
	signal rst_tb	: std_logic;

	-- Bank Controllers
	signal BankCtrlBankMem_tb	: std_logic_vector(BANK_CTRL_NUM_TB*(int_to_bit_num(BANK_NUM_TB)) - 1 downto 0);
	signal BankCtrlRowMem_tb	: std_logic_vector(BANK_CTRL_NUM_TB*ROW_L_TB - 1 downto 0);
	signal BankCtrlCmdMem_tb	: std_logic_vector(BANK_CTRL_NUM_TB*MEM_CMD_L - 1 downto 0);
	signal BankCtrlCmdReq_tb	: std_logic_vector(BANK_CTRL_NUM_TB - 1 downto 0);

	signal BankCtrlCmdAck_tb	: std_logic_vector(BANK_CTRL_NUM_TB - 1 downto 0);

	-- Column Controller
	signal ColCtrlColMem_tb		: std_logic_vector(COL_CTRL_NUM_TB*COL_L_TB - 1 downto 0);
	signal ColCtrlBankMem_tb	: std_logic_vector(COL_CTRL_NUM_TB*(int_to_bit_num(BANK_NUM_TB)) - 1 downto 0);
	signal ColCtrlCmdMem_tb		: std_logic_vector(COL_CTRL_NUM_TB*MEM_CMD_L - 1 downto 0);
	signal ColCtrlCmdReq_tb		: std_logic_vector(COL_CTRL_NUM_TB - 1 downto 0);

	signal ColCtrlCmdAck_tb		: std_logic_vector(COL_CTRL_NUM_TB - 1 downto 0);

	-- Refresh Controller
	signal RefCtrlCmdMem_tb		: std_logic_vector(REF_CTRL_NUM_TB*MEM_CMD_L - 1 downto 0);
	signal RefCtrlCmdReq_tb		: std_logic_vector(REF_CTRL_NUM_TB - 1 downto 0);

	signal RefCtrlCmdAck_tb		: std_logic_vector(REF_CTRL_NUM_TB - 1 downto 0);

	-- Arbitrer Controller
	signal AllowBankActivate_tb	: std_logic;

	signal BankActOut_tb		: std_logic;

	-- Command Decoder
	signal CmdDecColMem_tb		: std_logic_vector(COL_L_TB - 1 downto 0);
	signal CmdDecRowMem_tb		: std_logic_vector(ROW_L_TB - 1 downto 0);
	signal CmdDecBankMem_tb		: std_logic_vector(int_to_bit_num(BANK_NUM_TB) - 1 downto 0);
	signal CmdDecCmdMem_tb		: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal CmdDecMRSCmd_tb		: std_logic_vector(ADDR_L_TB - 1 downto 0);

begin

	DUT: ddr2_phy_bank_ctrl generic map (
		ROW_L => ROW_L_TB,
		COL_L => COL_L_TB,
		ADDR_L => ADDR_L_TB,
		BANK_NUM => BANK_NUM_TB,
		BANK_CTRL_NUM => BANK_CTRL_NUM_TB,
		COL_CTRL_NUM => COL_CTRL_NUM_TB,
		REF_CTRL_NUM => REF_CTRL_NUM_TB
	)
	port map (
		clk => clk_tb,
		rst => rst_tb,

		-- Bank Controllers
		BankCtrlBankMem => BankCtrlBankMem_tb,
		BankCtrlRowMem => BankCtrlRowMem_tb,
		BankCtrlCmdMem => BankCtrlCmdMem_tb,
		BankCtrlCmdReq => BankCtrlCmdReq_tb,

		BankCtrlCmdAck => BankCtrlCmdAck_tb,

		-- Column Controller
		ColCtrlColMem => ColCtrlColMem_tb,
		ColCtrlBankMem => ColCtrlBankMem_tb,
		ColCtrlCmdMem => ColCtrlCmdMem_tb,
		ColCtrlCmdReq => ColCtrlCmdReq_tb,

		ColCtrlCmdAck => ColCtrlCmdAck_tb,

		-- Refresh Controller
		RefCtrlCmdMem => RefCtrlCmdMem_tb,
		RefCtrlCmdReq => RefCtrlCmdReq_tb,

		RefCtrlCmdAck => RefCtrlCmdAck_tb,

		-- Arbitrer Controller
		AllowBankActivate => AllowBankActivate_tb,

		BankActOut => BankActOut_tb,

		-- Command Decoder
		CmdDecColMem => CmdDecColMem_tb,
		CmdDecRowMem => CmdDecRowMem_tb,
		CmdDecBankMem => CmdDecBankMem_tb,
		CmdDecCmdMem => CmdDecCmdMem_tb,
		CmdDecMRSCmd => CmdDecMRSCmd_tb

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

		procedure test_param(variable num_requests : out integer; variable bank_ctrl_bank, bank_ctrl_row, bank_ctrl_cmd : out int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (BANK_CTRL_NUM_TB - 1)); variable bank_ctrl_cmd_req : out bool_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (BANK_CTRL_NUM_TB - 1)); variable col_ctrl_bank, col_ctrl_col, col_ctrl_cmd : out int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (COL_CTRL_NUM_TB - 1)); variable col_ctrl_cmd_req : out bool_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (COL_CTRL_NUM_TB - 1)); variable ref_ctrl_cmd : out int_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (REF_CTRL_NUM_TB - 1)); variable ref_ctrl_cmd_req : out bool_arr_2d(0 to (MAX_REQUESTS_PER_TEST - 1), 0 to (REF_CTRL_NUM_TB - 1));) is
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
				for j in 0 to (BANK_CTRL_NUM_TB - 1) loop
					uniform(seed1, seed2, rand_val);
					bank_ctrl_bank(i, j) := integer(rand_val*real(BANK_NUM_TB - 1));
					uniform(seed1, seed2, rand_val);
					bank_ctrl_row(i, j) := integer(rand_val*real(2.0**(real(ROW_L_TB))));
					bank_ctrl_cmd(i, j) := to_integer(unsigned(CMD_BANK_ACT));
					uniform(seed1, seed2, rand_val);
					bank_ctrl_cmd_req(i, j) := rand_bool(rand_val, 0.5);
				end loop;

				for j in 0 to (COL_CTRL_NUM_TB - 1) loop
					uniform(seed1, seed2, rand_val);
					col_ctrl_bank(i, j) := integer(rand_val*real(BANK_NUM_TB - 1));
					uniform(seed1, seed2, rand_val);
					col_ctrl_col(i, j) := integer(rand_val*real(2.0**(real(COL_L_TB))));
					uniform(seed1, seed2, rand_val);
					col_cmd_id := integer(3.0*rand_val);
					if (col_cmd_id = 0) then
						col_ctrl_cmd(i, j) := to_integer(unsigned(CMD_WRITE));
					elsif (col_cmd_id = 1) then
						col_ctrl_cmd(i, j) := to_integer(unsigned(CMD_READ));
					elsif (col_cmd_id = 2) then
						col_ctrl_cmd(i, j) := to_integer(unsigned(CMD_WRITE_PRECHARGE));
					elsif (col_cmd_id = 3) then
						col_ctrl_cmd(i, j) := to_integer(unsigned(CMD_READ_PRECHARGE));
					else
						col_ctrl_cmd(i, j) := to_integer(unsigned(CMD_NOP));
					end if;
					uniform(seed1, seed2, rand_val);
					col_ctrl_cmd_req(i, j) := rand_bool(rand_val, 0.5);
				end loop;

				for j in 0 to (REF_CTRL_NUM_TB - 1) loop
					uniform(seed1, seed2, rand_val);
					ref_cmd_id := integer(2.0*rand_val);
					if (ref_cmd_id = 0) then
						ref_ctrl_cmd(i, j) := to_integer(unsigned(CMD_AUTO_REF));
					elsif (ref_cmd_id = 1) then
						ref_ctrl_cmd(i, j) := to_integer(unsigned(CMD_SELF_REF_ENTRY));
					elsif (ref_cmd_id = 2) then
						ref_ctrl_cmd(i, j) := to_integer(unsigned(CMD_SELF_REF_EXIT));
					else
						ref_ctrl_cmd(i, j) := to_integer(unsigned(CMD_NOP));
					end if;
					uniform(seed1, seed2, rand_val);
					ref_ctrl_cmd_req(i, j) := rand_bool(rand_val, 0.5);
				end loop;
			end loop;

		end procedure test_param;



end bench;
