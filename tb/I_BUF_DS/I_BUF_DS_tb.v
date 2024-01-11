module I_BUF_DS_tb;

localparam WEAK_KEEPER = "NONE";
  // Ports
  reg EN = 0;
//   reg I = 0;
  reg I_P;
  reg I_N;
  wire O1, O2;
  reg CLK = 0;
  integer mismatch = 0;
  always #5 CLK = ~CLK;

  always @(posedge CLK) begin
    I_P = $random;
    I_N = ~I_P;
    EN = $random;
    compare(O1, O2);
  end
  initial begin
      $dumpfile("I_BUF_DS.vcd");
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

  I_BUF_DS # (
    .WEAK_KEEPER(WEAK_KEEPER)
  )
  I_BUF_DS_inst (
    .I_P(I_P),
    .I_N(I_N),
    .EN(EN),
    .O(O1)
  );

  i_buf_ds i_buf_ds_dut2 (
    .en(EN),
    .i_p(I_P),
    .i_n(I_N),
    .o(O2)
  );

task compare(O1 , O2);
    if(O1 !== O2) begin
        $display("Output mismatch. dut1: %0h, dut2: %0h", O1, O2);
        mismatch = mismatch+1;
    end
endtask
endmodule

module i_buf_ds (input en, input i_n, input i_p, output reg o);

always @(i_p, i_n, en) begin
    casez ({i_p, i_n, en})
      3'b??0 : o = 0;      // When not enabled, output is set to zero
      3'b101 : o = 1;
      3'b011 : o = 0;
      default : begin end  // If enabled and I_P and I_N are the same, output does not change
    endcase
  end
endmodule
