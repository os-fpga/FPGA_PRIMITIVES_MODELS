// Design file to test the reverse mapping file for simulation

module sync_split_fifo_R18W18_R9W9 (
  input clock0, clock2, clock1, clock3, we1, we2, re1, re2, rst_ptr1, rst_ptr2,
  input [17:0] din1, 
  input [8:0] din2,
  output [17:0] dout1, 
  output [8:0] dout2,
  output EMPTY1,EPO1,EWM1,UNDERRUN1,FULL1,FMO1,FWM1,OVERRUN1, EMPTY2,EPO2,EWM2,UNDERRUN2,FULL2,FMO2,FWM2,OVERRUN2);

parameter [0:80] MODE_BITS =81'h14928800FFCC924400FFD;
wire [8:0] open_wire2;
 RS_TDP36K  #(.MODE_BITS(MODE_BITS))
  inst1(
    .ADDR_A1(15'd0),
    .ADDR_A2(14'd0),
    .ADDR_B1(15'd0),
    .ADDR_B2(14'd0),
    .BE_A1(2'b0),
    .BE_A2(2'b0),
    .BE_B1(2'b0),
    .BE_B2(2'b0),
    .CLK_A1(clock0),
    .CLK_A2(clock2),
    .CLK_B1(clock1),
    .CLK_B2(clock3),
    .FLUSH1(rst_ptr1),
    .FLUSH2(rst_ptr2),
    .RDATA_A1({EMPTY1,EPO1,EWM1,UNDERRUN1,FULL1,FMO1,FWM1,OVERRUN1}),
    .RDATA_A2({EMPTY2,EPO2,EWM2,UNDERRUN2,FULL2,FMO2,FWM2,OVERRUN2}),
    .RDATA_B1(dout1),
    .RDATA_B2({open_wire2[8],dout2[8],open_wire2[7:0],dout2[7:0]}),
    .REN_A1(1'b0),
    .REN_A2(1'b0),
    .REN_B1(re1),
    .REN_B2(re2),
    .WDATA_A1(din1),
    .WDATA_A2({1'b0,din2[8],8'b0,din2[7:0]}),
    .WDATA_B1(18'd0),
    .WDATA_B2(18'd0),
    .WEN_A1(we1),
    .WEN_A2(we2),
    .WEN_B1(1'b0),
    .WEN_B2(1'b0)
  );
 

endmodule