library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;
use work.execute_pkg.all;
use work.proc_pkg.all;
use work.tb_pkg.all;

entity alu_tb is
end entity alu_tb;

architecture bench of alu_tb is

	constant CLK_PERIOD	: time := 10 ns;
	constant NUM_TEST	: integer := 1000;

	signal clk_tb	: std_logic := '0';
	signal stop	: boolean := false;
	signal rst_tb	: std_logic;

	constant OP1_L_TB	: integer := 16;
	constant OP2_L_TB	: integer := 16;
	constant BASE_STACK_TB	: positive := 16#8000#;
	constant INSTR_L_TB		: positive := 32;
	constant REG_NUM_TB		: positive := 16;
	constant REG_L_TB		: positive := 32;
	constant ADDR_L_TB		: positive := 16;
	constant STAT_REG_L_TB	: positive := 8;
	constant EN_REG_FILE_L_TB	: positive := 3;
	constant OUT_REG_FILE_NUM_TB	: positive := 2;

	signal AddressRegFileIn_In_tb	: std_logic_vector(count_length(REG_NUM_TB) - 1 downto 0);
	signal AddressRegFileOut1_In_tb	: std_logic_vector(count_length(REG_NUM_TB) - 1 downto 0);
	signal AddressRegFileOut2_In_tb	: std_logic_vector(count_length(REG_NUM_TB) - 1 downto 0);
	signal Immediate_tb	: std_logic_vector(REG_L_TB - 1 downto 0);
	signal EnableRegFile_In_tb	: std_logic_vector(EN_REG_FILE_L_TB - 1 downto 0);

	signal CmdALU_In_tb	: std_logic_vector(ALU_CMD_L - 1 downto 0);
	signal CtrlCmd_tb	: std_logic_vector(CTRL_CMD_L - 1 downto 0);

	signal StatusRegOut_tb	: std_logic_vector(STAT_REG_L_TB - 1 downto 0);
	signal ResDbg_tb	: std_logic_vector(OP1_L_TB - 1 downto 0); -- debug signal
	signal Start_tb	: std_logic;
	signal Done_tb	: std_logic;

	type reg_file_array is array(0 to REG_NUM_TB) of integer;

begin

	DUT: execute_stage generic map(
		OP1_L => OP1_L_TB,
		OP2_L => OP2_L_TB,
		BASE_STACK => BASE_STACK_TB,
		INSTR_L => INSTR_L_TB,
		REG_NUM => REG_NUM_TB,
		REG_L => REG_L_TB,
		ADDR_L => ADDR_L_TB,
		STAT_REG_L => STAT_REG_L_TB,
		EN_REG_FILE_L => EN_REG_FILE_L_TB,
		OUT_REG_FILE_NUM => OUT_REG_FILE_NUM_TB
	)
	port map (
		rst => rst_tb,
		clk => clk_tb,
		Start => Start_tb,
		Done => Done_tb,
		AddressRegFileIn_In => AddressRegFileIn_In_tb,
		AddressRegFileOut1_In => AddressRegFileOut1_In_tb,
		AddressRegFileOut2_In => AddressRegFileOut2_In_tb,
		Immediate => Immediate_tb,
		EnableRegFile_In => EnableRegFile_In_tb,

		CmdALU_In => CmdALU_In_tb,
		CtrlCmd => CtrlCmd_tb,

		StatusRegOut => StatusRegOut,

		ResDbg => ResDbg_tb
	);

	clk_tb <= not clk_tb after CLK_PERIOD/2 when not stop;

	test: process

		procedure reset(variable RegFileOut_int : out reg_file_array) is
		begin
			rst_tb <= '0';
			wait until rising_edge(clk_tb);
			rst_tb <= '1';
			AddressRegFileIn_In_tb <= (others => '0');
			AddressRegFileOut1_In_tb <= (others => '0');
			AddressRegFileOut2_In_tb <= (others => '0');
			Immediate_tb <= (others => '0');
			EnableRegFile_tb <= (others => '0');
			RegFileOut_int := (others => 0);
			Start_tb <= '0';
			wait until rising_edge(clk_tb);
			rst_tb <= '0';
		end procedure reset;

		procedure push_op(variable AddressIn_int, AddressOut1_int, AddressOut2_int : out integer; variable Immediate_int: out integer; variable CmdALU: out std_logic_vector(ALU_CMD_L-1 downto 0); variable CtrlCmd: out std_logic_vector(CMD_CTRL_L-1 downto 0); variable EnableRegFile_vec: out std_logic_vector(EM_REG_FILE_L_TB-1 downto 0); variable seed1, seed2: inout positive) is
			variable AddressIn_in, AddressOut1_in, AddressOut2_in, CmdALU_in, CtrlCmd_in, EnableRegFile_in	: integer;
			variable rand_val, sign_val	: real;
			variable CmdALU_int: std_logic_vector(ALU_CMD_L-1 downto 0);
			variable CtrlCmd_int: std_logic_vector(CMD_CTRL_L-1 downto 0);
		begin
			uniform(seed1, seed2, rand_val);
			CmdALU_in := integer(rand_val*(2.0**(real(ALU_CMD_L)) - 1.0));
			CmdALU_In_tb <= std_logic_vector(to_unsigned(CmdALU_in, ALU_CMD_L));
			CmdALU := std_logic_vector(to_unsigned(CmdALU_in, ALU_CMD_L));
			CmdALU_int := std_logic_vector(to_unsigned(CmdALU_in, ALU_CMD_L));

			uniform(seed1, seed2, rand_val);
			CtrlCmd_in := integer(rand_val*(2.0**(real(CMD_CTRL_L)) - 1.0));
			CtrlCmd_tb <= std_logic_vector(to_unsigned(CtrlCmd_in, CMD_CTRL_L));
			CtrlCmd := std_logic_vector(to_unsigned(CtrlCmd_in, CMD_CTRL_L));
			CtrlCmd_int := std_logic_vector(to_unsigned(CtrlCmd_in, CMD_CTRL_L));

			uniform(seed1, seed2, rand_val);
			Immediate_in := integer(rand_val*(2.0**(real(REG_L_TB)) - 1.0));
			Immediate_tb <= std_logic_vector(to_unsigned(Immediate_in, REG_L_TB));
			Immediate_int := std_logic_vector(to_unsigned(Immediate_in, REG_L_TB));

			uniform(seed1, seed2, rand_val);
			AddressIn_in := integer(rand_val*(2.0**(real(count_length(REG_NUM_TB))) - 1.0));
			AddressIn_In_tb <= std_logic_vector(to_unsigned(AddressIn_in, count_length(REG_NUM_TB)));
			AddressIn_int := std_logic_vector(to_unsigned(AddressIn_in, count_length(REG_NUM_TB)));

			uniform(seed1, seed2, rand_val);
			AddressOut1_in := integer(rand_val*(2.0**(real(count_length(REG_NUM_TB))) - 1.0));
			AddressOut1_In_tb <= std_logic_vector(to_unsigned(AddressOut1_in, count_length(REG_NUM_TB)));
			AddressOut1_int := std_logic_vector(to_unsigned(AddressOut1_in, count_length(REG_NUM_TB)));

			uniform(seed1, seed2, rand_val);
			AddressOut2_in := integer(rand_val*(2.0**(real(count_length(REG_NUM_TB))) - 1.0));
			AddressOut2_In_tb <= std_logic_vector(to_unsigned(AddressOut2_in, count_length(REG_NUM_TB)));
			AddressOut2_int := std_logic_vector(to_unsigned(AddressOut2_in, count_length(REG_NUM_TB)));

			if (CtrlCmd_in = CTRL_CMD_ALU) then
				uniform(seed1, seed2, rand_val);
				EnableRegFile_in := std_logic_vector(to_unsigned(integer(rand_sign(rand_val)))) & "11";
				EnableRegFile_In_tb <= EnableRegFile_in;
			elsif (CtrlCmd_in = CTRL_CMD_MOV) then
 				uniform(seed1, seed2, rand_val);
				EnableRgFile_in := integer(rand_val*(2.0**(real(OUT_REG_FILE_NUM_TB)) - 1.0));
				EnableRegFile_In_tb <= std_logic_vector(to_unsigned(EnableRegFile_in, OUT_REG_FILE_NUM_TB)) & "1";
				EnableRegFile_vec := std_logic_vector(to_unsigned(EnableRegFile_in, OUT_REG_FILE_NUM_TB)) & "1";
			elsif (CtrlCmd_in = CTRL_CMD_WR_M) or (CtrlCmd_in = CTRL_CMD_WR_S) then
				EnableRegFile_In_tb <= "010";
				EnableRegFile_vec := "010";
			else -- (CtrlCmd_in = CTRL_CMD_RD_M) or (CtrlCmd_in = CTRL_CMD_RD_S)
				EnableRegFile_In_tb <= "001";
				EnableRegFile_vec := "001";
			end if;

			Start_tb <= '1';

			wait until rising_edge(clk_tb);
			Start_tb <= '0';
		end procedure push_op;

		variable RegFileOut, RegFileIn	: reg_file_array;

		variable pass	: integer;
		variable num_pass	: integer;

		file file_pointer	: text;
		variable file_line	: line;

	begin

		wait for 1 ns;

		num_pass := 0;

		reset;
		file_open(file_pointer, log_file, append_mode);

		write(file_line, string'( "ALU Test"));
		writeline(file_pointer, file_line);

		for i in 0 to NUM_TEST-1 loop
			num_pass := num_pass + pass;

			wait until rising_edge(clk_tb);
		end loop;

		file_close(file_pointer);

		file_open(file_pointer, summary_file, append_mode);
		write(file_line, string'( "EXECUTE STAGE => PASSES: " & integer'image(num_pass) & " out of " & integer'image(NUM_TEST)));
		writeline(file_pointer, file_line);

		file_close(file_pointer);
		stop <= true;

	end process test;

end bench;
