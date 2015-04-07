LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY sound IS
	PORT (CLOCK_50,AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK,AUD_ADCDAT			:IN STD_LOGIC;
			CLOCK_27															:IN STD_LOGIC;
			KEY																:IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			SW																	:IN STD_LOGIC_VECTOR(17 downto 0);
			I2C_SDAT															:INOUT STD_LOGIC;
			I2C_SCLK,AUD_DACDAT,AUD_XCK								:OUT STD_LOGIC);
END sound;

ARCHITECTURE Behavior OF sound IS

	   -- CODEC Cores
	
	COMPONENT clock_generator
		PORT(	CLOCK_27														:IN STD_LOGIC;
		    	reset															:IN STD_LOGIC;
				AUD_XCK														:OUT STD_LOGIC);
	END COMPONENT;

	COMPONENT audio_and_video_config
		PORT(	CLOCK_50,reset												:IN STD_LOGIC;
		    	I2C_SDAT														:INOUT STD_LOGIC;
				I2C_SCLK														:OUT STD_LOGIC);
	END COMPONENT;
	
	COMPONENT audio_codec
		PORT(	CLOCK_50,reset,read_s,write_s							:IN STD_LOGIC;
				writedata_left, writedata_right						:IN STD_LOGIC_VECTOR(23 DOWNTO 0);
				AUD_ADCDAT,AUD_BCLK,AUD_ADCLRCK,AUD_DACLRCK		:IN STD_LOGIC;
				read_ready, write_ready									:OUT STD_LOGIC;
				readdata_left, readdata_right							:OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
				AUD_DACDAT													:OUT STD_LOGIC);
	END COMPONENT;

	SIGNAL read_ready, write_ready, read_s, write_s		      :STD_LOGIC;
	SIGNAL writedata_left, writedata_right							:STD_LOGIC_VECTOR(23 DOWNTO 0);	
	SIGNAL readdata_left, readdata_right							:STD_LOGIC_VECTOR(23 DOWNTO 0);	
	SIGNAL reset															:STD_LOGIC;

	-- states are reset, write ready high, and write ready low
	type state_type is (rt, wrh, wrl);
	
BEGIN

	reset <= NOT(KEY(0));
	read_s <= '0';

	my_clock_gen: clock_generator PORT MAP (CLOCK_27, reset, AUD_XCK);
	cfg: audio_and_video_config PORT MAP (CLOCK_50, reset, I2C_SDAT, I2C_SCLK);
	codec: audio_codec PORT MAP(CLOCK_50,reset,read_s,write_s,writedata_left, writedata_right,AUD_ADCDAT,AUD_BCLK,AUD_ADCLRCK,AUD_DACLRCK,read_ready, write_ready,readdata_left, readdata_right,AUD_DACDAT);

	process(CLOCK_50, reset)
		-- Constants
		CONSTANT MAX_AMP : signed(23 downto 0) := "000000010000000000000000"; -- recommended 2^16 amplitude for volume
		CONSTANT C : unsigned(6 downto 0) := "1010100"; -- 44000/262 = 168 -> 84
		CONSTANT D : unsigned(6 downto 0) := "1001011"; -- 44000/293 = 150 -> 75
		CONSTANT E : unsigned(6 downto 0) := "1000111"; -- 44000/311 = 141 -> 71
		CONSTANT F : unsigned(6 downto 0) := "0111111"; -- 44000/349 = 126 -> 63
		CONSTANT G : unsigned(6 downto 0) := "0111000"; -- 44000/392 = 112 -> 56
		CONSTANT A : unsigned(6 downto 0) := "0110010"; -- 44000/440 = 100 -> 50
		CONSTANT B : unsigned(6 downto 0) := "0101101"; -- 44000/494 = 89 -> 45
		
		-- State
		variable state : state_type := rt;
		
		-- Tones
		variable tone_c : unsigned(6 downto 0) := C;
		variable tone_d : unsigned(6 downto 0) := D;
		variable tone_e : unsigned(6 downto 0) := E;
		variable tone_f : unsigned(6 downto 0) := F;
		variable tone_g : unsigned(6 downto 0) := G;
		variable tone_a : unsigned(6 downto 0) := A;
		variable tone_b : unsigned(6 downto 0) := B;
		
		-- Amplitudes
		variable amplitude : signed(23 downto 0);
		variable amp_c : signed(23 downto 0) := MAX_AMP;
		variable amp_d : signed(23 downto 0) := MAX_AMP;
		variable amp_e : signed(23 downto 0) := MAX_AMP;
		variable amp_f : signed(23 downto 0) := MAX_AMP;
		variable amp_g : signed(23 downto 0) := MAX_AMP;
		variable amp_a : signed(23 downto 0) := MAX_AMP;
		variable amp_b : signed(23 downto 0) := MAX_AMP;
	begin
		if(reset = '1') then
			state := rt;
		elsif(rising_edge(CLOCK_50)) then
			case state is
				when rt =>
					tone_c := C;
					tone_d := D;
					tone_e := E;
					tone_f := F;
					tone_g := G;
					tone_a := A;
					tone_b := B;
					
					state:= wrh;
					
				when wrh =>
					if(write_ready = '1') then
						amplitude := (others => '0'); --set all bits to 0
						
						-- Detect inputs
						if(sw(0) = '1') then
							amplitude := amplitude + amp_c;
						end if;
						if(sw(1) = '1') then
							amplitude := amplitude + amp_d;
						end if;
						if(sw(2) = '1') then
							amplitude := amplitude + amp_e;
						end if;
						if(sw(3) = '1') then
							amplitude := amplitude + amp_f;
						end if;
						if(sw(4) = '1') then
							amplitude := amplitude + amp_g;
						end if;
						if(sw(5) = '1') then
							amplitude := amplitude + amp_a;
						end if;
						if(sw(6) = '1') then
							amplitude := amplitude + amp_b;
						end if;
						
						-- Output sound
						writedata_left <= std_logic_vector(amplitude);
						writedata_right <= std_logic_vector(amplitude);
						write_s <= '1';
						
						-- Decrement to determine oscillation
						tone_c := tone_c - 1;
						tone_d := tone_d - 1;
						tone_e := tone_e - 1;
						tone_f := tone_f - 1;
						tone_g := tone_g - 1;
						tone_a := tone_a - 1;
						tone_b := tone_b - 1;
						
						-- Oscillation between + and -
						if(tone_c = "0000000") then
							amp_c := -amp_c;
							tone_c := C;
						end if;
						if(tone_d = "0000000") then
							amp_d := -amp_d;
							tone_d := D;
						end if;
						if(tone_e = "0000000") then
							amp_e := -amp_e;
							tone_e := E;
						end if;
						if(tone_f = "0000000") then
							amp_f := -amp_f;
							tone_f := F;
						end if;
						if(tone_g = "0000000") then
							amp_g := -amp_g;
							tone_g := G;
						end if;
						if(tone_a = "0000000") then
							amp_a := -amp_a;
							tone_a := A;
						end if;
						if(tone_b = "0000000") then
							amp_b := -amp_b;
							tone_b := B;
						end if;
						
						state := wrl;
					end if;
						
				when wrl =>
						if(write_ready = '0') then
							write_s <= '0';
							state := wrh;
						end if;
						
				when others =>
						state := rt;
			end case;
		end if;
	end process;

END Behavior;
