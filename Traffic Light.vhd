-- 4 way traffic light control

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- port definition
-- clr: clears all outputs
-- mode: '0' - auto, '1' - manual
-- switch: manual mode direction selector: E-W-N-S order
-- green, yellow, red: lights in 4 ways E-W-N-S order
-- zebraRed, zebraGreen: zebra crossing lights EW-NS order

entity controller is

    port(
		clr: in std_logic;
		clk: in std_logic;
		green: out std_logic_vector(3 downto 0); --3: N, 2: E, 1: S, 0: W
		yellow: out std_logic_vector(3 downto 0);
		red: out std_logic_vector(3 downto 0);
		 
end controller;


architecture arch of controller is

    -- used in timer to generate delay
    constant longCount   : integer := 70; --count 20 clock pulses
    constant shortCount  : integer := 5; --count 5 clock pulses

    signal state: integer range 0 to 7;
    signal timeout   : std_logic := '0'; -- flag : '1' if timeout in any state
    signal Tl, Ts    : std_logic := '0'; -- signals to trigger timer function : Tl - long time, Ts - short time

begin --architecture

    -- sequential circuit to determine present state
    seq: process (clr, timeout, clk)
    begin
	
		if clr = '1' then
			state <= 0;
		elsif timeout = '1' and rising_edge(clk) then
			state <= (state + 1) mod 8;
		end if;

    end process;

    -- combinational circuit which maps present state to correspongind lights
    comb: process (state)
    begin
        Tl <= '0'; Tm <= '0'; Ts <= '0';
        case state is
            when 0 =>
                -- NW yellow and all others RED
				yellow(3) <= '1'; red(3) <= '0'; -- N
				yellow(0) <= '1'; red(0) <= '0'; -- W
				yellow(2 downto 1) <= "00"; red(2 downto 1) <= "11"; --ES
                green(3 downto 0) <= "0000";

                -- start timer
                Ts <= '1';
            
            when 1 =>
                -- N - green, and all others RED
                green(3) <= '1'; red(3) <= '0';	-- N
				green(2 downto 0) <= "000"; red(2 downto 0) <= "111"; --ESW
				yellow(3 downto 0) <= "0000";

                -- start timer
                Tl <= '1';
            
            when 2 =>
                -- NE yellow and all others RED
                yellow(3 downto 2) <= "11"; red(3 downto 2) <= "00"; -- NE
                yellow(1 downto 0) <= "00"; red(1 downto 0) <= "11"; -- SW
                green(3 downto 0) <= "0000";

                -- start timer
                Ts <= '1';
            
            
            when 3 =>
                -- E - green, and all others RED
				green(3) <= '0'; red(3) <= '1';
                green(2) <= '1'; red(2) <= '0';
				green(1 downto 0) <= "00"; red(1 downto 0) <= "11";
				yellow(3 downto 0) <= "0000";

                -- start timer
                Tl <= '1';

            when 4 =>
                -- ES yellow and all others RED
				yellow(3) <= '0'; red(3) <= '0'; --N
                yellow(2 downto 1) <= "11"; red(2 downto 1) <= "00"; -- ES
                yellow(0) <= '0'; red(0) <= '1'; -- W
                green(3 downto 0) <= "0000";

                -- start timer
                Ts <= '1';
            
            when 5 =>
                -- S - green, and all others RED
				green(3 downto 2) <= "00"; red(3 downto 2) <= "11";
                green(1) <= '1'; red(1) <= '0';
				green(0) <= '0'; red(0) <= '1';
				yellow(3 downto 0) <= "0000";

                -- start timer
                Tl <= '1';

            when 6 =>
                -- SW yellow and all others RED
				yellow(3 downto 2) <= "11"; red(3 downto 2) <= "00"; --NE
                yellow(1 downto 0) <= "00"; red(1 downto 0) <= "11"; -- SW
                green(3 downto 0) <= "0000";

                -- start timer
                Ts <= '1';
            
            when 7 =>
                -- W - green, and all others RED
				green(3 downto 1) <= "000"; red(3 downto 1) <= "111";
				green(0) <= '1'; red(0) <= '0';
				yellow(3 downto 0) <= "0000";

                -- start timer
                Tl 	  <= '1';
				
				--back to state 0
				state <= '0';

        end case;
    end process;

    -- timer process
    timer: process(Tl, Ts, clk)
		variable count : integer;
    begin
        timeout <= '0';
        count := 0;
        if Tl = '1' then
            for i in 1 to longCount loop
                if rising_edge(clk) and count <= longCount then
                    count := count + 1;
                end if;
        end loop;
		timeout <= '1';
        -- Tl <= '0';

        elsif Ts = '1' then
            -- timeout <= '0';
            -- count := 0;
            for i in 1 to shortCount loop
                if rising_edge(clk) and count <= shortCount then
                    count := count +1;
                end if;
        end loop;
		  timeout <= '1';
        -- Ts <= '0';
                
        end if;

    end process;

end arch ; -- arch