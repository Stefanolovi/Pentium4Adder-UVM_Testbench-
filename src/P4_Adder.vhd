library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

	ENTITY P4_ADDER is
		generic (
			NBIT :		integer := 32);
		port (
			A :		in	std_logic_vector(NBIT-1 downto 0);
			B :		in	std_logic_vector(NBIT-1 downto 0);
			Cin :	in	std_logic;
			S :		out	std_logic_vector(NBIT-1 downto 0);
			Cout :	out	std_logic);
	end P4_ADDER;

architecture STRUCTURAL of P4_ADDER is

constant NBIT_PER_BLOCK: integer := 4; 
constant NBLOCKS: integer := NBIT/NBIT_PER_BLOCK;

signal C, Ctmp: std_logic_vector ((NBIT/NBIT_PER_BLOCK)-1 downto 0); 

component SUM_GENERATOR is
generic (	NBIT_PER_BLOCK: integer := 4;
			NBLOCKS:	integer := 8);
		port (
			A:	in	std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0);
			B:	in	std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0);
			Ci:	in	std_logic_vector(NBLOCKS-1 downto 0);
			S:	out	std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0));
end component;

component Carry_Generator is
  Generic (N: integer :=32;
           NBIT_PER_BLOCK: integer := 4);
  Port (A,B: in std_logic_vector(N-1 downto 0); 
        Cin: in std_logic; 
        C: out std_logic_vector ((N/4)-1 downto 0) );  
end component;



begin

Carry: Carry_Generator generic map (N=>NBIT, NBIT_PER_BLOCK=>NBIT_PER_BLOCK)
                       port map (A=>A,B=>B,Cin=>Cin,C=>C); 


Ctmp<=C(NBLOCKS-2 downto 0)&Cin; 

sum: SUM_GENERATOR generic map (NBIT_PER_BLOCK=>NBIT_PER_BLOCK,
			                    NBLOCKS=>NBIT/NBIT_PER_BLOCK)
                   port map 
                   (A=>A,
                   B=>B,
                   Ci=>Ctmp,
                   S=>S);			                   
Cout<=C(NBLOCKS-1);

end STRUCTURAL;