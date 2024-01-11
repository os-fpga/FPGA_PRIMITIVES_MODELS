module I_BUF_tb;

  // Ports
  reg EN = 0;
  reg I = 0;
  wire O1, O2;
  reg CLK = 0;
  integer mismatch = 0;
  localparam WEAK_KEEPER = "NONE";
  always #5 CLK = ~CLK;

  always @(posedge CLK) begin
    I <= $random;
    EN <= $random;
    compare(O1, O2);
  end
  initial begin
      $dumpfile("I_BUF.vcd");
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

  I_BUF #(.WEAK_KEEPER(WEAK_KEEPER)) 
  I_BUF_dut1 (
    .I (I),
    .EN(EN),
    .O (O1)
  );

  i_buf i_buf_dut2 (
    .en(EN),
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

module i_buf (
  input en, input i, output o
);
  assign o = en ? i : 0;
endmodule
