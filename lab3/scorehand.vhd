LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY scorehand IS
	PORT(
		hand : IN STD_LOGIC_VECTOR(15 downto 0);
		
		total : OUT STD_LOGIC_VECTOR( 4 DOWNTO 0);  -- total value of hand
		stand : OUT STD_LOGIC;
		bust  : OUT STD_LOGIC
	);
END scorehand;


ARCHITECTURE behavioral OF scorehand IS
	SIGNAL card1 : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL card2 : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL card3 : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL card4 : STD_LOGIC_VECTOR(3 DOWNTO 0);
BEGIN
	
	card1 <= hand(3 DOWNTO 0);
	card2 <= hand(7 DOWNTO 4);
	card3 <= hand(11 DOWNTO 8);
	card4 <= hand(15 DOWNTO 12);

	PROCESS (card1, card2, card3, card4)
	
	VARIABLE count : unsigned (5 downto 0);
	VARIABLE nAce : integer range 0 to 4 := 0;
	
	BEGIN
		CASE card1 IS
			WHEN "0001" =>	-- handle the ace
				count := "000001";
				nAce := nAce + 1;
			WHEN "1010" => count := "001010";
			WHEN "1011" => count := "001010";
			WHEN "1100" => count := "001010";
			WHEN "1101" => count := "001010";
			WHEN others => count := ("00" & unsigned(card1)) mod 10;	--need "00" for concatenate, doesn't work otherwise
		END CASE;
		
		CASE card2 IS
			WHEN "0001" =>
				count := count + "000001";
				nAce := nAce + 1;
			WHEN "1010" => count := count + "001010";
			WHEN "1011" => count := count + "001010";
			WHEN "1100" => count := count + "001010";
			WHEN "1101" => count := count + "001010";
			WHEN others => count := count + (("00" & unsigned(card2)) mod 10);
		END CASE;
		
		CASE card3 IS
			WHEN "0001" =>
				count := count + "000001";
				nAce := nAce + 1;
			WHEN "1010" => count := count + "001010";
			WHEN "1011" => count := count + "001010";
			WHEN "1100" => count := count + "001010";
			WHEN "1101" => count := count + "001010";
			WHEN others => count := count + (("00" & unsigned(card3)) mod 10);
		END CASE;
		
		CASE card4 IS
			WHEN "0001" =>
				count := count + "000001";
				nAce := nAce + 1;
			WHEN "1010" => count := count + "001010";
			WHEN "1011" => count := count + "001010";
			WHEN "1100" => count := count + "001010";
			WHEN "1101" => count := count + "001010";
			WHEN others => count := count + (("00" & unsigned(card4)) mod 10);
		END CASE;
		
		-- for some reason the compilation hangs on my machine when I try to use a while loop here, test it on your end if you want
		if(nAce > 0) then
			if(count <= 11) then
				count := count + "001010";
			end if;
			nAce := nAce - 1;
		end if;
		
		if(nAce > 0) then
			if(count <= 11) then
				count := count + "001010";
			end if;
			nAce := nAce - 1;
		end if;
		
		if(count > 21) then
			count := "011111";
			stand <= '0';
			bust <= '1';
		elsif(count >= 17) then
			stand <= '1';
			bust <= '0';
		else
			stand <= '0';
			bust <= '0';
		end if;
		
		total <= std_logic_vector(count(4 downto 0));
	END PROCESS;
END;