`timescale 1ns/1ps
`celldefine
//
// SOC_FPGA_INTF_JTAG simulation model
// SOC JTAG connection
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module SOC_FPGA_INTF_JTAG (
  input BOOT_JTAG_TCK, // JTAG TCK
  output reg BOOT_JTAG_TDI = 1'b0, // JTAG TDI
  input BOOT_JTAG_TDO, // JTAG TDO
  output reg BOOT_JTAG_TMS = 1'b0, // JTAG TMS
  output reg BOOT_JTAG_TRSTN = 1'b0, // JTAG TRSTN
  input BOOT_JTAG_EN // JTAG enable
);

endmodule
`endcelldefine
