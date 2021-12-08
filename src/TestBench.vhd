library ieee;
use ieee.std_logic_1164.all;

entity testbenchTL is
end testbenchTL;

architecture test of testbenchTL is
	component controller is
		port(
			clr : in std_logic;
			clk : in std_logic;

			North : out std_logic_vector(2 downto 0);
			East  : out std_logic_vector(2 downto 0);
			South : out std_logic_vector(2 downto 0);
			West  : out std_logic_vector(2 downto 0)
		);
	end component;

	component decoder is
		port(
			clk      : in std_logic;
			bcd_in   : in std_logic_vector(3 downto 0);  -- 4 bit BCD input
			segment7 : out std_logic_vector(6 downto 0)  -- 7 bit decoded output.
		);
	end component;
	
	signal clk : std_logic := '0';
	signal clr : std_logic := '0';

	signal North : std_logic_vector(2 downto 0) := "000";
	signal East  : std_logic_vector(2 downto 0) := "000";
	signal South : std_logic_vector(2 downto 0) := "000";
	signal West  : std_logic_vector(2 downto 0) := "000";

	signal counter_clk : integer := 0;
	constant clk_period : time := 1 ns;
begin
	
	UUT : controller port map(clr, clk, North, East, South, West);
	
	test_process : process
	begin
		clk <= '0';
		wait for clk_period/2;  --for 0.5 ns signal is '0'.
		clk <= '1';
		counter_clk <= counter_clk + 1; --count the clock cycle.
		wait for clk_period/2;  --for next 0.5 ns signal is '1'.
		
		if(counter_clk = 35) then -- change clr to 1 in state S3 to reset state back
			clr <= '1';
			assert North = "001" report "Output tidak sesuai!" severity warning;
			assert East  = "100" report "Output tidak sesuai!" severity warning;
			assert South = "001" report "Output tidak sesuai!" severity warning;
			assert West  = "001" report "Output tidak sesuai!" severity warning;
		
		elsif(counter_clk = 36) then -- change clr to 0, state
			clr <= '0';
			assert North = "010" report "Output tidak sesuai!" severity warning;
			assert East  = "001" report "Output tidak sesuai!" severity warning;
			assert South = "001" report "Output tidak sesuai!" severity warning;
			assert West  = "010" report "Output tidak sesuai!" severity warning;

		elsif(counter_clk = 45) then
			clr <= '1';
			assert North = "100" report "Output tidak sesuai!" severity warning;
			assert East  = "001" report "Output tidak sesuai!" severity warning;
			assert South = "001" report "Output tidak sesuai!" severity warning;
			assert West  = "001" report "Output tidak sesuai!" severity warning;

		elsif(counter_clk = 55) then
			clr <= '0';
			assert North = "010" report "Output tidak sesuai!" severity warning;
			assert East  = "001" report "Output tidak sesuai!" severity warning;
			assert South = "001" report "Output tidak sesuai!" severity warning;
			assert West  = "010" report "Output tidak sesuai!" severity warning;

		elsif(counter_clk = 100) then
			wait;
		end if;
	end process;
end architecture;