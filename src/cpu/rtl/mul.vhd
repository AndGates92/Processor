library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.alu_pkg.all;
use work.functions_pkg.all;

entity mul is
generic (
	OP1_L	: positive := 16;
	OP2_L	: positive := 16
);
port (
	rst	: in std_logic;
	clk	: in std_logic;
	Op1	: in std_logic_vector(OP1_L - 1 downto 0);
	Op2	: in std_logic_vector(OP2_L - 1 downto 0);
	Start	: in std_logic;
	Done	: out std_logic;
	Res	: out std_logic_vector(OP1_L+OP2_L-1 downto 0)
);
end entity mul;

architecture booth_radix2 of mul is

	constant MULTD_L	: integer := min_int(OP1_L, OP2_L);
	constant MULTR_L	: integer := calc_length_multiplier(OP1_L, OP2_L, 2, MULTD_L);
	constant PROD_INT_L	: integer := MULTD_L+MULTR_L+1;

	constant zero_multd : unsigned(MULTD_L-1 downto 0) := (others => '0');
	constant zero_multr : unsigned(MULTR_L-1 downto 0) := (others => '0');

	constant zero_add_sub_lsb	: unsigned((PROD_INT_L-MULTD_L-1) downto 0) := (others => '0');

	signal AddN, AddC, SubN, SubC, ProdN, ProdC	: unsigned(PROD_INT_L - 1 downto 0);
	signal Sum, Diff, Sum_Shift, Diff_Shift		: unsigned(PROD_INT_L - 1 downto 0);
	signal tmp 					: unsigned(PROD_INT_L - 1 downto 0);

	signal ProdLSB		: unsigned(1 downto 0);

	signal multd_2comp	: unsigned(MULTD_L - 1 downto 0);

	signal ProdLowIdle	: unsigned(MULTR_L - 1 downto 0);

	signal StateC, StateN: std_logic_vector(STATE_ALU_L - 1 downto 0);

	signal CountC, CountN: unsigned(int_to_bit_num(MULTR_L)-1 downto 0);

	signal multiplicand	: unsigned(MULTD_L - 1 downto 0);

	signal multiplier	: unsigned(MULTR_L - 1 downto 0);

begin

	op1_multd : if (OP1_L <=  OP2_L) generate
		multiplicand(OP1_L-2 downto 0) <= unsigned(Op1(OP1_L-2 downto 0));
		multiplicand(MULTD_L-1 downto OP1_L-1) <= (others => Op1(OP1_L-1));
		multiplier(OP2_L-2 downto 0) <= unsigned(Op2(OP2_L-2 downto 0));
		multiplier(MULTR_L-1 downto OP2_L-1) <= (others => Op2(OP2_L-1));
	end generate op1_multd;

	op2_multd : if (OP1_L > OP2_L) generate
		multiplicand(OP2_L-2 downto 0) <= unsigned(Op2(OP2_L-2 downto 0));
		multiplicand(MULTD_L-1 downto OP2_L-1) <= (others => Op2(OP2_L-1));
		multiplier(OP1_L-2 downto 0) <= unsigned(Op1(OP1_L-2 downto 0));
		multiplier(MULTR_L-1 downto OP1_L-1) <= (others => Op1(OP1_L-1));
	end generate op2_multd;

	reg: process(rst, clk)
	begin
		if (rst = '1') then
			AddC <= (others => '0');
			SubC <= (others => '0');
			ProdC <= (others => '0');
			CountC <= (others => '0');
			StateC <= ALU_IDLE;
		elsif (clk'event) and (clk = '1') then
			AddC <= AddN;
			SubC <= SubN;
			ProdC <= ProdN;
			StateC <= StateN;
			CountC <= CountN;
		end if;
	end process reg;

	state_det: process(StateC, Start, CountC, multiplicand, multiplier)
	begin
		StateN <= StateC; -- avoid latches
		if (StateC = ALU_IDLE) then
			if (Start = '1') then
				if (multiplicand = zero_multd) or (multiplier = zero_multr) then -- fast track in case of zero input
					StateN <= ALU_OUTPUT;
				else
					StateN <= COMPUTE;
				end if;
			end if;
		elsif (StateC = COMPUTE) then
			if CountC = to_unsigned(MULTR_L - 1, CountC'length) then
				StateN <= ALU_OUTPUT;
			else
				StateN <= COMPUTE;
			end if;
		elsif (StateC = ALU_OUTPUT) then
			StateN <= ALU_IDLE;
		else
			StateN <= StateC;
		end if;
	end process state_det;

	multd_2comp <= (not unsigned(multiplicand)) + 1;

	Sum <= ProdC + AddC;
	Sum_Shift <= ProdC + (AddC(AddC'length-2 downto 0) & "0");

	Diff <= ProdC + SubC;
	Diff_Shift <= ProdC + (SubC(SubC'length-2 downto 0) & "0");

	ProdLowIdle <= (others => '0') when (unsigned(multiplicand) = zero_multd) else unsigned(multiplier);

	prod_proc: process(ProdC, StateC, tmp, ProdLowIdle)
	begin
		-- avoid latches
		ProdN <= ProdC;

		if (StateC = ALU_IDLE) then
			ProdN(MULTR_L downto 0) <= ProdLowIdle & "0";
			ProdN(ProdN'length-1 downto MULTR_L + 1) <= to_unsigned(0,(ProdN'length - MULTR_L - 1));
		elsif (StateC = COMPUTE) then
			ProdN <= tmp(tmp'length-1 downto tmp'length-1) & tmp(tmp'length-1 downto 1);
		elsif (StateC = ALU_OUTPUT) then
			ProdN <= ProdC;
		else
			ProdN <= ProdC;
		end if;
	end process prod_proc;

	ProdLSB <= ProdC(1 downto 0);

	tmp <=	Sum when (ProdLSB = "01") else
		Diff when (ProdLSB = "10") else
		ProdC;

	AddN <= unsigned(multiplicand) & zero_add_sub_lsb when (StateC = ALU_IDLE) else AddC;
	SubN <= multd_2comp & zero_add_sub_lsb when (StateC = ALU_IDLE) else SubC;

	CountN <= (CountC + 1) when (StateC = COMPUTE) else (others => '0');

	Done <= '1' when StateC = ALU_OUTPUT else '0';
	Res <= std_logic_vector(ProdC(ProdC'length-1 downto ProdC'length-1) & ProdC(OP1_L+OP2_L-1 downto 1)) when StateC = ALU_OUTPUT else (others => '0');

end booth_radix2;

architecture booth_radix4 of mul is

	constant MULTD_L : integer := min_int(OP1_L, OP2_L);
	constant MULTR_L : integer := calc_length_multiplier(OP1_L, OP2_L, 2, MULTD_L);

	constant zero_multd : unsigned(MULTD_L-1 downto 0) := (others => '0');
	constant zero_multr : unsigned(MULTR_L-1 downto 0) := (others => '0');

	signal ProdN, ProdC	: unsigned(MULTD_L+MULTR_L+1 - 1 downto 0);
	signal AddN, AddC, SubN, SubC	: unsigned(MULTD_L - 1 downto 0);
	signal Sum, Diff, Sum_Shift, Diff_Shift		: unsigned(MULTD_L downto 0);
	signal tmp 					: unsigned(MULTD_L+MULTR_L+1 - 1 downto 0);

	signal ProdLSB		: unsigned(2 downto 0);

	signal ProdLowIdle	: unsigned(MULTR_L - 1 downto 0);

	signal multd_2comp	: unsigned(MULTD_L - 1 downto 0);

	signal StateC, StateN: std_logic_vector(STATE_ALU_L - 1 downto 0);

	signal CountC, CountN: unsigned(int_to_bit_num(MULTR_L/2)-1 downto 0);

	signal multiplicand	: unsigned(MULTD_L - 1 downto 0);

	signal multiplier	: unsigned(MULTR_L - 1 downto 0);

begin

	op1_multd : if (OP1_L <=  OP2_L) generate
		multiplicand(OP1_L-2 downto 0) <= unsigned(Op1(OP1_L-2 downto 0));
		multiplicand(MULTD_L-1 downto OP1_L-1) <= (others => Op1(OP1_L-1));
		multiplier(OP2_L-2 downto 0) <= unsigned(Op2(OP2_L-2 downto 0));
		multiplier(MULTR_L-1 downto OP2_L-1) <= (others => Op2(OP2_L-1));
	end generate op1_multd;

	op2_multd : if (OP1_L > OP2_L) generate
		multiplicand(OP2_L-2 downto 0) <= unsigned(Op2(OP2_L-2 downto 0));
		multiplicand(MULTD_L-1 downto OP2_L-1) <= (others => Op2(OP2_L-1));
		multiplier(OP1_L-2 downto 0) <= unsigned(Op1(OP1_L-2 downto 0));
		multiplier(MULTR_L-1 downto OP1_L-1) <= (others => Op1(OP1_L-1));
	end generate op2_multd;

	reg: process(rst, clk)
	begin
		if (rst = '1') then
			AddC <= (others => '0');
			SubC <= (others => '0');
			ProdC <= (others => '0');
			CountC <= (others => '0');
			StateC <= ALU_IDLE;
		elsif (clk'event) and (clk = '1') then
			AddC <= AddN;
			SubC <= SubN;
			ProdC <= ProdN;
			StateC <= StateN;
			CountC <= CountN;
		end if;
	end process reg;

	state_det: process(StateC, Start, CountC, multiplicand, multiplier)
	begin
		StateN <= StateC; -- avoid latches
		if (StateC = ALU_IDLE) then
			if (Start = '1') then
				if (unsigned(multiplicand) = zero_multd) or (unsigned(multiplier) = zero_multr) then -- fast track in case of zero input
					StateN <= ALU_OUTPUT;
				else
					StateN <= COMPUTE;
				end if;
			end if;
		elsif (StateC = COMPUTE) then
			if CountC = to_unsigned(MULTR_L/2 - 1, CountC'length) then
				StateN <= ALU_OUTPUT;
			else
				StateN <= COMPUTE;
			end if;
		elsif (StateC = ALU_OUTPUT) then
			StateN <= ALU_IDLE;
		else
			StateN <= StateC;
		end if;
	end process state_det;

	multd_2comp <= (not unsigned(multiplicand)) + 1;

	Sum <= (ProdC(ProdC'length-1 downto ProdC'length-1) & ProdC(ProdC'length-1 downto (ProdC'length-MULTD_L)))+ (AddC(AddC'length-1 downto AddC'length-1) & AddC);
	Sum_Shift <= (ProdC(ProdC'length-1 downto ProdC'length-1) & ProdC(ProdC'length-1 downto (ProdC'length-MULTD_L))) + (AddC & "0");

	Diff <= (ProdC(ProdC'length-1 downto ProdC'length-1) & ProdC(ProdC'length-1 downto (ProdC'length-MULTD_L))) + (SubC(SubC'length-1 downto SubC'length-1) & SubC);
	Diff_Shift <= (ProdC(ProdC'length-1 downto ProdC'length-1) & ProdC(ProdC'length-1 downto (ProdC'length-MULTD_L))) + (SubC & "0");

	ProdLowIdle <= (others => '0') when (unsigned(multiplicand) = zero_multd) else unsigned(multiplier);

	prod_proc: process(ProdC, StateC, tmp, ProdLowIdle)
	begin
		-- avoid latches
		ProdN <= ProdC;

		if (StateC = ALU_IDLE) then
			ProdN(MULTR_L downto 0) <= ProdLowIdle & "0";
			ProdN(ProdN'length-1 downto MULTR_L + 1) <= to_unsigned(0,MULTD_L);
		elsif (StateC = COMPUTE) then
			ProdN <= tmp(tmp'length-1 downto tmp'length-1) & tmp(tmp'length-1 downto 1);
		elsif (StateC = ALU_OUTPUT) then
			ProdN <= ProdC;
		else
			ProdN <= ProdC;
		end if;
	end process prod_proc;

	ProdLSB <= ProdC(2 downto 0);

	tmp <=	Sum & ProdC(MULTR_L downto 1) when ((ProdLSB = "010") or (ProdLSB = "001")) else
		Sum_Shift & ProdC(MULTR_L downto 1) when (ProdLSB = "011") else
		Diff & ProdC(MULTR_L downto 1) when ((ProdLSB = "101") or (ProdLSB = "110")) else
		Diff_Shift & ProdC(MULTR_L downto 1) when (ProdLSB = "100") else
		ProdC(ProdC'length-1 downto ProdC'length-1) & ProdC(ProdC'length-1 downto 1);

	AddN <= unsigned(multiplicand) when (StateC = ALU_IDLE) else AddC;
	SubN <= multd_2comp when (StateC = ALU_IDLE) else SubC;

	CountN <= (CountC + 1) when (StateC = COMPUTE) else (others => '0');


	Done <= '1' when StateC = ALU_OUTPUT else '0';
	Res <= std_logic_vector(ProdC(ProdC'length-1 downto ProdC'length-1) & ProdC(OP1_L+OP2_L-1 downto 1)) when StateC = ALU_OUTPUT else (others => '0');

end booth_radix4;
