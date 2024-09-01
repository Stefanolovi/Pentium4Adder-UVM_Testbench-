library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

entity RCA_generic is 
	generic ( N: integer:= 6);           -- add parameter N. 
	Port (	A:	In	std_logic_vector(N-1 downto 0);     --N determines size of A,B and S.
		B:	In	std_logic_vector(N-1 downto 0);
		Ci:	In	std_logic;
		S:	Out	std_logic_vector(N-1 downto 0);
		Co:	Out	std_logic);
end RCA_generic; 

architecture BEHAVIORAL of RCA_generic is

signal Atmp,Btmp,behSumTmp: std_logic_vector (N downto 0);   --signals needed for behavioural sum (they need to be of N+1 bits)

begin
  Atmp<="0" & A; 
  Btmp<="0" & B; 
  behSumTmp <=  std_logic_vector(unsigned(Atmp) + unsigned(Btmp) +1) when (Ci='1') else 
                std_logic_vector(unsigned(Atmp) + unsigned(Btmp)); 
  Co<=behSumTmp(N) ;
  S <= behSumTmp(N-1 downto 0);

end BEHAVIORAL;
