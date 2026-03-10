library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity shifter is
    Port ( 
        clk : in  STD_LOGIC;
        rst : in  STD_LOGIC;
        load : in  STD_LOGIC;                     
        enable : in  STD_LOGIC;                     
        shift_dir : in  STD_LOGIC;
        data_in : in  STD_LOGIC_VECTOR (31 downto 0);
        result : out STD_LOGIC_VECTOR (31 downto 0)
    );
end shifter;

architecture Behavioral of shifter is

signal res : STD_LOGIC_VECTOR(31 downto 0);

begin

process(clk, rst)
begin
   if rst = '1' then
       res <= (others => '0');
       
   elsif rising_edge(clk) then
      if load = '1' then
          res <= data_in;
          
      elsif enable = '1' then
          if shift_dir = '0' then
              res <= res(30 downto 0) & res(31);
          else
              res <= res(0) & res(31 downto 1);
          end if;
      end if;
   end if;
end process;

result <= res;

end Behavioral;