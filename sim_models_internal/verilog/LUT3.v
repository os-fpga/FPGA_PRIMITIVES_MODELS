`timescale 1ns/1ps
`celldefine
//
// LUT3 simulation model
// 3-input lookup table (LUT)
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module LUT3 #(
  parameter [7:0] INIT_VALUE = 8'h00 // 8-bit LUT logic value
) (
  input [2:0] A, // Data Input
  output Y // Data Output
);

  wire [ 3: 0] s2 = A[2] ? INIT_VALUE[ 7: 4] : INIT_VALUE[ 3: 0];
  wire [ 1: 0] s1 = A[1] ?   s2[ 3: 2] :   s2[ 1: 0];
  assign Y = A[0] ? s1[1] : s1[0];


endmodule
`endcelldefine
