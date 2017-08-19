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
	MRS_CTRL_NUM	: positive := 1;
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
	BankCtrlCmdMem		: in std_logic_vector(BANK_CTRL_NUM*MEM_CMD_L - 1 downto 0);
	BankCtrlCmdReq		: in std_logic_vector(BANK_CTRL_NUM - 1 downto 0);

	BankCtrlCmdAck		: out std_logic_vector(BANK_CTRL_NUM - 1 downto 0);

	-- Column Controller
	ColCtrlColMem		: in std_logic_vector(COL_CTRL_NUM*COL_L - 1 downto 0);
	ColCtrlBankMem		: in std_logic_vector(COL_CTRL_NUM*(int_to_bit_num(BANK_NUM)) - 1 downto 0);
	ColCtrlCmdMem		: in std_logic_vector(COL_CTRL_NUM*MEM_CMD_L - 1 downto 0);
	ColCtrlCmdReq		: in std_logic_vector(COL_CTRL_NUM - 1 downto 0);

	ColCtrlCmdAck		: out std_logic_vector(COL_CTRL_NUM - 1 downto 0);

	-- Refresh Controller
	RefCtrlCmdMem		: in std_logic_vector(REF_CTRL_NUM*MEM_CMD_L - 1 downto 0);
	RefCtrlCmdReq		: in std_logic_vector(REF_CTRL_NUM - 1 downto 0);

	RefCtrlCmdAck		: out std_logic_vector(REF_CTRL_NUM - 1 downto 0);

	-- MRS Controller
	MRSCtrlMRSCmd		: in std_logic_vector(MRS_CTRL_NUM*ADDR_L - 1 downto 0);
	MRSCtrlCmdMem		: in std_logic_vector(MRS_CTRL_NUM*MEM_CMD_L - 1 downto 0);
	MRSCtrlCmdReq		: in std_logic_vector(MRS_CTRL_NUM - 1 downto 0);

	MRSCtrlCmdAck		: out std_logic_vector(MRS_CTRL_NUM - 1 downto 0);

	-- Arbitrer Controller
	AllowBankActivate	: in std_logic;

	BankActOut		: out std_logic;

	-- Command Decoder
	CmdDecColMem		: out std_logic_vector(COL_L - 1 downto 0);
	CmdDecRowMem		: out std_logic_vector(ROW_L - 1 downto 0);
	CmdDecBankMem		: out std_logic_vector(int_to_bit_num(BANK_NUM) - 1 downto 0);
	CmdDecCmdMem		: out std_logic_vector(MEM_CMD_L - 1 downto 0);
	CmdDecMRSCmd		: out std_logic_vector(ADDR_L - 1 downto 0)

);
end entity ddr2_phy_arbitrer;

architecture rtl of ddr2_phy_arbitrer is

	constant MAX_VALUE_PRIORITY		: unsigned(int_to_bit_num(COL_CTRL_NUM+BANK_CTRL_NUM) - 1 downto 0) := to_unsigned((COL_CTRL_NUM+BANK_CTRL_NUM - 1), int_to_bit_num(COL_CTRL_NUM+BANK_CTRL_NUM));
	constant MAX_VALUE_BANK_PRIORITY	: unsigned(int_to_bit_num(BANK_CTRL_NUM) - 1 downto 0) := to_unsigned(BANK_CTRL_NUM - 1, int_to_bit_num(BANK_CTRL_NUM));
	constant MAX_VALUE_COL_PRIORITY		: unsigned(int_to_bit_num(COL_CTRL_NUM) - 1 downto 0) := to_unsigned(COL_CTRL_NUM - 1, int_to_bit_num(COL_CTRL_NUM));
	constant MAX_VALUE_REF_PRIORITY		: unsigned(int_to_bit_num(REF_CTRL_NUM) - 1 downto 0) := to_unsigned(REF_CTRL_NUM - 1, int_to_bit_num(REF_CTRL_NUM));
	constant MAX_VALUE_MRS_PRIORITY		: unsigned(int_to_bit_num(MRS_CTRL_NUM) - 1 downto 0) := to_unsigned(MRS_CTRL_NUM - 1, int_to_bit_num(MRS_CTRL_NUM));

	constant incr_value_priority		: unsigned(int_to_bit_num(COL_CTRL_NUM+BANK_CTRL_NUM) - 1 downto 0) := to_unsigned(1, int_to_bit_num(COL_CTRL_NUM+BANK_CTRL_NUM));
	constant incr_value_bank_priority	: unsigned(int_to_bit_num(BANK_CTRL_NUM) - 1 downto 0) := to_unsigned(1, int_to_bit_num(BANK_CTRL_NUM));
	constant incr_value_col_priority	: unsigned(int_to_bit_num(COL_CTRL_NUM) - 1 downto 0) := to_unsigned(1, int_to_bit_num(COL_CTRL_NUM));
	constant incr_value_ref_priority	: unsigned(int_to_bit_num(REF_CTRL_NUM) - 1 downto 0) := to_unsigned(1, int_to_bit_num(REF_CTRL_NUM));
	constant incr_value_mrs_priority	: unsigned(int_to_bit_num(MRS_CTRL_NUM) - 1 downto 0) := to_unsigned(1, int_to_bit_num(MRS_CTRL_NUM));

	constant ZeroColCtrlRowMem		: std_logic_vector(COL_CTRL_NUM*ROW_L - 1 downto 0) := (others => '0');
	constant ZeroBankCtrlColMem		: std_logic_vector(BANK_CTRL_NUM*COL_L - 1 downto 0) := (others => '0');

	signal PriorityC, PriorityN		: unsigned(int_to_bit_num(COL_CTRL_NUM+BANK_CTRL_NUM) - 1 downto 0);
	signal BankPriorityC, BankPriorityN	: unsigned(int_to_bit_num(BANK_CTRL_NUM) - 1 downto 0);
	signal ColPriorityC, ColPriorityN	: unsigned(int_to_bit_num(COL_CTRL_NUM) - 1 downto 0);
	signal RefPriorityC, RefPriorityN	: unsigned(int_to_bit_num(REF_CTRL_NUM) - 1 downto 0);
	signal MRSPriorityC, MRSPriorityN	: unsigned(int_to_bit_num(REF_CTRL_NUM) - 1 downto 0);

	signal ColMem				: std_logic_vector((COL_CTRL_NUM+BANK_CTRL_NUM)*COL_L - 1 downto 0);
	signal BankMem				: std_logic_vector((COL_CTRL_NUM+BANK_CTRL_NUM)*int_to_bit_num(BANK_NUM) - 1 downto 0);
	signal RowMem				: std_logic_vector((COL_CTRL_NUM+BANK_CTRL_NUM)*ROW_L - 1 downto 0);
	signal CmdMem				: std_logic_vector((COL_CTRL_NUM+BANK_CTRL_NUM)*MEM_CMD_L - 1 downto 0);
	signal CmdReq				: std_logic_vector((COL_CTRL_NUM+BANK_CTRL_NUM) - 1 downto 0);

	signal CmdAck				: std_logic_vector((COL_CTRL_NUM+BANK_CTRL_NUM) - 1 downto 0);

	signal PriorityColMem			: std_logic_vector(COL_L - 1 downto 0);
	signal PriorityBankMem			: std_logic_vector(int_to_bit_num(BANK_NUM) - 1 downto 0);
	signal PriorityRowMem			: std_logic_vector(ROW_L - 1 downto 0);
	signal PriorityCmdMem			: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal PriorityCmdReq			: std_logic;

	signal BankPriorityColMem		: std_logic_vector(COL_L - 1 downto 0);
	signal BankPriorityBankMem		: std_logic_vector(int_to_bit_num(BANK_NUM) - 1 downto 0);
	signal BankPriorityRowMem		: std_logic_vector(ROW_L - 1 downto 0);
	signal BankPriorityCmdMem		: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal BankPriorityCmdReq		: std_logic;

	signal ColPriorityColMem		: std_logic_vector(COL_L - 1 downto 0);
	signal ColPriorityBankMem		: std_logic_vector(int_to_bit_num(BANK_NUM) - 1 downto 0);
	signal ColPriorityRowMem		: std_logic_vector(ROW_L - 1 downto 0);
	signal ColPriorityCmdMem		: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal ColPriorityCmdReq		: std_logic;

	signal RefPriorityCmdMem		: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal RefPriorityCmdReq		: std_logic;

	signal MRSPriorityMRSCmd		: std_logic_vector(ADDR_L - 1 downto 0);
	signal MRSPriorityCmdMem		: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal MRSPriorityCmdReq		: std_logic;

	signal BankActOut_comb			: std_logic;

begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then

			PriorityC <= (others => '0');

			BankPriorityC <= (others => '0');

			ColPriorityC <= (others => '0');

			RefPriorityC <= (others => '0');

			MRSPriorityC <= (others => '0');

		elsif ((clk'event) and (clk = '1')) then

			PriorityC <= PriorityN;

			BankPriorityC <= BankPriorityN;

			ColPriorityC <= ColPriorityN;

			RefPriorityC <= RefPriorityN;

			MRSPriorityC <= MRSPriorityN;

		end if;
	end process reg;

	priority_next: process(PriorityC, AllowBankActivate)
	begin
		if (PriorityC < COL_CTRL_NUM) then -- increment priority if pointing to a column controller
			if (PriorityC = MAX_VALUE_PRIORITY) then
				PriorityN <= (others => '0');
			else
				PriorityN <= (PriorityC + incr_value_priority);
			end if;
		else -- increment priority only if activate is allowed through (i.e. tFAW exceeded and tRRD exceeded)
			if (AllowBankActivate = '1') then
				if (PriorityC = MAX_VALUE_PRIORITY) then
					PriorityN <= (others => '0');
				else
					PriorityN <= (PriorityC + incr_value_priority);
				end if;
			else
				PriorityN <= PriorityC;
			end if;
		end if;
	end process priority_next;

	bank_priority_next: process(BankPriorityC, AllowBankActivate)
	begin
		if (AllowBankActivate = '1') then -- increment priority only if activate is allowed through (i.e. tFAW exceeded and tRRD exceeded)
			if (BankPriorityC = MAX_VALUE_BANK_PRIORITY) then
				BankPriorityN <= (others => '0');
			else
				BankPriorityN <= (BankPriorityC + incr_value_bank_priority);
			end if;
		else
			BankPriorityN <= BankPriorityC;
		end if;
	end process bank_priority_next;

	ColPriorityN <= (others => '0') when (ColPriorityC = MAX_VALUE_COL_PRIORITY) else (ColPriorityC + incr_value_col_priority);

	RefPriorityN <= (others => '0') when (RefPriorityC = MAX_VALUE_REF_PRIORITY) else (RefPriorityC + incr_value_ref_priority);

	MRSPriorityN <= (others => '0') when (MRSPriorityC = MAX_VALUE_MRS_PRIORITY) else (MRSPriorityC + incr_value_mrs_priority);

	ColMem <= ZeroBankCtrlColMem & ColCtrlColMem;
	BankMem <= BankCtrlBankMem & ColCtrlBankMem;
	RowMem <= BankCtrlRowMem & ZeroColCtrlRowMem;
	CmdMem <= BankCtrlCmdMem & ColCtrlCmdMem;
	CmdReq <= BankCtrlCmdReq & ColCtrlCmdReq;

	BankCtrlCmdAck <= CmdAck((COL_CTRL_NUM+BANK_CTRL_NUM) - 1 downto COL_CTRL_NUM);
	ColCtrlCmdAck <= CmdAck(COL_CTRL_NUM - 1 downto 0);

	priority_mux: process(PriorityC, ColMem, BankMem, RowMem, CmdMem, CmdReq)
	begin
		PriorityColMem <= (others => '0');
		PriorityRowMem <= (others => '0');
		PriorityBankMem <= (others => '0');
		PriorityCmdMem <= (others => '0');
		PriorityCmdReq <= '0';

		for i in 0 to (COL_CTRL_NUM - 1) loop
			if (PriorityC = to_unsigned(i, int_to_bit_num(COL_CTRL_NUM+BANK_CTRL_NUM))) then
				PriorityColMem <= ColMem((i+1)*COL_L - 1 downto i*COL_L);
				PriorityRowMem <= RowMem((i+1)*ROW_L - 1 downto i*ROW_L);
				PriorityBankMem <= BankMem((i+1)*int_to_bit_num(BANK_NUM) - 1 downto i*int_to_bit_num(BANK_NUM));
				PriorityCmdMem <= CmdMem((i+1)*MEM_CMD_L - 1 downto i*MEM_CMD_L);
				PriorityCmdReq <= CmdReq(i);
			end if;
		end loop;
		for i in COL_CTRL_NUM to ((COL_CTRL_NUM+BANK_CTRL_NUM) - 1) loop
			if ((PriorityC = to_unsigned(i, int_to_bit_num(COL_CTRL_NUM+BANK_CTRL_NUM))) and (AllowBankActivate = '1')) then
				PriorityColMem <= ColMem((i+1)*COL_L - 1 downto i*COL_L);
				PriorityRowMem <= RowMem((i+1)*ROW_L - 1 downto i*ROW_L);
				PriorityBankMem <= BankMem((i+1)*int_to_bit_num(BANK_NUM) - 1 downto i*int_to_bit_num(BANK_NUM));
				PriorityCmdMem <= CmdMem((i+1)*MEM_CMD_L - 1 downto i*MEM_CMD_L);
				PriorityCmdReq <= CmdReq(i);
			end if;
		end loop;
	end process priority_mux;

	col_priority_mux: process(ColPriorityC, ColMem, BankMem, RowMem, CmdMem, CmdReq)
	begin
		ColPriorityColMem <= (others => '0');
		ColPriorityRowMem <= (others => '0');
		ColPriorityBankMem <= (others => '0');
		ColPriorityCmdMem <= (others => '0');
		ColPriorityCmdReq <= '0';

		for i in 0 to (COL_CTRL_NUM - 1) loop
			if (ColPriorityC = to_unsigned(i, int_to_bit_num(COL_CTRL_NUM))) then
				ColPriorityColMem <= ColMem((i+1)*COL_L - 1 downto i*COL_L);
				ColPriorityRowMem <= RowMem((i+1)*ROW_L - 1 downto i*ROW_L);
				ColPriorityBankMem <= BankMem((i+1)*int_to_bit_num(BANK_NUM) - 1 downto i*int_to_bit_num(BANK_NUM));
				ColPriorityCmdMem <= CmdMem((i+1)*MEM_CMD_L - 1 downto i*MEM_CMD_L);
				ColPriorityCmdReq <= CmdReq(i);
			end if;
		end loop;
	end process col_priority_mux;

	bank_priority_mux: process(BankPriorityC, ColMem, BankMem, RowMem, CmdMem, CmdReq)
	begin
		BankPriorityColMem <= (others => '0');
		BankPriorityRowMem <= (others => '0');
		BankPriorityBankMem <= (others => '0');
		BankPriorityCmdMem <= (others => '0');
		BankPriorityCmdReq <= '0';

		for i in 0 to (BANK_CTRL_NUM - 1) loop
			if ((BankPriorityC = to_unsigned(i, int_to_bit_num(BANK_CTRL_NUM))) and (AllowBankActivate = '1')) then
				BankPriorityColMem <= ColMem(((i+COL_CTRL_NUM)+1)*COL_L - 1 downto (i+COL_CTRL_NUM)*COL_L);
				BankPriorityRowMem <= RowMem(((i+COL_CTRL_NUM)+1)*ROW_L - 1 downto (i+COL_CTRL_NUM)*ROW_L);
				BankPriorityBankMem <= BankMem(((i+COL_CTRL_NUM)+1)*int_to_bit_num(BANK_NUM) - 1 downto (i+COL_CTRL_NUM)*int_to_bit_num(BANK_NUM));
				BankPriorityCmdMem <= CmdMem(((i+COL_CTRL_NUM)+1)*MEM_CMD_L - 1 downto (i+COL_CTRL_NUM)*MEM_CMD_L);
				BankPriorityCmdReq <= CmdReq(i+COL_CTRL_NUM);
			end if;
		end loop;
	end process bank_priority_mux;

	ref_priority_mux: process(RefPriorityC, RefCtrlCmdMem, RefCtrlCmdReq)
	begin
		RefPriorityCmdMem <= (others => '0');
		RefPriorityCmdReq <= '0';

		for i in 0 to (REF_CTRL_NUM - 1) loop
			if (RefPriorityC = to_unsigned(i, int_to_bit_num(REF_CTRL_NUM))) then
				RefPriorityCmdMem <= RefCtrlCmdMem((i+1)*MEM_CMD_L - 1 downto i*MEM_CMD_L);
				RefPriorityCmdReq <= RefCtrlCmdReq(i);
			end if;
		end loop;
	end process ref_priority_mux;

	mrs_priority_mux: process(MRSPriorityC, MRSCtrlMRSCmd, MRSCtrlCmdMem, MRSCtrlCmdReq)
	begin
		MRSPriorityCmdMem <= (others => '0');
		MRSPriorityCmdReq <= '0';

		for i in 0 to (REF_CTRL_NUM - 1) loop
			if (MRSPriorityC = to_unsigned(i, int_to_bit_num(REF_CTRL_NUM))) then
				MRSPriorityMRSCmd <= MRSCtrlMRSCmd((i+1)*ADDR_L - 1 downto i*ADDR_L);
				MRSPriorityCmdMem <= MRSCtrlCmdMem((i+1)*MEM_CMD_L - 1 downto i*MEM_CMD_L);
				MRSPriorityCmdReq <= MRSCtrlCmdReq(i);
			end if;
		end loop;
	end process mrs_priority_mux;

	CmdDecColMem <=	PriorityColMem		when (PriorityCmdReq = '1') else
			ColPriorityColMem	when (ColPriorityCmdReq = '1') else
			BankPriorityColMem	when (BankPriorityCmdReq = '1') else
			(others => '0');

	CmdDecRowMem <=	PriorityRowMem		when (PriorityCmdReq = '1') else
			ColPriorityRowMem	when (ColPriorityCmdReq = '1') else
			BankPriorityRowMem	when (BankPriorityCmdReq = '1') else
			(others => '0');

	CmdDecBankMem <=	PriorityBankMem		when (PriorityCmdReq = '1') else
				ColPriorityBankMem	when (ColPriorityCmdReq = '1') else
				BankPriorityBankMem	when (BankPriorityCmdReq = '1') else
				(others => '0');

	CmdDecCmdMem <=	PriorityCmdMem		when (PriorityCmdReq = '1') else
			ColPriorityCmdMem	when (ColPriorityCmdReq = '1') else
			BankPriorityCmdMem	when (BankPriorityCmdReq = '1') else
			RefPriorityCmdMem	when (RefPriorityCmdReq = '1') else
			MRSPriorityCmdMem	when (MRSPriorityCmdReq = '1') else
			CMD_NOP;

	CmdDecMRSCmd <= MRSPriorityMRSCmd;

	BankActOut <= BankActOut_comb;

	bank_act_out: process(PriorityCmdReq, PriorityC, BankPriorityCmdReq)
	begin

		if (PriorityCmdReq = '1') then
			if (PriorityC < COL_CTRL_NUM) then
				BankActOut_comb <= '0';
			else
				BankActOut_comb <= '1';
			end if;
		else
			BankActOut_comb <= BankPriorityCmdReq;
		end if;
	end process bank_act_out;

	ack_mux: process(PriorityC, BankPriorityC, ColPriorityC, RefPriorityC, MRSPriorityC, PriorityCmdReq, BankPriorityCmdReq, ColPriorityCmdReq, RefPriorityCmdReq, MRSPriorityCmdReq)
	begin
		CmdAck <= (others => '0');
		RefCtrlCmdAck <= (others => '0');

		if (PriorityCmdReq = '1') then
			RefCtrlCmdAck <= (others => '0');
			MRSCtrlCmdAck <= (others => '0');
			for i in 0 to ((COL_CTRL_NUM+BANK_CTRL_NUM) - 1) loop
				if (PriorityC = to_unsigned(i, int_to_bit_num(COL_CTRL_NUM+BANK_CTRL_NUM))) then
					CmdAck(i) <= '1';
				else
					CmdAck(i) <= '0';
				end if;
			end loop;
		elsif (ColPriorityCmdReq = '1') then
			RefCtrlCmdAck <= (others => '0');
			MRSCtrlCmdAck <= (others => '0');
			for i in 0 to (COL_CTRL_NUM - 1) loop
				if (ColPriorityC = to_unsigned(i, int_to_bit_num(COL_CTRL_NUM))) then
					CmdAck(i) <= '1';
				else
					CmdAck(i) <= '0';
				end if;
			end loop;
			for i in COL_CTRL_NUM to ((COL_CTRL_NUM+BANK_CTRL_NUM) - 1) loop
				CmdAck(i) <= '0';
			end loop;
		elsif (BankPriorityCmdReq = '1') then
			RefCtrlCmdAck <= (others => '0');
			MRSCtrlCmdAck <= (others => '0');
			for i in 0 to (COL_CTRL_NUM - 1) loop
				CmdAck(i) <= '0';
			end loop;
			for i in 0 to (BANK_CTRL_NUM - 1) loop
				if (BankPriorityC = to_unsigned(i, int_to_bit_num(BANK_CTRL_NUM))) then
					CmdAck(i+COL_CTRL_NUM) <= '1';
				else
					CmdAck(i+COL_CTRL_NUM) <= '0';
				end if;
			end loop;
		elsif (RefPriorityCmdReq = '1') then
			CmdAck <= (others => '0');
			MRSCtrlCmdAck <= (others => '0');
			for i in 0 to (REF_CTRL_NUM - 1) loop
				if (RefPriorityC = to_unsigned(i, int_to_bit_num(REF_CTRL_NUM))) then
					RefCtrlCmdAck(i) <= '1';
				else
					RefCtrlCmdAck(i) <= '0';
				end if;
			end loop;
		elsif (MRSPriorityCmdReq = '1') then
			CmdAck <= (others => '0');
			RefCtrlCmdAck <= (others => '0');
			for i in 0 to (REF_CTRL_NUM - 1) loop
				if (MRSPriorityC = to_unsigned(i, int_to_bit_num(REF_CTRL_NUM))) then
					MRSCtrlCmdAck(i) <= '1';
				else
					MRSCtrlCmdAck(i) <= '0';
				end if;
			end loop;
		else
			CmdAck <= (others => '0');
			RefCtrlCmdAck <= (others => '0');
			MRSCtrlCmdAck <= (others => '0');
		end if;
	end process ack_mux;

end rtl;
