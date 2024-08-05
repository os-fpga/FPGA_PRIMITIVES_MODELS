// Design file to test the reverse mapping file for simulation

module dsp19x2_inst_design (
input [8:0] b1, 
input [8:0] b2, 
input clk, reset,
input [9:0] a1,
output [18:0] z_out1,
input [9:0] a2,
output [18:0] z_out2);

wire [18:0] Z1, Z2, Z3, Z4;

RS_DSP_MULTACC #(
    .MODE_BITS(85'd1)
) RS_DSP_MULTACC (
    .a({a1, a2}), 
    .b({b1, b2}), 
    .z({Z1, Z3}),  
    .feedback(3'd0), 
    .unsigned_a(1'b1), 
    .unsigned_b(1'b1),
    .clk(clk), 
    .lreset(reset), 
    .load_acc(1'b1), 
    .saturate_enable(1'b0),
    .shift_right(5'd0), 
    .round(1'd0), 
    .subtract(1'd0)
);

RS_DSP_MULT_REGOUT #(
    .MODE_BITS(85'd1)
) RS_DSP_MULT_REGOUT (
    .a({a1, a2}), 
    .b({b1, b2}), 
    .z({Z2, Z4}),  
    .feedback(3'd0), 
    .unsigned_a(1'b1), 
    .unsigned_b(1'b1),
    .clk(clk), 
    .lreset(reset)
);

assign z_out1 = Z1 & Z2;
assign z_out2 = Z3 & Z4;
endmodule


