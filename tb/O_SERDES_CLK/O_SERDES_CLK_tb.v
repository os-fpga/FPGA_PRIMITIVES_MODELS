`timescale 1ns/1ps

module O_SERDES_CLK_tb;

  parameter PLL_CLK_PERIOD  = 2.0;
  parameter DATA_RATE       = "SDR";
  parameter CLOCK_PHASE     = 0;

  always
    #(PLL_CLK_PERIOD/2) PLL_CLK = ~PLL_CLK;

  reg   CLK_EN      = 1'b1;
  reg   PLL_LOCK    = 1'b0;
  reg   PLL_CLK     = 1'b0;
  wire  OUTPUT_CLK;

  O_SERDES_CLK #(
    .DATA_RATE(DATA_RATE), // Single or double data rate (SDR/DDR)
    .CLOCK_PHASE(CLOCK_PHASE) // Clock phase
  ) UUT (
    .CLK_EN(CLK_EN), // Gates output clock
    .OUTPUT_CLK(OUTPUT_CLK), // Clock output (Connect to output port, buffer or O_DELAY)
    .PLL_LOCK(PLL_LOCK), // PLL lock input
    .PLL_CLK(PLL_CLK) // PLL clock input
  );

real start;
real endd;
real diff;

  initial begin
    $display("\nDATA_RATE=%0s, CLOCK_PHASE=%0d", UUT.DATA_RATE, UUT.CLOCK_PHASE);
    $display("\n---------------------\nSimulation Started\n---------------------");
    #100;
    PLL_LOCK = 1'b1;
    #500;
    CLK_EN = 1'b0;
    #100;
    CLK_EN = 1'b1;
    #100;
    PLL_LOCK = 1'b0;
    #100;
    PLL_LOCK = 1'b1;
    #1000;
    if (CLK_EN && PLL_LOCK)
    begin
      repeat(256)@(posedge PLL_CLK)
      @(posedge OUTPUT_CLK)
      start = $realtime();
      @(posedge OUTPUT_CLK)
      endd = $realtime();
      diff = endd - start;
      $display("Start_Time: %d, End_Time: %d, Difference: %d", start, endd, diff);
      if (DATA_RATE == "SDR")
        if (diff == (PLL_CLK_PERIOD*2))
          $display("SDR Test Passed");
        else
          $display("SDR Test Failed");
        
      else
        if (diff == (PLL_CLK_PERIOD*4))
          $display("DDR Test Passed");
        else
          $display("DDR Test Failed");
    end
    $display("\n---------------------\nSimulation Completed\n---------------------");
    $finish;
  end
  
  initial begin
    $dumpfile("O_SERDES_CLK.vcd");
    $dumpvars(3,O_SERDES_CLK_tb);
  end

  initial
    $timeformat(-9,0," ns", 5);

endmodule