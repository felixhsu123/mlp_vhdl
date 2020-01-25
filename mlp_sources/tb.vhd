library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.txt_util.all;

--use work.utils_pkg.all;
entity mlp_tb is
end entity;

architecture beh of mlp_tb is
    file input_test_image : text open read_mode is "D:\ee36-86-2015\mlp_vhdl-master\params_18bits\input_images.txt";
    file input_weights_1 : text ;--open read_mode is "D:\ee36-86-2015\mlp_vhdl-master\params_18bits\weights1.txt";
    file input_biases_1 : text ;--open read_mode is "D:\ee36-86-2015\mlp_vhdl-master\params_18bits\biases1.txt";
    file input_weights_2 : text ;--open read_mode is "D:\ee36-86-2015\mlp_vhdl-master\params_18bits\weights2.txt";
    file input_biases_2 : text ;--open read_mode is "D:\ee36-86-2015\mlp_vhdl-master\params_18bits\biases2.txt";
    signal clk_s: std_logic;
    signal reset_s: std_logic;
--    signal mem_a_addr_s: std_logic_vector(9 downto 0);
--    signal mem_a_data_in_s: std_logic_vector(15 downto 0);
--    signal mem_a_data_out_s: std_logic_vector(15 downto 0);
--    signal mem_a_wr_s: std_logic;
--    signal mem_a_en_s: std_logic;
    signal start_s: std_logic;
    signal ready_s: std_logic;
    signal toggle_s: std_logic;
    signal cl_num_s: std_logic_vector(3 downto 0);
    signal sdata_s: std_logic_vector(17 downto 0);
    signal svalid_s: std_logic;
    signal sready_s: std_logic;
    
    

    begin
    
    --        -- BRAM connections
    --        matrix_a_mem: entity work.bram(Behavioral)
    --        --generic map (
    --        --    WADDR => DATA_WIDTH_c,
    --        --    WDATA => SIZE_c)
    --        port map (
    --            clka => clk_s,
    --            reset => reset_s,
    --            addra => mem_a_addr_s,
    --            dia => mem_a_data_in_s,
    --            doa => mem_a_data_out_s,
    --            wea => mem_a_wr_s,
    --            ena => mem_a_en_s);
                
            -- DUT
            top_core: entity work.top(Behavioral)
            --generic map (
            --WIDTH => DATA_WIDTH_c,
            --SIZE => SIZE_c)
            port map (
            ---- Clocking and reset interface
            clk => clk_s,
            reset => reset_s,
            ---- Command and Status interfaces 
            start => start_s,
            ready => ready_s,
            toggle => toggle_s,
            cl_num => cl_num_s,
            ----
            sdata => sdata_s,
            svalid => svalid_s,
            sready => sready_s);
            
        clk_gen: process
        begin
            clk_s <= '0', '1' after 100 ns;
            wait for 200 ns;
        end process;
        
        stim_gen: process
            variable curr_value : line;
        begin
        for k in 0 to 9 loop
            file_open(input_weights_1, "D:\ee36-86-2015\mlp_vhdl-master\params_18bits\weights1.txt", read_mode);
            file_open(input_weights_2, "D:\ee36-86-2015\mlp_vhdl-master\params_18bits\weights2.txt", read_mode);
            file_open(input_biases_1, "D:\ee36-86-2015\mlp_vhdl-master\params_18bits\biases1.txt", read_mode);
            file_open(input_biases_2, "D:\ee36-86-2015\mlp_vhdl-master\params_18bits\biases2.txt", read_mode);
            -- Apply system level reset
            reset_s <= '0';
            wait for 500 ns;
            reset_s <= '1';
            wait for 500 ns;
            reset_s <= '0';
            wait until falling_edge(clk_s);
            -- Load the data into the matrix A memory
            start_s <= '1';
            wait for 100 ns;
            start_s <= '0';
            for i in 0 to 783 loop
                wait until sready_s = '1';
                readline(input_test_image,curr_value);
                sdata_s <= to_std_logic_vector(string(curr_value));
                svalid_s <= '1';
                wait for 250 ns;
                svalid_s <= '0';
            end loop;
            
            --wait until toggle = '1'
            for j in 0 to 29 loop
                for i in 0 to 783 loop
                    wait until sready_s = '1';
                    readline(input_weights_1,curr_value);
                    sdata_s <= to_std_logic_vector(string(curr_value));
                    svalid_s <= '1';
                    wait for 250 ns;
                    svalid_s <= '0';
                end loop;
                --wait for 500ns;
                wait until sready_s = '1';
                readline(input_biases_1,curr_value);
                sdata_s <= to_std_logic_vector(string(curr_value));
                svalid_s <= '1';
                wait for 250 ns;
                svalid_s <= '0';
            end loop;
            
            for j in 0 to 9 loop
                for i in 0 to 29 loop
            --while not endfile(input_weights) loop
                    wait until sready_s = '1';
                    readline(input_weights_2,curr_value);
                    sdata_s <= to_std_logic_vector(string(curr_value));
                    svalid_s <= '1';
                    wait for 250 ns;
                    svalid_s <= '0';
                end loop;
               -- wait for 500ns;
                wait until sready_s = '1';
                readline(input_biases_2,curr_value);
                sdata_s <= to_std_logic_vector(string(curr_value));
                svalid_s <= '1';
                wait for 250 ns;
                svalid_s <= '0';
            end loop;
            
            svalid_s <= '0';
            wait for 1000 ns;
            --wait until ready_s = '1';
            file_close(input_weights_1);
            file_close(input_weights_2);
            file_close(input_biases_1);
            file_close(input_biases_2);
            wait until rising_edge(ready_s);
        end loop;
                        
--            mem_a_addr_s <= conv_std_logic_vector(i*M_c+j, mem_a_addr_s'length);
--            mem_a_data_in_s <= MEM_A_CONTENT_c(i*M_c+j);
--            wait until falling_edge(clk_s);
--            --end loop;
--            --end loop;
--            mem_a_wr_s <= '0';
--            -- Load the data into the matrix B memory
--            mem_b_wr_s <= '1';
--            for i in 0 to M_c-1 loop
--            for j in 0 to P_c-1 loop
--            mem_b_addr_s <= conv_std_logic_vector(i*P_c+j, mem_b_addr_s'length);
--            mem_b_data_in_s <= MEM_B_CONTENT_c(i*P_c+j);
--            wait until falling_edge(clk_s);
--            end loop;
--            end loop;
--            mem_b_wr_s <= '0';
--            -- Start the multiplication process
--            start_s <= '1';
--            wait until falling_edge(clk_s);
--            start_s <= '0';
--            -- Wait until matrix multiplication module signals operation has been complted
--            wait until ready_s = '1';
--            -- End stimulus generation
--            wait;
        end process;
        

end architecture beh;