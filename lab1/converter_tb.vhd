-- Lab1 Testbench.  A test bench is a file that describes the commands that should
-- be used when simulating the design.  The test bench does not describe any hardware,
-- but is only used during simulation.  In Lab 1, you can use this test bench directly,
-- and do *not need to modify it* (in later labs, you will have to write test benches).
-- Therefore, you do not need to worry about the details in this file (but you might find
-- it interesting to look through anyway).

-- The following lines should be at the top of all your
-- VHDL files.  The lines include standard libraries 
-- that you will need in your labs (and most future labs).

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;


-- Testbenches don't have input and output ports.  We'll talk about that in class
-- later in the course.

entity converter_tb is
end converter_tb;


architecture stimulus of converter_tb is

	--Declare the device under test (DUT)
	component converter is
		port(	SW : in std_logic_vector(2 downto 0);  
			HEX0 : out std_logic_vector(6 downto 0)); 
	end component;

	--Signals that connect to the ports of the DUT. The inputs would be 
	--driven inside the testbench according to different test cases, and
	--the output would be monitored in the waveform viewer.

	signal in_sw : std_logic_vector(2 downto 0);
	signal out_hex0 : std_logic_vector(6 downto 0);	

	--Declare a constant of type 'time'. This would be used to cause delay
        --between different testcases and it makes it easy to observe the output
 	--waveforms in the waveform viewer (the output waveforms would not change 
	--for this time period between different test cases)
	constant PERIOD : time := 5ns;

begin

	--Instantiate the DUT
	--=======================================================================
	DUT: converter
		port map (SW  => in_sw, 
                          HEX0 => out_hex0);
	--=======================================================================

	
	--Process block containing different test cases. We'll cover process blocks 
	--in the class later. The following is a special type of process block 
	--(without a sensitivity list) that can only be used inside test benches. 

	--Inside this process block, you would write all your test cases. For each
	--testcase, you would assign values to the signals that connect to inputs of
	--the DUT and wait for 'PERIOD' time. The DUT would drive the output signals 
	--that can be viewed in the waveform viewer.
	
	test : process
	begin
		--Testcase #1
		in_sw <= "000";
		wait for PERIOD;

		--Testcase #2
		in_sw <= "001";
		wait for PERIOD;

		--Testcase #3
		in_sw <= "010";
		wait for PERIOD;

		--Testcase #4
		in_sw <= "011";
		wait for PERIOD;

		--Testcase #5
		in_sw <= "100";
		wait for PERIOD;

		--Testcase #6
		in_sw <= "101";
		wait for PERIOD;

		--Testcase #7
		in_sw <= "110";
		wait for PERIOD;

		--Testcase #8
		in_sw <= "111";
		wait for PERIOD;	
	
		--Finally, at the end, when all the tests have been done, disable this process block
		wait;		
	end process;

end stimulus;
