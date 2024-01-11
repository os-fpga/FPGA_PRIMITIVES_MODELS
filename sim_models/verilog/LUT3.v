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

  assign Y = INIT_VALUE[A] ;


endmodule
`endcelldefine
