`timescale 1ps/1ps
`celldefine
//
// DLY_VALUE_MUX simulation model
// Multiplexer
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module DLY_VALUE_MUX (
  input [5:0] DLY_TAP_VAL_ARRAY[19:0], // 20 Delay Tap Value Input Ports
  input [4:0] DLY_ADDR, // Input Address
  output [5:0] DLY_TAP_VALUE // Delay Tap Value Output Port
);

assign DLY_TAP_VALUE= (DLY_ADDR<20)?DLY_TAP_VAL_ARRAY[DLY_ADDR]:5'd0;

endmodule
`endcelldefine
