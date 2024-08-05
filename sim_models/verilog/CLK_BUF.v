`timescale 1ns/1ps
`celldefine
//
// CLK_BUF simulation model
// Global clock buffer
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module CLK_BUF (
  input I, // Clock input
  output O // Clock output
);

   assign O = I ;

   specify
    (I => O) = (0, 0);
   endspecify

   
endmodule
`endcelldefine
