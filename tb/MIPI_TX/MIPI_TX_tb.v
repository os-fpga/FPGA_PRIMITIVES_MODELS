`timescale 1ns/1ps
module MIPI_TX_tb;

  // Parameters
  localparam  WIDTH = 4;
  localparam  EN_ODLY = "FALSE";
  localparam  LANE_MODE = "Master";
  localparam  DELAY = 0;

  //Ports
  reg  RST;
  reg  RX_CLK;
  reg  PLL_LOCK;
  reg  CLK_IN;
  reg [WIDTH-1:0] HS_TX_DATA;
  reg  HS_TXD_VALID;
  reg  HS_EN;
  reg  TX_LP_DP;
  reg  TX_LP_DN;
  reg  LP_EN;
  reg  TX_ODT_EN;
  reg  DLY_LOAD;
  reg  DLY_ADJ;
  reg  DLY_INCDEC;
  wire  TX_OE;
  wire  TX_DP;
  wire  TX_DN;
  reg  CHANNEL_BOND_SYNC_IN;
  wire  CHANNEL_BOND_SYNC_OUT;

  reg [WIDTH-1:0] HS_TX_DATA1=0;
  reg [WIDTH-1:0] HS_TX_DATA2=0;
  reg [WIDTH-1:0] HS_TX_DATA3=0;
  reg [WIDTH-1:0] comp_data=0;
  integer error=0;


  MIPI_TX # (
    .WIDTH(WIDTH),
    .EN_ODLY(EN_ODLY),
    .LANE_MODE(LANE_MODE),
    .DELAY(DELAY)
  )
  MIPI_TX_inst (
    .RST(RST),
    .RX_CLK(RX_CLK),
    .PLL_LOCK(PLL_LOCK),
    .CLK_IN(CLK_IN),
    .HS_TX_DATA(HS_TX_DATA),
    .HS_TXD_VALID(HS_TXD_VALID),
    .HS_EN(HS_EN),
    .TX_LP_DP(TX_LP_DP),
    .TX_LP_DN(TX_LP_DN),
    .LP_EN(LP_EN),
    .TX_ODT_EN(TX_ODT_EN),
    .DLY_LOAD(DLY_LOAD),
    .DLY_ADJ(DLY_ADJ),
    .DLY_INCDEC(DLY_INCDEC),
    .TX_OE(TX_OE),
    .TX_DP(TX_DP),
    .TX_DN(TX_DN),
    .CHANNEL_BOND_SYNC_IN(CHANNEL_BOND_SYNC_IN),
    .CHANNEL_BOND_SYNC_OUT(CHANNEL_BOND_SYNC_OUT)
  );

  always #0.2  RX_CLK = ! RX_CLK ; // 2.5 GHz
  always #0.8  CLK_IN = ! CLK_IN ;

  initial 
  begin
    CLK_IN=0;
		RX_CLK=1;
		PLL_LOCK=0;
		RST=0;
    TX_ODT_EN=0;
		HS_EN=1;
		LP_EN=0;
		CHANNEL_BOND_SYNC_IN=0;
		HS_TXD_VALID=1;
		HS_TX_DATA=0;
    TX_LP_DN=0;
		TX_LP_DP=0;
    DLY_LOAD=0;
    DLY_ADJ=0;
    DLY_INCDEC=0;
		@(negedge CLK_IN);
		RST=1;
		CHANNEL_BOND_SYNC_IN=1;
		PLL_LOCK=1;
		repeat(260)@(posedge RX_CLK);
		HS_TX_DATA=4'b0101;
    HS_TX_DATA1=HS_TX_DATA;
		@(negedge CLK_IN);
		HS_TX_DATA=$urandom();
    HS_TX_DATA2=HS_TX_DATA;
		@(negedge CLK_IN);
		HS_TX_DATA=$urandom();
    HS_TX_DATA3=HS_TX_DATA;
    @(negedge MIPI_TX_inst.O_SERDES_inst.word_load_en_sync);
    repeat(4)@(RX_CLK)
    begin
      comp_data={comp_data[WIDTH-2:0],TX_DP};
    end
    if(comp_data!==HS_TX_DATA1)
      error=error+1;

    @(negedge MIPI_TX_inst.O_SERDES_inst.word_load_en_sync);
    repeat(4)@(RX_CLK)
    begin
      comp_data={comp_data[WIDTH-2:0],TX_DP};
    end
    if(comp_data!==HS_TX_DATA2)
      error=error+1;

    @(negedge MIPI_TX_inst.O_SERDES_inst.word_load_en_sync);
    repeat(4)@(RX_CLK)
    begin
      comp_data={comp_data[WIDTH-2:0],TX_DP};
    end
    if(comp_data!==HS_TX_DATA3)
      error=error+1;

    #1000;
    HS_EN=0;
    LP_EN=1;
    repeat(50)@(negedge CLK_IN)
    begin
      TX_LP_DP=$urandom();
		  TX_LP_DN=~TX_LP_DP;
      #1;
      if(TX_LP_DP!==TX_DP || TX_LP_DN!==TX_DN)
        error=error+1;
    end
    #2;
    if(error===0)
      $display("Test Passed");
    else
      $display("Test Failed");

    #1000;
    TX_ODT_EN=1;
    #100;
    TX_ODT_EN=0;
    #1000;
		$finish;

  end

  initial 
  begin
    $dumpfile("waves.vcd");
    $dumpvars;
	end
endmodule
