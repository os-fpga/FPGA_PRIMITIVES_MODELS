module DFFRE_tb;

  // Ports
  reg EN = 0;
  reg I = 0;
  reg rst;
  wire O1, O2;
  reg CLK = 0;
  localparam DELAY = 0;
  integer mismatch = 0;
  always #5 CLK = ~CLK;

  always @(posedge CLK) begin
    I <= $random;
    compare(O1, O2);
  end
  initial begin
      $dumpfile("DFFRE.vcd");
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
      rst = 0;
      repeat(2) @(posedge CLK);
      rst = 1;
      repeat(10) @(posedge CLK);
    end
  end

  DFFRE #()
  DFFRE_dut1 (
    .D(I),
    .R(rst),
    .E(1'b1),
    .Q(O1),
    .C (CLK)
  );

  dffre dffre_dut2 (
    .din(I),
    .q(O2),
    .rst(rst),
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

module dffre (input din, output q, input rst, input en, input clk
);
reg Q_reg;
wire Q_assign;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        Q_reg <= 1'b0;
    end else if (en) begin
        Q_reg <= din;
    end
end

assign Q_assign = (rst && en) ? Q_reg : 1'b0;
assign q = Q_assign;
endmodule
