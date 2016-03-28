library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;
use work.alu_pkg.all;
use work.ctrl_pkg.all;
use work.proc_pkg.all;
use work.tb_pkg.all;

entity ctrl_tb is
end entity ctrl_tb;

architecture bench of ctrl_tb is

	constant CLK_PERIOD	: time := 10 ns;
	constant NUM_TEST	: integer := 1000;

	constant OP1_L_TB	: positive := 32;
	constant OP2_L_TB	: positive := 32;
	constant INSTR_L_TB	: positive := 32;
	constant REG_NUM_TB	: positive := 16;
	constant ADDR_L_TB	: positive := 16;
	constant REG_L_TB	: positive := 32;
	constant STAT_REG_L_TB	: positive := 8;
	constant EN_REG_FILE_L_TB	: positive := 3;
	constant OUT_NUM_TB	: positive := 2;

	signal rst_tb	: std_logic;
	signal stop	: boolean := false;
	signal clk_tb	: std_logic;

	-- Decode stage
	signal Immediate_tb	: std_logic_vector(REG_L_TB - 1 downto 0);
	signal EndDecoding_tb	: std_logic;
	signal CtrlCmd_tb	: std_logic_vector(CTRL_CMD_L - 1 downto 0);
	signal CmdALU_In_tb	: std_logic_vector(ALU_CMD_L - 1 downto 0);
	signal AddressRegFileIn_In_tb	: std_logic_vector(count_length(REG_NUM_TB) - 1 downto 0);
	signal AddressRegFileOut1_In_tb	: std_logic_vector(count_length(REG_NUM_TB) - 1 downto 0);
	signal AddressRegFileOut2_In_tb	: std_logic_vector(count_length(REG_NUM_TB) - 1 downto 0);
	signal Enable_reg_file_In_tb	: std_logic_vector(EN_REG_FILE_L_TB - 1 downto 0);

	-- ALU
	signal DoneALU_tb	: std_logic;
	signal EnableALU_tb	: std_logic;
	signal Op1ALU_tb	: std_logic_vector(OP1_L_TB - 1 downto 0);
	signal Op2ALU_tb	: std_logic_vector(OP2_L_TB - 1 downto 0);
	signal ResALU_tb	: std_logic_vector(OP1_L_TB - 1 downto 0);
	signal CmdALU_tb	: std_logic_vector(ALU_CMD_L - 1 downto 0);

	-- Multiplier
	signal DoneMul_tb	: std_logic;
	signal EnableMul_tb	: std_logic;
	signal Op1Mul_tb	: std_logic_vector(OP1_L_TB - 1 downto 0);
	signal Op2Mul_tb	: std_logic_vector(OP2_L_TB - 1 downto 0);
	signal ResMul_tb	: std_logic_vector(OP1_L_TB + OP2_L_TB - 1 downto 0);

	-- Divider
	signal DoneDiv_tb	: std_logic;
	signal EnableDiv_tb	: std_logic;
	signal Op1Div_tb	: std_logic_vector(OP1_L_TB - 1 downto 0);
	signal Op2Div_tb	: std_logic_vector(OP2_L_TB - 1 downto 0);
	signal ResDiv_tb	: std_logic_vector(OP1_L_TB - 1 downto 0);

	-- Memory access
	signal DoneMemory_tb	: std_logic;
	signal ReadMem_tb	: std_logic;
	signal EnableMemory_tb	: std_logic;
	signal DataMemIn_tb	: std_logic_vector(REG_L_TB - 1 downto 0);
	signal AddressMem_tb	: std_logic_vector(ADDR_L_TB - 1 downto 0);
	signal DataMemOut_tb	: std_logic_vector(REG_L_TB - 1 downto 0);

	-- Register File
	signal DoneRegFile_tb		: std_logic;
	signal DoneReadStatus_tb	: std_logic_vector(OUT_NUM_TB - 1 downto 0);
	signal DataRegIn_tb		: std_logic_vector(REG_L_TB - 1 downto 0);
	signal DataRegOut1_tb		: std_logic_vector(REG_L_TB - 1 downto 0);
	signal DataRegOut2_tb		: std_logic_vector(REG_L_TB - 1 downto 0);
	signal AddressRegFileIn_tb	: std_logic_vector(count_length(REG_NUM_TB) - 1 downto 0);
	signal AddressRegFileOut1_tb	: std_logic_vector(count_length(REG_NUM_TB) - 1 downto 0);
	signal AddressRegFileOut2_tb	: std_logic_vector(count_length(REG_NUM_TB) - 1 downto 0);
	signal EnableRegFile_tb		: std_logic_vector(EN_REG_FILE_L_TB - 1 downto 0);

begin

	DUT: ctrl generic map (
		OP1_L => OP1_L_TB,
		OP2_L => OP2_L_TB,
		INSTR_L => INSTR_L_TB,
		REG_NUM => REG_NUM_TB,
		ADDR_L => ADDR_L_TB,
		REG_L => REG_L_TB,
		STAT_REG_L => STAT_REG_L_TB,
		EN_REG_FILE_L => EN_REG_FILE_L,
		OUT_NUM => OUT_NUM_TB
	)
	port map (

		rst => rst_tb,
		clk => clk_tb,

		-- Decode stage
		Immediate => Immediate_tb,
		EndDecoding => EndDecoding_tb,
		CtrlCmd => CtrlCmd_tb,
		CmdALU_In => CmdALU_In_tb,
		AddressRegFileIn_In => AddressRegFileIn_In_tb,
		AddressRegFileOut1_In => AddressRegFileOut1_In_tb,
		AddressRegFileOut2_In => AddressRegFileOut2_In_tb,
		Enable_reg_file_In => Enable_reg_file_In_tb,

		-- ALU
		DoneALU => DoneALU_tb,
		EnableALU => EnableALU_tb,
		Op1ALU => Op1ALU_tb,
		Op2ALU => Op2ALU_tb,
		ResALU => ResALU_tb,
		CmdALU => CmdALU_tb,

		-- Multiplier
		DoneMul => DoneMul_tb,
		EnableMul => EnableMul_tb,
		Op1Mul => Op1Mul_tb,
		Op2Mul => Op2Mul_tb,
		ResMul => ResMul_tb,

		-- Divider
		DoneDiv => DoneDiv_tb,
		EnableDiv => EnableDiv_tb,
		Op1Div => Op1Div_tb,
		Op2Div => Op2Div_tb,
		ResDiv => ResDiv_tb,

		-- Memory access
		DoneMemory => DoneMemory_tb,
		ReadMem => ReadMem_tb,
		EnableMemory => EnableMemory_tb,
		DataMemIn => DataMemIn_tb,
		AddressMem => AddressMem_tb,
		DataMemOut => DataMemOut_tb,

		-- Register File
		DoneRegFile => DoneRegFile_tb,
		DoneReadStatus => DoneReadStatus,
		DataRegIn => DataRegIn_tb,	
		DataRegOut1 => DataRegOut1_tb,
		DataRegOut2 => DataRegOut2_tb,
		AddressRegFileIn => AddressRegFileIn_tb,
		AddressRegFileOut1 => AddressRegFileOut1_tb,
		AddressRegFileOut2 => AddressRegFileOut2_tb,
		EnableRegFile => EnableRegFile_tb
	);

	clk_tb <= not clk_tb after CLK_PERIOD/2 when not stop;

	test: process

		procedure reset is
		begin
			rst_tb <= '0';
			wait until rising_edge(clk_tb);
			rst_tb <= '1';
			Instr_tb <= (others => '0');
			PCIn_tb <= (others => '0');
			StatusRegIn_tb <= (others => '0');
			NewInstr_tb <= '0';
			wait until rising_edge(clk_tb);
			rst_tb <= '0';
		end procedure reset;

		procedure push_op(variable CmdALU_vec : out std_logic_vector(ALU_CMD_L - 1 downto 0); variable CtrlCmd_vec : out std_logic_vector(CTRL_CMD_L - 1 downto 0); variable EnableRegFile_vec : out std_logic_vector(EN_REG_FILE_L - 1 downto 0); variable seed1, seed2: inout positive) is
			variable CmdALU_in, Immediate_in, CtrlCmd_in, AddressIn_in, AddressOut1_in, AddressOut2_in, EnableRegFile_in	: integer;
		begin

			uniform(seed1, seed2, rand_val);
			CtrlCmd_in := integer(rand_val*(2.0**(real(CTRL_CMD_L)) - 1.0));
			CtrlCmd_tb <= std_logic_vector(to_unsigned(CtrlCmd_in, CTRL_CMD_L));
			CtrlCmd_vec := std_logic_vector(to_unsigned(CtrlCmd_in, CTRL_CMD_L));

			uniform(seed1, seed2, rand_val);
			EnableRegFile_in := integer(rand_val*(2.0**(real(EN_REG_FILE_L_TB)) - 1.0));
			Enable_reg_file_In_tb <= std_logic_vector(to_unsigned(EnableRegFile_in, EN_REG_FILE_L_TB));
			EnableRegFile_vec := std_logic_vector(to_unsigned(EnableRegFile_in, EN_REG_FILE_L_TB));

			uniform(seed1, seed2, rand_val);
			CmdALU_in := integer(rand_val*(2.0**(real(ALU_CMD_L)) - 1.0));
			CmdALU_tb <= std_logic_vector(to_unsigned(CmdALU_in, ALU_CMD_L));
			CmdALU_vec := std_logic_vector(to_unsigned(CmdALU_in, ALU_CMD_L));

			uniform(seed1, seed2, rand_val);
			Immediate_in := integer(rand_val*(2.0**(real(REG_L_TB)) - 1.0));
			Immediate_tb <= std_logic_vector(to_unsigned(Immediate_in, REG_L_TB));

			uniform(seed1, seed2, rand_val);
			AddressIn_in := integer(rand_val*(2.0**(real(count_length(REG_NUM_TB))) - 1.0));
			AddressIn_tb <= std_logic_vector(to_unsigned(AddressIn_in, count_length(REG_NUM_TB)));

			uniform(seed1, seed2, rand_val);
			AddressOut1_in := integer(rand_val*(2.0**(real(count_length(REG_NUM_TB))) - 1.0));
			AddressOut1_tb <= std_logic_vector(to_unsigned(AddressOut1_in, count_length(REG_NUM_TB)));

			uniform(seed1, seed2, rand_val);
			AddressOut2_in := integer(rand_val*(2.0**(real(count_length(REG_NUM_TB))) - 1.0));
			AddressOut2_tb <= std_logic_vector(to_unsigned(AddressOut2_in, coutn_length(REG_NUM_TB)));

			EnableALU_tb <= '0';
			EnableMul_tb <= '0';
			EnableDiv_tb <= '0';
			EnableRegFile_tb <= '0';
			EnableMem_tb <= '0';

			ResALU_tb <= (others => '0');
			ResMul_tb <= (others => '0');
			ResDiv_tb <= (others => '0');

			DataRegOut1_tb <= (others => '0');
			DataRegOut2_tb <= (others => '0');
			DataMemOut_tb <= (others => '0');

			DoneReadStatus_tb <= (others => '0');


			EndDecoding_tb <= '1';

			wait until rising_edge(clk_tb);
			EndDecoding_tb <= '0';
		end procedure push_op;

		procedure reference(variable CtrlCmd_vec : in std_logic_vector(CTRL_CMD_L_TB - 1 downto 0); variable CmdALU_vec : in std_logic_vector(ALU_CMD_L - 1 downto 0); variable EnableRegFile_vec : in std_logic_vector(EN_REG_FILE_L_TB - 1 downto 0); variable ALUOp, Mul, Div, ReadRegFile, WriteRegFile, MemAccess : out integer) i 
		begin
			Mul := 0;
			Div := 0;
			ALUOp := 0;
			ReadRegFile := 0;
			WriteRegFile := 0;
			MemAccess := 0;
			if (CtrlCmd_vec = CTRL_DISABLE)
				if (EnableALU_tb := '0')
					ALUOp := 0;
				else
					ALUOp := 1;
				end if;

				if (EnableMul_tb := '0')
					Mul := 0;
				else
					Mul := 1;
				end if;

				if (EnableDiv_tb := '0')
					Div := 0;
				else
					Div := 1;
				end if;

				if (EnableRegFile_tb := std_logic_vector(to_unsigned(0,OUT_NUM_TB)))
					ReadRegFile := 0;
					WriteRegFile := 0;
				else
					WriteRegFile := 1;
					ReadRegFile := 1;
				end if;

				if (EnableMemory_tb := '0')
					MemAccess := 0;
				else
					MemAccess := 1;
				end if;
			elsif (CtrlCmd_vec = CTRL_ALU) then
				wait on EnableRegFile_tb;
				if (EnableRegFile_tb = (EnableRegFile_vec(EN_REG_FILE_L_TB - 1 downto 1) & "0")) then
					ReadRegFile := 1;
				else
					ReadRegFile := 0;
				end if;
				for clk_cycle in 0 to 2 loop
					wait until rising_edge(clk_tb);
				end if;
				DoneRegFile_tb <= '1';
				if (CmdALU_vec = CMD_MUL) then
					if (EnableMul_tb = '1') then
						Mul := 1;
					else
						Mul := 0;
					end if;
					for clk_cycle in 0 to 15 loop
						wait until rising_edge(clk_tb);
						DoneRegFile_tb <= '0';
					end if;
					DoneMul_tb <= '1';
				elsif (CmdALU_vec = CMD_DIV) then
					if (EnableDiv_tb = '1') then
						Div := 1;
					else
						Div := 0;
					end if;
					for clk_cycle in 0 to 31 loop
						wait until rising_edge(clk_tb);
						DoneRegFile_tb <= '0';
					end if;
					DoneDiv_tb <= '1';
				else
					wait on EnableALU_tb;
					if ((CmdALU_vec = CmdALU_tb) and (EnableALU_tb = '1')) then
						ALUOp := 1;
					else
						ALUOp := 0;
					end if;
					for clk_cycle in 0 to 3 loop
						wait until rising_edge(clk_tb);
						DoneRegFile_tb <= '0';
					end if;
					DoneALU_tb <= '1';
				end if;
				if (EnableRegFile_tb = ("00" & EnableRegFile_vec(0))) then
					WriteRegFile := 1;
				else
					WriteRegFile := 0;
				end if;
				for clk_cycle in 0 to 2 loop
					wait until rising_edge(clk_tb);
				end if;
				DoneRegFile_tb <= '1';
			elsif (CtrlCmd_vec = CTRL_WR_M) or (CtrlCmd_vec = CTRL_WR_S) then
				wait on EnableRegFile_tb;
				if (EnableRegFile_tb = (EnableRegFile_vec(EN_REG_FILE_L_TB - 1 downto 1) & "0")) then
					ReadRegFile := 1;
				else
					ReadRegFile := 0;
				end if;
				for clk_cycle in 0 to 2 loop
					wait until rising_edge(clk_tb);
				end if;
				DoneRegFile_tb <= '1';
				if (EnableMemory_tb = '1') then
					MemAccess := 1;
				else
					MemAccess := 0;
				end if;
				for clk_cycle in 0 to 7 loop
					wait until rising_edge(clk_tb);
					DoneRegFile_tb <= '1';
				end if;
				DoneMemory_tb <= '1';
			elsif (CtrlCmd_vec = CTRL_RD_M) or (CtrlCmd_vec = CTRL_RD_S) then
				wait on EnableMemory_tb;
				if (EnableMemory_tb = '1') then
					MemAccess := 1;
				else
					MemAccess := 0;
				end if;
				for clk_cycle in 0 to 7 loop
					wait until rising_edge(clk_tb);
				end if;
				DoneMemory_tb <= '1';
				if (EnableRegFile_tb = ("00" & EnableRegFile_vec(0))) then
					WriteRegFile := 1;
				else
					WriteRegFile := 0;
				end if;
				for clk_cycle in 0 to 2 loop
					wait until rising_edge(clk_tb);
					DoneMemory_tb <= '0';
				end if;
				DoneRegFile_tb <= '1';
			elsif (CtrlCmd_vec = CTRL_MOV) then
				if (EnableRegFile_vec(1) = '0') then
					wait on EnableRegFile_tb;
					if (EnableRegFile_tb = ("00" & EnableRegFile_vec(0))) then
						WriteRegFile := 1;
					else
						WriteRegFile := 0;
					end if;
					for clk_cycle in 0 to 2 loop
						wait until rising_edge(clk_tb);
					end if;
					DoneRegFile_tb <= '1';
				else
					wait on EnableRegFile_tb;
					if (EnableRegFile_tb = (EnableRegFile_vec(EN_REG_FILE_L_TB - 1 downto 1) & "0")) then
						ReadRegFile := 1;
					else
						ReadRegFile := 0;
					end if;
					for clk_cycle in 0 to 2 loop
						wait until rising_edge(clk_tb);
					end if;
					DoneRegFile_tb <= '1';
					if (EnableRegFile_tb = ("00" & EnableRegFile_vec(0))) then
						WriteRegFile := 1;
					else
						WriteRegFile := 0;
					end if;
					for clk_cycle in 0 to 2 loop
						wait until rising_edge(clk_tb);
						DoneRegFile_tb <= '0';
					end if;
					DoneRegFile_tb <= '1';
				end if;
			end if;
		end procedure reference;

		procedure verify(variable CtrlCmd_vec : in std_logic_vector(CTRL_CMD_L_TB - 1 downto 0); variable CtrlCmd_str : in string; variable CmdALU_vec : in std_logic_vector(ALU_CMD_L - 1 downto 0); variable CmdALU_str : in string; variable EnableRegFile_vec : in std_logic_vector(EN_REG_FILE_L _TB - 1 downto 0); variable ALUOp, Mul, Div, ReadRegFile, WriteRegFile, MemAccess : in integer; file file_pointer : text; variable pass : out integer) is
			variable file_line	: line;
		begin
			write(file_line, string'("CONTROL UNIT: Ctrl Command " & CtrlCmd_str & " ALU Command " & CmdALU_str  & " Register File (In:" & integer'image(std_logic_to_int(EnableRegFile_vec(0))) & " Out1:" & integer'image(std_logic_to_int(EnableRegFile_vec(1))) & " Out2:" & integer'image(std_logic_to_int(EnableRegFile_vec(2))) & "):"));
			writeline(file_pointer, file_line);
			write(file_line, string'("ALU " & integer'image(ALUOp) & " Multiplication " & integer'image(Mul) & " Division " & integer'image(Div) & " Register File (Write: " & integer'image(WriteRegFile) & " and Read: " & integer'image(ReadRegFile) & ") Memory Access " & integer'image(MemAccess)));
			writeline(file_pointer, file_line);
			if ((CtrlCmd_vec = CTRL_ALU_CMD) and (CmdALU_vec = CMD_MUL) and (ALUOp = 0) and (Mul = 1) and (Div = 0) and (ReadRegFile = 1) and (WriteRegFile = 1) and (MemAccess = 0)) then
				write(file_line, string'("PASS"));
				pass := 1;
			elsif ((CtrlCmd_vec = CTRL_ALU_CMD) and (CmdALU_vec = CMD_DIV) and (ALUOp = 0) and (Mul = 0) and (Div = 1) and (ReadRegFile = 1) and (WriteRegFile = 1) and (MemAccess = 0)) then
				write(file_line, string'("PASS"));
				pass := 1;
			elsif ((CtrlCmd_vec = CTRL_ALU_CMD) and (ALUOp = 1) and (Mul = 0) and (Div = 0) and (ReadRegFile = 1) and (WriteRegFile = 1) and (MemAccess = 0)) then
				write(file_line, string'("PASS"));
				pass := 1;
			elsif (((CtrlCmd_vec = CTRL_CMD_WR_S) or (CtrlCmd_vec = CTRL_CMD_WR_W)) and (ALUOp = 0) and (Mul = 0) and (Div = 0) and (ReadRegFile = 1) and (WriteRegFile = 0) and (MemAccess = 1)) then
				write(file_line, string'("PASS"));
				pass := 1;
			elsif (((CtrlCmd_vec = CTRL_CMD_RD_S) or (CtrlCmd_vec = CTRL_CMD_RD_W)) and (ALUOp = 0) and (Mul = 0) and (Div = 0) and (ReadRegFile = 0) and (WriteRegFile = 1) and (MemAccess = 1)) then
				write(file_line, string'("PASS"));
				pass := 1;
			elsif ((CtrlCmd_vec = CTRL_CMD_MOV) and (EnableRegFile_vec(1) = '1') and (ALUOp = 0) and (Mul = 0) and (Div = 0) and (ReadRegFile = 1) and (WriteRegFile = 1) and (MemAccess = 0)) then
				write(file_line, string'("PASS"));
				pass := 1;
			elsif ((CtrlCmd_vec = CTRL_CMD_MOV) and (EnableRegFile_vec(1) = '0') and (ALUOp = 0) and (Mul = 0) and (Div = 0) and (ReadRegFile = 0) and (WriteRegFile = 1) and (MemAccess = 0)) then
				write(file_line, string'("PASS"));
				pass := 1;
			elsif ((CtrlCmd_vec = CTRL_CMD_DISABLE) and (ALUOp = 0) and (Mul = 0) and (Div = 0) and (ReadRegFile = 0) and (WriteRegFile = 0) and (MemAccess = 0)) then
				write(file_line, string'("PASS"));
				pass := 1;
			elsif ((CtrlCmd_vec /= CTRL_CMD_MOV) and (CtrlCmd_vec /= CTRL_CMD_WR_M) and (CtrlCmd_vec /= CTRL_CMD_WR_S) and (CtrlCmd_vec /= CTRL_CMD_RD_M) and (CtrlCmd_vec /= CTRL_CMD_RD_S) and (CtrlCmd_vec /= CTRL_ALU_CMD) and (ALUOp = 0) and (Mul = 0) and (Div = 0) and (ReadRegFile = 0) and (WriteRegFile = 0) and (MemAccess = 0)) then
				write(file_line, string'("PASS (unknown command"));
				pass := 1;
			else
				write(file_line, string'("FAIL"));
				pass := 0;
			end if;
			writeline(file_pointer, file_line);
		end procedure verify;

		file file_pointer : text;
		variable file_line	: line;
		variable CmdALU_vec : std_logic_vector(ALU_CMD_L - 1 downto 0);
		variable CtrlCmd_vec : std_logic_vector(CTRL_CMD_L - 1 downto 0); 
		variable EnableRegFile_vec : std_logic_vector(EN_REG_FILE_L - 1 downto 0);
		variable ALUOp, Mul, Div, ReadRegFile, WriteRegFile, MemAccess : integer;
		variable seed1, seed2: positive;

	begin

		wait for 1 ns;

		num_pass := 0;

		reset;

		file_open(file_pointer, log_file, append_mode);

		write(file_line, string'( "Decode stage Test"));
		writeline(file_pointer, file_line);

		for i in 0 to NUM_TEST-1 loop

			push_op(CmdALU_vec, CtrlCmd_vec, EnableRegFile_vec, seed1, seed2);
			reference(CtrlCmd_vec,CmdALU_vec, EnableRegFile_vec, ALUOp, Mul, Div, ReadRegFile, WriteRegFile, MemAccess);
			verify(CtrlCmd_vec, ctrl_cmd_std_vect_to_txt(Cmd), CmdALU_vec, full_alu_cmd_std_vect_to_txt(Cmd), EnableRegFile_vec, ALUOp, Mul, Div, ReadRegFile, WriteRegFile, MemAccess, file_pointer,  pass);

			num_pass := num_pass + pass;

			wait until rising_edge(clk_tb);
		end loop;

		file_close(file_pointer);

		file_open(file_pointer, summary_file, append_mode);
		write(file_line, "CONTROL UNIT => PASSES: " & integer'image(num_pass) & " out of " & integer'image(NUM_TEST));
		writeline(file_pointer, file_line);
		file_close(file_pointer);

		stop <= true;

	end process test;
end bench;
