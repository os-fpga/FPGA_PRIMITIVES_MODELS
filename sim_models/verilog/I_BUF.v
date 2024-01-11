`timescale 1ns/1ps
`celldefine
//
// I_BUF simulation model
// Input buffer
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module I_BUF #(
      parameter WEAK_KEEPER = "NONE" // Specify Pull-up/Pull-down on input (NONE/PULLUP/PULLDOWN)
) (
  input I, // Data input (connect to top-level port)
  input EN, // Enable the input
  output O // Data output
);
  generate
    if ( WEAK_KEEPER == "PULLUP" )  begin: add_pullup
      pullup(I);
    end else if ( WEAK_KEEPER == "PULLDOWN" ) begin: add_pulldown
      pulldown(I);
    end
  endgenerate

  assign O = EN ? I : 1'b0;


 initial begin
    case(WEAK_KEEPER)
      "NONE" ,
      "PULLUP" ,
      "PULLDOWN": begin end
      default: begin
        $display("\nError: I_BUF instance %m has parameter WEAK_KEEPER set to %s.  Valid values are NONE, PULLUP, PULLDOWN\n", WEAK_KEEPER);
        #1 $stop ;
      end
    endcase


  end

endmodule
`endcelldefine
