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
		#1000;
		$finish;
	end

	initial 
	begin
		$dumpfile("O_SERDES.vcd");
		$dumpvars;
	end

endmodule
