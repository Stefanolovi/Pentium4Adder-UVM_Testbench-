library IEEE;
use IEEE.std_logic_1164.all;

entity PG_block  is 
 PORT  (Pik,Gik,Pk_1j,Gk_1j: in std_logic; 
    Pij,Gij: out std_logic);
end PG_block; 

architecture behavioural of PG_block is 
begin 

    Pij <= Pik and Pk_1j; 
    Gij<= Gik or (Pik and Gk_1j); 

end behavioural; 
