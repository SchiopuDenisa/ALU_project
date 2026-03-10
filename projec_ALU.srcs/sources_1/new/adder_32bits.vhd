library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity adder_32bit is
    Port (
        A : in  STD_LOGIC_VECTOR (31 downto 0);
        B : in  STD_LOGIC_VECTOR (31 downto 0);
        Cin : in  STD_LOGIC;
        Sum : out STD_LOGIC_VECTOR (31 downto 0);
        Cout : out STD_LOGIC
    );
end adder_32bit;

architecture Structural of adder_32bit is

    -- Component Declaration (must match the Full_Adder.vhd entity)
    component full_adder
        Port (
            A, B, Cin : in STD_LOGIC;
            Sum, Cout : out STD_LOGIC
        );
    end component;

    -- Internal signal for carry propagation
    signal C : STD_LOGIC_VECTOR (32 downto 0);

begin

    -- The initial carry-in C(0) is the external Cin
    C(0) <= Cin;

    -- Generate the 32-bit Ripple Carry Adder
    G_RCA: for i in 0 to 31 generate
        FA_i: full_adder
            Port map (
                A => A(i),
                B => B(i),
                Cin => C(i),
                Sum => Sum(i),
                -- Connect Cout to the next stage's Cin, unless it's the last stage
                Cout => C(i+1)
            );
    end generate G_RCA;

    -- The final Cout is the carry out of the most significant bit (C(32))
    Cout <= C(32);

end Structural;