
module BOOT_CLOCK_tb;

  // Parameters
  localparam  PERIOD = 16.0;

  //Ports
  wire  O1, O2;
  integer mismatch = 0;

  BOOT_CLOCK # (
    .PERIOD(PERIOD)
  )
  BOOT_CLOCK_inst (
    .O(O1)
  );

  boot_clk # (
    .period(PERIOD)
  )
  boot_clk_inst (
    .O(O2)
  );

  initial begin
    $dumpfile("BOOT_CLOCK.vcd");
    $dumpvars;
    #500;
    if (mismatch > 0) begin
    $display("-----------------Simulation Failed-----------------");
    end
    else begin
      $display("-----------------Simulation Passed-----------------");
    end
    $display ("FINISH");
    $finish;
end

task compare(O1, O2);
    if(O1 !== O2) begin
        $display("Output mismatch. dut1: %0h, dut2: %0h", O1, O2);
        mismatch = mismatch+1;
    end
endtask


endmodule


module boot_clk #(
    parameter period = 30.0 // Clock period for simulation purposes (nS)
  ) (
    output reg O = 1'b0 // Clock output
  );
  localparam h_period = period/2.0;

    always
      #h_period O <= ~O;
  
  endmodule