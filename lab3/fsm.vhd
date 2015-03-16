LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY FSM IS
	PORT(
		clock 		 : IN STD_LOGIC;
		reset 		 : IN STD_LOGIC;

		nextStep     : IN STD_LOGIC; -- when true, it advances game to next step
		playerStands : IN STD_LOGIC; -- true if player wants to stand
		dealerStands : IN STD_LOGIC; -- true if dealerScore >= 17
		playerWins   : IN STD_LOGIC; -- true if playerScore >  dealerScore AND playerScore <= 21
		dealerWins   : IN STD_LOGIC; -- true if dealerScore >= playerScore AND dealerScore <= 21
		playerBust   : IN STD_LOGIC; -- true if playerScore > 21
		dealerBust   : IN STD_LOGIC; -- true if dealerScore > 21

		deal 			 : OUT STD_LOGIC;
		dealTo 		 : OUT STD_LOGIC;
		cardNum 		 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

		redLEDs   	 : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
		greenLEDs 	 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END;

ARCHITECTURE Behavioural OF FSM IS
BEGIN		
	PROCESS(clock, reset)
	VARIABLE state : BIT_VECTOR(2 DOWNTO 0) := "000";
	VARIABLE endGame : BIT_VECTOR(1 DOWNTO 0) := "00";
	VARIABLE pendingNextStep : BIT := '0';
	VARIABLE dealt : INTEGER := 0;
	BEGIN
		IF (reset = '0') THEN
			deal <= '0';
			redLEDs <= "000000000000000000";
			greenLEDs <= "00000000";
			state := "000";
			endGame := "00";
			pendingNextStep := '0';
			dealt := 0;
		ELSIF (RISING_EDGE(clock)) THEN
			IF (endGame = "00") THEN
				IF (nextStep = '0') THEN
					pendingNextStep := '1';
				ELSIF (pendingNextStep = '1') THEN
					pendingNextStep := '0';
					endGame := "01";
				END IF;
			ELSIF (endGame = "01") THEN
				IF (nextStep = '0') THEN
					pendingNextStep := '1';
				ELSIF (pendingNextStep = '1') THEN
					pendingNextStep := '0';
					
					IF (state = "000") THEN
						dealt := 0;
						state := "001";
					ELSIF (state = "001") THEN
						dealt := 0;
						state := "010";
					ELSIF (state = "010") THEN
						dealt := 0;
						
						IF (playerStands = '1') THEN
							state := "101";
						ELSE
							state := "011";
						END IF;
					ELSIF (state = "011") THEN
						dealt := 0;
						IF (playerStands = '1' OR playerBust = '1') THEN
							state := "101";
						ELSE
							state := "100";
						END IF;
					ELSIF (state = "100") THEN
						dealt := 0;
						state := "101";
					ELSIF (state = "101") THEN
						IF (dealerStands = '1') THEN
							endGame := "10";
						ELSE
							dealt := 0;
							state := "110";
						END IF;
					ELSIF (state = "110") THEN						
						IF (dealerStands = '1' OR dealerBust = '1') THEN
							endGame := "10";
						ELSE
							dealt := 0;
							state := "111";
						END IF;
					ELSIF (state = "111") THEN
						endGame := "10";
					END IF;			
				ELSIF (state = "000") THEN
					IF (dealt < 10) THEN
						dealTo <= '0';
						cardNum <= "00";
						dealt := dealt + 1;
					ELSIF (dealt < 20) THEN
						deal <= '1';
						dealt := dealt + 1;
					ELSE
						deal <= '0';
					END IF;
				ELSIF (state = "001") THEN
					IF (dealt < 10) THEN
						dealTo <= '1';
						cardNum <= "00";
						dealt := dealt + 1;
					ELSIF (dealt < 20) THEN
						deal <= '1';
						dealt := dealt + 1;
					ELSE
						deal <= '0';
					END IF;
				ELSIF (state = "010") THEN
					IF (dealt < 10) THEN
						dealTo <= '0';
						cardNum <= "01";
						dealt := dealt + 1;
					ELSIF (dealt < 20) THEN
						deal <= '1';
						dealt := dealt + 1;
					ELSE
						deal <= '0';
					END IF;
				ELSIF (state = "011") THEN
					IF (dealt < 10) THEN
						dealTo <= '0';
						cardNum <= "10";
						dealt := dealt + 1;
					ELSIF (dealt < 20) THEN
						deal <= '1';
						dealt := dealt + 1;
					ELSE
						deal <= '0';
					END IF;
				ELSIF (state = "100") THEN
					IF (dealt < 10) THEN
						dealTo <= '0';
						cardNum <= "11";
						dealt := dealt + 1;
					ELSIF (dealt < 20) THEN
						deal <= '1';
						dealt := dealt + 1;
					ELSE
						deal <= '0';
					END IF;
				ELSIF (state = "101") THEN
					IF (dealt < 10) THEN
						dealTo <= '1';
						cardNum <= "01";
						dealt := dealt + 1;
					ELSIF (dealt < 20) THEN
						deal <= '1';
						dealt := dealt + 1;
					ELSE
						deal <= '0';
					END IF;
				ELSIF (state = "110") THEN
					IF (dealt < 10) THEN
						dealTo <= '1';
						cardNum <= "10";
						dealt := dealt + 1;
					ELSIF (dealt < 20) THEN
						deal <= '1';
						dealt := dealt + 1;
					ELSE
						deal <= '0';
					END IF;
				ELSIF (state = "111") THEN
					IF (dealt < 10) THEN
						dealTo <= '1';
						cardNum <= "11";
						dealt := dealt + 1;
					ELSIF (dealt < 20) THEN
						deal <= '1';
						dealt := dealt + 1;
					ELSE
						deal <= '0';
					END IF;
				END IF;
			ELSIF (endGame = "10") THEN
				endGame := "11";
				IF (playerBust = '1' AND dealerBust = '1') THEN
					redLEDs <= "000000000000000000";
					greenLEDs <= "00000000";
				ELSIF (dealerWins = '1' OR playerBust = '1') THEN
					redLEDS <= "111111111111111111";
					greenLEDs <= "00000000";
				ELSIF (playerWins = '1' OR dealerBust = '1') THEN
					redLEDs <= "000000000000000000";
					greenLEDs <= "11111111";
				END IF;
			END IF;
		END IF;
	END PROCESS;					
END Behavioural;