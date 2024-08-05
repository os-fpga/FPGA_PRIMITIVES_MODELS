`timescale 1ns/1ps
`celldefine
//
// O_BUF simulation model
// Output buffer
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module O_BUF
(
  input I, // Data input
  output O // Data output (connect to top-level port)
);

   assign O = I ;
 initial begin


  end

endmodule
`endcelldefine
