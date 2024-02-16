`timescale 1ns/1ps
`celldefine
//
// TDP_RAM18KX2 Mapping model
// Dual 18Kb True-dual-port RAM
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module TDP_RAM18KX2 #(
  parameter [16383:0] INIT1         = {16384{1'b0}}, // Initial Contents of data memory, RAM 1
  parameter [2047:0] INIT1_PARITY   = {2048{1'b0}}, // Initial Contents of parity memory, RAM 1
  parameter WRITE_WIDTH_A1          = 18, // Write data width on port A, RAM 1 (1,2,4,9,18)
  parameter WRITE_WIDTH_B1          = 18, // Write data width on port B, RAM 1 (1,2,4,9,18)
  parameter READ_WIDTH_A1           = 18, // Read data width on port A, RAM 1  (1,2,4,9,18)
  parameter READ_WIDTH_B1           = 18, // Read data width on port B, RAM 1  (1,2,4,9,18)
  parameter [16383:0] INIT2         = {16384{1'b0}}, // Initial Contents of memory, RAM 2
  parameter [2047:0] INIT2_PARITY   = {2048{1'b0}}, // Initial Contents of memory, RAM 2
  parameter WRITE_WIDTH_A2          = 18, // Write data width on port A, RAM 2 (1,2,4,9,18)
  parameter WRITE_WIDTH_B2          = 18, // Write data width on port B, RAM 2 (1,2,4,9,18)
  parameter READ_WIDTH_A2           = 18, // Read data width on port A, RAM 2  (1,2,4,9,18)
  parameter READ_WIDTH_B2           = 18 // Read data width on port B, RAM 2   (1,2,4,9,18)
) 
(
  // Ports
  input WEN_A1, // Write-enable port A, RAM 1
  input WEN_B1, // Write-enable port B, RAM 1
  input REN_A1, // Read-enable port A, RAM 1
  input REN_B1, // Read-enable port B, RAM 1
  input CLK_A1, // Clock port A, RAM 1
  input CLK_B1, // Clock port B, RAM 1
  input [1:0] BE_A1, // Byte-write enable port A, RAM 1
  input [1:0] BE_B1, // Byte-write enable port B, RAM 1
  input [13:0] ADDR_A1, // Address port A, RAM 1
  input [13:0] ADDR_B1, // Address port B, RAM 1
  input [15:0] WDATA_A1, // Write data port A, RAM 1
  input [1:0] WPARITY_A1, // Write parity port A, RAM 1
  input [15:0] WDATA_B1, // Write data port B, RAM 1
  input [1:0] WPARITY_B1, // Write parity port B, RAM 1
  output wire [15:0] RDATA_A1 , // Read data port A, RAM 1
  output wire [1:0] RPARITY_A1, // Read parity port A, RAM 1
  output wire [15:0] RDATA_B1 , // Read data port B, RAM 1
  output wire [1:0] RPARITY_B1, // Read parity port B, RAM 1
  input WEN_A2, // Write-enable port A, RAM 2
  input WEN_B2, // Write-enable port B, RAM 2
  input REN_A2, // Read-enable port A, RAM 2
  input REN_B2, // Read-enable port B, RAM 2
  input CLK_A2, // Clock port A, RAM 2
  input CLK_B2, // Clock port B, RAM 2
  input [1:0] BE_A2, // Byte-write enable port A, RAM 2
  input [1:0] BE_B2, // Byte-write enable port B, RAM 2
  input [13:0] ADDR_A2, // Address port A, RAM 2
  input [13:0] ADDR_B2, // Address port B, RAM 2
  input [15:0] WDATA_A2, // Write data port A, RAM 2
  input [1:0] WPARITY_A2, // Write parity port A, RAM 2
  input [15:0] WDATA_B2, // Write data port B, RAM 2
  input [1:0] WPARITY_B2, // Write parity port B, RAM 2
  output wire [15:0] RDATA_A2 , // Read data port A, RAM 2
  output wire [1:0] RPARITY_A2, // Read parity port A, RAM 2
  output wire [15:0] RDATA_B2 , // Read data port B, RAM 2
  output wire [1:0] RPARITY_B2 // Read parity port B, RAM 2
);

// Internal Wires
wire [17:0] DATA_OUT_A1;
wire [17:0] DATA_OUT_A2;
wire [17:0] DATA_OUT_B1;
wire [17:0] DATA_OUT_B2;

// Port 1 Read-Write Modes
localparam write_mode_A1 =  WRITE_WIDTH_A1 == 18 ? 3'b010 : 
                            WRITE_WIDTH_A1 == 9  ? 3'b100 :
                            WRITE_WIDTH_A1 == 4  ? 3'b001 :
                            WRITE_WIDTH_A1 == 2  ? 3'b011 : 3'b101 ;

localparam read_mode_A1  =  READ_WIDTH_A1  == 18 ? 3'b010 : 
                            READ_WIDTH_A1  == 9  ? 3'b100 :
                            READ_WIDTH_A1  == 4  ? 3'b001 :
                            READ_WIDTH_A1  == 2  ? 3'b011 : 3'b101 ;

localparam write_mode_B1 =  WRITE_WIDTH_B1 == 18 ? 3'b010 : 
                            WRITE_WIDTH_B1 == 9  ? 3'b100 :
                            WRITE_WIDTH_B1 == 4  ? 3'b001 :
                            WRITE_WIDTH_B1 == 2  ? 3'b011 : 3'b101 ;

localparam read_mode_B1  =  READ_WIDTH_B1  == 18 ? 3'b010 : 
                            READ_WIDTH_B1  == 9  ? 3'b100 :
                            READ_WIDTH_B1  == 4  ? 3'b001 :
                            READ_WIDTH_B1  == 2  ? 3'b011 : 3'b101 ;

// Port 2 Read-Write Modes
localparam write_mode_A2 =  WRITE_WIDTH_A2 == 18 ? 3'b010 : 
                            WRITE_WIDTH_A2 == 9  ? 3'b100 :
                            WRITE_WIDTH_A2 == 4  ? 3'b001 :
                            WRITE_WIDTH_A2 == 2  ? 3'b011 : 3'b101 ;

localparam read_mode_A2  =  READ_WIDTH_A2  == 18 ? 3'b010 : 
                            READ_WIDTH_A2  == 9  ? 3'b100 :
                            READ_WIDTH_A2  == 4  ? 3'b001 :
                            READ_WIDTH_A2  == 2  ? 3'b011 : 3'b101 ;

localparam write_mode_B2 =  WRITE_WIDTH_B2 == 18 ? 3'b010 : 
                            WRITE_WIDTH_B2 == 9  ? 3'b100 :
                            WRITE_WIDTH_B2 == 4  ? 3'b001 :
                            WRITE_WIDTH_B2 == 2  ? 3'b011 : 3'b101 ;

localparam read_mode_B2  =  READ_WIDTH_B2  == 18 ? 3'b010 : 
                            READ_WIDTH_B2  == 9  ? 3'b100 :
                            READ_WIDTH_B2  == 4  ? 3'b001 :
                            READ_WIDTH_B2  == 2  ? 3'b011 : 3'b101 ;

// Memory Initialization
function [18432-1:0] sram1();
    integer i;
    sram1 = {18432{1'b0}};
    for (i = 0; i < 1024; i=i+1) begin // (1024*18) = 18432 bits
        sram1[(i*18) +:16]               = INIT1[(i*16) +:16];       // Extracts first 16-bits from INIT1 and place into fisrt 16 places in SRAM1.
        sram1[((i+1)*16+(2*i))+:2]       = INIT1_PARITY[(i*2) +:2];  // Extracts first 2-bits from INIT1_PARITY and place into the next two places in SRAM1.
        end
endfunction

function [18432-1:0] sram2();
    integer i;
    sram2 = {18432{1'b0}};
    for (i = 0; i < 1024; i=i+1) begin // (1024*18) = 18432 bits
        sram2[(i*18) +:16]                = INIT2[(i*16) +:16];      // Extracts first 16-bits from INIT2 and place into fisrt 16 places in SRAM2..
        sram2[((i+1)*16+(2*i)) +:2]      = INIT2_PARITY[(i*2) +:2]; // Extracts first 2-bits from INIT2_PARITY and place into the next two places in SRAM2.
        end
endfunction

localparam [36863:0] INIT_i1 = {sram2(), sram1()};

// Mode Bits (Split Mode)
localparam MODE_BITS = {1'b0, read_mode_A1, read_mode_B1, write_mode_A1, write_mode_B1, 29'd0, read_mode_A2, read_mode_B2, write_mode_A2, write_mode_B2, 26'd0, 1'd1};

// Data Out logic
// Port 1
assign RDATA_A1   = DATA_OUT_A1[15:0];
assign RDATA_B1   = DATA_OUT_B1[15:0];
assign RPARITY_A1 = DATA_OUT_A1[17:16];
assign RPARITY_B1 = DATA_OUT_B1[17:16];
// Port 2
assign RDATA_A2   = DATA_OUT_A2[15:0];
assign RDATA_B2   = DATA_OUT_B2[15:0];
assign RPARITY_A2 = DATA_OUT_A2[17:16];
assign RPARITY_B2 = DATA_OUT_B2[17:16];

// Old Model
RS_TDP36K  #(
    .MODE_BITS(MODE_BITS),
    .INIT_i(INIT_i1)
) RS_TDP36K_inst (
    .WEN_A1(WEN_A1),
    .WEN_B1(WEN_B1),
    .REN_A1(REN_A1),
    .REN_B1(REN_B1),
    .CLK_A1(CLK_A1),
    .CLK_B1(CLK_B1),
    .BE_A1(BE_A1[1:0]),
    .BE_B1(BE_B1[1:0]),
    .ADDR_A1(ADDR_A1),
    .ADDR_B1(ADDR_B1),
    .WDATA_A1({WPARITY_A1[1:0], WDATA_A1[15:0]}),
    .WDATA_B1({WPARITY_B1[1:0], WDATA_B1[15:0]}),
    .RDATA_A1(DATA_OUT_A1),
    .RDATA_B1(DATA_OUT_B1),
    .FLUSH1(1'b0),
    .WEN_A2(WEN_A2),
    .WEN_B2(WEN_B2),
    .REN_A2(REN_A2),
    .REN_B2(REN_B2),
    .CLK_A2(CLK_A2),
    .CLK_B2(CLK_B2),
    .BE_A2(BE_A2[1:0]),
    .BE_B2(BE_B2[1:0]),
    .ADDR_A2(ADDR_A2),
    .ADDR_B2(ADDR_B2),
    .WDATA_A2({WPARITY_A2[1:0], WDATA_A2[15:0]}),
    .WDATA_B2({WPARITY_B2[1:0], WDATA_B2[15:0]}),
    .RDATA_A2(DATA_OUT_A2),
    .RDATA_B2(DATA_OUT_B2),
    .FLUSH2(1'b0)
);

initial 
begin
    // write data width for Port A1
    case (WRITE_WIDTH_A1)
        18,
        9,
        4,
        2,
        1
        : begin end
        default: begin
            $error("Invalid WRITE_WIDTH_A1 %0d\nChoose any value from [18, 9, 4, 2, 1]", WRITE_WIDTH_A1);
            $finish;
        end
    endcase
    
    // read data width for Port A1
    case (READ_WIDTH_A1)
        18,
        9,
        4,
        2,
        1
        : begin end
        default: begin
            $error("Invalid READ_WIDTH_A1 %0d\nChoose any value from [18, 9, 4, 2, 1]", READ_WIDTH_A1);
            $finish;
        end
    endcase

    // write data width for Port B1
    case (WRITE_WIDTH_B1)
        18,
        9,
        4,
        2,
        1
        : begin end
        default: begin
            $error("Invalid WRITE_WIDTH_B1 %0d\nChoose any value from [18, 9, 4, 2, 1]", WRITE_WIDTH_B1);
            $finish;
        end
    endcase

    // read data width for Port B1
    case (READ_WIDTH_B1)
        18,
        9,
        4,
        2,
        1
        : begin end
        default: begin
            $error("Invalid READ_WIDTH_B1 %0d\nChoose any value from [18, 9, 4, 2, 1]", READ_WIDTH_B1);
            $finish;
        end
    endcase


    // write data width for Port A2
    case (WRITE_WIDTH_A2)
        18,
        9,
        4,
        2,
        1
        : begin end
        default: begin
            $error("Invalid WRITE_WIDTH_A1 %0d\nChoose any value from [18, 9, 4, 2, 1]", WRITE_WIDTH_A2);
            $finish;
        end
    endcase
    
    // read data width for Port A2
    case (READ_WIDTH_A2)
        18,
        9,
        4,
        2,
        1
        : begin end
        default: begin
            $error("Invalid READ_WIDTH_A1 %0d\nChoose any value from [18, 9, 4, 2, 1]", READ_WIDTH_A2);
            $finish;
        end
    endcase

    // write data width for Port B2
    case (WRITE_WIDTH_B2)
        18,
        9,
        4,
        2,
        1
        : begin end
        default: begin
            $error("Invalid WRITE_WIDTH_B1 %0d\nChoose any value from [18, 9, 4, 2, 1]", WRITE_WIDTH_B2);
            $finish;
        end
    endcase

    // read data width for Port B2
    case (READ_WIDTH_B2)
        18,
        9,
        4,
        2,
        1
        : begin end
        default: begin
            $error("Invalid READ_WIDTH_B1 %0d\nChoose any value from [18, 9, 4, 2, 1]", READ_WIDTH_B2);
            $finish;
        end
    endcase

end

endmodule
