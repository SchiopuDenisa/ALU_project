library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control_unit is
    Port (
        clk, rst : in STD_LOGIC;
        opcode : in STD_LOGIC_VECTOR (3 downto 0);
        start_op : in STD_LOGIC;
        ctrl_inv_x, ctrl_inv_y, ctrl_use_y, ctrl_cin : out STD_LOGIC;
        logic_op : out STD_LOGIC_VECTOR (1 downto 0);
        shift_dir, shift_en, start_mul, start_div : out STD_LOGIC;
        mux_sel : out STD_LOGIC_VECTOR (1 downto 0)
    );
end control_unit;

architecture Behavioral of control_unit is
begin
    process(opcode, start_op)
    begin
        -- Defaults
        ctrl_inv_x <= '0'; ctrl_inv_y <= '0'; ctrl_use_y <= '0'; ctrl_cin <= '0';
        logic_op <= "00"; shift_dir <= '0'; shift_en <= '0';
        start_mul <= '0'; start_div <= '0'; mux_sel <= "00";

        case opcode is
            when "0000" => -- ADD
                ctrl_use_y <= '1';
            when "0001" => -- SUB (X + NOT(Y) + 1)
                ctrl_inv_y <= '1'; ctrl_use_y <= '1'; ctrl_cin <= '1';
            when "0010" => -- INC (X + 1)
                ctrl_cin <= '1';
            when "0011" => -- DEC (X - 1) -> X + NOT(1) + 1
                ctrl_inv_y <= '1'; ctrl_use_y <= '1'; 
                ctrl_cin <= '1'; 
            when "0100" => -- NEG (NOT(X) + 1)
                ctrl_inv_x <= '1'; ctrl_cin <= '1';
            when "0101" => -- AND
                mux_sel <= "01"; logic_op <= "00";
            when "0110" => -- OR
                mux_sel <= "01"; logic_op <= "01";
            when "0111" => -- NOT
                mux_sel <= "01"; logic_op <= "10";
            when "1000" => -- ROL
                mux_sel <= "10"; shift_dir <= '0'; shift_en <= start_op;
            when "1001" => -- ROR
                mux_sel <= "10"; shift_dir <= '1'; shift_en <= start_op;
            when "1010" => -- MUL
                mux_sel <= "11"; start_mul <= start_op;
            when "1011" => -- DIV
                mux_sel <= "11"; start_div <= start_op;
            when others => null;
        end case;
    end process;
end Behavioral;