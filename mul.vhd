library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.alu_pkg.all;

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

	constant multiplicand : integer :=  sel_multiplicand(OP1_L, OP2_L);
	constant multiplier : integer := calc_length_multiplier(OP1_L, OP2_L, 2, multiplicand);

	constant zero_op1 : unsigned(OP1_L-1 downto 0) := (others => '0');
	constant zero_op2 : unsigned(OP2_L-1 downto 0) := (others => '0');

	signal AddN, AddC, SubN, SubC, ProdN, ProdC	: unsigned(OP1_L+OP2_L+1 - 1 downto 0);
	signal Sum, Diff, Sum_Shift, Diff_Shift		: unsigned(OP1_L+OP2_L+1 - 1 downto 0);
	signal tmp 					: unsigned(OP1_L+OP2_L+1 - 1 downto 0);

	signal Op1_2comp	: unsigned(OP1_L - 1 downto 0);

	type state_list is (IDLE, INIT, COMPUTE, OUTPUT);
	signal StateC, StateN: state_list;

	signal CountC, CountN: unsigned(count_length(OP2_L)-1 downto 0);

begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then
			AddC <= (others => '0');
			SubC <= (others => '0');
			ProdC <= (others => '0');
			CountC <= (others => '0');
			StateC <= IDLE;
		elsif (rising_edge(clk)) then
			AddC <= AddN;
			SubC <= SubN;
			ProdC <= ProdN;
			StateC <= StateN;
			CountC <= CountN;
		end if;
	end process reg;

	state_det: process(StateC, Start, CountC)
	begin
		StateN <= StateC; -- avoid latches
		case StateC is
			when IDLE =>
				if (Start = '1') then
					if (unsigned(Op1) = zero_op1) or (unsigned(Op2) = zero_op2) then -- fast track in case of zero input
						StateN <= OUTPUT;
					else
						StateN <= INIT;
					end if;
				end if;
			when INIT =>
				StateN <= COMPUTE;
			when COMPUTE =>
				if CountC = to_unsigned(OP2_L - 1, CountC'length) then
					StateN <= OUTPUT;
				else
					StateN <= COMPUTE;
				end if;
			when OUTPUT =>
				StateN <= IDLE;
			when others =>
				StateN <= StateC;
		end case;
	end process state_det;

	Op1_2comp <= (not unsigned(Op1)) + 1;

	Sum <= ProdC + AddC;
	Sum_Shift <= ProdC + (AddC(AddC'length-2 downto 0) & "0");

	Diff <= ProdC + SubC;
	Diff_Shift <= ProdC + (SubC(SubC'length-2 downto 0) & "0");

	data: process(ProdC, StateC, CountC, Op1, Op2, tmp)
	begin
		-- avoid latches
		ProdN <= ProdC;
		AddN <= AddC;
		SubN <= SubC;
		CountN <= CountC;
		tmp <= (others => '0');

		case StateC is
			when IDLE =>
				ProdN <= (others => '0');
			when INIT =>
				AddN(AddN'length-1 downto (AddN'length-OP1_L)) <= unsigned(Op1);
				AddN((AddN'length-OP1_L-1) downto 0) <= to_unsigned(0, AddN'length-OP1_L);
				SubN(SubN'length-1 downto (SubN'length-OP1_L)) <= Op1_2comp;
				SubN((SubN'length-OP1_L-1) downto 0) <= to_unsigned(0, SubN'length-OP1_L);
				ProdN(OP2_L downto 0) <= unsigned(Op2 & "0");
				ProdN(ProdN'length-1 downto OP2_L + 1) <= to_unsigned(0,OP1_L);
				CountN <= (others => '0');
			when COMPUTE =>
				CountN <= CountC + 1;
				case ProdC(1 downto 0) is
					when "00"|"11" =>
						tmp <= ProdC;
					when "01" =>
						tmp <= Sum;
					when "10" =>
						tmp <= Diff;
					when others =>
						tmp <= ProdC;
				end case;
				if tmp(tmp'length-1) = '0' then
					ProdN <= "0" & tmp(tmp'length-1 downto 1);
				else
					ProdN <= "1" & tmp(tmp'length-1 downto 1);
				end if;
			when OUTPUT =>
				ProdN <= ProdC;
			when others =>
				ProdN <= ProdC;
		end case;
	end process data;

	Done <= '1' when StateC = OUTPUT else '0';
	Res <= std_logic_vector(ProdC(ProdC'length-1 downto 1)) when StateC = OUTPUT else (others => '0');

end booth_radix2;

architecture booth_radix4 of mul is

	constant multiplicand : integer :=  sel_multiplicand(OP1_L, OP2_L);
	constant multiplier : integer := calc_length_multiplier(OP1_L, OP2_L, 2, multiplicand);

	constant zero_op1 : unsigned(OP1_L-1 downto 0) := (others => '0');
	constant zero_op2 : unsigned(OP2_L-1 downto 0) := (others => '0');

	signal ProdN, ProdC	: unsigned(OP1_L+OP2_L+1 - 1 downto 0);
	signal AddN, AddC, SubN, SubC	: unsigned(OP1_L - 1 downto 0);
	signal Sum, Diff, Sum_Shift, Diff_Shift		: unsigned(OP1_L downto 0);
	signal tmp 					: unsigned(OP1_L+OP2_L+1 - 1 downto 0);

	signal Op1_2comp	: unsigned(OP1_L - 1 downto 0);

	type state_list is (IDLE, INIT, COMPUTE, OUTPUT);
	signal StateC, StateN: state_list;

	signal CountC, CountN: unsigned(count_length(OP2_L/2)-1 downto 0);

begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then
			AddC <= (others => '0');
			SubC <= (others => '0');
			ProdC <= (others => '0');
			CountC <= (others => '0');
			StateC <= IDLE;
		elsif (rising_edge(clk)) then
			AddC <= AddN;
			SubC <= SubN;
			ProdC <= ProdN;
			StateC <= StateN;
			CountC <= CountN;
		end if;
	end process reg;

	state_det: process(StateC, Start, CountC)
	begin
		StateN <= StateC; -- avoid latches
		case StateC is
			when IDLE =>
				if (Start = '1') then
					if (unsigned(Op1) = zero_op1) or (unsigned(Op2) = zero_op2) then -- fast track in case of zero input
						StateN <= OUTPUT;
					else
						StateN <= INIT;
					end if;
				end if;
			when INIT =>
				StateN <= COMPUTE;
			when COMPUTE =>
				if CountC = to_unsigned(OP2_L/2 - 1, CountC'length) then
					StateN <= OUTPUT;
				else
					StateN <= COMPUTE;
				end if;
			when OUTPUT =>
				StateN <= IDLE;
			when others =>
				StateN <= StateC;
		end case;
	end process state_det;

	Op1_2comp <= (not unsigned(Op1)) + 1;

	Sum <= (ProdC(ProdC'length-1 downto ProdC'length-1) & ProdC(ProdC'length-1 downto ((ProdC'length-1)/2)+1))+ (AddC(AddC'length-1 downto AddC'length-1) & AddC);
	Sum_Shift <= (ProdC(ProdC'length-1 downto ProdC'length-1) & ProdC(ProdC'length-1 downto ((ProdC'length-1)/2)+1)) + (AddC & "0");

	Diff <= (ProdC(ProdC'length-1 downto ProdC'length-1) & ProdC(ProdC'length-1 downto ((ProdC'length-1)/2)+1)) + (SubC(SubC'length-1 downto SubC'length-1) & SubC);
	Diff_Shift <= (ProdC(ProdC'length-1 downto ProdC'length-1) & ProdC(ProdC'length-1 downto ((ProdC'length-1)/2)+1)) + (SubC & "0");

	data: process(ProdC, StateC, CountC, Op1, Op2, tmp, AddC, SubC, Sum, Sum_Shift, Diff, Diff_shift)
	begin
		-- avoid latches
		ProdN <= ProdC;
		AddN <= AddC;
		SubN <= SubC;
		CountN <= CountC;
		tmp <= (others => '0');

		case StateC is
			when IDLE =>
				ProdN <= (others => '0');
			when INIT =>
				AddN <= unsigned(Op1);
				SubN <= Op1_2comp;
				ProdN(OP2_L downto 0) <= unsigned(Op2 & "0");
				ProdN(ProdN'length-1 downto OP2_L + 1) <= to_unsigned(0,OP1_L);
				CountN <= (others => '0');
			when COMPUTE =>
				CountN <= CountC + 1;
				case ProdC(2 downto 0) is
					when "000"|"111" =>
						tmp <= ProdC(ProdC'length-1 downto ProdC'length-1) & ProdC(ProdC'length-1 downto 1);
					when "001"|"010" =>
						tmp <= Sum & ProdC(((ProdC'length-1)/2) downto 1);
					when "011" =>
						tmp <= Sum_Shift & ProdC(((ProdC'length-1)/2) downto 1);
					when "100" =>
						tmp <= Diff_Shift & ProdC(((ProdC'length-1)/2) downto 1);
					when "101"|"110" =>
						tmp <= Diff & ProdC(((ProdC'length-1)/2) downto 1);
					when others =>
						tmp <= ProdC;
				end case;
				ProdN <= tmp(tmp'length-1 downto tmp'length-1) & tmp(tmp'length-1 downto 1);
			when OUTPUT =>
				ProdN <= ProdC;
			when others =>
				ProdN <= ProdC;
		end case;
	end process data;

	Done <= '1' when StateC = OUTPUT else '0';
	Res <= std_logic_vector(ProdC(ProdC'length-1 downto 1)) when StateC = OUTPUT else (others => '0');

end booth_radix4;
