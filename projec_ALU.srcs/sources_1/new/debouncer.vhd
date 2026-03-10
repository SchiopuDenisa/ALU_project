library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debouncer is
    Port ( clk : in STD_LOGIC;
           btn_in : in STD_LOGIC;
           btn_out : out STD_LOGIC);
end debouncer;

architecture Behavioral of debouncer is
    signal count : integer := 0;
    signal x_new : std_logic := '0';
    signal x_old : std_logic := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if (btn_in /= x_new) then
                x_new <= btn_in;
                count <= 0;
            elsif (count = 100000) then 
                x_old <= x_new;
            else
                count <= count + 1;
            end if;
        end if;
    end process;
    btn_out <= x_old;
end Behavioral;