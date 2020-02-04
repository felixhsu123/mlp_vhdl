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
    file labels : text open read_mode is "D:\ee36-86-2015\mlp_vhdl-master\params_18bits\labels.txt";
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
         variable check_v: line;
         variable tmp : std_logic_vector(3 downto 0);
         variable tmp_output : std_logic_vector(3 downto 0);
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
            
            for k in 0 to 99 loop --100 test images
                file_open(input_weights_1, "D:\ee36-86-2015\mlp_vhdl-master\params_18bits\weights1.txt", read_mode);
                file_open(input_weights_2, "D:\ee36-86-2015\mlp_vhdl-master\params_18bits\weights2.txt", read_mode);
                file_open(input_biases_1, "D:\ee36-86-2015\mlp_vhdl-master\params_18bits\biases1.txt", read_mode);
                file_open(input_biases_2, "D:\ee36-86-2015\mlp_vhdl-master\params_18bits\biases2.txt", read_mode);
                --report "Loading the matrix dimensions information into the Matrix Multiplier core!";
                ------------------- STARTING MLP ------------------------------------
                --report "Waiting for the MLP to be ready!";
                loop
                    -- Read the content of the READY register
                    wait until falling_edge(clk_s);
                    s00_axi_araddr_s <= conv_std_logic_vector(READY_REG_ADDR_C, 5);
                    s00_axi_arvalid_s <= '1';
                    s00_axi_rready_s <= '1';
                    wait until s00_axi_arready_s = '1';
                    --axi_read_data_v := s00_axi_rdata_s;
                    wait until s00_axi_arready_s = '0';
                    axi_read_data_v := s00_axi_rdata_s;
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
                 --report "Reading CL_NUM register!";
                 --loop
                     wait until falling_edge(clk_s);
                     s00_axi_araddr_s <= conv_std_logic_vector(CL_NUM_REG_ADDR_C, 5);
                     s00_axi_arvalid_s <= '1';
                     s00_axi_rready_s <= '1';
                     wait until s00_axi_arready_s = '1';
                     wait until s00_axi_arready_s = '0';
                     axi_read_data_v := s00_axi_rdata_s;
                     wait until falling_edge(clk_s);
                     s00_axi_araddr_s <= conv_std_logic_vector(0, 5);
                     s00_axi_arvalid_s <= '0';
                     s00_axi_rready_s <= '0';
                     
                     if(k>0) then
                         readline(labels,check_v);
                         tmp := to_std_logic_vector(string(check_v));
                         tmp_output := axi_read_data_v(3 downto 0);
                         if(tmp = tmp_output) then
                            report "Correct classification " & integer'image(k);
                         else
                            report "Wrong classification" & integer'image(k);
                         end if;
                     end if;
                  --end loop;
                 --report "Starting MLP!";
                -- Set the value start bit (bit 0 in the START register) to 1
                wait until falling_edge(clk_s);
                s00_axi_awaddr_s <= conv_std_logic_vector(START_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
                s00_axi_awvalid_s <= '1';
                s00_axi_wdata_s <= conv_std_logic_vector(1, C_S00_AXI_DATA_WIDTH_c );
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
                
                --report "Clearing the start bit!";
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
                    -- Set pixel value
                    loop
                        -- Read the content of the SREADY register
                        --report "Reading sready register.";
                        wait until falling_edge(clk_s);
                        s00_axi_araddr_s <= conv_std_logic_vector(SREADY_REG_ADDR_C, 5);
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
                     
                    wait until falling_edge(clk_s);
                    --report "Writing sdata register: data_in=" & string(curr_value) & "h";
                    s00_axi_awaddr_s <= conv_std_logic_vector(SDATA_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
                    s00_axi_awvalid_s <= '1';
                    --s00_axi_wdata_s <= conv_std_logic_vector(curr_value, C_S00_AXI_DATA_WIDTH_c );
                    s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c - 18 ) & to_std_logic_vector(string(curr_value));
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
                    
                    wait until falling_edge(clk_s);
                    s00_axi_awaddr_s <= conv_std_logic_vector(SVALID_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
                    s00_axi_awvalid_s <= '1';
                    s00_axi_wdata_s <= conv_std_logic_vector(1, C_S00_AXI_DATA_WIDTH_c );
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
                    
                    
                    
                    wait until falling_edge(clk_s);
                    s00_axi_awaddr_s <= conv_std_logic_vector(SVALID_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
                    s00_axi_awvalid_s <= '1';
                    s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c );
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
                    
                end loop;
                
                for j in 0 to 29 loop
                    for i in 0 to 783 loop
                            loop
                                -- Read the content of the SREADY register
                                --report "Reading sready register.";
                                wait until falling_edge(clk_s);
                                s00_axi_araddr_s <= conv_std_logic_vector(SREADY_REG_ADDR_C, 5);
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
                             readline(input_weights_1,curr_value);
                                         
                        wait until falling_edge(clk_s);
                        --report "Writing sdata register: data_in=" & string(curr_value) & "h";
                        s00_axi_awaddr_s <= conv_std_logic_vector(SDATA_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
                        s00_axi_awvalid_s <= '1';
                        --s00_axi_wdata_s <= conv_std_logic_vector(curr_value, C_S00_AXI_DATA_WIDTH_c );
                        s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c - 18 ) & to_std_logic_vector(string(curr_value));
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
                        
                        wait until falling_edge(clk_s);
                        s00_axi_awaddr_s <= conv_std_logic_vector(SVALID_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
                        s00_axi_awvalid_s <= '1';
                        s00_axi_wdata_s <= conv_std_logic_vector(1, C_S00_AXI_DATA_WIDTH_c );
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
                        
                        --wait for 250 ns;
                        
                        wait until falling_edge(clk_s);
                        s00_axi_awaddr_s <= conv_std_logic_vector(SVALID_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
                        s00_axi_awvalid_s <= '1';
                        s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c );
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
                    end loop;
                    --now sending bias
                    loop
                        -- Read the content of the SREADY register
                        --report "Reading sready register.";
                        wait until falling_edge(clk_s);
                        s00_axi_araddr_s <= conv_std_logic_vector(SREADY_REG_ADDR_C, 5);
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
                    readline(input_biases_1,curr_value);
                                     
                    wait until falling_edge(clk_s);
                    --report "Writing bias in sdata register: data_in=" & string(curr_value) & "h";
                    s00_axi_awaddr_s <= conv_std_logic_vector(SDATA_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
                    s00_axi_awvalid_s <= '1';
                    --s00_axi_wdata_s <= conv_std_logic_vector(curr_value, C_S00_AXI_DATA_WIDTH_c );
                    s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c - 18 ) & to_std_logic_vector(string(curr_value));
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
                    
                    wait until falling_edge(clk_s);
                    s00_axi_awaddr_s <= conv_std_logic_vector(SVALID_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
                    s00_axi_awvalid_s <= '1';
                    s00_axi_wdata_s <= conv_std_logic_vector(1, C_S00_AXI_DATA_WIDTH_c );
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
                    
                    --wait for 250 ns;
                    
                    wait until falling_edge(clk_s);
                    s00_axi_awaddr_s <= conv_std_logic_vector(SVALID_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
                    s00_axi_awvalid_s <= '1';
                    s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c );
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
                end loop;
                
                --layer no. 2
                for j in 0 to 9 loop
                                    for i in 0 to 29 loop
                                            loop
                                                -- Read the content of the SREADY register
                                                --report "Reading sready register.";
                                                wait until falling_edge(clk_s);
                                                s00_axi_araddr_s <= conv_std_logic_vector(SREADY_REG_ADDR_C, 5);
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
                                             readline(input_weights_2,curr_value);
                                                         
                                        wait until falling_edge(clk_s);
                                        --report "Writing sdata register: data_in=" & string(curr_value) & "h";
                                        s00_axi_awaddr_s <= conv_std_logic_vector(SDATA_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
                                        s00_axi_awvalid_s <= '1';
                                        --s00_axi_wdata_s <= conv_std_logic_vector(curr_value, C_S00_AXI_DATA_WIDTH_c );
                                        s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c - 18 ) & to_std_logic_vector(string(curr_value));
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
                                        
                                        wait until falling_edge(clk_s);
                                        s00_axi_awaddr_s <= conv_std_logic_vector(SVALID_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
                                        s00_axi_awvalid_s <= '1';
                                        s00_axi_wdata_s <= conv_std_logic_vector(1, C_S00_AXI_DATA_WIDTH_c );
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
                                        
                                        --wait for 250 ns;
                                        
                                        wait until falling_edge(clk_s);
                                        s00_axi_awaddr_s <= conv_std_logic_vector(SVALID_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
                                        s00_axi_awvalid_s <= '1';
                                        s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c );
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
                                    end loop;
                                    --now sending bias
                                    loop
                                        -- Read the content of the SREADY register
                                        --report "Reading sready register.";
                                        wait until falling_edge(clk_s);
                                        s00_axi_araddr_s <= conv_std_logic_vector(SREADY_REG_ADDR_C, 5);
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
                                    readline(input_biases_2,curr_value);
                                                     
                                    wait until falling_edge(clk_s);
                                    --report "Writing bias in sdata register: data_in=" & string(curr_value) & "h";
                                    s00_axi_awaddr_s <= conv_std_logic_vector(SDATA_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
                                    s00_axi_awvalid_s <= '1';
                                    --s00_axi_wdata_s <= conv_std_logic_vector(curr_value, C_S00_AXI_DATA_WIDTH_c );
                                    s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c - 18 ) & to_std_logic_vector(string(curr_value));
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
                                    
                                    wait until falling_edge(clk_s);
                                    s00_axi_awaddr_s <= conv_std_logic_vector(SVALID_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
                                    s00_axi_awvalid_s <= '1';
                                    s00_axi_wdata_s <= conv_std_logic_vector(1, C_S00_AXI_DATA_WIDTH_c );
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
                                    
                                    --wait for 250 ns;
                                    
                                    wait until falling_edge(clk_s);
                                    s00_axi_awaddr_s <= conv_std_logic_vector(SVALID_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
                                    s00_axi_awvalid_s <= '1';
                                    s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c );
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
                                end loop;
                
                file_close(input_weights_1);
                file_close(input_weights_2);
                file_close(input_biases_1);
                file_close(input_biases_2);
                
            end loop;
            --check the result of last image classification
            loop
                -- Read the content of the READY register
                wait until falling_edge(clk_s);
                s00_axi_araddr_s <= conv_std_logic_vector(READY_REG_ADDR_C, 5);
                s00_axi_arvalid_s <= '1';
                s00_axi_rready_s <= '1';
                wait until s00_axi_arready_s = '1';
                --axi_read_data_v := s00_axi_rdata_s;
                wait until s00_axi_arready_s = '0';
                axi_read_data_v := s00_axi_rdata_s;
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
             --report "Reading CL_NUM register!";
                 wait until falling_edge(clk_s);
                 s00_axi_araddr_s <= conv_std_logic_vector(CL_NUM_REG_ADDR_C, 5);
                 s00_axi_arvalid_s <= '1';
                 s00_axi_rready_s <= '1';
                 wait until s00_axi_arready_s = '1';
                 wait until s00_axi_arready_s = '0';
                 axi_read_data_v := s00_axi_rdata_s;
                 wait until falling_edge(clk_s);
                 s00_axi_araddr_s <= conv_std_logic_vector(0, 5);
                 s00_axi_arvalid_s <= '0';
                 s00_axi_rready_s <= '0';
                 readline(labels,check_v);
                 tmp := to_std_logic_vector(string(check_v));
                 tmp_output := axi_read_data_v(3 downto 0);
                 if(tmp = tmp_output) then
                    report "Correct classification";
                 else
                    report "Wrong classification";
                 end if;
 
            wait;
            
        end process stimulus_generator;              
        
        MLP_V1: entity WORK.axi_mlp_core_v1_0 (arch_imp)
            port map(
                 -- Ports of Axi Slave Bus Interface S00_AXI
                 s00_axi_aclk => clk_s,
                 s00_axi_aresetn => s00_axi_aresetn_s,
                 s00_axi_awaddr => s00_axi_awaddr_s,
                 s00_axi_awprot => s00_axi_awprot_s, 
                 s00_axi_awvalid => s00_axi_awvalid_s,
                 s00_axi_awready => s00_axi_awready_s,
                 s00_axi_wdata => s00_axi_wdata_s,
                 s00_axi_wstrb => s00_axi_wstrb_s,
                 s00_axi_wvalid => s00_axi_wvalid_s,
                 s00_axi_wready => s00_axi_wready_s,
                 s00_axi_bresp => s00_axi_bresp_s,
                 s00_axi_bvalid => s00_axi_bvalid_s,
                 s00_axi_bready => s00_axi_bready_s,
                 s00_axi_araddr => s00_axi_araddr_s,
                 s00_axi_arprot => s00_axi_arprot_s,
                 s00_axi_arvalid => s00_axi_arvalid_s,
                 s00_axi_arready => s00_axi_arready_s,
                 s00_axi_rdata => s00_axi_rdata_s,
                 s00_axi_rresp => s00_axi_rresp_s,
                 s00_axi_rvalid => s00_axi_rvalid_s,
                 s00_axi_rready => s00_axi_rready_s);       
end Behavioral;
