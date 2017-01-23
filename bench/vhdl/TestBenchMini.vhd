library IEEE;
use IEEE.std_logic_1164.all;
library std;
use std.env.all;

entity TestBenchMini is
end entity TestBenchMini;

architecture behaviour of TestBenchMini is

	signal M1_n			: std_logic;
	signal MREQ_n		: std_logic;
	signal IORQ_n		: std_logic;
	signal RD_n			: std_logic;
	signal WR_n			: std_logic;
	signal RFSH_n		: std_logic;
	signal HALT_n		: std_logic;
	signal WAIT_n		: std_logic := '1';
	signal INT_n		: std_logic := '1';
	signal NMI_n		: std_logic := '1';
	signal RESET_n		: std_logic;
	signal BUSRQ_n		: std_logic := '1';
	signal BUSAK_n		: std_logic;
	signal CLK_n		: std_logic := '0';
	signal A			: std_logic_vector(15 downto 0);
	signal D			: std_logic_vector(7 downto 0);

	signal IOWR_n		: std_logic;
	signal ROMCS_n		: std_logic;
	signal RAMCS_n		: std_logic;

begin

	Reset_n <= '0', '1' after 1 us;

	-- 16 MHz clock
	CLK_n <= not CLK_n after 31.25 ns;

        -- Stop after 3.5us
        simulate :process
        begin
          wait for 3.5 us;
          finish;
        end process;
        
	IOWR_n <= WR_n or IORQ_n;
	ROMCS_n <= A(15) or MREQ_n;
	RAMCS_n <= not A(15) or MREQ_n;

	-- NMI
	NMI_n <= not D(0) when IOWR_n'event and IOWR_n = '1' and A(7 downto 0) = "00001000";
	-- INT
	INT_n <= not D(1) when IOWR_n'event and IOWR_n = '1' and A(7 downto 0) = "00001000";

	u0 : entity work.T80a
			port map(
				RESET_n,
				CLK_n,
				WAIT_n,
				INT_n,
				NMI_n,
				BUSRQ_n,
				M1_n,
				MREQ_n,
				IORQ_n,
				RD_n,
				WR_n,
				RFSH_n,
				HALT_n,
				BUSAK_n,
				A,
				D);

	u1 : entity work.ROM80
			port map(
				CE_n => ROMCS_n,
				OE_n => RD_n,
				A => A(14 downto 0),
				D => D);

	u2 : entity work.SRAM
			generic map(
				AddrWidth => 15)
			port map(
				CE_n => RAMCS_n,
				OE_n => RD_n,
				WE_n => WR_n,
				A => A(14 downto 0),
				D => D);

end;
