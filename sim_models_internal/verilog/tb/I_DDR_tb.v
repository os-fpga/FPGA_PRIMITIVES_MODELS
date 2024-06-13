module I_DDR_tb;

  // Ports
  reg CLK = 0;
  wire[1:0] I_DDR_Q, Expected_Q;
  reg R;
  reg DD;
  integer mismatch = 0;
  integer i;

  always #5 CLK = ~CLK;

  initial begin
    begin
      DD = 0;
      $display ("Random input ");  
      R = 0;
      @(posedge CLK);
      R = 1;
      @(posedge CLK);

      for (i = 0; i < 20; i = i + 1) begin
        @(CLK);
        DD <= $random;
        compare(I_DDR_Q, Expected_Q);
      end
      repeat(2) @(posedge CLK);

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

  I_DDR I_DDR_dut1 (
    .D(DD),
    .R(R),
    .E(1'b1),
    .C(CLK),
    .Q(I_DDR_Q)
  );

  i_ddr i_ddr_dut2 (
    .data(DD),
    .rst(R),
    .en(1'b1),
    .clk(CLK),
    .Q(Expected_Q)
  );

task compare(I_DDR_Q, Expected_Q);
    if(I_DDR_Q !== Expected_Q) begin
        $display("Output mismatch. I_DDR_Q: %0h, Expected_Q: %0h", I_DDR_Q, Expected_Q);
        mismatch = mismatch + 1;
    end
endtask

endmodule

module i_ddr (
  input data, 
  input rst, 
  input en, 
  input clk, 
  output reg [1:0] Q
);

reg [1:0] temp;

always@(posedge clk or negedge rst) begin
  if (!rst)
    temp[0] <= 1'd0;
  else if (en) begin
    temp[0] <= data;
  end 
end

always@(negedge clk or negedge rst) begin
  if (!rst)
    temp[1] <= 1'd0;
  else if (en) begin
    temp[1] <= data;
  end
end

always @(posedge clk or negedge rst) begin
  if (!rst)
    Q <= 2'd0;
  else
    Q[0] = temp[1];
    Q[1] = temp[0];
end

endmodule