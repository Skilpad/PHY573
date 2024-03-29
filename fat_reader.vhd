
-- output = Sum(coeff[i]*RAM[i+delay[i]])
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.nos_types.all;

entity fat_reader is


port (
    -- RAM
	 
	 	
    SRAM_ADDR : out std_logic_vector (17 downto 0);
    SRAM_WE_N : out std_logic;
    SRAM_OE_N : out std_logic;
    SRAM_DQ   : inout std_logic_vector (15 downto 0);
	 
    -- Time
    CLOCK_50  : in  std_logic;
    start     : in  std_logic;
    useRAM    : out std_logic;
	 
    -- Values
    i         : in  unsigned(17 downto 0);      -- 2^18 = 262144 cells in RAM
    delay     : in  unsigned_array18;
    coeff     : in  signed_array16;
	 
    -- output
	 input     : in std_logic_vector (15 downto 0);	
	 debug     : out std_logic_vector (15 downto 0);
    output    : out std_logic_vector (15 downto 0)
);
end fat_reader;





architecture fat_reader_arch of fat_reader is

  signal result     : signed (31 downto 0);
  signal result2     : signed (31 downto 0);
  signal smallerResult : signed(15 downto 0);
  signal big_output : std_logic_vector (31 downto 0);  
  signal sramdq : signed(15 downto 0);
  
  signal state : integer range 0 to 100 := 99;
  

	signal sramOut  : std_logic_vector (15 downto 0);
	signal sramIn   : std_logic_vector (15 downto 0);
	signal sramOE   : std_logic := '1';
	signal sramWE   : std_logic := '1';
	

  
  -- state = 99 : work done... waiting for start = 1
  --         0 : writing
  --         1 : waiting for start = 1. Then prepare to read RAM[1]
  --         k : RAM is ready to read RAM[k-1]. Prepare to read RAM[k]
  
begin
	
	
	debug(3 downto 0) <= std_logic_vector(to_unsigned(state,4));
	debug(7 downto 4) <= sramIn(3 downto 0);
	
		-- Sorties de pilotages
	SRAM_OE_N <= sramOE;
	SRAM_WE_N <= sramWE;
	--SRAM_ADDR <= sramAddr;
	
   -- Buffer double sens
	with sramOE select
	sramIn <= SRAM_DQ when '0',
				 "0000000000000000" when others;
	
	with sramOE select
	SRAM_DQ <= "ZZZZZZZZZZZZZZZZ" when '0',
				sramOut when others;
				  

   sramdq <= signed(sramIn);
  
  
  --big_output <= std_logic_vector(result); -- Vecteur logique du 32 bits signes
  result2 <= result / 1024;
  output <= std_logic_vector(TO_Signed(TO_integer(result2),16));
  

  
	process (CLOCK_50)
	begin

		if rising_edge(CLOCK_50) then
			
      case state is
      
				when 99 =>
		  
					if start = '1' then
						state <= 0;
					end if;
				
				
				when 0 =>
				      -- Si WE n'est pas a 1, il faut prevoir une etape en amont pour ly mettre
						sramWE <= '0'; -- Autorisation ecriture, asynchrone
						sramOE <= '1'; -- Preparation a lecriture
						SRAM_ADDR <= std_logic_vector(i);
						sramOut   <= input;
						useRAM    <= '1';
						result    <= to_signed(0, 32);
						state     <= 1;

				when 1 =>
						sramWE    <= '1'; -- Avec ce nouveau cycle, l'ecriture s'est termine
						sramOE    <= '0'; -- Mettra SRAM_DQ en haute impedance
						SRAM_ADDR <= std_logic_vector(i + delay(1));
						state     <= 2;
						
	      when 2 =>
              result <= result + sramdq * coeff(1);
              SRAM_ADDR <= std_logic_vector(i + delay(2));
              state <= 3;
				  
			when 3 =>
             result <= result + sramdq * coeff(2);
              SRAM_ADDR <= std_logic_vector(i + delay(3));
              state <= 4;
			when 4 =>
              result <= result + sramdq * coeff(3);
              SRAM_ADDR <= std_logic_vector(i + delay(4));
              state <= 5;
			when 5 =>
              result <= result + sramdq * coeff(4);
              SRAM_ADDR <= std_logic_vector(i + delay(5));
              state <= 6;
			when 6 =>
              result <= result + sramdq * coeff(5);
              SRAM_ADDR <= std_logic_vector(i + delay(6));
              state <= 7;
			when 7 =>
              result <= result + sramdq * coeff(6);
              SRAM_ADDR <= std_logic_vector(i + delay(7));
              state <= 8;
			when 8 =>
              result <= result + sramdq * coeff(7);
              SRAM_ADDR <= std_logic_vector(i + delay(8));
              state <= 9;
			when 9 =>
              result <= result + sramdq * coeff(8);
              SRAM_ADDR <= std_logic_vector(i + delay(9));
              state <= 10;
			when 10 =>
              result <= result + sramdq * coeff(9);
              SRAM_ADDR <= std_logic_vector(i + delay(10));
              state <= 11;
	 

        when 11 =>
            result <= result + sramdq * coeff(10);
            useRAM <= '0';
            state <= 99;
				sramOE <= '1';
				sramWE <= '1';
				
			when others =>
				state <= 99;
            
        end case;

		end if;
    
	end process;

  

end fat_reader_arch;