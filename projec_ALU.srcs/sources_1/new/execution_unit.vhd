library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity execution_unit is
    Port (
        clk, rst   : in  STD_LOGIC;
        opcode     : in  STD_LOGIC_VECTOR (3 downto 0);
        start_op   : in  STD_LOGIC;
        acc_data_in : in  STD_LOGIC_VECTOR (31 downto 0);
        load_acc    : in  STD_LOGIC;
        op2_data_in : in  STD_LOGIC_VECTOR (31 downto 0);
        load_op2    : in  STD_LOGIC;
        alu_result : out STD_LOGIC_VECTOR (31 downto 0);
        alu_flags  : out STD_LOGIC_VECTOR (6 downto 0);
        busy       : out STD_LOGIC
    );
end execution_unit;

architecture Behavioral of execution_unit is

    component control_unit
        Port ( clk, rst : in STD_LOGIC; 
               opcode : in STD_LOGIC_VECTOR(3 downto 0); 
               start_op : in STD_LOGIC;
               ctrl_inv_x, ctrl_inv_y, ctrl_use_y, ctrl_cin : out STD_LOGIC;
               logic_op : out STD_LOGIC_VECTOR(1 downto 0); 
               shift_dir, shift_en, start_mul, start_div : out STD_LOGIC;
               mux_sel : out STD_LOGIC_VECTOR(1 downto 0) );
    end component;

    component arithmetic_unit
        Port ( X, Y : in STD_LOGIC_VECTOR(31 downto 0); 
               ctrl_inv_x, ctrl_inv_y, ctrl_use_y, ctrl_cin : in STD_LOGIC;
               result : out STD_LOGIC_VECTOR(31 downto 0); 
               flags : out STD_LOGIC_VECTOR(6 downto 0) );
    end component;

    component logic_unit
        Port ( X, Y : in STD_LOGIC_VECTOR(31 downto 0); 
               operation : in STD_LOGIC_VECTOR(1 downto 0);
               result : out STD_LOGIC_VECTOR(31 downto 0); 
               flags : out STD_LOGIC_VECTOR(6 downto 0) );
    end component;

    component shifter
        Port ( clk, rst, load, enable, shift_dir : in STD_LOGIC; 
               data_in : in STD_LOGIC_VECTOR(31 downto 0);
               result : out STD_LOGIC_VECTOR(31 downto 0) );
    end component;

    component multiplier
        Port ( clk, rst, start : in STD_LOGIC; 
               X_in, Y_in : in STD_LOGIC_VECTOR(31 downto 0);
               result : out STD_LOGIC_VECTOR(31 downto 0); 
               flags : out STD_LOGIC_VECTOR(6 downto 0); 
               ready : out STD_LOGIC );
    end component;

    component divider
        Port ( clk, rst, start : in STD_LOGIC; 
               X_dividend, Y_divisor : in STD_LOGIC_VECTOR(31 downto 0);
               quotient, remainder : out STD_LOGIC_VECTOR(31 downto 0); 
               flags : out STD_LOGIC_VECTOR(6 downto 0); 
               ready : out STD_LOGIC );
    end component;

    signal ACC_reg, OP2_reg: STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    signal FLG_reg : STD_LOGIC_VECTOR (6 downto 0) := (others => '0');
    signal c_inv_x, c_inv_y, c_use_y, c_cin, c_shift_dir, c_shift_en, c_start_mul, c_start_div : STD_LOGIC;
    signal c_logic_op, c_mux_sel : STD_LOGIC_VECTOR(1 downto 0);
    signal arith_y_input : STD_LOGIC_VECTOR(31 downto 0);
    signal res_arith, res_logic, res_shift, res_mul, res_div_q, res_div_r, final_result : STD_LOGIC_VECTOR(31 downto 0);
    signal flags_arith, flags_logic, flags_mul, flags_div, final_flags : STD_LOGIC_VECTOR(6 downto 0);
    signal mul_ready_sig, div_ready_sig, shift_load : STD_LOGIC;
    
    signal shift_delay : STD_LOGIC := '0';
    
    constant ZERO_32 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    constant ZERO_7  : STD_LOGIC_VECTOR(6 downto 0)  := (others => '0');
    
begin

    arith_y_input <= x"00000001" when opcode = "0011" else OP2_reg;
    shift_load <= NOT c_shift_en;
    
    U_CONTROL: control_unit PORT MAP (
        clk => clk, 
        rst => rst, 
        opcode => opcode, 
        start_op => start_op,
        ctrl_inv_x => c_inv_x, 
        ctrl_inv_y => c_inv_y, 
        ctrl_use_y => c_use_y, 
        ctrl_cin => c_cin,
        logic_op => c_logic_op, 
        shift_dir => c_shift_dir, 
        shift_en => c_shift_en,
        start_mul => c_start_mul, 
        start_div => c_start_div, 
        mux_sel => c_mux_sel
    );

    U_ARITH: arithmetic_unit PORT MAP (
        X => ACC_reg, 
        Y => arith_y_input,
        ctrl_inv_x => c_inv_x, 
        ctrl_inv_y => c_inv_y, 
        ctrl_use_y => c_use_y, 
        ctrl_cin => c_cin,
        result => res_arith, 
        flags => flags_arith
    );

    U_LOGIC: logic_unit PORT MAP (
        X => ACC_reg, 
        Y => OP2_reg, 
        operation => c_logic_op,
        result => res_logic, 
        flags => flags_logic
    );
    
    U_SHIFT: shifter PORT MAP (
        clk => clk, 
        rst => rst,
        load => shift_load, 
        enable => c_shift_en, 
        shift_dir => c_shift_dir,
        data_in => ACC_reg, 
        result => res_shift
    );

    U_MUL: multiplier PORT MAP (
        clk => clk, 
        rst => rst, 
        start => c_start_mul,
        X_in => OP2_reg, 
        Y_in => ACC_reg,
        result => res_mul, 
        flags => flags_mul,
        ready => mul_ready_sig  
    );

    U_DIV: divider PORT MAP (
        clk => clk, 
        rst => rst, 
        start => c_start_div,
        X_dividend => ACC_reg, 
        Y_divisor => OP2_reg,
        quotient => res_div_q, 
        remainder => res_div_r,
        flags => flags_div,
        ready => div_ready_sig  
    );
    
process(c_mux_sel, res_arith, res_logic, res_shift, res_mul, res_div_q, opcode, flags_arith, flags_logic, flags_mul, flags_div)
    begin
        case c_mux_sel is
            when "00" => 
                final_result <= res_arith; 
                final_flags <= flags_arith;
            when "01" => 
                final_result <= res_logic; 
                final_flags <= flags_logic;
            when "10" => 
                final_result <= res_shift; 
                final_flags <= ZERO_7; 
            when "11" => 
                if opcode = "1010" then 
                    final_result <= res_mul; 
                    final_flags <= flags_mul;
                else 
                    final_result <= res_div_q; 
                    final_flags <= flags_div; 
                end if;
            when others => 
                final_result <= ZERO_32; 
                final_flags <= ZERO_7;   
        end case;
    end process;

    process(clk, rst)
    begin
        if rst = '1' then
            ACC_reg <= (others => '0'); 
            OP2_reg <= (others => '0'); 
            FLG_reg <= (others => '0');
            shift_delay <= '0';
            
        elsif rising_edge(clk) then
            if load_acc = '1' then ACC_reg <= acc_data_in; end if;
            if load_op2 = '1' then OP2_reg <= op2_data_in; end if;
            
            if load_acc = '0' then
                if start_op = '1' then
                    if c_mux_sel = "00" or c_mux_sel = "01" then 
                        ACC_reg <= final_result;
                        FLG_reg <= final_flags;
                    end if;
                end if;
                
                if start_op = '1' and c_mux_sel = "10" then
                    shift_delay <= '1'; 
                elsif shift_delay = '1' then
                    ACC_reg <= final_result;
                    shift_delay <= '0'; 
                end if;

                if c_mux_sel = "11" then 
                    if (opcode="1010" and mul_ready_sig='1') or (opcode="1011" and div_ready_sig='1') then
                        ACC_reg <= final_result;
                        FLG_reg <= final_flags;
                    end if;
                end if;
            end if;
        end if;
    end process;

    alu_result <= ACC_reg;
    alu_flags <= FLG_reg;
    busy <= c_start_mul OR c_start_div OR c_shift_en;
end Behavioral;