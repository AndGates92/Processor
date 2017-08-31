library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.alu_pkg.all;
use work.proc_pkg.all;

entity alu is
generic (
	OP1_L	: positive := 16;
	OP2_L	: positive := 16
);
port (
	rst	: in std_logic;
	clk	: in std_logic;
	Op1	: in std_logic_vector(OP1_L - 1 downto 0);
	Op2	: in std_logic_vector(OP2_L - 1 downto 0);
	Cmd	: in std_logic_vector(CMD_ALU_L - 1 downto 0);
	Start	: in std_logic;
	Done	: out std_logic;
	Ovfl	: out std_logic;
	Unfl	: out std_logic;
	UnCmd	: out std_logic;
	Res	: out std_logic_vector(OP1_L-1 downto 0)
);
end entity alu;

architecture rtl of alu is

	constant ZERO	: unsigned(OP1_L+1 - 1 downto 0) := to_unsigned(0, OP1_L+1);

	signal Op1N, Op1C	: unsigned(OP1_L - 1 downto 0);
	signal Op2N, Op2C	: unsigned(OP2_L - 1 downto 0);
	signal CmdN, CmdC	: std_logic_vector(CMD_ALU_L - 1 downto 0);
	signal ResN, ResC	: unsigned(OP1_L - 1 downto 0);

	signal SCmp, UCmp	: unsigned(OP1_L - 1 downto 0);

	signal USum		: unsigned(OP1_L+1 - 1 downto 0);
	signal USubN, USubC	: unsigned(OP1_L+1 - 1 downto 0);
	signal SSum		: unsigned(OP1_L+1 - 1 downto 0);
	signal SSubN, SSubC	: unsigned(OP1_L+1 - 1 downto 0);

	signal BAnd, BOr, BXor, BNot	: unsigned(OP1_L - 1 downto 0);

	signal OvflN, OvflC	: std_logic;
	signal UnflN, UnflC	: std_logic;

	signal DoneOp		: std_logic;
	signal UnCmdN, UnCmdC, UnCmdInt		: std_logic;

	signal StateC, StateN: std_logic_vector(STATE_ALU_L - 1 downto 0);

begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then
			Op1C <= (others => '0');
			Op2C <= (others => '0');
			CmdC <= CMD_ALU_DISABLE;
			SSubC <= (others => '0');
			USubC <= (others => '0');
			OvflC <= '0';
			UnflC <= '0';
			UnCmdC <= '0';
			ResC <= (others => '0');
			StateC <= ALU_IDLE;
		elsif (clk'event) and (clk = '1') then
			Op1C <= Op1N;
			Op2C <= Op2N;
			CmdC <= CmdN;
			SSubC <= SSubN;
			USubC <= USubN;
			OvflC <= OvflN;
			UnflC <= UnflN;
			UnCmdC <= UnCmdN;
			ResC <= ResN;
			StateC <= StateN;
		end if;
	end process reg;

	state_det: process(StateC, Start, DoneOp, UnCmdInt, CmdC, UnCmdC)
	begin
		StateN <= StateC; -- avoid latches
		if (StateC = ALU_IDLE) then
			if (Start = '1') then
				StateN <= COMPUTE;
			else
				StateN <= ALU_IDLE;
			end if;
		elsif (StateC = COMPUTE) then
			if DoneOp = '1' then
				StateN <= ALU_OUTPUT;
			elsif (CmdC = CMD_ALU_UCMP) or (CmdC = CMD_ALU_SCMP) then
				StateN <= COMPARE;
			elsif (UnCmdC = '1') then
				StateN <= ALU_OUTPUT;
			else
				StateN <= COMPUTE;
			end if;
		elsif (StateC = COMPARE) then
			StateN <= ALU_OUTPUT;
		elsif (StateC = ALU_OUTPUT) then
			StateN <= ALU_IDLE;
		else
			StateN <= ALU_IDLE;
		end if;
	end process state_det;

	UnCmdInt <= '0' when (StateC = COMPUTE) and ((CmdC = CMD_ALU_USUM) or (CmdC = CMD_ALU_SSUM) or (CmdC = CMD_ALU_USUB) or (CmdC = CMD_ALU_SSUB) or (CmdC = CMD_ALU_UCMP) or (CmdC = CMD_ALU_SCMP) or (CmdC = CMD_ALU_AND) or (CmdC = CMD_ALU_OR) or (CmdC = CMD_ALU_NOT) or (CmdC = CMD_ALU_XOR)) else '1';

	-- Unsigned operations
	USum <= ("0" & Op1C) + ("0" & Op2C);
	USubN <= ("0" & Op1C) - ("0" & Op2C);

	-- Unsigned comparison
	UCmp <=	(others => '0')			when USubC = ZERO else
		to_unsigned(1, UCmp'length)	when USubC(USubC'length-1) = '0' else
		(others => '1');

	-- Signed operations
	SSum <= unsigned(signed(Op1C(Op1C'length-1 downto Op1C'length-1) & Op1C) + signed(Op2C(Op2C'length-1 downto Op2C'length-1) & Op2C));
	SSubN <= unsigned(signed(Op1C(Op1C'length-1 downto Op1C'length-1) & Op1C) - signed(Op2C(Op2C'length-1 downto Op2C'length-1) & Op2C));

	-- Signed comparison
	SCmp <=	(others => '0')			when SSubC = ZERO else
		to_unsigned(1, SCmp'length)	when SSubC(SSubC'length-1) = '0' else
		(others => '1');

	-- Logical operations
	-- AND
	and_bit: for k in 0 to OP1_L-1 generate 
		BAnd(k) <= Op1C(k) and Op2C(k);
	end generate and_bit;

	-- OR
	or_bit: for k in 0 to OP1_L-1 generate 
		BOr(k) <= Op1C(k) or Op2C(k);
	end generate or_bit;

	-- XOR
	xor_bit: for k in 0 to OP1_L-1 generate 
		BXor(k) <= Op1C(k) xor Op2C(k);
	end generate xor_bit;

	-- NOT
	not_bit: for k in 0 to OP1_L-1 generate 
		BNot(k) <= not Op1C(k);
	end generate not_bit;

	result_proc : process(StateC, SSum, SSubN, USum, USubN, SCmp, UCmp, BNot, BAnd, BOr, BXor, ResC, CmdC)
	begin
		ResN <= ResC;
		if (StateC = COMPUTE) then
			if (CmdC = CMD_ALU_USUM) then
				ResN <= USum(USum'length-1 - 1 downto 0);
			elsif (CmdC = CMD_ALU_SSUM) then
				ResN <= SSum(SSum'length-1 - 1 downto 0);
			elsif (CmdC = CMD_ALU_USUB) then
				ResN <= USubN(USubN'length-1 - 1 downto 0);
			elsif (CmdC = CMD_ALU_SSUB) then
				ResN <= SSubN(SSubN'length-1 - 1 downto 0);
			elsif(CmdC = CMD_ALU_AND) then
				ResN <= BAnd;
			elsif(CmdC = CMD_ALU_NOT) then
				ResN <= BNot;
			elsif(CmdC = CMD_ALU_OR) then
				ResN <= BOr;
			elsif(CmdC = CMD_ALU_XOR) then
				ResN <= BXor;
			else
				ResN <= (others => '0');
			end if;
		elsif (StateC = COMPARE) then
			if (CmdC = CMD_ALU_SCMP) then
				ResN <= SCmp;
			elsif (CmdC = CMD_ALU_UCMP) then
				ResN <= UCmp;
			else
				ResN <= (others => '0');
			end if;
		elsif (StateC = ALU_OUTPUT) then
			ResN <= ResC;
		else
			ResN <= ResC;
		end if;
	end process result_proc;

	unfl_proc : process(StateC, SSum, SSubN, USubN, Op1C, Op2C, UnflC, CmdC)
	begin
		UnflN <= UnflC;

		if (StateC = ALU_IDLE) then
			UnflN <= '0';
		elsif (StateC = COMPUTE) then
			if (CmdC = CMD_ALU_SSUM) then
				if ((Op1C(Op1C'length-1) = '0') and ((Op2C(Op2C'length-1)) = '0') and (SSum(SSum'length-2) = '1')) then
					UnflN <= '0';
				elsif (((Op1C(Op1C'length-1) and Op2C(Op2C'length-1)) = '1') and (SSum(SSum'length-2) = '0')) then
					UnflN <= '1';
				else
					UnflN <= '0';
				end if;
			elsif (CmdC = CMD_ALU_USUB) then
				if (USubN(USubN'length-1) = '1') then
					UnflN <= '1';
				else
					UnflN <= '0';
				end if;
			elsif (CmdC = CMD_ALU_SSUB) then
				if (((Op2C(Op2C'length-1) or SSubN(SSubN'length-2)) = '0') and (Op1C(Op1C'length-1) = '1')) then
					UnflN <= '1';
				elsif (((SSubN(SSubN'length-2) and Op2C(Op2C'length-1)) = '1') and (Op1C(Op1C'length-1) = '0')) then
					UnflN <= '0';
				else
					UnflN <= '0';
				end if;
			end if;
		else
			UnflN <= UnflC;
		end if;
	end process unfl_proc;

	ovfl_proc : process(StateC, SSum, SSubN, USum, Op1C, Op2C, OvflC, CmdC)
	begin
		OvflN <= OvflC;

		if (StateC = ALU_IDLE) then
			OvflN <= '0';
		elsif (StateC = COMPUTE) then
			if (CmdC = CMD_ALU_USUM) then
				if (USum(USum'length-1) = '1') then
					OvflN <= '1';
				else
					OvflN <= '0';
				end if;
			elsif (CmdC = CMD_ALU_SSUM) then
				if ((Op1C(Op1C'length-1) = '0') and ((Op2C(Op2C'length-1)) = '0') and (SSum(SSum'length-2) = '1')) then
					OvflN <= '1';
				elsif (((Op1C(Op1C'length-1) and Op2C(Op2C'length-1)) = '1') and (SSum(SSum'length-2) = '0')) then
					OvflN <= '0';
				else
					OvflN <= '0';
				end if;
			elsif (CmdC = CMD_ALU_SSUB) then
				if (((Op2C(Op2C'length-1) or SSubN(SSubN'length-2)) = '0') and (Op1C(Op1C'length-1) = '1')) then
					OvflN <= '0';
				elsif (((SSubN(SSubN'length-2) and Op2C(Op2C'length-1)) = '1') and (Op1C(Op1C'length-1) = '0')) then
					OvflN <= '1';
				else
					OvflN <= '0';
				end if;
			end if;
		else
			OvflN <= OvflC;
		end if;
	end process ovfl_proc;

	done_proc : process(StateC, CmdC)
	begin
		DoneOp <= '0';

		if (StateC = COMPUTE) then
			if ((CmdC = CMD_ALU_USUM) or (CmdC = CMD_ALU_SSUM) or (CmdC = CMD_ALU_USUB) or (CmdC = CMD_ALU_SSUB) or (CmdC = CMD_ALU_AND) or (CmdC = CMD_ALU_NOT) or (CmdC = CMD_ALU_OR) or (CmdC = CMD_ALU_XOR)) then
				DoneOp <= '1';
			else
				DoneOp <= '0';
			end if;
		elsif (StateC = COMPARE) then
			if ((CmdC = CMD_ALU_SCMP) or (CmdC = CMD_ALU_UCMP)) then
				DoneOp <= '1';
			else
				DoneOp <= '0';
			end if;
		elsif (StateC = ALU_OUTPUT) then
			DoneOp <= '0';
		else
			DoneOp <= '0';
		end if;
	end process done_proc;

	Op1N <= unsigned(Op1) when (StateC = ALU_IDLE) else Op1C;
	Op2N <= unsigned(Op2) when (StateC = ALU_IDLE) else Op2C;
	CmdN <= Cmd when (StateC = ALU_IDLE) else CmdC;
	UnCmdN <= UnCmdInt when (StateC = ALU_IDLE) else UnCmdC;

	-- Assert flags when result is put on the output line
	Unfl <= UnflC when (StateC = ALU_OUTPUT) else '0';
	Ovfl <= OvflC when (StateC = ALU_OUTPUT) else '0';
	UnCmd <= UnCmdC when (StateC = ALU_OUTPUT) else '0';

	Done <= '1' when (StateC = ALU_OUTPUT) else '0';

	Res <= std_logic_vector(ResC) when (StateC = ALU_OUTPUT) else (others => '0');

end rtl; 
