
-- output = Sum(coeff[i]*RAM[i+delay[i]])
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.nos_types.all;

entity effect_actif is


port (

    CLOCK_50  : in  std_logic;
	 start     : in std_logic;
	 input     : in std_logic_vector (15 downto 0);	
    output    : out std_logic_vector (15 downto 0)
	 
);
end effect_actif;





architecture effect_actif_arch of effect_actif is

signal y1 : signed (15 downto 0);
signal y2 : signed (15 downto 0);
signal y3 : signed (15 downto 0);
signal y4 : signed (15 downto 0);
signal y5 : signed (15 downto 0);

signal y1 : signed (15 downto 0);
signal y2 : signed (15 downto 0);
signal y3 : signed (15 downto 0);
signal y4 : signed (15 downto 0);
signal y5 : signed (15 downto 0);



	

  
  -- state = 99 : work done... waiting for start = 1
  --         0 : writing
  --         1 : waiting for start = 1. Then prepare to read RAM[1]
  --         k : RAM is ready to read RAM[k-1]. Prepare to read RAM[k]
  
begin
	

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
						state  <= 0;
						result <= to_signed(0, 32);
					end if;
				

	      when 0 =>
              result <= result + sramdq * coeff(1);
              
				  state <= 
				  
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