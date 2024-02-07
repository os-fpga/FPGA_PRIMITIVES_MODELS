`timescale 1ns/1ps

module I_SERDES_tb;

  // Parameters
  localparam  DATA_RATE = "SDR";
  localparam  WIDTH = 4;
  localparam  DPA_MODE = "NONE";
  localparam  clk_period = 10;
  localparam  dly_clk_period = 40;
  localparam  phase = 0;
  //Ports
  reg  D;
  reg  RX_RST;
  reg  BITSLIP_ADJ;
  reg  EN;
  reg  CLK_IN;
  wire  CLK_OUT;
  wire [WIDTH-1:0] Q;
  wire  DATA_VALID;
  wire  DPA_LOCK;
  wire  DPA_ERROR;
  reg  PLL_LOCK;
  reg  PLL_CLK;

  real delay;

  I_SERDES # (
    .DATA_RATE(DATA_RATE),
    .WIDTH(WIDTH),
    .DPA_MODE(DPA_MODE)
  )
  I_SERDES_inst (
    .D(D),
    .RX_RST(RX_RST),
    .BITSLIP_ADJ(BITSLIP_ADJ),
    .EN(EN),
    .CLK_IN(CLK_IN),
    .CLK_OUT(CLK_OUT),
    .Q(Q),
    .DATA_VALID(DATA_VALID),
    .DPA_LOCK(DPA_LOCK),
    .DPA_ERROR(DPA_ERROR),
    .PLL_LOCK(PLL_LOCK),
    .PLL_CLK(PLL_CLK)
  );

initial 
begin
  CLK_IN =0;
	PLL_CLK =0;
  PLL_LOCK=1;
	RX_RST=0;
  D=0;
  EN=0;
  BITSLIP_ADJ=0;
  delay=(phase==90)?0.1:(phase==180)?0.2:(phase==270)?0.3:0;
  repeat(2)@(posedge PLL_CLK);
  RX_RST=1;
  D=0;
  EN=0;

  fork
  // begin
  repeat(100)
  begin
    // data
    @(posedge PLL_CLK);
    #(delay);
    EN=1;
    D=1;
    @(posedge PLL_CLK);
    #(delay);
    D=0;
    @(posedge PLL_CLK);
    #(delay);
    D=1;
    @(posedge PLL_CLK);
    #(delay);
    D=0;
  end
  
  // bitslip 
  @(posedge DATA_VALID)
  repeat(3)
  begin
    @(negedge CLK_IN);
    BITSLIP_ADJ=1;
    repeat(2)@(negedge CLK_IN);
    BITSLIP_ADJ=0;
  end
join

  @(posedge CLK_IN);
  if (Q == 4'hA)
    $display("Test Passed");
  else
    $display("Test Failed");
  
  fork
    begin
      repeat(20)
      begin
        @(posedge PLL_CLK);
        #(delay);
        EN=1;
        D=1;
        @(posedge PLL_CLK);
        #(delay);
        D=0;
        @(posedge PLL_CLK);
        #(delay);
        D=1;
        @(posedge PLL_CLK);
        #(delay);
        D=0;
      end
        @(posedge PLL_CLK);
        #(delay);
        D=1;
        @(posedge PLL_CLK);
        #(delay);
        D=1;
        @(posedge PLL_CLK);
        #(delay);
        D=0;
        @(posedge PLL_CLK);
        #(delay);
        D=0;

        @(posedge PLL_CLK);
        #(delay);
        D=1;
        @(posedge PLL_CLK);
        #(delay);
        D=1;
        @(posedge PLL_CLK);
        #(delay);
        D=0;
        @(posedge PLL_CLK);
        #(delay);
        D=1;
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

  #1000;
  $finish;
end

always #0.2  PLL_CLK = ~ PLL_CLK ; // 2.5 GHz
always #0.8  CLK_IN = ~ CLK_IN ;

initial 
begin
    $dumpfile("I_SERDES.vcd");
    $dumpvars;
end

endmodule