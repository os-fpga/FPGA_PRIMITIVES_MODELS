`timescale 1ns/1ps
`celldefine
//
// LUT5 simulation model
// 5-input lookup table (LUT)
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module LUT5 #(
  parameter [31:0] INIT_VALUE = 32'h00000000 // LUT logic value
) (
  input [4:0] A, // Data Input
  output Y // Data Output
);

  wire [15: 0] s4 = A[4] ? INIT_VALUE[31:16] : INIT_VALUE[15: 0];
  wire [ 7: 0] s3 = A[3] ?   s4[15: 8] :   s4[ 7: 0];
  wire [ 3: 0] s2 = A[2] ?   s3[ 7: 4] :   s3[ 3: 0];
  wire [ 1: 0] s1 = A[1] ?   s2[ 3: 2] :   s2[ 1: 0];
  assign Y = A[0] ? s1[1] : s1[0];


endmodule
`endcelldefine
