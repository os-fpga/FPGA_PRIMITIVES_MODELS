`timescale 1ns/1ps
`celldefine
//
// I_DDR simulation model
// DDR input register
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module I_DDR (
  input D, // Data input (connect to input port, buffer or I_DELAY)
  input R, // Active-low asynchrnous reset
  input E, // Active-high enable
  input C, // Clock input
  output reg [1:0] Q = 2'b00 // Data output
);

  always @(negedge R)
    Q <= 2'b00;

  always @(C)
    if (!R)
      Q <= 2'b00;
    else if (E) 
      if (C)
        Q[0] <= D;
      else
        Q[1] <= D;

endmodule
`endcelldefine
