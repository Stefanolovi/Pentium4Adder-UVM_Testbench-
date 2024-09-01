library IEEE;
use IEEE.std_logic_1164.all;

-- inputs and outputs are on N bits, defined through generic map
entity MUX21_GENERIC is
	Generic (NBIT: integer:= 4);
	Port (	A:	In	std_logic_vector(NBIT-1 downto 0) ;     
		B:	In	std_logic_vector(NBIT-1 downto 0);
		SEL:	In	std_logic;
		Y:	Out	std_logic_vector(NBIT-1 downto 0));
	end MUX21_GENERIC;


architecture behavioural of MUX21_GENERIC is    
begin 
process (A,B,SEL)
begin 
if (SEL='1') then Y<=A; 
else Y<=B;
end if;
end process;
end behavioural;

