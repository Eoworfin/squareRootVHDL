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

    -- Interne Register
    signal radicand_reg : unsigned(19 downto 0);   -- 10 Bit Input + 10 Bit für Iterationen
    signal root_reg     : unsigned(9 downto 0);
    signal remain_reg   : unsigned(11 downto 0);
    signal step_counter : unsigned(2 downto 0);    -- 0 bis 4 (5 Iterationen)

    signal done_int     : std_logic := '0';
    signal start_prev   : std_logic := '0';        -- für exakte 1-Takt-Erkennung von start

begin

    done <= done_int;

    process(clock, reset)
        variable trial      : unsigned(11 downto 0);
        variable new_remain : unsigned(11 downto 0);
        variable new_root   : unsigned(9 downto 0);
    begin
        if reset = '1' then
            state        <= IDLE;
            radicand_reg <= (others => '0');
            root_reg     <= (others => '0');
            remain_reg   <= (others => '0');
            step_counter <= (others => '0');
            done_int     <= '0';
            result       <= (others => '0');
            start_prev   <= '0';

        elsif rising_edge(clock) then

            start_prev <= start;
            done_int   <= '0';                     -- done ist standardmäßig '0'

            case state is

                -- ====================== IDLE ======================
                when IDLE =>
                    if start = '1' and start_prev = '0' then   -- Nur auf steigende Flanke von start reagieren
                        -- Input nur hier einlesen
                        radicand_reg <= unsigned(value) & "0000000000";  -- 10 Bit + 10 Nullen
                        root_reg     <= (others => '0');
                        remain_reg   <= (others => '0');
                        step_counter <= (others => '0');
                        state        <= CALC;
                    end if;

                -- ====================== CALC ======================
                when CALC =>
                    -- Trial berechnen: (remain << 2) + 1
                    trial := (remain_reg(9 downto 0) & "00") + 1;

                    if remain_reg >= trial then
                        new_remain := remain_reg - trial;
                        new_root   := root_reg(8 downto 0) & '1';
                    else
                        new_remain := remain_reg;
                        new_root   := root_reg(8 downto 0) & '0';
                    end if;

                    -- Nächste 2 Bits vom Radicand in Remainder schieben
                    remain_reg   <= new_remain(9 downto 0) & radicand_reg(19 downto 18);
                    root_reg     <= new_root;
                    radicand_reg <= radicand_reg(17 downto 0) & "00";

                    step_counter <= step_counter + 1;

                    -- Nach genau 5 Iterationen fertig
                    if step_counter = 4 then
                        -- Rounding
                        if roundup = '1' then
                            if new_remain >= (new_root + 1) then   -- Round half up
                                new_root := new_root + 1;
                            end if;
                        end if;

                        result   <= std_logic_vector(new_root);
                        done_int <= '1';      -- done genau 1 Takt lang
                        state    <= IDLE;
                    end if;

            end case;
        end if;
    end process;

end architecture rtl;