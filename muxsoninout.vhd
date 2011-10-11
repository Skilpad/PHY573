-- composant muxsoninout
-- date de cr�ation : 1� octobre 2007
-- version : 1.0 for Quartus 7.1
-- by J.Y. Parey
-- date de r�vsion : 15 Octobre 2007
-- version : 1.1 Am�lioration du case dans muxseqdatinout
-- date de r�vsion : 22 Octobre 2007
-- version : 1.2 Remplacement duTRI d'Alt�ra par un inout g�n�rique.
-- date de r�vsion : 26 Novembre 2007
-- version : 1.3 Modification du nom de la ROM pour �viter les incompatibilit�s
-- avec la gestion du clavier

-- version : 2.0 R�organisation compl�te du vhdl pour plus de lisibilit�.
-- Les composants sont d�plac�s dans un package (package_son_inout)
-- Suppression du composant Rom Altera (lpm_rom) pour le remplacer par une ROM Generique VHDL.

-- Des informations sur l'utilisation de ce code sont disponibles ici :
-- http://www.enseignement.polytechnique.fr/profs/trex-fpga/Yannick.Geerebaert/fpga/periph_son.html

-- Utilisation du codec WM8731 en entr�e et en sortie
-- Les donn�es �chang�es avec le codec sont sur 16 bits sign�s en compl�ment � 2
-- clk: horloge � 50 Mhz
-- Echantillonnage � 48 Khz (Clock_50 divis� par 1024).
-- Les donn�es (todac et fromdac) sont multiplex�es (voie droite et gauche sur un m�me bus)
-- 2 signaux de contr�le "rdRwrL" (read Right write Left) et rdLwrR (read Left write Right)
-- permettent la synchronisation :
-- � 1, la sortie du convertisseur, fromadc, est stable et peut �tre relue ,
--      la donn�e envoy�e vers le convertisseur, todac, peut �tre modifi�e (voie droite ou gauche).
-- lorsque ces deux signaux sont � 0, la sortie du convertisseur, fromadc, est instable
-- et la donn�e pr�sente sur todac au moment du front descendant est envoy�e vers le codec.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use work.package_son_inout.all;

entity muxsoninout is
port(
     -- signaux cot� utilisateurs
     clk     : in std_logic;                       -- CLOCK_50 (50MHz)
     todac   : in std_logic_vector (15 downto 0);  -- donnee HP (signed)
     fromadc : out std_logic_vector (15 downto 0); -- donnee ligne (signed)
     rdRwrL  : out std_logic; -- Lecture droite, ecriture gauche
     rdLwrR  : out std_logic; -- Lecture gauche, ecriture droite
     -- signaux d'interface avec le CODEC WM8731
     I2C_SCLK    : out std_logic;   -- horloge du bus I�C
     I2C_SDAT    : inout std_logic; -- donn�e  du bus I�C
     AUD_DACDAT  : out std_logic;   -- DAC donn�e audio
     AUD_ADCLRCK : out std_logic;   -- ADC horloge Gauche/Droite
     AUD_ADCDAT  : in std_logic;    -- ADC donn�e audio
     AUD_DACLRCK : out std_logic;   -- DAC horloge Gauche/Droite
     AUD_XCK     : out std_logic;   -- horloge du codec
     AUD_BCLK    : out std_logic    -- ADC/DAC horloge bit
     );
end muxsoninout;

architecture muxsoninout_arch of muxsoninout is
signal sckun : integer range 0 to 3;
signal sckdeu : integer range 0 to 255;
signal mclktmp : std_logic;
signal audiclktmp : std_logic;

begin
cir1 : component seqdata port map
    (clk => clk,
     clkdivun => sckun,
     clkdivdeu => sckdeu,
     mclk => mclktmp );
cir2 : component regofcodec port map
     (clk => clk,
      I2C_SCLK => I2C_SCLK ,
      I2C_SDAT => I2C_SDAT );
cir3 : component muxseqdatinout port map
     (clk => clk,
      divun => sckun,
      valin => todac ,
      valout  => fromadc ,
      AUD_DACDAT => AUD_DACDAT ,
      AUD_DACLRCK => audiclktmp ,
      AUD_ADCDAT => AUD_ADCDAT,
      divdeu => sckdeu,
      rdRwrL=> rdRwrL   ,
      rdLwrR => rdLwrR );


AUD_DACLRCK <= audiclktmp;
AUD_ADCLRCK <= audiclktmp;
AUD_XCK <= mclktmp;
AUD_BCLK <= mclktmp;

end muxsoninout_arch;