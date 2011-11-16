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
  -- signaux coté utilisateurs
  clk     : in std_logic;                       -- CLOCK_50 (50MHz)
  todac   : in std_logic_vector (15 downto 0);  -- donnee HP (signed)
  fromadc : out std_logic_vector (15 downto 0); -- donnee ligne (signed)                    
  rdRwrL  : out std_logic; -- Lecture droite, ecriture gauche
  rdLwrR  : out std_logic; -- Lecture gauche, ecriture droite
  -- signaux d'interface avec le CODEC WM8731
  I2C_SCLK    : out std_logic;   -- horloge du bus I²C
  I2C_SDAT    : inout std_logic; -- donnée  du bus I²C
  AUD_DACDAT  : out std_logic;   -- DAC donnée audio
  AUD_ADCLRCK : out std_logic;   -- ADC horloge Gauche/Droite
  AUD_ADCDAT  : in std_logic;    -- ADC donnée audio
  AUD_DACLRCK : out std_logic;   -- DAC horloge Gauche/Droite
  AUD_XCK     : out std_logic;   -- horloge du codec
  AUD_BCLK    : out std_logic    -- ADC/DAC horloge bit
);
end component muxsoninout;


component ram_reader
port(
  -- RAM
	SRAM_ADDR : inout std_logic_vector (17 downto 0);
	SRAM_WE_N : inout std_logic;
	SRAM_OE_N : inout std_logic;
	SRAM_DQ   : in  std_logic_vector (15 downto 0);
  -- Time
	CLOCK_50  : in  std_logic;
  start     : in  std_logic;
  freeRAM   : out std_logic;
  -- Values
  cnt       : in  std_logic_vector (17 downto 0);
  delay     : in  std_logic_vector (17 downto 0);
  alpha     : in  std_logic_vector (15 downto 0);
  beta      : in  std_logic_vector (15 downto 0);
  -- output
  output    : out std_logic_vector (15 downto 0)
);
end component ram_reader;


end notre_librairie;