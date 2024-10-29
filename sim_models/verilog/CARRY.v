`timescale 1ns/1ps
`celldefine
//
// CARRY simulation model
// FLE carry logic
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module CARRY (
  input P, // Partial data input
  input G, // Partial data input
  input CIN, // Carry in
  output O, // Data output
  output COUT // Carry out
);

assign {COUT, O} = {P ? CIN : G, P ^ CIN};

`ifndef SYNTHESIS  
 `ifdef TIMED_SIM
 
   specparam T1 = 0.3;
   specparam T2 = 0.4;


    specify
    
      if (P == 1'b1)
      (CIN => COUT) = (T1, T2);
      if (P == 1'b0)
      (G => COUT) = (T1, T2);

      ( P, CIN *> O ) = (T1, T2);

    endspecify

  `endif // `ifdef TIMED_SIM  
`endif //  `ifndef SYNTHESIS
    
endmodule
`endcelldefine
