`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


module mlp_tb#
(
   parameter integer WIDTH                 = 16,
   parameter integer C_S00_AXI_DATA_WIDTH_c  = 32,
   parameter integer C_S00_AXI_ADDR_WIDTH_c    = 4,
   parameter integer C_S00_AXIS_TDATA_WIDTH_c  = 32  
)
();
   // PARAMETERS
	localparam bit[9:0] IMG_LEN = 10'd784;
	localparam START_REG_ADDR_C = 0;
	localparam READY_REG_ADDR_C = 4;
	localparam TOGGLE_REG_ADDR_C = 8;
	localparam CL_NUM_REG_ADDR_C = 12;

   // Ports of Axi Slave Bus Interface S_AXI
   logic  clk_s=0;
   logic  reset_s=1;
   logic [C_S00_AXI_ADDR_WIDTH_c - 1 : 0] s00_axi_awaddr_s=0;
   logic [2 : 0] s00_axi_awprot_s=0;
   logic  s00_axi_awvalid_s=0;
   logic  s00_axi_awready_s=0;
   logic [C_S00_AXI_DATA_WIDTH_c-1 : 0] s00_axi_wdata_s=0;
   logic [(C_S00_AXI_DATA_WIDTH_c/8)-1 : 0] s00_axi_wstrb=0;
   logic  s00_axi_wvalid_s=0;
   logic  s00_axi_wready_s=0;
   logic [1 : 0] s00_axi_bresp_s=0;
   logic  s00_axi_bvalid_s=0;
   logic  s00_axi_bready_s=0;
   logic [C_S00_AXI_ADDR_WIDTH_c - 1 : 0] s00_axi_araddr_s=0;
   logic [2 : 0] s00_axi_arprot_s=0;
   logic  s00_axi_arvalid_s=0;
   logic  s00_axi_arready_s=0;
   logic [C_S00_AXI_DATA_WIDTH_c-1 : 0] s00_axi_rdata_s=0;
   logic [1 : 0] s00_axi_rresp_s=0;
   logic  s00_axi_rvalid_s=0;
   logic  s00_axi_rready_s=0;

   // Ports of Axi Slave Bus Interface S_AXIS
   logic  s00_axis_aclk_s=0;
   logic  s00_axis_aresetn_s=1;
   logic  s00_axis_tready_s=0;
   logic [C_S00_AXIS_TDATA_WIDTH_c-1 : 0] s00_axis_tdata_s=0;
   logic [(C_S00_AXIS_TDATA_WIDTH_c/8)-1 : 0] s00_axis_tstrb_s=4'b1111;
   logic  s00_axis_tlast_s=0;
   logic  s00_axis_tvalid_s=0;

   // TB VARIABLES

   string input_test_image = "D:\ee36-86-2015\mlp_vhdl-master\params_18bits\input_images.txt";
   string input_weights_1 = "D:\ee36-86-2015\mlp_vhdl-master\params_18bits\weights1.txt";
   string input_biases_1  = "D:\ee36-86-2015\mlp_vhdl-master\params_18bits\biases1.txt";
   string input_weights_2  = "D:\ee36-86-2015\mlp_vhdl-master\params_18bits\weights2.txt";
   string input_biases_2   = "D:\ee36-86-2015\mlp_vhdl-master\params_18bits\biases2.txt";

   logic[17 : 0] y[$];
   logic[17 : 0] w1[$];
   logic[17 : 0] b1[$];
   logic[17 : 0] w2[$];
   logic[17 : 0] b2[$];

   logic[17 : 0] tmp;
   int i=0;
   int num=0;
   int fd=0;
   string s="";

   int image=0;
   int neuron=0;
	
	logic[31:0] axi_read_data; 

   
   axi_mlp_v1_0 #
   mlp_ip_inst
   (
      .s00_axi_aclk(clk_s),
      .s00_axi_aresetn(reset_s),
      .s00_axi_awaddr(s00_axi_awaddr_s),
      .s00_axi_awprot(s00_axi_awprot_s),
      .s00_axi_awvalid(s00_axi_awvalid_s),
      .s00_axi_awready(s00_axi_awready_s),
      .s00_axi_wdata(s00_axi_wdata_s),
      .s00_axi_wstrb(s00_axi_wstrb_s),
      .s00_axi_wvalid(s00_axi_wvalid_s),
      .s00_axi_wready(s00_axi_wready_s),
      .s00_axi_bresp(s00_axi_bresp_s),
      .s00_axi_bvalid(s00_axi_bvalid_s),
      .s00_axi_bready(s00_axi_bready_s),
      .s00_axi_araddr(s00_axi_araddr_s),
      .s00_axi_arprot(s00_axi_arprot_s),
      .s00_axi_arvalid(s00_axi_arvalid_s),
      .s00_axi_arready(s00_axi_arready_s),
      .s00_axi_rdata(s00_axi_rdata_s),
      .s00_axi_rresp(s00_axi_rresp_s),
      .s00_axi_rvalid(s00_axi_rvalid_s),
      .s00_axi_rready(s00_axi_rready_s),
      .s00_axis_aclk(clk_s),
      .s00_axis_aresetn(reset_s),
      .s00_axis_tready(s00_axis_tready_s),
      .s00_axis_tdata(s00_axis_tdata_s),
      .s00_axis_tstrb(s00_axis_tstrb_s),
      .s00_axis_tlast(s00_axis_tlast_s),
      .s00_axis_tvalid(s00_axis_tvalid_s)
   );
   


   // CLOCK DRIVER
   always
#50ns clk_s <= ~clk_s;

   //CLEAR QUEUES, EXTRACT DATA FROM FILES                                       *****
   initial
   begin
   
      while(y.size()!=0)
      y.delete(0);
     
      while(w1.size()!=0)
      w1.delete(0);
      while(b1.size()!=0)
      b1.delete(0);
      while(w2.size()!=0)
      w2.delete(0);
      while(b2.size()!=0)
      b2.delete(0);

      //EXTRACTING TEST IMAGE [y]
      fd = ($fopen(input_test_image, "r"));
      if(fd)
      begin
         $display("test images opened successfuly");
         while(!$feof(fd))
         begin
               $fscanf(fd ,"%b\n",tmp);
               y.push_back(tmp);       
         end
      end
      else
        $display("Error opening test images file");
      $fclose(fd);

      //EXTRACTING WEIGHTS for 1st layers
         fd = ($fopen(input_weights_1, "r"));
         if(fd)
         begin
            while(!$feof(fd))
            begin
                  $fscanf(fd ,"%b\n",tmp);
                  w1.push_back(tmp);
            end
         end
         else
           $display("Error opening weights 1 file");
         $fclose(fd);

         //EXTRACTING BIASES for 1st layers
         fd = ($fopen(input_biases_1, "r"));
         if(fd)
         begin
            while(!$feof(fd))
            begin
                  $fscanf(fd ,"%b\n",tmp);
                  b1.push_back(tmp);
            end
         end
         else
          $display("Error opening biases 1 file");
         $fclose(fd);

      //EXTRACTING WEIGHTS for 2nd layers
         fd = ($fopen(input_weights_2, "r"));
         if(fd)
         begin
            while(!$feof(fd))
            begin
                  $fscanf(fd ,"%b\n",tmp);
                  w2.push_back(tmp);
            end
         end
         else
           $display("Error opening weights 2 file");
         $fclose(fd);

         //EXTRACTING BIASES for 2nd layers
         fd = ($fopen(input_biases_2, "r"));
         if(fd)
         begin
            while(!$feof(fd))
            begin
                  $fscanf(fd ,"%b\n",tmp);
                  b2.push_back(tmp);
            end
         end
         else
           $display("Error opening biases 2 file");
         $fclose(fd);


   end
   
   //RESET MODULE, START IT, SEND NECESSAIRY DATA TROUGH AXI STREAM *****
   initial
   begin
      reset_s=0;
      #300ns reset_s=1;
     
      for(image=0; image<100; image++)
      begin
         
        // START=1
        s00_axi_awaddr_s = 0;
        s00_axi_awvalid_s = 1;
        s00_axi_wdata_s = 1;
        s00_axi_wvalid_s = 1;
        s00_axi_wstrb_s = 4'b1111;
        wait(s00_axi_awready_s == 1);
        wait(s00_axi_wready_s == 1);
        $display("prosao1");
        s00_axi_bready_s = 1;
        wait(s00_axi_bvalid_s);
        $display("prosao2");
        s00_axi_awvalid_s = 0;
        s00_axi_wstrb_s = 4'b0000;
        s00_axi_wdata_s = 0;
        s00_axi_wvalid_s = 0;
        #200ns s_axi_bready_s = 0;
   
        //START=0
        s00_axi_awaddr_s = 0;
        s00_axi_awvalid_s = 1;
        s00_axi_wstrb_s=4'b1111;
        s00_axi_wdata_s = 0;
        s00_axi_wvalid_s = 1;
        wait(s00_axi_awready_s == 1);
        wait(s00_axi_wready_s == 1);
        $display("prosao3");
        s00_axi_bready_s = 1;
        wait(s00_axi_bvalid_s);
        #200ns s00_axi_bready_s = 0;
        s00_axi_wstrb_s = 4'b0000;
        s00_axi_wdata_s = 0;
        s00_axi_wvalid_s = 0;
       
       
          //@(posedge interrupt);
          for(i=0; i<IMG_LEN; i++)
          begin
             s00_axis_tstrb_s = 4'b1111;
             s00_axis_tdata_s = y[image*784+i];
             s00_axis_tvalid_s = 1;
             @(posedge clk_s iff s00_axis_tready_s == 1);
          end
          //$display("input image saved\n");
          s00_axis_tvalid_s = 0;
          s00_axis_tstrb_s = 4'b0000;

         
//hidden layer
             for(neuron=0; neuron < 30; neuron ++)
             begin
                //send weights
                for(i=0; i<IMG_LEN; i++)
                begin
                   s00_axis_tstrb_s = 4'b1111;
                   s00_axis_tdata_s = w1[neuron*IMG_LEN + i];
                   s00_axis_tvalid_s = 1;
                   @(posedge clk_s iff s00_axis_tready_s == 1);
                end
                s00_axis_tvalid_s = 0;
                s00_axis_tstrb_s = 4'b0000;
   
                //send bias
                s00_axis_tstrb_s=4'b1111;
                s00_axis_tdata_s=b1[neuron];
                s00_axis_tvalid_s=1;
                @(posedge clk_s iff s00_axis_tready_s==1);
                s00_axis_tvalid_s = 0;
                s00_axis_tstrb_s = 4'b0000;
             end

//output layer
             for(neuron=0; neuron < 10; neuron ++)
             begin
                //send weights
                for(i=0; i<IMG_LEN; i++)
                begin
                   s00_axis_tstrb_s = 4'b1111;
                   s00_axis_tdata_s = w2[neuron*IMG_LEN + i];
                   s00_axis_tvalid_s = 1;
                   @(posedge clk_s iff s00_axis_tready_s == 1);
                end
                s00_axis_tvalid_s = 0;
                s00_axis_tstrb_s = 4'b0000;
   
                //send bias
                s00_axis_tstrb_s=4'b1111;
                s00_axis_tdata_s=b2[neuron];
                s00_axis_tvalid_s=1;
                @(posedge clk_s iff s00_axis_tready_s==1);
                s00_axis_tvalid_s = 0;
                s00_axis_tstrb_s = 4'b0000;
             end


			while () begin
				@(negedge clk_s);
				s00_axi_araddr_s = 4'h4;
				s00_axi_arvalid_s = 1;
				s00_axi_rready_s = 1;
				wait(s00_axi_arready_s);
				wait(s00_axi_rvalid_s);
				//$display("ready is: %b", s00_axi_rdata_s[0]);
				axi_read_data = s00_axi_rdata_s;
				@(negedge clk_s);
				s00_axi_arvalid_s = 0;
				s00_axi_rready_s = 0;
				if(axi_read_data[0] == 1) break;
			
			end
			
          // @(posedge interrupt)
          // #100ns;
          // @(negedge s_axi_aclk_s);
          // //reading ready
          // s00_axi_araddr_s = 4'h4;
          // s00_axi_arvalid_s = 1;
          // s00_axi_rready_s = 1;
          // wait(s00_axi_arready_s);
          // wait(s00_axi_rvalid_s);
          // $display("ready is: %b", s00_axi_rdata_s[0]);
          // s00_axi_arvalid_s = 0;
          // s00_axi_rready_s = 0;
          // #200ns;
         
          @(negedge clk_s);
          //reading cl_num
          s00_axi_araddr_s = 4'h12;
          s00_axi_arvalid_s = 1;
          s00_axi_rready_s = 1;
          wait(s00_axi_arready_s);
          wait(s00_axi_rvalid_s);
          $display("res is: %d", s00_axi_rdata_s[3:0]);
			 //if s00_axi_rdata_s[] TODO compare with label
			 //$display TODO
			 @(negedge clk_s);
          s00_axi_arvalid_s = 0;
          s00_axi_rready_s = 0;
          #200ns;

      end  
      $finish;
   end
   

   
endmodule