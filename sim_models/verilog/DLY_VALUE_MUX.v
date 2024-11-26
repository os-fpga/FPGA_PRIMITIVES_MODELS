`timescale 1ps/1ps
`celldefine
//
// DLY_VALUE_MUX simulation model
// Multiplexer
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module DLY_VALUE_MUX (
  input [5:0] DLY_TAP0_VAL, // Delay Tap Value Input Port
  input [5:0] DLY_TAP1_VAL, // Delay Tap Value Input Port
  input [5:0] DLY_TAP2_VAL, // Delay Tap Value Input Port
  input [5:0] DLY_TAP3_VAL, // Delay Tap Value Input Port
  input [5:0] DLY_TAP4_VAL, // Delay Tap Value Input Port
  input [5:0] DLY_TAP5_VAL, // Delay Tap Value Input Port
  input [5:0] DLY_TAP6_VAL, // Delay Tap Value Input Port
  input [5:0] DLY_TAP7_VAL, // Delay Tap Value Input Port
  input [5:0] DLY_TAP8_VAL, // Delay Tap Value Input Port
  input [5:0] DLY_TAP9_VAL, // Delay Tap Value Input Port
  input [5:0] DLY_TAP10_VAL, // Delay Tap Value Input Port
  input [5:0] DLY_TAP11_VAL, // Delay Tap Value Input Port
  input [5:0] DLY_TAP12_VAL, // Delay Tap Value Input Port
  input [5:0] DLY_TAP13_VAL, // Delay Tap Value Input Port
  input [5:0] DLY_TAP14_VAL, // Delay Tap Value Input Port
  input [5:0] DLY_TAP15_VAL, // Delay Tap Value Input Port
  input [5:0] DLY_TAP16_VAL, // Delay Tap Value Input Port
  input [5:0] DLY_TAP17_VAL, // Delay Tap Value Input Port
  input [5:0] DLY_TAP18_VAL, // Delay Tap Value Input Port
  input [5:0] DLY_TAP19_VAL, // Delay Tap Value Input Port
  input [4:0] DLY_ADDR, // Input Address
  output reg [5:0] DLY_TAP_VALUE // Delay Tap Value Output Port
);

always@(*)
begin
    case(DLY_ADDR)
        5'd0:  DLY_TAP_VALUE = DLY_TAP0_VAL;
        5'd1:  DLY_TAP_VALUE = DLY_TAP1_VAL;
        5'd2:  DLY_TAP_VALUE = DLY_TAP2_VAL;
        5'd3:  DLY_TAP_VALUE = DLY_TAP3_VAL;
        5'd4:  DLY_TAP_VALUE = DLY_TAP4_VAL;
        5'd5:  DLY_TAP_VALUE = DLY_TAP5_VAL;
        5'd6:  DLY_TAP_VALUE = DLY_TAP6_VAL;
        5'd7:  DLY_TAP_VALUE = DLY_TAP7_VAL;
        5'd8:  DLY_TAP_VALUE = DLY_TAP8_VAL;
        5'd9:  DLY_TAP_VALUE = DLY_TAP9_VAL;
        5'd10: DLY_TAP_VALUE = DLY_TAP10_VAL;
        5'd11: DLY_TAP_VALUE = DLY_TAP11_VAL;
        5'd12: DLY_TAP_VALUE = DLY_TAP12_VAL;
        5'd13: DLY_TAP_VALUE = DLY_TAP13_VAL;
        5'd14: DLY_TAP_VALUE = DLY_TAP14_VAL;
        5'd15: DLY_TAP_VALUE = DLY_TAP15_VAL;
        5'd16: DLY_TAP_VALUE = DLY_TAP16_VAL;
        5'd17: DLY_TAP_VALUE = DLY_TAP17_VAL;
        5'd18: DLY_TAP_VALUE = DLY_TAP18_VAL;
        5'd19: DLY_TAP_VALUE = DLY_TAP19_VAL;
        default: DLY_TAP_VALUE = 5'd0;
    endcase
end




`ifndef SYNTHESIS  
 `ifdef TIMED_SIM
   specparam T1 = 0.4;

    specify
      if (DLY_ADDR == 5'd0)
      (DLY_TAP0_VAL => DLY_TAP_VALUE)   = T1;
      if (DLY_ADDR == 5'd1)
      (DLY_TAP1_VAL => DLY_TAP_VALUE)   = T1;
      if (DLY_ADDR == 5'd2)
      (DLY_TAP2_VAL => DLY_TAP_VALUE)   = T1;
      if (DLY_ADDR == 5'd3)
      (DLY_TAP3_VAL => DLY_TAP_VALUE)   = T1;
      if (DLY_ADDR == 5'd4)
      (DLY_TAP4_VAL => DLY_TAP_VALUE)   = T1;
      if (DLY_ADDR == 5'd5)
      (DLY_TAP5_VAL => DLY_TAP_VALUE)   = T1;
      if (DLY_ADDR == 5'd6)
      (DLY_TAP6_VAL => DLY_TAP_VALUE)   = T1;
      if (DLY_ADDR == 5'd7)
      (DLY_TAP7_VAL => DLY_TAP_VALUE)   = T1;
      if (DLY_ADDR == 5'd8)
      (DLY_TAP8_VAL => DLY_TAP_VALUE)   = T1;
      if (DLY_ADDR == 5'd9)
      (DLY_TAP9_VAL => DLY_TAP_VALUE)   = T1;
      if (DLY_ADDR == 5'd10)
      (DLY_TAP10_VAL => DLY_TAP_VALUE)   = T1;
      if (DLY_ADDR == 5'd11)
      (DLY_TAP11_VAL => DLY_TAP_VALUE)   = T1;
      if (DLY_ADDR == 5'd12)
      (DLY_TAP12_VAL => DLY_TAP_VALUE)   = T1;
      if (DLY_ADDR == 5'd13)
      (DLY_TAP13_VAL => DLY_TAP_VALUE)   = T1;
      if (DLY_ADDR == 5'd14)
      (DLY_TAP14_VAL => DLY_TAP_VALUE)   = T1;
      if (DLY_ADDR == 5'd15)
      (DLY_TAP15_VAL => DLY_TAP_VALUE)   = T1;
      if (DLY_ADDR == 5'd16)
      (DLY_TAP16_VAL => DLY_TAP_VALUE)   = T1;
      if (DLY_ADDR == 5'd17)
      (DLY_TAP17_VAL => DLY_TAP_VALUE)   = T1;
      if (DLY_ADDR == 5'd18)
      (DLY_TAP18_VAL => DLY_TAP_VALUE)   = T1;
      if (DLY_ADDR == 5'd19)
      (DLY_TAP19_VAL => DLY_TAP_VALUE)   = T1;
    endspecify

  `endif // `ifdef TIMED_SIM  
`endif //  `ifndef SYNTHESIS

endmodule
`endcelldefine
