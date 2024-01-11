module O_BUF_tb;

  // Ports
  reg EN = 0;
  reg I = 0;
  wire O1, O2;
  reg CLK = 0;
  integer mismatch = 0;
  localparam IOSTANDARD = "NONE";
  localparam DRIVE_STRENGTH = 2;
  localparam SLEW_RATE = "SLOW";
  always #5 CLK = ~CLK;

  always @(posedge CLK) begin
    I <= $random;
    EN <= $random;
    compare(O1, O2);
  end
  initial begin
      $dumpfile("O_BUF.vcd");
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

  O_BUF #(.IOSTANDARD(IOSTANDARD),
  .DRIVE_STRENGTH(DRIVE_STRENGTH),
  .SLEW_RATE(SLEW_RATE)) 
  O_BUF_dut1 (
    .I (I),
    .O (O1)
  );

  o_buf o_buf_dut2 (
    .i(I),
    .o(O2)
  );

task compare(O1, O2);
    if(O1 !== O2) begin
        $display("Output mismatch. dut1: %0h, dut2: %0h", O1, O2);
        mismatch = mismatch+1;
    end
endtask
endmodule

module o_buf (input i, output o
);
  assign o = i;
endmodule
