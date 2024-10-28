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
    else
      Q<=Q;
    
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
       (negedge R => (Q[0] +: 0)) = (T1, T2);
       (negedge R => (Q[1] +: 0)) = (T1, T2);

       (posedge C => (Q[1]+:D)) = (T1, T2);
       (negedge C => (Q[0]+:D)) = (T1, T2);



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
