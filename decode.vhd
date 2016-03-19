library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
--use work.pipeline_pkg.all;
use work.proc_pkg.all;

entity decode_stage is
generic (
	INSTR_L		: positive := 32;
	REG_NUM		: positive := 16;
	ALU_CMD_L	: positive := 4;
);
port (
	rst	: in std_logic;
	clk	: in std_logic;
	Op1	: in std_logic_vector(OP1_L - 1 downto 0);
	Op2	: in std_logic_vector(OP2_L - 1 downto 0);
	Cmd	: in std_logic_vector(CMD_L - 1 downto 0);
	Start	: in std_logic;
	Done	: out std_logic;
	Ovfl	: out std_logic;
	Unfl	: out std_logic;
	UnCmd	: out std_logic;
	Res	: out std_logic_vector(OP1_L-1 downto 0)
);
end entity decode_stage;


