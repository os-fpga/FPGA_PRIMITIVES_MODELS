`timescale 1ns/1ps
`celldefine
//
// O_BUF_DS simulation model
// Output differential buffer
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module O_BUF_DS
`ifdef RAPIDSILICON_INTERNAL
    #(
  parameter IOSTANDARD = "DEFAULT", // IO Standard
  parameter DIFFERENTIAL_TERMINATION = "TRUE" // Enable differential termination
)
`endif // RAPIDSILICON_INTERNAL
(
  input I, // Data input
  output O_P, // Data positive output (connect to top-level port)
  output O_N // Data negative output (connect to top-level port)
);

    assign O_P = I;
    assign O_N = ~I;
    
 initial begin

`ifdef RAPIDSILICON_INTERNAL

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
        $display("\nError: O_BUF_DS instance %m has parameter IOSTANDARD set to %s.  Valid values are DEFAULT, BLVDS_DIFF, LVDS_HP_DIFF, LVDS_HR_DIFF, LVPECL_25_DIFF, LVPECL_33_DIFF, HSTL_12_DIFF, HSTL_15_DIFF, HSUL_12_DIFF, MIPI_DIFF, POD_12_DIFF, RSDS_DIFF, SLVS_DIFF, SSTL_15_DIFF, SSTL_18_HP_DIFF, SSTL_18_HR_DIFF\n", IOSTANDARD);
        #1 $stop ;
      end
    endcase

    case(DIFFERENTIAL_TERMINATION)
      "TRUE" ,
      "FALSE": begin end
      default: begin
        $display("\nError: O_BUF_DS instance %m has parameter DIFFERENTIAL_TERMINATION set to %s.  Valid values are TRUE, FALSE\n", DIFFERENTIAL_TERMINATION);
        #1 $stop ;
      end
    endcase
`endif // RAPIDSILICON_INTERNAL

  end

endmodule
`endcelldefine
