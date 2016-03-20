library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.alu_pkg.all;
--use work.pipeline_pkg.all;
use work.proc_pkg.all;

entity decode_stage is
generic (
	INSTR_L		: positive := 32;
	REG_NUM		: positive := 16;
	REG_L		: positive := 32;
	PC_L		: positive := 32
);
port (
	rst		: in std_logic;
	clk		: in std_logic;

	NewInstr	: in std_logic;
	Instr		: in std_logic_vector(INSTR_L - 1 downto 0);

	PCC		: in std_logic_vector(PC_L - 1 downto 0);

	DataIn		: out std_logic_vector(REG_L - 1 downto 0);
	AddressIn	: out std_logic_vector(count_length(REG_NUM) - 1 downto 0);
	AddressOut1	: out std_logic_vector(count_length(REG_NUM) - 1 downto 0);
	AddressOut2	: out std_logic_vector(count_length(REG_NUM) - 1 downto 0);
	Cmd_alu		: out std_logic_vector(CMD_L - 1 downto 0);
	Enable_reg_file	: out std_logic;

	PCN		: out std_logic_vector(PC_L - 1 downto 0);

	EndOfProg	: out std_logic;
);
end entity decode_stage;

architecture rtl of decode_stage is

	type state_list is (IDLE, DECODE, OUTPUT);
	signal StateC, StateN: state_list;

begin

end rtl;
