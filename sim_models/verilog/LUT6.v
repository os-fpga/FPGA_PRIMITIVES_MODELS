`timescale 1ns/1ps
`celldefine
//
// LUT6 simulation model
// 6-input lookup table (LUT)
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module LUT6 #(
  parameter [63:0] INIT_VALUE = 64'h0000000000000000 // 64-bit LUT logic value
) (
  input [5:0] A, // Data Input
  output Y // Data Output
);

  assign Y = INIT_VALUE[A] ;


endmodule
`endcelldefine
