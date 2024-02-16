// BRAM Mapping File

`timescale 1ns/1ps

module TDP_RAM36K #(
    parameter [32767:0] INIT          = {32768{1'b0}}, // Initial Contents of data memory
    parameter [4095:0]  INIT_PARITY   = {4096{1'b0}}, // Initial Contents of parity memory
    parameter WRITE_WIDTH_A           = 36, // Write data width on port A (1,2,4,9,18, 36)
    parameter READ_WIDTH_A            = 36, // Read data width on port A  (1,2,4,9,18, 36)
    parameter WRITE_WIDTH_B           = 36, // Write data width on port B (1,2,4,9,18, 36)
    parameter READ_WIDTH_B            = 36  // Read data width on port B  (1,2,4,9,18, 36)
  ) 
  (
    // Ports
    input WEN_A, // Write-enable port A
    input WEN_B, // Write-enable port B
    input REN_A, // Read-enable port A
    input REN_B, // Read-enable port B
    input CLK_A, // Clock port A
    input CLK_B, // Clock port B
    input [3:0] BE_A, // Byte-write enable port A
    input [3:0] BE_B, // Byte-write enable port B
    input [14:0] ADDR_A, // Address port A, align MSBs and connect unused MSBs to logic 0
    input [14:0] ADDR_B, // Address port B, align MSBs and connect unused MSBs to logic 0
    input [31:0] WDATA_A, // Write data port A
    input [3:0] WPARITY_A, // Write parity data port A
    input [31:0] WDATA_B, // Write data port B
    input [3:0] WPARITY_B, // Write parity port B
    output wire [31:0] RDATA_A, // Read data port A
    output wire [3:0] RPARITY_A, // Read parity port A
    output wire [31:0] RDATA_B, // Read data port B
    output wire [3:0] RPARITY_B // Read parity port B
  );
  
  // internal wires
  wire [17:0] DATA_OUT_A1;
  wire [17:0] DATA_OUT_A2;
  wire [17:0] DATA_OUT_B1;
  wire [17:0] DATA_OUT_B2;
  
  wire [17:0] WDATA_A1;
  wire [17:0] WDATA_A2;
  wire [17:0] WDATA_B1;
  wire [17:0] WDATA_B2;

  // Modes Mapping
  localparam write_mode_A =   WRITE_WIDTH_A == 36 ? 3'b110 : 
                              WRITE_WIDTH_A == 18 ? 3'b010 : 
                              WRITE_WIDTH_A == 9  ? 3'b100 :
                              WRITE_WIDTH_A == 4  ? 3'b001 :
                              WRITE_WIDTH_A == 2  ? 3'b011 : 3'b101 ;
  
  localparam read_mode_A  =   READ_WIDTH_A  == 36 ? 3'b110 : 
                              READ_WIDTH_A  == 18 ? 3'b010 : 
                              READ_WIDTH_A  == 9  ? 3'b100 :
                              READ_WIDTH_A  == 4  ? 3'b001 :
                              READ_WIDTH_A  == 2  ? 3'b011 : 3'b101 ;
  
  localparam write_mode_B =   WRITE_WIDTH_B == 36 ? 3'b110 : 
                              WRITE_WIDTH_B == 18 ? 3'b010 : 
                              WRITE_WIDTH_B == 9  ? 3'b100 :
                              WRITE_WIDTH_B == 4  ? 3'b001 :
                              WRITE_WIDTH_B == 2  ? 3'b011 : 3'b101 ;
  
  localparam read_mode_B  =   READ_WIDTH_B  == 36 ? 3'b110 : 
                              READ_WIDTH_B  == 18 ? 3'b010 : 
                              READ_WIDTH_B  == 9  ? 3'b100 :
                              READ_WIDTH_B  == 4  ? 3'b001 :
                              READ_WIDTH_B  == 2  ? 3'b011 : 3'b101 ;
  
  // Write Data Port A
    assign WDATA_A1 = {WPARITY_A[1:0], WDATA_A[15:0]};
    assign WDATA_A2 = {WPARITY_A[3:2], WDATA_A[31:16]};

  // Write Data Port B
    assign WDATA_B1 = {WPARITY_B[1:0], WDATA_B[15:0]};
    assign WDATA_B2 = {WPARITY_B[3:2], WDATA_B[31:16]}; 

  // Read Data Port A
    assign RDATA_A   = {DATA_OUT_A2[15:0],  DATA_OUT_A1[15:0]};
    assign RPARITY_A = {DATA_OUT_A2[17:16], DATA_OUT_A1[17:16]};

  // Read Data Port B
    assign RDATA_B   = {DATA_OUT_B2[15:0],  DATA_OUT_B1[15:0]};
    assign RPARITY_B = {DATA_OUT_B2[17:16], DATA_OUT_B1[17:16]};

// Memory Initialization
    function [18432-1:0] sram1();
    integer i;
    sram1 = {18432{1'b0}};
    for (i = 0; i < 2048; i=i+2) begin // When i = 0,2,4,6,8.... (Even) (Total 1024 iterations)
        sram1[(i*9) +:16]             = INIT[(i*16) +:16];      // Extracts first 16-bits from INIT and place into fisrt 16 places in SRAM1.
        sram1[(((i+2)*9)-2) +:2]      = INIT_PARITY[(i*2) +:2]; // Extracts first 2-bits from INIT_PARITY and place into the next two places in SRAM1.
        end
endfunction

function [18432-1:0] sram2();
    integer i;
    sram2 = {18432{1'b0}};
    for (i = 1; i < 2048; i=i+2) begin // When i = 1,3,5,7,9.... (Odd) (Total 1024 iterations)
        sram2[((i-1)*9) +:16]         = INIT[(i*16) +:16];      // Extracts next 16-bits onwards to 16 bits from INIT and place into the first 16 places in SRAM2.
        sram2[(((i+1)*9)-2) +:2]      = INIT_PARITY[(i*2) +:2]; // Extracts next 2-bits onwards to 2-bits from INIT_PARITY and place into the next two places in SRAM2.
        end
endfunction

localparam [36863:0] INIT_i1 = {sram2(), sram1()};

// Mode Bits
localparam [0:80] MODE_BITS = {1'b0, read_mode_A, read_mode_B, write_mode_A, write_mode_B, 29'd0, read_mode_A, read_mode_B, write_mode_A, write_mode_B, 27'd0};
  
  // Old Model
  RS_TDP36K  #(
      .MODE_BITS(MODE_BITS),
      .INIT_i(INIT_i1)
  ) RS_TDP36K_inst (
      .WEN_A1(WEN_A),
      .WEN_B1(WEN_B),
      .REN_A1(REN_A),
      .REN_B1(REN_B),
      .CLK_A1(CLK_A),
      .CLK_B1(CLK_B),
      .BE_A1(BE_A[1:0]),
      .BE_B1(BE_B[1:0]),
      .ADDR_A1(ADDR_A),
      .ADDR_B1(ADDR_B),
      .WDATA_A1(WDATA_A1),
      .WDATA_B1(WDATA_B1),
      .RDATA_A1(DATA_OUT_A1),
      .RDATA_B1(DATA_OUT_B1),
      .FLUSH1(1'b0),
      .WEN_A2(WEN_A),
      .WEN_B2(WEN_B),
      .REN_A2(REN_A),
      .REN_B2(REN_B),
      .CLK_A2(CLK_A),
      .CLK_B2(CLK_B),
      .BE_A2(BE_A[3:2]),
      .BE_B2(BE_B[3:2]),
      .ADDR_A2(ADDR_A[13:0]),
      .ADDR_B2(ADDR_B[13:0]),
      .WDATA_A2(WDATA_A2),
      .WDATA_B2(WDATA_B2),
      .RDATA_A2(DATA_OUT_A2),
      .RDATA_B2(DATA_OUT_B2),
      .FLUSH2(1'b0)
  );
  
  initial 
  begin
      // write data width for Port A
      case (WRITE_WIDTH_A)
          36,
          18,
          9,
          4,
          2,
          1
          : begin end
          default: begin
              $error("Invalid WRITE_WIDTH_A %0d\nChoose any value from [36, 18, 9, 4, 2, 1]", WRITE_WIDTH_A);
              $finish;
          end
      endcase
      
      // read data width for Port A
      case (READ_WIDTH_A)
          36,
          18,
          9,
          4,
          2,
          1
          : begin end
          default: begin
              $error("Invalid READ_WIDTH_A %0d\nChoose any value from [36, 18, 9, 4, 2, 1]", READ_WIDTH_A);
              $finish;
          end
      endcase
  
      // write data width for Port B
      case (WRITE_WIDTH_B)
          36,
          18,
          9,
          4,
          2,
          1
          : begin end
          default: begin
              $error("Invalid WRITE_WIDTH_B %0d\nChoose any value from [36, 18, 9, 4, 2, 1]", WRITE_WIDTH_B);
              $finish;
          end
      endcase
  
      // read data width for Port B
      case (READ_WIDTH_B)
          36,
          18,
          9,
          4,
          2,
          1
          : begin end
          default: begin
              $error("Invalid READ_WIDTH_B %0d\nChoose any value from [36, 18, 9, 4, 2, 1]", READ_WIDTH_B);
              $finish;
          end
      endcase
  end
  
  endmodule
