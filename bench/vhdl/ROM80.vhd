library ieee;
use ieee.std_logic_1164.all;

entity ROM80 is
  port (
    CE_n : in std_logic;
    OE_n : in std_logic;
    A : in std_logic_vector(14 downto 0);
    D : out std_logic_vector(7 downto 0)
  );
end entity ROM80;

architecture rtl of ROM80 is
  type mem is array ( 0 to 7 ) of std_logic_vector(7 downto 0);
  constant ROM : mem := (
    x"F3", x"3E", x"45", x"32",
    x"00", x"80", x"00", x"76"
  );
begin
  process (A, OE_n, CE_n)
  begin
    if OE_n = '0' and CE_n = '0' then
      case A is
        when "000000000000000" => D <= ROM(0);
        when "000000000000001" => D <= ROM(1);
        when "000000000000010" => D <= ROM(2);
        when "000000000000011" => D <= ROM(3);
        when "000000000000100" => D <= ROM(4);
        when "000000000000101" => D <= ROM(5);
        when "000000000000110" => D <= ROM(6);
        when "000000000000111" => D <= ROM(7);
        when others => D <= "00000000";
      end case;
    else
      D <= "ZZZZZZZZ";
    end if;
  end process;
end architecture rtl;
