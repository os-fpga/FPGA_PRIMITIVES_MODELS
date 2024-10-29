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

   `ifndef SYNTHESIS  
    `ifdef TIMED_SIM
      specparam T1 = 0.5;
       specify
         (I => O) = (T1);
       endspecify
    
    `endif // `ifdef TIMED_SIM  
   `endif //  `ifndef SYNTHESIS


   
endmodule
`endcelldefine
