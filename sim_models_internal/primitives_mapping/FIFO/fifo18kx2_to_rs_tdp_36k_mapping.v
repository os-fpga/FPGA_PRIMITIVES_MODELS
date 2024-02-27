// --------------------------------------------------------------------------
// ---------------- Copyright (C) 2023 RapidSilicon -------------------------
// --------------------------------------------------------------------------
// ---------------------- FIFO18KX2 Primitive -------------------------------
// --------------------------------------------------------------------------
// -----------------Revision 1: Simplified Model 27/02/24-------------------//
module FIFO18KX2 #(
    parameter DATA_WRITE_WIDTH1 = 5'b10010,        // Write Data Width of FIFO1: 9 and 18 for translation in hardware
    parameter DATA_READ_WIDTH1 = 5'b10010,         // Read Data Width of FIFO1: 9 and 18 for translation in hardware
    parameter FIFO_TYPE1 = "SYNCHRONOUS",       // Synchronous or Asynchronous FIFO1     
    parameter PROG_EMPTY_THRESH1 = 11'b00000000100,     // Threshold indicating that the FIFO1 buffer is considered Empty
    parameter PROG_FULL_THRESH1 = 11'b10011111010,      // Threshold indicating that the FIFO1 buffer is considered Full
    
    parameter DATA_WRITE_WIDTH2 = 5'b10010,        // Write Data Width of FIFO2: 9 and 18 for transation in hardware
    parameter DATA_READ_WIDTH2 = 5'b10010,         // Read Data Width of FIFO1: 9 and 18 for transation in hardware
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

initial begin
    if (!(DATA_WRITE_WIDTH1 == 5'b10010 || DATA_WRITE_WIDTH1 == 4'b1001)) begin
       $display("FIFO18KX2 instance %m DATA_WRITE_WIDTH1 set to incorrect value, %d.  Values must be either 9 or 18.", DATA_WRITE_WIDTH1);
    #1 $stop;
    end
    if (!(DATA_READ_WIDTH1 == 5'b10010 || DATA_READ_WIDTH1 == 4'b1001)) begin
       $display("FIFO18KX2 instance %m DATA_READ_WIDTH1 set to incorrect value, %d.  Values must be either 9 or 18.", DATA_READ_WIDTH1);
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

    if (!(DATA_WRITE_WIDTH2 == 5'b10010 || DATA_WRITE_WIDTH2 == 4'b1001)) begin
       $display("FIFO18KX2 instance %m DATA_WRITE_WIDTH2 set to incorrected value, %d.  Values must be either 9 or 18.", DATA_WRITE_WIDTH2);
    #1 $stop;
    end
    if (!(DATA_READ_WIDTH2 == 5'b10010 || DATA_READ_WIDTH2 == 4'b1001)) begin
       $display("FIFO18KX2 instance %m DATA_READ_WIDTH2 set to incorrect value, %d.  Values must be either 9 or 18.", DATA_READ_WIDTH2);
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
localparam fifo_type1           = (FIFO_TYPE1 == "SYNCHRONOUS") ? 1'b1 : 1'b0;
localparam fifo_type2           = (FIFO_TYPE2 == "SYNCHRONOUS") ? 1'b1 : 1'b0;
localparam data_width_write1    = (DATA_WRITE_WIDTH1 == 5'd18) ? 3'b010 : 3'b100;
localparam data_width_read1     = (DATA_READ_WIDTH1 == 5'd18) ? 3'b010 : 3'b100;
localparam data_width_write2    = (DATA_WRITE_WIDTH2 == 5'd18) ? 3'b010 : 3'b100;
localparam data_width_read2     = (DATA_READ_WIDTH2 == 5'd18) ? 3'b010 : 3'b100;


wire [17:0] wrt_data1;
wire [17:0] rd_data1;
wire [17:0] wrt_data2;
wire [17:0] rd_data2;
wire [17:0] fifo1_flags;
wire [17:0] fifo2_flags;

assign OVERFLOW1 = fifo1_flags[0];
assign PROG_FULL1 = fifo1_flags[1];
assign ALMOST_EMPTY1 = fifo1_flags[2];
assign FULL1 = fifo1_flags[3];
assign UNDERFLOW1 = fifo1_flags[4];
assign PROG_EMPTY1 = fifo1_flags[5];
assign ALMOST_EMPTY1 = fifo1_flags[6];
assign EMPTY1 = fifo1_flags[7];

assign OVERFLOW2 = fifo2_flags[0];
assign PROG_FULL2 = fifo2_flags[1];
assign ALMOST_EMPTY2 = fifo2_flags[2];
assign FULL2 = fifo2_flags[3];
assign UNDERFLOW2 = fifo2_flags[4];
assign PROG_EMPTY2 = fifo2_flags[5];
assign ALMOST_EMPTY2 = fifo2_flags[6];
assign EMPTY2 = fifo2_flags[7];

if (DATA_READ_WIDTH1 == 5'd18) begin
    assign RD_DATA1 = {rd_data1[17], rd_data1[15:8], rd_data1[16], rd_data1[7:0]};
end else begin
    assign RD_DATA1 = {rd_data1[16], rd_data1[7:0]};
end

if (DATA_WRITE_WIDTH1 == 5'd18) begin
    assign wrt_data1 = {WR_DATA1[17], WR_DATA1[8], WR_DATA1[16:9], WR_DATA1[7:0]};
end else begin
    assign wrt_data1 = {1'bx, WR_DATA1[8], 8'dx, WR_DATA1[7:0]};
end

if (DATA_READ_WIDTH2 == 5'd18) begin
    assign RD_DATA2 = {rd_data2[17], rd_data2[15:8], rd_data2[16], rd_data2[7:0]};
end else begin
    assign RD_DATA2 = {rd_data2[16], rd_data2[7:0]};
end

if (DATA_WRITE_WIDTH2 == 5'd18) begin
    assign wrt_data2 = {WR_DATA2[17], WR_DATA2[8], WR_DATA2[16:9], WR_DATA2[7:0]};
end else begin
    assign wrt_data2 = {1'bx, WR_DATA2[8], 8'dx, WR_DATA2[7:0]};
end

RS_TDP36K #(
    // ----------------------------------------------------------Appending 12th bit as dont care bit
    .MODE_BITS({fifo_type1, {2{data_width_read1[2:0]}}, {2{data_width_write1[2:0]}}, 1'b1, 1'b0, 1'b0, 1'b0, PROG_EMPTY_THRESH1[10:0], 1'bx, PROG_FULL_THRESH1[10:0], 1'bx, fifo_type2, {2{data_width_read2[2:0]}}, {2{data_width_write2[2:0]}}, 1'b1, 1'b0, 1'b0, 1'b0, PROG_EMPTY_THRESH2[10:0], PROG_FULL_THRESH2[10:0], 1'b1})
    )
RS_TDP36K_FIFO_18KX2 (
    .WEN_A1(WR_EN1),
    .REN_B1(RD_EN1),
    .CLK_A1(WR_CLK1),
    .CLK_B1(RD_CLK1),
    .WDATA_A1(wrt_data1),
    .RDATA_A1(fifo1_flags),
    .RDATA_B1(rd_data1),
    .FLUSH1(RESET1),
        
    .WEN_A2(WR_EN2),
    .REN_B2(RD_EN2),
    .WDATA_A2(wrt_data2),
    .RDATA_A2(fifo2_flags),
    .RDATA_B2(rd_data2),
    .FLUSH2(RESET2),
    .CLK_A2(WR_CLK2),
    .CLK_B2(RD_CLK2),

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
    .WDATA_B2(18'd0)
);

endmodule
