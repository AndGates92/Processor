library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.alu_pkg.all;
use work.proc_pkg.all;

entity div is
generic (
	DIVD_L	: positive := 16;
	DIVR_L	: positive := 16
);
port (
	rst		: in std_logic;
	clk		: in std_logic;
	Dividend	: in std_logic_vector(DIVD_L - 1 downto 0);
	Divisor		: in std_logic_vector(DIVR_L - 1 downto 0);
	Start		: in std_logic;
	Done		: out std_logic;
	Quotient	: out std_logic_vector(DIVD_L - 1 downto 0);
	Remainder	: out std_logic_vector(DIVR_L - 1 downto 0)
);
end entity div;

architecture non_restoring of div is

	constant OP_L : integer := max_int(DIVD_L, DIVR_L);
	constant zero_divd : unsigned(OP_L-1 downto 0) := (others => '0');
	constant zero_divr : unsigned(OP_L-1 downto 0) := (others => '0');

	signal DivisorN, DivisorC	: unsigned(OP_L-1 - 1 downto 0);
	signal SignC, SignN, Sign	: std_logic;
	signal SignDvdC, SignDvdN	: std_logic;
	signal QuotC, QuotN		: unsigned(OP_L-1 - 1 downto 0);
	signal RemN, RemC, RemProp	: signed(OP_L - 1 downto 0);

	signal Dividend_2comp	: unsigned(OP_L-1 - 1 downto 0);
	signal Divisor_2comp	: unsigned(OP_L-1 - 1 downto 0);

	signal DividendProp	: unsigned(OP_L-1 - 1 downto 0);
	signal DivisorProp	: unsigned(OP_L-1 - 1 downto 0);

	signal ext_divr		: unsigned(OP_L - 1 downto 0);
	signal ext_divd		: unsigned(OP_L - 1 downto 0);

	signal ZeroDvdN, ZeroDvdC, ZeroDvd	: std_logic;
	signal ZeroDvsN, ZeroDvsC, ZeroDvs	: std_logic;

	signal StateC, StateN: std_logic_vector(STATE_ALU_L - 1 downto 0);

	signal CountC, CountN: unsigned(int_to_bit_num(OP_L-2)-1 downto 0);

begin

	-- Extend operands to make sure they have the same length
	ext_dividend : if (DIVD_L <=  DIVR_L) generate
		ext_divd(DIVD_L-2 downto 0) <= unsigned(Dividend(DIVD_L-2 downto 0));
		ext_divd(OP_L-1 downto DIVD_L-1) <= (others => Dividend(DIVD_L-1));
		ext_divr <= unsigned(Divisor);
	end generate ext_dividend;

	ext_divisor : if (DIVD_L > DIVR_L) generate
		ext_divr(DIVR_L-2 downto 0) <= unsigned(Divisor(DIVR_L-2 downto 0));
		ext_divr(OP_L-1 downto DIVR_L-1) <= (others => Divisor(DIVR_L-1));
		ext_divd <= unsigned(Dividend);
	end generate ext_divisor;


	reg: process(rst, clk)
	begin
		if (rst = '1') then
			DivisorC <= (others => '0');
			SignC <= '0';
			SignDvdC <= '0';
			CountC <= (others => '0');
			StateC <= ALU_IDLE;
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

	state_det: process(StateC, Start, CountC, ext_divd, ext_divr)
	begin
		StateN <= StateC; -- avoid latches
		if (StateC = ALU_IDLE) then
			if (Start = '1') then
				if (ext_divd = zero_divd) or (ext_divr = zero_divr) then -- fast track in case of zero input
					StateN <= ALU_OUTPUT;
				else
					StateN <= COMPUTE_FIRST;
				end if;
			end if;
		elsif (StateC = COMPUTE_FIRST) then
			StateN <= COMPUTE;
		elsif (StateC = COMPUTE) then
			if CountC = to_unsigned(OP_L - 3, CountC'length) then
				StateN <= COMPUTE_LAST;
			else
				StateN <= COMPUTE;
			end if;
		elsif (StateC = COMPUTE_LAST) then
			StateN <= ALU_OUTPUT;
		elsif (StateC = ALU_OUTPUT) then
			StateN <= ALU_IDLE;
		else
			StateN <= StateC;
		end if;
	end process state_det;

	ZeroDvd <=	'1' when ext_divd = zero_divd else
			'0';

	ZeroDvs <=	'1' when ext_divr = zero_divr else
			'0';

	-- Make operand unsigned
	Dividend_2comp <= 	(not unsigned(ext_divd(OP_L-1 - 1 downto 0)) + 1);


	DividendProp <= 	unsigned(ext_divd(OP_L-1 -1 downto 0)) when ext_divd(OP_L - 1) = '0' else
				Dividend_2comp;

	Divisor_2comp <= 	(not unsigned(ext_divr(OP_L-1 - 1 downto 0)) + 1);

	DivisorProp <= 	unsigned(ext_divr(OP_L-1 -1 downto 0)) when ext_divr(OP_L - 1) = '0' else
			Divisor_2comp;

	RemProp <=	(RemC(RemC'length-1 - 1 downto 0) & signed(QuotC(QuotC'length - 1 downto QuotC'length - 1))) + signed("0" & DivisorC) when RemC(RemC'length - 1) = '1' else
			(RemC(RemC'length-1 - 1 downto 0) & signed(QuotC(QuotC'length - 1 downto QuotC'length - 1))) - signed("0" & DivisorC);

	-- Sign bit
	Sign <=  ext_divd(OP_L - 1) xor ext_divr(OP_L - 1);

	data: process(QuotC, RemC, SignC, SignDvdC, StateC, CountC, DivisorC, RemProp, DivisorProp, DividendProp, Sign, ext_divd, ZeroDvdC, ZeroDvsC, ZeroDvd, ZeroDvs)
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

		if (StateC = ALU_IDLE) then
			DivisorN <= DivisorProp;
			QuotN <= DividendProp(DividendProp'length -1 downto 0);
			RemN <= (others => '0');
			SignN <= Sign;
			SignDvdN <= ext_divd(OP_L - 1);
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
		elsif (StateC = ALU_OUTPUT) then
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

	Done <=	'1' when StateC = ALU_OUTPUT else 
		'0';

	Quotient <=	(others => '1')									when StateC = ALU_OUTPUT and ZeroDvsC = '1' and ZeroDvdC = '1' else 
			std_logic_vector(to_unsigned((2**(Quotient'length-1)-1), Quotient'length)) 	when StateC = ALU_OUTPUT and ZeroDvsC = '1' and SignC = '0' else
			std_logic_vector(to_signed(-(2**(Quotient'length-1)-1), Quotient'length)) 	when StateC = ALU_OUTPUT and ZeroDvsC = '1' and SignC = '1' else
			std_logic_vector("0" & QuotC(DIVD_L-1 - 1 downto 0)) 				when StateC = ALU_OUTPUT and SignC = '0' and ZeroDvdC = '0' and ZeroDvsC = '0' else
			std_logic_vector(("1" & not QuotC(DIVD_L-1 - 1 downto 0)) + 1)			when StateC = ALU_OUTPUT and SignC = '1' and ZeroDvdC = '0' and ZeroDvsC = '0' else
			(others => '0');

	Remainder <= 	std_logic_vector((not unsigned(RemC(DIVR_L-1 downto 0))) + 1)		when StateC = ALU_OUTPUT and SignDvdC = '1' and ZeroDvdC = '0' and ZeroDvsC = '0' else
			std_logic_vector(RemC(DIVR_L-1 downto 0)) 				when StateC = ALU_OUTPUT and SignDvdC = '0' and ZeroDvdC = '0' and ZeroDvsC = '0' else
			(others => '0');
end non_restoring;
