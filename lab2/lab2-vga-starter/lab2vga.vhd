--Names: Rico Wen, Aaron Chan
--Lab Section: L2G

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab2vga is
  port(CLOCK_50            : in  std_logic;
       KEY                 : in  std_logic_vector(3 downto 0);
       SW                  : in  std_logic_vector(17 downto 0);
       VGA_R, VGA_G, VGA_B : out std_logic_vector(9 downto 0);  -- The outs go to VGA controller
       VGA_HS              : out std_logic;
       VGA_VS              : out std_logic;
       VGA_BLANK           : out std_logic;
       VGA_SYNC            : out std_logic;
       VGA_CLK             : out std_logic);
end lab2vga;

architecture rtl of lab2vga is

 --Component from the Verilog file: vga_adapter.v

  component vga_adapter
    generic(RESOLUTION : string);
    port (resetn                                       : in  std_logic;
          clock                                        : in  std_logic;
          colour                                       : in  std_logic_vector(2 downto 0);
          x                                            : in  std_logic_vector(7 downto 0);
          y                                            : in  std_logic_vector(6 downto 0);
          plot                                         : in  std_logic;
          VGA_R, VGA_G, VGA_B                          : out std_logic_vector(9 downto 0);
          VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK : out std_logic);
  end component;

  signal x      : std_logic_vector(7 downto 0) := "00000000";
  signal y      : std_logic_vector(6 downto 0) := "0000000";
  signal colour : std_logic_vector(2 downto 0);
  signal plot   : std_logic;

begin

  -- includes the vga adapter, which should be in your project 

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


	process(CLOCK_50, x, y, colour, plot, KEY)
		variable temp : integer;
	begin
		if(rising_edge(CLOCK_50)) then
			if(KEY(0) = '0') then
				plot <= '1';
				
				if(KEY(1) = '0') then
					colour <= "000";
				else
					temp := to_integer(unsigned(y));
					temp := temp mod 8;
					colour <= std_logic_vector(to_unsigned(temp, 3));
				end if;
					
				if(unsigned(y) < 119) and (unsigned(x) = 159) then
					y <= std_logic_vector( unsigned(y) + 1 );
					x <= "00000000";
				end if;
							
				x <= std_logic_vector( unsigned(x) + 1 );
				
			elsif(KEY(1) = '0') then
				x <= "00000000";
				y <= "0000000";
				
			elsif(KEY(2) = '0') then
				plot <= '1';
				
				colour <= SW(17 downto 15);
				y      <= SW(14 downto 8);
				
				if(unsigned(x) < 159) then
					x <= "00000000";
				end if;
				
				x <= std_logic_vector( unsigned(x) + 1 );
			end if;
				
		end if;
	end process;

end RTL;


