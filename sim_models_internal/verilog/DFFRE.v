`timescale 1ns/1ps
`celldefine
//
// DFFRE simulation model
// Posedge D flipflop with async reset and enable
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

// No prologue needed.
module DFFRE (
  input D, // Data Input
  input R, // Active-low, asynchronous reset
  input E, // Active-high enable
  input C, // Clock
  output reg Q = 1'b0 // Data Output
);

  always @(posedge C, negedge R)
    if (!R)
      Q <= 1'b0;
    else if (E)
      Q <= D;

endmodule
`endcelldefine
