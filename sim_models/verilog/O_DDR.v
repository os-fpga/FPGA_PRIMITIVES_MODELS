`timescale 1ns/1ps
`celldefine
//
// O_DDR simulation model
// DDR output register
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module O_DDR (
  input [1:0] D, // Data input
  input R, // Active-low asynchrnous reset
  input E, // Active-high enable
  input C, // Clock
  output reg Q = 1'b0 // Data output (connect to output port, buffer or O_DELAY)
);

  always @(negedge R)
    Q <= 1'b0;

  always @(C)
    if (!R)
      Q <= 1'b0;
    else if (E) 
      if (C)
        Q <= D[0];
      else
        Q <= D[1];

endmodule
`endcelldefine
