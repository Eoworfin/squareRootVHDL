-- ==================================================================================
--  File:         <tb_square_root.vhdl>  -  <Square Root>
--  Author(s):    <Thomet / Group 10>
--  Created on:   <07.04.2026>
--  Project:      <Square Root>
-- ==================================================================================--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity squareRoot_tb is
end entity squareRoot_tb;

architecture tb of squareRoot_tb is

    -- component für DUT wie in LIFO Buffer
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

    -- DUT Signals
    signal s_clock     : std_logic;
    signal s_reset     : std_logic;
    signal s_start     : std_logic;
    signal s_value     : std_logic_vector(9 downto 0);
    signal s_roundup   : std_logic;
    signal s_done      : std_logic;
    signal s_result    : std_logic_vector(9 downto 0);

    -- Clock-Period
    constant CLK_PERIOD : time := 10 ns;

    -- Zähler für Statistik
    signal test_count     : integer;
    signal error_count    : integer;

    

begin

    -- DUT Instanziierung
    DUT: squareRoot
        port map (
            clock   => s_clock,
            reset   => s_reset,
            start   => s_start,
            value   => s_value,
            roundup => s_roundup,
            done    => s_done,
            result  => s_result
        );

    -- Clock Generator
    clk_process : process
    begin
        while true loop
            s_clock <= '0';
            wait for clk_period/2;
            s_clock <= '1';
            wait for clk_period/2;
        end loop;
    end process;

    -- Stimulus + Self-Checking Process
    stim_proc: process

        file golden_file : text open read_mode is "../golden reference/golden_reference_squareroot.txt";
        variable line_buf : line;
        variable v_value  : integer;
        variable v_round  : integer;
        variable v_exp    : integer;
        variable ok       : boolean;

        variable current_value  : unsigned(9 downto 0) := (others => '0');
        variable expected_res   : unsigned(9 downto 0) := (others => '0');
        variable current_round  : std_logic := '0';


    -- Helper Function to check square root value
    procedure sq_check(value : std_logic_vector;expected_value : std_logic_vector; round_bit : std_logic) is
        begin
            s_value   <= value;
            s_start   <= '1';
            s_roundup <= round_bit;
            wait for CLK_PERIOD;
            s_start <= '0';
            -- Warte auf done
            wait until s_done = '1' for 20*CLK_PERIOD;
            assert s_done = '1'
                report "Timeout: done kam nicht! (value=" & integer'image(v_value) & ")"
                severity failure;

            -- Ergebnis vergleichen
            if s_result /= expected_value then
                error_count <= error_count + 1;
                report "FEHLER bei value=" & integer'image(v_value) &
                        "  roundup=" & integer'image(v_round) &
                        "  Erwartet=" & integer'image(v_exp) &
                        "  Erhalten=" & integer'image(to_integer(unsigned(s_result)))
                    severity error;
            end if;
        end procedure;


    begin
        report "=== SquareRoot Testbench (mask/root/remainder Algorithmus) gestartet ===" severity note;

        -- Reset
        s_reset <= '1';
        s_roundup <= '1';
        s_start <= '0';
        test_count <= 0;
        error_count <= 0;
        s_value <= "0000000000";
        wait for 5*CLK_PERIOD;
        s_reset <= '0';
        wait for 3*CLK_PERIOD;

        -- Datei zeilenweise einlesen
        while not endfile(golden_file) loop

            readline(golden_file, line_buf);

            -- Kommentare und leere Zeilen überspringen
            if line_buf'length = 0 or line_buf.all(1) = '#' then
                next;
            end if;

            -- Format: value roundup expected_result  (alle dezimal)
            read(line_buf, v_value, ok);
            assert ok report "Fehler beim Lesen von value!" severity failure;

            read(line_buf, v_round, ok);
            assert ok report "Fehler beim Lesen von roundup!" severity failure;

            read(line_buf, v_exp, ok);
            assert ok report "Fehler beim Lesen von expected_result!" severity failure;

            current_value := to_unsigned(v_value, 10);
            current_round := '1' when v_round /= 0 else '0';
            expected_res  := to_unsigned(v_exp, 10);

            test_count <= test_count + 1;

            -- Warte bis DUT idle ist
            wait until s_done = '0' for 20*CLK_PERIOD;

            -- Stimulus anlegen
            sq_check(std_logic_vector(current_value),std_logic_vector(expected_res),std_logic(current_round));

            -- Kurze Pause zwischen den Tests
            wait for 2*CLK_PERIOD;

        end loop;

        -- Abschlussbericht
        if error_count = 0 then
            report "=== TEST ERFOLGREICH ABGESCHLOSSEN! ===" & lf &
                   "  Getestete Vektoren : " & integer'image(test_count) & lf &
                   "  Fehler             : 0" severity note;
        else
            report "=== TEST MIT FEHLERN ABGESCHLOSSEN! ===" & lf &
                   "  Getestete Vektoren : " & integer'image(test_count) & lf &
                   "  Fehler             : " & integer'image(error_count) severity error;
        end if;

        wait;

    end process;

end architecture tb;