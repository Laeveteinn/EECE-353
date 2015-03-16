library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab5 is
  port(CLOCK_50            : in  std_logic;
       KEY                 : in  std_logic_vector(3 downto 0);
       SW                  : in  std_logic_vector(17 downto 0);
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
		
	type state_types is (init, test);
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

	process(CLOCK_50, KEY(3), state)
		variable tempx	: unsigned(7 downto 0) := "00000000";
		variable tempy : unsigned(6 downto 0) := "0000000";
		
		--player boards (red and blue)
		variable rg : unsigned(6 downto 0) := "0000000";
		variable rf : unsigned(6 downto 0) := "0000000";
		variable bg : unsigned(6 downto 0) := "0000000";
		variable bf : unsigned(6 downto 0) := "0000000";
		
		variable i: integer := 0;
	begin
		if(rising_edge(CLOCK_50)) then
			case state is
				when init =>
					tempx := "01011010"; --90
					tempy := "1001000"; --72
					rf := "1001000";
					state <= test;
					
				when test =>
					colour <= "000";
					
					x <= std_logic_vector(tempx);
					if(sw(1) = '1') then
						if(rf < 115) then
							rf := rf + 1;
							colour <= "100";
						end if;
					else
						if(rf > 5) then
							rf := rf - 1;
							colour <= "100";
						end if;
					end if;
					y <= std_logic_vector(rf);
					
				when others =>
					state <= test;
			end case;
		end if;
	end process;
	
	process(state)
	begin
		case state is
			when test =>
				plot <= '1';
			when others =>
				plot <= '0';
		end case;
	end process;
end RTL;


