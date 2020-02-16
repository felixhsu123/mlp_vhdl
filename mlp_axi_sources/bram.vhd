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
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
-- use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bram is
    generic (WADDR: positive := 10;
    WDATA: positive := 18); 
    Port ( clk,  ena,  wea : in STD_LOGIC;
           addra: in STD_LOGIC_VECTOR(WADDR-1 downto 0);
           dia : in STD_LOGIC_VECTOR(WDATA-1 downto 0);
           doa : out STD_LOGIC_VECTOR(WDATA-1 downto 0));
end bram;

architecture Behavioral of bram is
    type mem_t is array ((2** WADDR- 1) downto 0) of STD_LOGIC_VECTOR (WDATA-1 downto 0);
    signal mem_s: mem_t;
begin
--Dual-Port logic port A
    process (clk) begin
        if clk'event and clk = '1' then
                if ena = '1' then
                    if wea = '1' then
                        mem_s (CONV_INTEGER (addra)) <= dia;
                    else
                       doa <= mem_s (CONV_INTEGER (addra));
                    end if;
                end if;    
          end if;
    end process;

end Behavioral;
