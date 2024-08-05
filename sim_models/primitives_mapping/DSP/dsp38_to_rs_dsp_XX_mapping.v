//
// Copyright (C) 2023 RapidSilicon
// DSP38 Primitive Forward Mapping
//
//

module DSP38 #(
  parameter DSP_MODE = "MULTIPLY_ACCUMULATE", // DSP arithmetic mode (MULTIPLY/MULTIPLY_ADD_SUB/MULTIPLY_ACCUMULATE)
  parameter [19:0] COEFF_0 = 20'h00000, // 20-bit A input coefficient 0
  parameter [19:0] COEFF_1 = 20'h00000, // 20-bit A input coefficient 1
  parameter [19:0] COEFF_2 = 20'h00000, // 20-bit A input coefficient 2
  parameter [19:0] COEFF_3 = 20'h00000, // 20-bit A input coefficient 3
  parameter OUTPUT_REG_EN = "TRUE", // Enable output register (TRUE/FALSE)
  parameter INPUT_REG_EN = "TRUE" // Enable input register (TRUE/FALSE)
) (
  input wire [19:0] A, // 20-bit data input for multipluier or accumulator loading
  input wire [17:0] B, // 18-bit data input for multiplication
  input wire [5:0] ACC_FIR, // 6-bit left shift A input
  output wire [37:0] Z, // 38-bit data output
  output wire [17:0] DLY_B, // 18-bit B registered output
  input wire CLK, // Clock
  input wire RESET, // Active high reset
  input wire [2:0] FEEDBACK, // 3-bit feedback input selects coefficient
  input wire LOAD_ACC, // Load accumulator input
  input wire SATURATE, // Saturate enable
  input wire [5:0] SHIFT_RIGHT, // 6-bit Shift right
  input wire ROUND, // Round
  input wire SUBTRACT, // Add or subtract
  input wire UNSIGNED_A, // Selects signed or unsigned data for A input
  input wire UNSIGNED_B // Selects signed or unsigned data for B input
);
    localparam  accumulator         = (DSP_MODE == "MULTIPLY_ACCUMULATE") ? 1'h1 : 1'h0;
    localparam  adder               = (DSP_MODE == "MULTIPLY_ADD_SUB") ? 1'h1 : 1'h0;
    localparam  output_reg          = (OUTPUT_REG_EN == "TRUE") ? 1'h1 : 1'h0;
    localparam  input_reg           = (INPUT_REG_EN == "TRUE") ? 1'h1 : 1'h0;
    localparam [0:2] output_select  = {accumulator, adder, output_reg};

    initial begin
       case(DSP_MODE)
         "MULTIPLY" ,
         "MULTIPLY_ADD_SUB" ,
         "MULTIPLY_ACCUMULATE": begin end
         default: begin
           $display("\nError: DSP38 instance %m has parameter DSP_MODE set to %s.  Valid values are MULTIPLY, MULTIPLY_ADD_SUB, MULTIPLY_ACCUMULATE\n", DSP_MODE);
           #1 $stop ;
         end
       endcase
       case(OUTPUT_REG_EN)
         "TRUE" ,
         "FALSE": begin end
         default: begin
           $display("\nError: DSP38 instance %m has parameter OUTPUT_REG_EN set to %s.  Valid values are TRUE, FALSE\n", OUTPUT_REG_EN);
           #1 $stop ;
         end
       endcase
       case(INPUT_REG_EN)
         "TRUE" ,
         "FALSE": begin end
         default: begin
           $display("\nError: DSP38 instance %m has parameter INPUT_REG_EN set to %s.  Valid values are TRUE, FALSE\n", INPUT_REG_EN);
           #1 $stop ;
         end
       endcase
    end
    
    generate
        if (output_select == 3'b000 && input_reg == 1'b1) begin
            RS_DSP_MULT_REGIN # (
                .MODE_BITS({COEFF_0[19:0], COEFF_1[19:0], COEFF_2[19:0], COEFF_3[19:0], 4'bxxxx, 1'b0})
            ) RS_DSP_MULT_REGIN (
                .a(A), 
                .b(B), 
                .z(Z), 
                .feedback(FEEDBACK), 
                .unsigned_a(UNSIGNED_A), 
                .unsigned_b(UNSIGNED_B),
                .clk(CLK), 
                .lreset(RESET)
            );
        end
        else if (output_select == 3'b001 && input_reg == 1'b0) begin
            RS_DSP_MULT_REGOUT # (
                .MODE_BITS({COEFF_0[19:0], COEFF_1[19:0], COEFF_2[19:0], COEFF_3[19:0], 4'bxxxx, 1'b0})
            ) RS_DSP_MULT_REGOUT (
                .a(A), 
                .b(B), 
                .z(Z),  
                .feedback(FEEDBACK), 
                .unsigned_a(UNSIGNED_A), 
                .unsigned_b(UNSIGNED_B),
                .clk(CLK), 
                .lreset(RESET)
            );
        end
        else if (output_select == 3'b001 && input_reg == 1'b1) begin
            RS_DSP_MULT_REGIN_REGOUT # (
                .MODE_BITS({COEFF_0[19:0], COEFF_1[19:0], COEFF_2[19:0], COEFF_3[19:0], 4'bxxxx, 1'b0})
            ) RS_DSP_MULT_REGIN_REGOUT (
                .a(A), 
                .b(B), 
                .z(Z),  
                .feedback(FEEDBACK), 
                .unsigned_a(UNSIGNED_A), 
                .unsigned_b(UNSIGNED_B),
                .clk(CLK), 
                .lreset(RESET)
            );
        end
        else if (output_select == 3'b010 && input_reg == 1'b0) begin
            RS_DSP_MULTADD # (
                .MODE_BITS({COEFF_0[19:0], COEFF_1[19:0], COEFF_2[19:0], COEFF_3[19:0], 4'bxxxx, 1'b0})
            ) RS_DSP_MULTADD (
                .a(A), 
                .b(B), 
                .z(Z),  
                .dly_b(DLY_B),
                .feedback(FEEDBACK), 
                .unsigned_a(UNSIGNED_A), 
                .unsigned_b(UNSIGNED_B),
                .clk(CLK), 
                .lreset(RESET), 
                .acc_fir(ACC_FIR), 
                .load_acc(LOAD_ACC), 
                .saturate_enable(SATURATE),
                .shift_right(SHIFT_RIGHT), 
                .round(ROUND), 
                .subtract(SUBTRACT)
            );
        end
        else if (output_select == 3'b010 && input_reg == 1'b1) begin
            RS_DSP_MULTADD_REGIN # (
                .MODE_BITS({COEFF_0[19:0], COEFF_1[19:0], COEFF_2[19:0], COEFF_3[19:0], 4'bxxxx, 1'b0})
            ) RS_DSP_MULTADD_REGIN (
                .a(A), 
                .b(B), 
                .z(Z),  
                .dly_b(DLY_B),
                .feedback(FEEDBACK), 
                .unsigned_a(UNSIGNED_A), 
                .unsigned_b(UNSIGNED_B),
                .clk(CLK), 
                .lreset(RESET), 
                .acc_fir(ACC_FIR), 
                .load_acc(LOAD_ACC), 
                .saturate_enable(SATURATE),
                .shift_right(SHIFT_RIGHT), 
                .round(ROUND), 
                .subtract(SUBTRACT)
            );
        end
        else if (output_select == 3'b011 && input_reg == 1'b0) begin
            RS_DSP_MULTADD_REGOUT # (
                .MODE_BITS({COEFF_0[19:0], COEFF_1[19:0], COEFF_2[19:0], COEFF_3[19:0], 4'bxxxx, 1'b0})
            ) RS_DSP_MULTADD_REGOUT (
                .a(A), 
                .b(B), 
                .z(Z),  
                .dly_b(DLY_B),
                .feedback(FEEDBACK), 
                .unsigned_a(UNSIGNED_A), 
                .unsigned_b(UNSIGNED_B),
                .clk(CLK), 
                .lreset(RESET), 
                .acc_fir(ACC_FIR), 
                .load_acc(LOAD_ACC), 
                .saturate_enable(SATURATE),
                .shift_right(SHIFT_RIGHT), 
                .round(ROUND), 
                .subtract(SUBTRACT)
            );
        end
        else if (output_select == 3'b011 && input_reg == 1'b1) begin
            RS_DSP_MULTADD_REGIN_REGOUT # (
                .MODE_BITS({COEFF_0[19:0], COEFF_1[19:0], COEFF_2[19:0], COEFF_3[19:0], 4'bxxxx, 1'b0})
            ) RS_DSP_MULTADD_REGIN_REGOUT (
                .a(A), 
                .b(B), 
                .z(Z),  
                .dly_b(DLY_B),
                .feedback(FEEDBACK), 
                .unsigned_a(UNSIGNED_A), 
                .unsigned_b(UNSIGNED_B),
                .clk(CLK), 
                .lreset(RESET), 
                .acc_fir(ACC_FIR), 
                .load_acc(LOAD_ACC), 
                .saturate_enable(SATURATE),
                .shift_right(SHIFT_RIGHT), 
                .round(ROUND), 
                .subtract(SUBTRACT)
            );
        end
        else if (output_select == 3'b100 && input_reg == 1'b0) begin
            RS_DSP_MULTACC # (
                .MODE_BITS({COEFF_0[19:0], COEFF_1[19:0], COEFF_2[19:0], COEFF_3[19:0], 4'bxxxx, 1'b0})
            ) RS_DSP_MULTACC (
                .a(A), 
                .b(B), 
                .z(Z),  
                .feedback(FEEDBACK), 
                .unsigned_a(UNSIGNED_A), 
                .unsigned_b(UNSIGNED_B),
                .clk(CLK), 
                .lreset(RESET), 
                .load_acc(LOAD_ACC), 
                .saturate_enable(SATURATE),
                .shift_right(SHIFT_RIGHT), 
                .round(ROUND), 
                .subtract(SUBTRACT)
            );
        end
        else if (output_select == 3'b100 && input_reg == 1'b1) begin
            RS_DSP_MULTACC_REGIN # (
                .MODE_BITS({COEFF_0[19:0], COEFF_1[19:0], COEFF_2[19:0], COEFF_3[19:0], 4'bxxxx, 1'b0})
            ) RS_DSP_MULTACC_REGIN (
                .a(A), 
                .b(B), 
                .z(Z),  
                .feedback(FEEDBACK), 
                .unsigned_a(UNSIGNED_A), 
                .unsigned_b(UNSIGNED_B),
                .clk(CLK), 
                .lreset(RESET),  
                .load_acc(LOAD_ACC), 
                .saturate_enable(SATURATE),
                .shift_right(SHIFT_RIGHT), 
                .round(ROUND), 
                .subtract(SUBTRACT)
            );
        end
        else if (output_select == 3'b101 && input_reg == 1'b0) begin
            RS_DSP_MULTACC_REGOUT # (
                .MODE_BITS({COEFF_0[19:0], COEFF_1[19:0], COEFF_2[19:0], COEFF_3[19:0], 4'bxxxx, 1'b0})
            ) RS_DSP_MULTACC_REGOUT (
                .a(A), 
                .b(B), 
                .z(Z),  
                .feedback(FEEDBACK), 
                .unsigned_a(UNSIGNED_A), 
                .unsigned_b(UNSIGNED_B),
                .clk(CLK), 
                .lreset(RESET),  
                .load_acc(LOAD_ACC), 
                .saturate_enable(SATURATE),
                .shift_right(SHIFT_RIGHT), 
                .round(ROUND), 
                .subtract(SUBTRACT)
            );
        end
        else if (output_select == 3'b101 && input_reg == 1'b1) begin
            RS_DSP_MULTACC_REGIN_REGOUT # (
                .MODE_BITS({COEFF_0[19:0], COEFF_1[19:0], COEFF_2[19:0], COEFF_3[19:0], 4'bxxxx, 1'b0})
            ) RS_DSP_MULTACC_REGIN_REGOUT (
                .a(A), 
                .b(B), 
                .z(Z),  
                .feedback(FEEDBACK), 
                .unsigned_a(UNSIGNED_A), 
                .unsigned_b(UNSIGNED_B),
                .clk(CLK), 
                .lreset(RESET),
                .load_acc(LOAD_ACC), 
                .saturate_enable(SATURATE),
                .shift_right(SHIFT_RIGHT), 
                .round(ROUND), 
                .subtract(SUBTRACT)
            );
        end
        else begin
            RS_DSP_MULT # (
                .MODE_BITS({COEFF_0[19:0], COEFF_1[19:0], COEFF_2[19:0], COEFF_3[19:0], 4'bxxxx, 1'b0})
            ) RS_DSP_MULT (
                .a(A), 
                .b(B), 
                .z(Z), 
                .feedback(FEEDBACK), 
                .unsigned_a(UNSIGNED_A), 
                .unsigned_b(UNSIGNED_B)
            );
        end
    endgenerate

endmodule