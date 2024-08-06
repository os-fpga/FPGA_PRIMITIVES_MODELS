// Design file to test the reverse mapping file for simulation

module sync_fifo_R36W36 (
  input clock0, clock1, we1, re1, rst_ptr1,
  input [35:0] din1, 
  output [35:0] dout1,
  output EMPTY1,EPO1,EWM1,UNDERRUN1,FULL1,FMO1,FWM1,OVERRUN1);

parameter [0:80] MODE_BITS =81'h1DB68800FFCED24400FFC;
 RS_TDP36K  #(.MODE_BITS(MODE_BITS))
  inst1(
    .ADDR_A1(15'd0),
    .ADDR_B1(15'd0),
    .BE_A1(2'b0),
    .BE_B1(2'b0),
    .CLK_A1(clock0),
    .CLK_B1(clock1),
    .FLUSH1(rst_ptr1),
    .RDATA_A1({EMPTY1,EPO1,EWM1,UNDERRUN1,FULL1,FMO1,FWM1,OVERRUN1}),
    .RDATA_B1(dout1[17:0]),
    .RDATA_B2(dout1[35:18]),
    .REN_A1(1'b0),
    .REN_B1(re1),
    .WDATA_A1(din1[17:0]),
    .WDATA_A2(din1[35:18]),
    .WDATA_B1(18'd0),
    .WEN_A1(we1),
    .WEN_B1(1'b0)
  );
 

endmodule