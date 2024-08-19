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
    specify

      if (P == 1'b1)
      (CIN => COUT) = (0, 0);
      if (P == 1'b0)
      (G => COUT) = (0, 0);

      ( P, CIN *> O ) = (0, 0);

    endspecify
  `endif //  `ifndef SYNTHESIS

endmodule
`endcelldefine
