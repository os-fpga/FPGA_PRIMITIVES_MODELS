`timescale 1ns/1ps
module DSP38_tb;

	`ifdef in_out_reg_mult
		// Parameters
		`define mult_mode
		localparam  DSP_MODE = "MULTIPLY";
		localparam [19:0] COEFF_0 = 0;
		localparam [19:0] COEFF_1 = 0;
		localparam [19:0] COEFF_2 = 0;
		localparam [19:0] COEFF_3 = 0;
		localparam  OUTPUT_REG_EN = "TRUE";
		localparam  INPUT_REG_EN = "TRUE";
	`elsif in_reg_mult
		`define mult_mode
		localparam  DSP_MODE = "MULTIPLY";
		localparam [19:0] COEFF_0 = 0;
		localparam [19:0] COEFF_1 = 0;
		localparam [19:0] COEFF_2 = 0;
		localparam [19:0] COEFF_3 = 0;
		localparam  OUTPUT_REG_EN = "FALSE";
		localparam  INPUT_REG_EN = "TRUE";
	`elsif out_reg_mult
		`define mult_mode
		localparam  DSP_MODE = "MULTIPLY";
		localparam [19:0] COEFF_0 = 0;
		localparam [19:0] COEFF_1 = 0;
		localparam [19:0] COEFF_2 = 0;
		localparam [19:0] COEFF_3 = 0;
		localparam  OUTPUT_REG_EN = "TRUE";
		localparam  INPUT_REG_EN = "FALSE";
	`elsif comb_mult
		`define mult_mode
		localparam  DSP_MODE = "MULTIPLY";
		localparam [19:0] COEFF_0 = 0;
		localparam [19:0] COEFF_1 = 0;
		localparam [19:0] COEFF_2 = 0;
		localparam [19:0] COEFF_3 = 0;
		localparam  OUTPUT_REG_EN = "FALSE";
		localparam  INPUT_REG_EN = "FALSE";
	`elsif coeff_mult
		`define mult_mode
		localparam  DSP_MODE = "MULTIPLY";
		localparam [19:0] COEFF_0 = 2;
		localparam [19:0] COEFF_1 = 3;
		localparam [19:0] COEFF_2 = 4;
		localparam [19:0] COEFF_3 = 5;
		localparam  OUTPUT_REG_EN = "FALSE";
		localparam  INPUT_REG_EN = "TRUE";
	`elsif acc_mode
		localparam  DSP_MODE = "MULTIPLY_ACCUMULATE";
		localparam [19:0] COEFF_0 = 0;
		localparam [19:0] COEFF_1 = 0;
		localparam [19:0] COEFF_2 = 0;
		localparam [19:0] COEFF_3 = 0;
		localparam  OUTPUT_REG_EN = "FALSE";
		localparam  INPUT_REG_EN = "FALSE";
	`elsif acc_bypass_mode
		localparam  DSP_MODE = "MULTIPLY_ADD_SUB";
		localparam [19:0] COEFF_0 = 0;
		localparam [19:0] COEFF_1 = 0;
		localparam [19:0] COEFF_2 = 0;
		localparam [19:0] COEFF_3 = 0;
		localparam  OUTPUT_REG_EN = "FALSE";
		localparam  INPUT_REG_EN = "TRUE";
	`endif
	//Ports
	reg [19:0] A;
	reg [17:0] B;
	reg [5:0] ACC_FIR;
	wire [37:0] Z;
	wire reg [17:0] DLY_B;
	reg  CLK;
	reg  RESET;
	reg [2:0] FEEDBACK;
	reg  LOAD_ACC;
	reg  SATURATE;
	reg [5:0] SHIFT_RIGHT;
	reg  ROUND;
	reg  SUBTRACT;
	reg  UNSIGNED_A;
	reg  UNSIGNED_B;

	DSP38 # (
		.DSP_MODE(DSP_MODE),
		.COEFF_0(COEFF_0),
		.COEFF_1(COEFF_1),
		.COEFF_2(COEFF_2),
		.COEFF_3(COEFF_3),
		.OUTPUT_REG_EN(OUTPUT_REG_EN),
		.INPUT_REG_EN(INPUT_REG_EN)
	)
	DSP38_inst (
		.A(A),
		.B(B),
		.ACC_FIR(ACC_FIR),
		.Z(Z),
		.DLY_B(DLY_B),
		.CLK(CLK),
		.RESET(RESET),
		.FEEDBACK(FEEDBACK),
		.LOAD_ACC(LOAD_ACC),
		.SATURATE(SATURATE),
		.SHIFT_RIGHT(SHIFT_RIGHT),
		.ROUND(ROUND),
		.SUBTRACT(SUBTRACT),
		.UNSIGNED_A(UNSIGNED_A),
		.UNSIGNED_B(UNSIGNED_B)
	);	

	always #5  CLK = ! CLK ;

	initial 
	begin
		// INITIALIZATION
		CLK=1;
	    RESET=1;
		A=0;
	    B=0;
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
	    	A = 3;
	    	B = 2;
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
			if(Z===6)
				$display("UNSIGNED TEST PASSED");
			else
				$display("UNSIGNED TEST FAILED \n Z = %0d",Z);
			
			// SIGNED UNSIGNED MULTIPLICATION
			@(negedge CLK);
			A = -3;
			B =  2;
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
			if(Z===-6)
				$display("SIGNED UNSIGNED TEST PASSED");
			else
				$display("SIGNED UNSIGNED TEST FAILED \n Z = %0d",Z);

			// UNSIGNED SIGNED MULTIPLICATION
			@(negedge CLK);
			A = 3;
			B = -3;
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
			if(Z===-9)
				$display("UNSIGNED SIGNED TEST PASSED");
			else
				$display("UNSIGNED SIGNED TEST FAILED \n Z = %0d",Z);

			// SIGNED MULTIPLICATION
			@(negedge CLK);
			A = -3;
			B = -3;
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
			if(Z===9)
				$display("SIGNED TEST PASSED");
			else
				$display("SIGNED TEST FAILED \n Z = %0d",Z);
			
			// COEFFICIENTS MULTIPLICATION
			@(negedge CLK);
			A = 3;
			B = 3;
			FEEDBACK=4;
			UNSIGNED_A=1;
			UNSIGNED_B=1;

			if(INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "TRUE")
				repeat(2)@(posedge CLK);
			else if ((INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "FALSE") || (INPUT_REG_EN == "FALSE" && OUTPUT_REG_EN == "TRUE"))
				@(posedge CLK);
			
			#1;
			if(Z===COEFF_0*B)
				$display("COEFF0 TEST PASSED");
			else
				$display("COEFF0 TEST FAILED \n Z = %0d",Z);
			
			@(negedge CLK);
			FEEDBACK=5;
			
			if(INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "TRUE")
				repeat(2)@(posedge CLK);
			else if ((INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "FALSE") || (INPUT_REG_EN == "FALSE" && OUTPUT_REG_EN == "TRUE"))
				@(posedge CLK);
			
			#1;
			if(Z===COEFF_1*B)
				$display("COEFF1 TEST PASSED");
			else
				$display("COEFF1 TEST FAILED \n Z = %0d",Z);

			@(negedge CLK);
			FEEDBACK=6;
			
			if(INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "TRUE")
				repeat(2)@(posedge CLK);
			else if ((INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "FALSE") || (INPUT_REG_EN == "FALSE" && OUTPUT_REG_EN == "TRUE"))
				@(posedge CLK);
			
			#1;
			if(Z===COEFF_2*B)
				$display("COEFF2 TEST PASSED");
			else
				$display("COEFF2 TEST FAILED \n Z = %0d",Z);

			@(negedge CLK);
			FEEDBACK=7;
			
			if(INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "TRUE")
				repeat(2)@(posedge CLK);
			else if ((INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "FALSE") || (INPUT_REG_EN == "FALSE" && OUTPUT_REG_EN == "TRUE"))
				@(posedge CLK);
			
			#1;
			if(Z===COEFF_3*B)
				$display("COEFF3 TEST PASSED");
			else
				$display("COEFF3 TEST FAILED \n Z = %0d",Z);
			
			// FEEDBACK 1
			@(negedge CLK);
			A = 3;
			B = 2;
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
			if(Z===6)
				$display("FEEDBACK 1 TEST PASSED");
			else
				$display("FEEDBACK 1 TEST FAILED \n Z = %0d",Z);

		`elsif acc_mode
			// ADDITION
			@(negedge CLK);
			RESET=0;
			A=3;
			B=1;
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
			if(Z===3)
				$display("ACC ADDITION TEST PASSED");
			else
				$display("ACC ADDITION TEST FAILED \n Z = %0d",Z);
			
			@(posedge CLK);
			#1;
			if(Z===6)
				$display("ACC ADDITION TEST PASSED");
			else
				$display("ACC ADDITION TEST FAILED \n Z = %0d",Z);
			// RESET IN MIDDLE
			@(negedge CLK);
			RESET=1;

			if(INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "TRUE")
				repeat(2)@(posedge CLK);
			else if ((INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "FALSE") || (INPUT_REG_EN == "FALSE" && OUTPUT_REG_EN == "TRUE"))
				@(posedge CLK);

			@(posedge CLK);
			#1;
			if(Z===0 && DLY_B===0)
				$display("RESET IN MIDDLE TEST PASSED");
			else
				$display("RESET IN MIDDLE TEST FAILED \n Z = %0d",Z);
			
			@(negedge CLK);
			RESET=0;	

			if(INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "TRUE")
				repeat(2)@(posedge CLK);
			else if ((INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "FALSE") || (INPUT_REG_EN == "FALSE" && OUTPUT_REG_EN == "TRUE"))
				@(posedge CLK);
			
			@(posedge CLK);
			#1;
			if(Z===3)
				$display("ACC ADDITION TEST PASSED");
			else
				$display("ACC ADDITION TEST FAILED \n Z = %0d",Z);
			
			@(posedge CLK);
			#1;
			if(Z===6)
				$display("ACC ADDITION TEST PASSED");
			else
				$display("ACC ADDITION TEST FAILED \n Z = %0d",Z);
				
			@(posedge CLK);
			#1;
			if(Z===9)
				$display("ACC ADDITION TEST PASSED");
			else
				$display("ACC ADDITION TEST FAILED \n Z = %0d",Z);

			// SUBTRACTION
			@(negedge CLK);
			A=3;
			B=1;
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
			if(Z===6)
				$display("ACC SUBTRACTION TEST PASSED");
			else
				$display("ACC SUBTRACTION TEST FAILED \n Z = %0d",Z);
				
			@(posedge CLK);
			#1;
			if(Z===3)
				$display("ACC SUBTRACTION TEST PASSED");
			else
				$display("ACC SUBTRACTION TEST FAILED \n Z = %0d",Z);
			
			@(posedge CLK);
			#1;
			if(Z===0)
				$display("ACC SUBTRACTION TEST PASSED");
			else
				$display("ACC SUBTRACTION TEST FAILED \n Z = %0d",Z);

			// FEEDBACK 3 -> ACC Mult x B
			// @(negedge CLK);
			// A=3;
			// B=1;
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
			// 	repeat(2)@(posedge CLK);
			// else if ((INPUT_REG_EN == "TRUE" && OUTPUT_REG_EN == "FALSE") || (INPUT_REG_EN == "FALSE" && OUTPUT_REG_EN == "TRUE"))
			// 	@(posedge CLK);
			
			// @(posedge CLK);
			// #1;
			// if(Z===6)
			// 	$display("ACC MULT TEST PASSED");
			// else
			// 	$display("ACC MULT TEST FAILED \n Z = %0d",Z);

			// @(posedge CLK);
			// #1;
			// if(Z===12)
			// 	$display("ACC MULT TEST PASSED");
			// else
			// 	$display("ACC MULT TEST FAILED \n Z = %0d",Z);
				
			// @(posedge CLK);
			// #1;
			// if(Z===18)
			// 	$display("ACC MULT TEST PASSED");
			// else
			// 	$display("ACC MULT TEST FAILED \n Z = %0d",Z);

			// UNSIGNED SATURATION OVERFLOW
			@(negedge CLK);
			A=20'hfffff;
			B=18'h3ffff;
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
			if(Z===38'h3fffffffff)
				$display("U_SATURATION OVERFLOW TEST PASSED");
			else
				$display("U_SATURATION OVERFLOW TEST FAILED \n Z = %0d",Z);
			
				
			// UNSIGNED SATURATION UNDERFLOW
			@(negedge CLK);
			A=3;
			B=1;
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
			if(Z===0)
				$display("U_SATURATION UNDERFLOW TEST PASSED");
			else
				$display("U_SATURATION UNDERFLOW TEST FAILED \n Z = %0d",Z);
	
			// SIGNED SATURATION OVERFLOW
			@(negedge CLK);
			A=20'h7ffff;
			B=18'h1ffff;
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
			if(Z===38'h1fffffffff)
				$display("S_SATURATION OVERFLOW TEST PASSED");
			else
				$display("S_SATURATION OVERFLOW TEST FAILED \n Z = %0d",Z);

			// SIGNED SATURATION UNDERFLOW
			@(negedge CLK);
			A=20'hfffff;
			B=18'h20000;
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
			if(Z===38'h2000000000)
				$display("S_SATURATION UNDERFLOW TEST PASSED");
			else
				$display("S_SATURATION UNDERFLOW TEST FAILED \n Z = %0d",Z);
		
				
		`elsif acc_bypass_mode
			@(negedge CLK);
			RESET=0;
			A=-1;
			B=2;
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
			if(Z===-4)
				$display("ACC BYPASS TEST PASSED");
			else
				$display("ACC BYPASS TEST FAILED \n Z = %0d",$signed(Z));

			// SHIFT AND ROUND
			@(negedge CLK);
			A=3;
			B=1;
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
			if(Z===2)
				$display("SHIFT ROUND TEST PASSED");
			else
				$display("SHIFT ROUND TEST FAILED \n Z = %0d",$signed(Z));

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