library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab5 is
  port(CLOCK_50            : in  std_logic;
       KEY                 : in  std_logic_vector(3 downto 0);
       SW                  : in  std_logic_vector(17 downto 0);
		 LEDR                : out std_logic_vector(17 downto 0);
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
		
	type state_types is (init, draw, drawrg, drawrf, drawbg, drawbf, delay, erasep, eraserg, eraserf, erasebg, erasebf, movep, moverg, moverf, movebg, movebf);
	signal state : state_types := init;	
		
	signal x			: std_logic_vector(7 downto 0) := "00000000";
	signal y			: std_logic_vector(6 downto 0) := "0000000";
	signal colour	: std_logic_vector(2 downto 0) := "000";
	signal plot		: std_logic := '0';
	
	constant P_LENGTH : integer := 16;
	constant BG_X : unsigned(7 downto 0) := "00001010";
	constant BF_X : unsigned(7 downto 0) := "00110010";
	constant RG_X : unsigned(7 downto 0) := "10010110";
	constant RF_X : unsigned(7 downto 0) := "01101110";
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
		
		--player boards (blue and red)
		variable bg : unsigned(6 downto 0) := "0110100";
		variable bf : unsigned(6 downto 0) := "0110100";
		variable rg : unsigned(6 downto 0) := "0110100";
		variable rf : unsigned(6 downto 0) := "0110100";
		
		variable px : unsigned(7 downto 0) := "00000001";
		variable py : unsigned (6 downto 0) := "0000001";
		
		variable xdir : std_logic := '1';
		variable ydir : std_logic := '1';
		
		variable i: integer := 0;
	begin
		if (KEY(3) = '0') then
			state <= init;
			plot <= '0';
		elsif(rising_edge(CLOCK_50)) then
			case state is
				when init =>
					LEDR <= "000000000000000001";
				when draw =>
					LEDR <= "000000000000000010";
				when drawrg =>
					LEDR <= "000000000000000100";
				when drawrf =>
					LEDR <= "000000000000001000";
				when drawbg =>
					LEDR <= "000000000000010000";
				when drawbf =>
					LEDR <= "000000000000100000";
				when delay =>
					LEDR <= "000000000001000000";
				when erasep =>
					LEDR <= "000000000010000000";
				when eraserg =>
					LEDR <= "000000000100000000";
				when eraserf =>
					LEDR <= "000000001000000000";
				when erasebg =>
					LEDR <= "000000010000000000";
				when erasebf =>
					LEDR <= "000000100000000000";
				when movep =>
					LEDR <= "000001000000000000";
				when moverg =>
					LEDR <= "000010000000000000";
				when moverf =>
					LEDR <= "000100000000000000";
				when movebg =>
					LEDR <= "001000000000000000";
				when movebf =>
					LEDR <= "010000000000000000";
			end case;
			
			case state is
				when init =>
					tempx := "00000000"; 
					tempy := "0000000";
					bg := "0110100";
					bf := "0110100";
					rg := "0110100";
					rf := "0110100";
					px := "00000001";
					py := "0000001";
					
					colour <= "000";
					plot <= '1';
					state <= draw;
				when draw =>
					if (tempy = 120) then
						if (tempx = 160) then
							tempx := "00000000";
							tempy := "0000000";
							colour <= "111";
							x <= std_logic_vector(px);
							y <= std_logic_vector(py);
							state <= drawrg;
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
				when drawrg =>
					colour <= "100";
					x <= std_logic_vector(RG_X);
					y <= std_logic_vector(rg + tempy);
					if (tempy = P_LENGTH) then
						tempy := "0000000";
						state <= drawrf;
					else
						tempy := tempy + 1;
					end if;
				when drawrf =>
					x <= std_logic_vector(RF_X);
					y <= std_logic_vector(rf + tempy);
					if (tempy = P_LENGTH) then
						tempy := "0000000";
						state <= drawbg;
					else
						tempy := tempy + 1;
					end if;
				when drawbg =>
					colour <= "001";
					x <= std_logic_vector(BG_X);
					y <= std_logic_vector(bg + tempy);
					if (tempy = P_LENGTH) then
						tempy := "0000000";
						state <= drawbf;
					else
						tempy := tempy + 1;
					end if;
				when drawbf =>
					x <= std_logic_vector(BF_X);
					y <= std_logic_vector(bf + tempy);
					if (tempy = P_LENGTH) then
						tempy := "0000000";
						state <= delay;
					else
						tempy := tempy + 1;
					end if;
				when delay =>
					if (i = 1500000) then
						i := 0;
						state <= erasep;
					else
						i := i + 1;
					end if;
				when erasep => 
					colour <= "000";
					x <= std_logic_vector(px);
					y <= std_logic_vector(py);
					state <= eraserg;
				when eraserg =>
					if (SW(0) = '1') then
						if (rg > 0) then
							x <= std_logic_vector(RG_X);
							y <= std_logic_vector(rg + P_LENGTH);
							rg := rg - 1;
						end if;
					else
						if (rg + P_LENGTH < 120) then
							x <= std_logic_vector(RG_X);
							y <= std_logic_vector(rg);
							rg := rg + 1;
						end if;
					end if;
					state <= eraserf;
				when eraserf =>
					if (SW(1) = '1') then
						if (rf > 0) then
							x <= std_logic_vector(RF_X);
							y <= std_logic_vector(rf + P_LENGTH);
							rf := rf - 1;
						end if;
					else
						if (rf + P_LENGTH < 120) then
							x <= std_logic_vector(RF_X);
							y <= std_logic_vector(rf);
							rf := rf + 1;
						end if;
					end if;
					state <= erasebg;
				when erasebg =>
					if (SW(17) = '1') then
						if (bg > 0) then
							x <= std_logic_vector(BG_X);
							y <= std_logic_vector(bg + P_LENGTH);
							bg := bg - 1;
						end if;
					else
						if (bg + P_LENGTH < 120) then
							x <= std_logic_vector(BG_X);
							y <= std_logic_vector(bg);
							bg := bg + 1;
						end if;
					end if;
					state <= erasebf;
				when erasebf =>
					if (SW(16) = '1') then
						if (bf > 0) then
							x <= std_logic_vector(BF_X);
							y <= std_logic_vector(bf + P_LENGTH);
							bf := bf - 1;
						end if;
					else
						if (bf + P_LENGTH < 120) then
							x <= std_logic_vector(BF_X);
							y <= std_logic_vector(bf);
							bf := bf + 1;
						end if;
					end if;
					state <= movep;
				when movep =>
					if (px = 160 or px = 0) then
						xdir := not xdir;
					end if;
					if (py = 120 or py = 0) then
						ydir := not ydir;
					end if;
					
					colour <= "111";
					if (xdir = '1') then
						px := px + 1;
					else
						px := px - 1;
					end if;
					
					if (ydir = '1') then
						py := py + 1;
					else
						py := py - 1;
					end if;
					
					x <= std_logic_vector(px);
					y <= std_logic_vector(py);
					
					state <= moverg;
				when moverg =>
					colour <= "100";
					if (SW(0) = '1') then
						x <= std_logic_vector(RG_X);
						y <= std_logic_vector(rg);
					else
						x <= std_logic_vector(RG_X);
						y <= std_logic_vector(rg + P_LENGTH);
					end if;
					state <= moverf;
				when moverf =>
					if (SW(1) = '1') then
						x <= std_logic_vector(RF_X);
						y <= std_logic_vector(rf);
					else
						x <= std_logic_vector(RF_X);
						y <= std_logic_vector(rf + P_LENGTH);
					end if;
					state <= movebg;
				when movebg =>
					colour <= "001";
					if (SW(17) = '1') then
						x <= std_logic_vector(BG_X);
						y <= std_logic_vector(bg);
					else
						x <= std_logic_vector(BG_X);
						y <= std_logic_vector(bg + P_LENGTH);
					end if;
					state <= movebf;
				when movebf =>
					if (SW(16) = '1') then
						x <= std_logic_vector(BF_X);
						y <= std_logic_vector(bf);
					else
						x <= std_logic_vector(BF_X);
						y <= std_logic_vector(bf + P_LENGTH);
					end if;
					state <= delay;
				when others =>
					state <= init;
			end case;
		end if;
	end process;	
end RTL;


