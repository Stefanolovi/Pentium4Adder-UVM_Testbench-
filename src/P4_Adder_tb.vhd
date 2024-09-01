library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity TB_P4_ADDER is
end TB_P4_ADDER;

architecture TEST of TB_P4_ADDER is
	
	-- P4 component declaration
	component P4_ADDER is
		generic (
			NBIT :		integer := 32);
		port (
			A :		in	std_logic_vector(NBIT-1 downto 0);
			B :		in	std_logic_vector(NBIT-1 downto 0);
			Cin :	in	std_logic;
			S :		out	std_logic_vector(NBIT-1 downto 0);
			Cout :	out	std_logic);
	end component;
	

	
	constant N: integer := 32; 
	constant N_PER_BLOCK: integer := 4; 
	
	signal A_s,B_s: std_logic_vector (N-1 downto 0) := (others => '0'); 
	signal S_s: std_logic_vector (N-1 downto 0); 
	signal Cin_s,Cout_s: std_logic; 
	
begin
	-- P4 instantiation
	-- 
	--
	uut: P4_adder generic map (NBIT=>N)
	              port map (A=>A_s,B=>B_s,Cin=>Cin_s,S=>S_s,Cout=>Cout_s); 
	              
	process 
	begin 

		Cin_s<='1'; 

	    NumROW : for i in 0 to 2**(N/2)-1 loop

        -- cycle for operand B
    	NumCOL : for i in 0 to 2**(N/2)-1 loop
	    wait for 10 ns;
	    B_s <= B_s + '1';
	end loop NumCOL ;
        
	A_s <= A_s + '1'; 	
    end loop NumROW ;

  

    wait;
	end process;               
	              
	
end TEST;