----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/11/2020 01:21:59 PM
-- Design Name: 
-- Module Name: mlp - Behavioral
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
--use IEEE.std_logic_arith.ALL;
use ieee.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mlp is
    generic (WIDTH: positive := 16;
    IMG_LEN: positive := 784;
    LAYER_NUM: positive := 3); 
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           --status
           start: in STD_LOGIC;
           ready: out STD_LOGIC;
           toggle: out STD_LOGIC;
           cl_num: out STD_LOGIC_VECTOR(3 downto 0);
           --stream interface aka fifo interface
           sdata: in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
           svalid: in STD_LOGIC;
           sready: out STD_LOGIC;
           --bram interface
           bdata_in: in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
           bdata_out: out STD_LOGIC_VECTOR(WIDTH-1 downto 0);
           baddr: out STD_LOGIC_VECTOR(9 downto 0);
           en: out STD_LOGIC;
           we: out STD_LOGIC);
end mlp;

architecture Behavioral of mlp is
    type state_type is (idle, start_state, wait_pixel, load_pixel, layer_state, wait_weight, load_weight,
    wait_bias, load_bias, neuron_state, synapse_state, cont, find_res, end_state);
    signal state_reg, state_next: state_type;
    signal acc_reg, acc_next: STD_LOGIC_VECTOR(27 downto 0);
    signal acc_tmp_reg, acc_tmp_next: STD_LOGIC_VECTOR(27 downto 0);
    signal product_tmp_reg, product_tmp_next: STD_LOGIC_VECTOR(31 downto 0);
    signal p_reg, p_next: STD_LOGIC_VECTOR(9 downto 0); --max 784
    signal layer_reg, layer_next: STD_LOGIC_VECTOR(1 downto 0); --max 2
    signal neuron_reg, neuron_next: STD_LOGIC_VECTOR(4 downto 0); --max 30
    signal i_reg, i_next: STD_LOGIC_VECTOR(9 downto 0); --max 784
    signal j_reg, j_next: STD_LOGIC_VECTOR(3 downto 0); --max 10
    signal sdata_reg, sdata_next: STD_LOGIC_VECTOR(WIDTH-1 downto 0);
    signal res_reg, res_next: STD_LOGIC_VECTOR(3 downto 0); 
    signal max_reg, max_next: STD_LOGIC_VECTOR(WIDTH-1 downto 0);
    signal currmax_reg, currmax_next: STD_LOGIC_VECTOR(WIDTH-1 downto 0);
    type mem_t is array(0 to 2) of positive;--std_logic_vector(DATA_WIDTH_c - 1 downto 0);
    constant neuron_array: mem_t := (784, 30, 10);--(conv_std_logic_vector(1, DATA_WIDTH_c),conv_std_logic_vector(2, DATA_WIDTH_c),conv_std_logic_vector(3, DATA_WIDTH_c));
begin
    --state register
    process (clk, reset) is
    begin
        if (reset = '1') then
            state_reg <= idle;
            acc_reg <= (others => '0');
            acc_tmp_reg <= (others => '0');
            product_tmp_reg <= (others => '0');
            p_reg <= (others => '0');
            layer_reg <= (others => '0');
            neuron_reg <= (others => '0');
            i_reg <= (others => '0');
            j_reg <= (others => '0');
            sdata_reg <= (others => '0');
            res_reg <= (others => '0');
            max_reg <= (others => '0');
            currmax_reg <= (others => '0');

        elsif (clk'event and clk = '1') then
            state_reg <= state_next;
            acc_reg <= acc_next;
            acc_tmp_reg <= acc_tmp_next;
            product_tmp_reg <= product_tmp_next;
            p_reg <= p_next;
            layer_reg <= layer_next;
            neuron_reg <= neuron_next;
            i_reg <= i_next;
            j_reg <= j_next;
            sdata_reg <= sdata_next;
            res_reg <= res_next;
            max_reg <= max_next;
            currmax_reg <= currmax_next;
        end if;
    end process;
    
    --next state comb logic
    process(state_reg, xxxx)

    begin
--	res_next <= res_reg;
--	acc_next <= acc_reg;
--    p_next <= p_reg;
--    layer_next <= layer_reg;
--    neuron_next <= neuron_reg;
--    i_next <= i_reg;
--    state_next <= state_reg;
--    sdata_next <= sdata_reg;
      baddr <= (others => '0');
      bdata_out <= (others => '0');
      en <= '0';
      we <= '0';
      ready <= '0';
      toggle <= '0';
      sready <= '0';
        case state_reg is
            when idle =>
                res_next <= (others => '0');
                acc_next <= (others => '0');
                p_next <= (others => '0');
                layer_next <= (others => '0');
                neuron_next <= (others => '0');
                i_next <= (others => '0');
                sdata_next <= (others =>'0');
                ready <= '1';
                if start = '1' then  state_next <= start_state;
                else state_next <= idle;
                end if;
            when start_state =>
                toggle <= '1';
                state_next <= wait_pixel;
            when wait_pixel =>
                sready <= '1';
                if svalid = '1' then state_next <= load_pixel;
                else state_next <= wait_pixel;
                end if;

            when load_pixel =>
                    baddr <= p_reg;
                    bdata_out <= sdata;
                    en <= '1';
                    we <= '1';
                    toggle <= '0';
                    p_next <= std_logic_vector( unsigned(p_reg) + 1 );
                    if unsigned(p_next) < IMG_LEN then
                        state_next <= wait_pixel;
                    else
                        layer_next <= "01";
                        state_next <= layer_state;
                    end if;
            when layer_state =>
                    neuron_next <= (others => '0');
                    state_next <= neuron_state;
            when neuron_state =>
                    acc_next <= (others => '0');
                    i_next <= (others => '0');
                    state_next <= synapse_state;
            when synapse_state =>
                    toggle <= '1';
                    state_next <= wait_weight;       
            when wait_weight =>
                    sready <= '1';
                    if svalid = '1' then 
                        state_next <= load_weight;
                        --baddr <= i_reg; --will have to change later
                        baddr <= std_logic_vector (unsigned(start_addr(unsigned(layer_reg) - 1)) + unsigned(i_reg)); --get this under control
                        en<='1';
                        we<='0';
                        sdata_next <= sdata;
                    else
                        state_next <= wait_weight;
                    end if;
            when load_weight =>
                    product_tmp_next <= std_logic_vector(signed(bdata_in)*signed(sdata_reg));
                    acc_next <= std_logic_vector(signed(acc_reg) + signed(product_tmp_next(29 downto 14)));
                    toggle <= '0';
                    i_next <= std_logic_vector(unsigned(i_reg) + 1);
                    if unsigned(i_next) < neuron_array(signed(layer_reg) - 1)
                    then 
                        state_next <= synapse_state;
                    else 
                        toggle <= '1'; 
                        state_next <= wait_bias;
                    end if;
            when wait_bias =>
                    sready <= '1';
                    if svalid = '1' then 
                        state_next <= load_bias;
                        en<='1';
                        we<='0';
                        sdata_next <= sdata;
                    else
                        state_next <= wait_bias;
                    end if;
            when load_bias =>
                    toggle <= '0';
                    acc_tmp_next <= std_logic_vector(signed(acc_reg) + signed(sdata_reg));
                    --if signed(acc_tmp) < 0 then acc_next <= acc_tmp * 0.001;
                    if acc_tmp_next(acc_tmp_next'left) = '1' then acc_next <= std_logic_vector(signed(acc_tmp_next) * 0.001);
                    end if;
                    --write result in bram
                    baddr <= std_logic_vector(start_addr(layer)+neuron_reg);
                    bdata_out <= acc_next(15 downto 0);
                    en <= '1';
                    we <= '1';
                    neuron_next <= std_logic_vector(unsigned(neuron_reg) + 1);
                    if neuron_next < neuron_array(unsigned(layer_reg)) then state_next <= neuron_state;
                    else state_next <=cont;
                    end if;
            when cont =>
                    layer_next  <= std_logic_vector(unsigned(layer_reg) + 1);
                    if (unsigned(layer_next) < LAYER_NUM) then state_next <=layer_state;
                    else
                        --read from bram
                        baddr <= std_logic_vector(start_addr( LAYER_NUM - 1));
                        en <= '1';
                        we <= '0';
                        max_next <= bdata_in;
                        res_next <= (others=>'0');
                        j_next <= "0001";
                        state_next <= find_res;
                    end if;
            when find_res =>
                   --read from bram
                  baddr <= std_logic_vector(unsigned(j_reg) + start_addr( LAYER_NUM - 1));
                  en <= '1';
                  we <= '0';
                  currmax_next <= bdata_in;
                  if (currmax_next > max_reg) then
                  	max_next <= currmax_next;
                  	res_next <= j_reg;
                  	j_next <= std_logic_vector(unsigned(j_reg) + 1);
                  end if;
                  if(j_next = "1010") then
                  	state_next <= end_state;
            	else
                  	state_next <= find_res;
             	end if;
       	when end_state =>
       		toggle <= '1';
       		cl_num <= res_reg;
       		state_next <= idle;
                  --res_next <= (others=>'0');
                  --j_next <= std_logic_vector(1);
                  --state_next <= find_res;
            end case;
            
    end process;

end Behavioral;
