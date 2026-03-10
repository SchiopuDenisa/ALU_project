library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity logic_unit is
    Port ( 
        X : in  STD_LOGIC_VECTOR (31 downto 0); 
        Y : in  STD_LOGIC_VECTOR (31 downto 0);
        operation : in  STD_LOGIC_VECTOR (1 downto 0);
        result : out STD_LOGIC_VECTOR (31 downto 0);
        flags: out STD_LOGIC_VECTOR (6 downto 0)
    );
end logic_unit;

architecture Behavioral of logic_unit is

signal s_res : STD_LOGIC_VECTOR(31 downto 0);
signal Z, C, P, O, A, S, D : STD_LOGIC := '0';

begin

process(X, Y, operation)
begin
    case operation is
        when "00" => s_res <= X AND Y;
        when "01" => s_res <= X OR Y;
        when "10" => s_res <= NOT X;
        when others => s_res <= (others => '0');
    end case;
end process;

result <= s_res;

Z <= '1' when s_res = x"00000000" else '0';
S <= s_res(31);
P <= s_res(0) XOR s_res(1) XOR s_res(2) XOR s_res(3) XOR
     s_res(4) XOR s_res(5) XOR s_res(6) XOR s_res(7) XOR
     s_res(8) XOR s_res(9) XOR s_res(10) XOR s_res(11) XOR
     s_res(12) XOR s_res(13) XOR s_res(14) XOR s_res(15) XOR
     s_res(16) XOR s_res(17) XOR s_res(18) XOR s_res(19) XOR
     s_res(20) XOR s_res(21) XOR s_res(22) XOR s_res(23) XOR
     s_res(24) XOR s_res(25) XOR s_res(26) XOR s_res(27) XOR
     s_res(28) XOR s_res(29) XOR s_res(30) XOR s_res(31);
     
flags <= Z & C & NOT(P) & O & A & S & D;

end Behavioral;
