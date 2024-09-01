library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Carry_Generator is
  Generic (N: integer :=32;
           NBIT_PER_BLOCK: integer := 4);
  Port (A,B: in std_logic_vector(N-1 downto 0); 
        Cin: in std_logic; 
        C: out std_logic_vector ((N/4)-1 downto 0) );  
end Carry_Generator;

architecture STRUCTURAL of Carry_Generator is

component PG_block  is 
 PORT  (Pik,Gik,Pk_1j,Gk_1j: in std_logic; 
    Pij,Gij: out std_logic);
end component; 

component PG_network  is 
 PORT  (a,b: in std_logic; 
    p,g: out std_logic);
end component; 

component G_block is 
   port (Pik,Gik,Gk_1j: in std_logic; 
    Gij: out std_logic);
end component; 

type SignalVector is array (N downto 0) of std_logic_vector(N downto 0);
signal P,G: SignalVector;
--P(1)(1)=p11=p1.  P(5)(3)=p5:3 .... first index (column) its top border of the range
-- second index (row) is the bottom border of the range.   
--we effectively only need the diagonal and what's below it.                                    
  begin
  
  cycle: for I in 1 to N generate                
     
     --pg network blocks, 1 for each input bit.
     pg_nw: PG_network 
	 Port Map (a=>A(I-1),b=>B(I-1),p=>P(I)(I), g=> G(I)(I));
	
	--this block is not drawn in scheme but necessary to take into account Cin, generates C1 
	C1: if (I=1) generate 
    G1_0: G_block port map (Pik=>P(I)(I), Gik=>G(I)(I), Gk_1j=>Cin, Gij=>G(I)(0));  
	 end generate C1; 
	 
	--First G block top right in the scheme, generates C2 from C1
    C2: if (I=2) generate 
    G2_0: G_block port map (Pik=>P(I)(I), Gik=>G(I)(I), Gk_1j=>G(I-1)(0), Gij=>G(I)(0)); 
	     end generate C2;
	     
	--PG blocks in the first layer:one block every 2 input bits     
	 every2bits: if (I rem 2) = 0 and I>2 generate
	 PG1: PG_block 
	 port map (Pik=>P(I)(I),Gik=> G(I)(I),Pk_1j=>P(I-1)(I-1),Gk_1j=>G(I-1)(I-1),
	                         Pij=>P(I)(I-1),Gij=>G(I)(I-1));
	 end generate every2bits; 
	 
		 --G block in the second layer: generates C4.
	 C4: if (I=4) generate 
	 G4: G_block port map (Pik=>P(I)(I-1), Gik=>G(I)(I-1), Gk_1j=>G(I-2)(0), Gij=>G(I)(0)); 
	 end generate C4; 
	
		 every4bits: if (I rem 4)=0 and I>4 generate
	 PG2: PG_block port map (Pik=>P(I)(I-1) ,Gik=> G(I)(I-1) ,Pk_1j=> P(I-2)(I-3),Gk_1j=>G(I-2)(I-3),
	                         Pij=>P(I)(I-3),Gij=>G(I)(I-3));
	 end generate every4bits;
	 
	 C8: if (I=8) generate
	 G8_0: G_block port map (Pik=>P(I)(I-3), Gik=>G(I)(I-3), Gk_1j=>G(I-4)(0), Gij=>G(I)(0));
	 end generate C8; 
	 
	 every8bits: if (I rem 8)=0 and I>8 generate
	 PG3: PG_block port map (Pik=>P(I)(I-3) ,Gik=> G(I)(I-3) ,Pk_1j=> P(I-4)(I-7),Gk_1j=>G(I-4)(I-7),
	                         Pij=>P(I)(I-7),Gij=>G(I)(I-7));
	 end generate every8bits;

     C12: if (I=12) generate                  
	 G12_0: G_block port map (Pik=>P(I)(I-3), Gik=>G(I)(I-3), Gk_1j=>G(I-4)(0), Gij=>G(I)(0));
	 end generate C12;
     
     	 C16: if (I=16) generate 
	 G16_0: G_block port map (Pik=>P(I)(I-7), Gik=>G(I)(I-7), Gk_1j=>G(I-8)(0), Gij=>G(I)(0));
	 end generate C16;
	 
	  
	 pg32: if (I rem 16)=0 and I>16 generate
	 PG32_17 : PG_block port map (Pik=>P(I)(I-7) ,Gik=> G(I)(I-7) ,
	                              Pk_1j=> P(I-8)(I-15),Gk_1j=>G(I-8)(I-15),
	                              Pij=>P(I)(I-15),Gij=>G(I)(I-15));
	 end generate pg32; 
	 
	 pg28: if ((I-12) rem 16)=0 and I>16 generate                        
	 PG28_17: PG_block port map (Pik=>P(I)(I-3) ,Gik=> G(I)(I-3) ,
	                             Pk_1j=> P(I-4)(I-11),Gk_1j=>G(I-4)(I-11),
	                             Pij=>P(I)(I-11),Gij=>G(I)(I-11));
	 end generate pg28;
	
     	 
      
	 C20: if ((I-4) rem 16)=0 and I>16 generate  --vera per I=20
	 G20_0: G_block port map (Pik=>P(I)(I-3), Gik=>G(I)(I-3), Gk_1j=>G(I-4)(0), Gij=>G(I)(0)); 
	 end generate C20;
	  
	 C24: if ((I-8) rem 16)=0 and I>20 generate   --vera per I=24
	 G24_0: G_block port map (Pik=>P(I)(I-7), Gik=>G(I)(I-7), Gk_1j=>G(I-8)(0), Gij=>G(I)(0));
	 end generate C24; 
	 
	 C28: if ((I-12) rem 16)=0 and I>24 generate
	 G28_0: G_block port map (Pik=>P(I)(I-11), Gik=>G(I)(I-11), Gk_1j=>G(I-12)(0), Gij=>G(I)(0));
	 end generate C28; 
	 
	 C32: if (I rem 16)=0 and I>28 generate
	 G32_0: G_block port map (Pik=>P(I)(I-15), Gik=>G(I)(I-15), Gk_1j=>G(I-16)(0), Gij=>G(I)(0));            
	 end generate C32; 
	
	 every4: if (I rem 4)=0 generate 
	 carryVector: C((I/4)-1)<=G(I)(0);
	 end generate every4;
    --C(0)=G(4)(0)=C4, C(1)=G(8)(0)=C8...
	 
	 end generate cycle; 
	 
 
	
	 
 end STRUCTURAL;
