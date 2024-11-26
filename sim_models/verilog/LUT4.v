`timescale 1ns/1ps
`celldefine
//
// LUT4 simulation model
// 4-input lookup table (LUT)
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

  
module LUT4 #(
  parameter [15:0] INIT_VALUE = 16'h0000 // 16-bit LUT logic value
) (
  input [3:0] A, // Data Input
  output Y // Data Output
);

  wire [ 7: 0] s3 = A[3] ? INIT_VALUE[15: 8] : INIT_VALUE[ 7: 0];
  wire [ 3: 0] s2 = A[2] ?   s3[ 7: 4] :   s3[ 3: 0];
  wire [ 1: 0] s1 = A[1] ?   s2[ 3: 2] :   s2[ 1: 0];

  assign Y = A[0] ? s1[1] : s1[0];


  `ifndef SYNTHESIS  
    `ifdef TIMED_SIM
      specparam T1 = 0.5;

        specify
          (A *> Y) = (T1);
        endspecify
    `endif // `ifdef TIMED_SIM  
  `endif //  `ifndef SYNTHESIS
        
endmodule
`endcelldefine
