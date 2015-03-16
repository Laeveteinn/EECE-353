library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity lab2lcd is
	port(   key : in std_logic_vector(3 downto 0);  -- pushbutton switches
        lcd_rw : out std_logic;
        lcd_en : out std_logic;
        lcd_rs : out std_logic;
        lcd_on : out std_logic;
        lcd_blon : out std_logic;
        lcd_data : out std_logic_vector(7 downto 0));
end lab2lcd;

architecture behavioural of lab2lcd is

	TYPE state_list is (r0, r1, r2, r3, r4, r5, n1, n2, n3, n4);
	SIGNAL STATE : state_list := r0;
	
begin
	lcd_blon <= '1';
	lcd_on <= '1';
	lcd_en <= key(0);
	lcd_rw <= '0';

	process(key)
	variable NEXT_STATE : state_list;
	begin
		if(key(0) = '0') then
			CASE STATE IS
				WHEN r0 => NEXT_STATE := r1;
				WHEN r1 => NEXT_STATE := r2;
				WHEN r2 => NEXT_STATE := r3;
				WHEN r3 => NEXT_STATE := r4;
				WHEN r4 => NEXT_STATE := r5;
				WHEN r5 => NEXT_STATE := n1;
				WHEN n1 => NEXT_STATE := n2;
				WHEN n2 => NEXT_STATE := n3;
				WHEN n3 => NEXT_STATE := n4;
				WHEN others => null;
			END CASE;
			
			STATE <= NEXT_STATE;
		end if;
	end process;
	
	process(STATE)
	begin
		CASE STATE IS
			WHEN r0 =>
				lcd_rs <= '0';
				lcd_data <= "00111000";
			WHEN r1 =>
				lcd_rs <= '0';
				lcd_data <= "00111000";
			WHEN r2 =>
				lcd_rs <= '0';
				lcd_data <= "00001100";
			WHEN r3 =>
				lcd_rs <= '0';
				lcd_data <= "00000001";
			WHEN r4 =>
				lcd_rs <= '0';
				lcd_data <= "00000110";
			WHEN r5 =>
				lcd_rs <= '0';
				lcd_data <= "10000000";
			WHEN n1 =>
				lcd_rs <= '1';
				lcd_data <= "01010010"; --R
			WHEN n2 =>
				lcd_rs <= '1';
				lcd_data <= "01101001"; --i
			WHEN n3 =>
				lcd_rs <= '1';
				lcd_data <= "01100011"; --c
			WHEN n4 =>
				lcd_rs <= '1';
				lcd_data <= "01101111"; --o
			WHEN others => null;
		END CASE;
	end process;

end behavioural;
