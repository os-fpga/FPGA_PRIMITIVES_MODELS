`timescale 1ns/1ps

module O_DELAY_tb;

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

O_DELAY # (
  .DELAY(DELAY)
)
O_DELAY_inst (
  .I(I),
  .DLY_LOAD(DLY_LOAD),
  .DLY_ADJ(DLY_ADJ),
  .DLY_INCDEC(DLY_INCDEC),
  .DLY_TAP_VALUE(DLY_TAP_VALUE),
  .CLK_IN(CLK_IN),
  .O(O)
);

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
		$display("PASSED");
	else
		$error("DELAY TAP LOAD FAILED %0d",DLY_TAP_VALUE);
    // CHECK DELAY ADJUST AND INC
	DLY_LOAD = 0;
	I = 0;
	DLY_ADJ = 1;
	DLY_INCDEC = 1;
	repeat(DELAY)@(posedge CLK_IN);
	#1;
	if(DLY_TAP_VALUE==DELAY+1)
		$display("PASSED");
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
		$display("PASSED");
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
		$display("PASSED");
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
		$display("PASSED");
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
		$display("PASSED");
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
		$display("PASSED");
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
		$display("PASSED");
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
		$display("PASSED");
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
		$display("PASSED");
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
	#100;
	$finish;
end

initial 
	begin
	    $dumpfile("waves.vcd");
	    $dumpvars;
	end

endmodule