-- Your Names:  Xin (Rico) Wen
-- Your Student Numbers: 32458119
-- Your Lab Section:  L2G

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity converter_mult is
	port(
		-- slide switches	
		SW : in std_logic_vector(11 downto 0);

		-- 7-segment display
		HEX0 : out std_logic_vector(6 downto 0);
		HEX1 : out std_logic_vector(6 downto 0);
		HEX2 : out std_logic_vector(6 downto 0);
		HEX3 : out std_logic_vector(6 downto 0)
	);  
end converter_mult ;

architecture Behavioral of converter_mult is

component converter is
	port(
		-- slide switches	
		SW : in std_logic_vector(2 downto 0);  

		-- 7-segment display
		HEX0 : out std_logic_vector(6 downto 0)
	);  
end component ;

begin

conv1 : converter port map(SW(2 downto 0),HEX0);
conv2 : converter port map(SW(5 downto 3),HEX1);
conv3 : converter port map(SW(8 downto 6),HEX2);
conv4 : converter port map(SW(11 downto 9),HEX3);

end Behavioral;