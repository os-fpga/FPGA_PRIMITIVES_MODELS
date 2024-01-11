module DFFNRE_tb;

  // Ports
  reg EN = 0;
  reg I = 0;
  wire O1, O2;
  reg CLK = 1;
  localparam DELAY = 0;
  integer mismatch = 0;
  always #5 CLK = ~CLK;

  always @(posedge CLK) begin
    I <= $random;
    compare(O1, O2);
  end
  initial begin
      $dumpfile("DFFNRE.vcd");
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
  initial begin
    begin
      // DD = 0;
      $display ("Random input ");  
      repeat(10) @(posedge CLK);
    end
  end

  DFFNRE #()
  DFFNRE_dut1 (
    .D(I),
    .R(rst),
    .E(1'b1),
    .Q(O1),
    .C (CLK)
  );

  dffnre dffnre_dut2 (
    .din(I),
    .q(O2),
    .en(1'b1),
    .clk(CLK)
  );

task compare(O1, O2);
    if(O1 !== O2) begin
        $display("Output mismatch. dut1: %0h, dut2: %0h", O1, O2);
        mismatch = mismatch+1;
    end
endtask
endmodule

module dffnre (input din, output q, input en, input clk
);
reg Q_reg;
wire Q_assign;

always @(negedge clk) begin
    if (en) begin
        Q_reg <= din;
    end
    else begin
        Q_reg <= 1'b0;
    end
end

assign q = Q_reg;
endmodule
