`timescale 1ns/1ps

module I_DELAY_tb;

// Parameters
localparam  DELAY = 4;

//Ports
reg  I;
reg  DLY_LOAD;
reg  DLY_ADJ;
reg  DLY_INCDEC;
wire [5:0] DLY_TAP_VALUE;
reg  CLK_IN;
wire  O;

I_DELAY # (
  .DELAY(DELAY)
)
I_DELAY_inst (
  .I(I),
  .DLY_LOAD(DLY_LOAD),
  .DLY_ADJ(DLY_ADJ),
  .DLY_INCDEC(DLY_INCDEC),
  .DLY_TAP_VALUE(DLY_TAP_VALUE),
  .CLK_IN(CLK_IN),
  .O(O)
);

integer time1;
integer time2;
integer time_final;
integer formula;
integer delay_value;

always #5  CLK_IN = ! CLK_IN ;

initial 
begin
	// INITIALIZATION
	CLK_IN = 0;
	I = 0;
	DLY_LOAD = 0;
	DLY_ADJ = 0;
	DLY_INCDEC = 0;
	// CHECK THE DELAY LOAD
	@(negedge CLK_IN);
	DLY_LOAD = 1;
	I = 1;
	DLY_ADJ = 0;
	DLY_INCDEC = 0;
	repeat(DELAY)@(posedge CLK_IN);
	#1;
	if(DLY_TAP_VALUE==DELAY)
		$display("Test Passed");
	else
		$error("DELAY TAP LOAD FAILED %0d",DLY_TAP_VALUE);
	// CHECK THE DELAY LOAD WITH FORMULA
	@(negedge CLK_IN);
	DLY_LOAD = 0;
	I = 0;
	DLY_ADJ = 0;
	DLY_INCDEC = 0;
	delay_value = DLY_TAP_VALUE;
	time1 = $realtime;
	formula = ((delay_value*21.56)+30.00);
	wait(O==0);
	time2 = $realtime;
	time_final = time2 - time1;
	if(time_final == formula) 
		$display("Test Passed");
	else
		$error("DELAY TAP LOAD FAILED %0d %0d",formula, time_final);
    // CHECK DELAY ADJUST AND INC
	DLY_LOAD = 0;
	I = 0;
	DLY_ADJ = 1;
	DLY_INCDEC = 1;
	repeat(DELAY)@(posedge CLK_IN);
	#1;
	if(DLY_TAP_VALUE==DELAY+1)
		$display("Test Passed");
	else
		$error("DELAY ADJ INC FAILED %0d",DLY_TAP_VALUE);
	// DLY ADJ TO 0
	@(negedge CLK_IN);
	DLY_LOAD = 0;
	I = 0;
	DLY_ADJ = 0;
	DLY_INCDEC = 0;
	// DLY ADJ AND INC TO 1
	@(negedge CLK_IN);
	DLY_LOAD = 0;
	I = 0;
	DLY_ADJ = 1;
	DLY_INCDEC = 1;
	repeat(DELAY)@(posedge CLK_IN);
	#1;
	if(DLY_TAP_VALUE==DELAY+2)
		$display("Test Passed");
	else
		$error("DELAY ADJ INC FAILED %0d",DLY_TAP_VALUE);
	// DLY ADJ TO 0
	@(negedge CLK_IN);
	DLY_LOAD = 0;
	I = 0;
	DLY_ADJ = 0;
	DLY_INCDEC = 0;
	// DLY ADJ AND INC TO 1
	@(negedge CLK_IN);
	DLY_LOAD = 0;
	I = 0;
	DLY_ADJ = 1;
	DLY_INCDEC = 1;
	repeat(DELAY)@(posedge CLK_IN);
	#1;
	if(DLY_TAP_VALUE==DELAY+3)
		$display("Test Passed");
	else
		$error("DELAY ADJ INC FAILED %0d",DLY_TAP_VALUE);

	// DLY ADJ TO 0
	@(negedge CLK_IN);
	DLY_LOAD = 0;
	I = 1;
	DLY_ADJ = 0;
	DLY_INCDEC = 0;
	// DLY ADJ TO 1 AND INC TO 0
	@(negedge CLK_IN);
	DLY_LOAD = 0;
	I = 1;
	DLY_ADJ = 1;
	DLY_INCDEC = 0;
	repeat(DELAY)@(posedge CLK_IN);
	#1;
	if(DLY_TAP_VALUE==DELAY+2)
		$display("Test Passed");
	else
		$error("DELAY ADJ DEC FAILED %0d",DLY_TAP_VALUE);

	// DLY ADJ TO 0
	@(negedge CLK_IN);
	DLY_LOAD = 0;
	I = 1;
	DLY_ADJ = 0;
	DLY_INCDEC = 0;
	// DLY ADJ TO 1 AND INC TO 0
	@(negedge CLK_IN);
	DLY_LOAD = 0;
	I = 1;
	DLY_ADJ = 1;
	DLY_INCDEC = 0;
	repeat(DELAY)@(posedge CLK_IN);
	#1;
	if(DLY_TAP_VALUE==DELAY+1)
		$display("Test Passed");
	else
		$error("DELAY ADJ DEC FAILED %0d",DLY_TAP_VALUE);
	// DLY ADJ TO 0
	@(negedge CLK_IN);
	DLY_LOAD = 0;
	I = 1;
	DLY_ADJ = 0;
	DLY_INCDEC = 0;
	// DLY ADJ TO 1 AND INC TO 0
	@(negedge CLK_IN);
	DLY_LOAD = 0;
	I = 1;
	DLY_ADJ = 1;
	DLY_INCDEC = 0;
	repeat(DELAY)@(posedge CLK_IN);
	#1;
	if(DLY_TAP_VALUE==DELAY)
		$display("Test Passed");
	else
		$error("DELAY ADJ DEC FAILED %0d",DLY_TAP_VALUE);
	
	// DLY ADJ TO 0
	@(negedge CLK_IN);
	DLY_LOAD = 0;
	I = 1;
	DLY_ADJ = 0;
	DLY_INCDEC = 0;
	// DLY ADJ TO 1 AND INC TO 0
	@(negedge CLK_IN);
	DLY_LOAD = 0;
	I = 1;
	DLY_ADJ = 1;
	DLY_INCDEC = 0;
	repeat(DELAY)@(posedge CLK_IN);
	#1;
	if(DLY_TAP_VALUE==DELAY-1)
		$display("Test Passed");
	else
		$error("DELAY ADJ DEC FAILED %0d",DLY_TAP_VALUE);

	// CHECK THE DELAY LOAD
	@(negedge CLK_IN);
	DLY_LOAD = 1;
	I = 1;
	DLY_ADJ = 0;
	DLY_INCDEC = 0;
	repeat(DELAY)@(posedge CLK_IN);
	#1;
	if(DLY_TAP_VALUE==DELAY)
		$display("Test Passed");
	else
		$error("DELAY TAP LOAD FAILED %0d",DLY_TAP_VALUE);

	// TAP VAL SHOULD BE STABLE
	@(negedge CLK_IN);
	DLY_LOAD = 0;
	I = 1;
	DLY_ADJ = 0;
	DLY_INCDEC = 1;
	repeat(DELAY)@(posedge CLK_IN);
	#1;
	if(DLY_TAP_VALUE==DELAY)
		$display("Test Passed");
	else
		$error("TAP VAL STABLE TEST FAILED %0d",DLY_TAP_VALUE);
	// MAX INC DEC CHECK
	for(int i=0;i<=63;i++)
	begin
		@(negedge CLK_IN);
		I = 0;
		DLY_LOAD = 0;
		DLY_ADJ = 0;
		DLY_INCDEC = 1;
		@(negedge CLK_IN);
		I = 1;
		DLY_LOAD = 0;
		DLY_ADJ = 1;
		DLY_INCDEC = 1;
	end
	for(int i=0;i<=63;i++)
	begin
		@(negedge CLK_IN);
		I = 0;
		DLY_LOAD = 0;
		DLY_ADJ = 0;
		DLY_INCDEC = 0;
		@(negedge CLK_IN);
		I = 1;
		DLY_LOAD = 0;
		DLY_ADJ = 1;
		DLY_INCDEC = 0;
	end
	#1000;
	$finish;
end

initial 
	begin
	    $dumpfile("waves.vcd");
	    $dumpvars;
	end

endmodule