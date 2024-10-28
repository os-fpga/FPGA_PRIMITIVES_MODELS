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
    `ifdef TIMED_SIM
    
     specparam T1 = 0.3;
      specify
        (I => O) = T1;
      endspecify
     
    `endif // `ifdef TIMED_SIM  
   `endif //  `ifndef SYNTHESIS
 
endmodule
`endcelldefine
