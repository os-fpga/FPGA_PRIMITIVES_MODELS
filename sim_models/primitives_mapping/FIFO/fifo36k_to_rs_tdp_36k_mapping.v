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
    if (!(DATA_WRITE_WIDTH == 6'b100100 || DATA_WRITE_WIDTH == 6'b010010 || DATA_WRITE_WIDTH == 6'b001001)) begin
       $display("FIFO36K instance %m DATA_WRITE_WIDTH set to incorrect value, %d.  Values must be either 9, 18 or 36.", DATA_WRITE_WIDTH);
    #1 $stop;
    end
    if (!(DATA_READ_WIDTH == 6'b100100 || DATA_READ_WIDTH == 6'b010010 || DATA_READ_WIDTH == 6'b01001)) begin
       $display("FIFO36K instance %m DATA_READ_WIDTH set to incorrect value, %d.  Values must be either 9, 18 or 36.", DATA_READ_WIDTH);
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
localparam fifo_type           = (FIFO_TYPE == "SYNCHRONOUS")     ? 1'b1      : 1'b0;
localparam data_width_write    = (DATA_WRITE_WIDTH == 6'd36) ? 3'b110 : 
                                 (DATA_WRITE_WIDTH == 6'd18) ? 3'b010 : 3'b100;
localparam data_width_read     = (DATA_READ_WIDTH == 6'd36) ? 3'b110 : 
                                 (DATA_READ_WIDTH == 6'd18) ? 3'b010 : 3'b100;

wire [35:0] wrt_data;
wire [35:0] rd_data;
wire [17:0] fifo_flags;
wire [17:0] unused_rdataA2;
wire rd_clk;

assign OVERFLOW = fifo_flags[0];
assign PROG_FULL = fifo_flags[1];
assign ALMOST_FULL = fifo_flags[2];
assign FULL = fifo_flags[3];
assign UNDERFLOW = fifo_flags[4];
assign PROG_EMPTY = fifo_flags[5];
assign ALMOST_EMPTY = fifo_flags[6];
assign EMPTY = fifo_flags[7];
assign rd_clk = (FIFO_TYPE == "SYNCHRONOUS") ? WR_CLK : RD_CLK;

if (DATA_READ_WIDTH == 6'd36) begin
    assign RD_DATA = {rd_data[35], rd_data[33:26], rd_data[34], rd_data[25:18], rd_data[17], rd_data[15:8], rd_data[16], rd_data[7:0]};
end else if (DATA_READ_WIDTH == 5'd18) begin
    assign RD_DATA = {rd_data[17], rd_data[15:8], rd_data[16], rd_data[7:0]};
end else begin
    assign RD_DATA = {rd_data[16], rd_data[7:0]};
end

if (DATA_WRITE_WIDTH == 6'd36) begin
    assign wrt_data = {WR_DATA[35], WR_DATA[26], WR_DATA[34:27], WR_DATA[25:18], WR_DATA[17], WR_DATA[8], WR_DATA[16:9], WR_DATA[7:0]};
end else if (DATA_WRITE_WIDTH == 5'd18) begin
    assign wrt_data = {18'dx, WR_DATA[17], WR_DATA[8], WR_DATA[16:9], WR_DATA[7:0]};
end else begin
    assign wrt_data = {19'bx, WR_DATA[8], 8'dx, WR_DATA[7:0]};
end

// FIFO
    RS_TDP36K #(
        .MODE_BITS({fifo_type, {2{data_width_read[2:0]}}, {2{data_width_write[2:0]}}, 1'b1, 1'b0, 1'b0, 1'b0, PROG_EMPTY_THRESH[11:0], PROG_FULL_THRESH[11:0], 40'd0})
        )
    RS_TDP36K_FIFO_36K (
        .WEN_A1(WR_EN),
        .REN_B1(RD_EN),
        .CLK_A1(WR_CLK),
        .CLK_B1(rd_clk),
        .WDATA_A1(wrt_data[17:0]),
        .WDATA_A2(wrt_data[35:18]),
        .RDATA_A1(fifo_flags),
        .RDATA_B1(rd_data[17:0]),
        .RDATA_B2(rd_data[35:18]),
        .FLUSH1(RESET),
        .CLK_A2(WR_CLK),
        .CLK_B2(rd_clk),

        .WEN_B1(1'b0),
        .REN_A1(1'b0),
        .BE_A1(2'd0),
        .BE_B1(2'd0),
        .ADDR_A1(15'd0),
        .ADDR_B1(15'd0),
        .WDATA_B1(18'd0),
        .WEN_B2(1'b0),
        .REN_A2(1'b0),
        .BE_A2(2'd0),
        .BE_B2(2'd0),
        .ADDR_A2(14'd0),
        .ADDR_B2(14'd0),
        .WDATA_B2(18'd0),
        .WEN_A2(1'b0),
        .REN_B2(1'b0),
        .RDATA_A2(unused_rdataA2),
        .FLUSH2(1'b0)
    );



endmodule
