

--DIES IST EIN KI BEISPIEL


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity tb_squareRoot is
end entity;

architecture sim of tb_squareRoot is
    -- Component declaration deines squareRoot
    component squareRoot
        port (
            clock   : in  std_logic;
            reset   : in  std_logic;
            start   : in  std_logic;
            value   : in  std_logic_vector(9 downto 0);
            roundup : in  std_logic;
            done    : out std_logic;
            result  : out std_logic_vector(9 downto 0)
        );
    end component;

    signal clock   : std_logic := '0';
    signal reset   : std_logic := '1';
    signal start   : std_logic := '0';
    signal value   : std_logic_vector(9 downto 0) := (others=>'0');
    signal roundup : std_logic := '0';
    signal done    : std_logic;
    signal result  : std_logic_vector(9 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin
    DUT: squareRoot port map (clock, reset, start, value, roundup, done, result);

    clock <= not clock after CLK_PERIOD/2;

    stim_proc: process
        file golden_file : text open read_mode is "../golden reference/golden_reference_squareroot.txt";
        variable line_buf : line;
        variable v_value, v_roundup, v_expected : integer;
        variable errors : integer := 0;
    begin
        reset <= '0';
        wait for 100 ns;
        reset <= '1';
        wait for CLK_PERIOD*5;

        while not endfile(golden_file) loop
            readline(golden_file, line_buf);
            read(line_buf, v_value);
            read(line_buf, v_roundup);
            read(line_buf, v_expected);

            value   <= std_logic_vector(to_unsigned(v_value, 10));
            roundup <= std_logic'val(v_roundup);   -- '0' or '1'

            start <= '1';
            wait for CLK_PERIOD;
            start <= '0';

            -- Warte bis done = '1' (je nach deiner Implementierung evtl. mehrere Takte)
            wait until done = '1';

            if to_integer(unsigned(result)) /= v_expected then
                report "FEHLER bei value=" & integer'image(v_value) &
                       " roundup=" & integer'image(v_roundup) &
                       "  erwartet=" & integer'image(v_expected) &
                       "  erhalten=" & integer'image(to_integer(unsigned(result)))
                    severity error;
                errors := errors + 1;
            end if;

            wait for CLK_PERIOD * 2;   -- kleine Pause zwischen Tests
        end loop;

        report "Test abgeschlossen. Anzahl Fehler: " & integer'image(errors);
        wait;
    end process;

end architecture;