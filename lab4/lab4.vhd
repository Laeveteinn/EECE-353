--Name:	Rico Wen
--Student#: 32458119
--Name:	Aaron Chan
--Student#:	26643114


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab4 is
  port(CLOCK_50            : in  std_logic;
       KEY                 : in  std_logic_vector(3 downto 0);
       SW                  : in  std_logic_vector(17 downto 0);
		 LEDG						: out std_logic_vector(7 downto 0);
       VGA_R, VGA_G, VGA_B : out std_logic_vector(9 downto 0);  -- The outs go to VGA controller
       VGA_HS              : out std_logic;
       VGA_VS              : out std_logic;
       VGA_BLANK           : out std_logic;
       VGA_SYNC            : out std_logic;
       VGA_CLK             : out std_logic);
end lab4;

architecture rtl of lab4 is

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
  
	component FSM is
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
	end component;
	
	component datapath is
		port (
			reset													: in  std_logic;
			clock													: in  std_logic;
			xin													: in  std_logic_vector(7 downto 0);
			yin													: in  std_logic_vector(6 downto 0);
			prepx, prepy, loadx, loady, prepl, drawl	: in	std_logic; 							--from FSM
			x														: out  std_logic_vector(7 downto 0);
			y														: out  std_logic_vector(6 downto 0);
			xend, yend, lend									: out	std_logic 							--to FSM
		);
	end component;

  signal x      : std_logic_vector(7 downto 0) := "00000000";
  signal y      : std_logic_vector(6 downto 0) := "0000000";
  signal colour : std_logic_vector(2 downto 0);
  signal plot   : std_logic;
  
  signal xend, yend, lend		:	std_logic;
  signal prepx, prepy, prepl	:	std_logic;
  signal loadx, loady, drawl	:	std_logic;
  
  signal xin    : std_logic_vector(7 downto 0) := "00000000";
  signal yin    : std_logic_vector(6 downto 0) := "0000000";

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

	f_sm : FSM port map(
		sw		=> SW,
		reset	=> KEY(3),
		clock	=> CLOCK_50,
		draw	=> KEY(0),
		xend	=> xend,
		yend	=> yend,
		lend	=> lend,
		x		=> xin,
		y		=> yin,
		colour=> colour,
		plot	=> plot,
		prepx	=> prepx,
		prepy	=> prepy,
		loadx	=> loadx,
		loady	=> loady,
		prepl	=> prepl,
		drawl	=> drawl,
		ledg	=> LEDG
	);
	
	dp : datapath port map(
		reset	=> KEY(3),
		clock	=> CLOCK_50,
		xend	=> xend,
		yend	=> yend,
		lend	=> lend,
		x		=> x,
		y		=> y,
		xin	=> xin,
		yin	=> yin,
		prepx	=> prepx,
		prepy	=> prepy,
		loadx	=> loadx,
		loady	=> loady,
		prepl	=> prepl,
		drawl	=> drawl
	);

end RTL;


