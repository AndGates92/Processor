library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;
use work.ddr2_gen_ac_timing_pkg.all;
use work.ddr2_phy_pkg.all;
use work.ddr2_phy_arbitrer_pkg.all;

entity ddr2_phy_arbitrer is
generic (
	BANK_CTRL_NUM	: positive := 8;
	COL_CTRL_NUM	: positive := 1;
	REF_CTRL_NUM	: positive := 1;
	BANK_NUM	: positive := 8;
	COL_L		: positive := 10;
	ROW_L		: positive := 14;
	ADDR_L		: positive := 14

);
port (

	rst		: in std_logic;
	clk		: in std_logic;

	-- Bank Controllers
	BankCtrlBankMem		: in std_logic_vector(BANK_CTRL_NUM*(int_to_bit_num(BANK_NUM)) - 1 downto 0);
	BankCtrlRowMem		: in std_logic_vector(BANK_CTRL_NUM*ROW_L - 1 downto 0);
	BankCtrlCmd		: in std_logic_vector(BANK_CTRL_NUM*MEM_CMD_L - 1 downto 0);
	BankCtrlCmdReq		: in std_logic_vector(BANK_CTRL_NUM - 1 downto 0);

	BankCtrlCmdAck		: out std_logic_vector(BANK_CTRL_NUM - 1 downto 0);

	-- Column Controller
	ColCtrlColMem		: in std_logic_vector(COL_CTRL_NUM*COL_L - 1 downto 0);
	ColCtrlBankMem		: in std_logic_vector(COL_CTRL_NUM*(int_to_bit_num(BANK_NUM)) - 1 downto 0);
	ColCtrlCmd		: in std_logic_vector(COL_CTRL_NUM*MEM_CMD_L - 1 downto 0);
	ColCtrlCmdReq		: in std_logic_vector(COL_CTRL_NUM - 1 downto 0);

	ColCtrlCmdAck		: out std_logic_vector(COL_CTRL_NUM - 1 downto 0);

	-- Refresh Controller
	RefCtrlCmd		: in std_logic_vector(REF_CTRL_NUM*MEM_CMD_L - 1 downto 0);
	RefCtrlCmdReq		: in std_logic_vector(REF_CTRL_NUM - 1 downto 0);

	RefCtrlCmdAck		: out std_logic_vector(REF_CTRL_NUM - 1 downto 0);

	-- Command Decoder
	CmdDecColMem		: out std_logic_vector(COL_L - 1 downto 0);
	CmdDecRowMem		: out std_logic_vector(ROW_L - 1 downto 0);
	CmdDecBankMem		: out std_logic_vector(int_to_bit_num(BANK_NUM) - 1 downto 0);
	CmdDecCmdMem		: out std_logic_vector(MEM_CMD_L - 1 downto 0);
	CmdDecMRSCmd		: out std_logic_vector(ADDR_L - 1 downto 0);
);
end entity ddr2_phy_arbitrer;

architecture rtl of ddr2_phy_arbitrer is

	constant MAX_VALUE_PRIORITY		: unsigned(int_to_bit_num(COL_CTRL_NUM+BANK_CTRL_NUM) - 1 downto 0) := to_unsigned((COL_CTRL_NUM+BANK_CTRL_NUM-1), int_to_bit_num(COL_CTRL_NUM+BANK_CTRL_NUM));
	constant MAX_VALUE_BANK_PRIORITY	: unsigned(int_to_bit_num(BANK_CTRL_NUM - 1 downto 0) := to_unsigned((BANK_CTRL_NUM-1), int_to_bit_num(BANK_CTRL_NUM));
	constant MAX_VALUE_COL_PRIORITY		: unsigned(int_to_bit_num(COL_CTRL_NUM - 1 downto 0) := to_unsigned((COL_CTRL_NUM-1), int_to_bit_num(COL_CTRL_NUM));

	constant incr_value_priority		: unsigned(int_to_bit_num(COL_CTRL_NUM+BANK_CTRL_NUM) - 1 downto 0) := to_unsigned(1, int_to_bit_num(COL_CTRL_NUM+BANK_CTRL_NUM));
	constant incr_value_bank_priority	: unsigned(int_to_bit_num(BANK_CTRL_NUM - 1 downto 0) := to_unsigned(1, int_to_bit_num(BANK_CTRL_NUM));
	constant incr_value_col_priority	: unsigned(int_to_bit_num(COL_CTRL_NUM - 1 downto 0) := to_unsigned(1, int_to_bit_num(COL_CTRL_NUM));

	signal PriorityC, PriorityN		: unsigned(int_to_bit_num(COL_CTRL_NUM+BANK_CTRL_NUM) - 1 downto 0);
	signal BankPriorityC, BankPriorityN	: unsigned(int_to_bit_num(BANK_CTRL_NUM) - 1 downto 0);
	signal ColPriorityC, ColPriorityN	: unsigned(int_to_bit_num(COL_CTRL_NUM) - 1 downto 0);

	signal ColMem				: std_logic_vector((COL_CTRL_NUM+BANK_CTRL_NUM)*COL_L - 1 downto 0);
	signal BankMem				: std_logic_vector((COL_CTRL_NUM+BANK_CTRL_NUM)*ROW_L - 1 downto 0);
	signal RowMem				: std_logic_vector((COL_CTRL_NUM+BANK_CTRL_NUM)*ROW_L - 1 downto 0);
	signal CtrlCmd				: std_logic_vector((COL_CTRL_NUM+BANK_CTRL_NUM)*MEM_CMD_L - 1 downto 0);
	signal CtrlCmdReq			: std_logic_vector((COL_CTRL_NUM+BANK_CTRL_NUM) - 1 downto 0);

	signal CtrlCmdAck			: std_logic_vector((COL_CTRL_NUM+BANK_CTRL_NUM) - 1 downto 0);

	signal PriorityColMem			: std_logic_vector(COL_L - 1 downto 0);
	signal PriorityBankMem			: std_logic_vector(ROW_L - 1 downto 0);
	signal PriorityRowMem			: std_logic_vector(ROW_L - 1 downto 0);
	signal PriorityCtrlCmd			: std_logic_vector(MEM_CMD_L - 1 downto 0);

	signal BankPriorityColMem		: std_logic_vector(COL_L - 1 downto 0);
	signal BankPriorityBankMem		: std_logic_vector(ROW_L - 1 downto 0);
	signal BankPriorityRowMem		: std_logic_vector(ROW_L - 1 downto 0);
	signal BankPriorityCtrlCmd		: std_logic_vector(MEM_CMD_L - 1 downto 0);

	signal ColPriorityColMem		: std_logic_vector(COL_L - 1 downto 0);
	signal ColPriorityBankMem		: std_logic_vector(ROW_L - 1 downto 0);
	signal ColPriorityRowMem		: std_logic_vector(ROW_L - 1 downto 0);
	signal ColPriorityCtrlCmd		: std_logic_vector(MEM_CMD_L - 1 downto 0);

begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then

			PriorityC <= (others => '0');

			BankPriorityC <= (others => '0');

			ColPriorityC <= (others => '0');

		elsif ((clk'event) and (clk = '1')) then

			PriorityC <= PriorityN;

			BankPriorityC <= BankPriorityN;

			ColPriorityC <= ColPriorityN;

		end if;
	end process reg;

	PriorityN <= (others => '0') when (PriorityC = MAX_VALUE_PRIORITY) else (PriorityC + incr_value_priority);
	BankPriorityN <= (others => '0') when (BankPriorityC = MAX_VALUE_BANK_PRIORITY) else (BankPriorityC + incr_value_bank_priority);
	ColPriorityN <= (others => '0') when (ColPriorityC = MAX_VALUE_COL_PRIORITY) else (ColPriorityC + incr_value_col_priority);

	ColMem <= (COL_CTRL_NUM*COL_L - 1 downto 0 => ColCtrlColMem, others => '0');
	BankMem <= BankCtrlBankMem & ColCtrlBankMem;
	RowMem <= ((BANK_CTRL_NUM+COL_CTRL_NUM)*ROW_L - 1 downto COL_CTRL_NUM*ROW_L => BankCtrlRowMem, others => '0');
	CtrlCmd <= BankCtrlCmd & ColCtrlCmd;
	CtrlCmdReq <= BankCtrlCmdReq & ColCtrlCmdReq;

	ColCtrlCmdAck <= CtrlCmdAck((COL_CTRL_NUM+BANK_CTRL_NUM) - 1 downto COL_CTRL_NUM);
	BankCtrlCmdAck <= CtrlCmdAck(COL_CTRL_NUM - 1 downto 0);

	priority_mux: process(PriorityC, ColMem, BankMem, RowMem, CtrlCmd)
	begin
		PriorityColMem <= (others => '0');
		PriorityRowMem <= (others => '0');
		PriorityBankMem <= (others => '0');
		PriorityCtrlCmd <= (others => '0');

		for i in 0 to ((COL_CTRL_NUM+BANK_CTRL_NUM) - 1) loop
			if (PriorityC = to_unsigned(i, (COL_CTRL_NUM+BANK_CTRL_NUM))) then
				PriorityColMem <= ColMem((i+1)*COL_L - 1 downto i*COL_L);
				PriorityRowMem <= RowMem((i+1)*ROW_L - 1 downto i*ROW_L);
				PriorityBankMem <= BankMem((i+1)*int_to_bit_num(BANK_NUM) - 1 downto i*int_to_bit_num(BANK_NUM));
				PriorityCtrlCmd <= RowMem((i+1)*MEM_CMD_L - 1 downto i*MEM_CMD_L);
			end if;
		end loop;
	end process priority_mux;

	col_priority_mux: process(ColPriorityC, ColMem, BankMem, RowMem, CtrlCmd)
	begin
		ColPriorityColMem <= (others => '0');
		ColPriorityRowMem <= (others => '0');
		ColPriorityBankMem <= (others => '0');
		ColPriorityCtrlCmd <= (others => '0');

		for i in 0 to (COL_CTRL_NUM - 1) loop
			if (ColPriorityC = to_unsigned(i, (COL_CTRL_NUM+BANK_CTRL_NUM))) then
				ColPriorityColMem <= ColMem((i+1)*COL_L - 1 downto i*COL_L);
				ColPriorityRowMem <= RowMem((i+1)*ROW_L - 1 downto i*ROW_L);
				ColPriorityBankMem <= BankMem((i+1)*int_to_bit_num(BANK_NUM) - 1 downto i*int_to_bit_num(BANK_NUM));
				ColPriorityCtrlCmd <= RowMem((i+1)*MEM_CMD_L - 1 downto i*MEM_CMD_L);
			end if;
		end loop;
	end process col_priority_mux;

	bank_priority_mux: process(BankPriorityC, ColMem, BankMem, RowMem, CtrlCmd)
	begin
		BankPriorityColMem <= (others => '0');
		BankPriorityRowMem <= (others => '0');
		BankPriorityBankMem <= (others => '0');
		BankPriorityCtrlCmd <= (others => '0');

		for i in COL_CTRL_NUM to ((COL_CTRL_NUM+BANK_CTRL_NUM) - 1) loop
			if (BankPriorityC = to_unsigned(i, (COL_CTRL_NUM+BANK_CTRL_NUM))) then
				BankPriorityColMem <= ColMem((i+1)*COL_L - 1 downto i*COL_L);
				BankPriorityRowMem <= RowMem((i+1)*ROW_L - 1 downto i*ROW_L);
				BankPriorityBankMem <= BankMem((i+1)*int_to_bit_num(BANK_NUM) - 1 downto i*int_to_bit_num(BANK_NUM));
				BankPriorityCtrlCmd <= RowMem((i+1)*MEM_CMD_L - 1 downto i*MEM_CMD_L);
			end if;
		end loop;
	end process bank_priority_mux;

end rtl;
