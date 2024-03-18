`timescale 1ns/1ps
`celldefine
//
// LUT2 simulation model
// 2-input lookup table (LUT)
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module LUT2 #(
  parameter [3:0] INIT_VALUE = 4'h0 // 4-bit LUT logic value
) (
  input [1:0] A, // Data Input
  output Y // Data Output
);

  wire [ 1: 0] s1 = A[1] ? INIT_VALUE[ 3: 2] : INIT_VALUE[ 1: 0];
  assign Y = A[0] ? s1[1] : s1[0];


endmodule
`endcelldefine
