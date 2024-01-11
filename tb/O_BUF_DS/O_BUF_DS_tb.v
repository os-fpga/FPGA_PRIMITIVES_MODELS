module O_BUF_DS_tb;

  // Ports
  reg EN = 0;
  reg I = 0;
  wire O_P1, O_P2;
  wire O_N1, O_N2;
  reg CLK = 0;
  integer mismatch = 0;
  always #5 CLK = ~CLK;

  always @(posedge CLK) begin
    I <= $random;
    EN <= $random;
    compare(O_P1, O_P2, O_N1, O_N2);
  end
  initial begin
      $dumpfile("O_BUF_DS.vcd");
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

  O_BUF_DS 
  O_BUF_DS_dut1 (
    .I (I),
    .O_P (O_P1),
    .O_N(O_N1)
  );

  o_buf_ds o_buf_ds_dut2 (
    .i(I),
    .o_p(O_P2),
    .o_n(O_N2)
  );

task compare(O_P1, O_P2, O_N1, O_N2);
    if(O_P1 !== O_P2) begin
        $display("Positive Output mismatch. dut1: %0h, dut2: %0h", O_P1, O_P2);
        mismatch = mismatch+1;
    end
    if(O_N1 !== O_N2) begin
        $display("Negative Output mismatch. dut1: %0h, dut2: %0h", O_N1, O_N2);
        mismatch = mismatch+1;
    end
endtask
endmodule

module o_buf_ds (input i, output o_n, output o_p
);
  assign o_p = i;
  assign o_n = ~i;
endmodule
