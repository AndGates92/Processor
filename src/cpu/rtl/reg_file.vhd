library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;
use work.reg_file_pkg.all;

entity reg_file is
generic (
	REG_NUM	: positive := 16;
	OUT_NUM	: positive := 2;
	EN_L	: positive := 3
);
port (
	rst		: in std_logic;
	clk		: in std_logic;
	DataIn		: in std_logic_vector(DATA_L - 1 downto 0);
	AddressIn	: in std_logic_vector(int_to_bit_num(REG_NUM) - 1 downto 0);
	AddressOut1	: in std_logic_vector(int_to_bit_num(REG_NUM) - 1 downto 0);
	AddressOut2	: in std_logic_vector(int_to_bit_num(REG_NUM) - 1 downto 0);
	Enable		: in std_logic_vector(EN_L-1 downto 0);
	Done		: out std_logic_vector(OUT_NUM-1 downto 0);
	End_LS		: out std_logic;
	DataOut1	: out std_logic_vector(DATA_L-1 downto 0);
	DataOut2	: out std_logic_vector(DATA_L-1 downto 0)
);
end entity reg_file;

architecture rtl of reg_file is

	constant ZeroEnable	: std_logic_vector(EN_L - 1 downto 0) := (others => '0');

	type register_file is array(0 to REG_NUM-1) of std_logic_vector(DATA_L-1 downto 0);
	signal RegFileN, RegFileC	: register_file;

	signal DataInC, DataInN	: std_logic_vector(DATA_L - 1 downto 0);
	signal DataOut1C, DataOut1N	: std_logic_vector(DATA_L - 1 downto 0);
	signal DataOut2C, DataOut2N	: std_logic_vector(DATA_L - 1 downto 0);
	signal AddressOut1C, AddressOut1N	: std_logic_vector(int_to_bit_num(REG_NUM) - 1 downto 0);
	signal AddressOut2C, AddressOut2N	: std_logic_vector(int_to_bit_num(REG_NUM) - 1 downto 0);
	signal AddressInC, AddressInN	: std_logic_vector(int_to_bit_num(REG_NUM) - 1 downto 0);

	signal StateC, StateN	: std_logic_vector(STATE_REG_FILE_L - 1 downto 0);

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
			StateC <= REG_FILE_IDLE;
			RegFileC <= (others => (others => '0'));
			EnableC <= (others => '0');
			DoneC <= (others => '0');
		elsif ((clk'event) and (clk = '1')) then
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

	EnableN <= Enable when StateC = REG_FILE_IDLE else EnableC;
	Done <= DoneC when StateC = REG_FILE_OUTPUT else (others => '0');

	DataInN <= DataIn when StateC = REG_FILE_IDLE else DataInC;
	DataOut1 <= DataOut1C when (StateC = REG_FILE_OUTPUT) and (DoneC(0) = '1') else (others => '0');
	DataOut2 <= DataOut2C when (StateC = REG_FILE_OUTPUT) and (DoneC(1) = '1') else (others => '0');

	AddressInN <= AddressIn when StateC = REG_FILE_IDLE else AddressInC;
	AddressOut1N <= AddressOut1 when StateC = REG_FILE_IDLE else AddressOut1C;
	AddressOut2N <= AddressOut2 when StateC = REG_FILE_IDLE else AddressOut2C;

	UPDATE_REG_OUT: for i in 0 to REG_NUM-1 generate
		RegFileN(i) <= DataInC when (EnableC(0) = '1') and (AddressInC = std_logic_vector(to_unsigned(i, int_to_bit_num(REG_NUM)))) and (StateC = LOAD_STORE) else RegFileC(i);
	end generate;

	DataOut1N <= RegFileC(to_integer(unsigned(AddressOut1C))) when (EnableC(1) = '1') and (StateC = LOAD_STORE) else (others => '0');
	DataOut2N <= RegFileC(to_integer(unsigned(AddressOut2C))) when (EnableC(2) = '1') and (StateC = LOAD_STORE) else (others => '0');

	DoneN <= EnableC(2 downto 1) when StateC = LOAD_STORE else (others => '0');
	End_LS <= '1' when StateC = REG_FILE_OUTPUT else '0';

	state_det: process(StateC, Enable)
	begin
		StateN <= StateC; -- avoid latches
		if (StateC = REG_FILE_IDLE) then
			if (Enable = ZeroEnable) then
				StateN <= REG_FILE_IDLE;
			else
				StateN <= LOAD_STORE;
			end if;
		elsif (StateC = LOAD_STORE) then
			StateN <= REG_FILE_OUTPUT;
		elsif (StateC = REG_FILE_OUTPUT) then
			StateN <= REG_FILE_IDLE;
		else
			StateN <= StateC;
		end if;
	end process state_det;

end rtl;
