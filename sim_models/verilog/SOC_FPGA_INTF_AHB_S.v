`timescale 1ns/1ps
`celldefine
//
// SOC_FPGA_INTF_AHB_S simulation model
// SOC interface connection AHB Slave
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module SOC_FPGA_INTF_AHB_S (
  output HRESETN_I, // None
  output [31:0] HADDR, // None
  output [2:0] HBURST, // None
  output HMASTLOCK, // None
  input HREADY, // None
  output [3:0] HPROT, // None
  input [31:0] HRDATA, // None
  input HRESP, // None
  output HSEL, // None
  output [2:0] HSIZE, // None
  output [1:0] HTRANS, // None
  output [3:0] HWBE, // None
  output [31:0] HWDATA, // None
  output HWRITE, // None
  input HCLK // None
);

endmodule
`endcelldefine
