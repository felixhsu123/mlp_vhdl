----------------------------------------------------------------------------------
-- Company: 
-- Engineer: MaMa
-- 
-- Create Date: 01/27/2020 06:36:33 PM
-- Design Name: 
-- Module Name: tb - Behavioral
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.txt_util.all;

entity tb is
--  Port ( );
end tb;

architecture Behavioral of tb is
    file input_test_image : text open read_mode is "D:\ee36-86-2015\mlp_vhdl-master\params_18bits\input_images.txt";
    file input_weights_1 : text ;
    file input_biases_1 : text ;
    file input_weights_2 : text ;
    file input_biases_2 : text ;
    signal clk_s: std_logic;
    signal reset_s: std_logic;
    -- Matrix multiplier core's address map
    constant START_REG_ADDR_C : integer := 0;
    constant READY_REG_ADDR_C : integer := 4;
    constant TOGGLE_REG_ADDR_C : integer := 8;
    constant CL_NUM_REG_ADDR_C : integer := 12;
    constant SREADY_REG_ADDR_C : integer := 16;
    constant SVALID_REG_ADDR_C : integer := 20;
    constant SDATA_REG_ADDR_C : integer := 24;
     -- Parameters of Axi-Lite Slave Bus Interface S00_AXI
    constant C_S00_AXI_DATA_WIDTH_c : integer := 32;
    constant C_S00_AXI_ADDR_WIDTH_c : integer := 5;
     -- Ports of Axi-Lite Slave Bus Interface S01_AXI
    signal s00_axi_aclk_s : std_logic := '0';
    signal s00_axi_aresetn_s : std_logic := '1';
    signal s00_axi_awaddr_s : std_logic_vector(C_S00_AXI_ADDR_WIDTH_c-1 downto 0) := (others => '0');
    signal s00_axi_awprot_s : std_logic_vector(2 downto 0) := (others => '0');
    signal s00_axi_awvalid_s : std_logic := '0';
    signal s00_axi_awready_s : std_logic := '0';
    signal s00_axi_wdata_s : std_logic_vector(C_S00_AXI_DATA_WIDTH_c-1 downto 0) := (others => '0');
    signal s00_axi_wstrb_s : std_logic_vector((C_S00_AXI_DATA_WIDTH_c/8)-1 downto 0) := (others => '0');
    signal s00_axi_wvalid_s : std_logic := '0';
    signal s00_axi_wready_s : std_logic := '0';
    signal s00_axi_bresp_s : std_logic_vector(1 downto 0) := (others => '0');
    signal s00_axi_bvalid_s : std_logic := '0';
    signal s00_axi_bready_s : std_logic := '0';
    signal s00_axi_araddr_s : std_logic_vector(C_S00_AXI_ADDR_WIDTH_c-1 downto 0) := (others => '0');
    signal s00_axi_arprot_s : std_logic_vector(2 downto 0) := (others => '0');
    signal s00_axi_arvalid_s : std_logic := '0';
    signal s00_axi_arready_s : std_logic := '0';
    signal s00_axi_rdata_s : std_logic_vector(C_S00_AXI_DATA_WIDTH_c-1 downto 0) := (others => '0');
    signal s00_axi_rresp_s : std_logic_vector(1 downto 0) := (others => '0');
    signal s00_axi_rvalid_s : std_logic := '0';
    signal s00_axi_rready_s : std_logic := '0';
begin
        clk_gen: process
        begin
            clk_s <= '0', '1' after 100 ns;
            wait for 200 ns;
        end process;

        stimulus_generator: process
         variable curr_value : line;
         variable axi_read_data_v : std_logic_vector(31 downto 0);
         variable transfer_size_v : integer;
         begin
            -- reset AXI-lite interface. Reset will be 10 clock cycles wide
            s00_axi_aresetn_s <= '0';
            -- wait for 5 falling edges of AXI-lite clock signal
            for i in 1 to 5 loop
                wait until falling_edge(clk_s);
            end loop;
            -- release reset
            s00_axi_aresetn_s <= '1';
            wait until falling_edge(clk_s);
            end process;
            for k in 0 to 9 loop
                file_open(input_weights_1, "D:\ee36-86-2015\mlp_vhdl-master\params_18bits\weights1.txt", read_mode);
                file_open(input_weights_2, "D:\ee36-86-2015\mlp_vhdl-master\params_18bits\weights2.txt", read_mode);
                file_open(input_biases_1, "D:\ee36-86-2015\mlp_vhdl-master\params_18bits\biases1.txt", read_mode);
                file_open(input_biases_2, "D:\ee36-86-2015\mlp_vhdl-master\params_18bits\biases2.txt", read_mode);
                 report "Loading the matrix dimensions information into the Matrix Multiplier core!";
                ------------------- STARTING MLP ------------------------------------
                report "Starting MLP!";
                -- Set the value start bit (bit 0 in the START register) to 1
                wait until falling_edge(clk_s);
                s00_axi_awaddr_s <= conv_std_logic_vector(START_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
                s00_axi_awvalid_s <= '1';
                s00_axi_wdata_s <= conv_std_logic_vector(1, C_S00_AXI_DATA_WIDTH );
                s00_axi_wvalid_s <= '1';
                s00_axi_wstrb_s <= "1111";
                s00_axi_bready_s <= '1';
                wait until s00_axi_awready_s = '1';
                wait until s00_axi_awready_s = '0';
                wait until falling_edge(clk_s);
                s00_axi_awaddr_s <= conv_std_logic_vector(0, C_S00_AXI_ADDR_WIDTH_c);
                s00_axi_awvalid_s <= '0';
                s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c);
                s00_axi_wvalid_s <= '0';
                s00_axi_wstrb_s <= "0000";
                wait until s00_axi_bvalid_s = '0';
                wait until falling_edge(clk_s);
                s00_axi_bready_s <= '0';
                wait until falling_edge(clk_s); 
                
                -- wait for 5 falling edges of AXI-lite clock signal
                for i in 1 to 5 loop
                wait until falling_edge(clk_s);
                end loop;
                
                report "Clearing the start bit!";
                -- Set the value start bit (bit 0 in the START register) to 0
                wait until falling_edge(clk_s);
                s00_axi_awaddr_s <= conv_std_logic_vector(START_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
                s00_axi_awvalid_s <= '1';
                s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c);
                s00_axi_wvalid_s <= '1';
                s00_axi_wstrb_s <= "1111";
                s00_axi_bready_s <= '1';
                wait until s00_axi_awready_s = '1';
                wait until s00_axi_awready_s = '0';
                wait until falling_edge(clk_s);
                s00_axi_awaddr_s <= conv_std_logic_vector(0, C_S00_AXI_ADDR_WIDTH_c);
                s00_axi_awvalid_s <= '0';
                s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c);
                s00_axi_wvalid_s <= '0';
                s00_axi_wstrb_s <= "0000";
                wait until s00_axi_bvalid_s = '0';
                wait until falling_edge(clk_s);
                s00_axi_bready_s <= '0';
                wait until falling_edge(clk_s); 
                
                
                --send image
                for i in 0 to 783 loop
                    --wait until sready_s = '1';
                    report "Waiting for the MLP to be ready!";
                    loop
                        -- Read the content of the READY register
                        wait until falling_edge(clk_s);
                        s00_axi_araddr_s <= conv_std_logic_vector(READY_REG_ADDR_C, 5);
                        s00_axi_arvalid_s <= '1';
                        s00_axi_rready_s <= '1';
                        wait until s00_axi_arready_s = '1';
                        axi_read_data_v := s00_axi_rdata_s;
                        wait until s00_axi_arready_s = '0';
                        wait until falling_edge(clk_s);
                        s00_axi_araddr_s <= conv_std_logic_vector(0, 5);
                        s00_axi_arvalid_s <= '0';
                        s00_axi_rready_s <= '0';
                       
                        -- Check is the 1st bit of the READY register set to one
                        if (axi_read_data_v(0) = '1') then
                            --WAIT NO MORE, EXIT THE LOOP
                            exit;
                        else
                            wait for 1000 ns;
                        end if;
                    end loop;
                    
                    readline(input_test_image,curr_value);
                    sdata_s <= to_std_logic_vector(string(curr_value));
                    svalid_s <= '1';
                    wait for 250 ns;
                    svalid_s <= '0';
                    wait for 130ns;
                end loop;
            end loop;
                
                
end Behavioral;
