library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 

entity arithmetic_unit is
    Port (
        X : in  STD_LOGIC_VECTOR (31 downto 0);
        Y : in  STD_LOGIC_VECTOR (31 downto 0);
        ctrl_inv_x : in  STD_LOGIC; 
        ctrl_inv_y : in  STD_LOGIC; 
        ctrl_use_y : in  STD_LOGIC; 
        ctrl_cin : in  STD_LOGIC;   
        result: out STD_LOGIC_VECTOR (31 downto 0);
        flags: out STD_LOGIC_VECTOR (6 downto 0)
    );
end arithmetic_unit;

architecture Behavioral of arithmetic_unit is

    component full_adder
        Port (
            A, B, Cin : in STD_LOGIC;
            Sum, Cout : out STD_LOGIC
        );
    end component;

    signal S_sum : STD_LOGIC_VECTOR(31 downto 0);
    signal S_cout : STD_LOGIC_VECTOR(31 downto 0);
    signal S_A : STD_LOGIC_VECTOR(31 downto 0);
    signal S_B : STD_LOGIC_VECTOR(31 downto 0);
    
    signal Z, C, P, O, A_aux, S, D : STD_LOGIC := '0'; 

begin    

    S_A <= X when ctrl_inv_x = '0' else NOT X;
    
    S_B <= (others => '0') when ctrl_use_y = '0' else   
           Y when ctrl_inv_y = '0' else NOT Y;          
           
    adder_0: full_adder
        Port map (
            A => S_A(0),
            B => S_B(0),
            Cin => ctrl_cin,
            Sum => S_sum(0),
            Cout => S_cout(0)
        );

    G_RCA: for i in 1 to 31 generate
        adder_i: full_adder
            Port map (
                A => S_A(i),
                B => S_B(i),
                Cin => S_cout(i-1),
                Sum => S_sum(i),
                Cout => S_cout(i)
            );
    end generate G_RCA;
    
    
    Z <= '1' when S_sum = x"00000000" else '0';
    S <= S_sum(31);
    C <= S_cout(31);
    O <= S_cout(31) XOR S_cout(30);
    P <= S_sum(0) XOR S_sum(1) XOR S_sum(2) XOR S_sum(3) XOR S_sum(4) XOR S_sum(5) XOR S_sum(6) XOR S_sum(7) XOR
         S_sum(8) XOR S_sum(9) XOR S_sum(10) XOR S_sum(11) XOR S_sum(12) XOR S_sum(13) XOR S_sum(14) XOR S_sum(15) XOR
         S_sum(16) XOR S_sum(17) XOR S_sum(18) XOR S_sum(19) XOR S_sum(20) XOR S_sum(21) XOR S_sum(22) XOR S_sum(23) XOR
         S_sum(24) XOR S_sum(25) XOR S_sum(26) XOR S_sum(27) XOR S_sum(28) XOR S_sum(29) XOR S_sum(30) XOR S_sum(31);
    A_aux <= S_cout(3); 
    D <= '0';
    
    flags <= Z & C & P & O & A_aux & S & D;
    result <= S_sum;

end Behavioral;