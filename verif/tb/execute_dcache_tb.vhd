library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;
use work.proc_pkg.all;
use work.execute_dcache_pkg.all;
use work.ctrl_pkg.all;
use work.alu_pkg.all;
use work.tb_pkg.all;
use work.alu_pkg_tb.all;
use work.ctrl_pkg_tb.all;
use work.reg_file_pkg_tb.all;
use work.execute_pkg_tb.all;

entity execute_dcache_tb is
end entity execute_dcache_tb;

architecture bench of execute_dcache_tb is

	constant CLK_PERIOD	: time := PROC_CLK_PERIOD * 1 ns;
	constant NUM_TEST	: integer := 10000;

	signal clk_tb	: std_logic := '0';
	signal stop	: boolean := false;
	signal rst_tb	: std_logic;

	constant BASE_STACK_TB	: positive := 16#8000#;
	constant ADDR_L_TB		: positive := 16;
	constant OUT_REG_FILE_NUM_TB	: positive := 2;

	signal AddressRegFileIn_In_tb	: std_logic_vector(int_to_bit_num(REG_NUM_TB) - 1 downto 0);
	signal AddressRegFileOut1_In_tb	: std_logic_vector(int_to_bit_num(REG_NUM_TB) - 1 downto 0);
	signal AddressRegFileOut2_In_tb	: std_logic_vector(int_to_bit_num(REG_NUM_TB) - 1 downto 0);
	signal Immediate_tb	: std_logic_vector(DATA_L - 1 downto 0);
	signal EnableRegFile_In_tb	: std_logic_vector(EN_REG_FILE_L_TB - 1 downto 0);

	signal CmdALU_In_tb	: std_logic_vector(CMD_ALU_L - 1 downto 0);
	signal CtrlCmd_tb	: std_logic_vector(CTRL_CMD_L - 1 downto 0);

	signal StatusRegOut_tb	: std_logic_vector(STAT_REG_L_TB - 1 downto 0);
	signal ResDbg_tb	: std_logic_vector(OP1_L_TB - 1 downto 0); -- debug signal
	signal Start_tb	: std_logic;
	signal Endrst_tb	: std_logic;
	signal Done_tb	: std_logic;

begin

	DUT: execute_dcache generic map(
		OP1_L => OP1_L_TB,
		OP2_L => OP2_L_TB,
		BASE_STACK => BASE_STACK_TB,
		REG_NUM => REG_NUM_TB,
		ADDR_L => ADDR_L_TB,
		STAT_REG_L => STAT_REG_L_TB,
		EN_REG_FILE_L => EN_REG_FILE_L_TB,
		OUT_REG_FILE_NUM => OUT_REG_FILE_NUM_TB
	)
	port map (
		rst => rst_tb,
		clk => clk_tb,
		Start => Start_tb,
		Endrst => Endrst_tb,
		Done => Done_tb,
		AddressRegFileIn_In => AddressRegFileIn_In_tb,
		AddressRegFileOut1_In => AddressRegFileOut1_In_tb,
		AddressRegFileOut2_In => AddressRegFileOut2_In_tb,
		Immediate => Immediate_tb,
		EnableRegFile_In => EnableRegFile_In_tb,

		CmdALU_In => CmdALU_In_tb,
		CtrlCmd => CtrlCmd_tb,

		StatusRegOut => StatusRegOut_tb,

		ResDbg => ResDbg_tb
	);

	clk_gen(CLK_PERIOD, 0 ns, stop, clk_tb);

	test: process

		procedure reset(variable RegFileOut_int : out reg_file_array; variable StatusRegOut_int : out integer) is
		begin
			rst_tb <= '0';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_tb <= '1';
			AddressRegFileIn_In_tb <= (others => '0');
			AddressRegFileOut1_In_tb <= (others => '0');
			AddressRegFileOut2_In_tb <= (others => '0');
			Immediate_tb <= (others => '0');
			EnableRegFile_In_tb <= (others => '0');
			RegFileOut_int := (others => 0);
			StatusRegOut_int := 0;
			Start_tb <= '0';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_tb <= '0';

			wait on EndRst_tb;

			wait until ((clk_tb'event) and (clk_tb = '1'));
		end procedure reset;

		procedure push_op(variable AddressIn_int, AddressOut1_int, AddressOut2_int : out integer; variable Immediate_int: out integer; variable CmdALU: out std_logic_vector(CMD_ALU_L-1 downto 0); variable CtrlCmd: out std_logic_vector(CTRL_CMD_L-1 downto 0); variable EnableRegFile_vec: out std_logic_vector(EN_REG_FILE_L_TB-1 downto 0); variable seed1, seed2: inout positive) is
			variable AddressIn_in, AddressOut1_in, AddressOut2_in, CmdALU_in, CtrlCmd_in, EnableRegFile2_in, Immediate_in	: integer;
			variable EnableRegFile_in	: boolean;
			variable rand_val, sign_val	: real;
			variable CmdALU_int: std_logic_vector(CMD_ALU_L-1 downto 0);
			variable CtrlCmd_int: std_logic_vector(CTRL_CMD_L-1 downto 0);
		begin
			uniform(seed1, seed2, rand_val);
			CmdALU_in := integer(rand_val*(2.0**(real(CMD_ALU_L)) - 1.0));
			CmdALU_In_tb <= std_logic_vector(to_unsigned(CmdALU_in, CMD_ALU_L));
			CmdALU := std_logic_vector(to_unsigned(CmdALU_in, CMD_ALU_L));
			CmdALU_int := std_logic_vector(to_unsigned(CmdALU_in, CMD_ALU_L));

			uniform(seed1, seed2, rand_val);
			CtrlCmd_in := integer(rand_val*(2.0**(real(CTRL_CMD_L)) - 1.0));
			CtrlCmd_tb <= std_logic_vector(to_unsigned(CtrlCmd_in, CTRL_CMD_L));
			CtrlCmd := std_logic_vector(to_unsigned(CtrlCmd_in, CTRL_CMD_L));
			CtrlCmd_int := std_logic_vector(to_unsigned(CtrlCmd_in, CTRL_CMD_L));

			uniform(seed1, seed2, rand_val);
			Immediate_in := integer(rand_val*(2.0**(real(DATA_L)) - 1.0));
			Immediate_tb <= std_logic_vector(to_unsigned(Immediate_in, DATA_L));
			Immediate_int := Immediate_in;

			uniform(seed1, seed2, rand_val);
			AddressIn_in := integer(rand_val*(2.0**(real(int_to_bit_num(REG_NUM_TB))) - 1.0));
			AddressRegFileIn_In_tb <= std_logic_vector(to_unsigned(AddressIn_in, int_to_bit_num(REG_NUM_TB)));
			AddressIn_int := AddressIn_in;

			uniform(seed1, seed2, rand_val);
			AddressOut1_in := integer(rand_val*(2.0**(real(int_to_bit_num(REG_NUM_TB))) - 1.0));
			AddressRegFileOut1_In_tb <= std_logic_vector(to_unsigned(AddressOut1_in, int_to_bit_num(REG_NUM_TB)));
			AddressOut1_int := AddressOut1_in;

			uniform(seed1, seed2, rand_val);
			AddressOut2_in := integer(rand_val*(2.0**(real(int_to_bit_num(REG_NUM_TB))) - 1.0));
			AddressRegFileOut2_In_tb <= std_logic_vector(to_unsigned(AddressOut2_in, int_to_bit_num(REG_NUM_TB)));
			AddressOut2_int := AddressOut2_in;

			if (CtrlCmd_in = to_integer(unsigned(CTRL_CMD_ALU))) then
				uniform(seed1, seed2, rand_val);
				EnableRegFile_in := rand_bool(rand_val);
				EnableRegFile_vec(2) := bool_to_std_logic(EnableRegFile_in);
				EnableRegFile_vec(1 downto 0) := "11";
				EnableRegFile_In_tb(2) <= bool_to_std_logic(EnableRegFile_in);
				EnableRegFile_In_tb(1 downto 0) <= "11";
			elsif (CtrlCmd_in = to_integer(unsigned(CTRL_CMD_MOV))) then
				uniform(seed1, seed2, rand_val);
				EnableRegFile2_in := integer(rand_val*(2.0**(real(OUT_REG_FILE_NUM_TB)) - 1.0));
				EnableRegFile_In_tb <= std_logic_vector(to_unsigned(EnableRegFile2_in, OUT_REG_FILE_NUM_TB)) & "1";
				EnableRegFile_vec := std_logic_vector(to_unsigned(EnableRegFile2_in, OUT_REG_FILE_NUM_TB)) & "1";
			elsif (CtrlCmd_in = to_integer(unsigned(CTRL_CMD_WR_M))) or (CtrlCmd_in = to_integer(unsigned(CTRL_CMD_WR_S))) then
				EnableRegFile_In_tb <= "010";
				EnableRegFile_vec := "010";
			else -- (CtrlCmd_in = to_integer(unsigned(CTRL_CMD_RD_M))) or (CtrlCmd_in = to_integer(unsigned(CTRL_CMD_RD_S)))
				EnableRegFile_In_tb <= "001";
				EnableRegFile_vec := "001";
			end if;

			Start_tb <= '1';

			wait until ((clk_tb'event) and (clk_tb = '1'));
			Start_tb <= '0';
		end procedure push_op;

		procedure verify (variable Op1_int, Op2_int: in integer; variable AddressIn_int, AddressOut1_int, AddressOut2_int : in integer; variable Immediate_int : in integer; variable EnRegFile_int : in integer; variable CtrlCmd : std_logic_vector(CTRL_CMD_L - 1 downto 0); variable CtrlCmd_str, ALUCmd_str : string; variable ResOp_ideal : in integer; variable StatusReg_ideal : in integer; variable ResOp_rtl : in integer; variable StatusReg_rtl : in integer; variable pass : out integer; file file_pointer : text) is
			variable file_line	: line;
		begin

			if (CtrlCmd = CTRL_CMD_ALU) then
				write(file_line, string'( "Ctrl cmd " & CtrlCmd_str & " and ALU cmd " & ALUCmd_str & " with operands " & integer'image(Op1_int) & " at address " & integer'image(AddressOut1_int) & " and " & integer'image(Op2_int) & " at address " & integer'image(AddressOut2_int) & " and result stored at address " & integer'image(AddressIn_int) & " and immediate value " & integer'image(Immediate_int) & " Register File access " & integer'image(EnRegFile_int) & " gives: RTL result " & integer'image(ResOp_rtl) & " Status Register " & integer'image(StatusReg_rtl) & " and reference Result " & integer'image(ResOp_ideal) & " Status Register " & integer'image(StatusReg_ideal)));
			else
				write(file_line, string'( "Ctrl cmd " & CtrlCmd_str & " accessing address " & integer'image(AddressOut1_int) & " for reading out and " & integer'image(AddressIn_int) & " for storing and immediate value " & integer'image(Immediate_int) & " Register File access " & integer'image(EnRegFile_int) & " gives: RTL result " & integer'image(ResOp_rtl) & " Status Register " & integer'image(StatusReg_rtl) & " and reference Result " & integer'image(ResOp_ideal) & " Status Register " & integer'image(StatusReg_ideal)));
			end if;
			writeline(file_pointer, file_line);

			if (ResOp_rtl = ResOp_ideal) and (StatusReg_ideal = StatusReg_rtl) then
				write(file_line, string'("PASS"));
				pass := 1;
			elsif (StatusReg_ideal = StatusReg_rtl) then
				write(file_line, string'("FAIL (Wrong status register)"));
				pass := 0;
			elsif (ResOp_rtl = ResOp_ideal) then
				write(file_line, string'("FAIL (Wrong result)"));
				pass := 0;
			else
				write(file_line, string'("FAIL (Wrong result and status register)"));
				pass := 0;
			end if;
			writeline(file_pointer, file_line);

		end procedure verify;

		variable AddressIn_int, AddressOut1_int, AddressOut2_int	: integer; 
		variable Immediate_int	: integer; 
		variable CmdALU		: std_logic_vector(CMD_ALU_L-1 downto 0);
		variable CtrlCmd	: std_logic_vector(CTRL_CMD_L-1 downto 0);
		variable EnableRegFile_vec	: std_logic_vector(EN_REG_FILE_L_TB-1 downto 0);
		variable EnableRegFile_int	: integer;

		variable Op1, Op2	: integer;
		variable StatusReg_ideal, StatusReg_rtl, StatusRegIn_int : integer;
		variable ResOp_ideal, ResOp_rtl	: integer;

		variable seed1, seed2	: positive;

		variable RegFileOut_int, RegFileIn_int	: reg_file_array;

		variable pass	: integer;
		variable num_pass	: integer;

		file file_pointer	: text;
		variable file_line	: line;

	begin

		wait for 1 ns;

		num_pass := 0;

		reset(RegFileOut_int, StatusReg_ideal);
		file_open(file_pointer, log_file, append_mode);

		write(file_line, string'( "Execute stage with dcache Test"));
		writeline(file_pointer, file_line);

		for i in 0 to NUM_TEST-1 loop

			RegFileIn_int := RegFileOut_int;
			StatusRegIn_int := StatusReg_ideal;

			push_op(AddressIn_int, AddressOut1_int, AddressOut2_int, Immediate_int, CmdALU, CtrlCmd, EnableRegFile_vec, seed1, seed2);

			wait on Done_tb;

			ResOp_rtl := to_integer(unsigned(ResDbg_tb));

			StatusReg_rtl := to_integer(unsigned(StatusRegOut_tb));

			execute_ref(AddressIn_int, AddressOut1_int, AddressOut2_int, Immediate_int, CmdALU, CtrlCmd, EnableRegFile_vec, RegFileIn_int, RegFileOut_int, Op1, Op2, StatusRegIn_int, StatusReg_ideal, ResOp_ideal);

			EnableRegFile_int := to_integer(unsigned(EnableRegFile_vec));

			verify (Op1, Op2, AddressIn_int, AddressOut1_int, AddressOut2_int, Immediate_int, EnableRegFile_int, CtrlCmd, ctrl_cmd_std_vect_to_txt(CtrlCmd), full_alu_cmd_std_vect_to_txt(CmdALU), ResOp_ideal, StatusReg_ideal, ResOp_rtl, StatusReg_rtl, pass, file_pointer);

			num_pass := num_pass + pass;

			wait until ((clk_tb'event) and (clk_tb = '1'));
		end loop;

		file_close(file_pointer);

		file_open(file_pointer, summary_file, append_mode);
		write(file_line, string'( "EXECUTE STAGE WITH DCACHE => PASSES: " & integer'image(num_pass) & " out of " & integer'image(NUM_TEST)));
		writeline(file_pointer, file_line);

		if (num_pass = NUM_TEST) then
			write(file_line, string'( "EXECUTE STAGE WITH DCACHE: TEST PASSED"));
		else
			write(file_line, string'( "EXECUTE STAGE WITH DCACHE: TEST FAILED: " & integer'image(NUM_TEST-num_pass) & " failures"));
		end if;
		writeline(file_pointer, file_line);

		file_close(file_pointer);
		stop <= true;

	end process test;

end bench;
