library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;
use work.reg_file_pkg.all;

entity reg_file is
generic (
	REG_L	: positive := 16;
	REG_NUM	: positive := 16;
	OUT_NUM	: positive := 2;
	EN_L	: positive := 3
);
port (
	rst		: in std_logic;
	clk		: in std_logic;
	DataIn		: in std_logic_vector(REG_L - 1 downto 0);
	AddressIn	: in std_logic_vector(count_length(REG_NUM) - 1 downto 0);
	AddressOut1	: in std_logic_vector(count_length(REG_NUM) - 1 downto 0);
	AddressOut2	: in std_logic_vector(count_length(REG_NUM) - 1 downto 0);
	Enable		: in std_logic_vector(EN_L-1 downto 0);
	Done		: out std_logic_vector(OUT_NUM-1 downto 0);
	End_LS		: out std_logic;
	DataOut1	: out std_logic_vector(REG_L-1 downto 0);
	DataOut2	: out std_logic_vector(REG_L-1 downto 0)
);
end entity reg_file;

architecture rtl of reg_file is

	constant ZeroEnable	: std_logic_vector(EN_L - 1 downto 0) := (others => '0');

	type register_file is array(0 to REG_NUM-1) of std_logic_vector(REG_L-1 downto 0);
	signal RegFileN, RegFileC	: register_file;

	signal DataInC, DataInN	: std_logic_vector(REG_L - 1 downto 0);
	signal DataOut1C, DataOut1N	: std_logic_vector(REG_L - 1 downto 0);
	signal DataOut2C, DataOut2N	: std_logic_vector(REG_L - 1 downto 0);
	signal AddressOut1C, AddressOut1N	: std_logic_vector(count_length(REG_NUM) - 1 downto 0);
	signal AddressOut2C, AddressOut2N	: std_logic_vector(count_length(REG_NUM) - 1 downto 0);
	signal AddressInC, AddressInN	: std_logic_vector(count_length(REG_NUM) - 1 downto 0);

	type state_list is (IDLE, LOAD_STORE, OUTPUT);
	signal StateC, StateN: state_list;

	signal EnableC, EnableN	: std_logic_vector(EN_L - 1 downto 0);
	signal DoneC, DoneN	: std_logic_vector(OUT_NUM - 1 downto 0);

begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then
			DataInC <= (others => '0');
			DataOut1C <= (others => '0');
			DataOut2C <= (others => '0');
			AddressInC <= (others => '0');
			AddressOut1C <= (others => '0');
			AddressOut2C <= (others => '0');
			StateC <= IDLE;
			RegFileC <= (others => (others => '0'));
			EnableC <= (others => '0');
			DoneC <= (others => '0');
		elsif (rising_edge(clk)) then
			DataInC <= DataInN;
			DataOut1C <= DataOut1N;
			DataOut2C <= DataOut2N;
			AddressInC <= AddressInN;
			AddressOut1C <= AddressOut1N;
			AddressOut2C <= AddressOut2N;
			StateC <= StateN;
			RegFileC <= RegFileN;
			EnableC <= EnableN;
			DoneC <= DoneN;
		end if;
	end process reg;

	EnableN <= Enable when StateC = IDLE else EnableC;
	Done <= DoneC when StateC = OUTPUT else (others => '0');

	DataInN <= DataIn when StateC = IDLE else DataInC;
	DataOut1 <= DataOut1C when (StateC = OUTPUT) and (DoneC(0) = '1') else (others => '0');
	DataOut2 <= DataOut2C when (StateC = OUTPUT) and (DoneC(1) = '1') else (others => '0');

	AddressInN <= AddressIn when StateC = IDLE else AddressInC;
	AddressOut1N <= AddressOut1 when StateC = IDLE else AddressOut1C;
	AddressOut2N <= AddressOut2 when StateC = IDLE else AddressOut2C;

	UPDATE_REG_OUT: for i in 0 to REG_NUM-1 generate
		RegFileN(i) <= DataInC when (EnableC(0) = '1') and (AddressInC = std_logic_vector(to_unsigned(i, count_length(REG_NUM)))) and (StateC = LOAD_STORE) else RegFileC(i);
	end generate;

	DataOut1N <= RegFileC(to_integer(unsigned(AddressOut1C))) when (EnableC(1) = '1') and (StateC = LOAD_STORE) else (others => '0');
	DataOut2N <= RegFileC(to_integer(unsigned(AddressOut2C))) when (EnableC(2) = '1') and (StateC = LOAD_STORE) else (others => '0');

	DoneN <= EnableC(2 downto 1) when StateC = LOAD_STORE else (others => '0');
	End_LS <= '1' when StateC = OUTPUT else '0';

	state_det: process(StateC, Enable)
	begin
		StateN <= StateC; -- avoid latches
		case StateC is
			when IDLE =>
				if (Enable = ZeroEnable) then
					StateN <= IDLE;
				else
					StateN <= LOAD_STORE;
				end if;
			when LOAD_STORE =>
				StateN <= OUTPUT;
			when OUTPUT =>
				StateN <= IDLE;
			when others =>
				StateN <= StateC;
		end case;
	end process state_det;

end rtl;
