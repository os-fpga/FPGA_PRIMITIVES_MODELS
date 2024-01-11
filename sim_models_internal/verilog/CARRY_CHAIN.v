`timescale 1ns/1ps
`celldefine
//
// CARRY_CHAIN simulation model
// FLE carry logic
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module CARRY_CHAIN (
  input P, // Partial data input
  input G, // Partial data input
  input CIN, // Carry in
  output O, // Data Output
  output COUT // Carry out
);

  assign {COUT, O} = {P ? CIN : G, P ^ CIN};
endmodule
`endcelldefine
