library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab5 is
  port(CLOCK_50            : in  std_logic;
       KEY                 : in  std_logic_vector(3 downto 0);
       SW                  : in  std_logic_vector(17 downto 0);
		 LEDG                : out std_logic_vector(4 downto 0);
       VGA_R, VGA_G, VGA_B : out std_logic_vector(9 downto 0);  -- The outs go to VGA controller
       VGA_HS              : out std_logic;
       VGA_VS              : out std_logic;
       VGA_BLANK           : out std_logic;
       VGA_SYNC            : out std_logic;
       VGA_CLK             : out std_logic);
end lab5;

architecture RTL of lab5 is
	
	--familiar stuff from lab4
	component vga_adapter
		generic(RESOLUTION : string);
		port(resetn                                      : in  std_logic;
          clock                                        : in  std_logic;
          colour                                       : in  std_logic_vector(2 downto 0);
          x                                            : in  std_logic_vector(7 downto 0);
          y                                            : in  std_logic_vector(6 downto 0);
          plot                                         : in  std_logic;
          VGA_R, VGA_G, VGA_B                          : out std_logic_vector(9 downto 0);
          VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK : out std_logic);
	end component;
		
	type state_types is (init, draw, delay, erase, move);
	signal state : state_types := init;	
		
	signal x			: std_logic_vector(7 downto 0) := "00000000";
	signal y			: std_logic_vector(6 downto 0) := "0000000";
	signal colour	: std_logic_vector(2 downto 0) := "000";
	signal plot		: std_logic := '0';
	
begin

	--more stuff from lab4 (vga adapter)
	vga_u0 : vga_adapter
		generic map(RESOLUTION => "160x120") 
		port map(resetn    => KEY(3),
             clock     => CLOCK_50,
             colour    => colour,
             x         => x,
             y         => y,
             plot      => plot,
             VGA_R     => VGA_R,
             VGA_G     => VGA_G,
             VGA_B     => VGA_B,
             VGA_HS    => VGA_HS,
             VGA_VS    => VGA_VS,
             VGA_BLANK => VGA_BLANK,
             VGA_SYNC  => VGA_SYNC,
             VGA_CLK   => VGA_CLK);

	process(CLOCK_50, KEY(3))
		variable tempx	: unsigned(7 downto 0) := "00000000";
		variable tempy : unsigned(6 downto 0) := "0000000";
		
		--player boards (red and blue)
		variable rg : unsigned(6 downto 0) := "0000000";
		variable rfx : unsigned(7 downto 0) := "00000001";
		variable rfy : unsigned (6 downto 0) := "0000001";
		variable bg : unsigned(6 downto 0) := "0000000";
		variable bf : unsigned(6 downto 0) := "0000000";
		
		variable xdir : std_logic := '1';
		variable ydir : std_logic := '1';
		
		variable i: integer := 0;
	begin
		if (KEY(3) = '0') then
			state <= init;
		elsif(rising_edge(CLOCK_50)) then
			case state is
				when init =>
					LEDG <= "00001";
				when draw =>
					LEDG <= "00010";
				when delay =>
					LEDG <= "00100";
				when erase =>
					LEDG <= "01000";
				when move =>
					LEDG <= "10000";
			end case;
			
			case state is
				when init =>
					tempx := "00000000"; 
					tempy := "0000000";
					rfx := "00000001";
					rfy := "0000001";
					
					colour <= "000";
					plot <= '1';
					state <= draw;
				when draw =>
					if (tempy = 120) then
						if (tempx = 160) then
							colour <= "111";
							x <= std_logic_vector(rfx);
							y <= std_logic_vector(rfy);
							state <= delay;
						else
							tempx := tempx + 1;
							x <= std_logic_vector(tempx);
						end if;
					else
						if (tempx = 160) then
							tempx := "00000000";
							tempy := tempy + 1;
							x <= std_logic_vector(tempx);
							y <= std_logic_vector(tempy);
						else
							tempx := tempx + 1;
							x <= std_logic_vector(tempx);
						end if;
					end if;
				when delay =>
					if (i = 1000000) then
						i := 0;
						state <= erase;
					else
						i := i + 1;
					end if;
				when erase => 
					colour <= "000";
					state <= move;
				when move =>
					if (rfx = 160 or rfx = 0) then
						xdir := not xdir;
					end if;
					if (rfy = 120 or rfy = 0) then
						ydir := not ydir;
					end if;
					
					colour <= "111";
					if (xdir = '1') then
						rfx := rfx + 1;
					else
						rfx := rfx - 1;
					end if;
					
					if (ydir = '1') then
						rfy := rfy + 1;
					else
						rfy := rfy - 1;
					end if;
					
					x <= std_logic_vector(rfx);
					y <= std_logic_vector(rfy);
					
					state <= delay;
				when others =>
					state <= init;
			end case;
		end if;
	end process;	
end RTL;


