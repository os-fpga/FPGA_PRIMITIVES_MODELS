`timescale 1ns/1ps
`celldefine
//
// O_BUF_DS simulation model
// Output differential buffer
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module O_BUF_DS
#(
  parameter IOSTANDARD = "DEFAULT", // IO Standard
  parameter DIFFERENTIAL_TERMINATION = "TRUE" // Enable differential termination
)
(
  input I, // Data input
  output O_P, // Data positive output (connect to top-level port)
  output O_N // Data negative output (connect to top-level port)
);

    assign O_P = I;
    assign O_N = ~I;
    
    `ifndef SYNTHESIS  
        `ifdef TIMED_SIM
          specparam T1 = 0.5;
        
          specify
            (I => O_P) = (T1);
            (I => O_N) = (T1);
          endspecify
      
        `endif // `ifdef TIMED_SIM  
    `endif //  `ifndef SYNTHESIS


     initial begin

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
        $fatal(1,"\nError: O_BUF_DS instance %m has parameter IOSTANDARD set to %s.  Valid values are DEFAULT, BLVDS_DIFF, LVDS_HP_DIFF, LVDS_HR_DIFF, LVPECL_25_DIFF, LVPECL_33_DIFF, HSTL_12_DIFF, HSTL_15_DIFF, HSUL_12_DIFF, MIPI_DIFF, POD_12_DIFF, RSDS_DIFF, SLVS_DIFF, SSTL_15_DIFF, SSTL_18_HP_DIFF, SSTL_18_HR_DIFF\n", IOSTANDARD);
      end
    endcase

    case(DIFFERENTIAL_TERMINATION)
      "TRUE" ,
      "FALSE": begin end
      default: begin
        $fatal(1,"\nError: O_BUF_DS instance %m has parameter DIFFERENTIAL_TERMINATION set to %s.  Valid values are TRUE, FALSE\n", DIFFERENTIAL_TERMINATION);
      end
    endcase

  end

endmodule
`endcelldefine
