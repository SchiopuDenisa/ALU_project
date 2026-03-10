library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_divider is
end tb_divider;

architecture behavior of tb_divider is

    component divider
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        start : in STD_LOGIC;
        X_dividend : in STD_LOGIC_VECTOR (31 downto 0);
        Y_divisor : in STD_LOGIC_VECTOR (31 downto 0);
        quotient : out STD_LOGIC_VECTOR (31 downto 0);
        remainder : out STD_LOGIC_VECTOR (31 downto 0);
        flags : out STD_LOGIC_VECTOR (6 downto 0)
    );
    end component;

    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '0';
    signal start : STD_LOGIC := '0';
    signal X_dividend : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    signal Y_divisor : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    signal quotient : STD_LOGIC_VECTOR (31 downto 0);
    signal remainder : STD_LOGIC_VECTOR (31 downto 0);
    signal flags : STD_LOGIC_VECTOR (6 downto 0);

    constant clk_period : time := 10 ns;

begin

    uut: divider PORT MAP (
        clk => clk,
        rst => rst,
        start => start,
        X_dividend => X_dividend,
        Y_divisor => Y_divisor,
        quotient => quotient,
        remainder => remainder,
        flags => flags
    );

    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    stim_proc: process
    begin
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for clk_period;

        X_dividend <= std_logic_vector(to_signed(20, 32));
        Y_divisor <= std_logic_vector(to_signed(4, 32));
        start <= '1';
        wait for clk_period;
        start <= '0';
        
        wait for clk_period * 80;

        X_dividend <= std_logic_vector(to_signed(20, 32));
        Y_divisor <= std_logic_vector(to_signed(3, 32));
        start <= '1';
        wait for clk_period;
        start <= '0';
        wait for clk_period * 80;

        X_dividend <= std_logic_vector(to_signed(-20, 32));
        Y_divisor <= std_logic_vector(to_signed(4, 32));
        start <= '1';
        wait for clk_period;
        start <= '0';
        wait for clk_period * 80;

        X_dividend <= std_logic_vector(to_signed(50, 32));
        Y_divisor <= (others => '0');
        start <= '1';
        wait for clk_period;
        start <= '0';
        wait for clk_period * 10; 
        
        wait;
    end process;

end behavior;