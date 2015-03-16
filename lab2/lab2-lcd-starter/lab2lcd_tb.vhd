-- Lab2 Testbench.  A test bench is a file that describes the commands that should
-- be used when simulating the design.  The test bench does not describe any hardware,
-- but is only used during simulation.  In Lab 2, you can use this test bench directly,
-- and do *not need to modify it* (in later labs, you will have to write test benches).
-- Therefore, you do not need to worry about the details in this file (but you might find
-- it interesting to look through anyway).

-- The following lines should be at the top of all your
-- VHDL files.  The lines include standard libraries 
-- that you will need in your labs (and most future labs).

library ieee;
use ieee.std_logic_1164.all;

-- Testbenches don't have input and output ports. 

entity lab2lcd_tb is
end lab2lcd_tb;


architecture stimulus of lab2lcd_tb is

	--Declare the device under test (DUT)
	component lab2lcd is
	port(	key : in std_logic_vector(3 downto 0);  -- pushbutton switches
		lcd_rw : out std_logic;
		lcd_en : out std_logic;
		lcd_rs : out std_logic;
		lcd_on : out std_logic;
		lcd_blon : out std_logic;
		lcd_data : out std_logic_vector(7 downto 0)
	);	 
	end component;
	
	-- Some local signal declarations
  
	signal clk : std_logic := '0';
	signal resetb : std_logic := '0';	

	signal key : std_logic_vector(3 downto 0) := "0000";
	signal lcd_rw : std_logic;
	signal lcd_en : std_logic;
	signal lcd_rs : std_logic;
	signal lcd_on : std_logic;
	signal lcd_blon : std_logic;
	signal lcd_data : std_logic_vector(7 downto 0);
	

	--Declare a constant of type 'time'. This would be used to cause delay
        --between different testcases and it makes it easy to observe the output
 	--waveforms in the waveform viewer (the output waveforms would not change 
	--for this time period between different test cases)
	
	constant PERIOD : time := 6 ns;

begin
	--Instantiate the DUT
	--=======================================================================
	DUT: lab2lcd
		port map (
			key=>key,
			lcd_rw=>lcd_rw,
			lcd_en=>lcd_en,
			lcd_rs=>lcd_rs,
			lcd_on=>lcd_on,
			lcd_blon=>lcd_blon,
			lcd_data=>lcd_data
		);

     	--=======================================================================

	-- This process generates a periodic signal on the clock.
	-- Note that a process without a sensitivity list is called 
	-- during the simulation at time 0, as well as whenever the process
	-- finishes execution.
	
	clk_gen : process
	begin
		clk <= not clk;
		wait for PERIOD/2;
	end process;
	
	-- This generates a reset pulse for one cycle, and then
	-- exits reset for 20 cycles.  Note that it is offset slightly
	-- from the clock, since we don't like the idea of changing our clock 
	-- and reset at exactly the same time.  It also helps illustrate the
	-- asynchronous nature of the reset
	
	resetb_gen : process
	begin  
		resetb <= '0';  -- reset is active low, so a 0 means reset state machine
		wait for PERIOD*0.75; -- offset a bit so things dont happen on clock edge
		wait for PERIOD;
		resetb <= '1';  -- exit reset.  Circuit should operate now.
		wait for PERIOD*20;
	end process;
	
	key <= resetb & "00" & clk;	
	
end stimulus;
