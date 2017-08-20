library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;

entity arbiter is
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
end entity arbiter;

architecture rtl of arbiter is

	constant MAX_VALUE_PRIORITY		: unsigned(int_to_bit_num(NUM_REQ - 1 downto 0) := to_unsigned((NUM_REQ - 1), int_to_bit_num(NUM_REQ));
	constant incr_value_priority		: unsigned(int_to_bit_num(NUM_REQ - 1 downto 0) := to_unsigned(1, int_to_bit_num(NUM_REQ));

	signal PriorityC, PriorityN		: unsigned(int_to_bit_num(NUM_REQ - 1 downto 0);

	signal PriorityReq			: std_logic;
	signal PriorityData			: std_logic_vector(DATA_L - 1 downto 0);

	signal PriorityAck			: std_logic_vector(NUM_REQ - 1 downto 0);

begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then

			PriorityC <= (others => '0');

		elsif ((clk'event) and (clk = '1')) then

			PriorityC <= PriorityN;

		end if;
	end process reg;

	ReqOut <= PriorityReq;
	DataOut <= PriorityData;

	AckOut <= PriorityAck;

	priority_next: process(PriorityC, StopArb, AckIn)
	begin
		if ((StopArb = '0') and (AckIn = '1')) then -- increment priority only if arbitrer is not stopped
			if (PriorityC = MAX_BANK_PRIORITY) then
				PriorityN <= (others => '0');
			else
				PriorityN <= (PriorityC + incr_value_priority);
			end if;
		else
			PriorityN <= PriorityC;
		end if;
	end process priority_next;

	priority_mux: process(PriorityC, ReqIn, DataIn)
	begin
		PriorityReq <= '0';
		PriorityData <= (others => '0');

		for i in 0 to (NUM_REQ - 1) loop
			if (PriorityC = to_unsigned(i, int_to_bit_num(NUM_REQ))) then
				PriorityReq <= ReqIn(i);
				PriorityData <= DataIn((i+1)*DATA_L - 1 downto i*DATA_L);
			end if;
		end loop;
	end process priority_mux;

	ack_mux: process(PriorityC, AckIn)
	begin
		PriorityAck <= (others => '0');

		for i in 0 to (NUM_REQ - 1) loop
			if (PriorityC = to_unsigned(i, int_to_bit_num(NUM_REQ))) then
				PriorityAck(i) <= AckIn;
			else
				PriorityAck(i) <= '0';
			end if;
		end loop;
	end process ack_mux;

end rtl;
