
-- Allow to convert inout signal to in or out signal.
-- Depending on the used links, signal can be 16 or 18 bits.



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;



entity inout_to_in_out is
port(
  inout16 : inout std_logic_vector (15 downto 0); 
  inout18 : inout std_logic_vector (17 downto 0); 
  in16    : in    std_logic_vector (15 downto 0); 
  in18    : in    std_logic_vector (17 downto 0); 
  out16   : out   std_logic_vector (15 downto 0); 
  out18   : out   std_logic_vector (17 downto 0)
);
end inout_to_in_out;

architecture inout_to_in_out_arch of inout_to_in_out is
begin
      
  inout16 <= in16;
  inout16 <= out16;
  inout18 <= in18;
  inout18 <= out18;
    
end inout_to_in_out;