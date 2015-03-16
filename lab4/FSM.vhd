--Name:	Rico Wen
--Student#: 32458119
--Name:	Aaron Chan
--Student#:	26643114

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FSM is
	port (
		sw 													: in	std_logic_vector(17 downto 0);
		reset													: in  std_logic;
      clock													: in  std_logic;
		draw													: in	std_logic;								--key0
		xend, yend, lend									: in	std_logic; 								--from datapath
		x														: out std_logic_vector(7 downto 0);
      y														: out std_logic_vector(6 downto 0);
		colour												: out std_logic_vector(2 downto 0);
		plot													: out std_logic;
		prepx, prepy, loadx, loady, prepl, drawl	: out	std_logic; 								--to datapath
		ledg													: out std_logic_vector(7 downto 0)
	);
end FSM;

architecture behavioural of FSM is
	type state_types is (c, cx, cy, set, lstart, ldraw, ldone);
	signal state : state_types := c;
begin
	process(reset, clock)
		variable next_state : state_types;
		
	begin
		if(reset ='0') then
			state <= c;
		elsif(rising_edge(clock)) then
			case state is
				when c =>
					colour <= "000";
					next_state := cy;
					
				when cy =>
					next_state := cx;
					
				when cx =>
					if(xend = '0') then
						next_state := cx;
					elsif(xend = '1' and yend = '0') then
						next_state := cy;
					else
						next_state := set;
					end if;
					
				when set =>
					ledg <= "00000001";
					if(draw = '0') then
						ledg <= "11111111";
						x <= sw(17 downto 10);
						y <= sw(9 downto 3);
						colour <= sw(2 downto 0);
						if((unsigned(sw(17 downto 10)) <= 159) and (unsigned(sw(9 downto 3)) <= 119)) then
							ledg <= "10000001";
							next_state := lstart;
						end if;
					end if;
				
				when lstart =>
					ledg <= "00000010";
					next_state := ldraw;
					
				when ldraw =>
					ledg <= "00000100";
					if(lend = '1') then
						next_state := ldone;
					end if;
					
				when ldone =>
					ledg <= "11111111";
					next_state := set;
					
				when others =>
					next_state := set;
					
			end case;
			state <= next_state;
		end if;
	end process;
	
	process(state)
	begin
		case state is
			when c =>
				prepx <= '1';
				prepy <= '1';
				loadx <= '0';
				loady <= '0';
				prepl <= '0';
				drawl <= '0';
				plot 	<= '0';
				
			when cy =>
				prepx <= '0';
				prepy <= '0';
				loadx <= '0';
				loady <= '1';
				prepl <= '0';
				drawl <= '0';
				plot 	<= '0';
				
			when cx =>
				prepx <= '0';
				prepy <= '0';
				loadx <= '1';
				loady <= '0';
				prepl <= '0';
				drawl <= '0';
				plot 	<= '1';
				
			when lstart =>
				prepx <= '0';
				prepy <= '0';
				loadx <= '0';
				loady <= '0';
				prepl <= '1';
				drawl <= '0';
				plot 	<= '0';
				
			when ldraw =>
				prepx <= '0';
				prepy <= '0';
				loadx <= '0';
				loady <= '0';
				prepl <= '0';
				drawl <= '1';
				plot 	<= '1';
				
			when others =>
				prepx <= '0';
				prepy <= '0';
				loadx <= '0';
				loady <= '0';
				prepl <= '0';
				drawl <= '0';
				plot 	<= '0';
				
		end case;
	end process;
end behavioural;