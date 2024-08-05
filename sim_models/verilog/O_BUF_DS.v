`timescale 1ns/1ps
`celldefine
//
// O_BUF_DS simulation model
// Output differential buffer
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module O_BUF_DS
(
  input I, // Data input
  output O_P, // Data positive output (connect to top-level port)
  output O_N // Data negative output (connect to top-level port)
);

    assign O_P = I;
    assign O_N = ~I;
    
 initial begin


  end

endmodule
`endcelldefine
