library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

package alu_pkg is 

	constant CMD_ALU_L	: positive := 4;

	constant CMD_ALU_USUM		: std_logic_vector(CMD_ALU_L - 1 downto 0) := std_logic_vector(to_unsigned(0,CMD_ALU_L));
	constant CMD_ALU_SSUM		: std_logic_vector(CMD_ALU_L - 1 downto 0) := std_logic_vector(to_unsigned(1,CMD_ALU_L));
	constant CMD_ALU_USUB		: std_logic_vector(CMD_ALU_L - 1 downto 0) := std_logic_vector(to_unsigned(2,CMD_ALU_L));
	constant CMD_ALU_SSUB		: std_logic_vector(CMD_ALU_L - 1 downto 0) := std_logic_vector(to_unsigned(3,CMD_ALU_L));
	constant CMD_ALU_UCMP		: std_logic_vector(CMD_ALU_L - 1 downto 0) := std_logic_vector(to_unsigned(4,CMD_ALU_L));
	constant CMD_ALU_SCMP		: std_logic_vector(CMD_ALU_L - 1 downto 0) := std_logic_vector(to_unsigned(5,CMD_ALU_L));
	constant CMD_ALU_AND		: std_logic_vector(CMD_ALU_L - 1 downto 0) := std_logic_vector(to_unsigned(6,CMD_ALU_L));
	constant CMD_ALU_OR		: std_logic_vector(CMD_ALU_L - 1 downto 0) := std_logic_vector(to_unsigned(7,CMD_ALU_L));
	constant CMD_ALU_XOR		: std_logic_vector(CMD_ALU_L - 1 downto 0) := std_logic_vector(to_unsigned(8,CMD_ALU_L));
	constant CMD_ALU_NOT		: std_logic_vector(CMD_ALU_L - 1 downto 0) := std_logic_vector(to_unsigned(9,CMD_ALU_L));
	constant CMD_ALU_SHIFT		: std_logic_vector(CMD_ALU_L - 1 downto 0) := std_logic_vector(to_unsigned(10,CMD_ALU_L));
	constant CMD_ALU_MUL		: std_logic_vector(CMD_ALU_L - 1 downto 0) := std_logic_vector(to_unsigned(11,CMD_ALU_L));
	constant CMD_ALU_DIV		: std_logic_vector(CMD_ALU_L - 1 downto 0) := std_logic_vector(to_unsigned(12,CMD_ALU_L));
	constant CMD_ALU_DISABLE	: std_logic_vector(CMD_ALU_L - 1 downto 0) := std_logic_vector(to_unsigned(integer(2.0**(real(CMD_ALU_L)) - 1.0),CMD_ALU_L));

	constant STATE_ALU_L	: positive := 3;

	constant ALU_IDLE	: std_logic_vector(STATE_ALU_L - 1 downto 0) := std_logic_vector(to_unsigned(0, STATE_ALU_L));
	constant ALU_OUTPUT	: std_logic_vector(STATE_ALU_L - 1 downto 0) := std_logic_vector(to_unsigned(1, STATE_ALU_L));
	constant COMPUTE	: std_logic_vector(STATE_ALU_L - 1 downto 0) := std_logic_vector(to_unsigned(2, STATE_ALU_L));
	constant COMPARE	: std_logic_vector(STATE_ALU_L - 1 downto 0) := std_logic_vector(to_unsigned(3, STATE_ALU_L));
	constant COMPUTE_FIRST	: std_logic_vector(STATE_ALU_L - 1 downto 0) := std_logic_vector(to_unsigned(4, STATE_ALU_L));
	constant COMPUTE_LAST	: std_logic_vector(STATE_ALU_L - 1 downto 0) := std_logic_vector(to_unsigned(5, STATE_ALU_L));

	function calc_length_multiplier (op1_l, op2_l, base : integer; multiplicand : integer) return integer;

	component mul
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
	end component;

	component div
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
		Quotient	: out std_logic_vector(DIVD_L-1 downto 0);
		Remainder	: out std_logic_vector(DIVR_L - 1 downto 0)
	);
	end component;

	component alu
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
	end component;

end package alu_pkg;

package body alu_pkg is

	function calc_length_multiplier (op1_l, op2_l, base : integer; multiplicand : integer) return integer is
		variable multiplier, rem_multiplier	: integer;
		variable length_multiplier	: integer;
		variable length_op		: integer;
	begin
		if (op1_l = multiplicand) then
			multiplier := op2_l;
		elsif (op2_l = multiplicand) then
			multiplier := op1_l;
		else
			report "Error: cannot determine selected input" severity error;
		end if;

		rem_multiplier := (multiplier mod base);

		if (rem_multiplier = 0) then
			length_op := multiplier;
		else
			length_op := multiplier - rem_multiplier + base;
		end if;

		assert rem_multiplier = 0 report ("op width must be a multiple of " & integer'image(base) & ". It is " & integer'image(multiplier) & ". Input will be extended to " & integer'image(length_op)) severity warning;

		return length_op;

	end;

end package body alu_pkg;
