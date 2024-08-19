`timescale 1ns/1ps
`celldefine
//
// FCLK_BUF simulation model
// Clock buffer for routing logic signal to the global clock
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module FCLK_BUF (
  input I, // Clock input
  output O // Clock output
);

   assign O = I ;

  `ifndef SYNTHESIS
      specify
       (I => O) = (0, 0);
      endspecify
  `endif //  `ifndef SYNTHESIS
   

endmodule
`endcelldefine
