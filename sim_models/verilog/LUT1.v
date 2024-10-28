`timescale 1ns/1ps
`celldefine
//
// LUT1 simulation model
// 1-input lookup table (LUT)
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module LUT1 #(
  parameter [1:0] INIT_VALUE = 2'h0 // 2-bit LUT logic value
) (
  input A, // Data Input
  output Y // Data Output
);

  assign Y = A ? INIT_VALUE[1] : INIT_VALUE[0];

  `ifndef SYNTHESIS  
    `ifdef TIMED_SIM
      specparam T1 = 0.5;

        specify
          (A => Y) = (T1);
        endspecify
    `endif // `ifdef TIMED_SIM  
  `endif //  `ifndef SYNTHESIS


endmodule
`endcelldefine
