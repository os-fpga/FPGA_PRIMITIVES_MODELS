module tb_dsp19x2_inst_design;
	reg  [9:0] a1;
	reg  [8:0] b1;
    reg  [9:0] a2;
	reg  [8:0] b2;
	reg clk, reset;
	wire  [18:0] z_out1;
    wire  [18:0] z_out2;
	reg  [18:0] expected_out1;
    reg [18:0] multiple1;
    reg [18:0] multiple_acc1;
    reg  [18:0] expected_out2;
    reg [18:0] multiple2;
    reg [18:0] multiple_acc2;

integer mismatch =0;
dsp19x2_inst_design inst(.*);


//clock initialization
initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end
initial begin
	{reset, a1, b1, expected_out1, multiple_acc1, multiple1, a2, b2, expected_out2, multiple_acc2, multiple2}= 'd0;
	@(negedge clk);
	reset = 1;
	$display ("\n\n***Reset Test is applied***\n\n");
	display_stimulus1();
    display_stimulus2();
	@(negedge clk);
	@(negedge clk);
	compare1();
    compare2();
	$display ("\n\n***Reset Test is ended***\n\n");

	reset = 0;
	@(negedge clk);

	$display ("\n\n***Directed Functionality Test is applied for z_out1 = z_out1 + a1*b1***\n\n");
    $display ("\n\n***Directed Functionality Test is applied for z_out2 = z_out2 + a2*b2***\n\n");
	a1 = 10'hFF;
	b1 = 9'h7F;
    a2 = 10'hFF;
	b2 = 9'h7F;
	display_stimulus1();
    display_stimulus2();
	@(posedge clk);
    multiple1 = a1*b1;
    multiple_acc1 = multiple1 + multiple_acc1;
	expected_out1 = multiple_acc1 & (multiple1);
    multiple2 = a2*b2;
    multiple_acc2 = multiple2 + multiple_acc2;
	expected_out2 = multiple_acc2 & (multiple2);
	@(negedge clk);
	compare1();
    compare2();
	$display ("\n\n***Directed Functionality Test for z_out1 = z_out1 + a1*b1 is ended***\n\n");
    $display ("\n\n***Directed Functionality Test for z_out2 = z_out2 + a2*b2 is ended***\n\n");

	
	$display ("\n\n*** Random Functionality Tests with random inputs are applied for z_out1 = z_out1 + a1*b1***\n\n");
    $display ("\n\n*** Random Functionality Tests with random inputs are applied for z_out2 = z_out2 + a2*b2***\n\n");
	
	repeat (600) begin
		a1 = $urandom( );
		b1 = $urandom( );
        a2 = $urandom( );
		b2 = $urandom( );
		display_stimulus1();
        display_stimulus2();
	        @(posedge clk);
            multiple1 = a1*b1;
            multiple_acc1 = multiple1 + multiple_acc1;
	        expected_out1 = multiple_acc1 & (multiple1);
            multiple2 = a2*b2;
            multiple_acc2 = multiple2 + multiple_acc2;
	        expected_out2 = multiple_acc2 & (multiple2);
	        @(negedge clk);
	        compare1();
            compare2();
	end
	$display ("\n\n***Random Functionality Tests with random inputs for z_out1 = z_out1 + a1*b1 are ended***\n\n");
    $display ("\n\n***Random Functionality Tests with random inputs for z_out2 = z_out2 + a2*b2 are ended***\n\n");

    if(mismatch == 0)
        $display("\n**** All Comparison Matched ***\nSimulation Passed");
    else
        $display("%0d comparison(s) mismatched\nERROR: SIM: Simulation Failed", mismatch);
	$finish;
end
	

task compare1();
 	
  	if(z_out1 !== expected_out1 || z_out1 !== expected_out1) begin
    	$display("Data Mismatch. Golden RTL1: %0d, Expected output1: %0d, Time: %0t", z_out1, expected_out1, $time);
    	mismatch = mismatch+1;
 	end
  	else
  		$display("Data Matched. Golden RTL1: %0d, Expected output1: %0d, Time: %0t", z_out1, expected_out1, $time);
endtask
task compare2();
    if(z_out2 !== expected_out2 || z_out2 !== expected_out2) begin
    	$display("Data Mismatch. Golden RTL2: %0d, Expected output2: %0d, Time: %0t", z_out2, expected_out2, $time);
    	mismatch = mismatch+1;
 	end
  	else
  		$display("Data Matched. Golden RTL2: %0d, Expected output2: %0d, Time: %0t", z_out2, expected_out2, $time);
endtask

task display_stimulus1();
	$display ($time,," Test stimulus is: a1=%0d, b1=%0d", a1, b1);
endtask
task display_stimulus2();
    $display ($time,," Test stimulus is: a2=%0d, b2=%0d", a2, b2);
endtask

initial begin
    `ifdef PNR
        $dumpfile("dsp19x2_pnr.vcd");
    `elsif GATE
        $dumpfile("dsp19x2_gate.vcd");
    `else
        $dumpfile("dsp19x2_rtl.vcd");
    `endif
    $dumpvars;
end
endmodule