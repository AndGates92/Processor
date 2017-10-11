library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
library common_rtl_pkg;
use common_rtl_pkg.functions_pkg.all;
use common_rtl_pkg.mem_model_pkg.all;
library cpu_rtl_pkg;
use cpu_rtl_pkg.proc_pkg.all;
use cpu_rtl_pkg.alu_pkg.all;
use cpu_rtl_pkg.ctrl_pkg.all;
use cpu_rtl_pkg.dcache_pkg.all;
use cpu_rtl_pkg.reg_file_pkg.all;
use cpu_rtl_pkg.decode_pkg.all;
use cpu_rtl_pkg.execute_dcache_pkg.all;

entity execute_dcache is
generic (
	BASE_STACK	: positive := 16#8000#;
	OP1_L		: positive := 32;
	OP2_L		: positive := 16;
	REG_NUM		: positive := 16;
	ADDR_L		: positive := 16;
	STAT_REG_L	: positive := 8;
	EN_REG_FILE_L	: positive := 3;
	OUT_REG_FILE_NUM	: positive := 2
);
port (
	rst		: in std_logic;
	clk		: in std_logic;

	Start	: in std_logic;
	Endrst	: out std_logic;

	AddressRegFileIn_In	: in std_logic_vector(int_to_bit_num(REG_NUM) - 1 downto 0);
	AddressRegFileOut1_In	: in std_logic_vector(int_to_bit_num(REG_NUM) - 1 downto 0);
	AddressRegFileOut2_In	: in std_logic_vector(int_to_bit_num(REG_NUM) - 1 downto 0);
	Immediate	: in std_logic_vector(DATA_L - 1 downto 0);
	EnableRegFile_In	: in std_logic_vector(EN_REG_FILE_L - 1 downto 0);

	CmdALU_In	: in std_logic_vector(CMD_ALU_L - 1 downto 0);
	CtrlCmd	: in std_logic_vector(CTRL_CMD_L - 1 downto 0);

	StatusRegOut	: out std_logic_vector(STAT_REG_L - 1 downto 0);
	ResDbg	: out std_logic_vector(OP1_L - 1 downto 0); -- debug signal
	Done	: out std_logic
);
end entity execute_dcache;

architecture rtl of execute_dcache is

	constant ZERO_STAT_REG	: std_logic_vector(STAT_REG_L - 1 downto 0) := std_logic_vector(to_unsigned(0, STAT_REG_L));
	constant ZERO_RES	: std_logic_vector(DATA_L - 1 downto 0) := std_logic_vector(to_unsigned(0, DATA_L));

	signal Op1	: std_logic_vector(OP1_L - 1 downto 0);
	signal Op2	: std_logic_vector(OP2_L - 1 downto 0);
	signal NegBitALU	: std_logic;

	signal EnableALU, EnableMul, EnableDiv, EnableMemory, EnableDCache	: std_logic; -- enable signals
	signal EnableRegFile	: std_logic_vector(EN_REG_FILE_L - 1 downto 0);
	signal DoneALU, DoneMul, DoneDiv, DoneRegFile, DoneMemory, DoneDCache	: std_logic; -- done signals

	signal CmdALU	: std_logic_vector(CMD_ALU_L - 1 downto 0);

	-- Arithmetic and Logic operations
	signal ResALU	: std_logic_vector(OP1_L-1 downto 0);
	signal ResMul	: std_logic_vector(OP1_L+OP2_L-1 downto 0);
	signal ResDiv	: std_logic_vector(OP1_L - 1 downto 0);
	signal Ovfl, Unfl	: std_logic;

	-- Register File
	signal DataRegFileIn	: std_logic_vector(DATA_L - 1 downto 0);
	signal AddressRegFileIn	: std_logic_vector(int_to_bit_num(REG_NUM) - 1 downto 0);
	signal AddressRegFileOut1	: std_logic_vector(int_to_bit_num(REG_NUM) - 1 downto 0);
	signal AddressRegFileOut2	: std_logic_vector(int_to_bit_num(REG_NUM) - 1 downto 0);
	signal DoneReadStatus		: std_logic_vector(OUT_REG_FILE_NUM-1 downto 0);
	signal DataRegFileOut1	: std_logic_vector(DATA_L-1 downto 0);
	signal DataRegFileOut2	: std_logic_vector(DATA_L-1 downto 0);

	-- DCache Access
	signal ReadDCache	: std_logic;
	signal DataInDCache	: std_logic_vector(DATA_L - 1 downto 0);
	signal AddressDCache	: std_logic_vector(ADDR_L - 1 downto 0);
	signal DataOutDCache	: std_logic_vector(DATA_L - 1 downto 0);

	-- Memory Access
	signal ReadMem		: std_logic;
	signal DataMemIn	: std_logic_vector(DATA_L - 1 downto 0);
	signal AddressMem	: std_logic_vector(ADDR_L - 1 downto 0);
	signal DataMemOut	: std_logic_vector(DATA_L - 1 downto 0);

	signal ResDbgN, ResDbgC	: std_logic_vector(DATA_L - 1 downto 0);
	signal StatusRegN, StatusRegC	: std_logic_vector(STAT_REG_L - 1 downto 0);

begin

	ResDbgN <=	ResALU when DoneALU = '1' else
			ResMul(DATA_L - 1 downto 0) when DoneMul = '1' else
			ResDiv when DoneDiv = '1' else
			(others => '0') when Start = '1' else
			ResDbgC;

	ResDbg <= ResDbgC;

	NegBitALU <= ResALU(OP1_L - 1) when (CmdALU = CMD_ALU_SSUM) or (CmdALU = CMD_ALU_SSUB) or (CmdALU = CMD_ALU_SCMP) else '0';

	StatusRegN <= 	ZERO_STAT_REG(STAT_REG_L - 4 - 1 downto 0) & NegBitALU & Unfl & Ovfl & "1" when (DoneALU = '1') and (ResALU = ZERO_RES) else
			ZERO_STAT_REG(STAT_REG_L - 4 - 1 downto 0) & NegBitALU & Unfl & Ovfl & "0" when (DoneALU = '1') else
			ZERO_STAT_REG(STAT_REG_L - 4 - 1 downto 0) & ResMul(OP1_L - 1) & Unfl & Ovfl & "1" when (DoneMul = '1') and (ResMul(OP1_L - 1 downto 0) = ZERO_RES) else
			ZERO_STAT_REG(STAT_REG_L - 4 - 1 downto 0) & ResMul(OP1_L - 1) & Unfl & Ovfl & "0" when (DoneMul = '1') else
			ZERO_STAT_REG(STAT_REG_L - 4 - 1 downto 0) & ResDiv(OP1_L - 1) & Unfl & Ovfl & "1" when (DoneDiv = '1') and (ResDiv = ZERO_RES) else
			ZERO_STAT_REG(STAT_REG_L - 4 - 1 downto 0) & ResDiv(OP1_L - 1) & Unfl & Ovfl & "0" when (DoneDiv = '1') else
			StatusRegC;

	StatusRegOut <= StatusRegC;

	reg: process(rst, clk)
	begin
		if (rst = '1') then

			ResDbgC <= (others => '0');
			StatusRegC <= (others => '0');

		elsif ((clk'event) and (clk = '1')) then

			ResDbgC <= ResDbgN;
			StatusRegC <= StatusRegN;

		end if;
	end process reg;


	ALU_I: alu generic map(
		OP1_L => OP1_L,
		OP2_L => OP2_L
	)
	port map (
		rst => rst,
		clk => clk,
		Op1 => Op1,
		Op2 => Op2,
		Cmd => CmdALU,
		Start => EnableALU,
		Done => DoneALU,
		Ovfl => Ovfl,
		Unfl => Unfl,
		UnCmd => open,
		Res => ResALU
	);

	MUL_I: mul generic map(
		OP1_L => OP1_L,
		OP2_L => OP2_L
	)
	port map (
		rst => rst,
		clk => clk,
		Op1 => Op1,
		Op2 => Op2,
		Start => EnableMul,
		Done => DoneMul,
		Res => ResMul
	);

	DIV_I: div generic map(
		DIVD_L => OP1_L,
		DIVR_L => OP2_L
	)
	port map (
		rst => rst,
		clk => clk,
		Dividend => Op1,
		Divisor => Op2,
		Start => EnableDiv,
		Done => DoneDiv,
		Quotient => ResDiv,
		Remainder => open
	);

	REG_FILE_I: reg_file generic map(
		REG_NUM => REG_NUM,
		EN_L => EN_REG_FILE_L,
		OUT_NUM => OUT_REG_FILE_NUM
	)
	port map(
		clk => clk,
		rst => rst,
		DataIn => DataRegFileIn,
		DataOut1 => DataRegFileOut1,
		DataOut2 => DataRegFileOut2,
		AddressIn => AddressRegFileIn,
		AddressOut1 => AddressRegFileOut1,
		AddressOut2 => AddressRegFileOut2,
		Enable => EnableRegFile,
		End_LS => DoneRegFile,
		Done => DoneReadStatus
	);

	CTRL_I: ctrl generic map (
		OP1_L => OP1_L,
		OP2_L => OP2_L,
		REG_NUM => REG_NUM,
		ADDR_L => ADDR_L,
		STAT_REG_L => STAT_REG_L,
		EN_REG_FILE_L => EN_REG_FILE_L,
		BASE_STACK => BASE_STACK,
		OUT_NUM => OUT_REG_FILE_NUM
	)
	port map (
		rst => rst,
		clk => clk,

		EndExecution => Done,

		-- Decode stage
		Immediate => Immediate,
		EndDecoding => Start,
		CtrlCmd => CtrlCmd,
		CmdALU_In => CmdALU_In,
		AddressRegFileIn_In => AddressRegFileIn_In,
		AddressRegFileOut1_In => AddressRegFileOut1_In,
		AddressRegFileOut2_In => AddressRegFileOut2_In,
		EnableRegFile_In => EnableRegFile_In,

		Op1 => Op1,
		Op2 => Op2,

		-- ALU
		DoneALU => DoneALU,
		EnableALU => EnableALU,
		ResALU => ResALU,
		CmdALU => CmdALU,

		-- Multiplier
		DoneMul => DoneMul,
		EnableMul => EnableMul,
		ResMul => ResMul,

		-- Divider
		DoneDiv => DoneDiv,
		EnableDiv => EnableDiv,
		ResDiv => ResDiv,

		-- Memory access
		DoneMemory => DoneDCache,
		ReadMem => ReadDCache,
		EnableMemory => EnableDcache,
		DataMemIn => DataInDCache,
		AddressMem => AddressDCache,
		DataMemOut => DataOutDCache,

		-- Register File
		DoneRegFile => DoneRegFile,
		DoneReadStatus => DoneReadStatus,
		DataRegIn => DataRegFileIn,
		DataRegOut1 => DataRegFileOut1,
		DataRegOut2 => DataRegFileOut2,
		AddressRegFileIn => AddressRegFileIn,
		AddressRegFileOut1 => AddressRegFileOut1,
		AddressRegFileOut2 => AddressRegFileOut2,
		EnableRegFile => EnableRegFile
	);

	DCACHE_I: dcache generic map(
		ADDR_MEM_L => ADDR_L
	)
	port map (
		rst => rst,
		clk => clk,

		Hit => open,
		EndRst => EndRst,

		Start => EnableDCache,
		Done => DoneDCache,
		Read => ReadDCache,
		Address => AddressDCache,
		DataOut => DataOutDCache,
		DataIn => DataInDCache,

		-- Memory access
		DoneMemory => DoneMemory,
		EnableMemory => EnableMemory,
		AddressMem => AddressMem,
		DataMemIn => DataMemIn,
		ReadMem => ReadMem,
		DataMemOut => DataMemOut
	);

	MEM_INT_I: mem_model generic map(
		ADDR_L => ADDR_L,
		DATA_L => DATA_L
	)
	port map (
		rst => rst,
		clk => clk,

		DoneMemory => DoneMemory,
		ReadMem => ReadMem,
		EnableMemory => EnableMemory,
		DataMemIn => DataMemIn,
		AddressMem => AddressMem,
		DataMemOut => DataMemOut
	);
end rtl; 
