`timescale 1ps/1ps
`celldefine
//
// DLY_SEL_DECODER simulation model
// Address Decoder
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module DLY_SEL_DECODER (
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


`ifndef SYNTHESIS  
 `ifdef TIMED_SIM
   specparam T1 = 0.4;

    specify
      if (DLY_ADDR == 5'd0)
      (DLY_LOAD *> DLY0_CNTRL)   = T1;
      (DLY_ADJ *> DLY0_CNTRL)    = T1;
      (DLY_INCDEC => DLY0_CNTRL) = T1;
      if (DLY_ADDR == 5'd1)
      (DLY_LOAD *> DLY1_CNTRL)   = T1;
      (DLY_ADJ *> DLY1_CNTRL)    = T1;
      (DLY_INCDEC => DLY1_CNTRL) = T1;
      if (DLY_ADDR == 5'd2)
      (DLY_LOAD *> DLY2_CNTRL)   = T1;
      (DLY_ADJ *> DLY2_CNTRL)    = T1;
      (DLY_INCDEC => DLY2_CNTRL) = T1;
      if (DLY_ADDR == 5'd3)
      (DLY_LOAD *> DLY3_CNTRL)   = T1;
      (DLY_ADJ *> DLY3_CNTRL)    = T1;
      (DLY_INCDEC => DLY3_CNTRL) = T1;
      if (DLY_ADDR == 5'd4)
      (DLY_LOAD *> DLY4_CNTRL)   = T1;
      (DLY_ADJ *> DLY4_CNTRL)    = T1;
      (DLY_INCDEC => DLY4_CNTRL) = T1;
      if (DLY_ADDR == 5'd5)
      (DLY_LOAD *> DLY5_CNTRL)   = T1;
      (DLY_ADJ *> DLY5_CNTRL)    = T1;
      (DLY_INCDEC => DLY5_CNTRL) = T1;
      if (DLY_ADDR == 5'd6)
      (DLY_LOAD *> DLY6_CNTRL)   = T1;
      (DLY_ADJ *> DLY6_CNTRL)    = T1;
      (DLY_INCDEC => DLY6_CNTRL) = T1;
      if (DLY_ADDR == 5'd7)
      (DLY_LOAD *> DLY7_CNTRL)   = T1;
      (DLY_ADJ *> DLY7_CNTRL)    = T1;
      (DLY_INCDEC => DLY7_CNTRL) = T1;
      if (DLY_ADDR == 5'd8)
      (DLY_LOAD *> DLY8_CNTRL)   = T1;
      (DLY_ADJ *> DLY8_CNTRL)    = T1;
      (DLY_INCDEC => DLY8_CNTRL) = T1;
      if (DLY_ADDR == 5'd9)
      (DLY_LOAD *> DLY9_CNTRL)   = T1;
      (DLY_ADJ *> DLY9_CNTRL)    = T1;
      (DLY_INCDEC => DLY9_CNTRL) = T1;
      if (DLY_ADDR == 5'd10)
      (DLY_LOAD *> DLY10_CNTRL)   = T1;
      (DLY_ADJ *> DLY10_CNTRL)    = T1;
      (DLY_INCDEC => DLY10_CNTRL) = T1;
      if (DLY_ADDR == 5'd12)
      (DLY_LOAD *> DLY12_CNTRL)   = T1;
      (DLY_ADJ *> DLY12_CNTRL)    = T1;
      (DLY_INCDEC => DLY12_CNTRL) = T1;
      if (DLY_ADDR == 5'd13)
      (DLY_LOAD *> DLY13_CNTRL)   = T1;
      (DLY_ADJ *> DLY13_CNTRL)    = T1;
      (DLY_INCDEC => DLY13_CNTRL) = T1;
      if (DLY_ADDR == 5'd14)
      (DLY_LOAD *> DLY14_CNTRL)   = T1;
      (DLY_ADJ *> DLY14_CNTRL)    = T1;
      (DLY_INCDEC => DLY14_CNTRL) = T1;
      if (DLY_ADDR == 5'd15)
      (DLY_LOAD *> DLY15_CNTRL)   = T1;
      (DLY_ADJ *> DLY15_CNTRL)    = T1;
      (DLY_INCDEC => DLY15_CNTRL) = T1;
      if (DLY_ADDR == 5'd16)
      (DLY_LOAD *> DLY16_CNTRL)   = T1;
      (DLY_ADJ *> DLY16_CNTRL)    = T1;
      (DLY_INCDEC => DLY16_CNTRL) = T1;
      if (DLY_ADDR == 5'd17)
      (DLY_LOAD *> DLY17_CNTRL)   = T1;
      (DLY_ADJ *> DLY17_CNTRL)    = T1;
      (DLY_INCDEC => DLY17_CNTRL) = T1;
      if (DLY_ADDR == 5'd18)
      (DLY_LOAD *> DLY18_CNTRL)   = T1;
      (DLY_ADJ *> DLY18_CNTRL)    = T1;
      (DLY_INCDEC => DLY18_CNTRL) = T1;
      if (DLY_ADDR == 5'd19)
      (DLY_LOAD *> DLY19_CNTRL)   = T1;
      (DLY_ADJ *> DLY19_CNTRL)    = T1;
      (DLY_INCDEC => DLY19_CNTRL) = T1;

    endspecify

  `endif // `ifdef TIMED_SIM  
`endif //  `ifndef SYNTHESIS

endmodule
`endcelldefine
