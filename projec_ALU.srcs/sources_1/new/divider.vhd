library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity divider is
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        start : in STD_LOGIC;
        X_dividend : in STD_LOGIC_VECTOR (31 downto 0);
        Y_divisor : in STD_LOGIC_VECTOR (31 downto 0);
        quotient : out STD_LOGIC_VECTOR (31 downto 0);
        remainder : out STD_LOGIC_VECTOR (31 downto 0);
        flags : out STD_LOGIC_VECTOR (6 downto 0);
        ready : out STD_LOGIC 
    );
end divider;

architecture Behavioral of divider is
    type state_type is (IDLE, INIT, OPERATE, FINISH);
    signal current_state : state_type := IDLE;
    signal B_reg, Q_reg, A_reg : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal count : INTEGER range 0 to 32 := 0;
    signal q_sign, r_sign, div_zero : STD_LOGIC := '0';
begin
    process(clk, rst)
        variable v_A, v_Q, v_B : unsigned(31 downto 0);
    begin
        if rst = '1' then
            current_state <= IDLE; ready <= '0';
            quotient <= (others => '0'); 
            remainder <= (others => '0');
        elsif rising_edge(clk) then
            v_A := unsigned(A_reg); 
            v_Q := unsigned(Q_reg); 
            v_B := unsigned(B_reg);
            
            case current_state is
                when IDLE =>
                    ready <= '0';
                    if start = '1' then 
                        if Y_divisor = x"00000000" then 
                            div_zero <= '1'; 
                            Q_reg <= (others => '0');
                            A_reg <= (others => '0');
                            q_sign <= '0';
                            r_sign <= '0';
                            current_state <= FINISH;
                        else 
                            div_zero <= '0'; 
                            current_state <= INIT; 
                        end if;
                    end if;
                when INIT =>
                    q_sign <= X_dividend(31) XOR Y_divisor(31);
                    r_sign <= X_dividend(31);
                    A_reg <= (others => '0');
                    Q_reg <= std_logic_vector(abs(signed(X_dividend)));
                    B_reg <= std_logic_vector(abs(signed(Y_divisor)));
                    count <= 32; current_state <= OPERATE;
                when OPERATE =>
                    v_A := v_A(30 downto 0) & v_Q(31);
                    v_Q := v_Q(30 downto 0) & '0'; 
                    if v_A >= v_B then 
                        v_A := v_A - v_B;
                        v_Q(0) := '1'; 
                    else v_Q(0) := '0';
                    end if;
                    count <= count - 1;
                    if count = 1 then current_state <= FINISH;
                    end if;
                    A_reg <= std_logic_vector(v_A);
                    Q_reg <= std_logic_vector(v_Q);
                when FINISH =>
                    if q_sign='1' then quotient <= std_logic_vector(-signed(Q_reg));
                    else quotient <= Q_reg; end if;
                    if r_sign='1' then remainder <= std_logic_vector(-signed(A_reg));
                    else remainder <= A_reg; end if;
                    ready <= '1'; 
                    current_state <= IDLE;
            end case;
        end if;
    end process;
    flags <= "000000" & div_zero;
end Behavioral;