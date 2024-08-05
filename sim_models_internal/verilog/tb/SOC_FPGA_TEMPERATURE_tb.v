`timescale 1ns/1ps

module SOC_FPGA_TEMPERATURE_tb;

  parameter INITIAL_TEMPERATURE = 50;
  parameter TEMPERATURE_FILE = "temp.dat"; 

  wire [7:0] TEMPERATURE;
  wire VALID;
  wire ERROR;

  SOC_FPGA_TEMPERATURE #(
    .INITIAL_TEMPERATURE(INITIAL_TEMPERATURE),
    .TEMPERATURE_FILE(TEMPERATURE_FILE)  
  ) UUT (
    .TEMPERATURE(TEMPERATURE), // Temperature data
    .VALID(VALID), // Temperature data valid
    .ERROR(ERROR) // Temperature error
  );

  initial begin
     #200001;
    //$stop;
    $display("\nSimulation completed at %t.\n", $realtime);
    $finish;
  end

  initial
    $monitor("%t: TEMPERATURE=%d, VALID=%b, ERROR=%b", $realtime, TEMPERATURE, VALID, ERROR);

  //initial begin
  //  $monitor("d=%d, scan_temp_file=%h", UUT.d, UUT.scan_temp_file);
  //end

  
  initial begin
    $dumpfile("waveform_SOC_FPGA_TEMPERATURE.vcd");
    $dumpvars(3,testbench);
  end

  initial
    $timeformat(-9,0," ns", 5);

endmodule
