
-- When 'start' go from from 0 to 1, ram_writter set (after some cycles)
-- input value in RAM[cnt+delay].
-- freeRAM is 0 when the RAM is used. 1 when other elements can modified it.


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;



entity ram_writer is
port(
  -- RAM
	SRAM_ADDR : out std_logic_vector (17 downto 0);
	SRAM_WE_N : out std_logic;
	SRAM_OE_N : out std_logic;
	SRAM_DQ   : out std_logic_vector (15 downto 0);
  -- Time
	CLOCK_50  : in  std_logic;
  start     : in  std_logic;
  freeRAM   : out std_logic;
  -- Values
  cnt       : in  integer range 0 to 262143;      -- 2^18 = 262144 cells in RAM
  delay     : in  integer range 0 to 262143;
  input     : in  std_logic_vector (15 downto 0)
);
end ram_writer;

architecture ram_writer_arch of ram_writer is

  type state_type is (start_is_0,ram_ready,writing,done);
  
  signal state : state_type := start_is_0;
	signal SRAM_ADDR_loc : std_logic_vector (17 downto 0);
	signal SRAM_WE_N_loc : std_logic;
	signal SRAM_OE_N_loc : std_logic;
	signal SRAM_DQ_loc   : std_logic_vector (15 downto 0);
	signal freeRAM_loc   : std_logic;


begin
      
  SRAM_ADDR <= SRAM_ADDR_loc when (freeRAM_loc = '0') else "ZZZZZZZZZZZZZZZZZZ";
  SRAM_WE_N <= SRAM_WE_N_loc when (freeRAM_loc = '0') else 'Z';
  SRAM_OE_N <= SRAM_OE_N_loc when (freeRAM_loc = '0') else 'Z';
  SRAM_DQ   <= SRAM_DQ_loc   when (freeRAM_loc = '0') else "ZZZZZZZZZZZZZZZZ";
  freeRAM   <= freeRAM_loc;

  process (CLOCK_50)
	begin
  
    case state is
      when start_is_0 =>
          if start = '0' then
            state <= start_is_0;
          else
            SRAM_ADDR_loc <= std_logic_vector(to_unsigned(cnt + delay,18));
            SRAM_DQ_loc   <= input;
            SRAM_OE_N_loc <= '1';
            SRAM_WE_N_loc <= '1';
            freeRAM_loc   <= '0';
            state <= ram_ready;
          end if;
      when ram_ready =>
          SRAM_WE_N_loc <= '0';
          state <= writing;
      when writing =>
          SRAM_WE_N_loc <= '0';
          freeRAM_loc   <= '1';
          state <= done;
      when done =>
          if start = '0' then
            state <= start_is_0;
          else
            state <= done;
          end if;
    end case;
  
  end process;
  
end ram_writer_arch;