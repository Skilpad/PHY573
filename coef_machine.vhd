library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.nos_types.all;


--type signed_array16 is array(1 to 10) of signed (15 downto 0);
--type unsigned_array18 is array(1 to 10) of unsigned (17 downto 0);


entity coef_machine is
port(
	mode : in integer range 0 to 1;
	
   delay : out  unsigned_array18;
   coeff : out  signed_array16
);
end coef_machine;


architecture coef_machine_arch of coef_machine is
begin

-- Delay sans ecarts
LabelDebile : for gen in 1 to 10 generate 
  delay(gen) <= to_unsigned(gen, 18);
end generate;

-- Coefs uniformes ATTENTION LA SOMME DE MES COEFS DOIT FAIRE 1024


coeff(1) <= to_signed(1024, 16);
LabelDebile2 : for gen in 2 to 10 generate 
  coeff(gen) <= to_signed(0, 16);
end generate;


--LabelDebile2 : for gen in 1 to 10 generate 
--  coeff(gen) <= to_signed(100, 16);
--end generate;

				
				

end coef_machine_arch;