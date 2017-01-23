library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.T80_Pack.all;

entity Z80SoC_Atlys is
  port(
    AtlysClk : in std_logic;
    AtlysReset_n : in std_logic;
    LED : out std_logic_vector(7 downto 0);
    UP : in std_logic;
    LEFT : in std_logic;
    DOWN : in std_logic;
    RIGHT : in std_logic;
    CENTER : in std_logic;
    SWITCH : in std_logic_vector(7 downto 0)
  );
end Z80SoC_Atlys;

architecture rtl of Z80SoC_Atlys is
  signal T80Clk : std_logic;
  signal MREQ_n : std_logic;
  signal IORQ_n : std_logic;
  signal RD_n : std_logic;
  signal WR_n : std_logic;
  signal A : std_logic_vector(15 downto 0);
  signal D : std_logic_vector(7 downto 0);

  signal ROM_enable : boolean;
  signal ROM_address : integer;
  constant ROM_words : integer := 8;
  type ROM_type is array ( 0 to ROM_words-1 ) of std_logic_vector(7 downto 0);
  constant ROM : ROM_type := (
    x"F3", x"3E", x"45", x"32",
    x"00", x"80", x"00", x"76"
  );
    
  signal RAM_enable : boolean;
  signal RAM_event : boolean;
  signal RAM_address : integer;
  constant RAM_Abits : integer := 11;
  type RAM_type is array (natural range <>) of std_logic_vector(7 downto 0);
  signal RAM : RAM_type(0 to 2**RAM_Abits - 1);
  signal RAM_D : std_logic_vector(7 downto 0);

  signal IO_enable : boolean;
  signal IO_event : boolean;
  
begin
  -- Run at external clock frequency
  T80Clk <= AtlysClk;
  
  cpu : entity work.T80a
    port map(
      RESET_n => AtlysReset_n,
      CLK_n => T80Clk,
      WAIT_n => '1', -- No wait states needed
      INT_n => '1', -- No interrupts yet
      NMI_n => '1', -- No non-maskable interrupt,
      BUSRQ_n => '1', -- No bus request
      M1_n => open,
      MREQ_n => MREQ_n,
      IORQ_n => IORQ_n,
      RD_n => RD_n,
      WR_n => WR_n,
      RFSH_n => open,
      HALT_n => open,
      BUSAK_n => open,
      A => A,
      D => D
    );

  -- ROM read if A(15) = 0 and it is a mem request and not writing
  -- CPU will start executing commands from address 0 thus from ROM.
  ROM_enable <= A(15) = '0' and MREQ_n = '0' and RD_n = '0';
  ROM_address <= to_integer(unsigned(A(14 downto 0)));
  D <= ROM(ROM_address) when ROM_enable and ROM_address < ROM_words
       else "00000000" when ROM_enable;

  -- RAM access if A(15) = 1 and it is a mem request
  RAM_enable <= A(15) = '1' and MREQ_n = '0';
  RAM_event <= Rising_edge(T80Clk) and RAM_enable;
  RAM_address <= to_integer(unsigned(A(RAM_Abits-1 downto 0)));

  RAM_D <= RAM(RAM_address) when RAM_event and RD_n = '0';
  D <= RAM_D when RAM_enable and RD_n = '0';

  RAM(RAM_address) <= D when RAM_event and WR_n = '0';

  -- IO, we ignore IO address for the moment
  IO_enable <= IORQ_n = '0';
  IO_event <= Rising_edge(T80Clk) and IO_enable;
  
  D <= SWITCH when IO_enable and RD_n = '0';

  LED <= D when IO_event and WR_n = '0';
  
end architecture rtl;
