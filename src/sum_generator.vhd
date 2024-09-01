library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity SUM_GENERATOR is
generic (	NBIT_PER_BLOCK: integer := 4;
			NBLOCKS:	integer := 8);
		port (
			A:	in	std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0);
			B:	in	std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0);
			Ci:	in	std_logic_vector(NBLOCKS-1 downto 0);
			S:	out	std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0));
end SUM_GENERATOR;

architecture structural of SUM_GENERATOR is

component CARRY_S is
generic(nBits : integer := 4);
Port (	ci:	in	std_logic;
		A: in std_logic_vector(nBits-1 downto 0);
		B: in std_logic_vector(nBits-1 downto 0);
		S: out std_logic_vector(nBits-1 downto 0));

end component;

begin

sg: for i in 0 to NBLOCKS-1 generate
		CSBLOCK: CARRY_S generic map(nBits=>NBIT_PER_BLOCK )
		port map(A => A((i+1)*NBIT_PER_BLOCK-1 downto (i)*NBIT_PER_BLOCK),
				 B => B((i+1)*NBIT_PER_BLOCK-1 downto (i)*NBIT_PER_BLOCK),
				 Ci => ci(i), S => S((i+1)*NBIT_PER_BLOCK-1 downto (i)*NBIT_PER_BLOCK));
		end generate;

end structural;
