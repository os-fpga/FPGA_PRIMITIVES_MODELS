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
`ifdef RAPIDSILICON_INTERNAL
    ,  parameter IOSTANDARD = "DEFAULT" // IO Standard
`endif // RAPIDSILICON_INTERNAL
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

`ifdef RAPIDSILICON_INTERNAL

    case(IOSTANDARD)
      "DEFAULT" ,
      "LVCMOS_12" ,
      "LVCMOS_15" ,
      "LVCMOS_18_HP" ,
      "LVCMOS_18_HR" ,
      "LVCMOS_25" ,
      "LVCMOS_33" ,
      "LVTTL" ,
      "HSTL_I_12" ,
      "HSTL_II_12" ,
      "HSTL_I_15" ,
      "HSTL_II_15" ,
      "HSUL_12" ,
      "PCI66" ,
      "PCIX133" ,
      "POD_12" ,
      "SSTL_I_15" ,
      "SSTL_II_15" ,
      "SSTL_I_18_HP" ,
      "SSTL_II_18_HP" ,
      "SSTL_I_18_HR" ,
      "SSTL_II_18_HR" ,
      "SSTL_I_25" ,
      "SSTL_II_25" ,
      "SSTL_I_33" ,
      "SSTL_II_33": begin end
      default: begin
        $display("\nError: I_BUF instance %m has parameter IOSTANDARD set to %s.  Valid values are DEFAULT, LVCMOS_12, LVCMOS_15, LVCMOS_18_HP, LVCMOS_18_HR, LVCMOS_25, LVCMOS_33, LVTTL, HSTL_I_12, HSTL_II_12, HSTL_I_15, HSTL_II_15, HSUL_12, PCI66, PCIX133, POD_12, SSTL_I_15, SSTL_II_15, SSTL_I_18_HP, SSTL_II_18_HP, SSTL_I_18_HR, SSTL_II_18_HR, SSTL_I_25, SSTL_II_25, SSTL_I_33, SSTL_II_33\n", IOSTANDARD);
        #1 $stop ;
      end
    endcase
`endif // RAPIDSILICON_INTERNAL

  end

endmodule
`endcelldefine
