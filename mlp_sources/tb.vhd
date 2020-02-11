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
    file input_weights_1 : text ;
    file input_biases_1 : text ;
    file input_weights_2 : text ;
    file input_biases_2 : text ;
    signal clk_s: std_logic;
    signal reset_s: std_logic;
    signal start_s: std_logic;
    signal ready_s: std_logic;
    signal toggle_s: std_logic;
    signal cl_num_s: std_logic_vector(3 downto 0);
    signal sdata_s: std_logic_vector(17 downto 0);
    signal svalid_s: std_logic;
    signal sready_s: std_logic;

    begin              
            -- DUT
            top_core: entity work.top(Behavioral)
            -- using default generics
            port map (
            ---- Clocking and reset interface
            clk => clk_s,
            reset => reset_s,
            ---- Command and Status interfaces 
            start => start_s,
            ready => ready_s,
            toggle => toggle_s,
            cl_num => cl_num_s,
            ---- Stream interface
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
        -- Apply system level reset
        reset_s <= '0';
        wait for 500 ns;
        reset_s <= '1';
        wait for 500 ns;
        reset_s <= '0';
        for k in 0 to 99 loop
            file_open(input_weights_1, "D:\ee36-86-2015\mlp_vhdl-master\params_18bits\weights1.txt", read_mode);
            file_open(input_weights_2, "D:\ee36-86-2015\mlp_vhdl-master\params_18bits\weights2.txt", read_mode);
            file_open(input_biases_1, "D:\ee36-86-2015\mlp_vhdl-master\params_18bits\biases1.txt", read_mode);
            file_open(input_biases_2, "D:\ee36-86-2015\mlp_vhdl-master\params_18bits\biases2.txt", read_mode);
            
            --wait until falling_edge(clk_s);
            start_s <= '1';
            wait for 200 ns;
            start_s <= '0';
            for i in 0 to 783 loop
                wait until sready_s = '1';
                readline(input_test_image,curr_value);
                sdata_s <= to_std_logic_vector(string(curr_value));
                svalid_s <= '1';
                wait for 250 ns;
                svalid_s <= '0';
                wait for 130ns;
            end loop;
            
            for j in 0 to 29 loop
                for i in 0 to 783 loop
                    wait until rising_edge(sready_s);
                    readline(input_weights_1,curr_value);
                    sdata_s <= to_std_logic_vector(string(curr_value));
                    svalid_s <= '1';
                    wait for 250 ns;
                    svalid_s <= '0';
                end loop;

                wait until sready_s = '1';
                readline(input_biases_1,curr_value);
                sdata_s <= to_std_logic_vector(string(curr_value));
                svalid_s <= '1';
                wait for 250 ns;
                svalid_s <= '0';
            end loop;
            
            for j in 0 to 9 loop
                for i in 0 to 29 loop
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

            wait until toggle_s = '1';
            wait until rising_edge(ready_s);
            file_close(input_weights_1);
            file_close(input_weights_2);
            file_close(input_biases_1);
            file_close(input_biases_2);
        end loop;
        wait;
        end process;
end architecture beh;