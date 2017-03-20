--
-- Copyright (c) 2015 Marko Zec, University of Zagreb
-- Adapted for XO3 - Mario Vigliar, DPControl Srl Italy
--
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions
-- are met:
-- 1. Redistributions of source code must retain the above copyright
--    notice, this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright
--    notice, this list of conditions and the following disclaimer in the
--    documentation and/or other materials provided with the distribution.
--
-- THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
-- ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
-- FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
-- DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
-- OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
-- HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
-- LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
-- OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
-- SUCH DAMAGE.
--
-- $Id$
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.f32c_pack.all;


entity glue is
    generic (
	-- ISA: either ARCH_MI32 or ARCH_RV32
	C_arch: integer := ARCH_MI32;
	C_debug: boolean := false;

	-- Main clock: 50, 62, 75, 81, 87, 100, 112, 125, 137, 150 MHz
	-- Used 48 due to PLL limitations in XO3 devices
	C_clk_freq: integer := 48;

	-- SoC configuration options
	C_bram_size: integer := 16;
	C_sio: integer := 1;
	C_spi: integer := 0;
	C_gpio: integer := 0;
	C_simple_io: boolean := true;
	C_timer: boolean := false
    );
    port (
	clk_12m: in std_logic;
	clk_ena: out std_logic;
	clk_dbg: out std_logic;
	--reset_n: in std_logic;
	rs232_tx: out std_logic;
	rs232_rx: in std_logic;
	led: out std_logic_vector(7 downto 0);
	sw: in std_logic_vector(3 downto 0)
    );
end glue;

architecture Behavioral of glue is
    signal clk, rs232_break, rs232_break_n: std_logic;
    signal sw_n: std_logic_vector(3 downto 0);
    signal led_n: std_logic_vector(7 downto 0);
	
begin
	
	
    -- clock synthesizer: Lattice XO3 specific
    clkgen : entity work.xo3lstarter_clkgen_50_12
      port map (CLKI => clk_12m, CLKOP => clk, LOCK => clk_ena);
    --clk_ena <= '1';
    --clk <= clk_12m;
	
	clk_dbg <= clk;

    -- generic BRAM glue
    glue_bram: entity work.glue_bram
    generic map (
	C_arch => C_arch,
	C_clk_freq => C_clk_freq,
	C_bram_size => C_bram_size,
	C_sio => C_sio,
	C_spi => C_spi,
	C_gpio => C_gpio,
	C_timer => C_timer
    )
    port map (
	clk => clk,
	sio_txd(0) => rs232_tx, sio_rxd(0) => rs232_rx,
	sio_break(0) => rs232_break,
	spi_sck => open, spi_ss => open, spi_mosi => open, spi_miso => open,
	gpio => open,
	simple_out(7 downto 0) => led_n, simple_out(31 downto 8) => open,
	simple_in(4 downto 0) => open,   simple_in(15 downto 5) => open,
	simple_in(19 downto 16) => sw_n, simple_in(31 downto 20) => open
    );
    sw_n <= not sw;
    led <= not led_n;
	rs232_break_n <= not rs232_break;
	
end Behavioral;