library IEEE;
use IEEE.std_logic_1164.all;

package nos_types is

N = 500;
sumCoeffExp = 4;    -- Les coefficients multiplicateurs a[i] vérifient Sum(a[i]) = 2^n

type unsigned_array16 is array(1 to N) of unsigned (15 downto 0);
type unsigned_array18 is array(1 to N) of unsigned (17 downto 0);


end nos_types;