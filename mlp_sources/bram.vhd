----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/18/2020 06:01:49 PM
-- Design Name: 
-- Module Name: bram - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
-- use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bram is
    generic (WADDR: positive := 10;
    WDATA: positive := 16); 
    Port ( clka, clkb, ena, enb, wea, web : in STD_LOGIC;
           addra, addrb: in STD_LOGIC_VECTOR(WADDR-1 downto 0);
           dia, dib: in STD_LOGIC_VECTOR(WDATA-1 downto 0);
           doa, dob: out STD_LOGIC_VECTOR(WDATA-1 downto 0));
end bram;

architecture Behavioral of bram is
    type mem_array is array ((2** WADDR- 1) downto 0) of STD_LOGIC_VECTOR (WDATA-1 downto 0);
    signal mem: mem_array;
begin
--Dual-Port logic port A
    process (clka) begin
        if clka'event and clka = '1' then
            if ena = '1' then
                if wea = '1' then
                    mem (CONV_INTEGER (addra)) <= dia;
                end if;
            else
                doa <= mem (CONV_INTEGER (addra));
            end if;
        end if;
    end process;
--Dual-Port logic port B
    process (clkb) begin
        if clkb'event and clkb = '1' then
            if enb = '1' then
                if web = '1' then
                    mem (CONV_INTEGER (addrb)) <= dib;
                end if;
            else
                dob <= mem (CONV_INTEGER (addrb));
            end if;
        end if;
    end process;
end Behavioral;
