-- 4 way traffic light control

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- port definition
-- clr: clears all outputs
-- green, yellow, red: lights in 4 ways E-W-N-S order
-- zebraRed, zebraGreen: zebra crossing lights EW-NS order

entity controller is

	port(
		clr: in std_logic;
		clk: in std_logic
	);
end controller;


architecture arch of controller is

	-- used in timer to generate delay
	constant longCount   : integer := 20; --count 20 clock pulses
	constant shortCount  : integer := 5; --count 5 clock pulses

	-- variable pre_status: integer := 0;
	signal timeout   : std_logic := '0'; -- flag : '1' if timeout in any state
	signal Tl, Ts    : std_logic := '0'; -- signals to trigger timer function : Tl - long time, Ts - short time
	
	type states is (S0, S1, S2, S3, S4, S5, S6, S7);
	signal state : states;
	
	type tipe_lampu is (RED, GREEN, YELLOW);
	signal N,W,E,S : tipe_lampu;
	
	signal PS, NS;

begin --architecture

	-- sequential circuit to determine present state
	seq: process (clr, timeout, clk, NS)
	begin
	
		if clr = '1' then
			PS <= PS;
		elsif timeout = '1' and rising_edge(clk) then
			PS <= NS;
		end if;
		
    end process;

    -- combinational circuit which maps present state to correspongind lights
    comb: process (state)
    begin
        Tl <= '0'; Ts <= '0';
        case PS is
            when S0 =>
                -- NW yellow and all others RED
				N, W <= YELLOW;
				E, S <= RED;

                -- start timer
                Ts <= '1';
            
            when S1 =>
                -- N - green, and all others RED
                N 		<= GREEN;
				E, S, W <= RED;

                -- start timer
                Tl <= '1';
            
            when S2 =>
                -- NE yellow and all others RED
                N, E <= YELLOW;
				S, W <= RED;

                -- start timer
                Ts <= '1';
            
            
            when S3 =>
                -- E - green, and all others RED
				E <= GREEN;
				N, S, W <= RED;

                -- start timer
                Tl <= '1';

            when S4 =>
                -- ES yellow and all others RED
				E, S <= YELLOW;
				N, W <= RED;

                -- start timer
                Ts <= '1';
            
            when S5 =>
                -- S - green, and all others RED
				S <= GREEN;
				N, E, W <= RED;

                -- start timer
                Tl <= '1';

            when S6 =>
                -- SW yellow and all others RED
				S, W <= YELLOW;
				N, E <= RED;

                -- start timer
                Ts <= '1';
            
            when S7 =>
                -- W - green, and all others RED
				W <= GREEN;
				N, E, S <= RED;

                -- start timer
                Tl 	  <= '1';
				
				--back to state 0
				state <= S0;

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

        elsif Ts = '1' then
            for i in 1 to shortCount loop
                if rising_edge(clk) and count <= shortCount then
                    count := count +1;
                end if;
        end loop;
		  timeout <= '1';
                
        end if;
    end process;
	
end arch ;