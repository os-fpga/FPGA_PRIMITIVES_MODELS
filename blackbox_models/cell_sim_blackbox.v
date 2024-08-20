//
// BOOT_CLOCK black box model
// Internal BOOT_CLK connection
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module BOOT_CLOCK #(
  parameter PERIOD = 25 // Clock period for simulation purposes (nS)
  ) (
  output reg O
);
endmodule
`endcelldefine
//
// CARRY black box model
// FLE carry logic
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module CARRY (
  input logic P,
  input logic G,
  input logic CIN,
  output logic O,
  output logic COUT
);
endmodule
`endcelldefine
//
// CLK_BUF black box model
// Global clock buffer
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module CLK_BUF (
  input logic I,
  (* clkbuf_driver *)
  output logic O
);
endmodule
`endcelldefine
//
// DFFNRE black box model
// Negedge D flipflop with async reset and enable
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module DFFNRE (
  input logic D,
  input logic R,
  input logic E,
  (* clkbuf_sink *)
  input logic C,
  output reg Q
);
endmodule
`endcelldefine
//
// DFFRE black box model
// Posedge D flipflop with async reset and enable
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module DFFRE (
  input logic D,
  input logic R,
  input logic E,
  (* clkbuf_sink *)
  input logic C,
  output reg Q
);
endmodule
`endcelldefine
//
// DSP19X2 black box model
// Paramatizable dual 10x9-bit multiplier accumulator
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module DSP19X2 #(
  parameter DSP_MODE = "MULTIPLY_ACCUMULATE", // DSP arithmetic mode (MULTIPLY/MULTIPLY_ACCUMULATE)
  parameter [9:0] COEFF1_0 = 10'h000, // Multiplier 1 10-bit A input coefficient 0
  parameter [9:0] COEFF1_1 = 10'h000, // Multiplier 1 10-bit A input coefficient 1
  parameter [9:0] COEFF1_2 = 10'h000, // Multiplier 1 10-bit A input coefficient 2
  parameter [9:0] COEFF1_3 = 10'h000, // Multiplier 1 10-bit A input coefficient 3
  parameter [9:0] COEFF2_0 = 10'h000, // Multiplier 2 10-bit A input coefficient 0
  parameter [9:0] COEFF2_1 = 10'h000, // Multiplier 2 10-bit A input coefficient 1
  parameter [9:0] COEFF2_2 = 10'h000, // Multiplier 2 10-bit A input coefficient 2
  parameter [9:0] COEFF2_3 = 10'h000, // Multiplier 2 10-bit A input coefficient 3
  parameter OUTPUT_REG_EN = "TRUE", // Enable output register (TRUE/FALSE)
  parameter INPUT_REG_EN = "TRUE" // Enable input register (TRUE/FALSE)
  ) (
  input logic [9:0] A1,
  input logic [8:0] B1,
  output logic [18:0] Z1,
  output logic [8:0] DLY_B1,
  input logic [9:0] A2,
  input logic [8:0] B2,
  output logic [18:0] Z2,
  output logic [8:0] DLY_B2,
  (* clkbuf_sink *)
  input logic CLK,
  input logic RESET,
  input logic [4:0] ACC_FIR,
  input logic [2:0] FEEDBACK,
  input logic LOAD_ACC,
  input logic UNSIGNED_A,
  input logic UNSIGNED_B,
  input logic SATURATE,
  input logic [4:0] SHIFT_RIGHT,
  input logic ROUND,
  input logic SUBTRACT
);
endmodule
`endcelldefine
//
// DSP38 black box model
// Paramatizable 20x18-bit multiplier accumulator
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module DSP38 #(
  parameter DSP_MODE = "MULTIPLY_ACCUMULATE", // DSP arithmetic mode (MULTIPLY/MULTIPLY_ADD_SUB/MULTIPLY_ACCUMULATE)
  parameter [19:0] COEFF_0 = 20'h00000, // 20-bit A input coefficient 0
  parameter [19:0] COEFF_1 = 20'h00000, // 20-bit A input coefficient 1
  parameter [19:0] COEFF_2 = 20'h00000, // 20-bit A input coefficient 2
  parameter [19:0] COEFF_3 = 20'h00000, // 20-bit A input coefficient 3
  parameter OUTPUT_REG_EN = "TRUE", // Enable output register (TRUE/FALSE)
  parameter INPUT_REG_EN = "TRUE" // Enable input register (TRUE/FALSE)
  ) (
  input logic [19:0] A,
  input logic [17:0] B,
  input logic [5:0] ACC_FIR,
  output logic [37:0] Z,
  output reg [17:0] DLY_B,
  (* clkbuf_sink *)
  input logic CLK,
  input logic RESET,
  input logic [2:0] FEEDBACK,
  input logic LOAD_ACC,
  input logic SATURATE,
  input logic [5:0] SHIFT_RIGHT,
  input logic ROUND,
  input logic SUBTRACT,
  input logic UNSIGNED_A,
  input logic UNSIGNED_B
);
endmodule
`endcelldefine
//
// FCLK_BUF black box model
// Clock buffer for routing logic signal to the global clock
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module FCLK_BUF (
  input logic I,
  output logic O
);
endmodule
`endcelldefine
//
// FIFO18KX2 black box model
// Dual 18Kb FIFO
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module FIFO18KX2 #(
  parameter DATA_WRITE_WIDTH1 = 18, // FIFO data write width, FIFO 1 (9, 18)
  parameter DATA_READ_WIDTH1 = 18, // FIFO data read width, FIFO 1 (9, 18)
  parameter FIFO_TYPE1 = "SYNCHRONOUS", // Synchronous or Asynchronous data transfer, FIFO 1 (SYNCHRONOUS/ASYNCHRONOUS)
  parameter [10:0] PROG_EMPTY_THRESH1 = 11'h004, // 11-bit Programmable empty depth, FIFO 1
  parameter [10:0] PROG_FULL_THRESH1 = 11'h7fa, // 11-bit Programmable full depth, FIFO 1
  parameter DATA_WRITE_WIDTH2 = 18, // FIFO data write width, FIFO 2 (9, 18)
  parameter DATA_READ_WIDTH2 = 18, // FIFO data read width, FIFO 2 (9, 18)
  parameter FIFO_TYPE2 = "SYNCHRONOUS", // Synchronous or Asynchronous data transfer, FIFO 2 (SYNCHRONOUS/ASYNCHRONOUS)
  parameter [10:0] PROG_EMPTY_THRESH2 = 11'h004, // 11-bit Programmable empty depth, FIFO 2
  parameter [10:0] PROG_FULL_THRESH2 = 11'h7fa // 11-bit Programmable full depth, FIFO 2
  ) (
  input logic RESET1,
  (* clkbuf_sink *)
  input logic WR_CLK1,
  (* clkbuf_sink *)
  input logic RD_CLK1,
  input logic WR_EN1,
  input logic RD_EN1,
  input logic [DATA_WRITE_WIDTH1-1:0] WR_DATA1,
  output logic [DATA_READ_WIDTH1-1:0] RD_DATA1,
  output reg EMPTY1,
  output reg FULL1,
  output reg ALMOST_EMPTY1,
  output reg ALMOST_FULL1,
  output reg PROG_EMPTY1,
  output reg PROG_FULL1,
  output reg OVERFLOW1,
  output reg UNDERFLOW1,
  input logic RESET2,
  (* clkbuf_sink *)
  input logic WR_CLK2,
  (* clkbuf_sink *)
  input logic RD_CLK2,
  input logic WR_EN2,
  input logic RD_EN2,
  input logic [DATA_WRITE_WIDTH2-1:0] WR_DATA2,
  output logic [DATA_READ_WIDTH2-1:0] RD_DATA2,
  output reg EMPTY2,
  output reg FULL2,
  output reg ALMOST_EMPTY2,
  output reg ALMOST_FULL2,
  output reg PROG_EMPTY2,
  output reg PROG_FULL2,
  output reg OVERFLOW2,
  output reg UNDERFLOW2
);
endmodule
`endcelldefine
//
// FIFO36K black box model
// 36Kb FIFO
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module FIFO36K #(
  parameter DATA_WRITE_WIDTH = 36, // FIFO data write width (9, 18, 36)
  parameter DATA_READ_WIDTH = 36, // FIFO data read width (9, 18, 36)
  parameter FIFO_TYPE = "SYNCHRONOUS", // Synchronous or Asynchronous data transfer (SYNCHRONOUS/ASYNCHRONOUS)
  parameter [11:0] PROG_EMPTY_THRESH = 12'h004, // 12-bit Programmable empty depth
  parameter [11:0] PROG_FULL_THRESH = 12'hffa // 12-bit Programmable full depth
  ) (
  input logic RESET,
  (* clkbuf_sink *)
  input logic WR_CLK,
  (* clkbuf_sink *)
  input logic RD_CLK,
  input logic WR_EN,
  input logic RD_EN,
  input logic [DATA_WRITE_WIDTH-1:0] WR_DATA,
  output logic [DATA_READ_WIDTH-1:0] RD_DATA,
  output reg EMPTY,
  output reg FULL,
  output reg ALMOST_EMPTY,
  output reg ALMOST_FULL,
  output reg PROG_EMPTY,
  output reg PROG_FULL,
  output reg OVERFLOW,
  output reg UNDERFLOW
);
endmodule
`endcelldefine
//
// I_BUF_DS black box model
// input differential buffer
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module I_BUF_DS #(
  parameter WEAK_KEEPER = "NONE", // Specify Pull-up/Pull-down on input (NONE/PULLUP/PULLDOWN)
  parameter IOSTANDARD = "DEFAULT", // IO Standard
  parameter DIFFERENTIAL_TERMINATION = "TRUE" // Enable differential termination
  ) (
  (* iopad_external_pin *)
  input logic I_P,
  (* iopad_external_pin *)
  input logic I_N,
  input logic EN,
  output reg O
);
endmodule
`endcelldefine
//
// I_BUF black box model
// Input buffer
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module I_BUF #(
  parameter WEAK_KEEPER = "NONE" // Specify Pull-up/Pull-down on input (NONE/PULLUP/PULLDOWN)
,  parameter IOSTANDARD = "DEFAULT" // IO Standard
  ) (
  (* iopad_external_pin *)
  input logic I,
  input logic EN,
  output logic O
);
endmodule
`endcelldefine
//
// I_DDR black box model
// DDR input register
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module I_DDR (
  input logic D,
  input logic R,
  input logic E,
  (* clkbuf_sink *)
  input logic C,
  output reg [1:0] Q
);
endmodule
`endcelldefine
//
// I_DELAY black box model
// Input Delay
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module I_DELAY #(
  parameter DELAY = 0 // TAP delay value (0-63)
  ) (
  input logic I,
  input logic DLY_LOAD,
  input logic DLY_ADJ,
  input logic DLY_INCDEC,
  output logic [5:0] DLY_TAP_VALUE,
  (* clkbuf_sink *)
  input logic CLK_IN,
  output logic O
);
endmodule
`endcelldefine
//
// I_FAB black box model
// Marker Buffer for periphery to fabric transition
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module I_FAB (
  input logic I,
  output logic O
);
endmodule
`endcelldefine
//
// I_SERDES black box model
// Input Serial Deserializer
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module I_SERDES #(
  parameter DATA_RATE = "SDR", // Single or double data rate (SDR/DDR)
  parameter WIDTH = 4, // Width of Deserialization (3-10)
  parameter DPA_MODE = "NONE" // Select Dynamic Phase Alignment or Clock Data Recovery (NONE/DPA/CDR)
  ) (
  input logic D,
  input logic RST,
  input logic BITSLIP_ADJ,
  input logic EN,
  (* clkbuf_sink *)
  input logic CLK_IN,
  output logic CLK_OUT,
  output logic [WIDTH-1:0] Q,
  output logic DATA_VALID,
  output logic DPA_LOCK,
  output logic DPA_ERROR,
  input logic PLL_LOCK,
  input logic PLL_CLK
);
endmodule
`endcelldefine
//
// LUT1 black box model
// 1-input lookup table (LUT)
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module LUT1 #(
  parameter [1:0] INIT_VALUE = 2'h0 // 2-bit LUT logic value
  ) (
  input logic A,
  output logic Y
);
endmodule
`endcelldefine
//
// LUT2 black box model
// 2-input lookup table (LUT)
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module LUT2 #(
  parameter [3:0] INIT_VALUE = 4'h0 // 4-bit LUT logic value
  ) (
  input logic [1:0] A,
  output logic Y
);
endmodule
`endcelldefine
//
// LUT3 black box model
// 3-input lookup table (LUT)
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module LUT3 #(
  parameter [7:0] INIT_VALUE = 8'h00 // 8-bit LUT logic value
  ) (
  input logic [2:0] A,
  output logic Y
);
endmodule
`endcelldefine
//
// LUT4 black box model
// 4-input lookup table (LUT)
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module LUT4 #(
  parameter [15:0] INIT_VALUE = 16'h0000 // 16-bit LUT logic value
  ) (
  input logic [3:0] A,
  output logic Y
);
endmodule
`endcelldefine
//
// LUT5 black box model
// 5-input lookup table (LUT)
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module LUT5 #(
  parameter [31:0] INIT_VALUE = 32'h00000000 // LUT logic value
  ) (
  input logic [4:0] A,
  output logic Y
);
endmodule
`endcelldefine
//
// LUT6 black box model
// 6-input lookup table (LUT)
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module LUT6 #(
  parameter [63:0] INIT_VALUE = 64'h0000000000000000 // 64-bit LUT logic value
  ) (
  input logic [5:0] A,
  output logic Y
);
endmodule
`endcelldefine
//
// O_BUF_DS black box model
// Output differential buffer
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module O_BUF_DS
  #(
  parameter IOSTANDARD = "DEFAULT", // IO Standard
  parameter DIFFERENTIAL_TERMINATION = "TRUE" // Enable differential termination
  )
  (
  input logic I,
  (* iopad_external_pin *)
  output logic O_P,
  (* iopad_external_pin *)
  output logic O_N
);
endmodule
`endcelldefine
//
// O_BUFT_DS black box model
// Output differential tri-state buffer
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module O_BUFT_DS #(
  parameter WEAK_KEEPER = "NONE" // Enable pull-up/pull-down on output (NONE/PULLUP/PULLDOWN)
,  parameter IOSTANDARD = "DEFAULT", // IO Standard
  parameter DIFFERENTIAL_TERMINATION = "TRUE" // Enable differential termination
  ) (
  input logic I,
  input logic T,
  (* iopad_external_pin *)
  output logic O_P,
  (* iopad_external_pin *)
  output logic O_N
);
endmodule
`endcelldefine
//
// O_BUFT black box model
// Output tri-state buffer
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module O_BUFT #(
  parameter WEAK_KEEPER = "NONE" // Enable pull-up/pull-down on output (NONE/PULLUP/PULLDOWN)
,  parameter IOSTANDARD = "DEFAULT", // IO Standard
  parameter DRIVE_STRENGTH = 2, // Drive strength in mA for LVCMOS standards
  parameter SLEW_RATE = "SLOW" // Transition rate for LVCMOS standards
  ) (
  input logic I,
  input logic T,
  (* iopad_external_pin *)
  output logic O
);
endmodule
`endcelldefine
//
// O_BUF black box model
// Output buffer
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module O_BUF
  #(
  parameter IOSTANDARD = "DEFAULT", // IO Standard
  parameter DRIVE_STRENGTH = 2, // Drive strength in mA for LVCMOS standards
  parameter SLEW_RATE = "SLOW" // Transition rate for LVCMOS standards
  )
  (
  input logic I,
  (* iopad_external_pin *)
  output logic O
);
endmodule
`endcelldefine
//
// O_DDR black box model
// DDR output register
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module O_DDR (
  input logic [1:0] D,
  input logic R,
  input logic E,
  (* clkbuf_sink *)
  input logic C,
  output reg Q
);
endmodule
`endcelldefine
//
// O_DELAY black box model
// Serdes output
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module O_DELAY #(
  parameter DELAY = 0 // TAP delay value (0-63)
  ) (
  input logic I,
  input logic DLY_LOAD,
  input logic DLY_ADJ,
  input logic DLY_INCDEC,
  output logic [5:0] DLY_TAP_VALUE,
  (* clkbuf_sink *)
  input logic CLK_IN,
  output logic O
);
endmodule
`endcelldefine
//
// O_FAB black box model
// Marker Buffer for fabric to periphery transition
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module O_FAB (
  input logic I,
  output logic O
);
endmodule
`endcelldefine
//
// O_SERDES_CLK black box model
// Output Serializer Clock
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module O_SERDES_CLK #(
  parameter DATA_RATE = "SDR", // Single or double data rate (SDR/DDR)
  parameter CLOCK_PHASE = 0 // Clock phase (0,90,180,270)
  ) (
  input logic CLK_EN,
  output reg OUTPUT_CLK,
  input logic PLL_LOCK,
  input logic PLL_CLK
);
endmodule
`endcelldefine
//
// O_SERDES black box model
// Output Serializer
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module O_SERDES #(
  parameter DATA_RATE = "SDR", // Single or double data rate (SDR/DDR)
  parameter WIDTH = 4 // Width of input data to serializer (3-10)
  ) (
  input logic [WIDTH-1:0] D,
  input logic RST,
  input logic DATA_VALID,
  (* clkbuf_sink *)
  input logic CLK_IN,
  input logic OE_IN,
  output logic OE_OUT,
  output logic Q,
  input logic CHANNEL_BOND_SYNC_IN,
  output logic CHANNEL_BOND_SYNC_OUT,
  input logic PLL_LOCK,
  input logic PLL_CLK
);
endmodule
`endcelldefine
//
// PLL black box model
// Phase locked loop
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module PLL #(
  parameter DEV_FAMILY = "VIRGO", // Device Family
  parameter DIVIDE_CLK_IN_BY_2 = "FALSE", // Enable input divider (TRUE/FALSE)
  parameter PLL_MULT = 16, // VCO clock multiplier value (16-640)
  parameter PLL_DIV = 1, // VCO clock divider value (1-63)
  parameter PLL_MULT_FRAC = 0, // Fraction mode not supported
  parameter PLL_POST_DIV = 17 // VCO clock post-divider value (17,18,19,20,21,22,23,34,35,36,37,38,39,51,52,53,54,55,68,69,70,71,85,86,87,102,103,119)
  ) (
  input logic PLL_EN,
  (* clkbuf_sink *)
  input logic CLK_IN,
  output logic CLK_OUT,
  output logic CLK_OUT_DIV2,
  output logic CLK_OUT_DIV3,
  output logic CLK_OUT_DIV4,
  output logic FAST_CLK,
  output logic LOCK
);
endmodule
`endcelldefine
//
// SOC_FPGA_INTF_AHB_M black box model
// SOC interface connection AHB Master
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module SOC_FPGA_INTF_AHB_M (
  input logic HRESETN_I,
  input logic [31:0] HADDR,
  input logic [2:0] HBURST,
  input logic [3:0] HPROT,
  input logic [2:0] HSIZE,
  input logic [2:0] HTRANS,
  input logic [31:0] HWDATA,
  input logic HWWRITE,
  output logic [31:0] HRDATA,
  output logic HREADY,
  output logic HRESP,
  input logic HCLK
);
endmodule
`endcelldefine
//
// SOC_FPGA_INTF_AHB_S black box model
// SOC interface connection AHB Slave
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module SOC_FPGA_INTF_AHB_S (
  output logic HRESETN_I,
  output logic [31:0] HADDR,
  output logic [2:0] HBURST,
  output logic HMASTLOCK,
  input logic HREADY,
  output logic [3:0] HPROT,
  input logic [31:0] HRDATA,
  input logic HRESP,
  output logic HSEL,
  output logic [2:0] HSIZE,
  output logic [1:0] HTRANS,
  output logic [3:0] HWBE,
  output logic [31:0] HWDATA,
  output logic HWRITE,
  input logic HCLK
);
endmodule
`endcelldefine
//
// SOC_FPGA_INTF_AXI_M0 black box model
// SOC interface connection AXI Master 0
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module SOC_FPGA_INTF_AXI_M0 (
  input logic [31:0] M0_ARADDR,
  input logic [1:0] M0_ARBURST,
  input logic [3:0] M0_ARCACHE,
  input logic [3:0] M0_ARID,
  input logic [2:0] M0_ARLEN,
  input logic M0_ARLOCK,
  input logic [2:0] M0_ARPROT,
  output logic M0_ARREADY,
  input logic [2:0] M0_ARSIZE,
  input logic M0_ARVALID,
  input logic [31:0] M0_AWADDR,
  input logic [1:0] M0_AWBURST,
  input logic [3:0] M0_AWCACHE,
  input logic [3:0] M0_AWID,
  input logic [2:0] M0_AWLEN,
  input logic M0_AWLOCK,
  input logic [2:0] M0_AWPROT,
  output logic M0_AWREADY,
  input logic [2:0] M0_AWSIZE,
  input logic M0_AWVALID,
  output logic [3:0] M0_BID,
  input logic M0_BREADY,
  output logic [1:0] M0_BRESP,
  output logic M0_BVALID,
  output logic [63:0] M0_RDATA,
  output logic [3:0] M0_RID,
  output logic M0_RLAST,
  input logic M0_RREADY,
  output logic [1:0] M0_RRESP,
  output logic M0_RVALID,
  input logic [63:0] M0_WDATA,
  input logic M0_WLAST,
  output logic M0_WREADY,
  input logic [7:0] M0_WSTRB,
  input logic M0_WVALID,
  input logic M0_ACLK,
  output logic M0_ARESETN_I
);
endmodule
`endcelldefine
//
// SOC_FPGA_INTF_AXI_M1 black box model
// SOC interface connection AXI Master 1
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module SOC_FPGA_INTF_AXI_M1 (
  input logic [31:0] M1_ARADDR,
  input logic [1:0] M1_ARBURST,
  input logic [3:0] M1_ARCACHE,
  input logic [3:0] M1_ARID,
  input logic [2:0] M1_ARLEN,
  input logic M1_ARLOCK,
  input logic [2:0] M1_ARPROT,
  output logic M1_ARREADY,
  input logic [2:0] M1_ARSIZE,
  input logic M1_ARVALID,
  input logic [31:0] M1_AWADDR,
  input logic [1:0] M1_AWBURST,
  input logic [3:0] M1_AWCACHE,
  input logic [3:0] M1_AWID,
  input logic [2:0] M1_AWLEN,
  input logic M1_AWLOCK,
  input logic [2:0] M1_AWPROT,
  output logic M1_AWREADY,
  input logic [2:0] M1_AWSIZE,
  input logic M1_AWVALID,
  output logic [3:0] M1_BID,
  input logic M1_BREADY,
  output logic [1:0] M1_BRESP,
  output logic M1_BVALID,
  output logic [63:0] M1_RDATA,
  output logic [3:0] M1_RID,
  output logic M1_RLAST,
  input logic M1_RREADY,
  output logic [1:0] M1_RRESP,
  output logic M1_RVALID,
  input logic [63:0] M1_WDATA,
  input logic M1_WLAST,
  output logic M1_WREADY,
  input logic [7:0] M1_WSTRB,
  input logic M1_WVALID,
  input logic M1_ACLK,
  output logic M1_ARESETN_I
);
endmodule
`endcelldefine
//
// SOC_FPGA_INTF_DMA black box model
// SOC DMA interface
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module SOC_FPGA_INTF_DMA (
  input logic [3:0] DMA_REQ,
  output logic [3:0] DMA_ACK,
  input logic DMA_CLK,
  input logic DMA_RST_N
);
endmodule
`endcelldefine
//
// SOC_FPGA_INTF_IRQ black box model
// SOC Interupt connection
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module SOC_FPGA_INTF_IRQ (
  input logic [15:0] IRQ_SRC,
  output logic [15:0] IRQ_SET,
  input logic IRQ_CLK,
  input logic IRQ_RST_N
);
endmodule
`endcelldefine
//
// SOC_FPGA_INTF_JTAG black box model
// SOC JTAG connection
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module SOC_FPGA_INTF_JTAG (
  input logic BOOT_JTAG_TCK,
  output reg BOOT_JTAG_TDI,
  input logic BOOT_JTAG_TDO,
  output reg BOOT_JTAG_TMS,
  output reg BOOT_JTAG_TRSTN,
  input logic BOOT_JTAG_EN
);
endmodule
`endcelldefine
//
// SOC_FPGA_TEMPERATURE black box model
// SOC Temperature Interface
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module SOC_FPGA_TEMPERATURE #(
  parameter INITIAL_TEMPERATURE = 25, // Specify initial temperature for simulation (0-125)
  parameter TEMPERATURE_FILE = "" // Specify ASCII file containing temperature values over time
  ) (
  output reg [7:0] TEMPERATURE,
  output reg VALID,
  output reg ERROR
);
endmodule
`endcelldefine
//
// TDP_RAM18KX2 black box model
// Dual 18Kb True-dual-port RAM
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module TDP_RAM18KX2 #(
  parameter [16383:0] INIT1 = {16384{1'b0}}, // Initial Contents of data memory, RAM 1
  parameter [2047:0] INIT1_PARITY = {2048{1'b0}}, // Initial Contents of parity memory, RAM 1
  parameter WRITE_WIDTH_A1 = 18, // Write data width on port A, RAM 1 (1, 2, 4, 9, 18)
  parameter WRITE_WIDTH_B1 = 18, // Write data width on port B, RAM 1 (1, 2, 4, 9, 18)
  parameter READ_WIDTH_A1 = 18, // Read data width on port A, RAM 1 (1, 2, 4, 9, 18)
  parameter READ_WIDTH_B1 = 18, // Read data width on port B, RAM 1 (1, 2, 4, 9, 18)
  parameter [16383:0] INIT2 = {16384{1'b0}}, // Initial Contents of memory, RAM 2
  parameter [2047:0] INIT2_PARITY = {2048{1'b0}}, // Initial Contents of memory, RAM 2
  parameter WRITE_WIDTH_A2 = 18, // Write data width on port A, RAM 2 (1, 2, 4, 9, 18)
  parameter WRITE_WIDTH_B2 = 18, // Write data width on port B, RAM 2 (1, 2, 4, 9, 18)
  parameter READ_WIDTH_A2 = 18, // Read data width on port A, RAM 2 (1, 2, 4, 9, 18)
  parameter READ_WIDTH_B2 = 18 // Read data width on port B, RAM 2 (1, 2, 4, 9, 18)
  ) (
  input logic WEN_A1,
  input logic WEN_B1,
  input logic REN_A1,
  input logic REN_B1,
  (* clkbuf_sink *)
  input logic CLK_A1,
  (* clkbuf_sink *)
  input logic CLK_B1,
  input logic [1:0] BE_A1,
  input logic [1:0] BE_B1,
  input logic [13:0] ADDR_A1,
  input logic [13:0] ADDR_B1,
  input logic [15:0] WDATA_A1,
  input logic [1:0] WPARITY_A1,
  input logic [15:0] WDATA_B1,
  input logic [1:0] WPARITY_B1,
  output reg [15:0] RDATA_A1,
  output reg [1:0] RPARITY_A1,
  output reg [15:0] RDATA_B1,
  output reg [1:0] RPARITY_B1,
  input logic WEN_A2,
  input logic WEN_B2,
  input logic REN_A2,
  input logic REN_B2,
  (* clkbuf_sink *)
  input logic CLK_A2,
  (* clkbuf_sink *)
  input logic CLK_B2,
  input logic [1:0] BE_A2,
  input logic [1:0] BE_B2,
  input logic [13:0] ADDR_A2,
  input logic [13:0] ADDR_B2,
  input logic [15:0] WDATA_A2,
  input logic [1:0] WPARITY_A2,
  input logic [15:0] WDATA_B2,
  input logic [1:0] WPARITY_B2,
  output reg [15:0] RDATA_A2,
  output reg [1:0] RPARITY_A2,
  output reg [15:0] RDATA_B2,
  output reg [1:0] RPARITY_B2
);
endmodule
`endcelldefine
//
// TDP_RAM36K black box model
// 36Kb True-dual-port RAM
//
// Copyright (c) 2024 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module TDP_RAM36K #(
  parameter [32767:0] INIT = {32768{1'b0}}, // Initial Contents of memory
  parameter [4095:0] INIT_PARITY = {4096{1'b0}}, // Initial Contents of memory
  parameter WRITE_WIDTH_A = 36, // Write data width on port A (1, 2, 4, 9, 18, 36)
  parameter READ_WIDTH_A = WRITE_WIDTH_A, // Read data width on port A (1, 2, 4, 9, 18, 36)
  parameter WRITE_WIDTH_B = WRITE_WIDTH_A, // Write data width on port B (1, 2, 4, 9, 18, 36)
  parameter READ_WIDTH_B = READ_WIDTH_A // Read data width on port B (1, 2, 4, 9, 18, 36)
  ) (
  input logic WEN_A,
  input logic WEN_B,
  input logic REN_A,
  input logic REN_B,
  (* clkbuf_sink *)
  input logic CLK_A,
  (* clkbuf_sink *)
  input logic CLK_B,
  input logic [3:0] BE_A,
  input logic [3:0] BE_B,
  input logic [14:0] ADDR_A,
  input logic [14:0] ADDR_B,
  input logic [31:0] WDATA_A,
  input logic [3:0] WPARITY_A,
  input logic [31:0] WDATA_B,
  input logic [3:0] WPARITY_B,
  output reg [31:0] RDATA_A,
  output reg [3:0] RPARITY_A,
  output reg [31:0] RDATA_B,
  output reg [3:0] RPARITY_B
);
endmodule
`endcelldefine


//------------------------------------------------------------------------------
//
// Copyright (C) 2023 RapidSilicon
//
// genesis3 LATChes
//
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Positive level-sensitive latch implemented with feed-back loop LUT
//------------------------------------------------------------------------------

`celldefine
(* blackbox *)
module LATCH(D, G, Q);
  input D;
  input G;
  output Q;

endmodule
`endcelldefine

//------------------------------------------------------------------------------
// Negative level-sensitive latch implemented with feed-back loop LUT
//------------------------------------------------------------------------------
`celldefine
(* blackbox *)
module LATCHN(D, G, Q);
  input D;
  input G;
  output Q;

endmodule
`endcelldefine

//------------------------------------------------------------------------------
// Positive level-sensitive latch with active-high asyncronous reset
// implemented with feed-back loop LUT
//------------------------------------------------------------------------------
`celldefine
(* blackbox *)
module LATCHR(D, G, R, Q);
  input D;
  input G;
  output Q;
  input R;

endmodule
`endcelldefine
//------------------------------------------------------------------------------
// Positive level-sensitive latch with active-high asyncronous set
// implemented with feed-back loop LUT
//------------------------------------------------------------------------------
`celldefine
(* blackbox *)
module LATCHS(D, G, R, Q);
  input D;
  input G;
  output Q;
  input R;

endmodule
`endcelldefine

//------------------------------------------------------------------------------
// Negative level-sensitive latch with active-high asyncronous reset
// implemented with feed-back loop LUT
//------------------------------------------------------------------------------
`celldefine
(* blackbox *)
module LATCHNR(D, G, R, Q);
  input D;
  input G;
  output Q;
  input R;

endmodule
`endcelldefine

//------------------------------------------------------------------------------
// Negative level-sensitive latch with active-high asyncronous set
// implemented with feed-back loop LUT
//------------------------------------------------------------------------------
`celldefine
(* blackbox *)
module LATCHNS(D, G, R, Q);
  input D;
  input G;
  output Q;
  input R;

endmodule
`endcelldefine
