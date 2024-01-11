

module adder_carry_tb;

  //Ports
  reg  p;
  reg  g;
  reg  cin;
  wire o;
  wire cout1, cout2;
  reg clk = 1;

  integer i;
  integer mismatch=0;
  reg [6:0]cycle;

  always #(10)  
  clk = !clk;

  adder_carry adder_carry_inst (
    .p(p),
    .g(g),
    .cin(cin),
    .sumout(o),
    .cout(cout1)
  );

  adder adder_inst (
    .p(p),
    .g(g),
    .cin(cin),
    .o(o),
    .cout(cout2)
  );

  initial begin
    {p , g, cin} = 0;

    repeat (5) @(negedge clk);

    for (i=0; i<=100; i=i+1)begin
        repeat (1) @ (negedge clk)
        p <= $random; 
        g <= $random; 
        cin <= $random;
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
    if(cout1 !== cout2) begin
        $display("DATA mismatch !!! Carry Chain: %0d, Adder: %0d, Time: %0t", cout1, cout2, $time);
        mismatch = mismatch+1;
    end
    endtask

  initial begin
    $dumpfile("CARRY_CHAIN.vcd");
    $dumpvars;
  end

endmodule


module adder(
    input wire p,
    input wire g,
    input wire cin,
    output wire o,
    output wire cout
);

assign o = p ^ cin;
assign cout = p ? cin : g;

endmodule