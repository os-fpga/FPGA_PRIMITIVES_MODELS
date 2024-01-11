
module O_BUFT_tb;

  // Parameters
  localparam  WEAK_KEEPER = "NONE";

  //Ports
  reg  I;
  reg  T;
  wire  O1, O2;
  reg clk=1;
  integer mismatch = 0;

  O_BUFT # (
    .WEAK_KEEPER(WEAK_KEEPER)
  )
  O_BUFT_inst (
    .I(I),
    .T(T),
    .O(O1)
  );

  o_buft #()
  o_buft_inst (
    .I(I),
    .T(T),
    .O(O2)
  );

  always #5  clk = ! clk ;

  always @(posedge clk) begin
    I <= $random;
    T <= $random;
  end

  initial begin
    $dumpfile("O_BUFT.vcd");
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

module o_buft (
  input I,
  input T,
  output O
);

assign O = T ? I : 1'bz;
  
endmodule