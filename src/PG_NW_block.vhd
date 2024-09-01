library IEEE;
use IEEE.std_logic_1164.all;

entity PG_network  is 
 PORT  (a,b: in std_logic; 
    p,g: out std_logic);
end PG_network; 

architecture behavioural of PG_network is 
begin 

    p <= a xor b; 
    g<= a and b; 

end behavioural; 
