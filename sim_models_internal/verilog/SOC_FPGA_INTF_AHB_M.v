`timescale 1ns/1ps
`celldefine
//
// SOC_FPGA_INTF_AHB_M simulation model
// SOC interface connection AHB Master
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module SOC_FPGA_INTF_AHB_M (
  input HRESETN_I, // None
  input [31:0] HADDR, // None
  input [2:0] HBURST, // None
  input [3:0] HPROT, // None
  input [2:0] HSIZE, // None
  input [2:0] HTRANS, // None
  input [31:0] HWDATA, // None
  input HWWRITE, // None
  output [31:0] HRDATA, // None
  output HREADY, // None
  output HRESP, // None
  input HCLK // None
);

endmodule
`endcelldefine
