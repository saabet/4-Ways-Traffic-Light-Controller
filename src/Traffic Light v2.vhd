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
	signal PS, NS : states;
	
	type tipe_lampu is (RED, GREEN, YELLOW);
	signal N,W,E,S : tipe_lampu; -- N for North, E for East, S for South, W for West.
	

begin --architecture

	-- sequential circuit to determine present state
	seq: process (clr, timeout, clk, NS)
	begin
	
		if clr = '1' then
			PS <= S0;
		elsif timeout = '1' and rising_edge(clk) then
			PS <= NS;
		end if;
		
    end process;

    -- combinational circuit which maps present state to correspongind lights
    comb: process (PS)
    begin
        Tl <= '0'; Ts <= '0';
        case PS is
            when S0 =>
                -- NW yellow and all others RED
				N <= YELLOW; E <= RED;
				W <= YELLOW; S <= RED;

                Ts <= '1'; -- start timer
				NS <= S1;  -- Next State
            
            when S1 =>
                -- N - green, and all others RED
				N <= GREEN; E <= RED; 
				S <= RED;   W <= RED;
				
                Tl <= '1'; -- start timer		
				NS <= S2;  -- Next State
				
            when S2 =>
                -- NE yellow and all others RED
                N <= YELLOW; S <= RED;
				E <= YELLOW; W <= RED;

                Ts <= '1'; -- start timer
				NS <= S3;  -- Next State
				
            when S3 =>
                -- E - green, and all others RED
				E <= GREEN; N <= RED;
				S <= RED;	W <= RED;

                Tl <= '1'; -- start timer
				NS <= S4;  -- Next State
				
            when S4 =>
                -- ES yellow and all others RED
				E <= YELLOW; N <= RED;
				S <= YELLOW; W <= RED;

                Ts <= '1'; -- start timer
				NS <= S5;  -- Next State
            
            when S5 =>
                -- S - green, and all others RED
				S <= GREEN; N <= RED;
				E <= RED;	W <= RED;

                Tl <= '1'; -- start timer
				NS <= S6;  -- Next State
				
            when S6 =>
                -- SW yellow and all others RED
				S <= YELLOW; N <= RED;
				W <= YELLOW; E <= RED;

                Ts <= '1'; -- start timer
				NS <= S7;  -- Next State
            
            when S7 =>
                -- W - green, and all others RED
				W <= GREEN; N <= RED;
				E <= RED;	S <= RED;

                Tl <= '1'; -- start timer
				NS <= S0;  -- Next State

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
