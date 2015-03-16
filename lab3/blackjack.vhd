LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY BlackJack IS
	PORT(
		CLOCK_50 : in std_logic; -- A 50MHz clock
	   SW 	  	: in  std_logic_vector(17 downto 0); -- SW(0) = player stands
		KEY  		: in  std_logic_vector(3 downto 0);  -- KEY(3) reset, KEY(0) advance
	   LEDR 		: out std_logic_vector(17 downto 0); -- red LEDs: dealer wins
	   LEDG 		: out std_logic_vector(7 downto 0);  -- green LEDs: player wins

	   HEX7 		: out std_logic_vector(6 downto 0);  -- dealer, fourth card
	   HEX6 		: out std_logic_vector(6 downto 0);  -- dealer, third card
	   HEX5 		: out std_logic_vector(6 downto 0);  -- dealer, second card
	   HEX4 		: out std_logic_vector(6 downto 0);   -- dealer, first card

	   HEX3 		: out std_logic_vector(6 downto 0);  -- player, fourth card
	   HEX2 		: out std_logic_vector(6 downto 0);  -- player, third card
	   HEX1 		: out std_logic_vector(6 downto 0);  -- player, second card
	   HEX0 		: out std_logic_vector(6 downto 0)   -- player, first card
	);
END;


ARCHITECTURE Behavioural OF BlackJack IS

	COMPONENT Card7Seg IS
	PORT(
	   	card : IN  STD_LOGIC_VECTOR(3 DOWNTO 0); -- value of card
	   	seg7 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)  -- 7-seg LED pattern
	);
	END COMPONENT;

	COMPONENT DataPath IS
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
	END COMPONENT;

	COMPONENT FSM IS
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
	END COMPONENT;
	
	SIGNAL pCards 	 : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL dCards 	 : STD_LOGIC_VECTOR(15 DOWNTO 0);
	
	SIGNAL pWins    : STD_LOGIC;
	SIGNAL dWins    : STD_LOGIC;
	
	SIGNAL pBust  	 : STD_LOGIC;
	SIGNAL dBust  	 : STD_LOGIC;
	SIGNAL dStand 	 : STD_LOGIC;
	
	SIGNAL mDeal    : STD_LOGIC;
	SIGNAL mDealTo  : STD_LOGIC;
	signal mCardNum : STD_LOGIC_VECTOR(1 DOWNTO 0);

BEGIN	
	f : FSM
		port map(
			clock        => CLOCK_50,
			reset 		 => KEY(3),
			nextStep 	 => KEY(0),
			playerStands => SW(0),
			dealerStands => dStand,
			playerWins 	 => pWins,
			dealerWins 	 => dWins,
			playerBust 	 => pBust,
			dealerBust 	 => dBust,
			deal         => mDeal,
			dealTo       => mDealTo,
			cardNum      => mCardNum,
			redLEDs 		 => LEDR,
			greenLEDS 	 => LEDG
		);
	
	dPath : DataPath
		port map(
			clock        => CLOCK_50,
			reset        => KEY(3),
			deal         => mDeal,
			dealTo       => mDealTo,
			cardNum      => mCardNum,
			playerCards  => pCards,
			dealerCards  => dCards,
			dealerStands => dStand,
			playerWins   => pWins,
			dealerWins   => dWins,
			playerBust   => pBust,
			dealerBust   => dBust
		);
		
	pCard1: Card7Seg
		port map(pCards(3 DOWNTO 0), HEX0);
	pCard2: Card7Seg
		port map(pCards(7 DOWNTO 4), HEX1);
	pCard3: Card7Seg
		port map(pCards(11 DOWNTO 8), HEX2);
	pCard4: Card7Seg
		port map(pCards(15 DOWNTO 12), HEX3);
	dCard1: Card7Seg
		port map(dCards(3 DOWNTO 0), HEX4);
	dCard2: Card7Seg
		port map(dCards(7 DOWNTO 4), HEX5);
	dCard3: Card7Seg
		port map(dCards(11 DOWNTO 8), HEX6);
	dCard4: Card7Seg
		port map(dCards(15 DOWNTO 12), HEX7);	
END Behavioural;

