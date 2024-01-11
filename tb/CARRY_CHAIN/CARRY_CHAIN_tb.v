

module CARRY_CHAIN_tb;

  //Ports
  reg  P;
  reg  G;
  reg  CIN;
  wire O;
  wire COUT1, COUT2;
  reg clk = 1;

  integer i;
  integer mismatch=0;
  reg [6:0]cycle;

  always #(10)  
  clk = !clk;

  CARRY_CHAIN  CARRY_CHAIN_inst (
    .P(P),
    .G(G),
    .CIN(CIN),
    .O(O),
    .COUT(COUT1)
  );

  adder adder_inst (
    .P(P),
    .G(G),
    .CIN(CIN),
    .O(O),
    .COUT(COUT2)
  );

  initial begin
    {P , G, CIN} = 0;

    repeat (5) @(negedge clk);

    for (i=0; i<=100; i=i+1)begin
        repeat (1) @ (negedge clk)
        P <= $random; 
        G <= $random; 
        CIN <= $random;
        cycle = cycle +1;
        compare(cycle);
    end

    if(mismatch == 0)
      $display("\nSimulation result: Test Passed");
    else begin
      $display("\nSimulation result: Test Failed");
      $display("%0d comparison(s) mismatched\nERROR: SIM: Simulation Failed", mismatch);
    end
    repeat (10) @(negedge clk); 

    $finish;
  end

  task compare(input integer cycle);
    if(COUT1 !== COUT2) begin
        $display("DATA mismatch !!! Carry Chain: %0d, Adder: %0d, Time: %0t", COUT1, COUT2, $time);
        mismatch = mismatch+1;
    end
    endtask

  initial begin
    $dumpfile("CARRY_CHAIN.vcd");
    $dumpvars;
  end

endmodule


module adder(
    input wire P,
    input wire G,
    input wire CIN,
    output wire O,
    output wire COUT
);

assign O = P ^ CIN;
assign COUT = P ? CIN : G;

endmodule