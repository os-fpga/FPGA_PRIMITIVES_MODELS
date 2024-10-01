`timescale 1ns/1ps
module MIPI_RX_tb;

  // Parameters
  localparam  WIDTH = 4 ;
  localparam  EN_IDLY = "FALSE";
  localparam  DELAY = 0;
  localparam  phase = 0;

  //Ports
  reg  RST;
  reg  RX_CLK;
  reg  PLL_LOCK;
  reg  CLK_IN;
  reg  RX_DP;
  reg  RX_DN;
  reg  HS_EN;
  reg  LP_EN;
  reg  RX_TERM_EN;
  reg  BITSLIP_ADJ;
  reg  DLY_LOAD;
  reg  DLY_ADJ;
  reg  DLY_INCDEC;
  wire [5:0] DLY_TAP_VALUE;
  wire [WIDTH-1:0] HS_RX_DATA;
  wire  HS_RXD_VALID;
  wire  RX_OE;
  wire  LP_RX_DP;
  wire  LP_RX_DN;

  real delay;
  integer error=0;

  MIPI_RX # (
    .WIDTH(WIDTH),
    .EN_IDLY(EN_IDLY),
    .DELAY(DELAY)
  )
  MIPI_RX_inst (
    .RST(RST),
    .RX_CLK(RX_CLK),
    .PLL_LOCK(PLL_LOCK),
    .CLK_IN(CLK_IN),
    .RX_DP(RX_DP),
    .RX_DN(RX_DN),
    .HS_EN(HS_EN),
    .LP_EN(LP_EN),
    .RX_TERM_EN(RX_TERM_EN),
    .BITSLIP_ADJ(BITSLIP_ADJ),
    .DLY_LOAD(DLY_LOAD),
    .DLY_ADJ(DLY_ADJ),
    .DLY_INCDEC(DLY_INCDEC),
    .DLY_TAP_VALUE(DLY_TAP_VALUE),
    .HS_RX_DATA(HS_RX_DATA),
    .HS_RXD_VALID(HS_RXD_VALID),
    .RX_OE(RX_OE),
    .LP_RX_DP(LP_RX_DP),
    .LP_RX_DN(LP_RX_DN)
  );

  always #0.2  RX_CLK = ! RX_CLK ; // 2.5 GHz
  always #0.8  CLK_IN = ! CLK_IN ;

  initial 
  begin
    CLK_IN=0;
    RX_CLK=0;
    PLL_LOCK=1;
    RST=0;
    DLY_LOAD=0;
    DLY_ADJ=0;
    DLY_INCDEC=0;
    RX_DP=0;
    HS_EN=0;
    LP_EN=0;
    BITSLIP_ADJ=0;
    RX_TERM_EN=0;
    delay=(phase==90)?0.1:(phase==180)?0.2:(phase==270)?0.3:0;
    repeat(2)@(posedge RX_CLK);
    RST=1;
    RX_DP=0;
    HS_EN=0;
    repeat(63)
    begin
      @(posedge RX_CLK);
      #(delay);
      HS_EN=1;
      RX_DP=1;
      @(posedge RX_CLK);
      #(delay);
      RX_DP=0;
      @(posedge RX_CLK);
      #(delay);
      RX_DP=1;
      @(posedge RX_CLK);
      #(delay);
      RX_DP=0;

    end

    fork
      begin
        repeat(20)
        begin
          @(posedge RX_CLK);
          #(delay);
          HS_EN=1;
          RX_DP=1;
          @(posedge RX_CLK);
          #(delay);
          RX_DP=0;
          @(posedge RX_CLK);
          #(delay);
          RX_DP=1;
          @(posedge RX_CLK);
          #(delay);
          RX_DP=0;
        end
        @(posedge RX_CLK);
        #(delay);
        RX_DP=1;
        @(posedge RX_CLK);
        #(delay);
        RX_DP=1;
        @(posedge RX_CLK);
        #(delay);
        RX_DP=0;
        @(posedge RX_CLK);
        #(delay);
        RX_DP=0;

        @(posedge RX_CLK);
        #(delay);
        RX_DP=1;
        @(posedge RX_CLK);
        #(delay);
        RX_DP=1;
        @(posedge RX_CLK);
        #(delay);
        RX_DP=0;
        @(posedge RX_CLK);
        #(delay);
        RX_DP=1;
      end

      begin
      // bitslip 
        repeat(3)
        begin
          @(negedge CLK_IN);
          BITSLIP_ADJ=1;
          repeat(2)@(negedge CLK_IN);
          BITSLIP_ADJ=0;
        end
      end
    join_any
    repeat(17)@(posedge CLK_IN);
    if(HS_RX_DATA!=='ha)
      error=error+1;
    @(posedge CLK_IN);
    if(HS_RX_DATA!=='hc)
      error=error+1;
    @(posedge CLK_IN);
    if(HS_RX_DATA!=='hd)
      error=error+1;

    #2;
    if(error===0)
      $display("Test Passed");
    else
      $display("Test Failed");
      
    #1000;
    $finish;

  end

  assign RX_DN = ~RX_DP;
  initial 
  begin
    $dumpfile("waves.vcd");
    $dumpvars;
  end
endmodule
