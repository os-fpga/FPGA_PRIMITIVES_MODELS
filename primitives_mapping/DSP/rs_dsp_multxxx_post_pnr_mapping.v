// Copyright (C) 2023 RapidSilicon
//
// RS_DSP_MULTxxx Reverse Mapping File for Post PnR Simulation

`default_nettype none


module RS_DSP_MULT (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    input  wire [2:0] feedback,
    input  wire       unsigned_a,
    input  wire       unsigned_b
);

    parameter [0:84] MODE_BITS = 85'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
    localparam [0:19] COEFF_0 = MODE_BITS[0:19];
    localparam [0:19] COEFF_1 = MODE_BITS[20:39];
    localparam [0:19] COEFF_2 = MODE_BITS[40:59];
    localparam [0:19] COEFF_3 = MODE_BITS[60:79];
    localparam frac_i         = MODE_BITS[84];

generate
    if(frac_i == 1'b0) begin
        DSP38 #(
            .DSP_MODE("MULTIPLY"),
            .OUTPUT_REG_EN("FALSE"),
            .INPUT_REG_EN("FALSE"),
            .COEFF_0(COEFF_0),
            .COEFF_1(COEFF_1),
            .COEFF_2(COEFF_2),
            .COEFF_3(COEFF_3)
        ) DSP38_MULT (
            .A(a),
            .B(b),
            .Z(z),
            .FEEDBACK(feedback),
            .UNSIGNED_A(unsigned_a),
            .UNSIGNED_B(unsigned_b)
        );
    end else begin
        DSP19X2 #(
            .DSP_MODE("MULTIPLY"),
            .OUTPUT_REG_EN("FALSE"),
            .INPUT_REG_EN("FALSE"),
            .COEFF1_0(COEFF_0[0:9]),
            .COEFF1_1(COEFF_1[0:9]),
            .COEFF1_2(COEFF_2[0:9]),
            .COEFF1_3(COEFF_3[0:9]),
            .COEFF2_0(COEFF_0[10:19]),
            .COEFF2_1(COEFF_1[10:19]),
            .COEFF2_2(COEFF_2[10:19]),
            .COEFF2_3(COEFF_3[10:19])
        ) DSP19X2_MULT (
            .A1(a[9:0]),
            .B1(b[8:0]),
            .Z1(z[18:0]),
            .A2(a[19:10]),
            .B2(b[17:9]),
            .Z2(z[37:19]),
            .FEEDBACK(feedback),
            .UNSIGNED_A(unsigned_a),
            .UNSIGNED_B(unsigned_b)
        );
    end
endgenerate
endmodule

module RS_DSP_MULT_REGIN (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire       clk,
    input  wire       lreset,

    input  wire [2:0] feedback,
    input  wire       unsigned_a,
    input  wire       unsigned_b
);

    parameter [0:84] MODE_BITS = 85'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
        
    localparam [0:19] COEFF_0 = MODE_BITS[0:19];
    localparam [0:19] COEFF_1 = MODE_BITS[20:39];
    localparam [0:19] COEFF_2 = MODE_BITS[40:59];
    localparam [0:19] COEFF_3 = MODE_BITS[60:79];
    localparam frac_i         = MODE_BITS[84];

generate
    if(frac_i == 1'b0) begin
        DSP38 #(
            .DSP_MODE("MULTIPLY"),
            .OUTPUT_REG_EN("FALSE"),
            .INPUT_REG_EN("TRUE"),
            .COEFF_0(COEFF_0),
            .COEFF_1(COEFF_1),
            .COEFF_2(COEFF_2),
            .COEFF_3(COEFF_3)
        ) DSP38_MULT_REGIN (
            .A(a),
            .B(b),
            .Z(z),
            .FEEDBACK(feedback),
            .UNSIGNED_A(unsigned_a),
            .UNSIGNED_B(unsigned_b),
            .CLK(clk),
            .RESET(lreset)
        );
    end else begin
        DSP19X2 #(
            .DSP_MODE("MULTIPLY"),
            .OUTPUT_REG_EN("FALSE"),
            .INPUT_REG_EN("TRUE"),
            .COEFF1_0(COEFF_0[0:9]),
            .COEFF1_1(COEFF_1[0:9]),
            .COEFF1_2(COEFF_2[0:9]),
            .COEFF1_3(COEFF_3[0:9]),
            .COEFF2_0(COEFF_0[10:19]),
            .COEFF2_1(COEFF_1[10:19]),
            .COEFF2_2(COEFF_2[10:19]),
            .COEFF2_3(COEFF_3[10:19])
        ) DSP19X2_MULT_REGIN (
            .A1(a[9:0]),
            .B1(b[8:0]),
            .Z1(z[18:0]),
            .A2(a[19:10]),
            .B2(b[17:9]),
            .Z2(z[37:19]),
            .FEEDBACK(feedback),
            .UNSIGNED_A(unsigned_a),
            .UNSIGNED_B(unsigned_b),
            .CLK(clk),
            .RESET(lreset)
        );
    end
endgenerate
endmodule

module RS_DSP_MULT_REGOUT (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire       clk,
    input  wire       lreset,

    input  wire [2:0] feedback,
    input  wire       unsigned_a,
    input  wire       unsigned_b
);

    parameter [0:84] MODE_BITS = 85'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
        
    localparam [0:19] COEFF_0 = MODE_BITS[0:19];
    localparam [0:19] COEFF_1 = MODE_BITS[20:39];
    localparam [0:19] COEFF_2 = MODE_BITS[40:59];
    localparam [0:19] COEFF_3 = MODE_BITS[60:79];
    localparam frac_i         = MODE_BITS[84];

generate
    if(frac_i == 1'b0) begin
        DSP38 #(
            .DSP_MODE("MULTIPLY"),
            .OUTPUT_REG_EN("TRUE"),
            .INPUT_REG_EN("FALSE"),
            .COEFF_0(COEFF_0),
            .COEFF_1(COEFF_1),
            .COEFF_2(COEFF_2),
            .COEFF_3(COEFF_3)
        ) DSP38_MULT_REGOUT (
            .A(a),
            .B(b),
            .Z(z),
            .FEEDBACK(feedback),
            .UNSIGNED_A(unsigned_a),
            .UNSIGNED_B(unsigned_b),
            .CLK(clk),
            .RESET(lreset)
        );
    end else begin
        DSP19X2 #(
            .DSP_MODE("MULTIPLY"),
            .OUTPUT_REG_EN("TRUE"),
            .INPUT_REG_EN("FALSE"),
            .COEFF1_0(COEFF_0[0:9]),
            .COEFF1_1(COEFF_1[0:9]),
            .COEFF1_2(COEFF_2[0:9]),
            .COEFF1_3(COEFF_3[0:9]),
            .COEFF2_0(COEFF_0[10:19]),
            .COEFF2_1(COEFF_1[10:19]),
            .COEFF2_2(COEFF_2[10:19]),
            .COEFF2_3(COEFF_3[10:19])
        ) DSP19X2_MULT_REGOUT (
            .A1(a[9:0]),
            .B1(b[8:0]),
            .Z1(z[18:0]),
            .A2(a[19:10]),
            .B2(b[17:9]),
            .Z2(z[37:19]),
            .FEEDBACK(feedback),
            .UNSIGNED_A(unsigned_a),
            .UNSIGNED_B(unsigned_b),
            .CLK(clk),
            .RESET(lreset)
        );
    end
endgenerate

endmodule

module RS_DSP_MULT_REGIN_REGOUT (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire       clk,
    input  wire       lreset,

    input  wire [2:0] feedback,
    input  wire       unsigned_a,
    input  wire       unsigned_b
);

    parameter [0:84] MODE_BITS = 85'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
        
    localparam [0:19] COEFF_0 = MODE_BITS[0:19];
    localparam [0:19] COEFF_1 = MODE_BITS[20:39];
    localparam [0:19] COEFF_2 = MODE_BITS[40:59];
    localparam [0:19] COEFF_3 = MODE_BITS[60:79];
    localparam frac_i         = MODE_BITS[84];

generate
    if(frac_i == 1'b0) begin
        DSP38 #(
            .DSP_MODE("MULTIPLY"),
            .OUTPUT_REG_EN("TRUE"),
            .INPUT_REG_EN("TRUE"),
            .COEFF_0(COEFF_0),
            .COEFF_1(COEFF_1),
            .COEFF_2(COEFF_2),
            .COEFF_3(COEFF_3)
        ) DSP38_MULT_REGIN_REGOUT (
            .A(a),
            .B(b),
            .Z(z),
            .FEEDBACK(feedback),
            .UNSIGNED_A(unsigned_a),
            .UNSIGNED_B(unsigned_b),
            .CLK(clk),
            .RESET(lreset)
        );
    end else begin
        DSP19X2 #(
            .DSP_MODE("MULTIPLY"),
            .OUTPUT_REG_EN("TRUE"),
            .INPUT_REG_EN("TRUE"),
            .COEFF1_0(COEFF_0[0:9]),
            .COEFF1_1(COEFF_1[0:9]),
            .COEFF1_2(COEFF_2[0:9]),
            .COEFF1_3(COEFF_3[0:9]),
            .COEFF2_0(COEFF_0[10:19]),
            .COEFF2_1(COEFF_1[10:19]),
            .COEFF2_2(COEFF_2[10:19]),
            .COEFF2_3(COEFF_3[10:19])
        ) DSP19X2_MULT_REGIN_REGOUT (
            .A1(a[9:0]),
            .B1(b[8:0]),
            .Z1(z[18:0]),
            .A2(a[19:10]),
            .B2(b[17:9]),
            .Z2(z[37:19]),
            .FEEDBACK(feedback),
            .UNSIGNED_A(unsigned_a),
            .UNSIGNED_B(unsigned_b),
            .CLK(clk),
            .RESET(lreset)
        );
    end
endgenerate

endmodule

module RS_DSP_MULTADD (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    input  wire       clk,
    input  wire       lreset,

    input  wire [ 2:0] feedback,
    input  wire [ 5:0] acc_fir,
    input  wire        load_acc,
    input  wire        unsigned_a,
    input  wire        unsigned_b,

    input  wire        saturate_enable,
    input  wire [ 5:0] shift_right,
    input  wire        round,
    input  wire        subtract,
    output wire [17:0] dly_b
);

    parameter [0:84] MODE_BITS = 85'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
        
    localparam [0:19] COEFF_0 = MODE_BITS[0:19];
    localparam [0:19] COEFF_1 = MODE_BITS[20:39];
    localparam [0:19] COEFF_2 = MODE_BITS[40:59];
    localparam [0:19] COEFF_3 = MODE_BITS[60:79];
    localparam frac_i         = MODE_BITS[84];

generate
    if(frac_i == 1'b0) begin
        DSP38 #(
            .DSP_MODE("MULTIPLY_ADD_SUB"),
            .OUTPUT_REG_EN("FALSE"),
            .INPUT_REG_EN("FALSE"),
            .COEFF_0(COEFF_0),
            .COEFF_1(COEFF_1),
            .COEFF_2(COEFF_2),
            .COEFF_3(COEFF_3)
        ) DSP38_MULTADD (
            .A(a),
            .B(b),
            .Z(z),
            .DLY_B(dly_b),
            .FEEDBACK(feedback),
            .UNSIGNED_A(unsigned_a),
            .UNSIGNED_B(unsigned_b),
            .CLK(clk),
            .RESET(lreset),
            .ACC_FIR(acc_fir),
            .LOAD_ACC(load_acc),
            .SATURATE(saturate_enable),
            .SHIFT_RIGHT(shift_right),
            .ROUND(round),
            .SUBTRACT(subtract)
        );
    end else begin
        DSP19X2 #(
            .DSP_MODE("MULTIPLY_ADD_SUB"),
            .OUTPUT_REG_EN("FALSE"),
            .INPUT_REG_EN("FALSE"),
            .COEFF1_0(COEFF_0[0:9]),
            .COEFF1_1(COEFF_1[0:9]),
            .COEFF1_2(COEFF_2[0:9]),
            .COEFF1_3(COEFF_3[0:9]),
            .COEFF2_0(COEFF_0[10:19]),
            .COEFF2_1(COEFF_1[10:19]),
            .COEFF2_2(COEFF_2[10:19]),
            .COEFF2_3(COEFF_3[10:19])
        ) DSP19X2_MULTADD (
            .A1(a[9:0]),
            .B1(b[8:0]),
            .Z1(z[18:0]),
            .A2(a[19:10]),
            .B2(b[17:9]),
            .Z2(z[37:19]),
            .DLY_B1(dly_b[8:0]),
            .DLY_B2(dly_b[17:9]),
            .FEEDBACK(feedback),
            .UNSIGNED_A(unsigned_a),
            .UNSIGNED_B(unsigned_b),
            .CLK(clk),
            .RESET(lreset),
            .ACC_FIR(acc_fir),
            .LOAD_ACC(load_acc),
            .SATURATE(saturate_enable),
            .SHIFT_RIGHT(shift_right),
            .ROUND(round),
            .SUBTRACT(subtract)
        );
    end
endgenerate
endmodule

module RS_DSP_MULTADD_REGIN (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire        clk,
    input  wire        lreset,

    input  wire [ 2:0] feedback,
    input  wire [ 5:0] acc_fir,
    input  wire        load_acc,
    input  wire        unsigned_a,
    input  wire        unsigned_b,

    input  wire        saturate_enable,
    input  wire [ 5:0] shift_right,
    input  wire        round,
    input  wire        subtract,
    output wire [17:0] dly_b
);

    parameter [0:84] MODE_BITS = 85'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
        
    localparam [0:19] COEFF_0 = MODE_BITS[0:19];
    localparam [0:19] COEFF_1 = MODE_BITS[20:39];
    localparam [0:19] COEFF_2 = MODE_BITS[40:59];
    localparam [0:19] COEFF_3 = MODE_BITS[60:79];
    localparam frac_i         = MODE_BITS[84];

generate
    if(frac_i == 1'b0) begin
        DSP38 #(
            .DSP_MODE("MULTIPLY_ADD_SUB"),
            .OUTPUT_REG_EN("FALSE"),
            .INPUT_REG_EN("TRUE"),
            .COEFF_0(COEFF_0),
            .COEFF_1(COEFF_1),
            .COEFF_2(COEFF_2),
            .COEFF_3(COEFF_3)
        ) DSP38_MULTADD_REGIN (
            .A(a),
            .B(b),
            .Z(z),
            .DLY_B(dly_b),
            .FEEDBACK(feedback),
            .UNSIGNED_A(unsigned_a),
            .UNSIGNED_B(unsigned_b),
            .CLK(clk),
            .RESET(lreset),
            .ACC_FIR(acc_fir),
            .LOAD_ACC(load_acc),
            .SATURATE(saturate_enable),
            .SHIFT_RIGHT(shift_right),
            .ROUND(round),
            .SUBTRACT(subtract)
        );
    end else begin
        DSP19X2 #(
            .DSP_MODE("MULTIPLY_ADD_SUB"),
            .OUTPUT_REG_EN("FALSE"),
            .INPUT_REG_EN("TRUE"),
            .COEFF1_0(COEFF_0[0:9]),
            .COEFF1_1(COEFF_1[0:9]),
            .COEFF1_2(COEFF_2[0:9]),
            .COEFF1_3(COEFF_3[0:9]),
            .COEFF2_0(COEFF_0[10:19]),
            .COEFF2_1(COEFF_1[10:19]),
            .COEFF2_2(COEFF_2[10:19]),
            .COEFF2_3(COEFF_3[10:19])
        ) DSP19X2_MULTADD_REGIN (
            .A1(a[9:0]),
            .B1(b[8:0]),
            .Z1(z[18:0]),
            .A2(a[19:10]),
            .B2(b[17:9]),
            .Z2(z[37:19]),
            .DLY_B1(dly_b[8:0]),
            .DLY_B2(dly_b[17:9]),
            .FEEDBACK(feedback),
            .UNSIGNED_A(unsigned_a),
            .UNSIGNED_B(unsigned_b),
            .CLK(clk),
            .RESET(lreset),
            .ACC_FIR(acc_fir),
            .LOAD_ACC(load_acc),
            .SATURATE(saturate_enable),
            .SHIFT_RIGHT(shift_right),
            .ROUND(round),
            .SUBTRACT(subtract)
        );
    end
endgenerate
endmodule

module RS_DSP_MULTADD_REGOUT (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire        clk,
    input  wire        lreset,

    input  wire [ 2:0] feedback,
    input  wire [ 5:0] acc_fir,
    input  wire        load_acc,
    input  wire        unsigned_a,
    input  wire        unsigned_b,

    input  wire        saturate_enable,
    input  wire [ 5:0] shift_right,
    input  wire        round,
    input  wire        subtract,
    output wire [17:0] dly_b
);

    parameter [0:84] MODE_BITS = 85'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
        
    localparam [0:19] COEFF_0 = MODE_BITS[0:19];
    localparam [0:19] COEFF_1 = MODE_BITS[20:39];
    localparam [0:19] COEFF_2 = MODE_BITS[40:59];
    localparam [0:19] COEFF_3 = MODE_BITS[60:79];
    localparam frac_i         = MODE_BITS[84];

generate
    if(frac_i == 1'b0) begin
        DSP38 #(
            .DSP_MODE("MULTIPLY_ADD_SUB"),
            .OUTPUT_REG_EN("TRUE"),
            .INPUT_REG_EN("FALSE"),
            .COEFF_0(COEFF_0),
            .COEFF_1(COEFF_1),
            .COEFF_2(COEFF_2),
            .COEFF_3(COEFF_3)
        ) DSP38_MULTADD_REGOUT (
            .A(a),
            .B(b),
            .Z(z),
            .DLY_B(dly_b),
            .FEEDBACK(feedback),
            .UNSIGNED_A(unsigned_a),
            .UNSIGNED_B(unsigned_b),
            .CLK(clk),
            .RESET(lreset),
            .ACC_FIR(acc_fir),
            .LOAD_ACC(load_acc),
            .SATURATE(saturate_enable),
            .SHIFT_RIGHT(shift_right),
            .ROUND(round),
            .SUBTRACT(subtract)
        );
    end else begin
        DSP19X2 #(
            .DSP_MODE("MULTIPLY_ADD_SUB"),
            .OUTPUT_REG_EN("TRUE"),
            .INPUT_REG_EN("FALSE"),
            .COEFF1_0(COEFF_0[0:9]),
            .COEFF1_1(COEFF_1[0:9]),
            .COEFF1_2(COEFF_2[0:9]),
            .COEFF1_3(COEFF_3[0:9]),
            .COEFF2_0(COEFF_0[10:19]),
            .COEFF2_1(COEFF_1[10:19]),
            .COEFF2_2(COEFF_2[10:19]),
            .COEFF2_3(COEFF_3[10:19])
        ) DSP19X2_MULTADD_REGOUT (
            .A1(a[9:0]),
            .B1(b[8:0]),
            .Z1(z[18:0]),
            .A2(a[19:10]),
            .B2(b[17:9]),
            .Z2(z[37:19]),
            .DLY_B1(dly_b[8:0]),
            .DLY_B2(dly_b[17:9]),
            .FEEDBACK(feedback),
            .UNSIGNED_A(unsigned_a),
            .UNSIGNED_B(unsigned_b),
            .CLK(clk),
            .RESET(lreset),
            .ACC_FIR(acc_fir),
            .LOAD_ACC(load_acc),
            .SATURATE(saturate_enable),
            .SHIFT_RIGHT(shift_right),
            .ROUND(round),
            .SUBTRACT(subtract)
        );
    end
endgenerate
endmodule

module RS_DSP_MULTADD_REGIN_REGOUT (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire        clk,
    input  wire        lreset,

    input  wire [ 2:0] feedback,
    input  wire [ 5:0] acc_fir,
    input  wire        load_acc,
    input  wire        unsigned_a,
    input  wire        unsigned_b,

    input  wire        saturate_enable,
    input  wire [ 5:0] shift_right,
    input  wire        round,
    input  wire        subtract,
    output wire [17:0] dly_b
);

    parameter [0:84] MODE_BITS = 85'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
        
    localparam [0:19] COEFF_0 = MODE_BITS[0:19];
    localparam [0:19] COEFF_1 = MODE_BITS[20:39];
    localparam [0:19] COEFF_2 = MODE_BITS[40:59];
    localparam [0:19] COEFF_3 = MODE_BITS[60:79];
    localparam frac_i         = MODE_BITS[84];

generate
    if(frac_i == 1'b0) begin
        DSP38 #(
            .DSP_MODE("MULTIPLY_ADD_SUB"),
            .OUTPUT_REG_EN("TRUE"),
            .INPUT_REG_EN("TRUE"),
            .COEFF_0(COEFF_0),
            .COEFF_1(COEFF_1),
            .COEFF_2(COEFF_2),
            .COEFF_3(COEFF_3)
        ) DSP38_MULTADD_REGIN_REGOUT (
            .A(a),
            .B(b),
            .Z(z),
            .DLY_B(dly_b),
            .FEEDBACK(feedback),
            .UNSIGNED_A(unsigned_a),
            .UNSIGNED_B(unsigned_b),
            .CLK(clk),
            .RESET(lreset),
            .ACC_FIR(acc_fir),
            .LOAD_ACC(load_acc),
            .SATURATE(saturate_enable),
            .SHIFT_RIGHT(shift_right),
            .ROUND(round),
            .SUBTRACT(subtract)
        );
    end else begin
        DSP19X2 #(
            .DSP_MODE("MULTIPLY_ADD_SUB"),
            .OUTPUT_REG_EN("TRUE"),
            .INPUT_REG_EN("TRUE"),
            .COEFF1_0(COEFF_0[0:9]),
            .COEFF1_1(COEFF_1[0:9]),
            .COEFF1_2(COEFF_2[0:9]),
            .COEFF1_3(COEFF_3[0:9]),
            .COEFF2_0(COEFF_0[10:19]),
            .COEFF2_1(COEFF_1[10:19]),
            .COEFF2_2(COEFF_2[10:19]),
            .COEFF2_3(COEFF_3[10:19])
        ) DSP19X2_MULTADD_REGIN_REGOUT (
            .A1(a[9:0]),
            .B1(b[8:0]),
            .Z1(z[18:0]),
            .A2(a[19:10]),
            .B2(b[17:9]),
            .Z2(z[37:19]),
            .DLY_B1(dly_b[8:0]),
            .DLY_B2(dly_b[17:9]),
            .FEEDBACK(feedback),
            .UNSIGNED_A(unsigned_a),
            .UNSIGNED_B(unsigned_b),
            .CLK(clk),
            .RESET(lreset),
            .ACC_FIR(acc_fir),
            .LOAD_ACC(load_acc),
            .SATURATE(saturate_enable),
            .SHIFT_RIGHT(shift_right),
            .ROUND(round),
            .SUBTRACT(subtract)
        );
    end
endgenerate
endmodule

module RS_DSP_MULTACC (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire        clk,
    input  wire        lreset,

    input  wire        load_acc,
    input  wire [ 2:0] feedback,
    input  wire        unsigned_a,
    input  wire        unsigned_b,

    input  wire        saturate_enable,
    input  wire [ 5:0] shift_right,
    input  wire        round,
    input  wire        subtract
);

    parameter [0:84] MODE_BITS = 85'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
        
    localparam [0:19] COEFF_0 = MODE_BITS[0:19];
    localparam [0:19] COEFF_1 = MODE_BITS[20:39];
    localparam [0:19] COEFF_2 = MODE_BITS[40:59];
    localparam [0:19] COEFF_3 = MODE_BITS[60:79];
    localparam frac_i         = MODE_BITS[84];

generate
    if(frac_i == 1'b0) begin
        DSP38 #(
            .DSP_MODE("MULTIPLY_ACCUMULATE"),
            .OUTPUT_REG_EN("FALSE"),
            .INPUT_REG_EN("FALSE"),
            .COEFF_0(COEFF_0),
            .COEFF_1(COEFF_1),
            .COEFF_2(COEFF_2),
            .COEFF_3(COEFF_3)
        ) DSP38_MULTACC (
            .A(a),
            .B(b),
            .Z(z),
            .FEEDBACK(feedback),
            .UNSIGNED_A(unsigned_a),
            .UNSIGNED_B(unsigned_b),
            .CLK(clk),
            .RESET(lreset),
            .LOAD_ACC(load_acc),
            .SATURATE(saturate_enable),
            .SHIFT_RIGHT(shift_right),
            .ROUND(round),
            .SUBTRACT(subtract)
        );
    end else begin
        DSP19X2 #(
            .DSP_MODE("MULTIPLY_ACCUMULATE"),
            .OUTPUT_REG_EN("FALSE"),
            .INPUT_REG_EN("FALSE"),
            .COEFF1_0(COEFF_0[0:9]),
            .COEFF1_1(COEFF_1[0:9]),
            .COEFF1_2(COEFF_2[0:9]),
            .COEFF1_3(COEFF_3[0:9]),
            .COEFF2_0(COEFF_0[10:19]),
            .COEFF2_1(COEFF_1[10:19]),
            .COEFF2_2(COEFF_2[10:19]),
            .COEFF2_3(COEFF_3[10:19])
        ) DSP19X2_MULTACC (
            .A1(a[9:0]),
            .B1(b[8:0]),
            .Z1(z[18:0]),
            .A2(a[19:10]),
            .B2(b[17:9]),
            .Z2(z[37:19]),
            .FEEDBACK(feedback),
            .UNSIGNED_A(unsigned_a),
            .UNSIGNED_B(unsigned_b),
            .CLK(clk),
            .RESET(lreset),
            .LOAD_ACC(load_acc),
            .SATURATE(saturate_enable),
            .SHIFT_RIGHT(shift_right),
            .ROUND(round),
            .SUBTRACT(subtract)
        );
    end
endgenerate
endmodule

module RS_DSP_MULTACC_REGIN (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire        clk,
    input  wire        lreset,

    input  wire [ 2:0] feedback,
    input  wire        load_acc,
    input  wire        unsigned_a,
    input  wire        unsigned_b,

    input  wire        saturate_enable,
    input  wire [ 5:0] shift_right,
    input  wire        round,
    input  wire        subtract
);

    parameter [0:84] MODE_BITS = 85'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
        
    localparam [0:19] COEFF_0 = MODE_BITS[0:19];
    localparam [0:19] COEFF_1 = MODE_BITS[20:39];
    localparam [0:19] COEFF_2 = MODE_BITS[40:59];
    localparam [0:19] COEFF_3 = MODE_BITS[60:79];
    localparam frac_i         = MODE_BITS[84];

generate
    if(frac_i == 1'b0) begin
        DSP38 #(
            .DSP_MODE("MULTIPLY_ACCUMULATE"),
            .OUTPUT_REG_EN("FALSE"),
            .INPUT_REG_EN("TRUE"),
            .COEFF_0(COEFF_0),
            .COEFF_1(COEFF_1),
            .COEFF_2(COEFF_2),
            .COEFF_3(COEFF_3)
        ) DSP38_MULTACC_REGIN (
            .A(a),
            .B(b),
            .Z(z),
            .FEEDBACK(feedback),
            .UNSIGNED_A(unsigned_a),
            .UNSIGNED_B(unsigned_b),
            .CLK(clk),
            .RESET(lreset),
            .LOAD_ACC(load_acc),
            .SATURATE(saturate_enable),
            .SHIFT_RIGHT(shift_right),
            .ROUND(round),
            .SUBTRACT(subtract)
        );
    end else begin
        DSP19X2 #(
            .DSP_MODE("MULTIPLY_ACCUMULATE"),
            .OUTPUT_REG_EN("FALSE"),
            .INPUT_REG_EN("TRUE"),
            .COEFF1_0(COEFF_0[0:9]),
            .COEFF1_1(COEFF_1[0:9]),
            .COEFF1_2(COEFF_2[0:9]),
            .COEFF1_3(COEFF_3[0:9]),
            .COEFF2_0(COEFF_0[10:19]),
            .COEFF2_1(COEFF_1[10:19]),
            .COEFF2_2(COEFF_2[10:19]),
            .COEFF2_3(COEFF_3[10:19])
        ) DSP19X2_MULTACC_REGIN (
            .A1(a[9:0]),
            .B1(b[8:0]),
            .Z1(z[18:0]),
            .A2(a[19:10]),
            .B2(b[17:9]),
            .Z2(z[37:19]),
            .FEEDBACK(feedback),
            .UNSIGNED_A(unsigned_a),
            .UNSIGNED_B(unsigned_b),
            .CLK(clk),
            .RESET(lreset),
            .LOAD_ACC(load_acc),
            .SATURATE(saturate_enable),
            .SHIFT_RIGHT(shift_right),
            .ROUND(round),
            .SUBTRACT(subtract)
        );
    end
endgenerate
endmodule

module RS_DSP_MULTACC_REGOUT (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire        clk,
    input  wire        lreset,

    input  wire [ 2:0] feedback,
    input  wire        load_acc,
    input  wire        unsigned_a,
    input  wire        unsigned_b,

    input  wire        saturate_enable,
    input  wire [ 5:0] shift_right,
    input  wire        round,
    input  wire        subtract
);

    parameter [0:84] MODE_BITS = 85'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
        
    localparam [0:19] COEFF_0 = MODE_BITS[0:19];
    localparam [0:19] COEFF_1 = MODE_BITS[20:39];
    localparam [0:19] COEFF_2 = MODE_BITS[40:59];
    localparam [0:19] COEFF_3 = MODE_BITS[60:79];
    localparam frac_i         = MODE_BITS[84];

generate
    if(frac_i == 1'b0) begin
        DSP38 #(
            .DSP_MODE("MULTIPLY_ACCUMULATE"),
            .OUTPUT_REG_EN("TRUE"),
            .INPUT_REG_EN("FALSE"),
            .COEFF_0(COEFF_0),
            .COEFF_1(COEFF_1),
            .COEFF_2(COEFF_2),
            .COEFF_3(COEFF_3)
        ) DSP38_MULTACC_REGOUT (
            .A(a),
            .B(b),
            .Z(z),
            .FEEDBACK(feedback),
            .UNSIGNED_A(unsigned_a),
            .UNSIGNED_B(unsigned_b),
            .CLK(clk),
            .RESET(lreset),
            .LOAD_ACC(load_acc),
            .SATURATE(saturate_enable),
            .SHIFT_RIGHT(shift_right),
            .ROUND(round),
            .SUBTRACT(subtract)
        );
    end else begin
        DSP19X2 #(
            .DSP_MODE("MULTIPLY_ACCUMULATE"),
            .OUTPUT_REG_EN("TRUE"),
            .INPUT_REG_EN("FALSE"),
            .COEFF1_0(COEFF_0[0:9]),
            .COEFF1_1(COEFF_1[0:9]),
            .COEFF1_2(COEFF_2[0:9]),
            .COEFF1_3(COEFF_3[0:9]),
            .COEFF2_0(COEFF_0[10:19]),
            .COEFF2_1(COEFF_1[10:19]),
            .COEFF2_2(COEFF_2[10:19]),
            .COEFF2_3(COEFF_3[10:19])
        ) DSP19X2_MULTACC_REGOUT (
            .A1(a[9:0]),
            .B1(b[8:0]),
            .Z1(z[18:0]),
            .A2(a[19:10]),
            .B2(b[17:9]),
            .Z2(z[37:19]),
            .FEEDBACK(feedback),
            .UNSIGNED_A(unsigned_a),
            .UNSIGNED_B(unsigned_b),
            .CLK(clk),
            .RESET(lreset),
            .LOAD_ACC(load_acc),
            .SATURATE(saturate_enable),
            .SHIFT_RIGHT(shift_right),
            .ROUND(round),
            .SUBTRACT(subtract)
        );
    end
endgenerate
endmodule

module RS_DSP_MULTACC_REGIN_REGOUT (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire        clk,
    input  wire        lreset,

    input  wire [ 2:0] feedback,
    input  wire        load_acc,
    input  wire        unsigned_a,
    input  wire        unsigned_b,

    input  wire        saturate_enable,
    input  wire [ 5:0] shift_right,
    input  wire        round,
    input  wire        subtract
);

    parameter [0:84] MODE_BITS = 85'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
        
    localparam [0:19] COEFF_0 = MODE_BITS[0:19];
    localparam [0:19] COEFF_1 = MODE_BITS[20:39];
    localparam [0:19] COEFF_2 = MODE_BITS[40:59];
    localparam [0:19] COEFF_3 = MODE_BITS[60:79];
    localparam frac_i         = MODE_BITS[84];

generate
    if(frac_i == 1'b0) begin
        DSP38 #(
            .DSP_MODE("MULTIPLY_ACCUMULATE"),
            .OUTPUT_REG_EN("TRUE"),
            .INPUT_REG_EN("TRUE"),
            .COEFF_0(COEFF_0),
            .COEFF_1(COEFF_1),
            .COEFF_2(COEFF_2),
            .COEFF_3(COEFF_3)
        ) DSP38_MULTACC_REGIN_REGOUT (
            .A(a),
            .B(b),
            .Z(z),
            .FEEDBACK(feedback),
            .UNSIGNED_A(unsigned_a),
            .UNSIGNED_B(unsigned_b),
            .CLK(clk),
            .RESET(lreset),
            .LOAD_ACC(load_acc),
            .SATURATE(saturate_enable),
            .SHIFT_RIGHT(shift_right),
            .ROUND(round),
            .SUBTRACT(subtract)
        );
    end else begin
        DSP19X2 #(
            .DSP_MODE("MULTIPLY_ACCUMULATE"),
            .OUTPUT_REG_EN("TRUE"),
            .INPUT_REG_EN("TRUE"),
            .COEFF1_0(COEFF_0[0:9]),
            .COEFF1_1(COEFF_1[0:9]),
            .COEFF1_2(COEFF_2[0:9]),
            .COEFF1_3(COEFF_3[0:9]),
            .COEFF2_0(COEFF_0[10:19]),
            .COEFF2_1(COEFF_1[10:19]),
            .COEFF2_2(COEFF_2[10:19]),
            .COEFF2_3(COEFF_3[10:19])
        ) DSP19X2_MULTACC_REGIN_REGOUT (
            .A1(a[9:0]),
            .B1(b[8:0]),
            .Z1(z[18:0]),
            .A2(a[19:10]),
            .B2(b[17:9]),
            .Z2(z[37:19]),
            .FEEDBACK(feedback),
            .UNSIGNED_A(unsigned_a),
            .UNSIGNED_B(unsigned_b),
            .CLK(clk),
            .RESET(lreset),
            .LOAD_ACC(load_acc),
            .SATURATE(saturate_enable),
            .SHIFT_RIGHT(shift_right),
            .ROUND(round),
            .SUBTRACT(subtract)
        );
    end
endgenerate

endmodule