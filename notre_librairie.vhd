library IEEE;
use IEEE.std_logic_1164.all;

package notre_librairie is

component decodeur
port(
  nombre : in integer range 0 to 9;
  sortie : out std_logic_vector(6 downto 0) -- Afficheur 7 segments
);
end component decodeur;



component muxsoninout
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
end component muxsoninout;




end notre_librairie;