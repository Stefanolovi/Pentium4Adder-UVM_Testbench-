library IEEE;
use IEEE.std_logic_1164.all;

entity G_block is 
   port (Pik,Gik,Gk_1j: in std_logic; 
    Gij: out std_logic);
end G_block; 

architecture behavioural of G_block is 
begin 

    Gij<= Gik or (Pik and Gk_1j); 

end behavioural; 
