
-- When 'start' go from from 0 to 1, ram_reader set (after some cycles)
-- output to RAM[cnt+delay]*alpha + beta.
-- freeRAM is 0 when the RAM is used. 1 when other elements can modified it.


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;



entity ram_reader is
port(
  -- RAM
	SRAM_ADDR : out std_logic_vector (17 downto 0);
	SRAM_WE_N : out std_logic;
	SRAM_OE_N : out std_logic;
	SRAM_DQ   : in  std_logic_vector (15 downto 0);
  -- Time
	CLOCK_50  : in  std_logic;
  start     : in  std_logic;
  freeRAM   : out std_logic;
  -- Values
  cnt       : in  integer range 0 to 262143;      -- 2^18 = 262144 cells in RAM
  delay     : in  integer range 0 to 262143;
  alpha     : in  integer range 0 to 65536;       -- 2^16 = 65536
  beta      : in  integer range 0 to 65536;
  -- output
  output    : out integer range 0 to 65536
);
end ram_reader;

architecture ram_reader_arch of ram_reader is

  type state_type is (start_is_0,ram_ready,x_read,done);
  
  signal state : state_type := start_is_0;
  signal x     : std_logic_vector (15 downto 0);      -- Read in RAM
	signal SRAM_ADDR_loc : std_logic_vector (17 downto 0);
	signal SRAM_WE_N_loc : std_logic;
	signal SRAM_OE_N_loc : std_logic;
	signal freeRAM_loc   : std_logic;

begin
  
  SRAM_ADDR <= SRAM_ADDR_loc when (freeRAM_loc = '0') else "ZZZZZZZZZZZZZZZZZZ";
  SRAM_WE_N <= SRAM_WE_N_loc when (freeRAM_loc = '0') else 'Z';
  SRAM_OE_N <= SRAM_OE_N_loc when (freeRAM_loc = '0') else 'Z';
  freeRAM   <= freeRAM_loc;
  
  process (CLOCK_50)
	begin
  
    case state is
      when start_is_0 =>
          if start = '0' then
            state <= start_is_0;
          else
            SRAM_ADDR_loc <= std_logic_vector(to_unsigned(cnt + delay,18));
            SRAM_OE_N_loc <= '0';
            SRAM_WE_N_loc <= '1';
            freeRAM_loc   <= '0';
            state <= ram_ready;
          end if;
      when ram_ready =>
          x       <= SRAM_DQ;
          freeRAM_loc <= '1';
          state <= x_read;
      when x_read =>
          output <= alpha ; -- * x + beta;
          state <= done;
      when done =>
          if start = '0' then
            state <= start_is_0;
          else
            state <= done;
          end if;
    end case;
  
  end process;
  
end ram_reader_arch;