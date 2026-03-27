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

    type state_type is (IDLE, CALC);
    signal state : state_type := IDLE;

    -- Interne Signale 
    signal root_reg      : unsigned(15 downto 0) := (others => '0');
    signal remainder_reg : unsigned(15 downto 0) := (others => '0');
    signal mask_reg      : unsigned(15 downto 0) := (others => '0');
    signal bit_counter   : integer range 0 to 8 := 0;   -- max. 8 Iterationen für 10-Bit-Eingang

    signal done_int      : std_logic := '0';

begin

    done <= done_int;

    process(clock, reset)
        variable root_temp      : unsigned(15 downto 0);
        variable remainder_temp : unsigned(15 downto 0);
        variable mask_temp      : unsigned(15 downto 0);
    begin
        if reset = '1' then
            state         <= IDLE;
            root_reg      <= (others => '0');
            remainder_reg <= (others => '0');
            mask_reg      <= (others => '0');
            bit_counter   <= 0;
            done_int      <= '0';
            result        <= (others => '0');

        elsif rising_edge(clock) then

            done_int <= '0';   -- Standard: done nur einen Takt aktiv

            case state is

                when IDLE =>
                    if start = '1' then
                        remainder_reg <= resize(unsigned(value), 16);   -- value auf 16 Bit erweitern
                        root_reg      <= (others => '0');
                        mask_reg      <= to_unsigned(2**(16-2), 16);    -- mask = 2**14 = 16384
                        bit_counter   <= 0;
                        state         <= CALC;
                    end if;

                when CALC =>
                    root_temp      := root_reg;
                    remainder_temp := remainder_reg;
                    mask_temp      := mask_reg;

                    -- Eine Iteration des C-Algorithmus
                    if (root_temp + mask_temp) <= remainder_temp then
                        remainder_temp := remainder_temp - (root_temp + mask_temp);
                        root_temp      := root_temp + (mask_temp sll 1);   -- mask << 1
                    end if;

                    root_temp := root_temp srl 1;      -- root >>= 1
                    mask_temp := mask_temp srl 2;      -- mask >>= 2

                    -- Register aktualisieren
                    root_reg      <= root_temp;
                    remainder_reg <= remainder_temp;
                    mask_reg      <= mask_temp;

                    bit_counter <= bit_counter + 1;

                    -- Nach 8 Iterationen (genug für 10-Bit-Eingang) fertig
                    if bit_counter = 7 then
                        -- Rounding wie im C-Code
                        if (remainder_temp > root_temp) and (roundup = '1') then
                            root_temp := root_temp + 1;
                        end if;

                        -- Ergebnis ausgeben (nur untere 10 Bit, da entity 10 Bit hat)
                        result   <= std_logic_vector(resize(root_temp, 10));
                        done_int <= '1';
                        state    <= IDLE;
                    end if;

            end case;
        end if;
    end process;

end architecture rtl;