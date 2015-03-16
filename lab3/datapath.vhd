LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY DataPath IS
	PORT(
		clock         : IN STD_LOGIC;
		reset         : IN STD_LOGIC;
	
		deal          : IN STD_LOGIC;
		dealTo        : IN STD_LOGIC;
		cardNum       : IN STD_LOGIC_VECTOR(1 DOWNTO 0);

		playerCards   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); -- player’s hand
		dealerCards   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); -- dealer’s hand

		dealerStands  : OUT STD_LOGIC; -- true if dealerScore >= 17

		playerWins 	  : OUT STD_LOGIC; -- true if playerScore >  dealerScore AND playerScore <= 21
		dealerWins 	  : OUT STD_LOGIC; -- true if dealerScore >= playerScore AND dealerScore <= 21

		playerBust 	  : OUT STD_LOGIC; -- true if playerScore > 21
		dealerBust 	  : OUT STD_LOGIC  -- true if dealerScore > 21
	);
END;

ARCHITECTURE Behavioural OF DataPath IS
	
	COMPONENT DealCard IS
	PORT (
		clk     : IN STD_LOGIC;
		rst     : IN STD_LOGIC;
		
		newCard : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
	END COMPONENT;
	
	COMPONENT ScoreHand IS
	PORT (
		hand  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		
		total : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		stand : OUT STD_LOGIC;
		bust  : OUT STD_LOGIC
	);
	END COMPONENT;
	
	SIGNAL pBust  : STD_LOGIC;
	SIGNAL dBust  : STD_LOGIC;
	SIGNAL nCard  : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL pTotal : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL dTotal : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL pCards : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL dCards : STD_LOGIC_VECTOR(15 DOWNTO 0);
	
BEGIN
	dCard : DealCard
		port map (
			clk     => clock,
			rst     => reset,
			newCard => nCard
		);
		
	pScore : ScoreHand
		port map (
			hand  => pCards,
			total => pTotal,
			bust  => pBust
		);
	
	dScore : ScoreHand
		port map (
			hand  => dCards,
			total => dTotal,
			stand => dealerStands,
			bust  => dBust
		);
	
	playerBust <= pBust;
	dealerBust <= dBust;
	playerCards <= pCards;
	dealerCards <= dCards;
	
	PROCESS(clock, reset)
	VARIABLE mNCard : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
	VARIABLE dealt : BIT := '0';
	BEGIN
		IF (reset = '0') THEN
			pCards <= "0000000000000000";
			dCards <= "0000000000000000";
			mNCard := "0000";
			dealt := '0';
		ELSIF (RISING_EDGE(clock)) THEN
			IF (deal = '1') THEN
				IF (dealt = '0') THEN
					mNCard := nCard;
					dealt := '1';
					IF (dealTo = '0') THEN
						CASE cardNum IS
							WHEN "00"   => pCards(3 DOWNTO 0)   <= mNCard;
							WHEN "01"   => pCards(7 DOWNTO 4)   <= mNCard;
							WHEN "10"   => pCards(11 DOWNTO 8)  <= mNCard;
							WHEN OTHERS => pCards(15 DOWNTO 12) <= mNCard;
						END CASE;
					ELSE
						CASE cardNum IS
							WHEN "00"   => dCards(3 DOWNTO 0)   <= mNCard;
							WHEN "01"   => dCards(7 DOWNTO 4)   <= mNCard;
							WHEN "10"   => dCards(11 DOWNTO 8)  <= mNCard;
							WHEN OTHERS => dCards(15 DOWNTO 12) <= mNCard;
						END CASE;
					END IF;
				END IF;
			ELSIF (deal = '0') THEN
				dealt := '0';
			END IF;
			
			IF (TO_INTEGER(UNSIGNED(pTotal)) > TO_INTEGER(UNSIGNED(dTotal))) THEN
				IF (pBust = '0') THEN
					playerWins <= '1';
					dealerWins <= '0';
				ELSE
					playerWIns <= '0';
					dealerWIns <= '0';
				END IF;
			ELSE 
				IF (dBust = '0') THEN
					dealerWins <= '1';
					playerWins <= '0';
				ELSE
					dealerWins <= '0';
					playerWins <= '0';
				END IF;
			END IF;
		END IF;
	END PROCESS;
END Behavioural;