`timescale 1ns/1ps
`celldefine
//
// I_BUF_DS simulation model
// input differential buffer
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module I_BUF_DS #(
      parameter WEAK_KEEPER = "NONE" // Specify Pull-up/Pull-down on input (NONE/PULLUP/PULLDOWN)
) (
  input I_P, // Data positive input (connect to top-level port)
  input I_N, // Data negative input (connect to top-level port)
  input EN, // Enable the input
  output reg O // Data output
);

  generate
    if ( WEAK_KEEPER == "PULLUP" )  begin: add_pullup
      pullup(I_P);
      pullup(I_N);
    end else if ( WEAK_KEEPER == "PULLDOWN" ) begin: add_pulldown
      pulldown(I_P);
      pulldown(I_N);
    end
  endgenerate

  always @(I_P, I_N, EN) begin
    casez ({I_P, I_N, EN})
      3'b??0 : O = 0;      // When not enabled, output is set to zero
      3'b101 : O = 1;
      3'b011 : O = 0;
      default : begin end  // If enabled and I_P and I_N are the same, output does not change
    endcase
  end


 initial begin
    case(WEAK_KEEPER)
      "NONE" ,
      "PULLUP" ,
      "PULLDOWN": begin end
      default: begin
        $display("\nError: I_BUF_DS instance %m has parameter WEAK_KEEPER set to %s.  Valid values are NONE, PULLUP, PULLDOWN\n", WEAK_KEEPER);
        #1 $stop ;
      end
    endcase


  end

endmodule
`endcelldefine
