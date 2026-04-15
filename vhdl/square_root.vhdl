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
        clock   : in  std_logic;
        reset   : in  std_logic;
        start   : in  std_logic;
        value   : in  std_logic_vector(9 downto 0);
        roundup : in  std_logic;
        done    : out std_logic;
        result  : out std_logic_vector(9 downto 0)
    );
end entity squareRoot;

architecture rtl of squareRoot is

    type state_type is (IDLE, INIT, CALC, FINISH);
    signal state : state_type;

    signal root_reg      : unsigned(9 downto 0);
    signal remainder_reg : unsigned(9 downto 0);
    signal mask_reg      : unsigned(9 downto 0);

    signal done_reg      : std_logic; 
    signal result_reg    : unsigned(9 downto 0); 

    constant NR_OF_BITS : integer := 10;

begin

    done   <= done_reg;
    result <= std_logic_vector(result_reg);

    process(clock, reset)
        variable root_temp      : unsigned(9 downto 0);
        variable remainder_temp : unsigned(9 downto 0);
    begin
        if reset = '1' then
            state         <= IDLE;
            done_reg      <= '0';
            result_reg    <= (others => '0');
            root_reg      <= (others => '0');
            remainder_reg <= (others => '0');
            mask_reg      <= (others => '0');

        elsif rising_edge(clock) then

            done_reg <= '0';

            case state is

                when IDLE =>
                    if start = '1' then
                        remainder_reg <= unsigned(value);
                        state         <= INIT;
                    end if;

                when INIT =>
                    root_reg      <= (others => '0');
                    mask_reg      <= to_unsigned(1, 10) sll (NR_OF_BITS - 2);  -- 2^(8) = 256 bei 10 Bit
                    state         <= CALC;

                when CALC =>
                    root_temp      := root_reg;
                    remainder_temp := remainder_reg;

                    -- if ((root + mask) <= remainder)
                    if (root_temp + mask_reg) <= remainder_temp then
                        remainder_temp := remainder_temp - (root_temp + mask_reg);
                        root_temp      := root_temp + (mask_reg sll 1);   -- root += (mask << 1)
                    end if;

                    -- root >>= 1
                    root_temp := root_temp srl 1;

                    -- mask >>= 2
                    mask_reg <= mask_reg srl 2;

                    -- Update Register
                    root_reg      <= root_temp;
                    remainder_reg <= remainder_temp;

                    -- Schleife beenden, wenn mask nach Shift == 0
                    if (mask_reg srl 2) = 0 then
                        state <= FINISH;
                    end if;

                    when FINISH =>
                    if (roundup = '1') and (remainder_reg > root_reg) then
                        result_reg <= root_reg + 1;
                    else
                        result_reg <= root_reg;
                    end if;

                    done_reg <= '1';
                    state    <= IDLE;

                when others => state <= IDLE;

            end case;
        end if;
    end process;

end architecture rtl;