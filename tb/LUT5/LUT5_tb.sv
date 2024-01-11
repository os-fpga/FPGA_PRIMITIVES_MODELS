module LUT5_tb;

  // Ports
  reg clk;
  reg  [4:0]A;
  wire  Y_LUT5_0, Y_LUT5_1, Y_LUT5_2;
  wire Y_lut_0, Y_lut_1, Y_lut_2;
  
  integer i;
  integer mismatch = 0;
  reg [2:0] cycle;

  always #(10)   
  clk = !clk;

  // $lut Instantiation
 \$lut
 #(
    .WIDTH(5),
    .LUT(32'h0)
 )
 lut_dut0 (
    .A(A),
    .Y(Y_lut_0)
 );

 // LUT5 Instantiation
  LUT5 
  #(
    .INIT_VALUE (32'h0)
  )
  LUT5_dut0 (
    .A(A),
    .Y(Y_LUT5_0)
  );

    // $lut Instantiation
 \$lut
 #(
    .WIDTH(5),
    .LUT(32'h1)
 )
 lut_dut1 (
    .A(A),
    .Y(Y_lut_1)
 );

 // LUT5 Instantiation
  LUT5 
  #(
    .INIT_VALUE (32'h1)
  )
  LUT5_dut1 (
    .A(A ),
    .Y(Y_LUT5_1)
  );

  // $lut Instantiation
 \$lut
 #(
    .WIDTH(5),
    .LUT(32'h2)
 )
 lut_dut2 (
    .A(A),
    .Y(Y_lut_2)
 );

  // LUT5 Instantiation
  LUT5
  #(
    .INIT_VALUE (32'h2)
  )
  LUT5_dut2 (
    .A(A),
    .Y(Y_LUT5_2)
  );

  initial begin
    begin
        A = 0;
        clk = 0;
        repeat (2) @(posedge clk);
        for (i=0; i<50; i=i+1)begin
            repeat (1) @ (posedge clk)
            A <= $random; 
            cycle = cycle + 1;
            compare(cycle);
        end

        if(mismatch == 0)
            $display("\nSimulation result: Test Passed");
        else begin
            $display("\nSimulation result: Test Failed");
            $display("%0d comparison(s) mismatched\nERROR: SIM: Simulation Failed", mismatch);
        end
        
        repeat (5) @(posedge clk);
        $finish;
    end
  end

  task compare(input integer cycle);
    if(Y_LUT5_0 !== Y_lut_0) begin
        $display("Y mismatch. LUT1_0: %0h, $lut_0: %0h, Time: %0t", Y_LUT5_0, Y_lut_0, $time);
        mismatch = mismatch+1;
    end

    else if(Y_LUT5_1 !== Y_lut_1) begin
        $display("Y mismatch. LUT1_1: %0h, $lut_1: %0h, Time: %0t", Y_LUT5_1, Y_lut_1, $time);
        mismatch = mismatch+1;
    end

    else if(Y_LUT5_2 !== Y_lut_2) begin
        $display("Y mismatch. LUT1_2: %0h, $lut_2: %0h, Time: %0t", Y_LUT5_2, Y_lut_2, $time);
        mismatch = mismatch+1;
    end
    endtask

  initial begin
    $dumpfile("tb.vcd");
    $dumpvars;
end
endmodule

// $lut Declaration
module \$lut (A, Y);
parameter WIDTH = 0;
parameter LUT = 0;
input [WIDTH-1:0] A;
output Y;
\$bmux #(.WIDTH(1), .S_WIDTH(WIDTH)) mux(.A(LUT), .S(A), .Y(Y));
endmodule

// $bmux Declaration
module \$bmux (A, S, Y);
parameter WIDTH = 0;
parameter S_WIDTH = 0;
input [(WIDTH << S_WIDTH)-1:0] A;
input [S_WIDTH-1:0] S;
output [WIDTH-1:0] Y;
wire [WIDTH-1:0] bm0_out, bm1_out;
generate
	if (S_WIDTH > 1) begin:muxlogic
		\$bmux #(.WIDTH(WIDTH), .S_WIDTH(S_WIDTH-1)) bm0 (.A(A), .S(S[S_WIDTH-2:0]), .Y(bm0_out));
		\$bmux #(.WIDTH(WIDTH), .S_WIDTH(S_WIDTH-1)) bm1 (.A(A[(WIDTH << S_WIDTH)-1:WIDTH << (S_WIDTH - 1)]), .S(S[S_WIDTH-2:0]), .Y(bm1_out));
		assign Y = S[S_WIDTH-1] ? bm1_out : bm0_out;
	end else if (S_WIDTH == 1) begin:simple
		assign Y = S ? A[1] : A[0];
	end else begin:passthru
		assign Y = A;
	end
endgenerate
endmodule
