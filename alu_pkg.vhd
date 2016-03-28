library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;

package alu_pkg is 

	constant ALU_CMD_L	: positive := 4;

	constant CMD_USUM	: std_logic_vector(ALU_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(0,ALU_CMD_L));
	constant CMD_SSUM	: std_logic_vector(ALU_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(1,ALU_CMD_L));
	constant CMD_USUB	: std_logic_vector(ALU_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(2,ALU_CMD_L));
	constant CMD_SSUB	: std_logic_vector(ALU_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(3,ALU_CMD_L));
	constant CMD_UCMP	: std_logic_vector(ALU_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(4,ALU_CMD_L));
	constant CMD_SCMP	: std_logic_vector(ALU_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(5,ALU_CMD_L));
	constant CMD_AND	: std_logic_vector(ALU_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(6,ALU_CMD_L));
	constant CMD_OR		: std_logic_vector(ALU_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(7,ALU_CMD_L));
	constant CMD_XOR	: std_logic_vector(ALU_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(8,ALU_CMD_L));
	constant CMD_NOT	: std_logic_vector(ALU_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(9,ALU_CMD_L));
	constant CMD_SHIFT	: std_logic_vector(ALU_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(10,ALU_CMD_L));
	constant CMD_MUL	: std_logic_vector(ALU_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(11,ALU_CMD_L));
	constant CMD_DIV	: std_logic_vector(ALU_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(12,ALU_CMD_L));
	constant CMD_DISABLE	: std_logic_vector(ALU_CMD_L - 1 downto 0) := std_logic_vector(to_unsigned(integer(2.0**(real(ALU_CMD_L)) - 1.0),ALU_CMD_L));

	constant COMPUTE	: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(2, STATE_L));
	constant COMPARE	: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(3, STATE_L));
	constant COMPUTE_FIRST	: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(4, STATE_L));
	constant COMPUTE_LAST	: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(5, STATE_L));

	function calc_length_multiplier (op1_l, op2_l, base : integer; multiplicand : integer) return integer;
	function sel_multiplicand (op1_l, op2_l : integer) return integer;

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
		Quotient	: out std_logic_vector(OP1_L-1 downto 0);
		Remainder	: out std_logic_vector(OP2_L - 1 downto 0)
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
		Cmd	: in std_logic_vector(ALU_CMD_L - 1 downto 0);
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

		assert rem_multiplier = 0 report ("op length must be a multiple of " & integer'image(base) & ". It is " & integer'image(multiplier) & ". Input will be extended") severity warning;

		if (rem_multiplier = 0) then
			length_op := multiplier;
		else
			length_op := multiplier - rem_multiplier + base;
		end if;

		return length_op;

	end;

	function sel_multiplicand (op1_l, op2_l : integer) return integer is
		variable rem_op	: integer;
		variable multiplicand	: integer;
	begin
		if (op1_l <= op2_l) then
			multiplicand := op1_l;
		else
			multiplicand := op2_l;
		end if;

		return multiplicand;
	end;

end package body alu_pkg;
