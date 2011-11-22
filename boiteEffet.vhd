
library IEEE;
use IEEE.std_logic_1164.all;
use work.notre_librairie.all;
use IEEE.numeric_std.all;

-- sélectionner les bibliothèques dont vous aurez besoin
-- use IEEE.std_logic_arith.all;
-- use IEEE.std_logic_unsigned.all;
-- use IEEE.std_logic_signed.all;



entity boiteEffet is
    port (

-- liste des entrées sorties
SW : in std_logic_vector(17 downto 0);

-- KEY : in std_logic_vector(3 downto 0);
CLOCK_50 : in std_logic;
--HEX0 : out std_logic_vector(6 downto 0);
--LEDR : out std_logic_vector(17 downto 0);

GPIO_0 : out std_logic_vector(31 downto 0);

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
SRAM_WE_N   : out std_logic; -- Write Enable, actif a l'etat bas
SRAM_OE_N   : out std_logic; -- Output Enable, actif a l'etat bas
SRAM_UB_N   : out std_logic; -- Non utilise
SRAM_LB_N   : out std_logic; -- Non utilise
SRAM_CE_N   : out std_logic -- A zero pour activer le composant
-- REMARQUE: Le dernier n'a pas de point virgules


-- name : mode type ;

    );
end boiteEffet;





architecture boiteEffet_arch of boiteEffet is


signal rdRwrL  : std_logic;
signal rdLwrR  : std_logic;

signal todac   : std_logic_vector (15 downto 0);
signal fromadc : std_logic_vector (15 downto 0);


signal lastL : std_logic_vector (15 downto 0);
signal lastR : std_logic_vector (15 downto 0);



signal rIndex : integer range 0 to 200000 := 0;      -- Read position in memory
signal wIndex : integer range 0 to 200000 := 100001; -- Write position in memory

signal coef0  : integer range 0 to 1000;



signal sramAddr : std_logic_vector (17 downto 0);
signal sramOut  : std_logic_vector (15 downto 0);
signal sramIn   : std_logic_vector (15 downto 0);
signal sramOE   : std_logic := '1';
signal sramWE   : std_logic := '1';


signal prev0 : std_logic_vector (15 downto 0);
signal prev1 : std_logic_vector (15 downto 0);
signal prev2 : std_logic_vector (15 downto 0);

signal prev0i : unsigned (15 downto 0);-- range 0 to 65535;
signal prev1i : unsigned (15 downto 0);-- range 0 to 65535;
signal prev2i : unsigned (15 downto 0);-- range 0 to 65535;

signal tempInt : unsigned (15 downto 0);-- range 0 to 65535;


type StateType is (waiting,writing,reading1,reading2,reading3,calculate,finished);
signal state : StateType := waiting;




begin


	circuit_2 : muxsoninout
	port map(
		clk     => CLOCK_50,
		todac   => todac,
		fromadc => fromadc,
		rdRwrL  => rdRwrL,
		rdLwrR  => rdLwrR,
		
		I2C_SCLK    => I2C_SCLK,
		I2C_SDAT    => I2C_SDAT,
		AUD_DACDAT  => AUD_DACDAT,
		AUD_ADCLRCK => AUD_ADCLRCK,
		AUD_ADCDAT  => AUD_ADCDAT,
		AUD_DACLRCK => AUD_DACLRCK,
		AUD_XCK     => AUD_XCK,
		AUD_BCLK    => AUD_BCLK  
	);

	
	
	----------------------------
	-- CONNECTIQUE DE LA SRAM --
	----------------------------
	
	-- Connecteurs fixes
	SRAM_CE_N <= '0'; -- Activer le composant
	SRAM_UB_N <= '0'; -- Active le travail sur les bits de haut poids
	SRAM_LB_N <= '0'; -- Active le travail sur les bits de faible poids
	
	-- Sorties de pilotages
	SRAM_OE_N <= sramOE;
	SRAM_WE_N <= sramWE;
	SRAM_ADDR <= sramAddr;
	
   -- Buffer double sens
	with sramOE select
	sramIn <= SRAM_DQ when '0',
				 "0000000000000000" when others;
	
	with sramOE select
	SRAM_DQ <= "ZZZZZZZZZZZZZZZZ" when '0',
					sramOut when others;
	
	
	
	----------------------------
	--  CONNECTIQUE DE DEBUG  --
	----------------------------

	GPIO_0(0) <= CLOCK_50;
	GPIO_0(1) <= sramWE;
	GPIO_0(2) <= sramOE;
	
	--GPIO_0(3) <= rdRwrL;
	GPIO_0(3) <= '0';
	
	GPIO_0(4) <= sramIn(0);
	GPIO_0(5) <= sramIn(1);
	GPIO_0(6) <= sramIn(2);
	
	GPIO_0(7) <= '0';
	
	GPIO_0(8) <= sramAddr(0);
	GPIO_0(9) <= sramAddr(1);
	GPIO_0(10) <= sramAddr(2);
	
	with state select
	GPIO_0(13 downto 11) <= "000" when waiting,
									"001" when writing,
									"010" when reading1,
									"011" when reading2,
									"100" when reading3,
									"101" when calculate,
									"111" when finished;
	
	GPIO_0(14) <= '0';
	GPIO_0(15) <= '0';
	
	GPIO_0(16) <= sramOut(0);
	GPIO_0(17) <= sramOut(1);
	GPIO_0(18) <= sramOut(2);
	
	GPIO_0(19) <= prev0(0);
	GPIO_0(20) <= prev0(1);
	GPIO_0(21) <= prev0(2);
	
	GPIO_0(22) <= prev1(0);
	GPIO_0(23) <= prev1(1);
	GPIO_0(24) <= prev1(2);
	
	GPIO_0(25) <= prev2(0);
	GPIO_0(26) <= prev2(1);
	GPIO_0(27) <= prev2(2);
	
	GPIO_0(31 downto 28) <= "0000";
	


	
	
	process (CLOCK_50)
	begin

		if rising_edge(CLOCK_50) then
			
			
			-- Code pour lien direct, ecrit la droite sur la gauche
		--	if rdLwrR = '1' then
		--		lastL <= fromadc;
		--		todac <= lastR;
		--	end if;

		--	if rdRwrL = '1' then
		--		lastR <= fromadc;
		--		todac <= lastL;
		--	end if;
			
			
			if rdLwrR = '1' then
				
				case state is
				
				when waiting =>
				
				      -- Si WE n'est pas a 1, il faut prevoir une etape en amont pour ly mettre

						sramOE <= '1'; -- Preparation a lecriture
						sramWE <= '0'; -- Autorisation ecriture, asynchrone
						
						sramAddr <= std_logic_vector(to_unsigned(wIndex,18));
						sramOut  <= fromadc;
						
						state <= writing;

				when writing =>
				
						sramWE <= '1'; -- Avec ce nouveau cycle, l'ecriture s'est termine
						
						-- On debute la lecture
						sramAddr <= std_logic_vector(to_unsigned(rIndex,18));
						sramOE <= '0'; -- Mettra SRAM_DQ en haute impedance

						state <= reading1;
				
				when reading1 =>
				
						prev0 <= sramIn; -- Avec ce nouveau cycle, la lecture est stable
						
						-- On debute la lecture suivante
						sramAddr <= std_logic_vector(to_unsigned(rIndex - 1,18));
						sramOE <= '0'; -- Mettra SRAM_DQ en haute impedance

						state <= reading2;
						
				when reading2 =>
					
						prev1 <= sramIn; -- Avec ce nouveau cycle, la lecture est stable
					
						-- On debute la lecture suivante
						sramAddr <= std_logic_vector(to_unsigned(rIndex - 2,18));
						sramOE <= '0'; -- Mettra SRAM_DQ en haute impedance
					
						state <= reading3;				
				
				when reading3 =>
					
						prev2 <= sramIn; -- Avec ce nouveau cycle, la lecture est stable
					

						rIndex <= rIndex + 1;
						wIndex <= wIndex + 1;
						
						state <= calculate;
						
				when calculate =>
					
					-- Etat vide pour l'instant car les calculs se font hors mode process
					state <= finished;
						
				when finished =>
					-- Attention, ce cas se produit un grand nombre de fois sur chaque echantillon
					sramOE <= '1';


				end case;
			

			 else
					state <= waiting;
			 end if;
			


		end if; -- End clock
	end process;	


	
	--- CALCULS HORS DU PROCESS
	
	-- Conversion integer->logic: std_logic_vector(to_unsigned(MY_INT,NB_BITS))
	-- Conversion logic->integer: to_integer(unsigned(MY_VECT))

	
	prev0i <= unsigned(prev0);
	prev1i <= unsigned(prev1);
	prev2i <= unsigned(prev2);
	
		
	tempInt <= (prev0i + prev1i + prev2i);
			
			
	--with SW[0] select
	--sramIn <= SRAM_DQ when '0',
	--			 "0000000000000000" when others;
				 
	todac <= std_logic_vector(tempInt);
		
		
	--todac <= prev0; -- Pour l'instant !
					
					
	
		

end boiteEffet_arch;