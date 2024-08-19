`timescale 1ns/1ps
`celldefine
//
// DFFNRE simulation model
// Negedge D flipflop with async reset and enable
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

// No prologue needed.
module DFFNRE (
  input D, // Data Input
  input R, // Active-low, asynchronous reset
  input E, // Active-high enable
  input C, // Negedge clock
  output reg Q = 1'b0 // Data Output
);

  always @(negedge C, negedge R)
    if (!R)
      Q <= 1'b0;
    else if (E)
      Q <= D;

  `ifndef SYNTHESIS
    wire C_D_SDFCHK;
    wire C_nD_SDFCHK;
    wire nC_D_SDFCHK;
    wire nC_nD_SDFCHK;
    wire R_D_SDFCHK;
    wire R_nD_SDFCHK;
    wire R_SDFCHK;
    wire D_SDFCHK;

    assign C_D_SDFCHK   = C & D;
    assign C_nD_SDFCHK  = C & !D;
    assign nC_D_SDFCHK  = !C & D;
    assign nC_nD_SDFCHK = !C & !D;
    assign R_D_SDFCHK   = R & D;
    assign R_nD_SDFCHK  = R & !D; 
    assign R_SDFCHK     = R;
    assign D_SDFCHK     = D;


    specify
      if (C == 1'b1 && D == 1'b1 && E == 1'b0)
      (negedge R => (Q+:1'b0)) = (0, 0);
      if (C == 1'b1 && D == 1'b0 && E == 1'b0)
      (negedge R => (Q+:1'b0)) = (0, 0);
      if (C == 1'b0 && D == 1'b1 && E == 1'b0)
      (negedge R => (Q+:1'b0)) = (0, 0);
      if (C == 1'b0 && D == 1'b0 && E == 1'b0)
      (negedge R => (Q+:1'b0)) = (0, 0);
      if (C == 1'b1 && D == 1'b1 && E == 1'b1)
      (negedge R => (Q+:1'b0)) = (0, 0);
      if (C == 1'b1 && D == 1'b0 && E == 1'b1)
      (negedge R => (Q+:1'b0)) = (0, 0);
      if (C == 1'b0 && D == 1'b1 && E == 1'b1)
      (negedge R => (Q+:1'b0)) = (0, 0);
      if (C == 1'b0 && D == 1'b0 && E == 1'b1)
      (negedge R => (Q+:1'b0)) = (0, 0);
      (negedge C => (Q+:D)) = (0, 0);

      $width (negedge R &&& C_D_SDFCHK, 0, 0, notifier);
      $width (negedge R &&& C_nD_SDFCHK, 0, 0, notifier);
      $width (negedge R &&& nC_D_SDFCHK, 0, 0, notifier);
      $width (negedge R &&& nC_nD_SDFCHK, 0, 0, notifier);
      $width (posedge C &&& R_D_SDFCHK, 0, 0, notifier);
      $width (negedge C &&& R_D_SDFCHK, 0, 0, notifier);
      $width (posedge C &&& R_nD_SDFCHK, 0, 0, notifier);
      $width (negedge C &&& R_nD_SDFCHK, 0, 0, notifier);

      $setuphold (negedge C &&& R_SDFCHK, posedge D , 0, 0, notifier);
      $setuphold (negedge C &&& R_SDFCHK, negedge D , 0, 0, notifier);
      $recovery (posedge R &&& D_SDFCHK, negedge C &&& D_SDFCHK, 0, notifier);
      $hold (negedge C &&& D_SDFCHK, posedge R , 0, notifier);
    endspecify
  `endif //  `ifndef SYNTHESIS

endmodule
`endcelldefine
