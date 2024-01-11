`timescale 1ns/1ps


module O_SERDES_tb;

	// Parameters
	localparam  DATA_RATE = "SDR";
	localparam  WIDTH = 4;

	//Ports
	reg [WIDTH-1:0] D;
	reg  RST;
	reg  LOAD_WORD;
	reg  CLK_IN;
	reg  OE_IN;
	wire  OE_OUT;
	wire  Q;
	reg  CHANNEL_BOND_SYNC_IN;
	wire  CHANNEL_BOND_SYNC_OUT;
	reg  PLL_LOCK;
	reg  PLL_CLK;

	reg [WIDTH-1:0] dat = 0;
	integer error = 0;

	O_SERDES # (
	.DATA_RATE(DATA_RATE),
	.WIDTH(WIDTH)
	)
	O_SERDES_inst (
	.D(D),
	.RST(RST),
	.LOAD_WORD(LOAD_WORD),
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
		LOAD_WORD=0;
		OE_IN=0;
		D=0;
		@(negedge CLK_IN);
		RST=1;
		CHANNEL_BOND_SYNC_IN=1;
		PLL_LOCK=1;

		// Data 1
		D=4'b0101;
		OE_IN=1;
		dat = D;
		repeat(WIDTH)@(negedge LOAD_WORD);
		repeat(WIDTH)
		begin
			@(posedge PLL_CLK);
			if (dat[WIDTH-1] != Q && OE_OUT != OE_IN)
				error = error + 1;
			dat = dat << 1;
			
		end
		@(negedge CLK_IN);

		// Data 2
		D=$urandom();
		OE_IN=0;
		dat = D;
		repeat(WIDTH)@(negedge LOAD_WORD);
		repeat(WIDTH)
		begin
			@(posedge PLL_CLK);
			if (dat[WIDTH-1] != Q  && OE_OUT != OE_IN)
				error = error + 1;
			dat = dat << 1;
		end
		@(negedge CLK_IN);

		// Data 3
		D=$urandom();
		OE_IN=1;
		dat = D;
		repeat(WIDTH)@(negedge LOAD_WORD);
		repeat(WIDTH)
		begin
			@(posedge PLL_CLK);
			if (dat[WIDTH-1] != Q && OE_OUT != OE_IN)
				error = error + 1;
			dat = dat << 1;
		end

		// mismatch detection
		if (error == 0)
			$display("Simulation Passed");
		else
			$display("Simulation Failed");
		#1000;
		$finish;
	end

	initial 
	begin
		$dumpfile("O_SERDES.vcd");
		$dumpvars;
	end
	initial 
	begin
		forever 
		begin
			@(negedge CLK_IN);
			LOAD_WORD =1;
			@(posedge PLL_CLK);
			LOAD_WORD =0;
		end
	end

endmodule
