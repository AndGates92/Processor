library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

package arbiter_pkg is 

	component arbiter is
	generic (
		NUM_REQ	: positive := 1;
		DATA_L	: positive := 1
	);
	port (

		rst	: in std_logic;
		clk	: in std_logic;

		-- Request Set
		ReqIn	: in std_logic_vector(NUM_REQ - 1 downto 0);
		DataIn	: in std_logic_vector(DATA_L*NUM_REQ - 1 downto 0);

		AckIn	: in std_logic;

		-- Request
		ReqOut	: out std_logic;
		DataOut	: out std_logic_vector(DATA_L - 1 downto 0);

		AckOut	: out std_logic_vector(NUM_REQ - 1 downto 0);

		-- Arbiter External Control
		StopArb	: in std_logic
	);
	end component;

end package arbiter_pkg;
