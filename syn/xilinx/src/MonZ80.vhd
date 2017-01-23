-- This file was generated with xrom written by Daniel Wallner

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MonZ80 is
	port(
		Clk	: in std_logic;
		A	: in std_logic_vector(10 downto 0);
		D	: out std_logic_vector(7 downto 0)
	);
end MonZ80;

architecture rtl of MonZ80 is
	component RAMB4_S8
		port(
			DO     : out std_logic_vector(7 downto 0);
			ADDR   : in std_logic_vector(8 downto 0);
			CLK    : in std_ulogic;
			DI     : in std_logic_vector(7 downto 0);
			EN     : in std_ulogic;
			RST    : in std_ulogic;
			WE     : in std_ulogic);
	end component;

	type bRAMOut_a is array(0 to 3) of std_logic_vector(7 downto 0);
	signal bRAMOut : bRAMOut_a;
	signal biA_r : integer;
	signal A_r : unsigned(A'left downto 9);
begin
	process (Clk)
	begin
		if Clk'event and Clk = '1' then
			A_r <= unsigned(A(A'left downto 9));
		end if;
	end process;

	biA_r <= to_integer(A_r(A'left downto 9));

	bG1: for I in 0 to 3 generate
		bG2: for J in 0 to 0 generate
			BMonZ80 : RAMB4_S8
				port map (DI => "00000000", EN => '1', RST => '0', WE => '0', CLK => Clk, ADDR => A(8 downto 0), DO => bRAMOut(I)(7 + 8 * J downto 8 * J));
		end generate;
	end generate;

	process (biA_r, bRAMOut)
	begin
		D <= bRAMOut(0)(D'range);
		for I in 1 to 3 loop
			if biA_r = I then
				D <= bRAMOut(I)(D'range);
			end if;
		end loop;
	end process;
end;
