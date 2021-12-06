library ieee;
use ieee.std_logic_1164.all;

entity testbenchTL is
end testbench;

architecture test of testbenchTL is
	component controller is
		port(
			clr: in std_logic;
			clk: in std_logic
		);
	end component;
	
	signal clk : std_logic := '0';
	signal clr : std_logic := '0';
	constant clk_period : time := 1 ns;
begin
	
	UUT : controller port map(clr, clk);
	
	clk_process :process
	begin
		clk <= '0';
		wait for clk_period/2;  --for 0.5 ns signal is '0'.
		clk <= '1';
		wait for clk_period/2;  --for next 0.5 ns signal is '1'.
	end process;
end test;