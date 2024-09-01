library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

ENTITY CARRY_S is
generic(nBits : integer := 4);
Port (	ci:	in	std_logic;
		A: in std_logic_vector(nBits-1 downto 0);
		B: in std_logic_vector(nBits-1 downto 0);
		S: out std_logic_vector(nBits-1 downto 0));

end ENTITY;

architecture STRUCTURAL of CARRY_S is

component MUX21_GENERIC is
	Generic (NBIT: integer:= 4);
	Port (	A:	In	std_logic_vector(NBIT-1 downto 0) ;     
		B:	In	std_logic_vector(NBIT-1 downto 0);
		SEL:	In	std_logic;
		Y:	Out	std_logic_vector(NBIT-1 downto 0));
	end component;
	

component RCA_generic is 
	generic ( N: integer:= 6);           -- add parameter N. 
	Port (	A:	In	std_logic_vector(N-1 downto 0);     --N determines size of A,B and S.
		B:	In	std_logic_vector(N-1 downto 0);
		Ci:	In	std_logic;
		S:	Out	std_logic_vector(N-1 downto 0);
		Co:	Out	std_logic);
end component; 

signal sum0,sum1: std_logic_vector (nbits-1 downto 0);

begin

rca0: RCA_generic 
generic map (N=>nbits) 
port map ( A=>A,B=>B,Ci=>'0',S=>Sum0,Co=>open); 
                  
rca1: RCA_generic  
generic map (N=>nbits) 
port map ( A=>A,B=>B,Ci=>'1',S=>Sum1,Co=>open);
                  
mux: MUX21_GENERIC generic map (NBIT=>nBits) 
                   port map (A=>sum1,B=>sum0, SEL=>Ci,Y=>S);

end STRUCTURAL;


