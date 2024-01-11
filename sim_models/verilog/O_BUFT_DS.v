`timescale 1ns/1ps
`celldefine
//
// O_BUFT_DS simulation model
// Output differential tri-state buffer
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module O_BUFT_DS #(
      parameter WEAK_KEEPER = "NONE" // Enable pull-up/pull-down on output (NONE/PULLUP/PULLDOWN)
) (
  input I, // Data input
  input T, // Tri-state output
  output O_P, // Data positive output (connect to top-level port)
  output O_N // Data negative output (connect to top-level port)
);
  
  generate
    if ( WEAK_KEEPER == "PULLUP" )  begin: add_pullup
      pullup(O_P);
      pullup(O_N);
    end else if ( WEAK_KEEPER == "PULLDOWN" ) begin: add_pulldown
      pulldown(O_P);
      pulldown(O_N);
    end
  endgenerate

  assign O_P = T ? I  : 'hz;
  assign O_N = T ? ~I : 'hz;

   initial begin
    case(WEAK_KEEPER)
      "NONE" ,
      "PULLUP" ,
      "PULLDOWN": begin end
      default: begin
        $display("\nError: O_BUFT_DS instance %m has parameter WEAK_KEEPER set to %s.  Valid values are NONE, PULLUP, PULLDOWN\n", WEAK_KEEPER);
        #1 $stop ;
      end
    endcase


  end

endmodule
`endcelldefine
