-- ==================================================================================
--  File:         <squareRoot.vhdl>  -  <Square Root>
--  Author(s):    <Dirnberger / Group 10>
--  Created on:   <07.04.2026>
--  Project:      <Square Root>
-- ==================================================================================--


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity squareRoot is
port (
    clock   : in std_logic;
    reset   : in std_logic;
    start   : in std_logic;
    value   : in std_logic_vector(9 downto 0);
    roundup : in std_logic;
    done    : out std_logic;
    result  : out std_logic_vector(9 downto 0)
);
end entity;


architecture rtl of squareRoot is
    type state_type is (IDLE, INIT, CHECK, UPDATE, SHIFT, ROUND, DONE);
    signal s_state, s_next_state : s_state_type;
    signal s_root      : unsigned(9 downto 0);
    signal s_remainder : unsigned(9 downto 0);
    signal s_mask      : unsigned(9 downto 0);
    signal s_root_next, s_remainder_next, s_mask_next : unsigned(9 downto 0);

begin

-- Flip Flop
process(clock, reset)
begin
    if reset = '1' then
        s_state <= IDLE;
    elsif rising_edge(clock) then
        s_state <= s_next_state;
        s_root <= s_root_next;
        s_remainder <= s_remainder_next;
        s_mask <= s_mask_next;
    end if;
end process;


-- Transition Logic
process(s_state, start, s_mask, s_remainder, s_root, roundup)
begin
    s_next_state <= s_state;

    case s_state is

        when IDLE => if start = '1' then
                s_next_state <= INIT;
            end if;

        when INIT => s_next_state <= CHECK;

        when CHECK => if s_mask = 0 then
                s_next_state <= ROUND;
                    else
                s_next_state <= UPDATE;
            end if;
        when UPDATE => s_next_state <= SHIFT;
        when SHIFT => s_next_state <= CHECK;
        when ROUND => s_next_state <= DONE;
        when DONE => s_next_state <= IDLE;
    end case;
end process;


-- Datapath Logic
process(s_state, value, s_root, s_remainder, s_mask, roundup)
begin
    s_root_next <= s_root;
    s_remainder_next <= s_remainder;
    s_mask_next <= s_mask;
    done <= '0';

    case s_state is
        when IDLE => null;
        when INIT =>
            s_root_next <= (others => '0');
            s_remainder_next <= unsigned(value);
            s_ mask_next <= to_unsigned(256, 10); -- 2^(10-2)
        when CHECK => null;
        when UPDATE =>
            if (s_root + s_mask) <= s_remainder then
                s_remainder_next <= s_remainder - (s_root + s_mask);
                s_root_next <= s_root + (s_mask sll 1);
            end if;
        when SHIFT =>
            s_root_next <= s_root_next srl 1;
            s_mask_next <= s_mask srl 2;
        when ROUND =>
            if (s_remainder > s_root) and (s roundup = '1') then
                s_root_next <= s_root + 1;
            end if;
        when DONE => done <= '1';
    end case;
end process;

--Output
result <= std_logic_vector(s_root);

end architecture;