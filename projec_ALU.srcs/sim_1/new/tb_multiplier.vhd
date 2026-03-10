library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_multiplier is
end tb_multiplier;

architecture behavior of tb_multiplier is

    component multiplier
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        start : in STD_LOGIC;
        X_in : in STD_LOGIC_VECTOR (31 downto 0);
        Y_in : in STD_LOGIC_VECTOR (31 downto 0);
        result : out STD_LOGIC_VECTOR (31 downto 0);
        flags : out STD_LOGIC_VECTOR (6 downto 0)
    );
    end component;

    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '0';
    signal start : STD_LOGIC := '0';
    signal X_in : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    signal Y_in : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    signal result : STD_LOGIC_VECTOR (31 downto 0);
    signal flags : STD_LOGIC_VECTOR (6 downto 0);

    constant clk_period : time := 10 ns;

begin

    uut: multiplier PORT MAP (
        clk => clk,
        rst => rst,
        start => start,
        X_in => X_in,
        Y_in => Y_in,
        result => result,
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

        X_in <= std_logic_vector(to_signed(10, 32));
        Y_in <= std_logic_vector(to_signed(5, 32));
        start <= '1';
        wait for clk_period;
        start <= '0';
        wait for clk_period * 40; 
        
        X_in <= std_logic_vector(to_signed(10, 32));
        Y_in <= std_logic_vector(to_signed(-5, 32));
        start <= '1';
        wait for clk_period;
        start <= '0';
        wait for clk_period * 40;

        X_in <= std_logic_vector(to_signed(-4, 32));
        Y_in <= std_logic_vector(to_signed(-4, 32));
        start <= '1';
        wait for clk_period;
        start <= '0';
        wait for clk_period * 40;

        X_in <= std_logic_vector(to_signed(12345, 32));
        Y_in <= (others => '0');
        start <= '1';
        wait for clk_period;
        start <= '0';
        wait for clk_period * 40;

        wait;
    end process;

end behavior;