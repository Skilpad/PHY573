
library IEEE;
use IEEE.std_logic_1164.all;

entity decodeur is
port(
    nombre : in integer range 0 to 15;
    sortie : out std_logic_vector(6 downto 0) -- Afficheur 7 segments
);
end decodeur;


architecture decodeur_arch of decodeur is
begin

with nombre select
	-- RAPPEL: 1 = INACTIF, 0 = ACTIF
	sortie <="1000000" when 0,
				"1111001" when 1,
				"0100100" when 2,
				"0110000" when 3,
				"0011001" when 4,
				"0010010" when 5,
				"0000010" when 6,
				"1111000" when 7,
				"0000000" when 8,
				"0010000" when 9,
 			   "0001000" when 10,
			   "1100000" when 11,
			   "0110001" when 12,
 			   "1000010" when 13, 
			   "0110000" when 14,
 			   "0111000" when 15,
				"1111111" when others;
end decodeur_arch;