LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY DealCard IS
	PORT(
		clk     : IN STD_LOGIC;
		rst     : IN STD_LOGIC;
		
		newCard : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END;

ARCHITECTURE Behavioural OF DealCard IS
BEGIN
	PROCESS(clk, rst)
	VARIABLE counter : integer := 1;
	BEGIN
		IF(rst = '0') THEN
			counter := 1;
		ELSIF (RISING_EDGE(clk)) THEN
			CASE counter IS
				WHEN 1      => newCard <= "0001";
				WHEN 2      => newCard <= "0010";
				WHEN 3      => newCard <= "0011";
				WHEN 4      => newCard <= "0100";
				WHEN 5      => newCard <= "0101";
				WHEN 6      => newCard <= "0110";
				WHEN 7      => newCard <= "0111";
				WHEN 8      => newCard <= "1000";
				WHEN 9      => newCard <= "1001";
				WHEN 10     => newCard <= "1010";
				WHEN 11 	   => newCard <= "1011";
				WHEN 12 	   => newCard <= "1100";
				WHEN OTHERS => newCard <= "1101";
			END CASE;
			
			IF (counter >= 13) THEN 
					counter := 1;
			ELSE
				counter := counter + 1;
			END IF;
		END IF;
	END PROCESS;
END Behavioural;