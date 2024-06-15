`timescale 1ns/1ps
`celldefine
//
// I_DDR simulation model
// DDR input register
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module I_DDR (
  input D, // Data input (connect to input port, buffer or I_DELAY)
  input R, // Active-low asynchrnous reset
  input E, // Active-high enable
  input C, // Clock input
  output reg [1:0] Q = 2'b00 // Data output
);

  reg data_pos;
  reg data_neg;

  always @(negedge R)
  begin
    Q <= 2'b00;
    data_pos<=2'b00;
    data_neg<=2'b00;
  end

  always@(posedge C)
  begin
    if(!R)
      data_pos<=0;
    else
      data_pos<=D;
  end

  always@(negedge C)
  begin
    if(!R)
      data_neg<=0;
    else
      data_neg<=D;
  end

  always @(posedge C) 
  begin
    if(!R)
      Q<=0;
    else if(E)
    begin
      Q[1]<=data_pos;
      Q[0]<=data_neg;
    end
    
  end

endmodule
`endcelldefine
