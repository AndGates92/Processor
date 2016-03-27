library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;
use work.alu_pkg.all;

package ctrl_pkg is 

	constant CTRL_L	: positive := 3;

	constant CTRL_DISABLE	: std_logic_vector(CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(0, CTRL_L));
	constant CTRL_ALU	: std_logic_vector(CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(1, CTRL_L));
	constant CTRL_WR_M	: std_logic_vector(CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(2, CTRL_L));
	constant CTRL_RD_M	: std_logic_vector(CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(3, CTRL_L));
	constant CTRL_WR_S	: std_logic_vector(CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(4, CTRL_L));
	constant CTRL_RD_S	: std_logic_vector(CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(5, CTRL_L));
	constant CTRL_MOV	: std_logic_vector(CTRL_L - 1 downto 0) := std_logic_vector(to_unsigned(6, CTRL_L));

	constant ALU_OP		: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(1, STATE_L));
	constant MULTIPLICATION	: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(2, STATE_L));
	constant DIVISION	: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(3, STATE_L));
	constant REG_FILE_READ	: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(4, STATE_L));
	constant REG_FILE_WRITE	: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(5, STATE_L));
	constant MEMORY_ACCESS	: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(6, STATE_L));

end package ctrl_pkg;
