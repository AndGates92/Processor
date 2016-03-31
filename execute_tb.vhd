library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;
use work.execute_pkg.all;
use work.proc_pkg.all;
use work.ctrl_pkg.all;
use work.alu_pkg.all;
use work.tb_pkg.all;

entity execute_tb is
end entity execute_tb;

architecture bench of execute_tb is

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
	constant REG_L_TB		: positive := 16;
	constant ADDR_L_TB		: positive := 16;
	constant STAT_REG_L_TB	: positive := 8;
	constant EN_REG_FILE_L_TB	: positive := 3;
	constant OUT_REG_FILE_NUM_TB	: positive := 2;

	signal AddressRegFileIn_In_tb	: std_logic_vector(count_length(REG_NUM_TB) - 1 downto 0);
	signal AddressRegFileOut1_In_tb	: std_logic_vector(count_length(REG_NUM_TB) - 1 downto 0);
	signal AddressRegFileOut2_In_tb	: std_logic_vector(count_length(REG_NUM_TB) - 1 downto 0);
	signal Immediate_tb	: std_logic_vector(REG_L_TB - 1 downto 0);
	signal EnableRegFile_In_tb	: std_logic_vector(EN_REG_FILE_L_TB - 1 downto 0);

	signal CmdALU_In_tb	: std_logic_vector(CMD_ALU_L - 1 downto 0);
	signal CtrlCmd_tb	: std_logic_vector(CTRL_CMD_L - 1 downto 0);

	signal StatusRegOut_tb	: std_logic_vector(STAT_REG_L_TB - 1 downto 0);
	signal ResDbg_tb	: std_logic_vector(OP1_L_TB - 1 downto 0); -- debug signal
	signal Start_tb	: std_logic;
	signal Done_tb	: std_logic;

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

		StatusRegOut => StatusRegOut_tb,

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
			EnableRegFile_In_tb <= (others => '0');
			RegFileOut_int := (others => 0);
			Start_tb <= '0';
			wait until rising_edge(clk_tb);
			rst_tb <= '0';
		end procedure reset;

		procedure push_op(variable AddressIn_int, AddressOut1_int, AddressOut2_int : out integer; variable Immediate_int: out integer; variable CmdALU: out std_logic_vector(CMD_ALU_L-1 downto 0); variable CtrlCmd: out std_logic_vector(CTRL_CMD_L-1 downto 0); variable EnableRegFile_vec: out std_logic_vector(EN_REG_FILE_L_TB-1 downto 0); variable seed1, seed2: inout positive) is
			variable AddressIn_in, AddressOut1_in, AddressOut2_in, CmdALU_in, CtrlCmd_in, EnableRegFile_in, Immediate_in	: integer;
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
			Immediate_in := integer(rand_val*(2.0**(real(REG_L_TB)) - 1.0));
			Immediate_tb <= std_logic_vector(to_unsigned(Immediate_in, REG_L_TB));
			Immediate_int := Immediate_in;

			uniform(seed1, seed2, rand_val);
			AddressIn_in := integer(rand_val*(2.0**(real(count_length(REG_NUM_TB))) - 1.0));
			AddressRegFileIn_In_tb <= std_logic_vector(to_unsigned(AddressIn_in, count_length(REG_NUM_TB)));
			AddressIn_int := AddressIn_in;

			uniform(seed1, seed2, rand_val);
			AddressOut1_in := integer(rand_val*(2.0**(real(count_length(REG_NUM_TB))) - 1.0));
			AddressRegFileOut1_In_tb <= std_logic_vector(to_unsigned(AddressOut1_in, count_length(REG_NUM_TB)));
			AddressOut1_int := AddressOut1_in;

			uniform(seed1, seed2, rand_val);
			AddressOut2_in := integer(rand_val*(2.0**(real(count_length(REG_NUM_TB))) - 1.0));
			AddressRegFileOut2_In_tb <= std_logic_vector(to_unsigned(AddressOut2_in, count_length(REG_NUM_TB)));
			AddressOut2_int := AddressOut2_in;

			if (CtrlCmd_in = to_integer(unsigned(CTRL_CMD_ALU))) then
				uniform(seed1, seed2, rand_val);
				EnableRegFile_in := integer(rand_bin(rand_val));
				EnableRegFile_vec := std_logic_vector(to_unsigned(EnableRegFile_in,1)) & "11";
				EnableRegFile_In_tb <= std_logic_vector(to_unsigned(EnableRegFile_in,1)) & "11";
			elsif (CtrlCmd_in = to_integer(unsigned(CTRL_CMD_MOV))) then
 				uniform(seed1, seed2, rand_val);
				EnableRegFile_in := integer(rand_val*(2.0**(real(OUT_REG_FILE_NUM_TB)) - 1.0));
				EnableRegFile_In_tb <= std_logic_vector(to_unsigned(EnableRegFile_in, OUT_REG_FILE_NUM_TB)) & "1";
				EnableRegFile_vec := std_logic_vector(to_unsigned(EnableRegFile_in, OUT_REG_FILE_NUM_TB)) & "1";
			elsif (CtrlCmd_in = to_integer(unsigned(CTRL_CMD_WR_M))) or (CtrlCmd_in = to_integer(unsigned(CTRL_CMD_WR_S))) then
				EnableRegFile_In_tb <= "010";
				EnableRegFile_vec := "010";
			else -- (CtrlCmd_in = to_integer(unsigned(CTRL_CMD_RD_M))) or (CtrlCmd_in = to_integer(unsigned(CTRL_CMD_RD_S)))
				EnableRegFile_In_tb <= "001";
				EnableRegFile_vec := "001";
			end if;

			Start_tb <= '1';

			wait until rising_edge(clk_tb);
			Start_tb <= '0';
		end procedure push_op;

		procedure execute_ref(variable AddressIn_int, AddressOut1_int, AddressOut2_int : in integer; variable Immediate_int: in integer; variable CmdALU: in std_logic_vector(CMD_ALU_L-1 downto 0); variable CtrlCmd: in std_logic_vector(CTRL_CMD_L-1 downto 0); variable EnableRegFile_vec: in std_logic_vector(EN_REG_FILE_L_TB-1 downto 0); variable RegFileIn_int : in reg_file_array; variable RegFileOut_int : out reg_file_array; variable Op1, Op2 : out integer; variable StatusReg_int : out integer; variable ResOp_ideal: out integer) is
			variable Done_int	: integer;
			variable Enable_int	: integer;
			variable DataOut1_int, DataOut2_int	: integer;
			variable Op1_int, Op2_int, ResOp	: integer;
			variable Ovfl_ideal, Unfl_ideal	: integer;
			variable StatusReg_in	: integer;
			variable RegFileOut_op1_int	: reg_file_array;
		begin
			ResOp_ideal := 0;
			Ovfl_ideal := 0;
			Unfl_ideal := 0;
			StatusReg_in := 0;
			if (CmdALU = CTRL_CMD_ALU) then
				Enable_int := to_integer(unsigned(std_logic_vector(EnableRegFile_vec(EN_REG_FILE_L_TB-1 downto 1) & "0")));
				reg_file_ref(RegFileIn_int, Immediate_int, AddressIn_int, AddressOut1_int, AddressOut2_int, Enable_int, Done_int, DataOut1_int, DataOut2_int, RegFileOut_op1_int);
				Op1_int := DataOut1_int;
				if (EnableRegFile_vec(EN_REG_FILE_L_TB-1) = '1') then
					Op2_int := DataOut2_int;
				else
					Op2_int := Immediate_int;
				end if;

				if (CmdALU = CMD_ALU_SSUM) or (CmdALU = CMD_ALU_SSUB) or (CmdALU = CMD_ALU_SCMP) or (CmdALU = CMD_ALU_DIV) or (CmdALU = CMD_ALU_MUL) then
					Op1_int := to_integer(signed(to_unsigned(Op1_int, OP1_L_TB)));
					Op2_int := to_integer(signed(to_unsigned(Op2_int, OP2_L_TB)));
				end if;


				if (CmdALU = CMD_ALU_MUL) then
					ResOp := Op1_int * Op2_int;
				elsif (CmdALU = CMD_ALU_DIV) then
					ResOp := integer(Op1_int/Op2_int);
				else
					alu_ref(Op1_int, Op2_int, CmdALU, ResOp, Ovfl_ideal, Unfl_ideal);
				end if;
				Enable_int := to_integer(unsigned(std_logic_vector("00" & EnableRegFile_vec(0 downto 0))));
				reg_file_ref(RegFileIn_int, ResOp, AddressIn_int, AddressOut1_int, AddressOut2_int, Enable_int, Done_int, DataOut1_int, DataOut2_int, RegFileOut_op1_int);
				ResOp_ideal := ResOp;

				if (ResOp = 0) then
					StatusReg_in := StatusReg_in + 1;
				else
					StatusReg_in := StatusReg_in + integer(2.0**(3.0));
				end if;

				if (Unfl_ideal = 1) then
					StatusReg_in := StatusReg_in + integer(2.0**(2.0));
				end if;
				if (Ovfl_ideal = 1) then
					StatusReg_in := StatusReg_in + integer(2.0**(1.0));
				end if;

				StatusReg_int := StatusReg_in;
			else
				Enable_int := to_integer(unsigned(std_logic_vector(EnableRegFile_vec(EN_REG_FILE_L_TB-1 downto 1) & "0")));
				reg_file_ref(RegFileIn_int, Immediate_int, AddressIn_int, AddressOut1_int, AddressOut2_int, Enable_int, Done_int, DataOut1_int, DataOut2_int, RegFileOut_op1_int);
				if (EnableRegFile_vec(EN_REG_FILE_L_TB-1) = '1') then
					Op1_int := DataOut1_int;
				else
					Op1_int := Immediate_int;
				end if;
 				Enable_int := to_integer(unsigned(std_logic_vector("00" & EnableRegFile_vec(0 downto 0))));
				reg_file_ref(RegFileIn_int, Op1_int, AddressIn_int, AddressOut1_int, AddressOut2_int, Enable_int, Done_int, DataOut1_int, DataOut2_int, RegFileOut_op1_int);
				ResOp_ideal := ResOp;
			end if;

		end procedure execute_ref;

		procedure verify (variable Op1_int, Op2_int: in integer; variable CtrlCmd : std_logic_vector(CTRL_CMD_L - 1 downto 0); variable CtrlCmd_str, ALUCmd_str : string; variable ResOp_ideal : in integer; variable StatusReg_ideal : in integer; variable ResOp_rtl : in integer; variable StatusReg_rtl : in integer; variable pass : out integer; file file_pointer : text) is
			variable file_line	: line;
		begin

			if (CtrlCmd = CTRL_CMD_ALU) then
				write(file_line, string'( "Ctrl cmd " & CtrlCmd_str & " and ALU cmd" & ALUCmd_str & " with operands " & integer'image(Op1_int) & " and " & integer'image(Op2_int) & " gives: RTL result " & integer'image(ResOp_rtl) & " Status Register " & integer'image(StatusReg_rtl) & " and reference Result " & integer'image(ResOp_ideal) & " Status Register " & integer'image(StatusReg_ideal)));
			else
				write(file_line, string'( "Ctrl cmd " & CtrlCmd_str & " gives: RTL result " & integer'image(ResOp_rtl) & " Status Register " & integer'image(StatusReg_rtl) & " and reference Result " & integer'image(ResOp_ideal) & " Status Register " & integer'image(StatusReg_ideal)));
			end if;
			writeline(file_pointer, file_line);

			if (ResOp_rtl = ResOp_ideal) and (StatusReg_ideal = StatusReg_rtl) then
				write(file_line, string'("PASS"));
				pass := 1;
			elsif (StatusReg_ideal = StatusReg_rtl) then
				write(file_line, string'("FAIL (Wrong result)"));
				pass := 0;
			elsif (ResOp_rtl = ResOp_ideal) then
				write(file_line, string'("FAIL (Wrong status register)"));
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

		variable Op1, Op2	: integer;
		variable StatusReg_ideal, StatusReg_rtl : integer;
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

		reset(RegFileIn_int);
		file_open(file_pointer, log_file, append_mode);

		write(file_line, string'( "ALU Test"));
		writeline(file_pointer, file_line);

		for i in 0 to NUM_TEST-1 loop

			push_op(AddressIn_int, AddressOut1_int, AddressOut2_int, Immediate_int, CmdALU, CtrlCmd, EnableRegFile_vec, seed1, seed2);

			wait on Done_tb;

			if (CmdALU = CMD_ALU_SSUM) or (CmdALU = CMD_ALU_SSUB) or (CmdALU = CMD_ALU_SCMP)  or (CmdALU = CMD_ALU_DIV) or (CmdALU = CMD_ALU_MUL)then
				ResOp_rtl := to_integer(signed(ResDbg_tb));
			else
				ResOp_rtl := to_integer(unsigned(ResDbg_tb));
			end if;

			execute_ref(AddressIn_int, AddressOut1_int, AddressOut2_int, Immediate_int, CmdALU, CtrlCmd, EnableRegFile_vec, RegFileIn_int, RegFileOut_int, Op1, Op2, StatusReg_ideal, ResOp_ideal);

			verify (Op1, Op2, CtrlCmd, ctrl_cmd_std_vect_to_txt(CtrlCmd), alu_cmd_std_vect_to_txt(CmdALU), ResOp_ideal, StatusReg_ideal, ResOp_rtl, StatusReg_rtl, pass, file_pointer);

			RegFileIn_int := RegFileOut_int;
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