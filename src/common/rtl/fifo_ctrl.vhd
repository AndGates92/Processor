library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo_ctrl is
generic (
	RST_VAL		: natural := 0;
	ADDR_L		: positive := 16
);
port (
	rst	: in std_logic;
	clk	: in std_logic;

	Ptr	: in std_logic_vector(ADDR_L - 1 downto 0);
	PtrP1	: in std_logic_vector(ADDR_L - 1 downto 0);
	Ptr2	: in std_logic_vector(ADDR_L - 1 downto 0);

	En	: in std_logic;

	flag	: out std_logic;
	nflag	: out std_logic

);
end entity fifo_ctrl;

architecture rtl of fifo_ctrl is

	signal flagC, flagN	: std_logic;
	signal nflagC		: std_logic;

	signal rst_val_std_logic_vector	: std_logic_vector(0 downto 0);


begin

	reg : process(rst, clk) begin
		if (rst = '1') then
			flagC <= rst_val_std_logic_vector(0);
			nflagC <= not rst_val_std_logic_vector(0);
		elsif ((clk'event) and (clk = '1')) then
			flagC <= flagN;
			nflagC <= not flagN;
		end if;
	end process reg;

	flagN <=	flagC	when Ptr = Ptr2 else
			'1'	when (PtrP1 = Ptr2) and (En = '1') else
			'0';

	flag <= flagC;
	nflag <= nflagC;

	rst_val_std_logic_vector <= std_logic_vector(to_unsigned(RST_VAL, 1));

end rtl;
