

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
generic (WIDTH: positive := 16); 
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
           sready: out STD_LOGIC);
end top;

architecture Behavioral of top is
         signal mem_a_addr_s: std_logic_vector(9 downto 0);
         signal mem_a_data_in_s: std_logic_vector(15 downto 0);
         signal mem_a_data_out_s: std_logic_vector(15 downto 0);
         signal mem_a_wr_s: std_logic;
         signal mem_a_en_s: std_logic;
begin
                        -- BRAM connections
        mem: entity work.bram(Behavioral)
        --generic map (
        --    WADDR => DATA_WIDTH_c,
        --    WDATA => SIZE_c)
        port map (
            clk => clk,
            reset => reset,
            addra => mem_a_addr_s,
            dia => mem_a_data_out_s, --output from mlp is input for bram
            doa => mem_a_data_in_s,
            wea => mem_a_wr_s,
            ena => mem_a_en_s,
            addrb => (others => '0'),
            dib => (others => '0'),
            --doa => (others => '0'),
            web => '0',
            enb => '0');
    
        -- DUT
        mlp_core: entity work.mlp(Behavioral)
        --generic map (
        --WIDTH => DATA_WIDTH_c,
        --SIZE => SIZE_c)
        port map (
            ---- Clocking and reset interface
            clk => clk,
            reset => reset,
            ---- Command and Status interfaces 
            start => start,
            ready => ready,
            toggle => toggle,
            cl_num => cl_num,
            ----
            sdata => sdata,
            svalid => svalid,
            sready => sready,
            ----
            bdata_in => mem_a_data_in_s,
            bdata_out => mem_a_data_out_s,
            baddr => mem_a_addr_s,
            en => mem_a_en_s,
            we => mem_a_wr_s);

end Behavioral;
