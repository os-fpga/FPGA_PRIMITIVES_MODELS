`timescale 1ns/1ps
`celldefine
//
// O_BUF simulation model
// Output buffer
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module O_BUF
`ifdef RAPIDSILICON_INTERNAL
    #(
  parameter IOSTANDARD = "DEFAULT", // IO Standard
  parameter DRIVE_STRENGTH = 2, // Drive strength in mA for LVCMOS standards
  parameter SLEW_RATE = "SLOW" // Transition rate for LVCMOS standards
)
`endif // RAPIDSILICON_INTERNAL
(
  input I, // Data input
  output O // Data output (connect to top-level port)
);

   assign O = I ;
 initial begin

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
        $display("\nError: O_BUF instance %m has parameter IOSTANDARD set to %s.  Valid values are DEFAULT, LVCMOS_12, LVCMOS_15, LVCMOS_18_HP, LVCMOS_18_HR, LVCMOS_25, LVCMOS_33, LVTTL, HSTL_I_12, HSTL_II_12, HSTL_I_15, HSTL_II_15, HSUL_12, PCI66, PCIX133, POD_12, SSTL_I_15, SSTL_II_15, SSTL_I_18_HP, SSTL_II_18_HP, SSTL_I_18_HR, SSTL_II_18_HR, SSTL_I_25, SSTL_II_25, SSTL_I_33, SSTL_II_33\n", IOSTANDARD);
        #1 $stop ;
      end
    endcase

    case(DRIVE_STRENGTH)
      2 ,
      4 ,
      6 ,
      8 ,
      12 ,
      16: begin end
      default: begin
        $display("\nError: O_BUF instance %m has parameter DRIVE_STRENGTH set to %s.  Valid values are 2, 4, 6, 8, 12, 16\n", DRIVE_STRENGTH);
        #1 $stop ;
      end
    endcase

    case(SLEW_RATE)
      "SLOW" ,
      "FAST": begin end
      default: begin
        $display("\nError: O_BUF instance %m has parameter SLEW_RATE set to %s.  Valid values are SLOW, FAST\n", SLEW_RATE);
        #1 $stop ;
      end
    endcase
`endif // RAPIDSILICON_INTERNAL

  end

endmodule
`endcelldefine
