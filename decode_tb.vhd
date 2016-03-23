library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.alu_pkg.all;
use work.pipeline_pkg.all;
use work.proc_pkg.all;
use work.tb_pkg.all;

entity decode_stage_tb is
end entity decode_stage_tb;

architecture bench of decode_stage_tb is

	constant CLK_PERIOD	: time := 10 ns;
	constant NUM_TEST	: integer := 1000;

	signal clk_tb	: std_logic := '0';
	signal stop	: boolean := false;
	signal rst_tb	: std_logic;

	signal INSTR_L_TB	: positive := 32;
	signal REG_NUM_TB	: positive := 16;
	signal REG_L_TB		: positive := 32;
	signal PC_L_TB		: positive := 32;
	signal STAT_REG_L_TB	: positive := 8;
	signal INCR_PC_TB	: positive := 4;
	signal CTRL_L_TB	: positive := 3;
	signal EN_REG_FILE_L_TB	: positive := 3;

	signal NewInstr_tb	: std_logic;
	signal Instr_tb		: std_logic_vector(INSTR_L_TB - 1 downto 0);

	signal PCIn_tb		: std_logic_vector(PC_L_TB - 1 downto 0);
	signal StatusRegIn_tb	: std_logic_vector(STAT_REG_L_TB - 1 downto 0);

	signal AddressIn_tb	: std_logic_vector(count_length(REG_NUM_TB) - 1 downto 0);
	signal AddressOut1_tb	: std_logic_vector(count_length(REG_NUM_TB) - 1 downto 0);
	signal AddressOut2_tb	: std_logic_vector(count_length(REG_NUM_TB) - 1 downto 0);
	signal Immediate_tb	: std_logic_vector(REG_L_TB - 1 downto 0);
	signal Enable_reg_file_tb	: std_logic_vector(EN_REG_FILE_L_TB - 1 downto 0);

	signal Done_tb		: std_logic;

	signal CmdALU_tb	: std_logic_vector(CMD_L - 1 downto 0);
	signal Ctrl_tb		: std_logic_vector(CTRL_L_TB - 1 downto 0);

	signal PCOut_tb		: std_logic_vector(PC_L_TB - 1 downto 0);

	signal EndOfProg_tb	: std_logic;

begin

	DUT: decode_stage generic map (
		INSTR_L => INSTR_L_TB,
		REG_NUM => REG_NUM_TB,
		REG_L => REG_L_TB,
		PC_L => PC_L_TB,
		STAT_REG_L => STAT_REG_L_TB,
		INCR_PC => INCR_PC_TB,
		CTRL_L => CTRL_L_TB,
		EN_REG_FILE_L => EN_REG_FILE_L_TB
	)
	port map (
		rst => rst_tb,
		clk => clk_tb,

		NewInstr => NewInstr_tb,
		Instr => Instr_tb,

		PCIn => PCin_tb,
		StatusRegIn => StatusRegIn_tb,

		AddressIn => AddressIn_tb,
		AddressOut1 => AddressOut1_tb,
		AddressOut2 => AddressOut2_tb,
		Immediate => Immediate_tb,
		Enable_reg_file => Enable_reg_file_tb,

		Done => Done_tb,

		CmdALU => CmdALU_tb,
		Ctrl => Ctrl_tb,

		PCOut => PCOut_tb,

		EndOfProg => EndOfProg_tb
	);

end bench;
