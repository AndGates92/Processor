library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.functions_pkg.all;
use work.ddr2_phy_pkg.all;
use work.ddr2_mrs_max_pkg.all;
use work.ddr2_phy_col_ctrl_pkg.all;
use work.ddr2_phy_bank_ctrl_pkg.all;

entity ddr2_phy_cmd_ctrl is
generic (
	BANK_CTRL_NUM		: positive := 8;
	COL_CTRL_NUM		: positive := 1;
	BURST_LENGTH_L		: positive := 5;
	BANK_NUM		: positive := 8;
	COL_L			: positive := 10;
	ROW_L			: positive := 13;
	MAX_OUTSTANDING_BURSTS	: positive := 10
);
port (
	rst		: in std_logic;
	clk		: in std_logic;

	-- MRS configuration
	DDR2CASLatency			: in std_logic_vector(int_to_bit_num(CAS_LATENCY_MAX_VALUE) - 1 downto 0);
	DDR2BurstLength		: in std_logic_vector(int_to_bit_num(BURST_LENGTH_MAX_VALUE) - 1 downto 0);
	DDR2AdditiveLatency	: in std_logic_vector(int_to_bit_num(AL_MAX_VALUE) - 1 downto 0);
	DDR2WriteLatency	: in std_logic_vector(int_to_bit_num(WRITE_LATENCY_MAX_VALUE) - 1 downto 0);

	-- Column Controller
	-- Arbitrer
	ColCtrlCmdAck		: in std_logic_vector(COL_CTRL_NUM - 1 downto 0);

	ColCtrlColMemOut	: out std_logic_vector(COL_CTRL_NUM*COL_L - 1 downto 0);
	ColCtrlBankMemOut	: out std_logic_vector(COL_CTRL_NUM*(int_to_bit_num(BANK_NUM)) - 1 downto 0);
	ColCtrlCmdOut		: out std_logic_vector(COL_CTRL_NUM*MEM_CMD_L - 1 downto 0);
	ColCtrlCmdReq		: out std_logic_vector(COL_CTRL_NUM - 1 downto 0);

	-- Controller
	ColCtrlCtrlReq		: in std_logic_vector(COL_CTRL_NUM - 1 downto 0);
	ColCtrlReadBurstIn	: in std_logic_vector(COL_CTRL_NUM - 1 downto 0);
	ColCtrlColMemIn		: in std_logic_vector(COL_CTRL_NUM*COL_L - 1 downto 0);
	ColCtrlBankMemIn	: in std_logic_vector(COL_CTRL_NUM*(int_to_bit_num(BANK_NUM)) - 1 downto 0);
	ColCtrlBurstLength	: in std_logic_vector(COL_CTRL_NUM*BURST_LENGTH_L - 1 downto 0);

	ColCtrlCtrlAck		: out std_logic_vector(COL_CTRL_NUM - 1 downto 0);

	-- Bank Controllers
	-- Arbitrer
	BankCtrlCmdAck		: in std_logic_vector(BANK_CTRL_NUM - 1 downto 0);

	BankCtrlRowMemOut	: out std_logic_vector(BANK_CTRL_NUM*ROW_L - 1 downto 0);
	BankCtrlBankMemOut	: out std_logic_vector(BANK_CTRL_NUM*(int_to_bit_num(BANK_NUM)) - 1 downto 0);
	BankCtrlCmdOut		: out std_logic_vector(BANK_CTRL_NUM*MEM_CMD_L - 1 downto 0);
	BankCtrlCmdReq		: out std_logic_vector(BANK_CTRL_NUM - 1 downto 0);

	-- Transaction Controller
	BankCtrlRowMemIn	: in std_logic_vector(BANK_CTRL_NUM*ROW_L - 1 downto 0);
	BankCtrlCtrlReq		: in std_logic_vector(BANK_CTRL_NUM - 1 downto 0);

	BankCtrlCtrlAck		: out std_logic_vector(BANK_CTRL_NUM - 1 downto 0);

	-- Status
	BankIdleVec		: out std_logic_vector(BANK_CTRL_NUM - 1 downto 0)

);
end entity ddr2_phy_cmd_ctrl;

architecture rtl of ddr2_phy_cmd_ctrl is

	signal BankActiveVec			: std_logic_vector(BANK_CTRL_NUM - 1 downto 0);
	signal BankCtrlZeroOutstandingBurstsVec	: std_logic_vector(BANK_CTRL_NUM - 1 downto 0);
	signal EndDataPhaseVec			: std_logic_vector(BANK_CTRL_NUM - 1 downto 0);
	signal ReadBurstVec			: std_logic_vector(BANK_CTRL_NUM - 1 downto 0);


begin

	col_ctrl_loop : for i in 0 to (COL_CTRL_NUM - 1) generate

		col_ctrl: ddr2_phy_col_ctrl generic map (
			BURST_LENGTH_L => BURST_LENGTH_L,
			BANK_NUM => BANK_NUM,
			COL_L => COL_L
		)
		port map (
			clk => clk,
			rst => rst,

			-- MRS configuration
			DDR2CASLatency => DDR2CASLatency,
			DDR2BurstLength => DDR2BurstLength,

			-- Bank Controller
			BankActiveVec => BankActiveVec,
			ZeroOutstandingBurstsVec => BankCtrlZeroOutstandingBurstsVec,

			EndDataPhaseVec => EndDataPhaseVec,
			ReadBurstVec => ReadBurstVec,

			-- Arbitrer
			CmdAck => ColCtrlCmdAck(i),

			ColMemOut => ColCtrlColMemOut(((i+1)*COL_L - 1) downto i*COL_L),
			BankMemOut => ColCtrlBankMemOut(((i+1)*(int_to_bit_num(BANK_NUM)) - 1) downto i*(int_to_bit_num(BANK_NUM))),
			CmdOut => ColCtrlCmdOut(((i+1)*MEM_CMD_L - 1) downto i*MEM_CMD_L),
			CmdReq => ColCtrlCmdReq(i),

			-- Transaction Controller
			CtrlReq => ColCtrlCtrlReq(i),
			ColMemIn => ColCtrlColMemIn(((i+1)*COL_L - 1) downto i*COL_L),
			BankMemIn => ColCtrlBankMemIn(((i+1)*(int_to_bit_num(BANK_NUM)) - 1) downto i*(int_to_bit_num(BANK_NUM))),
			ReadBurstIn => ColCtrlReadBurstIn(i),
			BurstLength => ColCtrlBurstLength(((i+1)*BURST_LENGTH_L - 1) downto i*BURST_LENGTH_L),

			CtrlAck => ColCtrlCtrlAck(i)
		);

	end generate col_ctrl_loop;


	bank_ctrl_loop : for i in 0 to (BANK_CTRL_NUM - 1) generate

		bank_ctrl: ddr2_phy_bank_ctrl generic map (
			ROW_L => ROW_L,
			BANK_ID => i,
			BANK_NUM => BANK_NUM,
			MAX_OUTSTANDING_BURSTS => MAX_OUTSTANDING_BURSTS
		)
		port map (
			clk => clk,
			rst => rst,

			-- MRS configuration
			DDR2BurstLength => DDR2BurstLength,
			DDR2AdditiveLatency => DDR2AdditiveLatency,
			DDR2WriteLatency => DDR2WriteLatency,

			-- Arbitrer
			CmdAck => BankCtrlCmdAck(i),

			RowMemOut => BankCtrlRowMemOut(((i+1)*ROW_L - 1) downto i*ROW_L),
			BankMemOut => BankCtrlBankMemOut(((i+1)*(int_to_bit_num(BANK_NUM)) - 1) downto i*(int_to_bit_num(BANK_NUM))),
			CmdOut => BankCtrlCmdOut(((i+1)*MEM_CMD_L - 1) downto i*MEM_CMD_L),
			CmdReq => BankCtrlCmdReq(i),

			-- Transaction Controller
			CtrlReq => BankCtrlCtrlReq(i),
			RowMemIn => BankCtrlRowMemIn(((i+1)*ROW_L - 1) downto i*ROW_L),

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
