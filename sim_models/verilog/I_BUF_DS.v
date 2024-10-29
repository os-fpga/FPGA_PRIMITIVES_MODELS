`timescale 1ns/1ps
`celldefine
//
// I_BUF_DS simulation model
// input differential buffer
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module I_BUF_DS #(
  parameter WEAK_KEEPER = "NONE", // Specify Pull-up/Pull-down on input (NONE/PULLUP/PULLDOWN)
  parameter IOSTANDARD = "DEFAULT", // IO Standard
  parameter DIFFERENTIAL_TERMINATION = "TRUE" // Enable differential termination
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

`ifndef SYNTHESIS  
  `ifdef TIMED_SIM
    specify
      specparam T1 = 0.5;

      if (EN == 1'b1)
      ( I_P, I_N *> O ) = (T1);

    endspecify
  `endif // `ifdef TIMED_SIM  
`endif //  `ifndef SYNTHESIS

   initial begin
    case(WEAK_KEEPER)
      "NONE" ,
      "PULLUP" ,
      "PULLDOWN": begin end
      default: begin
        $fatal(1,"\nError: I_BUF_DS instance %m has parameter WEAK_KEEPER set to %s.  Valid values are NONE, PULLUP, PULLDOWN\n", WEAK_KEEPER);
      end
    endcase
    case(IOSTANDARD)
      "DEFAULT" ,
      "BLVDS_DIFF" ,
      "LVDS_HP_DIFF" ,
      "LVDS_HR_DIFF" ,
      "LVPECL_25_DIFF" ,
      "LVPECL_33_DIFF" ,
      "HSTL_12_DIFF" ,
      "HSTL_15_DIFF" ,
      "HSUL_12_DIFF" ,
      "MIPI_DIFF" ,
      "POD_12_DIFF" ,
      "RSDS_DIFF" ,
      "SLVS_DIFF" ,
      "SSTL_15_DIFF" ,
      "SSTL_18_HP_DIFF" ,
      "SSTL_18_HR_DIFF": begin end
      default: begin
        $fatal(1,"\nError: I_BUF_DS instance %m has parameter IOSTANDARD set to %s.  Valid values are DEFAULT, BLVDS_DIFF, LVDS_HP_DIFF, LVDS_HR_DIFF, LVPECL_25_DIFF, LVPECL_33_DIFF, HSTL_12_DIFF, HSTL_15_DIFF, HSUL_12_DIFF, MIPI_DIFF, POD_12_DIFF, RSDS_DIFF, SLVS_DIFF, SSTL_15_DIFF, SSTL_18_HP_DIFF, SSTL_18_HR_DIFF\n", IOSTANDARD);
      end
    endcase
    case(DIFFERENTIAL_TERMINATION)
      "TRUE" ,
      "FALSE": begin end
      default: begin
        $fatal(1,"\nError: I_BUF_DS instance %m has parameter DIFFERENTIAL_TERMINATION set to %s.  Valid values are TRUE, FALSE\n", DIFFERENTIAL_TERMINATION);
      end
    endcase

  end

endmodule
`endcelldefine
