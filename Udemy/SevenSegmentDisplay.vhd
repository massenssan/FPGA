library ieee;
use ieee.std_logic_1164.all;
--
--type of seven segment is common cathod
--
entity SevenSegmentDisplay is
port
(
	clk	: in std_logic;--clock 50 MHz
	rst	: in std_logic;--reset button
	sw1	: in std_logic;--switch
	
	k	: out std_logic_vector(6 downto 0);--cathod of the 7 LEDs
	dp	: out std_logic;--decimal point LED
	A	: out std_logic_vector(3 downto 0)--4 Anodes of each block 7 LEDs
);
end entity;


	
	
architecture rtl of SevenSegmentDisplay is

constant CT50m : integer :=2500000;--- 50ms
signal sync : std_logic_vector(1 downto 0);
signal cnt	: integer;
signal delaybutton : std_logic;
signal debutton	: std_logic;
signal debouncedsw1	: std_logic;
signal NumberToDisplay : natural := 0;
signal k_int : std_logic_vector(6 downto 0);

type state_digit is (DIGIT_1, DIGIT_2, DIGIT_3, DIGIT_4); --creating the 4 type of states fpr the 4 7Segments
signal SMState : state_digit;


begin
--switch synchronisation
syncpr:process(clk,rst)
begin
	if rst = '0' then
		sync <= "11";
		
	elsif rising_edge(clk) then
		sync(0) <= sw1;
		sync(1) <= sync(0);
		
	end if;
end process;

--counter rocess
counterpr:process(clk,rst)
begin
	if rst = '0' then
		cnt <= 0;
		debouncedsw1 <= '1' ;
	elsif rising_edge(clk) then
		if sync(1) = '0' then
			if cnt < CT50m then
				cnt <= cnt+1;
				
			end if;
			
		elsif sync(1) = '1' then
			if cnt > 0 then
				cnt <= cnt-1;
	
			end if;
		end if;
		if cnt = CT50m then
			debouncedsw1 <= '0';
		end if;
		if cnt = 0 then
			debouncedsw1 <= '1';
		end if;
	end if;
end process;

--debouncing process
Debouncepr:process(clk,rst)
begin
	if rst = '0' then
		debutton <= '1';
		delaybutton <= '1';
	elsif rising_edge(clk) then
	
			delaybutton <= debouncedsw1;
		
			if delaybutton = '1' and debouncedsw1= '0' then
				debutton <= '0';
			else
				debutton <= '1' ;
			end if;
		
		
	end if;	

end process;

--SevenSegments decoder
--K(0) --> Seg a
--K(1) --> Seg b
--K(2) --> Seg c
--K(3) --> Seg d
--K(4) --> Seg e
--K(5) --> Seg f
--K(6) --> Seg g
DecoderSeg:process(rst,clk)
begin
	if rst = '0' then
		k_int <= "0000000";
	elsif rising_edge(clk) then
		case NumberToDisplay is--- gfedcba
			when 0 => k_int <= not "0111111";	--"1000000"
			when 1 => k_int <= not "0000110";	
			when 2 => k_int <= not "1011011";	
			when 3 => k_int <= not "1001111";	
			when 4 => k_int <= not "1100110";	
			when 5 => k_int <= not "1101101";	
			when 6 => k_int <= not "1111101";
			when 7 => k_int <= not "0000111";	
			when 8 => k_int <= not "1111111";	
			when 9 => k_int <= not "1101111";
			when others => k_int <= "1111111";
		end case;
	end if;	
			

end process;


k <= k_int;
--A <= "1110";
--using only the first 7 segment A(4)
 process_A0:process(rst, clk)
 begin
	if rst = '0' then
		NumberToDisplay <= 0;
	elsif rising_edge(clk) then
		if debutton = '0' then
			NumberToDisplay <= NumberToDisplay+1;
		end if;
	end if;
 end process;

--creater a state machine for the 4 7Sgment

--using only the first 7 segment A(4)
 Process_SMachine:process(rst, clk)
 begin
	if rst = '0' then
		A <= "1111";
		SMState <= DIGIT_1;
	elsif rising_edge(clk) then
		case SMState is
			when DIGIT_1 => A <= "1110"; 
			when DIGIT_2 => A <= "1101"; 
			when DIGIT_3 => A <= "1011"; 
			when DIGIT_4 => A <= "0111";
			when others =>  A <= "1111"; 
		end case;
	end if;
 end process;
 
end rtl;