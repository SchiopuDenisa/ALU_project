library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_shifter is
end tb_shifter;

architecture behavior of tb_shifter is

    component shifter
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        load : in STD_LOGIC;
        enable : in STD_LOGIC;
        shift_dir : in STD_LOGIC;
        data_in : in STD_LOGIC_VECTOR (31 downto 0);
        result : out STD_LOGIC_VECTOR (31 downto 0)
    );
    end component;

    -- Inputs
    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '0';
    signal load : STD_LOGIC := '0';
    signal enable : STD_LOGIC := '0';
    signal shift_dir : STD_LOGIC := '0';
    signal data_in : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    signal result : STD_LOGIC_VECTOR (31 downto 0);

    constant clk_period : time := 50 ns;

begin

    uut: shifter PORT MAP (
        clk => clk,
        rst => rst,
        load => load,
        enable => enable,
        shift_dir => shift_dir,
        data_in => data_in,
        result => result
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
        wait for 20 ns;
        rst <= '0';

        load <= '1';
        data_in <= x"00000001";
        wait for clk_period;
        load <= '0';

        enable <= '1';
        shift_dir <= '0';
        wait for clk_period * 2;
        
        shift_dir <= '1';
        wait for clk_period * 3;
        
        enable <= '0';

        wait;
    end process;

end behavior;