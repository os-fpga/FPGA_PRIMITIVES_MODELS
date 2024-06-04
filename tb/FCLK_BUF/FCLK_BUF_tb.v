module FCLK_BUF_tb;

  // Ports
  reg CLK = 0;
  wire O1, O2;
  integer mismatch = 0;

  always #5 CLK = ~CLK;

  initial begin
      $dumpfile("FCLK_BUF.vcd");
      $dumpvars;
      #500;
      compare(O1, O2);
      if (mismatch > 0) begin
        $display("-----------------Simulation Failed-----------------");
      end
      else begin
        $display("-----------------Simulation Passed-----------------");
      end
      $display ("FINISH");
      $finish;
  end

  FCLK_BUF fclkbuf_dut1 (
      .I(CLK),
      .O(O1)
  );

  fclk_buf fclk_buf_dut2 (
    .i(CLK),
    .o(O2)
  );

task compare(O1, O2);
    if(O1 !== O2) begin
        $display("Output mismatch. dut1: %0h, dut2: %0h", O1, O2);
        mismatch = mismatch+1;
    end
endtask
endmodule



module fclk_buf (i, o);
input wire i;
output wire o;

assign o = i;

endmodule