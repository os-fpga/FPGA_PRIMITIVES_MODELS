`timescale 1ns/1ps
`celldefine
//
// MIPI_TX simulation model
// MIPI Transmitter
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module MIPI_TX #(
  parameter WIDTH = 4, // Width of input data to serializer (3-10)
  parameter EN_ODLY = "FALSE", // True or False
  parameter LANE_MODE = "Master", // Master or Slave
  parameter DELAY = 0 // Fixed TAP delay value (0-63)
) (
  input RST, // Active-low, asynchronous reset
  input RX_CLK, // MIPI RX_IO clock input, PLL_CLK
  input PLL_LOCK, // PLL lock input
  input CLK_IN, // Fabric core clock input
  input [WIDTH-1:0] HS_TX_DATA, // Parallel Data input bus from fabric
  input HS_TXD_VALID, // Load word input from Fabric
  input HS_EN, // EN HS Data Transmission (From Fabric)
  input TX_LP_DP, // LP TX Data positive from the Fabric
  input TX_LP_DN, // LP TX Data negative from the Fabric
  input LP_EN, // EN LP Data Transmission (From Fabric). Active high signal. This is a common signal between MIPI RX/TX interface.
  input TX_ODT_EN, // EN Termination
  input DLY_LOAD, // Delay load input, from Fabric
  input DLY_ADJ, // Delay adjust input, from Fabric
  input DLY_INCDEC, // Delay increment / decrement input, from Fabric
  output TX_OE, // IBUF OE signal for MIPI O_BUF
  output TX_DP, // Serial Data output to O_BUF
  output TX_DN, // Serial Data output to O_BUF
  input CHANNEL_BOND_SYNC_IN, // Channel bond sync input
  output CHANNEL_BOND_SYNC_OUT // Channel bond sync output
);


  wire o_serdes_dout;
  wire o_delay_dout;

  O_SERDES # (
    .DATA_RATE("DDR"),
    .WIDTH(WIDTH)
  )
  O_SERDES_inst (
    .D(HS_TX_DATA),
    .RST(RST),
    .DATA_VALID(HS_TXD_VALID),
    .CLK_IN(CLK_IN),
    .OE_IN(),
    .OE_OUT(),
    .Q(o_serdes_dout),
    .CHANNEL_BOND_SYNC_IN(CHANNEL_BOND_SYNC_IN),
    .CHANNEL_BOND_SYNC_OUT(CHANNEL_BOND_SYNC_OUT),
    .PLL_LOCK(PLL_LOCK),
    .PLL_CLK(RX_CLK)
  );

O_DELAY # (
  .DELAY(DELAY)
)
O_DELAY_inst (
  .I(tx_dp),
  .DLY_LOAD(DLY_LOAD),
  .DLY_ADJ(DLY_ADJ),
  .DLY_INCDEC(DLY_INCDEC),
  .DLY_TAP_VALUE(),
  .CLK_IN(CLK_IN),
  .O(o_delay_dout)
);
  reg tx_dp;
  reg tx_dn;
  assign TX_OE = LP_EN | HS_EN;

  always @(*) 
  begin
    if(HS_EN && TX_OE)
    begin
      tx_dp = o_serdes_dout;
      tx_dn = ~tx_dp;
    end
    else if (LP_EN && TX_OE) 
    begin
      tx_dp = TX_LP_DP;
      tx_dn = TX_LP_DN;
    end
  end

  assign TX_DP = (EN_ODLY=="FALSE")? tx_dp:o_delay_dout;
  assign TX_DN = (EN_ODLY=="FALSE")? tx_dn:~o_delay_dout;
  
  // assign TX_DP = tx_dp;
  // assign TX_DN = tx_dn;

  always@(*)
  begin
    if(LP_EN && HS_EN)
      $fatal(1,"\nERROR: MIPI TX instance %m LP_EN and HS_EN can't be hight at same time");
  end initial begin

    if ((WIDTH < 3) || (WIDTH > 10)) begin
       $fatal(1,"MIPI_TX instance %m WIDTH set to incorrect value, %d.  Values must be between 3 and 10.", WIDTH);
    end
    case(EN_ODLY)
      "TRUE" ,
      "FALSE": begin end
      default: begin
        $fatal(1,"\nError: MIPI_TX instance %m has parameter EN_ODLY set to %s.  Valid values are TRUE, FALSE\n", EN_ODLY);
      end
    endcase
    case(LANE_MODE)
      "Master" ,
      "Slave": begin end
      default: begin
        $fatal(1,"\nError: MIPI_TX instance %m has parameter LANE_MODE set to %s.  Valid values are Master, Slave\n", LANE_MODE);
      end
    endcase

    if ((DELAY < 0) || (DELAY > 63)) begin
       $fatal(1,"MIPI_TX instance %m DELAY set to incorrect value, %d.  Values must be between 0 and 63.", DELAY);
    end

  end

endmodule
`endcelldefine
