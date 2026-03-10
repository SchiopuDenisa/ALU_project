library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_logic_unit is
end tb_logic_unit;

architecture behavior of tb_logic_unit is

    component logic_unit
    Port (
        X : in STD_LOGIC_VECTOR (31 downto 0);
        Y : in STD_LOGIC_VECTOR (31 downto 0);
        operation : in STD_LOGIC_VECTOR (1 downto 0);
        result : out STD_LOGIC_VECTOR (31 downto 0);
        flags : out STD_LOGIC_VECTOR (6 downto 0)
    );
    end component;

    signal X : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    signal Y : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    signal operation : STD_LOGIC_VECTOR (1 downto 0) := "00";
    signal result : STD_LOGIC_VECTOR (31 downto 0);
    signal flags : STD_LOGIC_VECTOR (6 downto 0);
    
    signal Z_flag, C_flag, P_flag, O_flag, A_flag, S_flag, D_flag : STD_LOGIC;

begin

    uut: logic_unit PORT MAP (
        X => X,
        Y => Y,
        operation => operation,
        result => result,
        flags => flags
    );

    Z_flag <= flags(6);
    C_flag <= flags(5);
    P_flag <= flags(4); 
    O_flag <= flags(3);
    A_flag <= flags(2);
    S_flag <= flags(1);
    D_flag <= flags(0);

    stim_proc: process
    begin
        wait for 50 ns;

        X <= x"0000000F";
        Y <= x"00000005";
        operation <= "00";
        wait for 200 ns;

        X <= x"0000000A";
        Y <= x"00000005";
        operation <= "01";
        wait for 200 ns;

        X <= x"00000000";
        Y <= x"00000000"; 
        operation <= "10";
        wait for 200 ns;

        X <= x"55555555";
        Y <= x"AAAAAAAA";
        operation <= "00";
        wait for 200 ns;

        wait;
    end process;

end behavior;