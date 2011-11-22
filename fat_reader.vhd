
-- output = Sum(coeff[i]*RAM[i+delay[i]])

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.nos_types.all;

entity fat_reader is
-- generic (
    -- N = 500;
    -- sumCoeffExp = 4;    -- Les coefficients multiplicateurs a[i] vérifient Sum(a[i]) = 2^n
-- );
port (
    -- RAM
    SRAM_ADDR : out std_logic_vector (17 downto 0);
    SRAM_WE_N : out std_logic;
    SRAM_OE_N : out std_logic;
    SRAM_DQ   : in  std_logic_vector (15 downto 0);
    -- Time
    CLOCK_50  : in  std_logic;
    start     : in  std_logic;
    useRAM    : out std_logic;
    -- Values
    i         : in  unsigned(17 downto 0);      -- 2^18 = 262144 cells in RAM
    delay     : in  unsigned_array18;
    coeff     : in  unsigned_array16;       -- 2^16 = 65536
    -- output
    output    : out std_logic_vector (15 downto 0)
);
end fat_reader;





architecture fat_reader_arch of fat_reader is

  signal result     : unsigned (15+sumCoeffExp downto 0);
  signal big_output : std_logic_vector (15+sumCoeffExp downto 0);  
  
  signal state      : unsigned (17 downto 0) := to_unsigned(0);
  -- state = 0 : work done... waiting for start = 0
  --         1 : waiting for start = 1. Then prepare to read RAM[1]
  --         k : RAM is ready to read RAM[k-1]. Prepare to read RAM[k]
  
begin
	
  big_output <= std_logic_vector(result);
  
  for k in 0 to sumCoeffExp-1 generate
    output(k) <= big_output(sumCoeffExp+k);
  end generate;

  
	process (CLOCK_50)
	begin

		if rising_edge(CLOCK_50) then
			
      case state is
      
        when 0 =>
            if start = '0' then
              state <= 1;        -- state-1 = -2
            end if;
        when 1 =>
            if start = '0' then
              state <= 1;        -- state-1 = -2
            else
              SRAM_OE_N <= '0';
              SRAM_WE_N <= '1';
              useRAM    <= '1';
              result    <= to_unsigned(0);
              SRAM_ADDR <= std_logic_vector(i + delay(1));
              state <= 2;        -- state-1 = 0
            end if;
            
    for k in 2 to N generate
        when k =>
              result <= result + (SRAM_DQ / totCoeff) * coeff(k);
              SRAM_ADDR <= std_logic_vector(i + delay(k));
              state <= k + 1;
    end generate;
            
        when N+1 =>
            result <= result + (SRAM_DQ / totCoeff) * coeff(k);
            useRAM <= '0';
            state <= 0;
            
        end case;

		end if;
    
	end process;

  

end fat_reader_arch;