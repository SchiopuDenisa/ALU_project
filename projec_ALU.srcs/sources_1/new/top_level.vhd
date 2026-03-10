library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_level is
    Port ( 
        clk : in STD_LOGIC;
        sw  : in STD_LOGIC_VECTOR (5 downto 0);
        btnC : in STD_LOGIC; 
        btnU : in STD_LOGIC; 
        btnR : in STD_LOGIC; 
        btnD : in STD_LOGIC; 
        
        seg : out STD_LOGIC_VECTOR (6 downto 0);
        an  : out STD_LOGIC_VECTOR (3 downto 0);
        led : out STD_LOGIC_VECTOR (15 downto 0)
    );
end top_level;

architecture Behavioral of top_level is

    component instruction_memory
        Port ( addr : in STD_LOGIC_VECTOR(5 downto 0);
               out_opcode : out STD_LOGIC_VECTOR(3 downto 0);
               out_acc, out_op2 : out STD_LOGIC_VECTOR(31 downto 0) );
    end component;

    component execution_unit
        Port ( clk, rst, start_op : in STD_LOGIC;
               opcode : in STD_LOGIC_VECTOR(3 downto 0);
               acc_data_in, op2_data_in : in STD_LOGIC_VECTOR(31 downto 0);
               load_acc, load_op2 : in STD_LOGIC;
               alu_result : out STD_LOGIC_VECTOR(31 downto 0);
               alu_flags : out STD_LOGIC_VECTOR(6 downto 0);
               busy : out STD_LOGIC );
    end component;

    component seven_seg_driver
        Port ( clk, rst : in STD_LOGIC;
               display_data : in STD_LOGIC_VECTOR(15 downto 0);
               an : out STD_LOGIC_VECTOR(3 downto 0);
               seg : out STD_LOGIC_VECTOR(6 downto 0) );
    end component;

    component debouncer
        Port ( clk, btn_in : in STD_LOGIC; btn_out : out STD_LOGIC );
    end component;

    signal s_opcode : STD_LOGIC_VECTOR(3 downto 0);
    signal s_acc_in, s_op2_in, s_result : STD_LOGIC_VECTOR(31 downto 0);
    signal s_flags : STD_LOGIC_VECTOR(6 downto 0);
    signal s_busy : STD_LOGIC;
    
    signal s_rst, s_start_clean, s_scroll_clean, s_load_clean : STD_LOGIC;
    signal s_start_pulse_reg : STD_LOGIC := '0';
    signal s_start_pulse : STD_LOGIC;
    
    signal display_window : STD_LOGIC_VECTOR(15 downto 0);
    signal show_upper_bits : STD_LOGIC := '0'; 
    signal s_scroll_prev : STD_LOGIC := '0';

begin

    U_DB_START: debouncer PORT MAP (clk => clk, btn_in => btnC, btn_out => s_start_clean);
    U_DB_SCROLL: debouncer PORT MAP (clk => clk, btn_in => btnR, btn_out => s_scroll_clean);
    U_DB_LOAD: debouncer PORT MAP (clk => clk, btn_in => btnD, btn_out => s_load_clean); 
    
    s_rst <= btnU;

    process(clk)
    begin
        if rising_edge(clk) then
            s_start_pulse_reg <= s_start_clean;
        end if;
    end process;
    s_start_pulse <= s_start_clean and (not s_start_pulse_reg);

    U_MEM: instruction_memory PORT MAP (
        addr => sw(5 downto 0),
        out_opcode => s_opcode,
        out_acc => s_acc_in,
        out_op2 => s_op2_in
    );

    U_ALU: execution_unit PORT MAP (
        clk => clk, 
        rst => s_rst,
        opcode => s_opcode,
        start_op => s_start_pulse,
        acc_data_in => s_acc_in,
        load_acc => s_load_clean, 
        op2_data_in => s_op2_in,
        load_op2 => s_load_clean, 
        alu_result => s_result,
        alu_flags => s_flags,
        busy => s_busy
    );

    process(clk)
    begin
        if rising_edge(clk) then
            if s_rst = '1' then
                show_upper_bits <= '0';
            elsif s_scroll_clean = '1' and s_scroll_prev = '0' then
                show_upper_bits <= not show_upper_bits;
            end if;
            s_scroll_prev <= s_scroll_clean;
        end if;
    end process;

    display_window <= s_result(31 downto 16) when show_upper_bits = '1' else s_result(15 downto 0);

    U_DISPLAY: seven_seg_driver PORT MAP (
        clk => clk, 
        rst => s_rst,
        display_data => display_window,
        an => an,
        seg => seg
    );

    led(0) <= show_upper_bits; 
    led(1) <= s_busy;
    led(2) <= s_load_clean; 
    led(15 downto 12) <= s_opcode;
    led(8 downto 3) <= s_flags(5 downto 0);

end Behavioral;