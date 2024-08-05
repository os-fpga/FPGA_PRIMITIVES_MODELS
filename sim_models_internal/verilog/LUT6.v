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

  wire [31: 0] s5 = A[5] ? INIT_VALUE[63:32] : INIT_VALUE[31: 0];
  wire [15: 0] s4 = A[4] ?   s5[31:16] :   s5[15: 0];
  wire [ 7: 0] s3 = A[3] ?   s4[15: 8] :   s4[ 7: 0];
  wire [ 3: 0] s2 = A[2] ?   s3[ 7: 4] :   s3[ 3: 0];
  wire [ 1: 0] s1 = A[1] ?   s2[ 3: 2] :   s2[ 1: 0];
  assign Y = A[0] ? s1[1] : s1[0];


endmodule
`endcelldefine
