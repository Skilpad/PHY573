

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

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
	LEDR : out std_logic_vector(17 downto 0);


	I2C_SCLK    : out std_logic;   -- horloge du bus I²C
	I2C_SDAT    : inout std_logic; -- donnée  du bus I²C
	AUD_DACDAT  : out std_logic;   -- DAC donnée audio
	AUD_ADCLRCK : out std_logic;   -- ADC horloge Gauche/Droite
	AUD_ADCDAT  : in std_logic;    -- ADC donnée audio
	AUD_DACLRCK : out std_logic;   -- DAC horloge Gauche/Droite
	AUD_XCK     : out std_logic;   -- horloge du codec
	AUD_BCLK    : out std_logic;   -- ADC/DAC horloge bit

	SRAM_ADDR   : out std_logic_vector (17 downto 0);
	SRAM_DQ     : inout std_logic_vector (15 downto 0); 
	SRAM_WE_N   : out std_logic;
	SRAM_OE_N   : out std_logic;
	SRAM_UB_N   : out std_logic;
	SRAM_LB_N   : out std_logic;
	
-- name : mode type ;

    );
end boiteEffet;




 



architecture boiteEffet_arch of boiteEffet is

-- signal declaration
-- signal  name : type  := valeur initiale;

-- signal maxDivis : integer range 1 to 10000000 := 1;
-- signal divis : integer range 1 to 10000000 := 1;
-- signal tempo : integer range 1 to 9 := 1;
-- signal danse : integer range 1 to 17 := 1;
-- signal appui : std_logic := '0';
-- signal a : std_logic := '1';
-- signal b : std_logic := '1';
-- signal hasRdLwrR : std_logic := '0';
-- signal hasRdRwrL : std_logic := '0';
--
-- signal todac   : std_logic_vector (15 downto 0);
-- signal fromadc : std_logic_vector (15 downto 0);
-- signal rdRwrL  : std_logic := '0';
-- signal rdLwrR  : std_logic := '0';
-- 
-- signal lastL : std_logic_vector (15 downto 0);
-- signal lastR : std_logic_vector (15 downto 0);


type state_type is (s0,s1,s2,s3,s4,s5,s6,s7,s8,s9)

signal position : integer range 0 to 131072 := 0;      -- Readed position in memory
signal posDelay : integer range 0 to 131072 := 70000;  -- Written position in memory
signal rSignal  : std_logic_vector (15 downto 0);      -- Signal read from input
signal wSignal  : std_logic_vector (15 downto 0);      -- Signal to write to output
signal readable : std_logic := '0';                    -- If rSignal is correct

signal state : state_type;

-- signal zzz : std_logic_vector (15 downto 0) := "0000000000000000";



begin

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

	circuit_1 : muxsoninout
	port map(
		clk     => CLOCK_50,
		todac   => wSignal,
		fromadc => rSignal,
		rdRwrL  => open,
		rdLwrR  => readable,
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

	
	process (CLOCK_50)
	begin

--		if rising_edge(CLOCK_50) then
--			
--			if rdLwrR = '1' then
--				lastL <= fromadc;
--				todac <= lastR;
--			end if;
--
--			if rdRwrL = '1' then
--				lastR <= fromadc;
--				todac <= lastL;
--			end if;
--	
--		end if;

		if readable = '0' then
			state <= s0;
		else
			case state is
				when s0 =>
						position <= position + 1;
						posDelay <= posDelay + 1;
						state <= s1;
				when s1 =>
						SRAM_WE_N <= 0;
						state <= s2;
				when s2 =>
						SRAM_WE_N <= 1;
						state <= s3;
				when s3 =>
						SRAM_ADDR <= std_logic_vector(to_usigned(position,18));
						state <= s4;
				when s4 =>
						SRAM_OE_N <= 1;
						state <= s5;
				when s5 =>
						wSignal <= SRAM_DQ;
						state <= s6;
				when s6 =>
						SRAM_OE_N <= 0;
						state <= s7;
				when s7 =>
						SRAM_ADDR <= std_logic_vector(to_usigned(posDelay,18));
						state <= s8;
				when s8 =>
						wSignal <= SRAM_DQ;
						state <= s9;
			end case;
		end if;
		
	end process;	




end boiteEffet_arch;