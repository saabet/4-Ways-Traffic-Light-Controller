library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity decoder is
	port(
		clk      : in std_logic;
		bcd_in   : in std_logic_vector(3 downto 0);  -- 4 bit BCD input
		segment7 : out std_logic_vector(6 downto 0)  -- 7 bit decoded output.
	);
end decoder;
--'a' corresponds to MSB of segment7 and g corresponds to LSB of segment7.
architecture Behavioral of decoder is

begin
process (clk, bcd_in)
BEGIN
    if (rising_edge(clk)) then  
        -- 0 off 
        -- 1 on
        case  bcd is
            when "0000"=> segment7 <= "1111110";  -- '0'
            when "0001"=> segment7 <= "0110000";  -- '1'
            when "0010"=> segment7 <= "1101101";  -- '2'
            when "0011"=> segment7 <= "1111001";  -- '3'
            when "0100"=> segment7 <= "0110011";  -- '4'
            when "0101"=> segment7 <= "1011011";  -- '5'
            when "0110"=> segment7 <= "1011111";  -- '6'
            when "0111"=> segment7 <= "1110000";  -- '7'
            when "1000"=> segment7 <= "1111111";  -- '8'
            when "1001"=> segment7 <= "1111011";  -- '9'
			
            -- nothing is displayed when a number more than 9 is given as input.
            when others=> segment7 <= "0000000";
        end case;
    end if;

end process;

end Behavioral;