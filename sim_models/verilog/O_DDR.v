`timescale 1ns/1ps
`celldefine
//
// O_DDR simulation model
// DDR output register
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module O_DDR (
  input [1:0] D, // Data input
  input R, // Active-low asynchrnous reset
  input E, // Active-high enable
  input C, // Clock
  output reg Q = 1'b0 // Data output (connect to output port, buffer or O_DELAY)
);

  reg Q0;
  reg Qp;
  reg Q1;

  always @(negedge R)
    Q <= 1'b0;

  always@(posedge C)
  begin
    if(!R)
    begin
      Qp<=0;
      Q0<=0;
    end

    else 
    begin
      Q0<=D[0];
      Qp<=D[1];
    end
  end

  always@(negedge C)
  begin
    if(!R)
      Q1<=0;
    else
      Q1<=Qp;
  end

  
  always @(*)
  begin
    if (!R)
      Q <= 1'b0;
    else if (E) 
      if (C)
        Q <= Q0;
      else
        Q <= Q1;
    else
      Q <= Q;
  end
  

`ifndef SYNTHESIS  
  `ifdef TIMED_SIM
 
    specparam T1 = 0.2;
    specparam T2 = 0.3;
    specparam T3 = 5;
    specparam T4 = 0.3;
    specparam T5 = 0.3;
 
     specify
   
 
      (C => Q) = (T3);
      (negedge R => (Q +: 0)) = (T1, T2);
 
      (posedge C => (Q+:D[0])) = (T1, T2);
      (negedge C => (Q+:D[1])) = (T1, T2);
 
 
 
      $setuphold (negedge C, negedge E  , T4, T5, notifier2);
      $setuphold (negedge C, negedge D  , T4, T5, notifier2);
      $setuphold (negedge C, negedge R  , T4, T5, notifier2);
      $setuphold (negedge C, posedge E  , T4, T5, notifier2);
      $setuphold (negedge C, posedge D  , T4, T5, notifier2);
      $setuphold (negedge C, posedge R  , T4, T5, notifier2);
      $setuphold (posedge C, negedge E  , T4, T5, notifier1);
      $setuphold (posedge C, negedge D  , T4, T5, notifier1);
      $setuphold (posedge C, negedge R  , T4, T5, notifier1);
      $setuphold (posedge C, posedge E  , T4, T5, notifier1);
      $setuphold (posedge C, posedge D  , T4, T5, notifier1);
      $setuphold (posedge C, posedge R  , T4, T5, notifier1);
 
 
     endspecify
 
   `endif // `ifdef TIMED_SIM  
 `endif //  `ifndef SYNTHESIS
 
 
endmodule
`endcelldefine
