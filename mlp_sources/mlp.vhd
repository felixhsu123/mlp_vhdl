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
    generic (WDATA: positive := 18; -- 4 + 14
    WADDR: positive := 10;
    ACC_WDATA: positive := 28; -- 14 + 14
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
           sdata: in STD_LOGIC_VECTOR(WDATA-1 downto 0);
           svalid: in STD_LOGIC;
           sready: out STD_LOGIC;
           --bram interface
           bdata_in: in STD_LOGIC_VECTOR(WDATA-1 downto 0);
           bdata_out: out STD_LOGIC_VECTOR(WDATA-1 downto 0);
           baddr: out STD_LOGIC_VECTOR(WADDR-1 downto 0);
           en: out STD_LOGIC;
           we: out STD_LOGIC);
end mlp;

architecture Behavioral of mlp is
    type state_type is (idle, start_state, wait_pixel, load_pixel, layer_state, wait_weight, load_weight,
    wait_bias, load_bias, neuron_state, synapse_state, cont, cont1, find_res, find_res_1, end_state);
    signal state_reg, state_next: state_type;
    signal acc_reg, acc_next: STD_LOGIC_VECTOR(ACC_WDATA - 1 downto 0);
    signal acc_tmp_reg, acc_tmp_next: STD_LOGIC_VECTOR(ACC_WDATA - 1 downto 0);
    signal acc_tmp2_reg, acc_tmp2_next: STD_LOGIC_VECTOR(ACC_WDATA + 16 - 1 downto 0); 
    signal product_tmp_reg, product_tmp_next: STD_LOGIC_VECTOR(2*WDATA - 1 downto 0);
    signal p_reg, p_next: STD_LOGIC_VECTOR(9 downto 0); --max 784
    signal layer_reg, layer_next: STD_LOGIC_VECTOR(1 downto 0); --max 2
    signal neuron_reg, neuron_next: STD_LOGIC_VECTOR(4 downto 0); --max 30
    signal i_reg, i_next: STD_LOGIC_VECTOR(9 downto 0); --max 784
    signal j_reg, j_next: STD_LOGIC_VECTOR(3 downto 0); --max 10
    signal sdata_reg, sdata_next: STD_LOGIC_VECTOR(WDATA-1 downto 0);
    signal res_reg, res_next: STD_LOGIC_VECTOR(3 downto 0); 
    signal max_reg, max_next: STD_LOGIC_VECTOR(WDATA-1 downto 0);
    signal currmax_reg, currmax_next: STD_LOGIC_VECTOR(WDATA-1 downto 0);
    constant param: STD_LOGIC_VECTOR(15 downto 0):= (x"0004"); --leakyReLu parameter 4 + 12
    type mem_t is array(0 to 2) of positive;--std_logic_vector(DATA_WDATA_c - 1 downto 0);
    constant neuron_array: mem_t := (784, 30, 10);--(conv_std_logic_vector(1, DATA_WDATA_c),conv_std_logic_vector(2, DATA_WDATA_c),conv_std_logic_vector(3, DATA_WDATA_c));
    subtype addr_range_t is integer range 0 to 900;
    type addr_t is array(0 to 2) of addr_range_t;--std_logic_vector(DATA_WDATA_c - 1 downto 0);
    constant start_addr: addr_t := (0, 784, 814);
begin
    --state register
    process (clk) is
    begin
    if (clk'event and clk = '1') then
        if (reset = '1') then
            state_reg <= idle;
            acc_reg <= (others => '0');
            acc_tmp_reg <= (others => '0');
            acc_tmp2_reg <= (others => '0');
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
        else
            state_reg <= state_next;
            acc_reg <= acc_next;
            acc_tmp_reg <= acc_tmp_next;
            acc_tmp2_reg <= acc_tmp2_next;
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
    end if;
end process;
    
    --next state comb logic
    process(state_reg, res_reg, acc_reg, layer_reg, neuron_reg,p_next,  p_reg, i_reg, sdata_reg, j_reg, product_tmp_reg, acc_tmp_reg, 
    acc_tmp2_reg, currmax_reg, max_reg,  product_tmp_next, i_next, acc_tmp_next, acc_tmp2_next, acc_next, neuron_next, layer_next,
    currmax_next, j_next, start, sdata, svalid, bdata_in)
    
    begin
	res_next <= res_reg;
	acc_next <= acc_reg;
--    p_next <= p_reg;
--    layer_next <= layer_reg;
--    neuron_next <= neuron_reg;
--    i_next <= i_reg;
--    state_next <= state_reg;
--    sdata_next <= sdata_reg;
    j_next <= j_reg;
    product_tmp_next <= product_tmp_reg;
    acc_tmp_next <= acc_tmp_reg;
    acc_tmp2_next <= acc_tmp2_reg;
    currmax_next <= currmax_reg;
    max_next <= max_reg;
    cl_num <= "0000";
    
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
                    p_next <= std_logic_vector( unsigned(p_reg) + 1 );
                    if unsigned(p_next) < IMG_LEN then
                        state_next <= wait_pixel;
                    else
                        layer_next <= "01";
                        state_next <= layer_state;
                    end if;
            when layer_state =>
                    toggle <= '1';
                    neuron_next <= (others => '0');
                    state_next <= neuron_state;
            when neuron_state =>
                    --toggle <= '1'; --subject to change
                    acc_next <= (others => '0');
                    i_next <= (others => '0');
                    state_next <= synapse_state;
            when synapse_state =>
                    --toggle <= '1'; --moved to neuron_state
                    state_next <= wait_weight;       
            when wait_weight =>
                    sready <= '1';
                    if svalid = '1' then 
                        state_next <= load_weight;
                        baddr <= std_logic_vector (to_unsigned(start_addr(to_integer(unsigned(layer_reg)) - 1), 10) + unsigned(i_reg)); --get this under control
                        en<='1';
                        we<='0';
                        sdata_next <= sdata;
                    else
                        state_next <= wait_weight;
                    end if;
            when load_weight =>
                    product_tmp_next <= std_logic_vector(signed(bdata_in)*signed(sdata_reg)); --gr8
                    --acc_next <= std_logic_vector(signed(acc_reg) + signed(product_tmp_next(27 downto 12))); --
                    acc_next <= std_logic_vector(signed(acc_reg) + signed(product_tmp_next(31 downto 14))); -- parametrize WDATAs
                    i_next <= std_logic_vector(unsigned(i_reg) + 1);
                    if unsigned(i_next) < neuron_array(to_integer(unsigned(layer_reg)) - 1)
                    then 
                        --state_next <= synapse_state;
                        state_next <= wait_weight;
                    else 
                        --toggle <= '1'; 
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
                    acc_tmp_next <= std_logic_vector(signed(acc_reg) + signed(sdata_reg));
                    --if signed(acc_tmp) < 0 then acc_next <= acc_tmp * 0.001;
                    --if acc_tmp_next(acc_tmp_next'left) = '1' then
                    if signed(acc_tmp_next) < 0 then 
                        acc_tmp2_next <= std_logic_vector(signed(acc_tmp_next) * signed(param));
                       -- acc_tmp2_next <= std_logic_vector(signed(acc_tmp_next) * 0.001);
                        acc_next <= acc_tmp2_next(39 downto 12);
                    else
                        acc_next <= acc_tmp_next;
                    end if;
                    
                    --write result in bram
                    --baddr <= "00000"&std_logic_vector(start_addr(to_integer(unsigned(layer_reg))) + unsigned(neuron_reg)); --concatenation possible problem
                    baddr <= std_logic_vector(to_unsigned(start_addr(to_integer(unsigned(layer_reg))) + to_integer(unsigned(neuron_reg)), baddr'length));
                    bdata_out <= acc_next(WDATA - 1 downto 0);
                    en <= '1';
                    we <= '1';
                    neuron_next <= std_logic_vector(unsigned(neuron_reg) + 1);
                    if to_integer(unsigned(neuron_next)) < neuron_array(to_integer(unsigned(layer_reg))) then 
                        state_next <= neuron_state;
                    else 
                        state_next <=cont;
                    end if;
            when cont =>
                    layer_next  <= std_logic_vector(unsigned(layer_reg) + 1);
                    if (unsigned(layer_next) < LAYER_NUM) then state_next <=layer_state;
                    else
                        --read from bram
                        baddr <= std_logic_vector(to_unsigned(start_addr(LAYER_NUM - 1), 10));
                        en <= '1';
                        we <= '0';
                        state_next <= cont1;
                    end if;
            when cont1 =>
                    max_next <= bdata_in;
                    res_next <= (others=>'0');
                    j_next <= "0001";
                    state_next <= find_res;
            when find_res =>
                   --read from bram
                  --baddr <= "000000"&std_logic_vector(unsigned(j_reg) + start_addr( LAYER_NUM - 1)); --concatenation possible problem
                  baddr <= std_logic_vector(to_unsigned(start_addr(LAYER_NUM - 1) + to_integer(unsigned(j_reg)), baddr'length));
                  en <= '1';
                  we <= '0';
                  state_next <= find_res_1;
          when find_res_1 =>
                  currmax_next <= bdata_in;
                  if (signed(currmax_next) > signed(max_reg)) then
                  	max_next <= currmax_next;
                  	res_next <= j_reg;
                  end if;
                  j_next <= std_logic_vector(unsigned(j_reg)+1);
                  if(j_next = "1010") then
                  	state_next <= end_state;
            	else
                  	state_next <= find_res;
             	end if;
       	when end_state =>
       		toggle <= '1';
       		--cl_num <= res_reg;
       		cl_num <= std_logic_vector(unsigned(res_reg));
       		state_next <= idle;
       		--new signal
       		--done <= '1';
                  --res_next <= (others=>'0');
                  --j_next <= std_logic_vector(1);
                  --state_next <= find_res;
        end case;
            
    end process;

end Behavioral;
