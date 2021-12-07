-- 4 ways traffic light controller

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity controller is
	port(
		clr : in std_logic; -- clear all outputs
		clk : in std_logic;
		
		--output port for each direction
		-- 100 = GREEN, 010 = YELLOW, 001 = RED
		North : out std_logic_vector(2 downto 0);
		East  : out std_logic_vector(2 downto 0);
		South : out std_logic_vector(2 downto 0);
		West  : out std_logic_vector(2 downto 0)
	);
end controller; 

architecture arch of controller is

	--component decoder is
	--	port(
	--		clk      : in std_logic;
	--		bcd_in   : in std_logic_vector(3 downto 0);  -- 4 bit BCD input
	--		segment7 : out std_logic_vector(6 downto 0)  -- 7 bit decoded output.
	--	);
	--end component;

	-- used in timer to generate delay
	constant longCount   : integer := 20; --count 20 clock pulses
	constant shortCount  : integer := 5; --count 5 clock pulses
	signal count : integer := 1; --counting the clock cycles

	-- variable pre_status: integer := 0;
	signal timeout   : std_logic := '0'; -- flag : '1' if timeout in any state
	signal Tl, Ts    : std_logic := '0'; -- signals to trigger timer function : Tl - long time, Ts - short time
	
	--state declaration using type
	type states is (S0, S1, S2, S3, S4, S5, S6, S7);
	signal PS, NS : states;
	
	--lamp declaration using type
	type tipe_lampu is (RED, GREEN, YELLOW);
	signal N,E,S,W : tipe_lampu; -- N for North, E for East, S for South, W for West.
	
	--signal inBCDRed_puluhan   : std_logic_vector(3 downto 0);  --input BCD Red
	--signal inBCDRed_satuan    : std_logic_vector(3 downto 0);  --input BCD Red
	--signal inBCDGreen_puluhan : std_logic_vector(3 downto 0);  --input BCD Green
	--signal inBCDGreen_satuan  : std_logic_vector(3 downto 0);  --input BCD Green
	--														   
	--signal outBCDRed_puluhan   : std_logic_vector(6 downto 0); --output 7 segment Red
	--signal outBCDRed_satuan    : std_logic_vector(6 downto 0); --output 7 segment Red
	--signal outBCDGreen_puluhan : std_logic_vector(6 downto 0); --output 7 segment Green
	--signal outBCDGreen_satuan  : std_logic_vector(6 downto 0); --output 7 segment Green
	

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
    comb: process (PS, count)
    begin
        Tl <= '0'; Ts <= '0';
		if(clr = '1') then -- yang terjadi saat tombol clr ditekan, NS akan kembali ke S0
			NS <= S0;
		end if;
        case PS is
            when S0 =>
                -- NW yellow and all others RED
				N <= YELLOW; North <= "010";
				E <= RED; 	 East  <= "001";
				S <= RED; 	 South <= "001";
				W <= YELLOW; West  <= "010";

                Ts <= '1'; -- start timer
				if(count = shortCount) then
					NS <= S1;  -- Next State
				end if;
            
            when S1 =>
                -- N - green, and all others RED
				N <= GREEN; North <= "100";
				E <= RED; 	East  <= "001";
				S <= RED;	South <= "001";
				W <= RED;	West  <= "001";
				
                Tl <= '1'; -- start timer		
				if(count = longCount) then
					NS <= S2;  -- Next State
				end if;
				
            when S2 =>
                -- NE yellow and all others RED
                N <= YELLOW; North <= "010";
				E <= YELLOW; East  <= "010";
				S <= RED;	 South <= "001";
				W <= RED;	 West  <= "001";
				
                Ts <= '1'; -- start timer
				if(count = shortCount) then
					NS <= S3;  -- Next State
				end if;
				
            when S3 =>
                -- E - green, and all others RED
				N <= RED;	North <= "001";
				E <= GREEN; East  <= "100";
				S <= RED;	South <= "001";
				W <= RED;	West  <= "001";

                Tl <= '1'; -- start timer
				if(count = longCount) then
					NS <= S4;  -- Next State
				end if;
				
            when S4 =>
                -- ES yellow and all others RED
				E <= YELLOW; East  <= "010";
				N <= RED;  	 North <= "001";
				S <= YELLOW; South <= "010";
				W <= RED; 	 West  <= "001";

                Ts <= '1'; -- start timer
				if(count = shortCount) then
					NS <= S5;  -- Next State
				end if;
            
            when S5 =>
                -- S - green, and all others RED
				S <= GREEN; South <= "100";
				N <= RED; 	North <= "001";
				E <= RED; 	East  <= "001";
				W <= RED; 	West  <= "001";

                Tl <= '1'; -- start timer
				if(count = longCount) then
					NS <= S6;  -- Next State
				end if;
				
            when S6 =>
                -- SW yellow and all others RED
				S <= YELLOW; South <= "010";
				N <= RED; 	 North <= "001";
				W <= YELLOW; West  <= "010";
				E <= RED; 	 East  <= "001";

                Ts <= '1'; -- start timer
				if(count = shortCount) then
					NS <= S7;  -- Next State
				end if;
            
            when S7 =>
                -- W - green, and all others RED
				W <= GREEN; West  <= "100";
				N <= RED; 	North <= "001";
				E <= RED; 	East  <= "001";
				S <= RED; 	South <= "001";

                Tl <= '1'; -- start timer
				if(count = longCount) then
					NS <= S0;  -- Next State
				end if;

        end case;
    end process;

    -- timer process
    timer: process(Tl, Ts, clk, clr)
	
    begin
        timeout <= '0';
		if clr = '1' then
			count <= 1; -- when clr 1, counter will stay at 1.
		
        elsif Tl = '1' then
			if rising_edge(clk) then
				count <= count + 1;
				if(count = longCount) then
					count <= 1;
				end if;
			end if;
		timeout <= '1';

        elsif Ts = '1' then
			if rising_edge(clk) then
			   count <= count + 1;
				if(count = shortCount) then
					count <= 1;
				end if;
			end if;
		timeout <= '1';
                
        end if;
    end process;
	
	--bcdCounter : process(count, Tl, Ts)
	--begin
	--	if (tipe_lampu = GREEN) then
	--		if(count = 1) then
	--			inBCDGreen_puluhan <= "0010";
	--		elsif(count > 1 and count < 12) then	
	--			inBCDGreen_puluhan <= "0001";
	--		else
	--			inBCDGreen_puluhan <= "0010";
	--		end if;
	--		
	--		case count is
	--			when 1 =>
	--				inBCDGreen_satuan <= "0000"; -- 20
	--			when 2 =>
	--				inBCDGreen_satuan <= "1001"; -- 19
	--			when 3 =>
	--				inBCDGreen_satuan <= "1000"; -- 18
	--			when 4 =>
	--				inBCDGreen_satuan <= "0111"; -- 17
	--			when 5 =>
	--				inBCDGreen_satuan <= "0110"; -- 16
	--			when 6 =>
	--				inBCDGreen_satuan <= "0101"; -- 15
	--			when 7 =>
	--				inBCDGreen_satuan <= "0100"; -- 14
	--			when 8 =>
	--				inBCDGreen_satuan <= "0011"; -- 13
	--			when 9 =>
	--				inBCDGreen_satuan <= "0010"; -- 12
	--			when 10 =>
	--				inBCDGreen_satuan <= "0001"; -- 11
	--			when 11 =>
	--				inBCDGreen_satuan <= "0000"; -- 10
	--			when 12 =>
	--				inBCDGreen_satuan <= "1001"; -- 09
	--			when 13 =>
	--				inBCDGreen_satuan <= "1000"; -- 08
	--			when 14 =>
	--				inBCDGreen_satuan <= "0111"; -- 07
	--			when 15 =>
	--				inBCDGreen_satuan <= "0110"; -- 06
	--			when 16 =>
	--				inBCDGreen_satuan <= "0101"; -- 05
	--			when 17 =>
	--				inBCDGreen_satuan <= "0100"; -- 04
	--			when 18 =>
	--				inBCDGreen_satuan <= "0011"; -- 03
	--			when 19 =>
	--				inBCDGreen_satuan <= "0010"; -- 02
	--			when 20 =>
	--				inBCDGreen_satuan <= "0001"; -- 01
	--		end case;
	--	end if;
	--end process;
end arch ;
