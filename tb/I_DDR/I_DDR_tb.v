module I_DDR_tb;

  // Ports
  reg CLK = 0;
  wire[1:0] O1, O2;
  reg R;
  reg DD;
  integer mismatch = 0;

  always #5 CLK = ~CLK;

  always @(CLK) begin
    DD <= $random;
    compare(O1, O2);
  end

  initial begin
    begin
      // DD = 0;
      $display ("Random input ");  
      R = 0;
      repeat(2) @(posedge CLK);
      R = 1;
      repeat(10) @(posedge CLK);
      if (mismatch > 0) begin
      $display("-----------------Simulation Failed-----------------");
      end
      else begin
        $display("-----------------Simulation Passed-----------------");
      end
    end
  end

  initial begin
      $dumpfile("I_DDR.vcd");
      $dumpvars;
      #500;
      $display ("FINISH");
      $finish;
  end

  I_DDR 
  I_DDR_dut1 (
    .D (DD),
    .R (R),
    .E (1'b1),
    .C (CLK),
    .Q (O1)
  );

  i_ddr i_ddr_dut2 (
    .data(DD),
    .rst(R),
    .en(1'b1),
    .clk(CLK),
    .Q(O2)
  );

task compare(O1, O2);
    if(O1 !== O2) begin
        $display("Output mismatch. dut1: %0h, dut2: %0h", O1, O2);
        mismatch = mismatch + 1;
    end
endtask

endmodule

module i_ddr (
  input data, input rst, input en, input clk, output [1:0] Q
);
reg [1:0] Q = 2'd0;
always@(posedge clk) begin
  if (en) begin
    Q[0] <= data;
  end 
end

always@(clk) begin
  if(!rst)
    Q <= 2'b00;
end

always@(negedge clk) begin
  if (en) begin
    Q[1] <= data;
  end
end

always@(negedge rst) begin
  Q <= 2'b00;
end

endmodule