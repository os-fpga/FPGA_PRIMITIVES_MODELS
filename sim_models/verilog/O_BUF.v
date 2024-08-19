`timescale 1ns/1ps
`celldefine
//
// O_BUF simulation model
// Output buffer
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module O_BUF
#(
  parameter IOSTANDARD = "DEFAULT", // IO Standard
  parameter DRIVE_STRENGTH = 2, // Drive strength in mA for LVCMOS standards
  parameter SLEW_RATE = "SLOW" // Transition rate for LVCMOS standards
)
(
  input I, // Data input
  output O // Data output (connect to top-level port)
);

   assign O = I ;

  `ifndef SYNTHESIS
      specify
       (I => O) = (0, 0);
      endspecify
  `endif //  `ifndef SYNTHESIS
 initial begin

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
        $fatal(1,"\nError: O_BUF instance %m has parameter IOSTANDARD set to %s.  Valid values are DEFAULT, LVCMOS_12, LVCMOS_15, LVCMOS_18_HP, LVCMOS_18_HR, LVCMOS_25, LVCMOS_33, LVTTL, HSTL_I_12, HSTL_II_12, HSTL_I_15, HSTL_II_15, HSUL_12, PCI66, PCIX133, POD_12, SSTL_I_15, SSTL_II_15, SSTL_I_18_HP, SSTL_II_18_HP, SSTL_I_18_HR, SSTL_II_18_HR, SSTL_I_25, SSTL_II_25, SSTL_I_33, SSTL_II_33\n", IOSTANDARD);
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
        $fatal(1,"\nError: O_BUF instance %m has parameter DRIVE_STRENGTH set to %s.  Valid values are 2, 4, 6, 8, 12, 16\n", DRIVE_STRENGTH);
      end
    endcase

    case(SLEW_RATE)
      "SLOW" ,
      "FAST": begin end
      default: begin
        $fatal(1,"\nError: O_BUF instance %m has parameter SLEW_RATE set to %s.  Valid values are SLOW, FAST\n", SLEW_RATE);
      end
    endcase

  end

endmodule
`endcelldefine
