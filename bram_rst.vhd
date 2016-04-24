library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bram_pkg.all;
use work.proc_pkg.all;

entity bram_rst is
generic (
	ADDR_L	: positive := 32
);
port (
	rst		: in std_logic;
	clk		: in std_logic;

	Start		: in std_logic;
	Done		: out std_logic;
	PortA_Address	: out std_logic_vector(ADDR_L - 1 downto 0);
	PortB_Address	: out std_logic_vector(ADDR_L - 1 downto 0)
);
end entity bram_rst;

architecture rtl_bram_1port of bram_rst is

	constant GEN_ADDR		: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(2, STATE_L));
	constant MAX_ADDR		: unsigned(ADDR_L - 1 downto 0) := (others => '1');

	signal StateN, StateC			: std_logic_vector(STATE_L - 1 downto 0);
	signal PortA_AddressC, PortA_AddressN	: unsigned(ADDR_L - 1 downto 0);

begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then

			StateC <= IDLE;
			PortA_AddressC <= (others => '0');

		elsif ((clk'event) and (clk = '1')) then

			StateC <= StateN;
			PortA_AddressC <= PortA_AddressN;

		end if;
	end process reg;

	state_det: process(StateC, Start, PortA_AddressC)
	begin
		StateN <= StateC; -- avoid latches
		if (StateC = IDLE) then
			if (Start = '1') then
				StateN <= GEN_ADDR;
			else
				StateN <= StateC;
			end if;
		elsif (StateC = GEN_ADDR) then
			if (PortA_AddressC = MAX_ADDR) then
				StateN <= OUTPUT;
			else
				StateN <= StateC;
			end if;
		elsif (StateC = OUTPUT) then
			StateN <= IDLE;
		else
			StateN <= StateC;
		end if;
	end process state_det;

	Done <=	'1' when (StateC = OUTPUT) else '0';

	PortA_Address <= std_logic_vector(PortA_AddressC);
	PortB_Address <= (others => 'X');

	PortA_AddressN <= PortA_AddressC + 1 when (StateC = GEN_ADDR) else PortA_AddressC;

end rtl_bram_1port;

architecture rtl_bram_2port of bram_rst is

	constant GEN_ADDR		: std_logic_vector(STATE_L - 1 downto 0) := std_logic_vector(to_unsigned(2, STATE_L));
	constant MAX_ADDR		: unsigned(ADDR_L - 1 downto 0) := (others => '1');

	signal StateN, StateC			: std_logic_vector(STATE_L - 1 downto 0);
	signal PortA_AddressC, PortA_AddressN	: unsigned(ADDR_L - 1 downto 0);
	signal PortB_AddressC, PortB_AddressN	: unsigned(ADDR_L - 1 downto 0);

begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then

			StateC <= IDLE;
			PortA_AddressC <= (others => '0');
			PortB_AddressC <= to_unsigned(1, ADDR_L);

		elsif ((clk'event) and (clk = '1')) then

			StateC <= StateN;
			PortA_AddressC <= PortA_AddressN;
			PortB_AddressC <= PortB_AddressN;

		end if;
	end process reg;

	state_det: process(StateC, Start, PortA_AddressC, PortB_AddressC)
	begin
		StateN <= StateC; -- avoid latches
		if (StateC = IDLE) then
			if (Start = '1') then
				StateN <= GEN_ADDR;
			else
				StateN <= StateC;
			end if;
		elsif (StateC = GEN_ADDR) then
			if (PortA_AddressC = MAX_ADDR) or (PortB_AddressC = MAX_ADDR) then
				StateN <= OUTPUT;
			else
				StateN <= StateC;
			end if;
		elsif (StateC = OUTPUT) then
			StateN <= IDLE;
		else
			StateN <= StateC;
		end if;
	end process state_det;

	Done <=	'1' when (StateC = OUTPUT) else '0';

	PortA_Address <= std_logic_vector(PortA_AddressC);
	PortB_Address <= std_logic_vector(PortB_AddressC);

	PortA_AddressN <= PortA_AddressC + 2 when (StateC = GEN_ADDR) else PortA_AddressC;
	PortB_AddressN <= PortB_AddressC + 2 when (StateC = GEN_ADDR) else PortB_AddressC;

end rtl_bram_2port;
