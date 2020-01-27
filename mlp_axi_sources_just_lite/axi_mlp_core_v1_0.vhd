library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_mlp_core_v1_0 is
	generic (
		-- Users to add parameters here
        WDATA: positive := 18;
        WADDR: positive := 10;
        ACC_WDATA: positive := 28;
        IMG_LEN: positive := 784;
        LAYER_NUM: positive := 3; 
		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 5
	);
	port (
		-- Users to add ports here

		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end axi_mlp_core_v1_0;

architecture arch_imp of axi_mlp_core_v1_0 is
    --**AXI LITE <-> MEM SUBS
    signal start_al2mm: std_logic;
    signal start_mm2al: std_logic;
    signal ready_mm2al: std_logic;
    signal toggle_mm2al: std_logic;
    signal cl_num_mm2al : std_logic_vector(3 downto 0);
    signal sready_mm2al: std_logic;
    signal svalid_al2mm: std_logic;
    signal svalid_mm2al: std_logic;
    signal sdata_al2mm: std_logic_vector(WDATA-1 downto 0);
    signal sdata_mm2al: std_logic_vector(WDATA-1 downto 0);
    --**MEMSUBS <-> MLP
    signal start_mm2mlp: std_logic;
    signal ready_mlp2mm: std_logic;
    signal toggle_mlp2mm: std_logic;
    signal cl_num_mlp2mm: std_logic_vector(3 downto 0);
    signal sready_mlp2mm: std_logic;
    signal svalid_mm2mlp: std_logic;
    signal sdata_mml2mlp: std_logic_vector(WDATA-1 downto 0);
    --**MLP<->BRAM
    signal bdata_br2mlp: std_logic_vector(WDATA-1 downto 0);
    signal bdata_mlp2br: std_logic_vector(WDATA-1 downto 0);
    signal baddr_mlp2br: std_logic_vector(WADDR-1 downto 0);
    signal we_mlp2br: std_logic;
    signal en_mlp2br: std_logic;
	-- component declaration
	component axi_mlp_core_v1_0_S00_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 5
		);
		port (
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component axi_mlp_core_v1_0_S00_AXI;

begin

-- Instantiation of Axi Bus Interface S00_AXI
axi_mlp_core_v1_0_S00_AXI_inst : entity work.axi_mlp_core_v1_0_S00_AXI(arch_imp)
    generic map (
               --user added generic
         WDATA => WDATA,
         WADDR => WADDR,
         ACC_WDATA => ACC_WDATA,
         IMG_LEN => IMG_LEN,
         LAYER_NUM => LAYER_NUM,
        --user added generics end here
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
		   --user added ports
        S_AXI_START_O => start_al2mm,
        S_AXI_START_I => start_mm2al,
        S_AXI_READY_I => ready_mm2al,
        S_AXI_TOGGLE_I => toggle_mm2al,
        S_AXI_CL_NUM_I => cl_num_mm2al,
        S_AXI_SREADY_I => sready_mm2al,
        S_AXI_SVALID_I => svalid_mm2al,
        S_AXI_SVALID_O => svalid_al2mm,
        S_AXI_SDATA_I => sdata_mm2al,
        S_AXI_SDATA_O => sdata_al2mm,
        --user added ports end here
		S_AXI_ACLK	=> s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	=> s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready
	);

	-- Add user logic here
        reset_s <= not s00_axi_aresetn;
        
        --instantiation of mlp
        mlp: entity work.mlp(Behavioral)
        generic map (
               --user added generic
                WDATA => WDATA,
                WADDR => WADDR,
                ACC_WDATA => ACC_WDATA,
                IMG_LEN => IMG_LEN,
                LAYER_NUM => LAYER_NUM)
         port map (
                ---- Clocking and reset interface
                clk => s00_axi_aclk,
                --reset => s00_axi_aresetn,
                reset => reset_s,
                ---- Command and Status interfaces 
                start => start_mm2mlp,
                ready => ready_mlp2mm,
                toggle => toggle_mlp2mm,
                cl_num => cl_num_mlp2mm,
                ----
                sdata => sdata_mml2mlp,
                svalid => svalid_mm2mlp,
                sready => sready_mlp2mm,
                ----
                bdata_in => bdata_br2mlp,
                bdata_out => bdata_mlp2br,
                baddr => baddr_mlp2br,
                en => en_mlp2br,
                we => we_mlp2br);
                
        --instantiation of memory subsystem
        memory_subsystem: entity work.mem_subsystem(Behavioral)
        port map(
            clk => s00_axi_aclk,
            --reset => s00_axi_aresetn,
            reset => reset_s,
            start_axi_i => start_al2mm,
            start_axi_o => start_mm2al,
            start_mlp_o => start_mm2mlp,
            ready_axi_o => ready_mm2al,
            ready_mlp_i => ready_mlp2mm,
            toggle_axi_o => toggle_mm2al,
            toggle_mlp_i => toggle_mlp2mm, 
            cl_num_axi_o => cl_num_mm2al,
            cl_num_mlp_i => cl_num_mlp2mm,
            --sready
            sready_mlp_i => sready_mlp2mm,
            sready_axi_o => sready_mm2al,
            --svalid
            svalid_axi_i => svalid_al2mm,
            svalid_axi_o => svalid_mm2al,
            svalid_mlp_o => svalid_mm2mlp,
            --sdata
            sdata_axi_i => sdata_al2mm,
            sdata_axi_o => sdata_mm2al,
            sdata_mlp_o => sdata_mml2mlp
        );
        
         --instantiation of BRAM
         bram: entity work.bram(Behavioral)
         generic map (
             WADDR => WADDR,
             WDATA => WDATA)
         port map (
             clk => s00_axi_aclk,
             --reset => s00_axi_aresetn,
             reset => reset_s,
             addra => baddr_mlp2br,
             dia => bdata_mlp2br, --output from mlp is input for bram
             doa => bdata_br2mlp,
             wea => we_mlp2br,
             ena => en_mlp2br,
             addrb => (others => '0'),
             dib => (others => '0'),
             web => '0',
             enb => '0');
             
        
	-- User logic ends

end arch_imp;
