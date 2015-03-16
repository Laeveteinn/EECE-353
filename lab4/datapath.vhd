--Name:	Rico Wen
--Student#: 32458119
--Name:	Aaron Chan
--Student#:	26643114

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
	port (
		reset													: in  std_logic;
      clock													: in  std_logic;
      xin													: in  std_logic_vector(7 downto 0);
      yin													: in  std_logic_vector(6 downto 0);
		prepx, prepy, loadx, loady, prepl, drawl	: in	std_logic; 							--from FSM
		x														: out std_logic_vector(7 downto 0);
      y														: out std_logic_vector(6 downto 0);
		xend, yend, lend									: out	std_logic 							--to FSM
	);
end datapath;

architecture behavioural of datapath is
begin
	process(reset, clock)
	variable temp_x : unsigned(7 downto 0) := "00000000";
	variable temp_y : unsigned(6 downto 0) := "0000000";
	
	variable x0 : unsigned(7 downto 0) := "01010000";	--initialized to 60
	variable y0 : unsigned(6 downto 0) := "0111100";	--initialized to 80
	variable x1 : unsigned(7 downto 0) := "01010000";
	variable y1 : unsigned(6 downto 0) := "0111100";
	
	--need signed since we're essentially working with delta x/y (relativity needs negatives)
	variable dx : signed(8 downto 0);
	variable dy : signed(7 downto 0);
	variable sx : signed(1 downto 0);
	variable sy : signed(1 downto 0);
	
	variable error : signed(8 downto 0);
	variable e2 : signed(9 downto 0);
	
	begin
		if(reset = '0') then
			x0 := "01010000";
			y0 := "0111100";
			x1 := "01010000";
			y1 := "0111100";
		
		elsif(rising_edge(clock)) then
			if(prepl = '1') then
				x0 := x1;
				y0 := y1;
				x1 := unsigned(xin);
				y1 := unsigned(yin);
				
				--more to_ stuff :( --makes you wish it could just autoconvert
				dx := to_signed(abs(to_integer(x1) - to_integer(x0)), 9);
				dy := to_signed(abs(to_integer(y1) - to_integer(y0)), 8);
				
				if(x0 < x1) then
					sx := to_signed(1, 2);
				else
					sx := to_signed(-1, 2);
				end if;
				
				if(y0 < y1) then
					sy := to_signed(1, 2);
				else
					sy := to_signed(-1, 2);
				end if;
				
				error := to_signed(to_integer(dx) - to_integer(dy), 9);
				lend <= '0';
				
			elsif(drawl = '1') then
				x <= std_logic_vector(x0);
				y <= std_logic_vector(y0);
				
				if((x0 = x1) and (y0 = y1)) then
					lend <= '1';
				else
					e2 := signed(2*error)(9 downto 0);
					if(e2 > -dy) then
						error := error - dy;
						x0 := unsigned(signed(x0) + sx);
					end if;
					
					if(e2 < dx) then
						error := error + dx;
						y0 := unsigned(signed(y0) + sy);
					end if;
				end if;
			
			else --clear screen (essentially a for loop in a for loop with FSM, much prettier than lab 2 :) )
				if(prepy = '1') then
					temp_y := "0000000";
				elsif(loady = '1') then
					temp_y := temp_y + 1;
				end if;
				
				if(prepx = '1') then
					temp_x := "00000000";
				elsif(loadx = '1') then
					temp_x := temp_x + 1;
				end if;
				
				if(temp_y = 119) then
					yend <= '1';
				else
					yend <= '0';
				end if;
				
				if(temp_x = 159) then
					xend <= '1';
				else
					xend <= '0';
				end if;
				
				y <= std_logic_vector(temp_y);
				x <= std_logic_vector(temp_x);
			
			end if;
		end if;
	end process;

end behavioural;