

library IEEE;
use IEEE.std_logic_1164.all;

use work.notre_librairie.all;

-- use work.package_son_inout.all;

-- sélectionner les bibliothèques dont vous aurez besoin
-- use IEEE.std_logic_arith.all;
-- use IEEE.std_logic_unsigned.all;


entity boiteEffet is

port(

-- liste des entrées sorties

	KEY : in std_logic_vector(3 downto 0);
  SW  : in std_logic_vector(17 downto 0);
	CLOCK_50 : in std_logic;
	HEX0 : out std_logic_vector(6 downto 0);
	HEX1 : out std_logic_vector(6 downto 0);
	LEDR : out std_logic_vector(17 downto 0);


	-- I2C_SCLK    : out std_logic;   -- horloge du bus I²C
	-- I2C_SDAT    : inout std_logic; -- donnée  du bus I²C
	-- AUD_DACDAT  : out std_logic;   -- DAC donnée audio
	-- AUD_ADCLRCK : out std_logic;   -- ADC horloge Gauche/Droite
	-- AUD_ADCDAT  : in std_logic;    -- ADC donnée audio
	-- AUD_DACLRCK : out std_logic;   -- DAC horloge Gauche/Droite
	-- AUD_XCK     : out std_logic;   -- horloge du codec
	-- AUD_BCLK    : out std_logic;   -- ADC/DAC horloge bit

	SRAM_ADDR   : out std_logic_vector (17 downto 0);
	SRAM_DQ     : inout std_logic_vector (15 downto 0); 
	SRAM_WE_N   : out std_logic;
	SRAM_OE_N   : out std_logic;
	SRAM_UB_N   : out std_logic;
	SRAM_LB_N   : out std_logic;
	SRAM_CE_N   : out std_logic

);
end boiteEffet;




 



architecture boiteEffet_arch of boiteEffet is

-- signal declaration
-- signal  name : type  := valeur initiale;

-- signal todac  : std_logic_vector (15 downto 0);
-- signal fromadc: std_logic_vector (15 downto 0);
-- signal rdRwrL : std_logic := '0';
-- signal rdLwrR : std_logic := '0';

signal addr0  : integer range 0 to 262143 := 0;
signal addr1  : integer range 0 to 262143 := 1;
signal zero16 : integer range 0 to 65536  := 0;
signal un16   : integer range 0 to 65536  := 1;
signal deux16 : integer range 0 to 65536  := 2;

signal output0 : integer range 0 to 65536;
signal output1 : integer range 0 to 65536;

begin


	SRAM_UB_N <= '0';
	SRAM_LB_N <= '0';
	SRAM_CE_N <= '0';

  
  
--	circuit_2 : muxsoninout
--	port map(
--		clk     => CLOCK_50,
--		todac   => todac,
--		fromadc => fromadc,
--		rdRwrL  => rdRwrL,
--		rdLwrR  => rdLwrR,
--		-- signaux 
--		I2C_SCLK    => I2C_SCLK,
--		I2C_SDAT    => I2C_SDAT,
--		AUD_DACDAT  => AUD_DACDAT,
--		AUD_ADCLRCK => AUD_ADCLRCK,
--		AUD_ADCDAT  => AUD_ADCDAT,
--		AUD_DACLRCK => AUD_DACLRCK,
--		AUD_XCK     => AUD_XCK,
--		AUD_BCLK    => AUD_BCLK  
--	);

	circuit_0 : ram_reader
	port map(
    -- RAM
    SRAM_ADDR => SRAM_ADDR,
    SRAM_WE_N => SRAM_WE_N,
    SRAM_OE_N => SRAM_OE_N,
    SRAM_DQ   => SRAM_DQ,
    -- Time
    CLOCK_50  => CLOCK_50,
    start     => SW(0),
    freeRAM   => open,
    -- Values
    cnt       => addr0,
    delay     => addr0,
    alpha     => un16,
    beta      => zero16,
    -- output
    output    => output0
	);

	circuit_1 : ram_reader
	port map(
    -- RAM
    SRAM_ADDR => SRAM_ADDR,
    SRAM_WE_N => SRAM_WE_N,
    SRAM_OE_N => SRAM_OE_N,
    SRAM_DQ   => SRAM_DQ,
    -- Time
    CLOCK_50  => CLOCK_50,
    start     => SW(1),
    freeRAM   => open,
    -- Values
    cnt       => addr1,
    delay     => addr1,
    alpha     => deux16,
    beta      => un16,
    -- output
    output    => output1
	);
 


end boiteEffet_arch;