// --------------------------------------------------------------------------
// ---------------- Copyright (C) 2023 RapidSilicon -------------------------
// --------------------------------------------------------------------------
// ---------------------- FIFO36K Primitive ---------------------------------
// --------------------------------------------------------------------------

module FIFO36K #(
    parameter   DATA_WRITE_WIDTH    = 6'b100100,           // Supported Data Width: 9, 18 and 36 for translation in hardware
    parameter   DATA_READ_WIDTH     = 6'b100100,           // Supported Data Width: 9, 18 and 36 for translation in hardware
    parameter   FIFO_TYPE           = "SYNCHRONOUS",       // Synchronous or Asynchronous
    parameter   PROG_FULL_THRESH    = 12'b111111111010,    // Threshold indicating that the FIFO buffer is considered Full
    parameter   PROG_EMPTY_THRESH   = 12'b000000000100     // Threshold indicating that the FIFO buffer is considered Empty
)
(
    input wire  [DATA_WRITE_WIDTH-1:0] WR_DATA,            // 36-bits Data coming inside FIFO
    output wire [DATA_READ_WIDTH-1:0] RD_DATA,             // 36-bits Data coming out from FIFO
    output wire EMPTY,                                     // 1-bit output: Empty Flag
    output wire FULL,                                      // 1-bit output: Full Flag
    output wire OVERFLOW,                                  // 1-bit output: Overflow Flag 
    output wire UNDERFLOW,                                 // 1-bit output: Underflow Flag
    input wire  RD_EN,                                     // 1-bit input:  Read Enable
    input wire  WR_EN,                                     // 1-bit input:  Write Enable
    output wire ALMOST_EMPTY,                              // 1-bit output: This Flag is asserted when FIFO contains EMPTY plus one data words.
    output wire ALMOST_FULL,                               // 1-bit output: This Flag is asserted when FIFO contains FULL minus one data words.
    output wire PROG_EMPTY,                                // 1-bit output: Empty Watermark Flag
    output wire PROG_FULL,                                 // 1-bit output: Full Watermark Flag
    input wire  WR_CLK,                                    // 1-bit input:  Write Clock
    input wire  RD_CLK,                                    // 1-bit input:  Read Clock
    input wire  RESET                                      // 1-bit input:  Active Low Synchronous Reset
);

initial begin
    if ((DATA_WRITE_WIDTH < 1'b1) || (DATA_WRITE_WIDTH > 6'b100100)) begin
       $display("FIFO36K instance %m DATA_WRITE_WIDTH set to incorrect value, %d.  Values must be between 1 and 36.", DATA_WRITE_WIDTH);
    #1 $stop;
    end
    if ((DATA_READ_WIDTH < 1'b1) || (DATA_READ_WIDTH > 6'b100100)) begin
       $display("FIFO36K instance %m DATA_READ_WIDTH set to incorrect value, %d.  Values must be between 1 and 36.", DATA_READ_WIDTH);
    #1 $stop;
    end
    case(FIFO_TYPE)
      "SYNCHRONOUS" ,
      "ASYNCHRONOUS": begin end
      default: begin
        $display("\nError: FIFO36K instance %m has parameter FIFO_TYPE set to %s.  Valid values are SYNCHRONOUS, ASYNCHRONOUS\n", FIFO_TYPE);
        #1 $stop ;
      end
    endcase
end

// Synchronous/Asynchronous FIFO 
localparam fifo_type   = (FIFO_TYPE == "SYNCHRONOUS")     ? 1'b1      : 1'b0;

// FIFO
generate
    if (DATA_WRITE_WIDTH == 6'b100100 && DATA_READ_WIDTH == 6'b100100)
        begin
            RS_TDP36K #(
                .MODE_BITS({fifo_type, {4{3'b110}}, 1'b1, 1'b0, 1'b0, 1'b0, PROG_EMPTY_THRESH[11:0], PROG_FULL_THRESH[11:0], 39'b000000000000000000000000000000000000000, 1'b0})
                )
            RS_TDP36K_W36_R36 (
                .WEN_A1(WR_EN),
                .REN_B1(RD_EN),
                .CLK_A1(WR_CLK),
                .CLK_B1(RD_CLK),
                .WDATA_A1(WR_DATA[17:0]),
                .WDATA_A2(WR_DATA[35:18]),
                .RDATA_A1({EMPTY, ALMOST_EMPTY, PROG_EMPTY, UNDERFLOW, FULL, ALMOST_FULL, PROG_FULL, OVERFLOW}),
                .RDATA_B1(RD_DATA[17:0]),
                .RDATA_B2(RD_DATA[35:18]),
                .FLUSH1(RESET),
                .CLK_A2(WR_CLK),
                .CLK_B2(RD_CLK)
            );
        end

    else if (DATA_WRITE_WIDTH == 5'b10010 && DATA_READ_WIDTH == 5'b10010)
        begin
            RS_TDP36K #(
                // ----------------------------------------------------------Appending 12th bit as dont care bit
                .MODE_BITS({fifo_type, {4{3'b010}}, 1'b1, 1'b0, 1'b0, 1'b0, 1'bx, PROG_EMPTY_THRESH[10:0], 1'bx, PROG_FULL_THRESH[10:0], 39'b000000000000000000000000000000000000000, 1'b1})
                )
            RS_TDP36K_W18_R18 (
                .WEN_A1(WR_EN),
                .REN_B1(RD_EN),
                .CLK_A1(WR_CLK),
                .CLK_B1(RD_CLK),
                .WDATA_A1(WR_DATA[17:0]),
                .RDATA_A1({EMPTY, ALMOST_EMPTY, PROG_EMPTY, UNDERFLOW, FULL, ALMOST_FULL, PROG_FULL, OVERFLOW}),
                .RDATA_B1(RD_DATA[17:0]),
                .FLUSH1(RESET),
                .CLK_A2(WR_CLK),
                .CLK_B2(RD_CLK)
            );
        end

    else if (DATA_WRITE_WIDTH == 4'b1001 && DATA_READ_WIDTH == 4'b1001)
        begin
            wire [17:0] rd_data;
            assign RD_DATA = {rd_data[16], rd_data[7:0]};
            RS_TDP36K #(
                // ----------------------------------------------------------Appending 12th bit as dont care bit
                .MODE_BITS({fifo_type, {4{3'b100}}, 1'b1, 1'b0, 1'b0, 1'b0, 1'bx, PROG_EMPTY_THRESH[10:0], 1'bx, PROG_FULL_THRESH[10:0], 39'b000000000000000000000000000000000000000, 1'b1})
                )
            RS_TDP36K_W9_R9 (
                .WEN_A1(WR_EN),
                .REN_B1(RD_EN),
                .CLK_A1(WR_CLK),
                .CLK_B1(RD_CLK),
                .WDATA_A1({1'bx, WR_DATA[8], {8{1'bx}}, WR_DATA[7:0]}),
                .RDATA_A1({EMPTY, ALMOST_EMPTY, PROG_EMPTY, UNDERFLOW, FULL, ALMOST_FULL, PROG_FULL, OVERFLOW}),
                .RDATA_B1(rd_data),
                .FLUSH1(RESET),
                .CLK_A2(WR_CLK),
                .CLK_B2(RD_CLK)
            );
        end
    else if (DATA_WRITE_WIDTH == 6'b100100 && DATA_READ_WIDTH == 5'b10010)
        begin
            RS_TDP36K #(
                .MODE_BITS({fifo_type, {2{3'b010}}, {2{3'b110}}, 1'b1, 1'b0, 1'b0, 1'b0, PROG_EMPTY_THRESH[11:0], PROG_FULL_THRESH[11:0], 39'b000000000000000000000000000000000000000, 1'b0})
                )
            RS_TDP36K_W36_R18 (
                .WEN_A1(WR_EN),
                .REN_B1(RD_EN),
                .CLK_A1(WR_CLK),
                .CLK_B1(RD_CLK),
                .WDATA_A1(WR_DATA[17:0]),
                .WDATA_A2(WR_DATA[35:18]),
                .RDATA_A1({EMPTY, ALMOST_EMPTY, PROG_EMPTY, UNDERFLOW, FULL, ALMOST_FULL, PROG_FULL, OVERFLOW}),
                .RDATA_B1(RD_DATA[17:0]),
                .FLUSH1(RESET),
                .CLK_A2(WR_CLK),
                .CLK_B2(RD_CLK)
            );
        end
    else if (DATA_WRITE_WIDTH == 6'b100100 && DATA_READ_WIDTH == 4'b1001)
        begin
            wire [17:0] rd_data;
            assign RD_DATA = {rd_data[16], rd_data[7:0]};
            RS_TDP36K #(
                .MODE_BITS({fifo_type, {2{3'b100}}, {2{3'b110}}, 1'b1, 1'b0, 1'b0, 1'b0, PROG_EMPTY_THRESH[11:0], PROG_FULL_THRESH[11:0], 39'b000000000000000000000000000000000000000, 1'b0})
                )
            RS_TDP36K_W36_R9 (
                .WEN_A1(WR_EN),
                .REN_B1(RD_EN),
                .CLK_A1(WR_CLK),
                .CLK_B1(RD_CLK),
                .WDATA_A1({WR_DATA[17], WR_DATA[8], WR_DATA[16:9], WR_DATA[7:0]}),
                .WDATA_A2({WR_DATA[35], WR_DATA[26], WR_DATA[34:27], WR_DATA[25:18]}),
                .RDATA_A1({EMPTY, ALMOST_EMPTY, PROG_EMPTY, UNDERFLOW, FULL, ALMOST_FULL, PROG_FULL, OVERFLOW}),
                .RDATA_B1(rd_data),
                .FLUSH1(RESET),
                .CLK_A2(WR_CLK),
                .CLK_B2(RD_CLK)
            );
        end
    else if (DATA_WRITE_WIDTH == 5'b10010 && DATA_READ_WIDTH == 4'b1001)
        begin
            wire [17:0] rd_data;
            assign RD_DATA = {rd_data[16], rd_data[7:0]};
            // ----------------------------------------------------------Appending 12th bit as dont care bit
            RS_TDP36K #(
                .MODE_BITS({fifo_type, {2{3'b100}}, {2{3'b010}}, 1'b1, 1'b0, 1'b0, 1'b0, 1'bx, PROG_EMPTY_THRESH[10:0], 1'bx, PROG_FULL_THRESH[10:0], 39'b000000000000000000000000000000000000000, 1'b1})
                )
            RS_TDP36K_W18_R9 (
                .WEN_A1(WR_EN),
                .REN_B1(RD_EN),
                .CLK_A1(WR_CLK),
                .CLK_B1(RD_CLK),
                .WDATA_A1({WR_DATA[17], WR_DATA[8], WR_DATA[16:9], WR_DATA[7:0]}),
                .RDATA_A1({EMPTY, ALMOST_EMPTY, PROG_EMPTY, UNDERFLOW, FULL, ALMOST_FULL, PROG_FULL, OVERFLOW}),
                .RDATA_B1(rd_data),
                .FLUSH1(RESET),
                .CLK_A2(WR_CLK),
                .CLK_B2(RD_CLK)
            );
        end
    else if (DATA_WRITE_WIDTH == 4'b1001 && DATA_READ_WIDTH == 5'b10010)
        begin
            wire [17:0] rd_data;
            assign RD_DATA = {rd_data[17], rd_data[15:8], rd_data[16], rd_data[7:0]};
            RS_TDP36K #(
                // ----------------------------------------------------------Appending 12th bit as dont care bit
                .MODE_BITS({fifo_type, {2{3'b010}}, {2{3'b100}}, 1'b1, 1'b0, 1'b0, 1'b0, 1'bx, PROG_EMPTY_THRESH[10:0], 1'bx, PROG_FULL_THRESH[10:0], 39'b000000000000000000000000000000000000000, 1'b1})
                )
            RS_TDP36K_W9_R18 (
                .WEN_A1(WR_EN),
                .REN_B1(RD_EN),
                .CLK_A1(WR_CLK),
                .CLK_B1(RD_CLK),
                .WDATA_A1({1'bx, WR_DATA[8], {8{1'bx}}, WR_DATA[7:0]}),
                .RDATA_A1({EMPTY, ALMOST_EMPTY, PROG_EMPTY, UNDERFLOW, FULL, ALMOST_FULL, PROG_FULL, OVERFLOW}),
                .RDATA_B1(rd_data),
                .FLUSH1(RESET),
                .CLK_A2(WR_CLK),
                .CLK_B2(RD_CLK)
            );
        end
    else if (DATA_WRITE_WIDTH == 5'b10010 && DATA_READ_WIDTH == 6'b100100)
        begin
            RS_TDP36K #(
                .MODE_BITS({fifo_type, {2{3'b110}}, {2{3'b010}}, 1'b1, 1'b0, 1'b0, 1'b0, PROG_EMPTY_THRESH[11:0], PROG_FULL_THRESH[11:0], 39'b000000000000000000000000000000000000000, 1'b0})
                )
            RS_TDP36K_W18_R36 (
                .WEN_A1(WR_EN),
                .REN_B1(RD_EN),
                .CLK_A1(WR_CLK),
                .CLK_B1(RD_CLK),
                .WDATA_A1(WR_DATA[17:0]),
                .RDATA_A1({EMPTY, ALMOST_EMPTY, PROG_EMPTY, UNDERFLOW, FULL, ALMOST_FULL, PROG_FULL, OVERFLOW}),
                .RDATA_B1(RD_DATA[17:0]),
                .RDATA_B2(RD_DATA[35:18]),
                .FLUSH1(RESET),
                .CLK_A2(WR_CLK),
                .CLK_B2(RD_CLK)
            );
        end
    else 
        begin
            wire [35:0] rd_data;
            assign RD_DATA = {rd_data[35], rd_data[33:26], rd_data[34], rd_data[25:18], rd_data[17], rd_data[15:8] ,rd_data[16], rd_data[7:0]};
            RS_TDP36K #(
                .MODE_BITS({fifo_type, {2{3'b110}}, {2{3'b100}}, 1'b1, 1'b0, 1'b0, 1'b0, PROG_EMPTY_THRESH[11:0], PROG_FULL_THRESH[11:0], 39'b000000000000000000000000000000000000000, 1'b0})
                )
            RS_TDP36K_W9_R36 (
                .WEN_A1(WR_EN),
                .REN_B1(RD_EN),
                .CLK_A1(WR_CLK),
                .CLK_B1(RD_CLK),
                .WDATA_A1({1'bx, WR_DATA[8], {8{1'bx}}, WR_DATA[7:0]}),
                .RDATA_A1({EMPTY, ALMOST_EMPTY, PROG_EMPTY, UNDERFLOW, FULL, ALMOST_FULL, PROG_FULL, OVERFLOW}),
                .RDATA_B1(rd_data[17:0]),
                .RDATA_B2(rd_data[35:18]),
                .FLUSH1(RESET),
                .CLK_A2(WR_CLK),
                .CLK_B2(RD_CLK)
            );
        end

endgenerate

endmodule
