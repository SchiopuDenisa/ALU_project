library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_arithmetic_unit is
end tb_arithmetic_unit;

architecture behavior of tb_arithmetic_unit is

    component arithmetic_unit
    Port (
        X : in STD_LOGIC_VECTOR (31 downto 0);
        Y : in STD_LOGIC_VECTOR (31 downto 0);
        ctrl_inv_x : in STD_LOGIC;
        ctrl_inv_y : in STD_LOGIC;
        ctrl_use_y : in STD_LOGIC;
        ctrl_cin   : in STD_LOGIC;
        result     : out STD_LOGIC_VECTOR (31 downto 0); 
        flags      : out STD_LOGIC_VECTOR (6 downto 0)
    );
    end component;

    signal X : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    signal Y : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    signal ctrl_inv_x : STD_LOGIC := '0';
    signal ctrl_inv_y : STD_LOGIC := '0';
    signal ctrl_use_y : STD_LOGIC := '0';
    signal ctrl_cin   : STD_LOGIC := '0';
    signal result : STD_LOGIC_VECTOR (31 downto 0);
    signal flags : STD_LOGIC_VECTOR (6 downto 0);

begin

    uut: arithmetic_unit PORT MAP (
        X => X,
        Y => Y,
        ctrl_inv_x => ctrl_inv_x,
        ctrl_inv_y => ctrl_inv_y,
        ctrl_use_y => ctrl_use_y,
        ctrl_cin => ctrl_cin,
        result => result,
        flags => flags
    );

    stim_proc: process
    begin
        wait for 50 ns;

        X <= std_logic_vector(to_signed(10, 32));
        Y <= std_logic_vector(to_signed(5, 32));
        ctrl_inv_x <= '0'; ctrl_inv_y <= '0'; ctrl_use_y <= '1'; ctrl_cin <= '0';
        wait for 200 ns;

        X <= std_logic_vector(to_signed(20, 32));
        Y <= std_logic_vector(to_signed(5, 32));
        ctrl_inv_x <= '0'; ctrl_inv_y <= '1'; ctrl_use_y <= '1'; ctrl_cin <= '1';
        wait for 200 ns;

        X <= std_logic_vector(to_signed(15, 32));
        ctrl_inv_x <= '0'; ctrl_inv_y <= '0'; ctrl_use_y <= '0'; ctrl_cin <= '1';
        wait for 200 ns;

        X <= std_logic_vector(to_signed(50, 32));
        ctrl_inv_x <= '1'; ctrl_inv_y <= '0'; ctrl_use_y <= '0'; ctrl_cin <= '1';
        wait for 200 ns;

        wait;
    end process;
end behavior;