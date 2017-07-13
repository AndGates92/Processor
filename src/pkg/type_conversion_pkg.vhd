library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package type_conversion_pkg is 
	function std_logic_to_bool(val : std_logic) return boolean;
	function bool_to_std_logic(val : boolean) return std_logic;
	function bool_to_str(val : boolean) return string;
	function std_logic_to_str(val : std_logic) return string;

end package type_conversion_pkg;

package body type_conversion_pkg is

	function std_logic_to_bool(val : std_logic) return boolean is
		variable val_conv	: boolean;
	begin
		if (val = '1') then
			val_conv := True;
		else
			val_conv := False;
		end if;

		return val_conv;
	end;

	function bool_to_std_logic(val : boolean) return std_logic is
		variable val_conv	: std_logic;
	begin
		if (val = true) then
			val_conv := '1';
		else
			val_conv := '0';
		end if;

		return val_conv;
	end;

	function bool_to_str(val : boolean) return string is
		variable val_conv	: string(1 to 5);
	begin
		if (val = true) then
			val_conv := "True ";
		else
			val_conv := "False";
		end if;

		return val_conv;
	end;

	function std_logic_to_str(val : std_logic) return string is
		variable str_val	: string(1 to 5);
		variable bool_val	: boolean;
	begin
		bool_val := std_logic_to_bool(val);
		str_val := bool_to_str(bool_val);

		return str_val;
	end;

end package body type_conversion_pkg;
