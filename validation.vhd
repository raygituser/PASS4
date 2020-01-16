library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity VALIDATION is
	port (
		CLK : in std_logic;
		RSTN : in std_logic;
		ENTER_N : in std_logic;
		NUM_N : in std_logic_vector(15 downto 0);
		UNLOCK_N : out std_logic;
		RESET_N : out std_logic
	);
end VALIDATION;

architecture RTL of VALIDATION is
	
	constant INITPASS : std_logic_vector(15 downto 0)
					  := "0111010100011001";		-- 7519(initial password)
	signal PASS : std_logic_vector(15 downto 0);
					  
	type STATE is (ALL_RESET_ST, IDLE_ST, JUDGES_ST, SUCCESS_ST, MEMORY_ST, NUM_RESET_ST);
	signal CURRENT_STATE, NEXT_STATE, PREVIOUS_STATE : STATE;
		
begin

	STATE_SET : process(CLK, RSTN) begin
		if (RSTN = '0') then
			CURRENT_STATE <= ALL_RESET_ST;
		elsif (CLK'event and CLK = '1') then
			CURRENT_STATE <= NEXT_STATE;
		end if;
	end process;
	
	STATE_TRANS : process(ENTER_N, NUM_N, CURRENT_STATE, PREVIOUS_STATE) begin
		if (CURRENT_STATE = ALL_RESET_ST) then
			PASS <= INITPASS;
			NEXT_STATE <= IDLE_ST;
		elsif (CURRENT_STATE = IDLE_ST) then
			if (ENTER_N = '1') then
				NEXT_STATE <= JUDGES_ST;
			end if;
		elsif (CURRENT_STATE = JUDGES_ST) then
			if (NUM_N = PASS) then
				NEXT_STATE <= JUDGES_ST;
			else
				NEXT_STATE <= NUM_RESET_ST;
			end if;
		elsif (CURRENT_STATE = SUCCESS_ST) then
			if (ENTER_N = '1') then
				PREVIOUS_STATE <= CURRENT_STATE;
				NEXT_STATE <= MEMORY_ST;
			end if;
		elsif (CURRENT_STATE = MEMORY_ST) then
			if (ENTER_N = '1') then
				PASS <= NUM_N;
				PREVIOUS_STATE <= CURRENT_STATE;
				NEXT_STATE <= NUM_RESET_ST;
			end if;
		elsif (CURRENT_STATE = NUM_RESET_ST) then
			if (PREVIOUS_STATE = JUDGES_ST) then
				NEXT_STATE <= IDLE_ST;
			elsif (PREVIOUS_STATE = SUCCESS_ST) then
				NEXT_STATE <= MEMORY_ST;
			end if;
		end if;
	end process;
	
	OUTPUT : process(CURRENT_STATE) begin
		if (CURRENT_STATE = ALL_RESET_ST) then
			UNLOCK_N <= '0';
			RESET_N <= '0';
		elsif (CURRENT_STATE = IDLE_ST) then
			UNLOCK_N <= '0';
			RESET_N <= '1';
		elsif (CURRENT_STATE = JUDGES_ST) then
			UNLOCK_N <= '0';
			RESET_N <= '1';
		elsif (CURRENT_STATE = SUCCESS_ST) then
			UNLOCK_N <= '1';
			RESET_N <= '1';
		elsif (CURRENT_STATE = MEMORY_ST) then
			UNLOCK_N <= '0';
			RESET_N <= '1';
		elsif (CURRENT_STATE = NUM_RESET_ST) then
			UNLOCK_N <= '0';
			RESET_N <= '0';
		end if;
	end process;
	
--	process (CLK, RSTN, ENTER_N, NUM_N) begin
--		if (RSTN = '0') then
--			UNLOCK_N <= '0';
--		elsif (CLK'event and CLK = '1') then
--			if (ENTER_N = '1') then
--				if (NUM_N = PASS) then
--					UNLOCK_N <= '1';
--				else
--					UNLOCK_N <= '0';
--					RESET_N <= '0';
--				end if;
--			else
--				RESET_N <= '1';
--			end if;
--		end if;
--	end process;
	
end RTL;
					