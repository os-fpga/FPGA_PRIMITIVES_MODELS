module O_BUFT_DS_tb;

  // Ports
  reg EN = 0;
  reg I = 0;
  reg T = 0;
  wire O_P1, O_P2;
  wire O_N1, O_N2;
  reg CLK = 0;
  localparam WEAK_KEEPER = "NONE";
  integer mismatch = 0;
  always #5 CLK = ~CLK;

  always @(posedge CLK) begin
    I <= $random;
    T <= $random;
    compare(O_P1, O_P2, O_N1, O_N2);
  end
  initial begin
      $dumpfile("O_BUFT_DS.vcd");
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

  O_BUFT_DS 
  O_BUFT_DS_dut1 (
    .I (I),
    .T(T),
    .O_P (O_P1),
    .O_N(O_N1)
  );

  o_buft_ds o_buft_ds_dut2 (
    .i(I),
    .t(T),
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

module o_buft_ds (input i, output o_n, output o_p, input t
);
  assign o_p = t ? i : 'hz;
  assign o_n = t ? ~i : 'hz;
endmodule
