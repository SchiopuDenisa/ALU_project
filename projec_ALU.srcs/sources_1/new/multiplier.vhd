library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity multiplier is
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        start : in STD_LOGIC;
        X_in : in STD_LOGIC_VECTOR (31 downto 0);
        Y_in : in STD_LOGIC_VECTOR (31 downto 0);
        result : out STD_LOGIC_VECTOR (31 downto 0);
        flags : out STD_LOGIC_VECTOR (6 downto 0);
        ready : out STD_LOGIC 
    );
end multiplier;

architecture Behavioral of multiplier is
    type state_type is (IDLE, CALC, DONE);
    signal state : state_type := IDLE;
    signal A, B, Q : unsigned(63 downto 0);
    signal N : integer range 0 to 32;
    signal sign_res : STD_LOGIC;
begin
    process(clk, rst)
    begin
        if rst = '1' then
            state <= IDLE; 
            result <= (others => '0');
            ready <= '0';
            flags <= (others => '0');
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    ready <= '0';
                    if start = '1' then
                        A <= (others => '0');
                        B(31 downto 0) <= unsigned(abs(signed(X_in))); B(63 downto 32) <= (others => '0');
                        Q(31 downto 0) <= unsigned(abs(signed(Y_in))); Q(63 downto 32) <= (others => '0');
                        N <= 32;
                        sign_res <= X_in(31) XOR Y_in(31);
                        state <= CALC;
                    end if;
                when CALC =>
                    if Q(0) = '1' then A <= A + B; end if;
                    B <= B(62 downto 0) & '0';
                    Q <= '0' & Q(63 downto 1);
                    N <= N - 1;
                    if N = 1 then state <= DONE; end if;
                when DONE =>
                    if sign_res = '1' then result <= std_logic_vector(-signed(A(31 downto 0)));
                    else result <= std_logic_vector(A(31 downto 0));
                    end if;
                    ready <= '1'; 
                    state <= IDLE;
            end case;
        end if;
    end process;
end Behavioral;