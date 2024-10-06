`timescale 1ps/1ps
`celldefine
//
// DLY_SEL_DCODER simulation model
// Address Decoder
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module DLY_SEL_DCODER (
  input DLY_LOAD, // Delay load input
  input DLY_ADJ, // Delay adjust input
  input DLY_INCDEC, // Delay increment / decrement input
  input [4:0] DLY_ADDR, // Input Address
  output reg [2:0] DLY0_CNTRL, // Output Bus
  output reg [2:0] DLY1_CNTRL, // Output Bus
  output reg [2:0] DLY2_CNTRL, // Output Bus
  output reg [2:0] DLY3_CNTRL, // Output Bus
  output reg [2:0] DLY4_CNTRL, // Output Bus
  output reg [2:0] DLY5_CNTRL, // Output Bus
  output reg [2:0] DLY6_CNTRL, // Output Bus
  output reg [2:0] DLY7_CNTRL, // Output Bus
  output reg [2:0] DLY8_CNTRL, // Output Bus
  output reg [2:0] DLY9_CNTRL, // Output Bus
  output reg [2:0] DLY10_CNTRL, // Output Bus
  output reg [2:0] DLY11_CNTRL, // Output Bus
  output reg [2:0] DLY12_CNTRL, // Output Bus
  output reg [2:0] DLY13_CNTRL, // Output Bus
  output reg [2:0] DLY14_CNTRL, // Output Bus
  output reg [2:0] DLY15_CNTRL, // Output Bus
  output reg [2:0] DLY16_CNTRL, // Output Bus
  output reg [2:0] DLY17_CNTRL, // Output Bus
  output reg [2:0] DLY18_CNTRL, // Output Bus
  output reg [2:0] DLY19_CNTRL // Output Bus
);


always @(*) 
begin
  DLY0_CNTRL  = 3'b000;
  DLY1_CNTRL  = 3'b000;
  DLY2_CNTRL  = 3'b000;
  DLY3_CNTRL  = 3'b000;
  DLY4_CNTRL  = 3'b000;
  DLY5_CNTRL  = 3'b000;
  DLY6_CNTRL  = 3'b000;
  DLY7_CNTRL  = 3'b000;
  DLY8_CNTRL  = 3'b000;
  DLY9_CNTRL  = 3'b000;
  DLY10_CNTRL = 3'b000;
  DLY11_CNTRL = 3'b000;
  DLY12_CNTRL = 3'b000;
  DLY13_CNTRL = 3'b000;
  DLY14_CNTRL = 3'b000;
  DLY15_CNTRL = 3'b000;
  DLY16_CNTRL = 3'b000;
  DLY17_CNTRL = 3'b000;
  DLY18_CNTRL = 3'b000;
  DLY19_CNTRL = 3'b000;

  case(DLY_ADDR)
    5'd0:  DLY0_CNTRL  = {DLY_LOAD, DLY_ADJ, DLY_INCDEC};
    5'd1:  DLY1_CNTRL  = {DLY_LOAD, DLY_ADJ, DLY_INCDEC};
    5'd2:  DLY2_CNTRL  = {DLY_LOAD, DLY_ADJ, DLY_INCDEC};
    5'd3:  DLY3_CNTRL  = {DLY_LOAD, DLY_ADJ, DLY_INCDEC};
    5'd4:  DLY4_CNTRL  = {DLY_LOAD, DLY_ADJ, DLY_INCDEC};
    5'd5:  DLY5_CNTRL  = {DLY_LOAD, DLY_ADJ, DLY_INCDEC};
    5'd6:  DLY6_CNTRL  = {DLY_LOAD, DLY_ADJ, DLY_INCDEC};
    5'd7:  DLY7_CNTRL  = {DLY_LOAD, DLY_ADJ, DLY_INCDEC};
    5'd8:  DLY8_CNTRL  = {DLY_LOAD, DLY_ADJ, DLY_INCDEC};
    5'd9:  DLY9_CNTRL  = {DLY_LOAD, DLY_ADJ, DLY_INCDEC};
    5'd10: DLY10_CNTRL = {DLY_LOAD, DLY_ADJ, DLY_INCDEC};
    5'd11: DLY11_CNTRL = {DLY_LOAD, DLY_ADJ, DLY_INCDEC};
    5'd12: DLY12_CNTRL = {DLY_LOAD, DLY_ADJ, DLY_INCDEC};
    5'd13: DLY13_CNTRL = {DLY_LOAD, DLY_ADJ, DLY_INCDEC};
    5'd14: DLY14_CNTRL = {DLY_LOAD, DLY_ADJ, DLY_INCDEC};
    5'd15: DLY15_CNTRL = {DLY_LOAD, DLY_ADJ, DLY_INCDEC};
    5'd16: DLY16_CNTRL = {DLY_LOAD, DLY_ADJ, DLY_INCDEC};
    5'd17: DLY17_CNTRL = {DLY_LOAD, DLY_ADJ, DLY_INCDEC};
    5'd18: DLY18_CNTRL = {DLY_LOAD, DLY_ADJ, DLY_INCDEC};
    5'd19: DLY19_CNTRL = {DLY_LOAD, DLY_ADJ, DLY_INCDEC};
  
  endcase

end


endmodule
`endcelldefine
