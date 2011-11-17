

library IEEE;
use IEEE.std_logic_1164.all;

use work.notre_librairie.all;

-- use work.package_son_inout.all;

-- sélectionner les bibliothèques dont vous aurez besoin
-- use IEEE.std_logic_arith.all;
-- use IEEE.std_logic_unsigned.all;
-- use IEEE.std_logic_signed.all;



entity boiteEffet is
    port (

-- liste des entrées sorties

KEY : in std_logic_vector(3 downto 0);
CLOCK_50 : in std_logic;
HEX0 : out std_logic_vector(6 downto 0);
LEDR : out std_logic_vector(17 downto 0)

-- name : mode type ;

    );
end boiteEffet;




 



architecture boiteEffet_arch of boiteEffet is

-- signal declaration
-- signal  name : type  := valeur initiale;
signal maxDivis : integer range 1 to 10000000 := 1;
signal divis : integer range 1 to 10000000 := 1;
signal tempo : integer range 1 to 9 := 1;
signal danse : integer range 1 to 17 := 1;
signal appui : std_logic := '0';
signal a : std_logic := '1';
signal b : std_logic := '1';
signal hasRdLwrR : std_logic := '0';
signal hasRdRwrL : std_logic := '0';

signal todac  : std_logic_vector (15 downto 0);
signal fromadc: std_logic_vector (15 downto 0);
signal rdRwrL : std_logic := '0';
signal rdLwrR : std_logic := '0';

 signal     I2C_SCLK    : std_logic;   -- horloge du bus I²C
  signal    I2C_SDAT    : std_logic; -- donnée  du bus I²C
  signal    AUD_DACDAT  : std_logic;   -- DAC donnée audio
 signal     AUD_ADCLRCK : std_logic;   -- ADC horloge Gauche/Droite
 signal     AUD_ADCDAT  : std_logic;    -- ADC donnée audio
 signal     AUD_DACLRCK : std_logic;   -- DAC horloge Gauche/Droite
 signal     AUD_XCK     : std_logic;   -- horloge du codec
  signal    AUD_BCLK    : std_logic;    -- ADC/DAC horloge bit


  



begin


appui <= b and (a xor b);


LedsRouges : for toto in 0 to 17 generate

LEDR(toto) <= '1' when (danse = toto) else '0';

end generate;
	

with tempo select
	-- RAPPEL: 1 = INACTIF, 0 = ACTIF
	maxDivis <=10000000 when 1,
				5000000 when 2,
				1000000 when 3,
				500000 when 4,
				100000 when 5,
				50000 when 6,
				10000 when 7,
				5000 when 8,
				1000 when 9,
				100000 when others;
				

 
process (CLOCK_50)
	begin
	
	if CLOCK_50'event and CLOCK_50 = '1' then

		b <= a;
		a <= KEY(3);
		
	end if;
end process;
 
 
process (CLOCK_50)
begin

 	if CLOCK_50'event and CLOCK_50 = '1' then

	
		if rdRwrL = '1' then 
		-- Lecture droite, ecriture gauche
			if hasRdRwrL = '0' then
				todac <= fromadc;
	  
				hasRdRwrL <= '1';
			end if;
		else
		   hasRdRwrL <= '0';
		end if;
	  
	
	-- todac   : in std_logic_vector (15 downto 0);  -- donnee HP (signed)
   -- fromadc : out std_logic_vector (15 downto 0); -- donnee ligne (signed)    
	  

		if hasRdLwrR = '1' then
			-- Lecture gauche, ecriture droite
			if hasRdLwrR = '0' then
				todac <= fromadc;
				hasRdLwrR <= '1';
			end if;
		else
			hasRdLwrR <= '0';
		end if;
	end if;
		
	
	                


end process;	


circuit_2 : muxsoninout
port map(
clk     => CLOCK_50,
todac   => todac,
fromadc => fromadc,
rdRwrL  => rdRwrL,
rdLwrR  => rdLwrR,
-- signaux 
I2C_SCLK    => I2C_SCLK,
I2C_SDAT    => I2C_SDAT,
AUD_DACDAT  => AUD_DACDAT,
AUD_ADCLRCK => AUD_ADCLRCK,
AUD_ADCDAT  => AUD_ADCDAT,
AUD_DACLRCK => AUD_DACLRCK,
AUD_XCK     => AUD_XCK,
AUD_BCLK    => AUD_BCLK  
);

circuit_1 : decodeur
port map(
nombre => tempo, -- tempo
sortie => HEX0
);



end boiteEffet_arch;