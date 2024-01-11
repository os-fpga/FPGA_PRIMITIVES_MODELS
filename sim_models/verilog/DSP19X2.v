`timescale 1ns/1ps
`celldefine
//
// DSP19X2 simulation model
// Paramatizable dual 10x9-bit multiplier accumulator
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module DSP19X2 #(
  parameter DSP_MODE = "MULTIPLY_ACCUMULATE", // DSP arithmetic mode (MULTIPLY/MULTIPLY_ACCUMULATE)
  parameter [9:0] COEFF1_0 = 10'h000, // Multiplier 1 10-bit A input coefficient 0
  parameter [9:0] COEFF1_1 = 10'h000, // Multiplier 1 10-bit A input coefficient 1
  parameter [9:0] COEFF1_2 = 10'h000, // Multiplier 1 10-bit A input coefficient 2
  parameter [9:0] COEFF1_3 = 10'h000, // Multiplier 1 10-bit A input coefficient 3
  parameter [9:0] COEFF2_0 = 10'h000, // Multiplier 2 10-bit A input coefficient 0
  parameter [9:0] COEFF2_1 = 10'h000, // Multiplier 2 10-bit A input coefficient 1
  parameter [9:0] COEFF2_2 = 10'h000, // Multiplier 2 10-bit A input coefficient 2
  parameter [9:0] COEFF2_3 = 10'h000, // Multiplier 2 10-bit A input coefficient 3
  parameter OUTPUT_REG_EN = "TRUE", // Enable output register (TRUE/FALSE)
  parameter INPUT_REG_EN = "TRUE" // Enable input register (TRUE/FALSE)
) (
  input [9:0] A1, // Multiplier 1 10-bit data input for multiplier or accumulator loading
  input [8:0] B1, // 9-bit data input for multiplication
  output [18:0] Z1, // Multiplier 1 19-bit data output
  output [8:0] DLY_B1, // Multiplier 1 9-bit B registered output
  input [9:0] A2, // Multiplier 2 10-bit data input for multiplier or accumulator loading
  input [8:0] B2, // Multiplier 2 9-bit data input for multiplication
  output [18:0] Z2, // Multiplier 2 19-bit data output
  output [8:0] DLY_B2, // Multiplier 2 9-bit B registered output
  input CLK, // Clock
  input RESET, // Reset input
  input [4:0] ACC_FIR, // 5-bit left shift A input
  input [2:0] FEEDBACK, // 3-bit feedback input selects coefficient
  input LOAD_ACC, // Load accumulator input
  input UNSIGNED_A, // Selects signed or unsigned data for A input
  input UNSIGNED_B, // Selects signed or unsigned data for B input
  input SATURATE, // Saturate enable
  input [4:0] SHIFT_RIGHT, // 5-bit Shift right
  input ROUND, // Round
  input SUBTRACT // Add or subtract
);


	// registers
	reg 	   		  subtract_reg		= 1'b0;
	reg 	   [4:0]  acc_fir_reg		= 5'h00;
	reg 	   [2:0]  feedback_reg		= 3'h0;
	reg 	   [4:0]  shift_right_reg1	= 5'h00;
	reg 	   [4:0]  shift_right_reg2	= 5'h00;
	reg 	   		  round_reg1		= 1'b0;
	reg 	   		  round_reg2		= 1'b0;
	reg 	   		  saturate_reg1		= 1'b0;
	reg 	   		  saturate_reg2		= 1'b0;
	reg 	   		  load_acc_reg		= 1'b0;
	reg 	   [9:0]  a1_reg			= 10'h000;
	reg 	   [9:0]  a2_reg			= 10'h000;
	reg 	   [8:0]  b1_reg			= 9'h000;
	reg 	   [8:0]  b2_reg			= 9'h000;
	reg 	   		  unsigned_a_reg	= 1'b1;
	reg 	   		  unsigned_b_reg	= 1'b1;
//////////////////////////////////////////////////////////////
	reg				  subtract_int		= 1'b0;
	reg		   [4:0]  acc_fir_int		= 5'h00;
	reg		   [2:0]  feedback_int		= 3'h0;
	reg		   [4:0]  shift_right_int	= 5'h00;
	reg 			  round_int			= 1'b0;
	reg 			  saturate_int		= 1'b0;
	reg 			  load_acc_int		= 1'b0;
	reg		   [9:0]  a1_int			= 10'h000;
	reg		   [9:0]  a2_int			= 10'h000;
	reg		   [8:0]  b1_int			=  9'h000;
	reg		   [8:0]  b2_int			=  9'h000;
	reg				  unsigned_a_int	= 1'b1;
	reg				  unsigned_b_int	= 1'b1;
	reg signed [63:0] accumulator		= 64'h0000000000000000;
	reg signed [63:0] add_sub_in		= 64'h0000000000000000;
	reg signed [63:0] mult_out			= 64'h0000000000000000;
	reg signed [31:0] mult_out1			= 32'h00000000;
	reg signed [31:0] mult_out2			= 32'h00000000;
	reg signed [63:0] add_sub_out		= 64'h0000000000000000;
	reg signed [63:0] pre_shift			= 64'h0000000000000000;
	reg signed [31:0] shift_right_f0	= 32'h00000000;
	reg signed [31:0] shift_right_f1	= 32'h00000000;
	reg signed [31:0] round_f0			= 32'h00000000;
	reg signed [31:0] round_f1			= 32'h00000000;
	reg signed [18:0] saturate_f0 		= 19'h00000;
	reg signed [18:0] saturate_f1 		= 19'h00000;
	reg 	   [37:0] z_out				= 38'h0000000000;
	reg		   [37:0] z_out_reg			= 38'h0000000000;
	reg		   [8:0]  dly_b1			= 9'h000;
	reg		   [8:0]  dly_b2			= 9'h000;



	reg [9:0] mult_a1 = 10'h000;
	reg [9:0] mult_a2 = 10'h000;
	reg [8:0] mult_b1 = 9'h000;
	reg [8:0] mult_b2 = 9'h000;

	// pipelining
	always @(posedge CLK or posedge RESET)
	begin
		if (RESET) 
		begin
			subtract_reg		<= 1'b0;
			acc_fir_reg			<= 6'h00;
			feedback_reg		<= 1'b0;
			shift_right_reg1	<= 6'h00;
			shift_right_reg2	<= 6'h00;
			round_reg1			<= 1'b0;
			round_reg2			<= 1'b0;
			saturate_reg1		<= 1'b0;
			saturate_reg2		<= 1'b0;
			load_acc_reg		<= 1'b0;
			a1_reg				<= 10'h000;
			a2_reg				<= 10'h000;
			b1_reg				<= 9'h000;
			b2_reg				<= 9'h000;
			unsigned_a_reg		<= 1'b1;
			unsigned_b_reg		<= 1'b1;
		end
		else 
		begin
			subtract_reg		<= SUBTRACT;
			acc_fir_reg			<= ACC_FIR;
			feedback_reg		<= FEEDBACK;
			shift_right_reg1	<= SHIFT_RIGHT;
			shift_right_reg2	<= shift_right_reg1;
			round_reg1			<= ROUND;
			round_reg2			<= round_reg1;
			saturate_reg1		<= SATURATE;
			saturate_reg2		<= saturate_reg1;
			load_acc_reg		<= LOAD_ACC;
			a1_reg				<= A1;
			a2_reg				<= A2;
			b1_reg				<= B1;
			b2_reg				<= B2;
			unsigned_a_reg		<= UNSIGNED_A;
			unsigned_b_reg		<= UNSIGNED_B;


		end
	end

	always @(*) 
	begin
		if (INPUT_REG_EN == "TRUE")  
		begin
			a1_int			= a1_reg;
			a2_int			= a2_reg;
    	    b1_int			= b1_reg;
    	    b2_int			= b2_reg;
			subtract_int	= subtract_reg;
			acc_fir_int		= acc_fir_reg;
			feedback_int	= feedback_reg;
			load_acc_int	= load_acc_reg;
			unsigned_a_int	= unsigned_a_reg;
			unsigned_b_int	= unsigned_b_reg;
			shift_right_int = (DSP_MODE== "MULTIPLY_ACCUMULATE")?shift_right_reg2:shift_right_reg1;
			round_int		= (DSP_MODE== "MULTIPLY_ACCUMULATE")?round_reg2:round_reg1;
			saturate_int	= (DSP_MODE== "MULTIPLY_ACCUMULATE")?saturate_reg2:saturate_reg1;
		end 
		else 
		begin
			a1_int 			= A1;
			a2_int 			= A2;
    	    b1_int 			= B1;
    	    b2_int 			= B2;
			subtract_int	= SUBTRACT;
			acc_fir_int		= ACC_FIR;
			feedback_int	= FEEDBACK;
			load_acc_int	= LOAD_ACC;
			unsigned_a_int	= UNSIGNED_A;
			unsigned_b_int	= UNSIGNED_B;
			shift_right_int = (DSP_MODE== "MULTIPLY_ACCUMULATE")?shift_right_reg1:SHIFT_RIGHT;
			round_int		= (DSP_MODE== "MULTIPLY_ACCUMULATE")?round_reg1:ROUND;
			saturate_int	= (DSP_MODE== "MULTIPLY_ACCUMULATE")?saturate_reg1:SATURATE;

    	end
	end

	//  Feedback paths
	always @(*)
	begin
    	case (feedback_int)
      		3'b000:	begin
        				mult_a1		= a1_int;
        				mult_b1		= b1_int;
						mult_a2		= a2_int;
        				mult_b2		= b2_int;
        				add_sub_in	= accumulator;
					end
      		3'b001:	begin
						mult_a1		= a1_int;
						mult_b1		= b1_int;
						mult_a2		= a2_int;
						mult_b2		= b2_int;
        				add_sub_in	= 64'h0000000000000000;
     				end
      		3'b010:	begin
						mult_a1		= a1_int;
						mult_b1		= 9'h000;
						mult_a2		= a2_int;
						mult_b2		= 9'h000;
        				add_sub_in	= (unsigned_a_int)?{({{22{1'b0}},a2_int}<<acc_fir_int),({{22{1'b0}},a1_int}<<acc_fir_int)}: 
											{({{22{a2_int[9]}},a2_int}<<acc_fir_int),({{22{a1_int[9]}},a1_int}<<acc_fir_int)};
      				end
			3'b011:	begin
        				mult_a1		= accumulator[9:0];
        				mult_b1		= b1_int;
						mult_a2		= accumulator[41:32];
        				mult_b2		= b2_int;
        				add_sub_in	= (unsigned_a_int)?{({{22{1'b0}},a2_int}<<acc_fir_int),({{22{1'b0}},a1_int}<<acc_fir_int)}: 
											{({{22{a2_int[9]}},a2_int}<<acc_fir_int),({{22{a1_int[9]}},a1_int}<<acc_fir_int)};
					end
      		3'b100:	begin
        				mult_a1		= COEFF1_0;
        				mult_b1		= b1_int;
						mult_a2		= COEFF2_0;
        				mult_b2		= b2_int;
        				add_sub_in	= (unsigned_a_int)?{({{22{1'b0}},a2_int}<<acc_fir_int),({{22{1'b0}},a1_int}<<acc_fir_int)}: 
											{({{22{a2_int[9]}},a2_int}<<acc_fir_int),({{22{a1_int[9]}},a1_int}<<acc_fir_int)};
      				end
      		3'b101:	begin 
						mult_a1		= COEFF1_1;
						mult_b1		= b1_int;
						mult_a2		= COEFF2_1;
						mult_b2		= b2_int;
        				add_sub_in	= (unsigned_a_int)?{({{22{1'b0}},a2_int}<<acc_fir_int),({{22{1'b0}},a1_int}<<acc_fir_int)}: 
											{({{22{a2_int[9]}},a2_int}<<acc_fir_int),({{22{a1_int[9]}},a1_int}<<acc_fir_int)};
					end
			3'b110:	begin 
						mult_a1		= COEFF1_2;
						mult_b1		= b1_int;
						mult_a2		= COEFF2_2;
						mult_b2		= b2_int;
						add_sub_in	= (unsigned_a_int)?{({{22{1'b0}},a2_int}<<acc_fir_int),({{22{1'b0}},a1_int}<<acc_fir_int)}: 
											{({{22{a2_int[9]}},a2_int}<<acc_fir_int),({{22{a1_int[9]}},a1_int}<<acc_fir_int)};
					end
			3'b111:	begin
						mult_a1		= COEFF1_3;
						mult_b1		= b1_int;
						mult_a2		= COEFF2_3;
						mult_b2		= b2_int;
        				add_sub_in	= (unsigned_a_int)?{({{22{1'b0}},a2_int}<<acc_fir_int),({{22{1'b0}},a1_int}<<acc_fir_int)}: 
											{({{22{a2_int[9]}},a2_int}<<acc_fir_int),({{22{a1_int[9]}},a1_int}<<acc_fir_int)};
					end
    	endcase
	end
	
	// Multiplier
	always@(*)
	begin
		case({unsigned_a_int,unsigned_b_int})
			2'b00: 
			begin
				mult_out1 = $signed(mult_a1) * $signed(mult_b1);
				mult_out2 = $signed(mult_a2) * $signed(mult_b2);
				mult_out  = {mult_out2,mult_out1};
			end
			2'b01:
			begin
				mult_out1 = $signed(mult_a1) * $signed({{1'b0},mult_b1});
				mult_out2 = $signed(mult_a2) * $signed({{1'b0},mult_b2});
				mult_out  = {mult_out2,mult_out1};
			end
			2'b10:
			begin
				mult_out1 = $signed({{1'b0},mult_a1}) * $signed(mult_b1);
				mult_out2 = $signed({{1'b0},mult_a2}) * $signed(mult_b2);
				mult_out  = {mult_out2,mult_out1};
			end
			2'b11:
			begin
				mult_out1 = mult_a1 * mult_b1;
				mult_out2 = mult_a2 * mult_b2;
				mult_out  = {mult_out2,mult_out1};
			end
		endcase
	end	

	// Adder/Subtractor
	always@(*)
	begin
		if(subtract_int)
			add_sub_out = {($signed(add_sub_in[63:32]) - $signed(mult_out[63:32])),($signed(add_sub_in[31:0]) - $signed(mult_out[31:0]))};
		else
			add_sub_out = {(add_sub_in[63:32]+ mult_out[63:32]),(add_sub_in[31:0] + mult_out[31:0])};
	end

	// Accumulator
	always @(posedge CLK or posedge RESET)
	begin
		if(RESET)
			accumulator <= 64'h0000000000000000;
	    else if(load_acc_int)
			accumulator <= add_sub_out;
		else
			accumulator <= accumulator;
	end
  
	// Shift Round Saturate
	always@(*)
	begin
		pre_shift      = (DSP_MODE == "MULTIPLY_ACCUMULATE")? accumulator : add_sub_out;
		shift_right_f0 = pre_shift[31:0] >>> shift_right_int;
		shift_right_f1 = pre_shift[63:32] >>> shift_right_int;
		round_f0       = (round_int && shift_right_int>0)? (pre_shift[shift_right_int-1]==1)?shift_right_f0+1:shift_right_f0:shift_right_f0; 
		round_f1       = (round_int && shift_right_int>0)? (pre_shift[(shift_right_int+32)-1]==1)?shift_right_f1+1:shift_right_f1:shift_right_f1; 
	
		if(saturate_int)
		begin
			if(unsigned_a_int && unsigned_b_int)
			begin
				if($signed(round_f0)<0)
					saturate_f0 = 19'h00000;
				else if($signed(round_f0)>19'h7ffff)
					saturate_f0 = 19'h7ffff;
				else
					saturate_f0 = round_f0;

				if($signed(round_f1)<0)
					saturate_f1 = 19'h00000;
				else if($signed(round_f1)>19'h7ffff)
					saturate_f1 = 19'h7ffff;
				else
					saturate_f1 = round_f1;
			end
			else 
			begin
				if($signed(round_f0)>$signed(19'h3ffff))
                    saturate_f0 = 19'h3ffff;
                else if($signed(round_f0)<$signed(19'h40000))
                    saturate_f0 = 19'h40000;
				else
					saturate_f0 = round_f0;

				if($signed(round_f1)>$signed(19'h3ffff))
                    saturate_f1 = 19'h3ffff;
                else if($signed(round_f1)<$signed(19'h40000))
                    saturate_f1 = 19'h40000;
				else
					saturate_f1 = round_f1;
			end
			
		end
		else 
		begin
			saturate_f0 = round_f0;
			saturate_f1 = round_f1;
		end
			z_out = (DSP_MODE== "MULTIPLY")? {mult_out[50:32],mult_out[18:0]}:{saturate_f1,saturate_f0};
	end

 
	// output register
	always @(posedge CLK or posedge RESET)
	begin
		if(RESET)
		begin
			dly_b1 <= 9'h000;
			dly_b2 <= 9'h000;
			z_out_reg <= 38'h0000000000;	
		end
		else 
		begin
			dly_b1 <= B1;
			dly_b2 <= B2;
			z_out_reg <= z_out;
		end
	end

	assign Z1 = (OUTPUT_REG_EN == "TRUE")?z_out_reg[18:0]:z_out[18:0];
	assign Z2 = (OUTPUT_REG_EN == "TRUE")?z_out_reg[37:19]:z_out[37:19];
	assign DLY_B1 = dly_b1;
	assign DLY_B2 = dly_b2;


	// If ACC_FIR is greater than 21, result is invalid
	always @(ACC_FIR)
		if (ACC_FIR > 21)
		begin
			$display("WARNING: DSP19x2 instance %m ACC_FIR input is %d which is greater than 21 which serves no function", ACC_FIR);
			#1 $finish ;
		end
	// If SHIFT_RIGHT is greater than 31, result is invalid
	always @(SHIFT_RIGHT)
		if (SHIFT_RIGHT > 31)
		begin
			$display("WARNING: DSP19x2 instance %m SHIFT_RIGHT input is %d which is greater than 31 which serves no function", SHIFT_RIGHT);
			#1 $finish ;
		end

 initial begin
    case(DSP_MODE)
      "MULTIPLY" ,
      "MULTIPLY_ADD_SUB" ,
      "MULTIPLY_ACCUMULATE": begin end
      default: begin
        $display("\nError: DSP19X2 instance %m has parameter DSP_MODE set to %s.  Valid values are MULTIPLY, MULTIPLY_ADD_SUB, MULTIPLY_ACCUMULATE\n", DSP_MODE);
        #1 $stop ;
      end
    endcase
    case(OUTPUT_REG_EN)
      "TRUE" ,
      "FALSE": begin end
      default: begin
        $display("\nError: DSP19X2 instance %m has parameter OUTPUT_REG_EN set to %s.  Valid values are TRUE, FALSE\n", OUTPUT_REG_EN);
        #1 $stop ;
      end
    endcase
    case(INPUT_REG_EN)
      "TRUE" ,
      "FALSE": begin end
      default: begin
        $display("\nError: DSP19X2 instance %m has parameter INPUT_REG_EN set to %s.  Valid values are TRUE, FALSE\n", INPUT_REG_EN);
        #1 $stop ;
      end
    endcase

  end

endmodule
`endcelldefine
