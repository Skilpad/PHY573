library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package nos_types is

-- N = 10;
-- SumCoef = 1024 = 2^10  -- Les coefficients multiplicateurs a[i] vérifient Sum(a[i]) = 2^n

type signed_array16 is array(1 to 10) of signed (15 downto 0);
type unsigned_array18 is array(1 to 10) of unsigned (17 downto 0);


end nos_types;