`timescale 1ns/1ps
`celldefine
//
// MIPI_RX simulation model
// MIPI Receiver
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module MIPI_RX #(
  parameter WIDTH = 4, // Width of input data to serializer (3-10)
  parameter EN_IDLY = "FALSE", // True or False
  parameter DELAY = 0 // Fixed TAP delay value (0-63)
) (
  input RST, // Active-low, asynchronous reset
  input RX_CLK, // MIPI RX_IO clock input, PLL_CLK
  input PLL_LOCK, // PLL lock input
  input CLK_IN, // Fabric core clock input
  input RX_DP, // MIPI RX Data Positive input From I_BUF
  input RX_DN, // MIPI RX Data Negative input from I_BUF
  input HS_EN, // EN HS Data input (From Fabric). Active high signal. This is a common signal between MIPI RX/TX interface.
  input LP_EN, // EN LP Data input (From Fabric). This is a common signal between MIPI RX/TX interface.
  input RX_TERM_EN, // EN Differential Termination
  input BITSLIP_ADJ, // BITSLIP_ADJ input from Fabric
  input DLY_LOAD, // Delay load input, from Fabric
  input DLY_ADJ, // Delay adjust input, from Fabric
  input DLY_INCDEC, // Delay increment / decrement input, from Fabric
  output [5:0] DLY_TAP_VALUE, // Delay tap value output to fabric
  output [WIDTH-1:0] HS_RX_DATA, // HS RX Data output to Fabric
  output HS_RXD_VALID, // HS RX Parallel DATA is VALID
  output RX_OE, // IBUF OE signal for MIPI I_BUF
  output LP_RX_DP, // LP RX Data positive output to the Fabric
  output LP_RX_DN // LP RX Data negative output to the Fabric
);


  wire i_delay_out;
	wire rx_dp_delay;
	wire rx_dn_delay;
	wire rx_dp;
	wire rx_dn;

  I_DELAY # (
    .DELAY(DELAY)
  )
  I_DELAY_inst (
    .I(RX_DP),
    .DLY_LOAD(DLY_LOAD),
    .DLY_ADJ(DLY_ADJ),
    .DLY_INCDEC(DLY_INCDEC),
    .DLY_TAP_VALUE(DLY_TAP_VALUE),
    .CLK_IN(CLK_IN),
    .O(i_delay_out)
  );

  I_SERDES # (
    .DATA_RATE("DDR"),
    .WIDTH(WIDTH),
    .DPA_MODE("NONE")
  )
  I_SERDES_inst (
    .D(rx_dp),
    .RST(RST),
    .BITSLIP_ADJ(BITSLIP_ADJ),
    .EN(HS_EN),
    .CLK_IN(CLK_IN),
    .CLK_OUT(CLK_OUT),
    .Q(HS_RX_DATA),
    .DATA_VALID(HS_RXD_VALID),
    .DPA_LOCK(),
    .DPA_ERROR(),
    .PLL_LOCK(PLL_LOCK),
    .PLL_CLK(RX_CLK)
  );

	assign RX_OE= HS_EN | LP_EN;
	assign rx_dp_delay = (EN_IDLY=="FALSE")? RX_DP:i_delay_out;
  assign rx_dn_delay = (EN_IDLY=="FALSE")? RX_DN:~i_delay_out;
  
	// assign rx_dp = RX_TERM_EN?1'bz:RX_OE?rx_dp_delay:'b0;
	// assign rx_dn = RX_TERM_EN?1'bz:RX_OE?rx_dn_delay:'b0;
  assign rx_dp = RX_OE?rx_dp_delay:'b0;
	assign rx_dn = RX_OE?rx_dn_delay:'b0;

  assign LP_RX_DP = rx_dp;
  assign LP_RX_DN = rx_dn;

 initial begin

    if ((WIDTH < 3) || (WIDTH > 10)) begin
       $fatal(1,"MIPI_RX instance %m WIDTH set to incorrect value, %d.  Values must be between 3 and 10.", WIDTH);
    end
    case(EN_IDLY)
      "TRUE" ,
      "FALSE": begin end
      default: begin
        $fatal(1,"\nError: MIPI_RX instance %m has parameter EN_IDLY set to %s.  Valid values are TRUE, FALSE\n", EN_IDLY);
      end
    endcase

    if ((DELAY < 0) || (DELAY > 63)) begin
       $fatal(1,"MIPI_RX instance %m DELAY set to incorrect value, %d.  Values must be between 0 and 63.", DELAY);
    end

  end

endmodule
`endcelldefine
