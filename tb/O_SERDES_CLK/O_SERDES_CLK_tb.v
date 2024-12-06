`timescale 1ns/1ps

module O_SERDES_CLK_tb;

  parameter PLL_CLK_PERIOD = 2.0;

  parameter DATA_RATE = "SDR";
  parameter CLOCK_PHASE = 0;

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

  initial begin
    $display("\nDATA_RATE=%0s, CLOCK_PHASE=%0d", UUT.DATA_RATE, UUT.CLOCK_PHASE);
    $display("\nSimulation started");
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
    //$stop;
    $display("\nSimulation completed.");
    $finish;
  end
  
  initial begin
    $dumpfile("waveform_O_SERDES_CLK.vcd");
    $dumpvars(3,O_SERDES_CLK_tb);
  end

  initial
    $timeformat(-9,0," ns", 5);

endmodule