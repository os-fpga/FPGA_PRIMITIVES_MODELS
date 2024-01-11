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

  assign Y = INIT_VALUE[A] ;


endmodule
`endcelldefine
