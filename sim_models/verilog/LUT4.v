`timescale 1ns/1ps
`celldefine
//
// LUT4 simulation model
// 4-input lookup table (LUT)
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

  
module LUT4 #(
  parameter [15:0] INIT_VALUE = 16'h0000 // 16-bit LUT logic value
) (
  input [3:0] A, // Data Input
  output Y // Data Output
);

  assign Y = INIT_VALUE[A] ;


endmodule
`endcelldefine
