library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_execution_unit is
end tb_execution_unit;

architecture behavior of tb_execution_unit is

    component execution_unit
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
    end component;

    signal clk, rst, start_op, load_acc, load_op2, busy : STD_LOGIC := '0';
    signal opcode : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
    signal acc_data_in, op2_data_in : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    signal alu_result : STD_LOGIC_VECTOR (31 downto 0);
    signal alu_flags : STD_LOGIC_VECTOR (6 downto 0);

    constant clk_period : time := 10 ns;

   procedure verify_op(
        signal clk_s     : in std_logic;
        signal ld_acc    : out std_logic;
        signal ld_op2    : out std_logic;
        signal acc_bus   : out std_logic_vector(31 downto 0);
        signal op2_bus   : out std_logic_vector(31 downto 0);
        signal start_s   : out std_logic;
        signal op_s      : out std_logic_vector(3 downto 0);
        signal res_s     : in std_logic_vector(31 downto 0);
        
        op_code_in : in std_logic_vector(3 downto 0);
        val_acc_in : in std_logic_vector(31 downto 0);
        val_op2_in : in std_logic_vector(31 downto 0);
        exp_res_in : in std_logic_vector(31 downto 0);
        wait_cyc   : in integer;
        pulse_len  : in integer;
        test_msg   : in string
    ) is
    begin
        acc_bus <= val_acc_in;
        ld_acc <= '1'; wait for clk_period; ld_acc <= '0';
        
        op2_bus <= val_op2_in;
        ld_op2 <= '1'; wait for clk_period; ld_op2 <= '0';
        
        op_s <= op_code_in;
        start_s <= '1'; 
        wait for clk_period * pulse_len; 
        start_s <= '0';
        
        if wait_cyc > 0 then
            wait for clk_period * wait_cyc;
        else
            wait for clk_period;
        end if;
        
        assert res_s = exp_res_in
            report "FAIL: " & test_msg
            severity error;
            
        wait for 2 us; 
    end procedure;

begin

    uut: execution_unit PORT MAP (
        clk => clk, rst => rst, opcode => opcode, start_op => start_op,
        acc_data_in => acc_data_in, load_acc => load_acc,
        op2_data_in => op2_data_in, load_op2 => load_op2,
        alu_result => alu_result, alu_flags => alu_flags, busy => busy
    );

    clk_process :process begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;

    stim_proc: process
    begin
        rst <= '1'; wait for 50 ns; rst <= '0'; wait for clk_period;

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "0000", x"0000000A", x"00000010", x"0000001A", 2, 1, "ADD: 10 + 16");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "0000", x"00000006", x"0000000A", x"00000010", 2, 1, "ADD: 6 + 10");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "0000", x"FFFFFFFA", x"FFFFFFF0", x"FFFFFFEA", 2, 1, "ADD: -6 + (-16)");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "0000", x"7FFFFFFF", x"6FFFFFFF", x"EFFFFFFE", 2, 1, "ADD: Overflow Test");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "0001", x"0000000A", x"00000010", x"FFFFFFFA", 2, 1, "SUB: 10 - 16");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "0001", x"0000000A", x"00000012", x"FFFFFFF8", 2, 1, "SUB: 10 - 18");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "0001", x"80000000", x"00000002", x"7FFFFFFE", 2, 1, "SUB: Underflow Test");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "0010", x"0000000A", x"00000000", x"0000000B", 2, 1, "INC: 10 + 1");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "0010", x"80000002", x"00000000", x"80000003", 2, 1, "INC: Negative + 1");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "0011", x"FFFFFFF8", x"00000000", x"FFFFFFF7", 2, 1, "DEC: -8 - 1");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "0011", x"80000000", x"00000000", x"7FFFFFFF", 2, 1, "DEC: Min Int - 1");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "0100", x"0000000A", x"00000000", x"FFFFFFF6", 2, 1, "NEG: Negate 10");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "0100", x"FFFFFFF6", x"00000000", x"0000000A", 2, 1, "NEG: Negate -10");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "0101", x"0000000A", x"00000009", x"00000008", 2, 1, "AND: 10 & 9");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "0101", x"ABC500F1", x"0A536221", x"0A410021", 2, 1, "AND: Large Hex");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "0110", x"0000000A", x"0000000B", x"0000000B", 2, 1, "OR: 10 | 11");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "0110", x"ABC500F1", x"0A536221", x"ABD762F1", 2, 1, "OR: Large Hex");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "0111", x"0000000A", x"00000000", x"FFFFFFF5", 2, 1, "NOT: ~10");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "0111", x"FFFFFFF5", x"00000000", x"0000000A", 2, 1, "NOT: ~(-11)");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "1000", x"80000000", x"00000000", x"00000001", 3, 2, "ROL: MSB to LSB");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "1000", x"0000000B", x"00000000", x"00000016", 3, 2, "ROL: 11 << 1");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "1001", x"00000010", x"00000000", x"00000008", 3, 2, "ROR: 16 >> 1");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "1001", x"0000000B", x"00000000", x"80000005", 3, 2, "ROR: 11 >> 1 (Wrap)");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "1010", x"0000000A", x"00000006", x"0000003C", 45, 1, "MUL: 10 * 6");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "1010", x"FFFFFFF6", x"00000006", x"FFFFFFC4", 45, 1, "MUL: -10 * 6");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "1010", x"0000000A", x"FFFFFFFA", x"FFFFFFC4", 45, 1, "MUL: 10 * -6");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "1010", x"FFFFFFF6", x"FFFFFFFA", x"0000003C", 45, 1, "MUL: -10 * -6");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "1010", x"0000000A", x"00000000", x"00000000", 45, 1, "MUL: Zero");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "1010", x"7FFFFFFF", x"00000003", x"7FFFFFFD", 45, 1, "MUL: Overflow");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "1011", x"0000000C", x"00000006", x"00000002", 45, 1, "DIV: 12 / 6");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "1011", x"0000000C", x"00000005", x"00000002", 45, 1, "DIV: 12 / 5");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "1011", x"FFFFFFF4", x"00000005", x"FFFFFFFE", 45, 1, "DIV: -12 / 5");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "1011", x"0000000C", x"FFFFFFFB", x"FFFFFFFE", 45, 1, "DIV: 12 / -5");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "1011", x"FFFFFFF4", x"FFFFFFFB", x"00000002", 45, 1, "DIV: -12 / -5");

        verify_op(clk, load_acc, load_op2, acc_data_in, op2_data_in, start_op, opcode, alu_result,
            "1011", x"0000000C", x"00000000", x"00000000", 45, 1, "DIV: Divide by Zero");

        wait;
    end process;

end behavior;