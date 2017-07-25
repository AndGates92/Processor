library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_pkg.all;
use work.ddr2_phy_pkg.all;

entity ddr2_phy_cmd_ctrl is
generic (
	BURST_LENGTH_L		: positive := 5;
	BANK_NUM		: positive := 8;
	COL_L			: positive := 10;
	ROW_L			: positive := 13;
	MAX_OUTSTANDING_BURSTS	: positive := 10
);
port (
	rst		: in std_logic;
	clk		: in std_logic;

	-- Column Controller
	-- Arbitrer
	ColCtrlCmdAck		: in std_logic;

	ColCtrlColMemOut	: out std_logic_vector(COL_L - 1 downto 0);
	ColCtrlBankMemOut	: out std_logic_vector(int_to_bit_num(BANK_NUM) - 1 downto 0);
	ColCtrlCmdOut		: out std_logic_vector(MEM_CMD_L - 1 downto 0);
	ColCtrlCmdReq		: out std_logic;

	-- Controller
	ColCtrlCtrlReq		: in std_logic;
	ColCtrlReadBurstIn	: in std_logic;
	ColCtrlColMemIn		: in std_logic_vector(COL_L - to_integer(unsigned(BURST_LENGTH)) - 1 downto 0);
	ColCtrlBankMemIn	: in std_logic_vector(int_to_bit_num(BANK_NUM) - 1 downto 0);
	ColCtrlBurstLength	: in std_logic_vector(BURST_LENGTH_L - 1 downto 0);

	ColCtrlCtrlAck		: out std_logic;

	-- Bank Controllers
	-- Arbitrer
	BankCtrlCmdAck		: in std_logic_vector(BANK_NUM - 1 downto 0);

	BankCtrlRowMemOut	: out std_logic_vector(BANK_NUM*ROW_L - 1 downto 0);
	BankCtrlCmdOut		: out std_logic_vector(BANK_NUM*MEM_CMD_L - 1 downto 0);
	BankCtrlCmdReq		: out std_logic_vector(BANK_NUM - 1 downto 0);

	-- Transaction Controller
	BankCtrlRowMemIn	: in std_logic_vector(BANK_NUM*ROW_L - 1 downto 0);
	BankCtrlCtrlReq		: in std_logic_vector(BANK_NUM - 1 downto 0);

	BankCtrlCtrlAck		: out std_logic_vector(BANK_NUM - 1 downto 0);

	-- Status
	BankIdleVec		: out std_logic_vector(BANK_NUM - 1 downto 0)

);
end entity ddr2_phy_cmd_ctrl;

architecture rtl of ddr2_phy_cmd_ctrl is

	signal BankActiveVec			: std_logic_vector(BANK_NUM - 1 downto 0);
	signal BankCtrlZeroOutstandingBurstsVec	: std_logic_vector(BANK_NUM - 1 downto 0);
	signal EndDataPhaseVec			: std_logic_vector(BANK_NUM - 1 downto 0);
	signal ReadBurstVec			: std_logic_vector(BANK_NUM - 1 downto 0);


begin

	col_ctrl: ddr2_phy_col_ctrl generic map (
		BURST_LENGTH_L => BURST_LENGTH_L,
		BANK_NUM => BANK_NUM,
		COL_L => COL_L
	)
	port map (
		clk => clk,
		rst => rst,

		-- Bank Controller
		BankActiveVec => BankActiveVec,
		ZeroOutstandingBurstsVec => BankCtrlZeroOutstandingBurstsVec,

		EndDataPhaseVec => EndDataPhaseVec,
		ReadBurstVec => ReadBurstVec,

		-- Arbitrer
		CmdAck => ColCtrlCmdAck,

		ColMemOut => ColCtrlColMemOut,
		BankMemOut => ColCtrlBankMemOut,
		CmdOut => ColCtrlCmdOut,
		CmdReq => ColCtrlCmdReq,

		-- Transaction Controller
		CtrlReq => ColCtrlCtrlReq,
		ColMemIn => ColCtrlColMemIn,
		BankMemIn => ColCtrlBankMemIn,
		ReadBurstIn => ColCtrlReadBurstIn,
		BurstLength => ColCtrlBurstLength,

		CtrlAck => ColCtrlCtrlAck
	);


	bank_ctrl_loop : for i in 0 to (BANK_NUM - 1) generate

		bank_ctrl: ddr2_phy_bank_ctrl generic map (
			ROW_L => ROW_L,
			MAX_OUTSTANDING_BURSTS => MAX_OUTSTANDING_BURSTS
		)
		port map (
			clk => clk,
			rst => rst,

			-- Arbitrer
			CmdAck => BankCtrlCmdAck(i),

			RowMemOut => BankCtrlRowMemOut((i+1)*ROW_L downto i*ROW_L),
			CmdOut => BankCtrlCmdOut((i+1)*MEM_CMD_L downto i*MEM_CMD_L),
			CmdReq => BankCtrlCmdReq(i),

			-- Transaction Controller
			CtrlReq => BankCtrlCtrlReq(i),
			RowMemIn => RowMemIn((i+1)*ROW_L downto i*ROW_L),

			CtrlAck => BankCtrlCtrlAck(i),

			-- Column Controller
			ReadBurst => ReadBurstVec(i),
			EndDataPhase => EndDataPhaseVec(i),

			-- Bank Status
			ZeroOutstandingBursts => BankCtrlZeroOutstandingBurstsVec(i),
			BankIdle => BankIdleVec(i),
			BankActive => BankActiveVec(i)

		);
 
	end generate bank_ctrl_loop;

end rtl;