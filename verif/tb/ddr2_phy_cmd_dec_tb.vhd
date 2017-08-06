library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.textio.all;

library work;
use work.ddr2_define_pkg.all;
use work.ddr2_phy_pkg.all;
use work.ddr2_phy_cmd_dec_pkg.all;
use work.type_conversion_pkg.all;
use work.tb_pkg.all;
use work.proc_pkg.all;
use work.ddr2_pkg_tb.all;

entity ddr2_phy_cmd_dec_tb is
end entity ddr2_phy_cmd_dec_tb;

architecture bench of ddr2_phy_cmd_dec_tb is

	constant CLK_PERIOD	: time := DDR2_CLK_PERIOD * 1 ns;
	constant NUM_TEST	: integer := 1000;
	constant NUM_EXTRA_TEST	: integer := 0;
	constant TOT_NUM_TEST	: integer := NUM_TEST + NUM_EXTRA_TEST;

	constant MAX_COMMANDS_PER_TEST		: integer := 50;

	signal clk_tb	: std_logic := '0';
	signal stop	: boolean := false;
	signal rst_tb	: std_logic;

	signal ColIn_tb			: std_logic_vector(COL_L_TB - 1 downto 0);
	signal RowIn_tb			: std_logic_vector(ROW_L_TB - 1 downto 0);
	signal BankIn_tb		: std_logic_vector(int_to_bit_num(BANK_NUM_TB) - 1 downto 0);
	signal CmdIn_tb			: std_logic_vector(MEM_CMD_L - 1 downto 0);
	signal MRSCmd_tb		: std_logic_vector(ADDR_MEM_L_TB - 1 downto 0);

	signal ClkEnable_tb		: std_logic;
	signal nChipSelect_tb		: std_logic;
	signal nRowAccessStrobe_tb	: std_logic;
	signal nColAccessStrobe_tb	: std_logic;
	signal nWriteEnable_tb		: std_logic;
	signal BankOut_tb		: std_logic_vector(int_to_bit_num(BANK_NUM_TB) - 1 downto 0);
	signal Address_tb		: std_logic_vector(ADDR_MEM_L_TB - 1 downto 0);

begin

	DUT: ddr2_phy_cmd_dec generic map (
		BANK_NUM => BANK_NUM_TB,
		COL_L => COL_L_TB,
		ROW_L => ROW_L_TB,
		ADDR_L => ADDR_MEM_L_TB
	)
	port map (
		clk => clk_tb,
		rst => rst_tb,

		ColIn => ColIn_tb,
		RowIn => RowIn_tb,
		BankIn => BankIn_tb,
		CmdIn => CmdIn_tb,
		MRSCmd => MRSCmd_tb,

		ClkEnable => ClkEnable_tb,
		nChipSelect => nChipSelect_tb,
		nRowAccessStrobe => nRowAccessStrobe_tb,
		nColAccessStrobe => nColAccessStrobe_tb,
		nWriteEnable => nWriteEnable_tb,
		BankOut => BankOut_tb,
		Address => Address_tb

	);
 
	clk_gen(CLK_PERIOD, 0 ns, stop, clk_tb);

	test: process

		procedure reset is
		begin
			rst_tb <= '0';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_tb <= '1';
			wait until ((clk_tb'event) and (clk_tb = '1'));
			rst_tb <= '0';
		end procedure reset;

		procedure test_param(variable num_commands : out integer; variable col, row, bank, cmd, mrs_cmd : out int_arr(0 to (MAX_COMMANDS_PER_TEST - 1)); variable seed1, seed2 : inout positive) is
			variable rand_val		: real;
			variable num_commands_int	: integer;
		begin

			num_commands_int := 0;
			while (num_commands_int = 0) loop
				uniform(seed1, seed2, rand_val);
				num_commands_int := integer(rand_val*real(MAX_COMMANDS_PER_TEST));
			end loop;
			num_commands := num_commands_int;

			for i in 0 to (num_commands_int - 1) loop
				uniform(seed1, seed2, rand_val);
				col(i) := integer(rand_val*real(2.0**(real(COL_L_TB))));
				uniform(seed1, seed2, rand_val);
				row(i) := integer(rand_val*real(2.0**(real(ROW_L_TB))));
				uniform(seed1, seed2, rand_val);
				bank(i) := integer(rand_val*real(BANK_NUM_TB - 1));
				uniform(seed1, seed2, rand_val);
				cmd(i) := integer(rand_val*real(2.0**(real(MEM_CMD_L))));
				uniform(seed1, seed2, rand_val);
				mrs_cmd(i) := integer(rand_val*real(2.0**(real(ADDR_MEM_L_TB))));
			end loop;
			for i in num_commands_int to (MAX_COMMANDS_PER_TEST - 1) loop
				col(i) := int_arr_def;
				row(i) := int_arr_def;
				bank(i) := int_arr_def;
				cmd(i) := int_arr_def;
				mrs_cmd(i) := int_arr_def;
			end loop;

		end procedure test_param;

		procedure run_cmd_dec(variable num_commands_exp : in integer; variable col_exp, row_exp, bank_exp, cmd, mrs_cmd : in int_arr(0 to (MAX_COMMANDS_PER_TEST - 1)); variable num_commands_rtl : out integer; variable clk_enable, chip_sel_n, ras_n, cas_n, wr_en_n : out bool_arr(0 to (MAX_COMMANDS_PER_TEST - 1)); variable bank_rtl, address_rtl : out int_arr(0 to (MAX_COMMANDS_PER_TEST - 1))) is

			variable num_commands_rtl_int		: integer;
			variable num_dec_commands_rtl_int	: integer;

			variable cmd_sent	: boolean;

		begin
			num_commands_rtl_int := 0;
			num_dec_commands_rtl_int := 0;

			cmd_sent := false;

			ref_loop: loop

				exit ref_loop when ((num_commands_rtl_int = num_commands_exp) and (num_dec_commands_rtl_int = num_commands_exp));

				if (cmd_sent = true) then
					if (num_dec_commands_rtl_int < num_commands_exp) then
						clk_enable(num_dec_commands_rtl_int) := std_logic_to_bool(ClkEnable_tb);
						chip_sel_n(num_dec_commands_rtl_int) := std_logic_to_bool(nChipSelect_tb);
						ras_n(num_dec_commands_rtl_int) := std_logic_to_bool(nRowAccessStrobe_tb);
						cas_n(num_dec_commands_rtl_int) := std_logic_to_bool(nColAccessStrobe_tb);
						wr_en_n(num_dec_commands_rtl_int) := std_logic_to_bool(nWriteEnable_tb);
						bank_rtl(num_dec_commands_rtl_int) := to_integer(unsigned(BankOut_tb));
						address_rtl(num_dec_commands_rtl_int) := to_integer(unsigned(Address_tb));

						num_dec_commands_rtl_int := num_dec_commands_rtl_int + 1;
					end if;
				end if;

				if (num_commands_rtl_int < num_commands_exp) then
					ColIn_tb <= std_logic_vector(to_unsigned(col_exp(num_commands_rtl_int), COL_L_TB));
					RowIn_tb <= std_logic_vector(to_unsigned(row_exp(num_commands_rtl_int), ROW_L_TB));
					BankIn_tb <= std_logic_vector(to_unsigned(bank_exp(num_commands_rtl_int), int_to_bit_num(BANK_NUM_TB)));
					CmdIn_tb <= std_logic_vector(to_unsigned(cmd(num_commands_rtl_int), MEM_CMD_L));
					MRSCmd_tb <= std_logic_vector(to_unsigned(mrs_cmd(num_commands_rtl_int), ADDR_MEM_L_TB));

					num_commands_rtl_int := num_commands_rtl_int + 1;
					cmd_sent := true;
				end if;

				wait until ((clk_tb'event) and (clk_tb = '1'));

				wait for 1 ps;

			end loop;

			num_commands_rtl := num_commands_rtl_int;

		end procedure run_cmd_dec;

		procedure verify(variable num_commands_exp, num_commands_rtl : in integer; variable clk_enable, chip_sel_n, ras_n, cas_n, wr_en_n : in bool_arr(0 to (MAX_COMMANDS_PER_TEST - 1)); variable bank_exp, bank_rtl, address_rtl, cmd : in int_arr(0 to (MAX_COMMANDS_PER_TEST - 1)); file file_pointer : text; variable pass: out integer) is
			variable file_line	: line;

			variable address_bit_vec	: std_logic_vector(ADDR_MEM_L_TB - 1 downto 0);

			variable errors		: integer;

		begin

			errors := 0;

			write(file_line, string'( "PHY Command Decoder: Number of commands: " & integer'image(num_commands_exp)));
			writeline(file_pointer, file_line);

			for i in 0 to (num_commands_exp - 1) loop
				if (cmd(i) = to_integer(unsigned(CMD_NOP))) then
					if ((chip_sel_n(i) = false) and (ras_n(i) = true) and (cas_n(i) = true) and (wr_en_n(i) = true)) then
						write(file_line, string'("PHY Command Decoder: NOP Command correctly decoded"));
						writeline(file_pointer, file_line);
					else
						write(file_line, string'("PHY Command Decoder: NOP Command: cs_n exp false rtl " & bool_to_str(chip_sel_n(i)) & " ras_n exp true rtl " & bool_to_str(ras_n(i)) & " cas_n exp true rtl " & bool_to_str(cas_n(i))  & " wr_en_n exp true rtl " & bool_to_str(wr_en_n(i))));
						writeline(file_pointer, file_line);

						errors := errors + 1;
					end if;
				elsif (cmd(i) = to_integer(unsigned(CMD_DESEL))) then
					if (chip_sel_n(i) = true) then
						write(file_line, string'("PHY Command Decoder: DESEL Command correctly decoded"));
						writeline(file_pointer, file_line);
					else
						write(file_line, string'("PHY Command Decoder: DESEL Command: cs_n exp true rtl " & bool_to_str(chip_sel_n(i))));
						writeline(file_pointer, file_line);

						errors := errors + 1;
					end if;
				elsif (cmd(i) = to_integer(unsigned(CMD_BANK_ACT))) then
					if ((clk_enable(i) = true) and (chip_sel_n(i) = false) and (ras_n(i) = false) and (cas_n(i) = true) and (wr_en_n(i) = true) and (bank_rtl(i) = bank_exp(i))) then
						write(file_line, string'("PHY Command Decoder: Activate Command correctly decoded"));
						writeline(file_pointer, file_line);
					else
						write(file_line, string'("PHY Command Decoder: Activate Command: clk_enable exp true rtl " & bool_to_str(clk_enable(i)) & " cs_n exp false rtl " & bool_to_str(chip_sel_n(i)) & " ras_n exp false rtl " & bool_to_str(ras_n(i)) & " cas_n exp true rtl " & bool_to_str(cas_n(i))  & " wr_en_n exp true rtl " & bool_to_str(wr_en_n(i)) & " bank exp " & integer'image(bank_exp(i)) & " rtl " & integer'image(bank_rtl(i))));
						writeline(file_pointer, file_line);

						errors := errors + 1;
					end if;
				elsif (cmd(i) = to_integer(unsigned(CMD_MODE_REG_SET))) then
					if ((clk_enable(i) = true) and (chip_sel_n(i) = false) and (ras_n(i) = false) and (cas_n(i) = false) and (wr_en_n(i) = false) and (bank_rtl(i) = 0)) then
						write(file_line, string'("PHY Command Decoder: MRS Command correctly decoded"));
						writeline(file_pointer, file_line);
					else
						write(file_line, string'("PHY Command Decoder: MRS Command: clk_enable exp true rtl " & bool_to_str(clk_enable(i)) & " cs_n exp false rtl " & bool_to_str(chip_sel_n(i)) & " ras_n exp false rtl " & bool_to_str(ras_n(i)) & " cas_n exp false rtl " & bool_to_str(cas_n(i))  & " wr_en_n exp false rtl " & bool_to_str(wr_en_n(i)) & " bank exp 0 rtl " & integer'image(bank_rtl(i))));
						writeline(file_pointer, file_line);

						errors := errors + 1;
					end if;
				elsif (cmd(i) = to_integer(unsigned(CMD_EXT_MODE_REG_SET_1))) then
					if ((clk_enable(i) = true) and (chip_sel_n(i) = false) and (ras_n(i) = false) and (cas_n(i) = false) and (wr_en_n(i) = false) and (bank_rtl(i) = 1)) then
						write(file_line, string'("PHY Command Decoder: EMRS1 Command correctly decoded"));
						writeline(file_pointer, file_line);
					else
						write(file_line, string'("PHY Command Decoder: EMRS1 Command: clk_enable exp true rtl " & bool_to_str(clk_enable(i)) & " cs_n exp false rtl " & bool_to_str(chip_sel_n(i)) & " ras_n exp false rtl " & bool_to_str(ras_n(i)) & " cas_n exp false rtl " & bool_to_str(cas_n(i))  & " wr_en_n exp false rtl " & bool_to_str(wr_en_n(i)) & " bank exp 1 rtl " & integer'image(bank_rtl(i))));
						writeline(file_pointer, file_line);

						errors := errors + 1;
					end if;
				elsif (cmd(i) = to_integer(unsigned(CMD_EXT_MODE_REG_SET_2))) then
					if ((clk_enable(i) = true) and (chip_sel_n(i) = false) and (ras_n(i) = false) and (cas_n(i) = false) and (wr_en_n(i) = false) and (bank_rtl(i) = 2)) then
						write(file_line, string'("PHY Command Decoder: EMRS2 Command correctly decoded"));
						writeline(file_pointer, file_line);
					else
						write(file_line, string'("PHY Command Decoder: EMRS2 Command: clk_enable exp true rtl " & bool_to_str(clk_enable(i)) & " cs_n exp false rtl " & bool_to_str(chip_sel_n(i)) & " ras_n exp false rtl " & bool_to_str(ras_n(i)) & " cas_n exp false rtl " & bool_to_str(cas_n(i))  & " wr_en_n exp false rtl " & bool_to_str(wr_en_n(i)) & " bank exp 2 rtl " & integer'image(bank_rtl(i))));
						writeline(file_pointer, file_line);

						errors := errors + 1;
					end if;
				elsif (cmd(i) = to_integer(unsigned(CMD_EXT_MODE_REG_SET_3))) then
					if ((clk_enable(i) = true) and (chip_sel_n(i) = false) and (ras_n(i) = false) and (cas_n(i) = false) and (wr_en_n(i) = false) and (bank_rtl(i) = 3)) then
						write(file_line, string'("PHY Command Decoder: EMRS3 Command correctly decoded"));
						writeline(file_pointer, file_line);
					else
						write(file_line, string'("PHY Command Decoder: EMRS3 Command: clk_enable exp true rtl " & bool_to_str(clk_enable(i)) & " cs_n exp false rtl " & bool_to_str(chip_sel_n(i)) & " ras_n exp false rtl " & bool_to_str(ras_n(i)) & " cas_n exp false rtl " & bool_to_str(cas_n(i))  & " wr_en_n exp false rtl " & bool_to_str(wr_en_n(i)) & " bank exp 3 rtl " & integer'image(bank_rtl(i))));
						writeline(file_pointer, file_line);

						errors := errors + 1;
					end if;
				elsif (cmd(i) = to_integer(unsigned(CMD_AUTO_REF))) then
					if ((clk_enable(i) = true) and (chip_sel_n(i) = false) and (ras_n(i) = false) and (cas_n(i) = false) and (wr_en_n(i) = true)) then
						write(file_line, string'("PHY Command Decoder: Auto-Refresh Command correctly decoded"));
						writeline(file_pointer, file_line);
					else
						write(file_line, string'("PHY Command Decoder: Auto-Refresh Command: clk_enable exp true rtl " & bool_to_str(clk_enable(i)) & " cs_n exp false rtl " & bool_to_str(chip_sel_n(i)) & " ras_n exp false rtl " & bool_to_str(ras_n(i)) & " cas_n exp false rtl " & bool_to_str(cas_n(i))  & " wr_en_n exp true rtl " & bool_to_str(wr_en_n(i))));
						writeline(file_pointer, file_line);

						errors := errors + 1;
					end if;
				elsif (cmd(i) = to_integer(unsigned(CMD_SELF_REF_ENTRY))) then
					if ((clk_enable(i) = false) and (chip_sel_n(i) = false) and (ras_n(i) = false) and (cas_n(i) = false) and (wr_en_n(i) = true)) then
						write(file_line, string'("PHY Command Decoder: Self-Refresh Entry Command correctly decoded"));
						writeline(file_pointer, file_line);
					else
						write(file_line, string'("PHY Command Decoder: Self-Refresh Entry Command: clk_enable exp false rtl " & bool_to_str(clk_enable(i)) & " cs_n exp false rtl " & bool_to_str(chip_sel_n(i)) & " ras_n exp false rtl " & bool_to_str(ras_n(i)) & " cas_n exp false rtl " & bool_to_str(cas_n(i))  & " wr_en_n exp true rtl " & bool_to_str(wr_en_n(i))));
						writeline(file_pointer, file_line);

						errors := errors + 1;
					end if;
				elsif (cmd(i) = to_integer(unsigned(CMD_SELF_REF_EXIT))) then
					if ((clk_enable(i) = true) and (chip_sel_n(i) = true)) then
						write(file_line, string'("PHY Command Decoder: Self-Refresh Exit Command correctly decoded"));
						writeline(file_pointer, file_line);
					elsif ((clk_enable(i) = true) and (chip_sel_n(i) = false) and (ras_n(i) = true) and (cas_n(i) = true) and (wr_en_n(i) = true)) then
						write(file_line, string'("PHY Command Decoder: Self-Refresh Exit Command correctly decoded"));
						writeline(file_pointer, file_line);
					else
						write(file_line, string'("PHY Command Decoder: Self-Refresh Exit Command: clk_enable exp true rtl " & bool_to_str(clk_enable(i)) & " cs_n exp false rtl " & bool_to_str(chip_sel_n(i)) & " ras_n exp true rtl " & bool_to_str(ras_n(i)) & " cas_n exp true rtl " & bool_to_str(cas_n(i))  & " wr_en_n exp true rtl " & bool_to_str(wr_en_n(i))));
						writeline(file_pointer, file_line);

						write(file_line, string'("PHY Command Decoder: Self-Refresh Exit Command: clk_enable exp true rtl " & bool_to_str(clk_enable(i)) & " cs_n exp true rtl " & bool_to_str(chip_sel_n(i))));
						writeline(file_pointer, file_line);

						errors := errors + 1;
					end if;
				elsif (cmd(i) = to_integer(unsigned(CMD_POWER_DOWN_ENTRY))) then
					if ((clk_enable(i) = false) and (chip_sel_n(i) = true)) then
						write(file_line, string'("PHY Command Decoder: Power Down Entry Command correctly decoded"));
						writeline(file_pointer, file_line);
					elsif ((clk_enable(i) = false) and (chip_sel_n(i) = false) and (ras_n(i) = true) and (cas_n(i) = true) and (wr_en_n(i) = true)) then
						write(file_line, string'("PHY Command Decoder: Power Down Entry Command correctly decoded"));
						writeline(file_pointer, file_line);
					else
						write(file_line, string'("PHY Command Decoder: Power Down Entry Command: clk_enable exp false rtl " & bool_to_str(clk_enable(i)) & " cs_n exp false rtl " & bool_to_str(chip_sel_n(i)) & " ras_n exp true rtl " & bool_to_str(ras_n(i)) & " cas_n exp true rtl " & bool_to_str(cas_n(i))  & " wr_en_n exp true rtl " & bool_to_str(wr_en_n(i))));
						writeline(file_pointer, file_line);

						write(file_line, string'("PHY Command Decoder: Power Down Entry Command: clk_enable exp false rtl " & bool_to_str(clk_enable(i)) & " cs_n exp true rtl " & bool_to_str(chip_sel_n(i))));
						writeline(file_pointer, file_line);

						errors := errors + 1;
					end if;
				elsif (cmd(i) = to_integer(unsigned(CMD_POWER_DOWN_EXIT))) then
					if ((clk_enable(i) = true) and (chip_sel_n(i) = true)) then
						write(file_line, string'("PHY Command Decoder: Power Down Exit Command correctly decoded"));
						writeline(file_pointer, file_line);
					elsif ((clk_enable(i) = true) and (chip_sel_n(i) = false) and (ras_n(i) = true) and (cas_n(i) = true) and (wr_en_n(i) = true)) then
						write(file_line, string'("PHY Command Decoder: Power Down Exit Command correctly decoded"));
						writeline(file_pointer, file_line);
					else
						write(file_line, string'("PHY Command Decoder: Power Down Exit Command: clk_enable exp true rtl " & bool_to_str(clk_enable(i)) & " cs_n exp false rtl " & bool_to_str(chip_sel_n(i)) & " ras_n exp true rtl " & bool_to_str(ras_n(i)) & " cas_n exp true rtl " & bool_to_str(cas_n(i))  & " wr_en_n exp true rtl " & bool_to_str(wr_en_n(i))));
						writeline(file_pointer, file_line);

						write(file_line, string'("PHY Command Decoder: Power Down Exit Command: clk_enable exp true rtl " & bool_to_str(clk_enable(i)) & " cs_n exp true rtl " & bool_to_str(chip_sel_n(i))));
						writeline(file_pointer, file_line);

						errors := errors + 1;
					end if;
				elsif (cmd(i) = to_integer(unsigned(CMD_BANK_PRECHARGE))) then
					address_bit_vec := std_logic_vector(to_unsigned(address_rtl(i), ADDR_MEM_L_TB));
					if ((clk_enable(i) = true) and (chip_sel_n(i) = false) and (ras_n(i) = false) and (cas_n(i) = true) and (wr_en_n(i) = false) and (bank_rtl(i) = bank_exp(i)) and (address_bit_vec(10) = '0')) then
						write(file_line, string'("PHY Command Decoder: Single Bank Precharge Command correctly decoded"));
						writeline(file_pointer, file_line);
					else
						write(file_line, string'("PHY Command Decoder: Single Bank Precharge Command: clk_enable exp true rtl " & bool_to_str(clk_enable(i)) & " cs_n exp false rtl " & bool_to_str(chip_sel_n(i)) & " ras_n exp false rtl " & bool_to_str(ras_n(i)) & " cas_n exp true rtl " & bool_to_str(cas_n(i))  & " wr_en_n exp false rtl " & bool_to_str(wr_en_n(i)) & " bank exp " & integer'image(bank_exp(i)) & " rtl " & integer'image(bank_rtl(i)) & " Bit 10 address: exp false rtl " & std_logic_to_str(address_bit_vec(10))));
						writeline(file_pointer, file_line);

						errors := errors + 1;
					end if;
				elsif (cmd(i) = to_integer(unsigned(CMD_ALL_BANK_PRECHARGE))) then
					address_bit_vec := std_logic_vector(to_unsigned(address_rtl(i), ADDR_MEM_L_TB));
					if ((clk_enable(i) = true) and (chip_sel_n(i) = false) and (ras_n(i) = false) and (cas_n(i) = true) and (wr_en_n(i) = false) and (bank_rtl(i) = bank_exp(i)) and (address_bit_vec(10) = '1')) then
						write(file_line, string'("PHY Command Decoder: All Bank Precharge Command correctly decoded"));
						writeline(file_pointer, file_line);
					else
						write(file_line, string'("PHY Command Decoder: All Bank Precharge Command: clk_enable exp true rtl " & bool_to_str(clk_enable(i)) & " cs_n exp false rtl " & bool_to_str(chip_sel_n(i)) & " ras_n exp false rtl " & bool_to_str(ras_n(i)) & " cas_n exp true rtl " & bool_to_str(cas_n(i))  & " wr_en_n exp false rtl " & bool_to_str(wr_en_n(i)) & " bank exp " & integer'image(bank_exp(i)) & " rtl " & integer'image(bank_rtl(i)) & " Bit 10 address: exp true rtl " & std_logic_to_str(address_bit_vec(10))));
						writeline(file_pointer, file_line);

						errors := errors + 1;
					end if;
				elsif (cmd(i) = to_integer(unsigned(CMD_WRITE))) then
					address_bit_vec := std_logic_vector(to_unsigned(address_rtl(i), ADDR_MEM_L_TB));
					if ((clk_enable(i) = true) and (chip_sel_n(i) = false) and (ras_n(i) = true) and (cas_n(i) = false) and (wr_en_n(i) = false) and (bank_rtl(i) = bank_exp(i)) and (address_bit_vec(10) = '0')) then
						write(file_line, string'("PHY Command Decoder: Write Command correctly decoded"));
						writeline(file_pointer, file_line);
					else
						write(file_line, string'("PHY Command Decoder: Write Command: clk_enable exp true rtl " & bool_to_str(clk_enable(i)) & " cs_n exp false rtl " & bool_to_str(chip_sel_n(i)) & " ras_n exp true rtl " & bool_to_str(ras_n(i)) & " cas_n exp false rtl " & bool_to_str(cas_n(i))  & " wr_en_n exp false rtl " & bool_to_str(wr_en_n(i)) & " bank exp " & integer'image(bank_exp(i)) & " rtl " & integer'image(bank_rtl(i)) & " Bit 10 address: exp false rtl " & std_logic_to_str(address_bit_vec(10))));
						writeline(file_pointer, file_line);

						errors := errors + 1;
					end if;
				elsif (cmd(i) = to_integer(unsigned(CMD_WRITE_PRECHARGE))) then
					address_bit_vec := std_logic_vector(to_unsigned(address_rtl(i), ADDR_MEM_L_TB));
					if ((clk_enable(i) = true) and (chip_sel_n(i) = false) and (ras_n(i) = true) and (cas_n(i) = false) and (wr_en_n(i) = false) and (bank_rtl(i) = bank_exp(i)) and (address_bit_vec(10) = '1')) then
						write(file_line, string'("PHY Command Decoder: Write Command with Auto Precharge correctly decoded"));
						writeline(file_pointer, file_line);
					else
						write(file_line, string'("PHY Command Decoder: Write Command with Auto Precharge: clk_enable exp true rtl " & bool_to_str(clk_enable(i)) & " cs_n exp false rtl " & bool_to_str(chip_sel_n(i)) & " ras_n exp true rtl " & bool_to_str(ras_n(i)) & " cas_n exp false rtl " & bool_to_str(cas_n(i))  & " wr_en_n exp false rtl " & bool_to_str(wr_en_n(i)) & " bank exp " & integer'image(bank_exp(i)) & " rtl " & integer'image(bank_rtl(i)) & " Bit 10 address: exp true rtl " & std_logic_to_str(address_bit_vec(10))));
						writeline(file_pointer, file_line);

						errors := errors + 1;
					end if;
				elsif (cmd(i) = to_integer(unsigned(CMD_READ))) then
					address_bit_vec := std_logic_vector(to_unsigned(address_rtl(i), ADDR_MEM_L_TB));
					if ((clk_enable(i) = true) and (chip_sel_n(i) = false) and (ras_n(i) = true) and (cas_n(i) = false) and (wr_en_n(i) = true) and (bank_rtl(i) = bank_exp(i)) and (address_bit_vec(10) = '0')) then
						write(file_line, string'("PHY Command Decoder: Read Command correctly decoded"));
						writeline(file_pointer, file_line);
					else
						write(file_line, string'("PHY Command Decoder: Read Command: clk_enable exp true rtl " & bool_to_str(clk_enable(i)) & " cs_n exp false rtl " & bool_to_str(chip_sel_n(i)) & " ras_n exp true rtl " & bool_to_str(ras_n(i)) & " cas_n exp false rtl " & bool_to_str(cas_n(i))  & " wr_en_n exp true rtl " & bool_to_str(wr_en_n(i)) & " bank exp " & integer'image(bank_exp(i)) & " rtl " & integer'image(bank_rtl(i)) & " Bit 10 address: exp false rtl " & std_logic_to_str(address_bit_vec(10))));
						writeline(file_pointer, file_line);

						errors := errors + 1;
					end if;
				elsif (cmd(i) = to_integer(unsigned(CMD_READ_PRECHARGE))) then
					address_bit_vec := std_logic_vector(to_unsigned(address_rtl(i), ADDR_MEM_L_TB));
					if ((clk_enable(i) = true) and (chip_sel_n(i) = false) and (ras_n(i) = true) and (cas_n(i) = false) and (wr_en_n(i) = true) and (bank_rtl(i) = bank_exp(i)) and (address_bit_vec(10) = '1')) then
						write(file_line, string'("PHY Command Decoder: Read Command with Auto Precharge correctly decoded"));
						writeline(file_pointer, file_line);
					else
						write(file_line, string'("PHY Command Decoder: Read Command with Auto Precharge: clk_enable exp true rtl " & bool_to_str(clk_enable(i)) & " cs_n exp false rtl " & bool_to_str(chip_sel_n(i)) & " ras_n exp true rtl " & bool_to_str(ras_n(i)) & " cas_n exp false rtl " & bool_to_str(cas_n(i))  & " wr_en_n exp true rtl " & bool_to_str(wr_en_n(i)) & " bank exp " & integer'image(bank_exp(i)) & " rtl " & integer'image(bank_rtl(i)) & " Bit 10 address: exp true rtl " & std_logic_to_str(address_bit_vec(10))));
						writeline(file_pointer, file_line);

						errors := errors + 1;
					end if;
				else
					write(file_line, string'("PHY Command Decoder: Unknown command ID #" & integer'image(cmd(i))));
					writeline(file_pointer, file_line);
				end if;

				if (errors = 0) then
					pass := 1;
				else
					pass := 0;
				end if;

			end loop;

		end procedure verify;

		variable seed1, seed2	: positive;

		variable num_commands_exp	: integer;
		variable num_commands_rtl	: integer;

		variable col_exp	: int_arr(0 to (MAX_COMMANDS_PER_TEST - 1));
		variable row_exp	: int_arr(0 to (MAX_COMMANDS_PER_TEST - 1));
		variable bank_exp	: int_arr(0 to (MAX_COMMANDS_PER_TEST - 1));
		variable cmd		: int_arr(0 to (MAX_COMMANDS_PER_TEST - 1));
		variable mrs_cmd	: int_arr(0 to (MAX_COMMANDS_PER_TEST - 1));

		variable clk_enable	: bool_arr(0 to (MAX_COMMANDS_PER_TEST - 1));
		variable chip_sel_n	: bool_arr(0 to (MAX_COMMANDS_PER_TEST - 1));
		variable ras_n		: bool_arr(0 to (MAX_COMMANDS_PER_TEST - 1));
		variable cas_n		: bool_arr(0 to (MAX_COMMANDS_PER_TEST - 1));
		variable wr_en_n	: bool_arr(0 to (MAX_COMMANDS_PER_TEST - 1));

		variable address_rtl	: int_arr(0 to (MAX_COMMANDS_PER_TEST - 1));
		variable bank_rtl	: int_arr(0 to (MAX_COMMANDS_PER_TEST - 1));

		variable pass		: integer;
		variable num_pass	: integer;

		file file_pointer	: text;
		variable file_line	: line;

	begin

		wait for 1 ns;

		num_pass := 0;

		reset;
		file_open(file_pointer, log_file, append_mode);

		write(file_line, string'( "PHY Command Decoder Test"));
		writeline(file_pointer, file_line);

		for i in 0 to NUM_TEST-1 loop

			test_param(num_commands_exp, col_exp, row_exp, bank_exp, cmd, mrs_cmd, seed1, seed2);

			run_cmd_dec(num_commands_exp, col_exp, row_exp, bank_exp, cmd, mrs_cmd, num_commands_rtl, clk_enable, chip_sel_n, ras_n, cas_n, wr_en_n, bank_rtl, address_rtl);

			verify(num_commands_exp, num_commands_rtl, clk_enable, chip_sel_n, ras_n, cas_n, wr_en_n, bank_exp, bank_rtl, address_rtl, cmd, file_pointer, pass);

			num_pass := num_pass + pass;

			wait until ((clk_tb'event) and (clk_tb = '1'));

		end loop;

		file_close(file_pointer);

		file_open(file_pointer, summary_file, append_mode);
		write(file_line, string'( "PHY Command Decoder => PASSES: " & integer'image(num_pass) & " out of " & integer'image(TOT_NUM_TEST)));
		writeline(file_pointer, file_line);

		if (num_pass = TOT_NUM_TEST) then
			write(file_line, string'( "PHY Command Decoder: TEST PASSED"));
		else
			write(file_line, string'( "PHY Command Decoder: TEST FAILED: " & integer'image(TOT_NUM_TEST-num_pass) & " failures"));
		end if;
		writeline(file_pointer, file_line);

		file_close(file_pointer);
		stop <= true;

	end process test;

end bench;
