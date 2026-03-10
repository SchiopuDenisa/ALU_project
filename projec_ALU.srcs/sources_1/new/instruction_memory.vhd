library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instruction_memory is
    Port (
        addr        : in  STD_LOGIC_VECTOR(5 downto 0); 
        out_opcode  : out STD_LOGIC_VECTOR(3 downto 0);
        out_acc     : out STD_LOGIC_VECTOR(31 downto 0);
        out_op2     : out STD_LOGIC_VECTOR(31 downto 0)
    );
end instruction_memory;

architecture Behavioral of instruction_memory is

    type rom_type is array (0 to 38) of std_logic_vector(67 downto 0);
    
    constant ROM : rom_type := (
        "0000" & x"0000000A" & x"00000010",-- 0: ADD 10 + 16
        "0000" & x"00000006" & x"0000000A",-- 1: ADD 6 + 10
        "0000" & x"FFFFFFFA" & x"FFFFFFF0",-- 2: ADD -6 + (-16)
        "0000" & x"7FFFFFFF" & x"6FFFFFFF",-- 3: ADD Overflow Test
        "0001" & x"0000000A" & x"00000010",-- 4: SUB 10 - 16
        "0001" & x"0000000A" & x"00000012",-- 5: SUB 10 - 18
        "0001" & x"80000000" & x"00000002",-- 6: SUB Underflow Test
        "0010" & x"0000000A" & x"00000000",-- 7: INC 10 + 1
        "0010" & x"80000002" & x"00000000",-- 8: INC Negative + 1
        "0011" & x"FFFFFFF8" & x"00000000",-- 9: DEC -8 - 1
        "0011" & x"80000000" & x"00000000",-- 10: DEC Min Int - 1
        "0100" & x"0000000A" & x"00000000",-- 11: NEG 10
        "0100" & x"FFFFFFF6" & x"00000000",-- 12: NEG -10
        "0101" & x"0000000A" & x"00000009",-- 13: AND 10 & 9
        "0101" & x"ABC500F1" & x"0A536221",-- 14: AND Large Hex
        "0110" & x"0000000A" & x"0000000B",-- 15: OR 10 | 11
        "0110" & x"ABC500F1" & x"0A536221",-- 16: OR Large Hex
        "0111" & x"0000000A" & x"00000000",-- 17: NOT 10
        "0111" & x"FFFFFFF5" & x"00000000",-- 18: NOT -11
        "1000" & x"80000000" & x"00000001",-- 19: ROL MSB to LSB
        "1000" & x"0000000B" & x"00000001",-- 20: ROL 11 << 1
        "1001" & x"00000010" & x"00000001",-- 21: ROR 16 >> 1
        "1001" & x"0000000B" & x"00000001",-- 22: ROR 11 >> 1 
        "1010" & x"0000000A" & x"00000006",-- 23: MUL 10 * 6
        "1010" & x"FFFFFFF6" & x"00000006",-- 24: MUL -10 * 6
        "1010" & x"0000000A" & x"FFFFFFFA",-- 25: MUL 10 * -6
        "1010" & x"FFFFFFF6" & x"FFFFFFFA",-- 26: MUL -10 * -6
        "1010" & x"0000000A" & x"00000000",-- 27: MUL Zero
        "1010" & x"7FFFFFFF" & x"00000003",-- 28: MUL Overflow
        "1011" & x"0000000C" & x"00000006",-- 29: DIV 12 / 6
        "1011" & x"0000000C" & x"00000005",-- 30: DIV 12 / 5
        "1011" & x"FFFFFFF4" & x"00000005",-- 31: DIV -12 / 5
        "1011" & x"0000000C" & x"FFFFFFFB",-- 32: DIV 12 / -5
        "1011" & x"FFFFFFF4" & x"FFFFFFFB",-- 33: DIV -12 / -5
        "1011" & x"0000000C" & x"00000000",-- 34: DIV Divide by Zero
        others => (others => '0')
    );

    signal raw_data : std_logic_vector(67 downto 0);

begin
    raw_data <= ROM(to_integer(unsigned(addr)));
    out_opcode <= raw_data(67 downto 64);
    out_acc    <= raw_data(63 downto 32);
    out_op2    <= raw_data(31 downto 0);

end Behavioral;