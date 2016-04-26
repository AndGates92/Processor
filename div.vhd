library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.alu_pkg.all;
use work.proc_pkg.all;

entity div is
generic (
	OP1_L	: positive := 16;
	OP2_L	: positive := 16
);
port (
	rst		: in std_logic;
	clk		: in std_logic;
	Dividend	: in std_logic_vector(OP1_L - 1 downto 0);
	Divisor		: in std_logic_vector(OP2_L - 1 downto 0);
	Start		: in std_logic;
	Done		: out std_logic;
	Quotient	: out std_logic_vector(OP1_L - 1 downto 0);
	Remainder	: out std_logic_vector(OP2_L - 1 downto 0)
);
end entity div;

architecture non_restoring of div is

	constant zero_op1 : unsigned(OP1_L-1 downto 0) := (others => '0');
	constant zero_op2 : unsigned(OP2_L-1 downto 0) := (others => '0');

	signal DivisorN, DivisorC	: unsigned(OP2_L-1 - 1 downto 0);
	signal SignC, SignN, Sign	: std_logic;
	signal SignDvdC, SignDvdN	: std_logic;
	signal QuotC, QuotN		: unsigned(OP1_L-1 - 1 downto 0);
	signal RemN, RemC, RemProp	: signed(OP2_L - 1 downto 0);
--	signal QuotOut			: unsigned(OP1_L - 1 downto 0);
--	signal RemOut			: unsigned(OP2_L - 1 downto 0);

	signal Dividend_2comp	: unsigned(OP1_L-1 - 1 downto 0);
	signal Divisor_2comp	: unsigned(OP2_L-1 - 1 downto 0);

	signal DividendProp	: unsigned(OP1_L-1 - 1 downto 0);
	signal DivisorProp	: unsigned(OP2_L-1 - 1 downto 0);

	signal ZeroDvdN, ZeroDvdC, ZeroDvd	: std_logic;
	signal ZeroDvsN, ZeroDvsC, ZeroDvs	: std_logic;

	signal StateC, StateN: std_logic_vector(STATE_L - 1 downto 0);

	signal CountC, CountN: unsigned(int_to_bit_num(OP2_L-2)-1 downto 0);

begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then
			DivisorC <= (others => '0');
			SignC <= '0';
			SignDvdC <= '0';
			CountC <= (others => '0');
			StateC <= IDLE;
			QuotC <= (others => '0');
			RemC <= (others => '0');
			ZeroDvsC <= '0';
			ZeroDvdC <= '0';
		elsif ((clk'event) and (clk = '1')) then
			DivisorC <= DivisorN;
			SignC <= SignN;
			StateC <= StateN;
			CountC <= CountN;
			QuotC <= QuotN;
			RemC <= RemN;
			SignDvdC <= SignDvdN;
			ZeroDvsC <= ZeroDvsN;
			ZeroDvdC <= ZeroDvdN;
		end if;
	end process reg;

	state_det: process(StateC, Start, CountC, Dividend, Divisor)
	begin
		StateN <= StateC; -- avoid latches
		if (StateC = IDLE) then
			if (Start = '1') then
				if (unsigned(Dividend) = zero_op1) or (unsigned(Divisor) = zero_op2) then -- fast track in case of zero input
					StateN <= OUTPUT;
				else
					StateN <= COMPUTE_FIRST;
				end if;
			end if;
		elsif (StateC = COMPUTE_FIRST) then
			StateN <= COMPUTE;
		elsif (StateC = COMPUTE) then
			if CountC = to_unsigned(OP2_L - 3, CountC'length) then
				StateN <= COMPUTE_LAST;
			else
				StateN <= COMPUTE;
			end if;
		elsif (StateC = COMPUTE_LAST) then
			StateN <= OUTPUT;
		elsif (StateC = OUTPUT) then
			StateN <= IDLE;
		else
			StateN <= StateC;
		end if;
	end process state_det;

	ZeroDvd <=	'1' when unsigned(Dividend) = zero_op1 else
			'0';

	ZeroDvs <=	'1' when unsigned(Divisor) = zero_op2 else
			'0';

	Dividend_2comp <= 	(not unsigned(Dividend(OP1_L-1 - 1 downto 0)) + 1);

	DividendProp <= 	unsigned(Dividend(OP1_L-1 -1 downto 0)) when Dividend(OP1_L - 1) = '0' else
				Dividend_2comp;

	Divisor_2comp <= 	(not unsigned(Divisor(OP2_L-1 - 1 downto 0)) + 1);

	DivisorProp <= 	unsigned(Divisor(OP2_L-1 -1 downto 0)) when Divisor(OP2_L - 1) = '0' else
			Divisor_2comp;

	RemProp <=	(RemC(RemC'length-1 - 1 downto 0) & signed(QuotC(QuotC'length - 1 downto QuotC'length - 1))) + signed("0" & DivisorC) when RemC(RemC'length - 1) = '1' else
			(RemC(RemC'length-1 - 1 downto 0) & signed(QuotC(QuotC'length - 1 downto QuotC'length - 1))) - signed("0" & DivisorC);

	Sign <=  Dividend(OP1_L - 1) xor Divisor(OP2_L - 1);

	data: process(QuotC, RemC, SignC, SignDvdC, StateC, CountC, DivisorC, RemProp, DivisorProp, DividendProp, Sign, Dividend, ZeroDvdC, ZeroDvsC, ZeroDvd, ZeroDvs)
	begin
		-- avoid latches
		DivisorN <= DivisorC;
		SignN <= SignC;
		SignDvdN <= SignDvdC;
		CountN <= CountC;
		QuotN <= QuotC;
		RemN <= RemC;
		ZeroDvsN <= ZeroDvsC;
		ZeroDvdN <= ZeroDvdC;

		if (StateC = IDLE) then
			DivisorN <= DivisorProp;
			QuotN <= DividendProp(DividendProp'length -1 downto 0);
			RemN <= (others => '0');
			SignN <= Sign;
			SignDvdN <= Dividend(OP1_L - 1);
			CountN <= (others => '0');
			ZeroDvdN <= ZeroDvd;
			ZeroDvsN <= ZeroDvs;
		elsif (StateC = COMPUTE_FIRST) then
			RemN <= RemProp;
			QuotN <= QuotC(QuotC'length-1 - 1 downto 0) & "0";
		elsif (StateC = COMPUTE) then
			CountN <= CountC + 1;
			QuotN <= QuotC(QuotC'length-1 - 1 downto 1) & (not unsigned(RemC(RemC'length - 1 downto RemC'length - 1))) & "0";
			RemN <= RemProp;
		elsif (StateC = COMPUTE_LAST) then
			QuotN <= QuotC(QuotC'length - 1 downto 1) & (not unsigned(RemC(RemC'length - 1 downto RemC'length - 1)));
			if RemC(RemC'length - 1) = '1' then
				RemN <= RemC + signed("0" & DivisorC);
			else
				RemN <= RemC;
			end if;
		elsif (StateC = OUTPUT) then
			RemN <= RemC;
			QuotN <= QuotC;
		else
			DivisorN <= DivisorC;
			SignN <= SignC;
			CountN <= CountC;
			QuotN <= QuotC;
			RemN <= RemC;
		end if;
	end process data;

	Done <=	'1' when StateC = OUTPUT else 
		'0';

--	QuotOut <=	("0" & QuotC) when SignC = '0' else
--			("1" & not QuotC) + 1;

--	Quotient <= 	std_logic_vector(QuotOut) when StateC = OUTPUT else 
--			(others => '0');

--	RemOut <=	unsigned(RemC) when SignDvdC = '0' else
--			(not unsigned(RemC)) + 1;

--	Remainder <= 	std_logic_vector(RemC) when StateC = OUTPUT else 
--			(others => '0');

	Quotient <=	(others => '1')									when StateC = OUTPUT and ZeroDvsC = '1' and ZeroDvdC = '1' else 
			std_logic_vector(to_unsigned((2**(Quotient'length-1)-1), Quotient'length)) 	when StateC = OUTPUT and ZeroDvsC = '1' and SignC = '0' else
			std_logic_vector(to_signed(-(2**(Quotient'length-1)-1), Quotient'length)) 	when StateC = OUTPUT and ZeroDvsC = '1' and SignC = '1' else
			std_logic_vector("0" & QuotC) 							when StateC = OUTPUT and SignC = '0' and ZeroDvdC = '0' and ZeroDvsC = '0' else
			std_logic_vector(("1" & not QuotC) + 1)						when StateC = OUTPUT and SignC = '1' and ZeroDvdC = '0' and ZeroDvsC = '0' else
			(others => '0');

	Remainder <= 	std_logic_vector((not unsigned(RemC)) + 1)	when StateC = OUTPUT and SignDvdC = '1' and ZeroDvdC = '0' and ZeroDvsC = '0' else
			std_logic_vector(RemC) 				when StateC = OUTPUT and SignDvdC = '0' and ZeroDvdC = '0' and ZeroDvsC = '0' else
			(others => '0');
end non_restoring;
