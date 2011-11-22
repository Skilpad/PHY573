
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
LEDR : out std_logic_vector(17 downto 0);

GPIO_0 : out std_logic_vector(31 downto 0);

I2C_SCLK    : out std_logic;   -- horloge du bus I²C
I2C_SDAT    : inout std_logic; -- donnée  du bus I²C
AUD_DACDAT  : out std_logic;   -- DAC donnée audio
AUD_ADCLRCK : out std_logic;   -- ADC horloge Gauche/Droite
AUD_ADCDAT  : in std_logic;    -- ADC donnée audio
AUD_DACLRCK : out std_logic;   -- DAC horloge Gauche/Droite
AUD_XCK     : out std_logic;   -- horloge du codec
AUD_BCLK    : out std_logic;   -- ADC/DAC horloge bit



LCD_ON : out std_logic;	
LCD_EN : out std_logic;
LCD_RS : out std_logic;
LCD_RW : out std_logic; 
LCD_DATA : inout std_logic_vector(7 downto 0);
--busy   : out std_logic;
			

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
signal wIndex : integer range 0 to 200000 := 10000;  -- Write position in memory


signal a_ligne    : std_logic := '0'; -- 0 = ligne 1, 1 = ligne 2
signal a_place 	: std_logic_vector(3 downto 0) := "0000";     -- place ds la ligne, en commencant a gauche
signal a_data     : std_logic_vector(7 downto 0) := "00110000"; -- code caractere 1
signal a_enaadd   : std_logic := '0';
signal a_enadata  : std_logic := '0';
signal a_wr       : std_logic := '0'; 
signal a_busy     : std_logic;-- := '1' -- BUSY est OUT, les autres sont IN
			
			


signal sramAddr : std_logic_vector (17 downto 0);
signal sramOut  : std_logic_vector (15 downto 0);
signal sramIn   : std_logic_vector (15 downto 0);
signal sramOE   : std_logic := '1';
signal sramWE   : std_logic := '1';


signal prev0 : signed (15 downto 0);
signal prev1 : signed (15 downto 0);
signal prev2 : signed (15 downto 0);
signal prev3 : signed (15 downto 0);
signal prev4 : signed (15 downto 0);
signal prev5 : signed (15 downto 0);
signal prev6 : signed (15 downto 0);
signal prev7 : signed (15 downto 0);
signal prev8 : signed (15 downto 0);
signal prev9 : signed (15 downto 0);

signal tempInt : signed (15 downto 0);
signal lastIn  : signed (15 downto 0);

type StateType is (waiting,wr,r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,finished);
signal state : StateType := waiting;


type writeMsgType is (chP0, chP1, ch0, ch1, ch2, ch3, ch4);
signal writeState : writeMsgType := ch1;

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

	
	circuit_3 : simple_lcd
	port map(
           ligne    => a_ligne,
           place 	  => a_place,
           data     => a_data,
           enaadd   => a_enaadd,
           enadata  => a_enadata,
			  wr       => a_wr,
           clk      => CLOCK_50,

		     LCD_ON => LCD_ON,	
           LCD_EN => LCD_EN,
           LCD_RS => LCD_RS,
           LCD_RW => LCD_RW,
           LCD_DATA => LCD_DATA,
			  
			  busy   => a_busy
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
	

	
	GPIO_0(14) <= '0';
	GPIO_0(15) <= '0';
	
	GPIO_0(16) <= sramOut(0);
	GPIO_0(17) <= sramOut(1);
	GPIO_0(18) <= sramOut(2);
	
	GPIO_0(31 downto 28) <= "0000";
	
	
	--with SW(14) select
	--	a_place <= "0100" when '0',
	--				  "1000" when others;
		
	--a_place <= "0000";
	
	
	--a_data <= "00110000";
	
	--a_enaadd <= SW(17);
	--a_enadata <= SW(16);
	--a_wr <= SW(15);
	
	
	process (CLOCK_50)
	begin
		if rising_edge(CLOCK_50) then
	
			if a_busy = '0' then
			
			case writeState is
				
				when chP0 =>
				
				a_wr <= '1';
				a_enaadd <= '0';
				a_enadata <= '0';
				-- Efface tout
				
				writeState <= chP1;
				
				when chP1 =>
	
					
					a_wr <= '0';
				 	a_enaadd <= '1';
					a_enadata <= '1';
					writeState <= ch0;
					
				when ch0 =>
	
					a_wr <= '1';
					a_data <= "00110000";
					a_place <= "0000";
					writeState <= ch1;
					
				when ch1 =>
	
					--a_wr <= '1';
					a_data <= "00110001";
					a_place <= "0001";
					writeState <= ch2;
					
				when ch2 =>
	
					--a_wr <= '1';
					a_data <= "00110010";
					a_place <= "0010";
					writeState <= ch3;
					
				when ch3 =>
	
					--a_wr <= '1';
					a_data <= "00110011";
					a_place <= "0011";
					writeState <= ch3;
					
				when ch4 =>
	
					--a_place <= "0100";
					writeState <= chP0;
					--a_wr <= '0';
				
				
			end case;
			end if;
	
		end if; -- End clock
	end process;	
	
	
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
						lastIn   <= signed(fromadc);
						state    <= wr;

				when wr =>
						sramWE   <= '1'; -- Avec ce nouveau cycle, l'ecriture s'est termine
						sramOE   <= '0'; -- Mettra SRAM_DQ en haute impedance
						sramAddr <= std_logic_vector(to_unsigned(rIndex,18));
						state    <= r0;
				
				when r0 =>
						prev0    <= signed(sramIn); -- Avec ce nouveau cycle, la lecture est stable
						sramOE   <= '0'; -- Mettra SRAM_DQ en haute impedance
						sramAddr <= std_logic_vector(to_unsigned(rIndex - 1,18));
						state    <= r1;
						
				when r1 =>
						prev1    <= signed(sramIn); -- Avec ce nouveau cycle, la lecture est stable
						sramOE   <= '0'; -- Mettra SRAM_DQ en haute impedance
						sramAddr <= std_logic_vector(to_unsigned(rIndex - 2,18));
						state    <= r2;
			
				when r2 =>
						prev1    <= signed(sramIn); -- Avec ce nouveau cycle, la lecture est stable
						sramOE   <= '0'; -- Mettra SRAM_DQ en haute impedance
						sramAddr <= std_logic_vector(to_unsigned(rIndex - 3,18));
						state    <= r3;
				
				when r3 =>
						prev1    <= signed(sramIn); -- Avec ce nouveau cycle, la lecture est stable
						sramOE   <= '0'; -- Mettra SRAM_DQ en haute impedance
						sramAddr <= std_logic_vector(to_unsigned(rIndex - 4,18));
						state    <= r4;	
				
				when r4 =>
						prev1    <= signed(sramIn); -- Avec ce nouveau cycle, la lecture est stable
						sramOE   <= '0'; -- Mettra SRAM_DQ en haute impedance
						sramAddr <= std_logic_vector(to_unsigned(rIndex - 5,18));
						state    <= r5;	
				
				when r5 =>
						prev1    <= signed(sramIn); -- Avec ce nouveau cycle, la lecture est stable
						sramOE   <= '0'; -- Mettra SRAM_DQ en haute impedance
						sramAddr <= std_logic_vector(to_unsigned(rIndex - 6,18));
						state    <= r6;	
				
				when r6 =>
						prev1    <= signed(sramIn); -- Avec ce nouveau cycle, la lecture est stable
						sramOE   <= '0'; -- Mettra SRAM_DQ en haute impedance
						sramAddr <= std_logic_vector(to_unsigned(rIndex - 7,18));
						state    <= r7;	
				
				when r7 =>
						prev1    <= signed(sramIn); -- Avec ce nouveau cycle, la lecture est stable
						sramOE   <= '0'; -- Mettra SRAM_DQ en haute impedance
						sramAddr <= std_logic_vector(to_unsigned(rIndex - 8,18));
						state    <= r8;	
				
				when r8 =>
						prev1    <= signed(sramIn); -- Avec ce nouveau cycle, la lecture est stable
						sramOE   <= '0'; -- Mettra SRAM_DQ en haute impedance
						sramAddr <= std_logic_vector(to_unsigned(rIndex - 9,18));
						state    <= r9;			
				
				when r9 =>
						prev9  <= signed(sramIn); -- Avec ce nouveau cycle, la lecture est stable
						rIndex <= rIndex + 1;
						wIndex <= wIndex + 1;
						state  <= finished;
						
						
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


	tempInt <= prev0 / 8 + prev1/ 8 + prev2/ 8 + prev3/ 8  + prev4/ 8  + prev5/ 8  + prev6 / 8 + prev7/ 8 ;
	

	--tempInt <= ((prev0 / 2) + (lastIn / 2));
		
		
			
	with SW(0) select
		todac <= std_logic_vector(tempInt) when '1',
					std_logic_vector(prev0) when others;
	
	with SW(0) select			
		LEDR(0) <= '1' when '1',
					  '0' when others;
					  
	
	LedRouges: for gen in 1 to 17 generate
	
		with SW(gen) select
			LEDR(gen) <= '1' when '1',
							 '0' when others;
	
	end generate;

		

end boiteEffet_arch;