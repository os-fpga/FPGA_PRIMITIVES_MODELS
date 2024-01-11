`timescale 1ns/1ps

module SOC_FPGA_TEMPERATURE_tb();

  parameter INITIAL_TEMPERATURE = 50;
  parameter TEMPERATURE_FILE = "./tb/SOC_FPGA_TEMPERATURE/temp.dat"; 

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
    $display("\nSimulation Completed at %t.\n", $realtime);
    $finish;
  end

  initial begin
    $monitor("%t: TEMPERATURE=%d, VALID=%b, ERROR=%b", $realtime, TEMPERATURE, VALID, ERROR);
    @(posedge VALID);
    if (TEMPERATURE == 25)
        $display("\nSimulation Passed");
    else
        $display("\nSimulation Failed");
  end
  initial begin
    $dumpfile("SOC_FPGA_TEMPERATURE.vcd");
    $dumpvars();
  end

  initial
    $timeformat(-9,0," ns", 5);

endmodule