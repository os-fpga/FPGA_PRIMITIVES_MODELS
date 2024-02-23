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

  //assign Y = INIT_VALUE[A] ;
  \$bmux #(.WIDTH(1), .S_WIDTH(2)) mux(.A(INIT_VALUE), .S(A), .Y(Y));


endmodule
`endcelldefine

