`timescale 1ns/1ps
module DSP19x2_tb;

	`ifdef in_out_reg_mult
		// Parameters
		`define mult_mode
		localparam  DSP_MODE = "MULTIPLY";
		localparam [9:0] COEFF1_0 = 0;
		localparam [9:0] COEFF1_1 = 0;
		localparam [9:0] COEFF1_2 = 0;
		localparam [9:0] COEFF1_3 = 0;
		localparam [9:0] COEFF2_0 = 0;
		localparam [9:0] COEFF2_1 = 0;
		localparam [9:0] COEFF2_2 = 0;
		localparam [9:0] COEFF2_3 = 0;
		localparam  OUTPUT_REG_EN = "TRUE";
		localparam  INPUT_REG_EN = "TRUE";
	`elsif in_reg_mult
		`define mult_mode
		localparam  DSP_MODE = "MULTIPLY";
		localparam [9:0] COEFF1_0 = 0;
		localparam [9:0] COEFF1_1 = 0;
		localparam [9:0] COEFF1_2 = 0;
		localparam [9:0] COEFF1_3 = 0;
		localparam [9:0] COEFF2_0 = 0;
		localparam [9:0] COEFF2_1 = 0;
		localparam [9:0] COEFF2_2 = 0;
		localparam [9:0] COEFF2_3 = 0;
		localparam  OUTPUT_REG_EN = "FALSE";
		localparam  INPUT_REG_EN = "TRUE";
	`elsif out_reg_mult
		`define mult_mode
		localparam  DSP_MODE = "MULTIPLY";
		localparam [9:0] COEFF1_0 = 0;
		localparam [9:0] COEFF1_1 = 0;
		localparam [9:0] COEFF1_2 = 0;
		localparam [9:0] COEFF1_3 = 0;
		localparam [9:0] COEFF2_0 = 0;
		localparam [9:0] COEFF2_1 = 0;
		localparam [9:0] COEFF2_2 = 0;
		localparam [9:0] COEFF2_3 = 0;
		localparam  OUTPUT_REG_EN = "TRUE";
		localparam  INPUT_REG_EN = "FALSE";
	`elsif comb_mult
		`define mult_mode
		localparam  DSP_MODE = "MULTIPLY";
		localparam [9:0] COEFF1_0 = 0;
		localparam [9:0] COEFF1_1 = 0;
		localparam [9:0] COEFF1_2 = 0;
		localparam [9:0] COEFF1_3 = 0;
		localparam [9:0] COEFF2_0 = 0;
		localparam [9:0] COEFF2_1 = 0;
		localparam [9:0] COEFF2_2 = 0;
		localparam [9:0] COEFF2_3 = 0;
		localparam  OUTPUT_REG_EN = "FALSE";
		localparam  INPUT_REG_EN = "FALSE";
	`elsif coeff_mult
		`define mult_mode
		localparam  DSP_MODE = "MULTIPLY";
		localparam [9:0] COEFF1_0 = 2;
		localparam [9:0] COEFF1_1 = 3;
		localparam [9:0] COEFF1_2 = 4;
		localparam [9:0] COEFF1_3 = 5;
		localparam [9:0] COEFF2_0 = 2;
		localparam [9:0] COEFF2_1 = 3;
		localparam [9:0] COEFF2_2 = 4;
		localparam [9:0] COEFF2_3 = 5;
		localparam  OUTPUT_REG_EN = "FALSE";
		localparam  INPUT_REG_EN = "TRUE";
	`elsif acc_mode
		localparam  DSP_MODE = "MULTIPLY_ACCUMULATE";
		localparam [9:0] COEFF1_0 = 0;
		localparam [9:0] COEFF1_1 = 0;
		localparam [9:0] COEFF1_2 = 0;
		localparam [9:0] COEFF1_3 = 0;
		localparam [9:0] COEFF2_0 = 0;
		localparam [9:0] COEFF2_1 = 0;
		localparam [9:0] COEFF2_2 = 0;
		localparam [9:0] COEFF2_3 = 0;
		localparam  OUTPUT_REG_EN = "FALSE";
		localparam  INPUT_REG_EN = "FALSE";
	`elsif acc_bypass_mode
		localparam  DSP_MODE = "MULTIPLY_ADD_SUB";
		localparam [9:0] COEFF1_0 = 0;
		localparam [9:0] COEFF1_1 = 0;
		localparam [9:0] COEFF1_2 = 0;
		localparam [9:0] COEFF1_3 = 0;
		localparam [9:0] COEFF2_0 = 0;
		localparam [9:0] COEFF2_1 = 0;
		localparam [9:0] COEFF2_2 = 0;
		localparam [9:0] COEFF2_3 = 0;
		localparam  OUTPUT_REG_EN = "FALSE";
		localparam  INPUT_REG_EN = "TRUE";
	`endif
	

	//Ports
	reg [9:0] A1;
	reg [8:0] B1;
	wire [18:0] Z1;
	wire [8:0] DLY_B1;
	reg [9:0] A2;
	reg [8:0] B2;
	wire [18:0] Z2;
	wire [8:0] DLY_B2;
	reg  CLK;
	reg  RESET;
	reg [4:0] ACC_FIR;
	reg [2:0] FEEDBACK;
	reg  LOAD_ACC;
	reg  UNSIGNED_A;
	reg  UNSIGNED_B;
	reg  SATURATE;
	reg [4:0] SHIFT_RIGHT;
	reg  ROUND;
	reg  SUBTRACT;

	DSP19X2 # (
		.DSP_MODE(DSP_MODE),
		.COEFF1_0(COEFF1_0),
		.COEFF1_1(COEFF1_1),
		.COEFF1_2(COEFF1_2),
		.COEFF1_3(COEFF1_3),
		.COEFF2_0(COEFF2_0),
		.COEFF2_1(COEFF2_1),
		.COEFF2_2(COEFF2_2),
		.COEFF2_3(COEFF2_3),
		.OUTPUT_REG_EN(OUTPUT_REG_EN),
		.INPUT_REG_EN(INPUT_REG_EN)
		)
	DSP19X2_inst (
		.A1(A1),
		.B1(B1),
		.Z1(Z1),
		.DLY_B1(DLY_B1),
		.A2(A2),
		.B2(B2),
		.Z2(Z2),
		.DLY_B2(DLY_B2),
		.CLK(CLK),
		.RESET(RESET),
		.ACC_FIR(ACC_FIR),
		.FEEDBACK(FEEDBACK),
		.LOAD_ACC(LOAD_ACC),
		.UNSIGNED_A(UNSIGNED_A),
		.UNSIGNED_B(UNSIGNED_B),
		.SATURATE(SATURATE),
		.SHIFT_RIGHT(SHIFT_RIGHT),
		.ROUND(ROUND),
		.SUBTRACT(SUBTRACT)
	);
	

	always #5  CLK = ! CLK ;

	initial 
	begin
		// INITIALIZATION
		CLK=1;
	    RESET=1;
		A1=0;
		A2=0;
	    B1=0;
	    B2=0;
		ACC_FIR=0;
	    FEEDBACK=0;
	    LOAD_ACC=0;
	    SATURATE=0;
	    SHIFT_RIGHT=0;
	    ROUND=0;
	    SUBTRACT=0;
	    UNSIGNED_A=1;
	    UNSIGNED_B=1;
		@(posedge CLK);

		`ifdef mult_mode
			@(negedge CLK);
			// UNSIGNED MULTIPLICATION
	    	RESET=0;
	    	A1 = 3;
	    	B1 = 2;
			A2 = 3;
			B2 = 2;
	    	ACC_FIR=0;
	    	FEEDBACK=0;
	    	LOAD_ACC=0;
	    	SATURATE=0;
	    	SHIFT_RIGHT=0;
	    	ROUND=0;
	    	SUBTRACT=0;
	    	UNSIGNED_A=1;
	    	UNSIGNED_B=1;
			if(INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "TRUE")
				repeat(2)@(posedge CLK);
			else if ((INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "FALSE") || (INPUT_REG_EN == "FALSE" && OUTPUT_REG_EN == "TRUE"))
				@(posedge CLK);

			#1;
			if(Z1===6 && Z2===6)
				$display("UNSIGNED Test Passed");
			else
				$display("UNSIGNED Test Failed \n Z1 = %0d \t Z2= %0d",Z1,Z2);
		
			// SIGNED UNSIGNED MULTIPLICATION
			@(negedge CLK);
			A1 = -3;
			B1 =  2;
			A2 = -3;
			B2 =  2;
			ACC_FIR=0;
			FEEDBACK=0;
			LOAD_ACC=0;
			SATURATE=0;
			SHIFT_RIGHT=0;
			ROUND=0;
			SUBTRACT=0;
			UNSIGNED_A=0;
			UNSIGNED_B=1;
			if(INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "TRUE")
				repeat(2)@(posedge CLK);
			else if ((INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "FALSE") || (INPUT_REG_EN == "FALSE" && OUTPUT_REG_EN == "TRUE"))
				@(posedge CLK);
			
			#1;
			if($signed(Z1)===-6 && $signed(Z2)===-6)
				$display("SIGNED UNSIGNED Test Passed");
			else
				$display("SIGNED UNSIGNED Test Failed \n Z1 = %0d \t Z2= %0d",$signed(Z1),$signed(Z2));

			// UNSIGNED SIGNED MULTIPLICATION
			@(negedge CLK);
			A1 = 3;
			B1 = -3;
			A2 = 3;
			B2 = -3;
			ACC_FIR=0;
			FEEDBACK=0;
			LOAD_ACC=0;
			SATURATE=0;
			SHIFT_RIGHT=0;
			ROUND=0;
			SUBTRACT=0;
			UNSIGNED_A=1;
			UNSIGNED_B=0;
			if(INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "TRUE")
				repeat(2)@(posedge CLK);
			else if ((INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "FALSE") || (INPUT_REG_EN == "FALSE" && OUTPUT_REG_EN == "TRUE"))
				@(posedge CLK);
			
			#1;
			if($signed(Z1)===-9 && $signed(Z2)===-9)
				$display("UNSIGNED SIGNED Test Passed");
			else
				$display("UNSIGNED SIGNED Test Failed \n Z1 = %0d \t Z2= %0d",Z1,Z2);

			// SIGNED MULTIPLICATION
			@(negedge CLK);
			A1 = -3;
			B1 = -3;
			A2 = -3;
			B2 = -3;
			ACC_FIR=0;
			FEEDBACK=0;
			LOAD_ACC=0;
			SATURATE=0;
			SHIFT_RIGHT=0;
			ROUND=0;
			SUBTRACT=0;
			UNSIGNED_A=0;
			UNSIGNED_B=0;
			if(INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "TRUE")
				repeat(2)@(posedge CLK);
			else if ((INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "FALSE") || (INPUT_REG_EN == "FALSE" && OUTPUT_REG_EN == "TRUE"))
				@(posedge CLK);
			
			#1;
			if(Z1===9 && Z2===9)
				$display("SIGNED Test Passed");
			else
				$display("SIGNED Test Failed \n Z1 = %0d \t Z2= %0d",Z1,Z2);
			
			// COEFFICIENTS MULTIPLICATION
			@(negedge CLK);
			A1 = 3;
			B1 = 3;
			A2 = 3;
			B2 = 3;
			FEEDBACK=4;
			UNSIGNED_A=1;
			UNSIGNED_B=1;

			if(INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "TRUE")
				repeat(2)@(posedge CLK);
			else if ((INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "FALSE") || (INPUT_REG_EN == "FALSE" && OUTPUT_REG_EN == "TRUE"))
				@(posedge CLK);
			
			#1;
			if(Z1===COEFF1_0*B1 && Z2===COEFF2_0*B2)
				$display("COEFF0 Test Passed");
			else
				$display("COEFF0 Test Failed \n Z1 = %0d \t Z2= %0d",Z1,Z2);
			
			@(negedge CLK);
			FEEDBACK=5;
			
			if(INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "TRUE")
				repeat(2)@(posedge CLK);
			else if ((INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "FALSE") || (INPUT_REG_EN == "FALSE" && OUTPUT_REG_EN == "TRUE"))
				@(posedge CLK);
			
			#1;
			if(Z1===COEFF1_1*B1 && Z2===COEFF2_1*B2)
				$display("COEFF1 Test Passed");
			else
				$display("COEFF1 Test Failed \nZ1 = %0d \t Z2= %0d",Z1,Z2);

			@(negedge CLK);
			FEEDBACK=6;
			
			if(INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "TRUE")
				repeat(2)@(posedge CLK);
			else if ((INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "FALSE") || (INPUT_REG_EN == "FALSE" && OUTPUT_REG_EN == "TRUE"))
				@(posedge CLK);
			
			#1;
			if(Z1===COEFF1_2*B1 && Z2===COEFF2_2*B2)
				$display("COEFF2 Test Passed");
			else
				$display("COEFF2 Test Failed \n Z1 = %0d \t Z2= %0d",Z1,Z2);

			@(negedge CLK);
			FEEDBACK=7;
			
			if(INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "TRUE")
				repeat(2)@(posedge CLK);
			else if ((INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "FALSE") || (INPUT_REG_EN == "FALSE" && OUTPUT_REG_EN == "TRUE"))
				@(posedge CLK);
			
			#1;
			if(Z1===COEFF1_3*B1 && Z2===COEFF2_3*B2) 
				$display("COEFF3 Test Passed");
			else
				$display("COEFF3 Test Failed \n Z1 = %0d \t Z2= %0d",Z1,Z2);
			
			// FEEDBACK 1
			@(negedge CLK);
			A1 = 3;
			B1 = 2;
			A2 = 3;
			B2 = 2;
			ACC_FIR=0;
			FEEDBACK=1;
			LOAD_ACC=1;
			SATURATE=0;
			SHIFT_RIGHT=0;
			ROUND=0;
			SUBTRACT=0;
			UNSIGNED_A=1;
			UNSIGNED_B=1;
			
			if(INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "TRUE")
				repeat(2)@(posedge CLK);
			else if ((INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "FALSE") || (INPUT_REG_EN == "FALSE" && OUTPUT_REG_EN == "TRUE"))
				@(posedge CLK);
			
			#1;
			if(Z1===6 && Z2===6)
				$display("FEEDBACK 1 Test Passed");
			else
				$display("FEEDBACK 1 Test Failed \n Z1 = %0d \t Z2= %0d",Z1,Z2);

		`elsif acc_mode
			// ADDITION
			@(negedge CLK);
			RESET=0;
			A1=3;
			B1=1;
			A2=3;
			B2=1;
			ACC_FIR=0;
			FEEDBACK=0;
			LOAD_ACC=1;
			SATURATE=0;
			SHIFT_RIGHT=0;
			ROUND=0;
			SUBTRACT=0;
			UNSIGNED_A=1;
			UNSIGNED_B=1;

			if(INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "TRUE")
				repeat(2)@(posedge CLK);
			else if ((INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "FALSE") || (INPUT_REG_EN == "FALSE" && OUTPUT_REG_EN == "TRUE"))
				@(posedge CLK);
			
			@(posedge CLK);
			#1;
			if(Z1===3 && Z2===3)
				$display("ACC ADDITION Test Passed");
			else
				$display("ACC ADDITION Test Failed \n Z1 = %0d \t Z2= %0d",Z1,Z2);
			
			@(posedge CLK);
			#1;
			if(Z1===6 && Z2===6)
				$display("ACC ADDITION Test Passed");
			else
				$display("ACC ADDITION Test Failed \n Z1 = %0d \t Z2= %0d",Z1,Z2);
			
			@(posedge CLK);
			#1;
			if(Z1===9 && Z2===9)
				$display("ACC ADDITION Test Passed");
			else
				$display("ACC ADDITION Test Failed \n Z1 = %0d \t Z2= %0d",Z1,Z2);

			// SUBTRACTION
			@(negedge CLK);
			A1=3;
			B1=1;
			A2=3;
			B2=1;
			ACC_FIR=0;
			FEEDBACK=0;
			LOAD_ACC=1;
			SATURATE=0;
			SHIFT_RIGHT=0;
			ROUND=0;
			SUBTRACT=1;
			UNSIGNED_A=1;
			UNSIGNED_B=1;

			if(INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "TRUE")
				repeat(2)@(posedge CLK);
			else if ((INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "FALSE") || (INPUT_REG_EN == "FALSE" && OUTPUT_REG_EN == "TRUE"))
				@(posedge CLK);
			
			@(posedge CLK);
			#1;
			if(Z1===6 && Z2===6)
				$display("ACC SUBTRACTION Test Passed");
			else
				$display("ACC SUBTRACTION Test Failed \n Z1 = %0d \t Z2= %0d",Z1,Z2);
				
			@(posedge CLK);
			#1;
			if(Z1===3 && Z2===3)
				$display("ACC SUBTRACTION Test Passed");
			else
				$display("ACC SUBTRACTION Test Failed \n Z1 = %0d \t Z2= %0d",Z1,Z2);
			
			@(posedge CLK);
			#1;
			if(Z1===0 && Z2===0)
				$display("ACC SUBTRACTION Test Passed");
			else
				$display("ACC SUBTRACTION Test Failed \n Z1 = %0d \t Z2= %0d",Z1,Z2);

			// FEEDBACK 3 -> ACC Mult x B
			// @(negedge CLK);
			// A1=3;
			// B1=1;
			// A2=3;
			// B2=1;
			// ACC_FIR=1;
			// FEEDBACK=3;
			// LOAD_ACC=1;
			// SATURATE=0;
			// SHIFT_RIGHT=0;
			// ROUND=0;
			// SUBTRACT=0;
			// UNSIGNED_A=1;
			// UNSIGNED_B=1;
			// if(INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "TRUE")
				// repeat(2)@(posedge CLK);
			// else if ((INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "FALSE") || (INPUT_REG_EN == "FALSE" && OUTPUT_REG_EN == "TRUE"))
				// @(posedge CLK);
			// 
			// @(posedge CLK);
			// #1;
			// if(Z1===6 && Z2===6)
				// $display("ACC MULT Test Passed");
			// else
				// $display("ACC MULT Test Failed \n Z1 = %0d \t Z2= %0d",Z1,Z2);
			// @(posedge CLK);
			// #1;
			// if(Z1===12 && Z2===12)
				// $display("ACC MULT Test Passed");
			// else
				// $display("ACC MULT Test Failed \n Z1 = %0d \t Z2= %0d",Z1,Z2);
				// 
			// @(posedge CLK);
			// #1;
			// if(Z1===18 && Z2===18)
				// $display("ACC MULT Test Passed");
			// else
				// $display("ACC MULT Test Failed \n Z1 = %0d \t Z2= %0d",Z1,Z2);

			// UNSIGNED SATURATION OVERFLOW
			@(negedge CLK);
			A1=10'h3ff;
			B1=9'h1ff;
			A2=10'h3ff;
			B2=9'h1ff;
			ACC_FIR=0;
			FEEDBACK=0;
			LOAD_ACC=1;
			SATURATE=1;
			SHIFT_RIGHT=0;
			ROUND=0;
			SUBTRACT=0;
			UNSIGNED_A=1;
			UNSIGNED_B=1;

			if(INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "TRUE")
				repeat(2)@(posedge CLK);
			else if ((INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "FALSE") || (INPUT_REG_EN == "FALSE" && OUTPUT_REG_EN == "TRUE"))
				@(posedge CLK);
			
			repeat(2)@(posedge CLK);
			#1;
			if(Z1===19'h7ffff && Z2===19'h7ffff)
				$display("U_SATURATION OVERFLOW Test Passed");
			else
				$display("U_SATURATION OVERFLOW Test Failed \n Z1 = %0d \t Z2= %0d",Z1,Z2);
			
				
			// UNSIGNED SATURATION UNDERFLOW
			@(negedge CLK);
			A1=3;
			B1=1;
			A2=4;
			B2=2;
			ACC_FIR=0;
			FEEDBACK=1;
			LOAD_ACC=1;
			SATURATE=1;
			SHIFT_RIGHT=0;
			ROUND=0;
			SUBTRACT=1;
			UNSIGNED_A=1;
			UNSIGNED_B=1;

			if(INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "TRUE")
				repeat(2)@(posedge CLK);
			else if ((INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "FALSE") || (INPUT_REG_EN == "FALSE" && OUTPUT_REG_EN == "TRUE"))
				@(posedge CLK);
			
			@(posedge CLK);
			#1;
			if(Z1===0 && Z2===0)
				$display("U_SATURATION UNDERFLOW Test Passed");
			else
				$display("U_SATURATION UNDERFLOW Test Failed \n Z1 = %0d \t Z2= %0d",Z1,Z2);
	
			// SIGNED SATURATION OVERFLOW
			@(negedge CLK);
			A1=10'h1ff;
			B1=9'hff;
			A2=10'h1ff;
			B2=9'hff;
			ACC_FIR=0;
			FEEDBACK=0;
			LOAD_ACC=1;
			SATURATE=1;
			SHIFT_RIGHT=0;
			ROUND=0;
			SUBTRACT=0;
			UNSIGNED_A=0;
			UNSIGNED_B=0;

			if(INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "TRUE")
				repeat(2)@(posedge CLK);
			else if ((INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "FALSE") || (INPUT_REG_EN == "FALSE" && OUTPUT_REG_EN == "TRUE"))
				@(posedge CLK);
			
			repeat(3)@(posedge CLK);
			#1;
			if(Z1===19'h3ffff && Z2===19'h3ffff)
				$display("S_SATURATION OVERFLOW Test Passed");
			else
				$display("S_SATURATION OVERFLOW Test Failed \n Z1 = %0d \t Z2= %0d",Z1,Z2);

			// SIGNED SATURATION UNDERFLOW
			@(negedge CLK);
			A1=10'h3ff;
			B1=18'h100;
			A2=10'h3ff;
			B2=18'h100;
			ACC_FIR=0;
			FEEDBACK=0;
			LOAD_ACC=1;
			SATURATE=1;
			SHIFT_RIGHT=0;
			ROUND=0;
			SUBTRACT=0;
			UNSIGNED_A=1;
			UNSIGNED_B=0;

			if(INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "TRUE")
				repeat(2)@(posedge CLK);
			else if ((INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "FALSE") || (INPUT_REG_EN == "FALSE" && OUTPUT_REG_EN == "TRUE"))
				@(posedge CLK);
			
			repeat(3)@(posedge CLK);
			#1;
			if(Z1===19'h40000 && Z2===19'h40000)
				$display("S_SATURATION UNDERFLOW Test Passed");
			else
				$display("S_SATURATION UNDERFLOW Test Failed \n Z1 = %0d \t Z2= %0d",Z1,Z2);
		
				
		`elsif acc_bypass_mode
			@(negedge CLK);
			RESET=0;
			A1=-1;
			B1=2;
			A2=-1;
			B2=2;
			ACC_FIR=2;
			FEEDBACK=2;
			LOAD_ACC=0;
			SATURATE=0;
			SHIFT_RIGHT=0;
			ROUND=0;
			SUBTRACT=0;
			UNSIGNED_A=0;
			UNSIGNED_B=1;

			if(INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "TRUE")
				repeat(2)@(posedge CLK);
			else if ((INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "FALSE") || (INPUT_REG_EN == "FALSE" && OUTPUT_REG_EN == "TRUE"))
				@(posedge CLK);

			#1;
			if($signed(Z1)===-4 && $signed(Z2)===-4)
				$display("ACC BYPASS Test Passed");
			else
				$display("ACC BYPASS Test Failed \n Z1 = %0d \t Z2= %0d",Z1,Z2);

			// SHIFT AND ROUND
			@(negedge CLK);
			A1=3;
			B1=1;
			A2=3;
			B2=1;
			ACC_FIR=0;
			FEEDBACK=0;
			LOAD_ACC=0;
			SATURATE=1;
			SHIFT_RIGHT=1;
			ROUND=1;
			SUBTRACT=0;
			UNSIGNED_A=1;
			UNSIGNED_B=1;

			if(INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "TRUE")
				repeat(2)@(posedge CLK);
			else if ((INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "FALSE") || (INPUT_REG_EN == "FALSE" && OUTPUT_REG_EN == "TRUE"))
				@(posedge CLK);

			#1;
			if(Z1===2 && Z2===2)
				$display("SHIFT ROUND Test Passed");
			else
				$display("SHIFT ROUND Test Failed \n Z1 = %0d \t Z2= %0d",Z1,Z2);

		`endif
		#40
	    $finish;

	
	end
	initial 
	begin
	    $dumpfile("waves.vcd");
	    $dumpvars;
	end
endmodule