`timescale 1ns/1ps
`celldefine
//
// SOC_FPGA_INTF_DMA simulation model
// SOC DMA interface
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

`ifdef TB
module SOC_FPGA_INTF_DMA_tb;
  bit DMA_CLK;
  reg DMA_RST_N;

`else
module SOC_FPGA_INTF_DMA_tb(
  input DMA_CLK,
  input DMA_RST_N
);
`endif

  reg [3:0] DMA_REQ;
  wire [3:0] DMA_ACK;

  reg [3:0] dma_req;

SOC_FPGA_INTF_DMA soc_fpga_intf_dma(
  .DMA_REQ(DMA_REQ),
  .DMA_ACK(DMA_ACK),
  .DMA_CLK(DMA_CLK),
  .DMA_RST_N(DMA_RST_N)
);

  

  `ifdef TB

    initial begin
      //generating clock
      DMA_CLK = 0;
      forever #5 DMA_CLK = ~DMA_CLK;
    end

    initial begin
      DMA_REQ = 0;
      DMA_RST_N = 0;

      repeat(2) @(posedge DMA_CLK);
      DMA_RST_N = 1;

      for (int i=0; i<10; i++) begin
        DMA_REQ = $random();
        @(posedge DMA_CLK);
      end

      $finish;

    end

    always @(posedge DMA_CLK) dma_req <= DMA_REQ;

    initial begin 
      forever begin
        if(DMA_RST_N)
         if (DMA_ACK == dma_req) 
          $info("True DMA_ACK");
         else $error("False DMA_ACK %0d , DMA_REQ %0d ", DMA_ACK ,dma_req );
        @(posedge DMA_CLK);
      end
    end

  `else
    always@(posedge DMA_CLK) DMA_REQ <= DMA_REQ + 1;

  `endif

  // assert property (
  //   @(posedge DMA_CLK) disable iff (!DMA_RST_N)
  //   DMA_REQ[1] |=> DMA_ACK[1]; 
  // );

endmodule
`endcelldefine