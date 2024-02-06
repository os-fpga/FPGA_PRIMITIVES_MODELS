// --------------------------------------------------------------------------
// ---------------- Copyright (C) 2023 RapidSilicon -------------------------
// --------------------------------------------------------------------------
// ---------------------- FIFO18KX2 Primitive -------------------------------
// --------------------------------------------------------------------------

module FIFO18KX2 #(
    parameter DATA_WRITE_WIDTH1 = 5'b10010,        // Write Data Width of FIFO1 from 1, 2, 4, 9, 18
    parameter DATA_READ_WIDTH1 = 5'b10010,         // Read Data Width of FIFO1 from 1, 2, 4, 9, 18
    parameter FIFO_TYPE1 = "SYNCHRONOUS",       // Synchronous or Asynchronous FIFO1     
    parameter PROG_EMPTY_THRESH1 = 11'b00000000100,     // Threshold indicating that the FIFO1 buffer is considered Empty
    parameter PROG_FULL_THRESH1 = 11'b10011111010,      // Threshold indicating that the FIFO1 buffer is considered Full
    
    parameter DATA_WRITE_WIDTH2 = 5'b10010,        // Write Data Width of FIFO2 from 1, 2, 4, 9, 18
    parameter DATA_READ_WIDTH2 = 5'b10010,         // Read Data Width of FIFO1 from 1, 2, 4, 9, 18
    parameter FIFO_TYPE2 = "SYNCHRONOUS",       // Synchronous or Asynchronous FIFO2    
    parameter PROG_EMPTY_THRESH2 = 11'b00000000100,     // Threshold indicating that the FIFO2 buffer is considered Empty
    parameter PROG_FULL_THRESH2 = 11'b10011111010       // Threshold indicating that the FIFO2 buffer is considered Full
)
(
    // -------------Ports for FIFO 1-----------------
    input wire RESET1,                          // 1-bit input:  Active Low Synchronous Reset
    input wire WR_CLK1,                         // 1-bit input:  Write Clock
    input wire RD_CLK1,                         // 1-bit input:  Read Clock
    input wire RD_EN1,                          // 1-bit input:  Read Enable
    input wire WR_EN1,                          // 1-bit input:  Write Enable
    input wire [DATA_WRITE_WIDTH1-1:0] WR_DATA1,// DATA_WIDTH1-bits Data coming inside FIFO
    output wire [DATA_READ_WIDTH1-1:0] RD_DATA1,// DATA_WIDTH1-bits Data coming out from FIFO
    output wire EMPTY1,                         // 1-bit output: Empty Flag
    output wire FULL1,                          // 1-bit output: Full Flag
    output wire ALMOST_EMPTY1,                  // 1-bit output: This Flag is asserted when FIFO contains EMPTY plus one data words
    output wire ALMOST_FULL1,                   // 1-bit output: This Flag is asserted when FIFO contains FULL minus one data words
    output wire PROG_EMPTY1,                    // 1-bit output: Empty Watermark Flag
    output wire PROG_FULL1,                     // 1-bit output: Full Watermark Flag
    output wire OVERFLOW1,                      // 1-bit output: Overflow Flag 
    output wire UNDERFLOW1,                     // 1-bit output: Underflow Flag

    // -------------Ports for FIFO 2-----------------
    input wire RESET2,                          // 1-bit input:  Active Low Synchronous Reset
    input wire WR_CLK2,                         // 1-bit input:  Write Clock
    input wire RD_CLK2,                         // 1-bit input:  Read Clock
    input wire RD_EN2,                          // 1-bit input:  Read Enable
    input wire WR_EN2,                          // 1-bit input:  Write Enable
    input wire [DATA_WRITE_WIDTH2-1:0] WR_DATA2,// DATA_WIDTH2-bits Data coming inside FIFO
    output wire [DATA_READ_WIDTH2-1:0] RD_DATA2,// DATA_WIDTH2-bits Data coming out from FIFO
    output wire EMPTY2,                         // 1-bit output: Empty Flag
    output wire FULL2,                          // 1-bit output: Full Flag
    output wire ALMOST_EMPTY2,                  // 1-bit output: This Flag is asserted when FIFO contains EMPTY plus one data words
    output wire ALMOST_FULL2,                   // 1-bit output: This Flag is asserted when FIFO contains FULL minus one data words
    output wire PROG_EMPTY2,                    // 1-bit output: Empty Watermark Flag
    output wire PROG_FULL2,                     // 1-bit output: Full Watermark Flag
    output wire OVERFLOW2,                      // 1-bit output: Overflow Flag 
    output wire UNDERFLOW2                      // 1-bit output: Underflow Flag
);

localparam data_width_write1 = (DATA_WRITE_WIDTH1 > 4'b1001) ? 5'b10010 : DATA_WRITE_WIDTH1;
localparam data_width_write2 = (DATA_WRITE_WIDTH2 > 4'b1001) ? 5'b10010 : DATA_WRITE_WIDTH2;
localparam data_width_read1 = (DATA_READ_WIDTH1 > 4'b1001) ? 5'b10010 : DATA_READ_WIDTH1;
localparam data_width_read2 = (DATA_READ_WIDTH2 > 4'b1001) ? 5'b10010 : DATA_READ_WIDTH2;

initial begin
    if ((DATA_WRITE_WIDTH1 < 1'b1) || (DATA_WRITE_WIDTH1 > 5'b10010)) begin
       $display("FIFO18KX2 instance %m DATA_WRITE_WIDTH1 set to incorrect value, %d.  Values must be between 1 and 18.", DATA_WRITE_WIDTH1);
    #1 $stop;
    end
    if ((DATA_READ_WIDTH1 < 1'b1) || (DATA_READ_WIDTH1 > 5'b10010)) begin
       $display("FIFO18KX2 instance %m DATA_READ_WIDTH1 set to incorrect value, %d.  Values must be between 1 and 18.", DATA_READ_WIDTH1);
    #1 $stop;
    end
    case(FIFO_TYPE1)
      "SYNCHRONOUS" ,
      "ASYNCHRONOUS": begin end
      default: begin
        $display("\nError: FIFO18KX2 instance %m has parameter FIFO_TYPE1 set to %s.  Valid values are SYNCHRONOUS, ASYNCHRONOUS\n", FIFO_TYPE1);
        #1 $stop ;
      end
    endcase

    if ((DATA_WRITE_WIDTH2 < 1'b1) || (DATA_WRITE_WIDTH2 > 5'b10010)) begin
       $display("FIFO18KX2 instance %m DATA_WRITE_WIDTH2 set to incorrect value, %d.  Values must be between 1 and 18.", DATA_WRITE_WIDTH2);
    #1 $stop;
    end
    if ((DATA_READ_WIDTH2 < 1'b1) || (DATA_READ_WIDTH2 > 5'b10010)) begin
       $display("FIFO18KX2 instance %m DATA_READ_WIDTH2 set to incorrect value, %d.  Values must be between 1 and 18.", DATA_READ_WIDTH2);
    #1 $stop;
    end
    case(FIFO_TYPE2)
      "SYNCHRONOUS" ,
      "ASYNCHRONOUS": begin end
      default: begin
        $display("\nError: FIFO18KX2 instance %m has parameter FIFO_TYPE2 set to %s.  Valid values are SYNCHRONOUS, ASYNCHRONOUS\n", FIFO_TYPE2);
        #1 $stop ;
      end
    endcase
end

// Synchronous/Asynchronous FIFO 
localparam fifo_type1   = (FIFO_TYPE1 == "SYNCHRONOUS") ? 1'b1 : 1'b0;
localparam fifo_type2   = (FIFO_TYPE2 == "SYNCHRONOUS") ? 1'b1 : 1'b0;

// FIFO1
generate
  if (data_width_write1 == 5'b10010 && data_width_read1 == 5'b10010)
      begin
          RS_TDP36K #(
              // ----------------------------------------------------------Appending 12th bit as dont care bit
              .MODE_BITS({fifo_type1, {4{3'b010}}, 1'b1, 1'b0, 1'b0, 1'b0, 1'bx, PROG_EMPTY_THRESH1[10:0], 1'bx, PROG_FULL_THRESH1[10:0], 39'b000000000000000000000000000000000000000, 1'b1})
              )
          RS_TDP36K_W18_R18 (
              .WEN_A1(WR_EN1),
              .REN_B1(RD_EN1),
              .CLK_A1(WR_CLK1),
              .CLK_B1(RD_CLK1),
              .WDATA_A1(WR_DATA1[17:0]),
              .RDATA_A1({EMPTY1, ALMOST_EMPTY1, PROG_EMPTY1, UNDERFLOW1, FULL1, ALMOST_FULL1, PROG_FULL1, OVERFLOW1}),
              .RDATA_B1(RD_DATA1[17:0]),
              .FLUSH1(RESET1),
              .CLK_A2(WR_CLK1),
              .CLK_B2(RD_CLK1)
          );
      end

  else if (data_width_write1 == 4'b1001 && data_width_read1 == 4'b1001)
      begin
          wire [17:0] rd_data1;
          assign RD_DATA1 = {rd_data1[16], rd_data1[7:0]};
          RS_TDP36K #(
              // ----------------------------------------------------------Appending 12th bit as dont care bit
              .MODE_BITS({fifo_type1, {4{3'b100}}, 1'b1, 1'b0, 1'b0, 1'b0, 1'bx, PROG_EMPTY_THRESH1[10:0], 1'bx, PROG_FULL_THRESH1[10:0], 39'b000000000000000000000000000000000000000, 1'b1})
              )
          RS_TDP36K_W9_R9 (
              .WEN_A1(WR_EN1),
              .REN_B1(RD_EN1),
              .CLK_A1(WR_CLK1),
              .CLK_B1(RD_CLK1),
              .WDATA_A1({1'bx, WR_DATA1[8], {8{1'bx}}, WR_DATA1[7:0]}),
              .RDATA_A1({EMPTY1, ALMOST_EMPTY1, PROG_EMPTY1, UNDERFLOW1, FULL1, ALMOST_FULL1, PROG_FULL1, OVERFLOW1}),
              .RDATA_B1(rd_data1),
              .FLUSH1(RESET1),
              .CLK_A2(WR_CLK1),
              .CLK_B2(RD_CLK1)
          );
      end
  else if (data_width_write1 == 5'b10010 && data_width_read1 == 4'b1001)
      begin
          wire [17:0] rd_data1;
          assign RD_DATA1 = {rd_data1[16], rd_data1[7:0]};
          // ----------------------------------------------------------Appending 12th bit as dont care bit
          RS_TDP36K #(
              .MODE_BITS({fifo_type1, {2{3'b100}}, {2{3'b010}}, 1'b1, 1'b0, 1'b0, 1'b0, 1'bx, PROG_EMPTY_THRESH1[10:0], 1'bx, PROG_FULL_THRESH1[10:0], 39'b000000000000000000000000000000000000000, 1'b1})
              )
          RS_TDP36K_W18_R9 (
              .WEN_A1(WR_EN1),
              .REN_B1(RD_EN1),
              .CLK_A1(WR_CLK1),
              .CLK_B1(RD_CLK1),
              .WDATA_A1({WR_DATA1[17], WR_DATA1[8], WR_DATA1[16:9], WR_DATA1[7:0]}),
              .RDATA_A1({EMPTY1, ALMOST_EMPTY1, PROG_EMPTY1, UNDERFLOW1, FULL1, ALMOST_FULL1, PROG_FULL1, OVERFLOW1}),
              .RDATA_B1(rd_data1),
              .FLUSH1(RESET1),
              .CLK_A2(WR_CLK1),
              .CLK_B2(RD_CLK1)
          );
      end
  else
      begin
          wire [17:0] rd_data1;
          assign RD_DATA1 = {rd_data1[17], rd_data1[15:8], rd_data1[16], rd_data1[7:0]};
          RS_TDP36K #(
              // ----------------------------------------------------------Appending 12th bit as dont care bit
              .MODE_BITS({fifo_type1, {2{3'b010}}, {2{3'b100}}, 1'b1, 1'b0, 1'b0, 1'b0, 1'bx, PROG_EMPTY_THRESH1[10:0], 1'bx, PROG_FULL_THRESH1[10:0], 39'b000000000000000000000000000000000000000, 1'b1})
              )
          RS_TDP36K_W9_R18 (
              .WEN_A1(WR_EN1),
              .REN_B1(RD_EN1),
              .CLK_A1(WR_CLK1),
              .CLK_B1(RD_CLK1),
              .WDATA_A1({1'bx, WR_DATA1[8], {8{1'bx}}, WR_DATA1[7:0]}),
              .RDATA_A1({EMPTY1, ALMOST_EMPTY1, PROG_EMPTY1, UNDERFLOW1, FULL1, ALMOST_FULL1, PROG_FULL1, OVERFLOW1}),
              .RDATA_B1(rd_data1),
              .FLUSH1(RESET1),
              .CLK_A2(WR_CLK1),
              .CLK_B2(RD_CLK1)
          );
      end

endgenerate

// FIFO2
generate
  if (data_width_write2 == 5'b10010 && data_width_read2 == 5'b10010)
      begin
          RS_TDP36K #(
              // ----------------------------------------------------------Appending 12th bit as dont care bit
              .MODE_BITS({fifo_type2, {4{3'b010}}, 1'b1, 1'b0, 1'b0, 1'b0, 1'bx, PROG_EMPTY_THRESH2[10:0], 1'bx, PROG_FULL_THRESH2[10:0], 39'b000000000000000000000000000000000000000, 1'b1})
              )
          RS_TDP36K_W18_R18 (
              .WEN_A1(WR_EN2),
              .REN_B1(RD_EN2),
              .CLK_A1(WR_CLK2),
              .CLK_B1(RD_CLK2),
              .WDATA_A1(WR_DATA2[17:0]),
              .RDATA_A1({EMPTY2, ALMOST_EMPTY2, PROG_EMPTY2, UNDERFLOW2, FULL2, ALMOST_FULL2, PROG_FULL2, OVERFLOW2}),
              .RDATA_B1(RD_DATA2[17:0]),
              .FLUSH1(RESET2),
              .CLK_A2(WR_CLK2),
              .CLK_B2(RD_CLK2)
          );
      end

  else if (data_width_write2 == 4'b1001 && data_width_read2 == 4'b1001)
      begin
          wire [17:0] rd_data2;
          assign RD_DATA2 = {rd_data2[16], rd_data2[7:0]};
          RS_TDP36K #(
              // ----------------------------------------------------------Appending 12th bit as dont care bit
              .MODE_BITS({fifo_type2, {4{3'b100}}, 1'b1, 1'b0, 1'b0, 1'b0, 1'bx, PROG_EMPTY_THRESH2[10:0], 1'bx, PROG_FULL_THRESH2[10:0], 39'b000000000000000000000000000000000000000, 1'b1})
              )
          RS_TDP36K_W9_R9 (
              .WEN_A1(WR_EN2),
              .REN_B1(RD_EN2),
              .CLK_A1(WR_CLK2),
              .CLK_B1(RD_CLK2),
              .WDATA_A1({1'bx, WR_DATA2[8], {8{1'bx}}, WR_DATA2[7:0]}),
              .RDATA_A1({EMPTY2, ALMOST_EMPTY2, PROG_EMPTY2, UNDERFLOW2, FULL2, ALMOST_FULL2, PROG_FULL2, OVERFLOW2}),
              .RDATA_B1(rd_data2),
              .FLUSH1(RESET2),
              .CLK_A2(WR_CLK2),
              .CLK_B2(RD_CLK2)
          );
      end
  else if (data_width_write2 == 5'b10010 && data_width_read2 == 4'b1001)
      begin
          wire [17:0] rd_data2;
          assign RD_DATA2 = {rd_data2[16], rd_data2[7:0]};
          // ----------------------------------------------------------Appending 12th bit as dont care bit
          RS_TDP36K #(
              .MODE_BITS({fifo_type2, {2{3'b100}}, {2{3'b010}}, 1'b1, 1'b0, 1'b0, 1'b0, 1'bx, PROG_EMPTY_THRESH2[10:0], 1'bx, PROG_FULL_THRESH2[10:0], 39'b000000000000000000000000000000000000000, 1'b1})
              )
          RS_TDP36K_W18_R9 (
              .WEN_A1(WR_EN2),
              .REN_B1(RD_EN2),
              .CLK_A1(WR_CLK2),
              .CLK_B1(RD_CLK2),
              .WDATA_A1({WR_DATA2[17], WR_DATA2[8], WR_DATA2[16:9], WR_DATA2[7:0]}),
              .RDATA_A1({EMPTY2, ALMOST_EMPTY2, PROG_EMPTY2, UNDERFLOW2, FULL2, ALMOST_FULL2, PROG_FULL2, OVERFLOW2}),
              .RDATA_B1(rd_data2),
              .FLUSH1(RESET2),
              .CLK_A2(WR_CLK2),
              .CLK_B2(RD_CLK2)
          );
      end
  else
      begin
          wire [17:0] rd_data2;
          assign RD_DATA2 = {rd_data2[17], rd_data2[15:8], rd_data2[16], rd_data2[7:0]};
          RS_TDP36K #(
              // ----------------------------------------------------------Appending 12th bit as dont care bit
              .MODE_BITS({fifo_type2, {2{3'b010}}, {2{3'b100}}, 1'b1, 1'b0, 1'b0, 1'b0, 1'bx, PROG_EMPTY_THRESH2[10:0], 1'bx, PROG_FULL_THRESH2[10:0], 39'b000000000000000000000000000000000000000, 1'b1})
              )
          RS_TDP36K_W9_R18 (
              .WEN_A1(WR_EN2),
              .REN_B1(RD_EN2),
              .CLK_A1(WR_CLK2),
              .CLK_B1(RD_CLK2),
              .WDATA_A1({1'bx, WR_DATA2[8], {8{1'bx}}, WR_DATA2[7:0]}),
              .RDATA_A1({EMPTY2, ALMOST_EMPTY2, PROG_EMPTY2, UNDERFLOW2, FULL2, ALMOST_FULL2, PROG_FULL2, OVERFLOW2}),
              .RDATA_B1(rd_data2),
              .FLUSH1(RESET2),
              .CLK_A2(WR_CLK2),
              .CLK_B2(RD_CLK2)
          );
      end

endgenerate

endmodule
