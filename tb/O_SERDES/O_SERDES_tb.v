`timescale 1ns/1ps


module O_SERDES_tb;

	// Parameters
	localparam  DATA_RATE = "SDR";
	localparam  WIDTH = 4;

	//Ports
	reg [WIDTH-1:0] D;
	reg  RST;
	reg  DATA_VALID;
	reg  CLK_IN;
	reg  OE_IN;
	wire  OE_OUT;
	wire  Q;
	reg  CHANNEL_BOND_SYNC_IN;
	wire  CHANNEL_BOND_SYNC_OUT;
	reg  PLL_LOCK;
	reg  PLL_CLK;

	O_SERDES # (
	.DATA_RATE(DATA_RATE),
	.WIDTH(WIDTH)
	)
	O_SERDES_inst (
	.D(D),
	.RST(RST),
	.DATA_VALID(DATA_VALID),
	.CLK_IN(CLK_IN),
	.OE_IN(OE_IN),
	.OE_OUT(OE_OUT),
	.Q(Q),
	.CHANNEL_BOND_SYNC_IN(CHANNEL_BOND_SYNC_IN),
	.CHANNEL_BOND_SYNC_OUT(CHANNEL_BOND_SYNC_OUT),
	.PLL_LOCK(PLL_LOCK),
	.PLL_CLK(PLL_CLK)
	);

	always #0.2  PLL_CLK = ! PLL_CLK ; // 2.5 GHz
	always #0.8  CLK_IN = ! CLK_IN ;

	integer i, j;
	integer mismatch = 0;	

	reg [WIDTH-1:0] D_MEM [2:0];
	reg [WIDTH-1:0] Q_MEM [2:0];

	reg [3:0] Q_int = 'd0;
	reg [3:0] Q_out = 'd0;
	reg [1:0] count = 'd0;
	reg [1:0] count1 = 'd0;
	reg [1:0] count2 = 'd0;
	reg [1:0] count3 = 'd0;
	reg valid_data = 'd0;

	always @(*) begin
		if (count == 0) begin
    		Q_out = Q_int;
			count1 = count1 + 1;
			valid_data = 1;
		end
	end

	always @(posedge PLL_CLK) begin
		if (valid_data)
			Q_MEM[count1-1] = Q_out;

		if (OE_IN) begin
			count2 <= count2 + 1;
			D_MEM[count3] <= D;
		end

		if (count2 == 3)
			count3 <= count3 + 1; 
		
		if (OE_OUT) begin
			count <= count + 1;
			Q_int <= {Q_int[2:0], Q};
		end
	end

	initial 
	begin
		CLK_IN=0;
		PLL_CLK=1;
		RST=0;
		CHANNEL_BOND_SYNC_IN=0;
		DATA_VALID=1;
		OE_IN=0;
		D=0;
		@(negedge CLK_IN);
		RST=1;
		CHANNEL_BOND_SYNC_IN=1;
		PLL_LOCK=1;
		repeat(260)@(posedge PLL_CLK);
		D=4'b0101;
		OE_IN=1;
		@(negedge CLK_IN);
		D=$urandom();
		@(negedge CLK_IN);
		D=$urandom();
		@(negedge CLK_IN);
		OE_IN=0;

		@(posedge valid_data)
		for (j = 0; j < 3; j = j + 1) begin
			@(posedge CLK_IN);
    		if(D_MEM[j] !== Q_MEM[j])
    		    mismatch = mismatch + 1;
		end

		if (mismatch == 0) begin
			$display("Test Passed");
		end else begin
			$display("Test Failed");
		end

		#1000;
		$finish;
	end

	initial 
	begin
		$dumpfile("O_SERDES.vcd");
		$dumpvars;
	end

endmodule
