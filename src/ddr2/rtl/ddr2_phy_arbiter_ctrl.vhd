library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library common_rtl_pkg;
use common_rtl_pkg.types_pkg.all;
library ddr2_rtl_pkg;
use ddr2_rtl_pkg.ddr2_phy_pkg.all;
use ddr2_rtl_pkg.ddr2_phy_arbiter_ctrl_pkg.all;
use ddr2_rtl_pkg.ddr2_gen_ac_timing_pkg.all;

entity ddr2_phy_arbiter_ctrl is
--generic (

--);
port (

	rst		: in std_logic;
	clk		: in std_logic;

	ODTCtrlPauseArbiter	: in std_logic;
	BankActCmd		: in std_logic;

	PauseArbiter		: out std_logic;
	AllowBankActivate	: out std_logic
);
end entity ddr2_phy_arbiter_ctrl;

architecture rtl of ddr2_phy_arbiter_ctrl is

	constant zero_four_act_win_cnt					: unsigned(four_act_win_unsigned'length - 1 downto 0) := (others => '0');
	constant incr_four_act_win_cnt_value				: unsigned(four_act_win_unsigned'length - 1 downto 0) := to_unsigned(1, four_act_win_unsigned'length);

	constant incr_four_act_win_ptr_value				: unsigned(int_to_bit_num(WINDOW_L) - 1 downto 0) := to_unsigned(1, int_to_bit_num(WINDOW_L));

	constant zero_act_to_act_cnt					: unsigned(CNT_ACT_TO_ACT_L - 1 downto 0) := (others => '0');
	constant incr_act_to_act_cnt_value				: unsigned(CNT_ACT_TO_ACT_L - 1 downto 0) := to_unsigned(1, CNT_ACT_TO_ACT_L);

	signal CntFourActWinArrC, CntFourActWinArrN			: four_act_win_unsigned_arr(WINDOW_L - 1 downto 0);
	signal FourActWinCntInitValue					: four_act_win_unsigned;
	signal SetFourActWinCntArr					: std_logic_vector(WINDOW_L - 1 downto 0);
	signal FourActWinCntArrEnC, FourActWinCntArrEnN			: std_logic_vector(WINDOW_L - 1 downto 0);
	signal ZeroFourActWinCntArr					: std_logic_vector(WINDOW_L - 1 downto 0);

	signal CntFourActWinNextActPtrC, CntFourActWinNextActPtrN	: unsigned((int_to_bit_num(WINDOW_L) - 1) downto 0);
	signal CntFourActWinLastActPtrC, CntFourActWinLastActPtrN	: unsigned((int_to_bit_num(WINDOW_L) - 1) downto 0);
	signal IncrCntFourActWinPtr					: std_logic;

	signal CntActToActC, CntActToActN				: unsigned(CNT_ACT_TO_ACT_L - 1 downto 0);
	signal ActToActCntInitValue					: unsigned(CNT_ACT_TO_ACT_L - 1 downto 0);
	signal SetActToActCnt						: std_logic;
	signal ActToActCntEnC, ActToActCntEnN				: std_logic;
	signal ZeroActToActCnt						: std_logic;

	signal AllowBankActivate_int					: std_logic;

	signal FourActWinElapsed					: std_logic;

begin

	reg: process(rst, clk)
	begin
		if (rst = '1') then
			CntFourActWinArrC <= (others => (others => '0'));
			FourActWinCntArrEnC <= (others => '0');

			CntFourActWinNextActPtrC <= (others => '0');
			CntFourActWinLastActPtrC <= (others => '0');

			CntActToActC <= (others => '0');
			ActToActCntEnC <= (others => '0');
		elsif ((clk'event) and (clk = '1')) then
			CntFourActWinArrC <= CntFourActWinArrN;
			FourActWinCntArrEnC <= FourActWinCntArrEnN;

			CntFourActWinNextActPtrC <= CntFourActWinNextActPtrN;
			CntFourActWinLastActPtrC <= CntFourActWinLastActPtrN;

			CntActToActC <= CntActToActN;
			ActToActCntEnC <= ActToActCntEnN;
		end if;
	end process reg;

	-- Pause arbiter when updating MRS registers (ODT controller sends the request because ODT is taken low)
	PauseArbiter <= ODTCtrlPauseArbiter;

	-- Four-Active-Window counter initial value. tFAW - 1 because count down to 0
	FourActWinCntInitValue <= to_unsigned((T_FAW_min - 1), four_act_win_unsigned'length);

	AllowBankActivate <= AllowBankActivate_int;

	ZERO_FOUR_ACT_CNT: for i in 0 to (WINDOW_L - 1) generate
		ZeroFourActWinCntArr(i) <= '1' when (CntFourActWinArrC(i) = zero_four_act_win_cnt) else '0';
	end generate ZERO_FOUR_ACT_CNT;

	FOUR_ACT_CNT_EN: for i in 0 to (WINDOW_L - 1) generate
		FourActWinCntArrEnN(i) <= '1' when (CntFourActWinNextActPtrC = to_unsigned(i, int_to_bit_num(WINDOW_L))) else FourActWinCntArrEnC;
	end generate FOUR_ACT_CNT_EN;

	SET_FOUR_ACT_CNT: for i in 0 to (WINDOW_L - 1) generate
		SetFourActWinCntArr(i) <= BankActCmd when (CntFourActWinNextActPtrC = to_unsigned(i, int_to_bit_num(WINDOW_L))) else '0';
	end generate SET_FOUR_ACT_CNT;

	FOUR_ACT_CNT: for i in 0 to (WINDOW_L - 1) generate
		CntFourActWinArrN(i) <=	FourActWinCntInitValue					when (SetFourActWinCntArr(i) = '1') else
					(CntFourActWinArrC(i) - incr_four_act_win_cnt_value)	when ((FourActWinCntArrEnC(i) = '1') and (ZeroFourActWinCntArr(i) = '0')) else
					CntFourActWinArrC(i);
	end generate FOUR_ACT_CNT;

	tFAW_mux: process(ZeroFourActWinCntArr, CntFourActWinLastActPtrC)
	begin
		FourActWinElapsed <= '0';
		for i in 0 to (WINDOW_L - 1) loop
			if (CntFourActWinLastActPtrC = to_unsigned(i, int_to_bit_num(WINDOW_L))) begin
				FourActWinElapsed <= ZeroFourActWinCntArr(i);
			end if;
		end loop;
	end process tFAW_mux;

	IncrCntFourActWinPtr <= BankActCmd;

	CntFourActWinLastActPtrN <= (CntFourActWinLastActPtrC + incr_four_act_win_ptr_value) when (IncrCntFourActWinPtr = '1') else CntFourActWinLastActPtrC;
	CntFourActWinNextActPtrN <= (CntFourActWinNextActPtrC + incr_four_act_win_ptr_value) when (IncrCntFourActWinPtr = '1') else CntFourActWinNextActPtrC;

	-- Activate to Activate counter initial value. tRRD - 1 because count down to 0
	ActToActCntInitValue <= to_unsigned((T_RRD - 1), CNT_ACT_TO_ACT_L);

	SetActToActCnt <= BankActCmd;

	ActToActCntEnN <= '1' when SetActToActCnt else ActToActCntEnC;

	ZeroActToActCnt <= '1' when (CntActToActC(i) = zero_act_to_act_cnt) else '0';

	CntActToActN(i) <=	ActToActCntInitValue					when (SetActToActCnt(i) = '1') else
				(CntActToActC(i) - incr_act_to_act_cnt_value)		when ((ActToActCntEnC(i) = '1') and (ZeroActToActCnt(i) = '0')) else
				CntActToActC(i);

	AllowBankActivate_int <= FourActWinElapsed and ZeroActToActCnt;

end rtl;
