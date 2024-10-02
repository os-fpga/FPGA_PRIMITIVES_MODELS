`timescale 1ps/1ps
`celldefine
//
// DLY_SEL_DCODER simulation model
// Address Decoder
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module DLY_SEL_DCODER (
  input DLY_LOAD, // Delay load input
  input DLY_ADJ, // Delay adjust input
  input DLY_INCDEC, // Delay increment / decrement input
  input [4:0] DLY_ADDR, // Input Address
  output reg [2:0] DLY_CNTRL[31:0] // Output Bus
);


always @(*) 
begin
  for(integer i=0; i<32;i=i+1)
  begin
    DLY_CNTRL[i] = 3'b000;
  end
  if (DLY_ADDR < 5'd20) 
  begin
    DLY_CNTRL[DLY_ADDR] = {DLY_LOAD, DLY_ADJ, DLY_INCDEC};
  end
end


endmodule
`endcelldefine
