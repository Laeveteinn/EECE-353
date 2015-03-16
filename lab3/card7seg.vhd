LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY Card7Seg IS
	PORT(
		card : IN  STD_LOGIC_VECTOR(3 DOWNTO 0); -- value of card
		seg7 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)  -- 7-seg LED pattern
	);
END;

ARCHITECTURE Behavioural OF Card7Seg IS
BEGIN
	PROCESS(card)
	BEGIN
		CASE card IS
			WHEN "0000" => seg7 <= "1111111";
			WHEN "0001" => seg7 <= "0001000";
			WHEN "0010" => seg7 <= "0100100";
			WHEN "0011" => seg7 <= "0110000";
			WHEN "0100" => seg7 <= "0011001";
			WHEN "0101" => seg7 <= "0010010";
			WHEN "0110" => seg7 <= "0000010";
			WHEN "0111" => seg7 <= "1111000";
			WHEN "1000" => seg7 <= "0000000";
			WHEN "1001" => seg7 <= "0010000";
			WHEN "1010" => seg7 <= "1000000";
			WHEN "1011" => seg7 <= "1110000";
			WHEN "1100" => seg7 <= "0011000";
			WHEN "1101" => seg7 <= "0001001";
			WHEN OTHERS => seg7 <= "1111111";
		END CASE;
	END PROCESS;
			
END Behavioural;