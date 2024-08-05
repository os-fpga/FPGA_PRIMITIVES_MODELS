

module sync_split_fifo_R18W18_R9W9 (
  input clock0, clock2, clock1, clock3, we1, we2, re1, re2, rst_ptr1, rst_ptr2,
  input [17:0] din1, 
  input [8:0] din2,
  output [17:0] dout1, 
  output [8:0] dout2,
  output EMPTY1,EPO1,EWM1,UNDERRUN1,FULL1,FMO1,FWM1,OVERRUN1, EMPTY2,EPO2,EWM2,UNDERRUN2,FULL2,FMO2,FWM2,OVERRUN2);

 FIFO18KX2 #(
    .DATA_WRITE_WIDTH1(6'd18),
    .DATA_READ_WIDTH1(5'd18),
    .FIFO_TYPE1("SYNCHRONOUS"),
    .PROG_FULL_THRESH1(11'h7fc),
    .PROG_EMPTY_THRESH1(11'h0),
    .DATA_WRITE_WIDTH2(4'd9),
    .DATA_READ_WIDTH2(4'd9),
    .FIFO_TYPE2("SYNCHRONOUS"),
    .PROG_FULL_THRESH2(11'h7fe),
    .PROG_EMPTY_THRESH2(11'h400)
) FIFO18KX2 (
    .WR_DATA1(din1),
    .RD_DATA1(dout1),
    .EMPTY1(EMPTY1),
    .FULL1(FULL1),
    .OVERFLOW1(OVERRUN1),
    .UNDERFLOW1(UNDERRUN1),
    .RD_EN1(re1),
    .WR_EN1(we1),
    .ALMOST_EMPTY1(EPO1),
    .ALMOST_FULL1(FMO1),
    .PROG_EMPTY1(EWM1),
    .PROG_FULL1(FWM1),
    .WR_CLK1(clock0),
    .RD_CLK1(clock1),
    .RESET1(rst_ptr1),
    .WR_DATA2(din2),
    .RD_DATA2(dout2),
    .EMPTY2(EMPTY2),
    .FULL2(FULL2),
    .OVERFLOW2(OVERRUN2),
    .UNDERFLOW2(UNDERRUN2),
    .RD_EN2(re2),
    .WR_EN2(we2),
    .ALMOST_EMPTY2(EPO2),
    .ALMOST_FULL2(FMO2),
    .PROG_EMPTY2(EWM2),
    .PROG_FULL2(FWM2),
    .WR_CLK2(clock2),
    .RD_CLK2(clock3),
    .RESET2(rst_ptr2)
);
 

endmodule

`ifdef SIM

`timescale 1ns/1ps
`celldefine
//
// FIFO18KX2 simulation model
// Dual 18Kb FIFO
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module FIFO18KX2 #(
  parameter DATA_WRITE_WIDTH1 = 18, // FIFO data write width, FIFO 1 (1-18)
  parameter DATA_READ_WIDTH1 = 18, // FIFO data read width, FIFO 1 (1-18)
  parameter FIFO_TYPE1 = "SYNCHRONOUS", // Synchronous or Asynchronous data transfer, FIFO 1 (SYNCHRONOUS/ASYNCHRONOUS)
  parameter [10:0] PROG_EMPTY_THRESH1 = 11'h004, // 11-bit Programmable empty depth, FIFO 1
  parameter [10:0] PROG_FULL_THRESH1 = 11'h7fa, // 11-bit Programmable full depth, FIFO 1
  parameter DATA_WRITE_WIDTH2 = 18, // FIFO data write width, FIFO 2 (1-18)
  parameter DATA_READ_WIDTH2 = 18, // FIFO data read width, FIFO 2 (1-18)
  parameter FIFO_TYPE2 = "SYNCHRONOUS", // Synchronous or Asynchronous data transfer, FIFO 2 (SYNCHRONOUS/ASYNCHRONOUS)
  parameter [10:0] PROG_EMPTY_THRESH2 = 11'h004, // 11-bit Programmable empty depth, FIFO 2
  parameter [10:0] PROG_FULL_THRESH2 = 11'h7fa // 11-bit Programmable full depth, FIFO 2
) (
  input RESET1, // Active high asynchronous FIFO reset, FIFO 1
  input WR_CLK1, // Write clock, FIFO 1
  input RD_CLK1, // Read clock, FIFO 1
  input WR_EN1, // Write enable, FIFO 1
  input RD_EN1, // Read enable, FIFO 1
  input [DATA_WRITE_WIDTH1-1:0] WR_DATA1, // Write data, FIFO 1
  output [DATA_READ_WIDTH1-1:0] RD_DATA1, // Read data, FIFO 1
  output reg EMPTY1 = 1'b1, // FIFO empty flag, FIFO 1
  output reg FULL1 = 1'b0, // FIFO full flag, FIFO 1
  output reg ALMOST_EMPTY1 = 1'b0, // FIFO almost empty flag, FIFO 1
  output reg ALMOST_FULL1 = 1'b0, // FIFO almost full flag, FIFO 1
  output reg PROG_EMPTY1 = 1'b1, // FIFO programmable empty flag, FIFO 1
  output reg PROG_FULL1 = 1'b0, // FIFO programmable full flag, FIFO 1
  output reg OVERFLOW1 = 1'b0, // FIFO overflow error flag, FIFO 1
  output reg UNDERFLOW1 = 1'b0, // FIFO underflow error flag, FIFO 1
  input RESET2, // Active high synchronous FIFO reset, FIFO 2
  input WR_CLK2, // Write clock, FIFO 2
  input RD_CLK2, // Read clock, FIFO 2
  input WR_EN2, // Write enable, FIFO 2
  input RD_EN2, // Read enable, FIFO 2
  input [DATA_WRITE_WIDTH2-1:0] WR_DATA2, // Write data, FIFO 2
  output [DATA_READ_WIDTH2-1:0] RD_DATA2, // Read data, FIFO 2
  output reg EMPTY2 = 1'b1, // FIFO empty flag, FIFO 2
  output reg FULL2 = 1'b0, // FIFO full flag, FIFO 2
  output reg ALMOST_EMPTY2 = 1'b0, // FIFO almost empty flag, FIFO 2
  output reg ALMOST_FULL2 = 1'b0, // FIFO almost full flag, FIFO 2
  output reg PROG_EMPTY2 = 1'b1, // FIFO programmable empty flag, FIFO 2
  output reg PROG_FULL2 = 1'b0, // FIFO programmable full flag, FIFO 2
  output reg OVERFLOW2 = 1'b0, // FIFO overflow error flag, FIFO 2
  output reg UNDERFLOW2 = 1'b0 // FIFO underflow error flag, FIFO 2
);
wire fifo_type   = (FIFO_TYPE2 == "SYNCHRONOUS")     ? 1'b1      : 1'b0;

  //FIFO1
  localparam DATA_WIDTH1 = DATA_WRITE_WIDTH1;
  localparam  fifo_depth1 = (DATA_WIDTH1 <= 9) ? 2048 : 1024;  
  localparam  fifo_addr_width1 = (DATA_WIDTH1 <= 9) ? 11 :  10;

  reg [fifo_addr_width1-1:0] fifo_wr_addr1 = {fifo_addr_width1{1'b0}};
  reg [fifo_addr_width1-1:0] fifo_rd_addr1 = {fifo_addr_width1{1'b0}};

  wire [15:0] ram_wr_data1;
  wire [1:0] ram_wr_parity1;

  reg fwft1 = 1'b0;
  reg fall_through1;
  reg wr_data_fwft1;
  reg [DATA_WIDTH1-1:0] fwft_data1 = {DATA_WIDTH1{1'b0}};

  wire [15:0] ram_rd_data1; 
  wire [1:0]  ram_rd_parity1;
  wire ram_clk_b1;
  
  integer number_entries1 = 0;
  reg underrun_status1 = 0;
  reg overrun_status1 = 0;

  generate

    if ((DATA_WIDTH1 == 9)|| (DATA_WIDTH1 == 17)) begin: one_parity
      assign ram_wr_data1 = {{16-DATA_WIDTH1{1'b0}}, WR_DATA1};
      assign ram_wr_parity1 = {1'b0, WR_DATA1[DATA_WIDTH1-1]};
      assign RD_DATA1 = fwft1 ? fwft_data1 : {ram_rd_parity1[0], ram_rd_data1[DATA_WIDTH1-2:0]};
    end else if ((DATA_WIDTH1 == 18)) begin: two_parity
      assign ram_wr_data1 = WR_DATA1[15:0];
      assign ram_wr_parity1 = WR_DATA1[DATA_WIDTH1-1:DATA_WIDTH1-2];
      assign RD_DATA1 = fwft1 ? fwft_data1 : {ram_rd_parity1[1:0], ram_rd_data1[DATA_WIDTH1-3:0]};
    end else begin: no_parity
      assign ram_wr_data1 = fall_through1 ? wr_data_fwft1 : {{16-DATA_WIDTH1{1'b0}}, WR_DATA1};
      assign ram_wr_parity1 = 2'b0;
      assign RD_DATA1 = fwft1 ? fwft_data1 : ram_rd_data1[DATA_WIDTH1-1:0];
    end

    if ( FIFO_TYPE1 == "SYNCHRONOUS" )  begin: sync

      always @(posedge WR_CLK1)
        if (WR_EN1 && !RD_EN1) begin
          number_entries1 <= number_entries1 + 1;
          underrun_status1 = 0;
          if (number_entries1 >= fifo_depth1)
            overrun_status1  = 1;
        end
        else if (!WR_EN1 && RD_EN1 && number_entries1 == 0) begin
          number_entries1 <= 0;
          underrun_status1 = 1;
        end
        else if (!WR_EN1 && RD_EN1) begin
          number_entries1 <= number_entries1 - 1;
          underrun_status1 = 0;
        end

      always @(posedge RESET1, posedge WR_CLK1)
        if (RESET1) begin
          fifo_wr_addr1 <= {fifo_addr_width1{1'b0}};
          fifo_rd_addr1 <= {fifo_addr_width1{1'b0}};
          EMPTY1        <= 1'b1;
          FULL1         <= 1'b0;
          ALMOST_EMPTY1 <= 1'b0;
          ALMOST_FULL1  <= 1'b0;
          PROG_EMPTY1   <= 1'b1;
          PROG_FULL1    <= 1'b0;
          OVERFLOW1     <= 1'b0;
          UNDERFLOW1    <= 1'b0;
          number_entries1 = 0;
          fwft1         <= 1'b0;
          fwft_data1    <= {DATA_WIDTH1-1{1'b0}};
          underrun_status1 <=1'b0;
          overrun_status1  <= 1'b0;
        end else begin
          if (WR_EN1)
            fifo_wr_addr1 <= fifo_wr_addr1 + 1'b1;
          EMPTY1        <= ((number_entries1==0) && (underrun_status1==0) || ((RD_EN1 && !WR_EN1) && (number_entries1==1)));
          FULL1         <= ((number_entries1==fifo_depth1) || ((number_entries1==(fifo_depth1-1)) && WR_EN1 && !RD_EN1));
          ALMOST_EMPTY1 <= (((number_entries1==1) && !(RD_EN1 && !WR_EN1)) ||  ((RD_EN1 && !WR_EN1) && (number_entries1==2)));
          ALMOST_FULL1  <= (((number_entries1==(fifo_depth1-1)) && !(!RD_EN1 && WR_EN1)) ||  ((!RD_EN1 && WR_EN1) && (number_entries1==fifo_depth1-2)));
          PROG_EMPTY1   <= ((number_entries1) < (PROG_EMPTY_THRESH1)) || ((RD_EN1 && !WR_EN1) && ((number_entries1) <= PROG_EMPTY_THRESH1) );
          PROG_FULL1    <= ((fifo_depth1-number_entries1) < (PROG_FULL_THRESH1)) || ((!RD_EN1 && WR_EN1) && ((fifo_depth1-number_entries1) <= PROG_FULL_THRESH1) );
          UNDERFLOW1    <= (EMPTY1 && RD_EN1) || (underrun_status1==1);
          OVERFLOW1     <= (FULL1 && WR_EN1) || (overrun_status1==1);
          if (EMPTY1 && WR_EN1 && !fwft1) begin
            fwft_data1 <= WR_DATA1;
            fifo_rd_addr1 <= fifo_rd_addr1 + 1'b1;
            fwft1 <= 1'b1;
          end else if (RD_EN1) begin
            fwft1 <= 1'b0;
            if (!(ALMOST_EMPTY1 && !WR_EN1))
              fifo_rd_addr1 <= fifo_rd_addr1 + 1'b1;
          end
        end

        assign ram_clk_b1 = WR_CLK1;

        initial begin
          #1;
          @(RD_CLK1);
          $display("\nWarning: FIFO36K instance %m RD_CLK1 should be tied to ground when FIFO36K is configured as FIFO1_TYPE=SYNCHRONOUS.");
        end

    end else begin: async

      assign ram_clk_b1 = RD_CLK1;

    end

  endgenerate

  //FIFO2
  localparam DATA_WIDTH2 = DATA_WRITE_WIDTH2;
  localparam  fifo_depth2 = (DATA_WIDTH2 <= 9) ? 2048 : 1024;  
  localparam  fifo_addr_width2 = (DATA_WIDTH2 <= 9) ? 11 :  10;

  reg [fifo_addr_width2-1:0] fifo_wr_addr2 = {fifo_addr_width2{1'b0}};
  reg [fifo_addr_width2-1:0] fifo_rd_addr2 = {fifo_addr_width2{1'b0}};

  wire [15:0] ram_wr_data2;
  wire [1:0] ram_wr_parity2;

  reg fwft2 = 1'b0;
  reg fall_through2;
  reg wr_data_fwft2;
  reg [DATA_WIDTH2-1:0] fwft_data2 = {DATA_WIDTH2{1'b0}};

  wire [15:0] ram_rd_data2; 
  wire [1:0]  ram_rd_parity2;
  wire ram_clk_b2;
  
  integer number_entries2 = 0;
  reg underrun_status2 = 0;
  reg overrun_status2 = 0;

  generate

    if ((DATA_WIDTH2 == 9)|| (DATA_WIDTH2 == 17)) begin: one_parity_fifo2
      assign ram_wr_data2 = {{16-DATA_WIDTH2{1'b0}}, WR_DATA2};
      assign ram_wr_parity2 = {1'b0, WR_DATA2[DATA_WIDTH2-1]};
      assign RD_DATA2 = fwft2 ? fwft_data2 : {ram_rd_parity2[0], ram_rd_data2[DATA_WIDTH2-2:0]};
    end else if ((DATA_WIDTH2 == 18)) begin: two_parity_fifo2
      assign ram_wr_data2 = WR_DATA2[15:0];
      assign ram_wr_parity2 = WR_DATA2[DATA_WIDTH2-1:DATA_WIDTH2-2];
      assign RD_DATA2 = fwft2 ? fwft_data2 : {ram_rd_parity2[1:0], ram_rd_data2[DATA_WIDTH2-3:0]};
    end else begin: no_parity_fifo2
      assign ram_wr_data2 = fall_through2 ? wr_data_fwft2 : {{16-DATA_WIDTH2{1'b0}}, WR_DATA2};
      assign ram_wr_parity2 = 2'b0;
      assign RD_DATA2 = fwft2 ? fwft_data2 : ram_rd_data2[DATA_WIDTH2-1:0];
    end

    if ( FIFO_TYPE2 == "SYNCHRONOUS" )  begin: sync_fifo2

      always @(posedge WR_CLK2)
        if (WR_EN2 && !RD_EN2) begin
          number_entries2 <= number_entries2 + 1;
          underrun_status2 = 0;
          if (number_entries2 >= fifo_depth2)
            overrun_status2  = 1;
        end
        else if (!WR_EN2 && RD_EN2 && number_entries2 == 0) begin
          number_entries2 <= 0;
          underrun_status2 = 1;
        end
        else if (!WR_EN2 && RD_EN2) begin
          number_entries2 <= number_entries2 - 1;
          underrun_status2 = 0;
        end

      always @(posedge RESET2, posedge WR_CLK2)
        if (RESET2) begin
          fifo_wr_addr2 <= {fifo_addr_width2{1'b0}};
          fifo_rd_addr2 <= {fifo_addr_width2{1'b0}};
          EMPTY2        <= 1'b1;
          FULL2         <= 1'b0;
          ALMOST_EMPTY2 <= 1'b0;
          ALMOST_FULL2  <= 1'b0;
          PROG_EMPTY2   <= 1'b1;
          PROG_FULL2    <= 1'b0;
          OVERFLOW2     <= 1'b0;
          UNDERFLOW2    <= 1'b0;
          number_entries2 = 0;
          fwft2         <= 1'b0;
          fwft_data2    <= {DATA_WIDTH2-1{1'b0}};
          underrun_status2 <=1'b0;
          overrun_status2  <= 1'b0;
        end else begin
          if (WR_EN2)
            fifo_wr_addr2 <= fifo_wr_addr2 + 1'b1;
          EMPTY2        <= ((number_entries2==0) && (underrun_status2==0) || ((RD_EN2 && !WR_EN2) && (number_entries2==1)));
          FULL2         <= ((number_entries2==fifo_depth2) || ((number_entries2==(fifo_depth2-1)) && WR_EN2 && !RD_EN2));
          ALMOST_EMPTY2 <= (((number_entries2==1) && !(RD_EN2 && !WR_EN2)) ||  ((RD_EN2 && !WR_EN2) && (number_entries2==2)));
          ALMOST_FULL2  <= (((number_entries2==(fifo_depth2-1)) && !(!RD_EN2 && WR_EN2)) ||  ((!RD_EN2 && WR_EN2) && (number_entries2==fifo_depth2-2)));
          PROG_EMPTY2   <= ((number_entries2) < (PROG_EMPTY_THRESH2)) || ((RD_EN2 && !WR_EN2) && ((number_entries2) <= PROG_EMPTY_THRESH2) );
          PROG_FULL2    <= ((fifo_depth2-number_entries2) < (PROG_FULL_THRESH2)) || ((!RD_EN2 && WR_EN2) && ((fifo_depth2-number_entries2) <= PROG_FULL_THRESH2) );
          UNDERFLOW2    <= (EMPTY2 && RD_EN2) || (underrun_status2==1);
          OVERFLOW2     <= (FULL2 && WR_EN2) || (overrun_status2==1);
          if (EMPTY2 && WR_EN2 && !fwft2) begin
            fwft_data2 <= WR_DATA2;
            fifo_rd_addr2 <= fifo_rd_addr2 + 1'b1;
            fwft2 <= 1'b1;
          end else if (RD_EN2) begin
            fwft2 <= 1'b0;
            if (!(ALMOST_EMPTY2 && !WR_EN2))
              fifo_rd_addr2 <= fifo_rd_addr2 + 1'b1;
          end
        end

        assign ram_clk_b2 = WR_CLK2;

        initial begin
          #1;
          @(RD_CLK2);
          $display("\nWarning: FIFO36K instance %m RD_CLK2 should be tied to ground when FIFO36K is configured as FIFO_TYPE2=SYNCHRONOUS.");
        end

    end else begin: async_fifo2

      assign ram_clk_b2 = RD_CLK2;

    end

  endgenerate

// Use BRAM
TDP_RAM18KX2 #(
  .INIT1({16384{1'b0}}), // Initial Contents of memory, RAM 1
  .INIT1_PARITY({2048{1'b0}}), // Initial Contents of memory
  .WRITE_WIDTH_A1(DATA_WRITE_WIDTH1), // Write data width on port A, RAM 1 (1-18)
  .WRITE_WIDTH_B1(DATA_WRITE_WIDTH1), // Write data width on port B, RAM 1 (1-18)
  .READ_WIDTH_A1(DATA_READ_WIDTH1), // Read data width on port A, RAM 1 (1-18)
  .READ_WIDTH_B1(DATA_READ_WIDTH1), // Read data width on port B, RAM 1 (1-18)
  .INIT2({16384{1'b0}}), // Initial Contents of memory, RAM 2
  .INIT2_PARITY({2048{1'b0}}), // Initial Contents of memory
  .WRITE_WIDTH_A2(DATA_WRITE_WIDTH2), // Write data width on port A, RAM 2 (1-18)
  .WRITE_WIDTH_B2(DATA_WRITE_WIDTH2), // Write data width on port B, RAM 2 (1-18)
  .READ_WIDTH_A2(DATA_READ_WIDTH2), // Read data width on port A, RAM 2 (1-18)
  .READ_WIDTH_B2(DATA_READ_WIDTH2) // Read data width on port B, RAM 2 (1-18)
) 
tdp_ram18kx2_inst
(
  // Ports for 1st 18K RAM
  .WEN_A1(WR_EN1), // Write-enable port A, RAM 1
  .WEN_B1(1'b0), // Write-enable port B, RAM 1
  .REN_A1(1'b0), // Read-enable port A, RAM 1
  .REN_B1(RD_EN1), // Read-enable port B, RAM 1
  .CLK_A1(WR_CLK1), // Clock port A, RAM 1
  .CLK_B1(ram_clk_b1), // Clock port B, RAM 1
  .BE_A1(2'b11), // Byte-write enable port A, RAM 1
  .BE_B1(2'b11), // Byte-write enable port B, RAM 1
  .ADDR_A1({fifo_wr_addr1, {14-fifo_addr_width1{1'b0}}}), // Address port A, RAM 1
  .ADDR_B1({fifo_rd_addr1, {14-fifo_addr_width1{1'b0}}}), // Address port B, RAM 1
  .WDATA_A1(ram_wr_data1), // Write data port A, RAM 1
  .WPARITY_A1(ram_wr_parity1), // Write parity port A, RAM 1
  .WDATA_B1(16'h0000), // Write data port B, RAM 1
  .WPARITY_B1(2'b00), // Write parity port B, RAM 1
  .RDATA_A1(), // Read data port A, RAM 1
  .RPARITY_A1(), // Read parity port A, RAM 1
  .RDATA_B1(ram_rd_data1), // Read data port B, RAM 1
  .RPARITY_B1(ram_rd_parity1), // Read parity port B, RAM 1
  // Ports for 2nd 18K RAM
  .WEN_A2(WR_EN2), // Write-enable port A, RAM 2
  .WEN_B2(1'b0), // Write-enable port B, RAM 2
  .REN_A2(1'b0), // Read-enable port A, RAM 2
  .REN_B2(RD_EN2), // Read-enable port B, RAM 2
  .CLK_A2(WR_CLK2), // Clock port A, RAM 2
  .CLK_B2(ram_clk_b2), // Clock port B, RAM 2
  .BE_A2(2'b11), // Byte-write enable port A, RAM 2
  .BE_B2(2'b11), // Byte-write enable port B, RAM 2
  .ADDR_A2({fifo_wr_addr2, {14-fifo_addr_width2{1'b0}}}), // Address port A, RAM 2
  .ADDR_B2({fifo_rd_addr2, {14-fifo_addr_width2{1'b0}}}), // Address port B, RAM 2
  .WDATA_A2(ram_wr_data2), // Write data port A, RAM 2
  .WPARITY_A2(ram_wr_parity2), // Write parity port A, RAM 2
  .WDATA_B2(16'h0000), // Write data port B, RAM 2
  .WPARITY_B2(2'b00), // Write parity port B, RAM 2
  .RDATA_A2(), // Read data port A, RAM 2
  .RPARITY_A2(), // Read parity port A, RAM 2
  .RDATA_B2(ram_rd_data2), // Read data port B, RAM 2
  .RPARITY_B2(ram_rd_parity2) // Read parity port B, RAM 2
); initial begin

    if ((DATA_WRITE_WIDTH1 < 1) || (DATA_WRITE_WIDTH1 > 18)) begin
       $display("FIFO18KX2 instance %m DATA_WRITE_WIDTH1 set to incorrect value, %d.  Values must be between 1 and 18.", DATA_WRITE_WIDTH1);
    #1 $stop;
    end

    if ((DATA_READ_WIDTH1 < 1) || (DATA_READ_WIDTH1 > 18)) begin
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

    if ((DATA_WRITE_WIDTH2 < 1) || (DATA_WRITE_WIDTH2 > 18)) begin
       $display("FIFO18KX2 instance %m DATA_WRITE_WIDTH2 set to incorrect value, %d.  Values must be between 1 and 18.", DATA_WRITE_WIDTH2);
    #1 $stop;
    end

    if ((DATA_READ_WIDTH2 < 1) || (DATA_READ_WIDTH2 > 18)) begin
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

endmodule
`endcelldefine
`timescale 1ns/1ps
`celldefine
//
// TDP_RAM18KX2 simulation model
// Dual 18Kb True-dual-port RAM
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module TDP_RAM18KX2 #(
  parameter [16383:0] INIT1 = {16384{1'b0}}, // Initial Contents of data memory, RAM 1
  parameter [2047:0] INIT1_PARITY = {2048{1'b0}}, // Initial Contents of parity memory, RAM 1
  parameter WRITE_WIDTH_A1 = 18, // Write data width on port A, RAM 1 (1-18)
  parameter WRITE_WIDTH_B1 = 18, // Write data width on port B, RAM 1 (1-18)
  parameter READ_WIDTH_A1 = 18, // Read data width on port A, RAM 1 (1-18)
  parameter READ_WIDTH_B1 = 18, // Read data width on port B, RAM 1 (1-18)
  parameter [16383:0] INIT2 = {16384{1'b0}}, // Initial Contents of memory, RAM 2
  parameter [2047:0] INIT2_PARITY = {2048{1'b0}}, // Initial Contents of memory, RAM 2
  parameter WRITE_WIDTH_A2 = 18, // Write data width on port A, RAM 2 (1-18)
  parameter WRITE_WIDTH_B2 = 18, // Write data width on port B, RAM 2 (1-18)
  parameter READ_WIDTH_A2 = 18, // Read data width on port A, RAM 2 (1-18)
  parameter READ_WIDTH_B2 = 18 // Read data width on port B, RAM 2 (1-18)
) (
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
  output reg [15:0] RDATA_A1 = {16{1'b0}}, // Read data port A, RAM 1
  output reg [1:0] RPARITY_A1 = {2{1'b0}}, // Read parity port A, RAM 1
  output reg [15:0] RDATA_B1 = {16{1'b0}}, // Read data port B, RAM 1
  output reg [1:0] RPARITY_B1 = {2{1'b0}}, // Read parity port B, RAM 1
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
  output reg [15:0] RDATA_A2 = {16{1'b0}}, // Read data port A, RAM 2
  output reg [1:0] RPARITY_A2 = {2{1'b0}}, // Read parity port A, RAM 2
  output reg [15:0] RDATA_B2 = {16{1'b0}}, // Read data port B, RAM 2
  output reg [1:0] RPARITY_B2 = {2{1'b0}} // Read parity port B, RAM 2
);
	
	
	//RAM1
	localparam A1_DATA_WRITE_WIDTH = calc_data_width(WRITE_WIDTH_A1);
  localparam A1_WRITE_ADDR_WIDTH = calc_depth(A1_DATA_WRITE_WIDTH);
  localparam A1_DATA_READ_WIDTH = calc_data_width(READ_WIDTH_A1);
  localparam A1_READ_ADDR_WIDTH = calc_depth(A1_DATA_READ_WIDTH);
  localparam A1_DATA_WIDTH = (A1_DATA_WRITE_WIDTH > A1_DATA_READ_WIDTH) ? A1_DATA_WRITE_WIDTH : A1_DATA_READ_WIDTH;

  localparam A1_PARITY_WRITE_WIDTH = calc_parity_width(WRITE_WIDTH_A1);
  localparam A1_PARITY_READ_WIDTH = calc_parity_width(READ_WIDTH_A1);
  localparam A1_PARITY_WIDTH = (A1_PARITY_WRITE_WIDTH > A1_PARITY_READ_WIDTH) ? A1_PARITY_WRITE_WIDTH : A1_PARITY_READ_WIDTH;
  
  localparam B1_DATA_WRITE_WIDTH = calc_data_width(WRITE_WIDTH_B1);
  localparam B1_WRITE_ADDR_WIDTH = calc_depth(B1_DATA_WRITE_WIDTH);
  localparam B1_DATA_READ_WIDTH = calc_data_width(READ_WIDTH_B1);
  localparam B1_READ_ADDR_WIDTH = calc_depth(B1_DATA_READ_WIDTH);
  localparam B1_DATA_WIDTH = (B1_DATA_WRITE_WIDTH > B1_DATA_READ_WIDTH) ? B1_DATA_WRITE_WIDTH : B1_DATA_READ_WIDTH;

  localparam B1_PARITY_WRITE_WIDTH = calc_parity_width(WRITE_WIDTH_B1);
  localparam B1_PARITY_READ_WIDTH = calc_parity_width(READ_WIDTH_B1);
  localparam B1_PARITY_WIDTH = (B1_PARITY_WRITE_WIDTH > B1_PARITY_READ_WIDTH) ? B1_PARITY_WRITE_WIDTH : B1_PARITY_READ_WIDTH;

  localparam RAM1_DATA_WIDTH = (A1_DATA_WIDTH > B1_DATA_WIDTH) ? A1_DATA_WIDTH : B1_DATA_WIDTH;
  localparam RAM1_PARITY_WIDTH = (A1_PARITY_WIDTH > B1_PARITY_WIDTH) ? A1_PARITY_WIDTH : B1_PARITY_WIDTH;
  localparam RAM1_ADDR_WIDTH = calc_depth(RAM1_DATA_WIDTH);

	integer f, g, h, i, j, k, m;
  
  reg collision_window = 1;
  reg collision_a_write_flag = 0;                                   
  reg collision_b_write_flag = 0;                                   
  reg collision_a_read_flag = 0;                                   
  reg collision_b_read_flag = 0;                                   
  reg [RAM1_ADDR_WIDTH-1:0] collision_a_address = {RAM1_ADDR_WIDTH{1'b0}};                                   
  reg [RAM1_ADDR_WIDTH-1:0] collision_b_address = {RAM1_ADDR_WIDTH{1'b0}};

	wire [RAM1_ADDR_WIDTH-1:0] a1_addr = ADDR_A1[13:14-RAM1_ADDR_WIDTH];                                 
  wire [RAM1_ADDR_WIDTH-1:0] b1_addr = ADDR_B1[13:14-RAM1_ADDR_WIDTH];                                  
  
  reg [RAM1_DATA_WIDTH-1:0] RAM1_DATA [2**RAM1_ADDR_WIDTH-1:0];

  generate
    if (RAM1_PARITY_WIDTH > 0) begin: parity_RAM1
      reg [RAM1_PARITY_WIDTH-1:0] RAM1_PARITY [2**RAM1_ADDR_WIDTH-1:0];

      integer f_p, g_p, h_p, i_p, j_p, k_p, m_p;

      // Initialize Parity RAM contents
      initial begin
        f_p = 0;
        for (g_p = 0; g_p < 2**RAM1_ADDR_WIDTH; g_p = g_p + 1)
          for (h_p = 0; h_p < RAM1_PARITY_WIDTH; h_p = h_p + 1) begin
            RAM1_PARITY[g_p][h_p] <= INIT1_PARITY[f_p];
            f_p = f_p + 1;
          end
      end

      always @(posedge CLK_A1)
        if (WEN_A1) begin
          for (i_p = find_a1_write_index(ADDR_A1)*A1_PARITY_WRITE_WIDTH; i_p < find_a1_write_index(ADDR_A1)*A1_PARITY_WRITE_WIDTH+A1_PARITY_WRITE_WIDTH; i_p = i_p + 1) begin
            if (A1_PARITY_WRITE_WIDTH > 1) begin
              if (BE_A1[i_p/1] == 1'b1)
                RAM1_PARITY[a1_addr][i_p] <= WPARITY_A1[i_p-(find_a1_write_index(ADDR_A1)*A1_PARITY_WRITE_WIDTH)];
            end
            else
              RAM1_PARITY[a1_addr][i_p] <= WPARITY_A1[i_p-(find_a1_write_index(ADDR_A1)*A1_PARITY_WRITE_WIDTH)];
          //$display("i_p: %0h, [i_p/1] %0h", i_p, i_p/2,$time);
          end
        end      

      always @(posedge CLK_A1)
        if (REN_A1) begin
          for (j_p = find_a1_read_index(ADDR_A1)*A1_PARITY_READ_WIDTH; j_p < find_a1_read_index(ADDR_A1)*A1_PARITY_READ_WIDTH+A1_PARITY_READ_WIDTH; j_p = j_p + 1)
            RPARITY_A1[j_p-(find_a1_read_index(ADDR_A1)*A1_PARITY_READ_WIDTH)] <= RAM1_PARITY[a1_addr][j_p];
        end      

      always @(posedge CLK_B1)
        if (WEN_B1) begin
          for (k_p = find_b1_write_index(ADDR_B1)*B1_PARITY_WRITE_WIDTH; k_p < find_b1_write_index(ADDR_B1)*B1_PARITY_WRITE_WIDTH+B1_PARITY_WRITE_WIDTH; k_p = k_p + 1) begin
            if (B1_PARITY_WRITE_WIDTH > 1) begin
              if (BE_B1[k_p/1] == 1'b1)
                RAM1_PARITY[b1_addr][k_p] <= WPARITY_B1[k_p-(find_b1_write_index(ADDR_B1)*B1_PARITY_WRITE_WIDTH)];
            end
            else
              RAM1_PARITY[b1_addr][k_p] <= WPARITY_B1[k_p-(find_b1_write_index(ADDR_B1)*B1_PARITY_WRITE_WIDTH)];
          end
        end      

      always @(posedge CLK_B1)
        if (REN_B1) begin
          for (m_p = find_b1_read_index(ADDR_B1)*B1_PARITY_READ_WIDTH; m_p < find_b1_read_index(ADDR_B1)*B1_PARITY_READ_WIDTH+B1_PARITY_READ_WIDTH; m_p = m_p + 1)
            RPARITY_B1[m_p-(find_b1_read_index(ADDR_B1)*B1_PARITY_READ_WIDTH)] <= RAM1_PARITY[b1_addr][m_p];
        end      

    end
  endgenerate

	// Initialize Base RAM contents
  initial begin
    f = 0;
    for (g = 0; g < 2**RAM1_ADDR_WIDTH; g = g + 1)
      for (h = 0; h < RAM1_DATA_WIDTH; h = h + 1) begin
        RAM1_DATA[g][h] <= INIT1[f];
        f = f + 1;
      end
  end
  
 // Base RAM read/write functionality
  always @(posedge CLK_A1)
    if (WEN_A1) begin
      //$display("AADR_A: %b   index: %d", ADDR_A1, find_a1_write_index(ADDR_A1)*8);
      for (i = find_a1_write_index(ADDR_A1)*A1_DATA_WRITE_WIDTH; i < find_a1_write_index(ADDR_A1)*A1_DATA_WRITE_WIDTH+A1_DATA_WRITE_WIDTH; i = i + 1) begin
        if (A1_DATA_WRITE_WIDTH > 9) begin
          if (BE_A1[i/8] == 1'b1)
            RAM1_DATA[a1_addr][i] <= WDATA_A1[i-(find_a1_write_index(ADDR_A1)*A1_DATA_WRITE_WIDTH)];
        end
        else
          RAM1_DATA[a1_addr][i] <= WDATA_A1[i-(find_a1_write_index(ADDR_A1)*A1_DATA_WRITE_WIDTH)];
      end
      collision_a_address = a1_addr;
      collision_a_write_flag = 1;
      #collision_window;
      collision_a_write_flag = 0;
    end      

  always @(posedge CLK_A1)
    if (REN_A1) begin
      for (j = find_a1_read_index(ADDR_A1)*A1_DATA_READ_WIDTH; j < find_a1_read_index(ADDR_A1)*A1_DATA_READ_WIDTH+A1_DATA_READ_WIDTH; j = j + 1)
        RDATA_A1[j-(find_a1_read_index(ADDR_A1)*A1_DATA_READ_WIDTH)] <= RAM1_DATA[a1_addr][j];
      collision_a_address = a1_addr;
      collision_a_read_flag = 1;
      #collision_window;
      collision_a_read_flag = 0;
    end

  always @(posedge CLK_B1)
    if (WEN_B1) begin
      for (k = find_b1_write_index(ADDR_B1)*B1_DATA_WRITE_WIDTH; k < find_b1_write_index(ADDR_B1)*B1_DATA_WRITE_WIDTH+B1_DATA_WRITE_WIDTH; k = k + 1) begin
        if (B1_DATA_WRITE_WIDTH > 9) begin
          if (BE_B1[k/8] == 1'b1)
            RAM1_DATA[b1_addr][k] <= WDATA_B1[k-(find_b1_write_index(ADDR_B1)*B1_DATA_WRITE_WIDTH)];
        end
        else
          RAM1_DATA[b1_addr][k] <= WDATA_B1[k-(find_b1_write_index(ADDR_B1)*B1_DATA_WRITE_WIDTH)];    
        
      end
      collision_b_address = b1_addr;
      collision_b_write_flag = 1;
      #collision_window;
      collision_b_write_flag = 0;
    end      

  always @(posedge CLK_B1)
    if (REN_B1) begin
      //$display("index: %d  b1_addr: %h ADDR_B1: %h", find_b1_read_index(ADDR_B1), b1_addr, ADDR_B1);
      for (m = find_b1_read_index(ADDR_B1)*B1_DATA_READ_WIDTH; m < find_b1_read_index(ADDR_B1)*B1_DATA_READ_WIDTH+B1_DATA_READ_WIDTH; m = m + 1)
        RDATA_B1[m-(find_b1_read_index(ADDR_B1)*B1_DATA_READ_WIDTH)] <= RAM1_DATA[b1_addr][m];
      collision_b_address = b1_addr;
      collision_b_read_flag = 1;
      #collision_window;
      collision_b_read_flag = 0;
    end

  // Collision checking
    always @(posedge collision_a_write_flag) begin
      if (collision_b_write_flag && (collision_a_address == collision_b_address)) begin
        $display("ERROR: Write collision occured on TDP_RAM18K instance %m at time %t where port A1 is writing to the same address, %h, as port B1.\n       The write data may not be valid.", $realtime, collision_a_address);
        collision_a_write_flag = 0;
      end
      if (collision_b_read_flag && (collision_a_address == collision_b_address)) begin
        $display("ERROR: Memory collision occured on TDP_RAM18K instance %m at time %t where port A1 is writing to the same address, %h, as port B1 is reading.\n       The write data is valid but the read data is not.", $realtime, collision_b_address);
        collision_a_write_flag = 0;
      end
    end
     
    always @(posedge collision_a_read_flag) begin
      if (collision_b_write_flag && (collision_a_address == collision_b_address))
        $display("ERROR: Memory collision occured on TDP_RAM18K instance %m at time %t where port B1 is writing to the same address, %h, as port A1 is reading.\n       The write data is valid but the read data is not.", $realtime, collision_a_address);
        collision_a_read_flag = 0;
      end
      
    always @(posedge collision_b_write_flag) begin
      if (collision_a_write_flag && (collision_a_address == collision_b_address)) begin
        $display("ERROR: Write collision occured on TDP_RAM18K instance %m at time %t where port B1 is writing to the same address, %h, as port A1.\n       The write data may not be valid.", $realtime, collision_b_address);
        collision_b_write_flag = 0;   
      end
      if (collision_a_read_flag && (collision_a_address == collision_b_address)) begin
        $display("ERROR: Memory collision occured on TDP_RAM18K instance %m at time %t where port B1 is writing to the same address, %h, as port A1 is reading.\n       The write data is valid but the read data is not.", $realtime, collision_b_address);
        collision_b_write_flag = 0;
      end
    end
  
    always @(posedge collision_b_read_flag) begin
      if (collision_a_write_flag && (collision_a_address == collision_b_address)) begin
        $display("ERROR: Memory collision occured on TDP_RAM18K instance %m at time %t where port A1 is writing to the same address, %h, as port B1 is reading.\n       The write data is valid but the read data is not.", $realtime, collision_b_address);
        collision_b_read_flag = 0;
      end
    end

  //RAM2
  localparam A2_DATA_WRITE_WIDTH = calc_data_width(WRITE_WIDTH_A2);
  localparam A2_WRITE_ADDR_WIDTH = calc_depth(A2_DATA_WRITE_WIDTH);
  localparam A2_DATA_READ_WIDTH = calc_data_width(READ_WIDTH_A2);
  localparam A2_READ_ADDR_WIDTH = calc_depth(A2_DATA_READ_WIDTH);
  localparam A2_DATA_WIDTH = (A2_DATA_WRITE_WIDTH > A2_DATA_READ_WIDTH) ? A2_DATA_WRITE_WIDTH : A2_DATA_READ_WIDTH;

  localparam A2_PARITY_WRITE_WIDTH = calc_parity_width(WRITE_WIDTH_A2);
  localparam A2_PARITY_READ_WIDTH = calc_parity_width(READ_WIDTH_A2);
  localparam A2_PARITY_WIDTH = (A2_PARITY_WRITE_WIDTH > A2_PARITY_READ_WIDTH) ? A2_PARITY_WRITE_WIDTH : A2_PARITY_READ_WIDTH;
  
  localparam B2_DATA_WRITE_WIDTH = calc_data_width(WRITE_WIDTH_B2);
  localparam B2_WRITE_ADDR_WIDTH = calc_depth(B2_DATA_WRITE_WIDTH);
  localparam B2_DATA_READ_WIDTH = calc_data_width(READ_WIDTH_B2);
  localparam B2_READ_ADDR_WIDTH = calc_depth(B2_DATA_READ_WIDTH);
  localparam B2_DATA_WIDTH = (B2_DATA_WRITE_WIDTH > B2_DATA_READ_WIDTH) ? B2_DATA_WRITE_WIDTH : B2_DATA_READ_WIDTH;

  localparam B2_PARITY_WRITE_WIDTH = calc_parity_width(WRITE_WIDTH_B2);
  localparam B2_PARITY_READ_WIDTH = calc_parity_width(READ_WIDTH_B2);
  localparam B2_PARITY_WIDTH = (B2_PARITY_WRITE_WIDTH > B2_PARITY_READ_WIDTH) ? B2_PARITY_WRITE_WIDTH : B2_PARITY_READ_WIDTH;

  localparam RAM2_DATA_WIDTH = (A2_DATA_WIDTH > B2_DATA_WIDTH) ? A2_DATA_WIDTH : B2_DATA_WIDTH;
  localparam RAM2_PARITY_WIDTH = (A2_PARITY_WIDTH > B2_PARITY_WIDTH) ? A2_PARITY_WIDTH : B2_PARITY_WIDTH;
  localparam RAM2_ADDR_WIDTH = calc_depth(RAM2_DATA_WIDTH);

	integer a, b, c, l, n, p, r;
  
  reg collision_a2_write_flag = 0;                                   
  reg collision_b2_write_flag = 0;                                   
  reg collision_a2_read_flag = 0;                                   
  reg collision_b2_read_flag = 0;                                   
  reg [RAM2_ADDR_WIDTH-1:0] collision_a2_address = {RAM2_ADDR_WIDTH{1'b0}};                                   
  reg [RAM2_ADDR_WIDTH-1:0] collision_b2_address = {RAM2_ADDR_WIDTH{1'b0}};

	wire [RAM2_ADDR_WIDTH-1:0] a2_addr = ADDR_A2[13:14-RAM2_ADDR_WIDTH];                                 
  wire [RAM2_ADDR_WIDTH-1:0] b2_addr = ADDR_B2[13:14-RAM2_ADDR_WIDTH];                                  
  
  reg [RAM2_DATA_WIDTH-1:0] RAM2_DATA [2**RAM2_ADDR_WIDTH-1:0];

  generate
    if (RAM2_PARITY_WIDTH > 0) begin: parity_RAM2
      reg [RAM2_PARITY_WIDTH-1:0] RAM2_PARITY [2**RAM2_ADDR_WIDTH-1:0];

      integer f_p2, g_p2, h_p2, i_p2, j_p2, k_p2, m_p2;

      // Initialize Parity RAM contents
      initial begin
        f_p2 = 0;
        for (g_p2 = 0; g_p2 < 2**RAM2_ADDR_WIDTH; g_p2 = g_p2 + 1)
          for (h_p2 = 0; h_p2 < RAM2_PARITY_WIDTH; h_p2 = h_p2 + 1) begin
            RAM2_PARITY[g_p2][h_p2] <= INIT2_PARITY[f_p2];
            f_p2 = f_p2 + 1;
          end
      end

      always @(posedge CLK_A2)
        if (WEN_A2) begin
          for (i_p2 = find_a2_write_index(ADDR_A2)*A2_PARITY_WRITE_WIDTH; i_p2 < find_a2_write_index(ADDR_A2)*A2_PARITY_WRITE_WIDTH+A2_PARITY_WRITE_WIDTH; i_p2 = i_p2 + 1) begin
            if (A2_PARITY_WRITE_WIDTH > 1) begin
              if (BE_A2[i_p2/1] == 1'b1)
                RAM2_PARITY[a2_addr][i_p2] <= WPARITY_A2[i_p2-(find_a2_write_index(ADDR_A2)*A2_PARITY_WRITE_WIDTH)];
            end
            else
              RAM2_PARITY[a2_addr][i_p2] <= WPARITY_A2[i_p2-(find_a2_write_index(ADDR_A2)*A2_PARITY_WRITE_WIDTH)];
          //$display("i_p2: %0h, [i_p2/1] %0h", i_p2, i_p2/2,$time);
          end
        end      

      always @(posedge CLK_A2)
        if (REN_A2) begin
          for (j_p2 = find_a2_read_index(ADDR_A2)*A2_PARITY_READ_WIDTH; j_p2 < find_a2_read_index(ADDR_A2)*A2_PARITY_READ_WIDTH+A2_PARITY_READ_WIDTH; j_p2 = j_p2 + 1)
            RPARITY_A2[j_p2-(find_a2_read_index(ADDR_A2)*A2_PARITY_READ_WIDTH)] <= RAM2_PARITY[a2_addr][j_p2];
        end      

      always @(posedge CLK_B2)
        if (WEN_B2) begin
          for (k_p2 = find_b2_write_index(ADDR_B2)*B2_PARITY_WRITE_WIDTH; k_p2 < find_b2_write_index(ADDR_B2)*B2_PARITY_WRITE_WIDTH+B2_PARITY_WRITE_WIDTH; k_p2 = k_p2 + 1) begin
            if (B2_PARITY_WRITE_WIDTH > 1) begin
              if (BE_B2[k_p2/1] == 1'b1)
                RAM2_PARITY[b2_addr][k_p2] <= WPARITY_B2[k_p2-(find_b2_write_index(ADDR_B2)*B2_PARITY_WRITE_WIDTH)];
            end
            else
              RAM2_PARITY[b2_addr][k_p2] <= WPARITY_B2[k_p2-(find_b2_write_index(ADDR_B2)*B2_PARITY_WRITE_WIDTH)];
          end
        end      

      always @(posedge CLK_B2)
        if (REN_B2) begin
          for (m_p2 = find_b2_read_index(ADDR_B2)*B2_PARITY_READ_WIDTH; m_p2 < find_b2_read_index(ADDR_B2)*B2_PARITY_READ_WIDTH+B2_PARITY_READ_WIDTH; m_p2 = m_p2 + 1)
            RPARITY_B2[m_p2-(find_b2_read_index(ADDR_B2)*B2_PARITY_READ_WIDTH)] <= RAM2_PARITY[b2_addr][m_p2];
        end      

    end
  endgenerate

	// Initialize Base RAM contents
  initial begin
    a = 0;
    for (b = 0; b < 2**RAM2_ADDR_WIDTH; b = b + 1)
      for (c = 0; c < RAM2_DATA_WIDTH; c = c + 1) begin
        RAM2_DATA[b][c] <= INIT2[a];
        a = a + 1;
      end
  end
  
 // Base RAM read/write functionality
  always @(posedge CLK_A2)
    if (WEN_A2) begin
      //$display("AADR_A: %b   index: %d", ADDR_A2, find_a2_write_index(ADDR_A2)*8);
      for (l = find_a2_write_index(ADDR_A2)*A2_DATA_WRITE_WIDTH; l < find_a2_write_index(ADDR_A2)*A2_DATA_WRITE_WIDTH+A2_DATA_WRITE_WIDTH; l = l + 1) begin
        if (A2_DATA_WRITE_WIDTH > 9) begin
          if (BE_A2[l/8] == 1'b1)
            RAM2_DATA[a2_addr][l] <= WDATA_A2[l-(find_a2_write_index(ADDR_A2)*A2_DATA_WRITE_WIDTH)];
        end
        else
          RAM2_DATA[a2_addr][l] <= WDATA_A2[l-(find_a2_write_index(ADDR_A2)*A2_DATA_WRITE_WIDTH)];
      end
      collision_a2_address = a2_addr;
      collision_a2_write_flag = 1;
      #collision_window;
      collision_a2_write_flag = 0;
    end      

  always @(posedge CLK_A2)
    if (REN_A2) begin
      for (l = find_a2_read_index(ADDR_A2)*A2_DATA_READ_WIDTH; l < find_a2_read_index(ADDR_A2)*A2_DATA_READ_WIDTH+A2_DATA_READ_WIDTH; l = l + 1)
        RDATA_A2[l-(find_a2_read_index(ADDR_A2)*A2_DATA_READ_WIDTH)] <= RAM2_DATA[a2_addr][l];
      collision_a2_address = a2_addr;
      collision_a2_read_flag = 1;
      #collision_window;
      collision_a2_read_flag = 0;
    end

  always @(posedge CLK_B2)
    if (WEN_B2) begin
      for (p = find_b2_write_index(ADDR_B2)*B2_DATA_WRITE_WIDTH; p < find_b2_write_index(ADDR_B2)*B2_DATA_WRITE_WIDTH+B2_DATA_WRITE_WIDTH; p = p + 1) begin
        if (B2_DATA_WRITE_WIDTH > 9) begin
          if (BE_B2[p/8] == 1'b1)
            RAM2_DATA[b2_addr][p] <= WDATA_B2[p-(find_b2_write_index(ADDR_B2)*B2_DATA_WRITE_WIDTH)];
        end
        else
          RAM2_DATA[b2_addr][p] <= WDATA_B2[p-(find_b2_write_index(ADDR_B2)*B2_DATA_WRITE_WIDTH)];    
        
      end
      collision_b2_address = b2_addr;
      collision_b2_write_flag = 1;
      #collision_window;
      collision_b2_write_flag = 0;
    end      

  always @(posedge CLK_B2)
    if (REN_B2) begin
      //$display("index: %d  b2_addr: %h ADDR_B2: %h", find_b2_read_index(ADDR_B2), b2_addr, ADDR_B2);
      for (r = find_b2_read_index(ADDR_B2)*B2_DATA_READ_WIDTH; r < find_b2_read_index(ADDR_B2)*B2_DATA_READ_WIDTH+B2_DATA_READ_WIDTH; r = r + 1)
        RDATA_B2[r-(find_b2_read_index(ADDR_B2)*B2_DATA_READ_WIDTH)] <= RAM2_DATA[b2_addr][r];
      collision_b2_address = b2_addr;
      collision_b2_read_flag = 1;
      #collision_window;
      collision_b2_read_flag = 0;
    end

    // Collision checking
    always @(posedge collision_a2_write_flag) begin
      if (collision_b2_write_flag && (collision_a2_address == collision_b2_address)) begin
        $display("ERROR: Write collision occured on TDP_RAM18K instance %m at time %t where port A2 is writing to the same address, %h, as port B2.\n       The write data may not be valid.", $realtime, collision_a2_address);
        collision_a2_write_flag = 0;
      end
      if (collision_b2_read_flag && (collision_a2_address == collision_b2_address)) begin
        $display("ERROR: Memory collision occured on TDP_RAM18K instance %m at time %t where port A2 is writing to the same address, %h, as port B2 is reading.\n       The write data is valid but the read data is not.", $realtime, collision_b2_address);
        collision_a2_write_flag = 0;
      end
    end
     
    always @(posedge collision_a2_read_flag) begin
      if (collision_b2_write_flag && (collision_a2_address == collision_b2_address))
        $display("ERROR: Memory collision occured on TDP_RAM18K instance %m at time %t where port B2 is writing to the same address, %h, as port A2 is reading.\n       The write data is valid but the read data is not.", $realtime, collision_a2_address);
        collision_a2_read_flag = 0;
      end
      
    always @(posedge collision_b2_write_flag) begin
      if (collision_a2_write_flag && (collision_a2_address == collision_b2_address)) begin
        $display("ERROR: Write collision occured on TDP_RAM18K instance %m at time %t where port B2 is writing to the same address, %h, as port A2.\n       The write data may not be valid.", $realtime, collision_b2_address);
        collision_b2_write_flag = 0;   
      end
      if (collision_a2_read_flag && (collision_a2_address == collision_b2_address)) begin
        $display("ERROR: Memory collision occured on TDP_RAM18K instance %m at time %t where port B2 is writing to the same address, %h, as port A2 is reading.\n       The write data is valid but the read data is not.", $realtime, collision_b2_address);
        collision_b2_write_flag = 0;
      end
    end
  
    always @(posedge collision_b2_read_flag) begin
      if (collision_a2_write_flag && (collision_a2_address == collision_b2_address)) begin
        $display("ERROR: Memory collision occured on TDP_RAM18K instance %m at time %t where port A2 is writing to the same address, %h, as port B2 is reading.\n       The write data is valid but the read data is not.", $realtime, collision_b2_address);
        collision_b2_read_flag = 0;
      end
    end

	function integer find_a1_write_index;
    input [13:0] addr;
    
    if (RAM1_ADDR_WIDTH == A1_WRITE_ADDR_WIDTH)
      find_a1_write_index = 0;
    else    
      find_a1_write_index = ADDR_A1[13-RAM1_ADDR_WIDTH:14-A1_WRITE_ADDR_WIDTH]; 

  endfunction

  function integer find_a1_read_index;
    input [13:0] addr;
    
    if (RAM1_ADDR_WIDTH == A1_READ_ADDR_WIDTH)
      find_a1_read_index = 0;
    else    
      find_a1_read_index = ADDR_A1[13-RAM1_ADDR_WIDTH:14-A1_READ_ADDR_WIDTH]; 

  endfunction

  function integer find_b1_write_index;
    input [13:0] addr;
    
    if (RAM1_ADDR_WIDTH == B1_WRITE_ADDR_WIDTH)
      find_b1_write_index = 0;
    else    
      find_b1_write_index = ADDR_B1[13-RAM1_ADDR_WIDTH:14-B1_WRITE_ADDR_WIDTH]; 

  endfunction

  function integer find_b1_read_index;
    input [13:0] addr;
    
    if (RAM1_ADDR_WIDTH == B1_READ_ADDR_WIDTH)
      find_b1_read_index = 0;
    else    
      find_b1_read_index = ADDR_B1[13-RAM1_ADDR_WIDTH:14-B1_READ_ADDR_WIDTH]; 

  endfunction

  function integer find_a2_write_index;
    input [13:0] addr;
    
    if (RAM2_ADDR_WIDTH == A2_WRITE_ADDR_WIDTH)
      find_a2_write_index = 0;
    else    
      find_a2_write_index = ADDR_A2[13-RAM2_ADDR_WIDTH:14-A2_WRITE_ADDR_WIDTH]; 

  endfunction

  function integer find_a2_read_index;
    input [13:0] addr;
    
    if (RAM2_ADDR_WIDTH == A2_READ_ADDR_WIDTH)
      find_a2_read_index = 0;
    else    
      find_a2_read_index = ADDR_A2[13-RAM2_ADDR_WIDTH:14-A2_READ_ADDR_WIDTH]; 

  endfunction

  function integer find_b2_write_index;
    input [13:0] addr;
    
    if (RAM2_ADDR_WIDTH == B2_WRITE_ADDR_WIDTH)
      find_b2_write_index = 0;
    else    
      find_b2_write_index = ADDR_B2[13-RAM2_ADDR_WIDTH:14-B2_WRITE_ADDR_WIDTH]; 

  endfunction

  function integer find_b2_read_index;
    input [13:0] addr;
    
    if (RAM2_ADDR_WIDTH == B2_READ_ADDR_WIDTH)
      find_b2_read_index = 0;
    else    
      find_b2_read_index = ADDR_B2[13-RAM2_ADDR_WIDTH:14-B2_READ_ADDR_WIDTH]; 

  endfunction

	function integer calc_data_width;
    input integer width;
    if (width==9)
      calc_data_width = 8;
    else if (width==18) 
      calc_data_width = 16;
    else
      calc_data_width = width;
  endfunction

  function integer calc_parity_width;
    input integer width;
    if (width==9)
      calc_parity_width = 1;
    else if (width==18) 
      calc_parity_width = 2;
    else
      calc_parity_width = 0;
  endfunction

  function integer calc_depth;
    input integer width;
    if (width<=1)
      calc_depth = 14;
    else if (width<=2) 
      calc_depth = 13;
    else if (width<=4) 
      calc_depth = 12;
    else if (width<=9) 
      calc_depth = 11;
    else if (width<=18) 
      calc_depth = 10;
    else
      calc_depth = 0;
  endfunction

  initial
    $timeformat(-9,0," ns", 5); initial begin

    if ((WRITE_WIDTH_A1 < 1) || (WRITE_WIDTH_A1 > 18)) begin
       $display("TDP_RAM18KX2 instance %m WRITE_WIDTH_A1 set to incorrect value, %d.  Values must be between 1 and 18.", WRITE_WIDTH_A1);
    #1 $stop;
    end

    if ((WRITE_WIDTH_B1 < 1) || (WRITE_WIDTH_B1 > 18)) begin
       $display("TDP_RAM18KX2 instance %m WRITE_WIDTH_B1 set to incorrect value, %d.  Values must be between 1 and 18.", WRITE_WIDTH_B1);
    #1 $stop;
    end

    if ((READ_WIDTH_A1 < 1) || (READ_WIDTH_A1 > 18)) begin
       $display("TDP_RAM18KX2 instance %m READ_WIDTH_A1 set to incorrect value, %d.  Values must be between 1 and 18.", READ_WIDTH_A1);
    #1 $stop;
    end

    if ((READ_WIDTH_B1 < 1) || (READ_WIDTH_B1 > 18)) begin
       $display("TDP_RAM18KX2 instance %m READ_WIDTH_B1 set to incorrect value, %d.  Values must be between 1 and 18.", READ_WIDTH_B1);
    #1 $stop;
    end

    if ((WRITE_WIDTH_A2 < 1) || (WRITE_WIDTH_A2 > 18)) begin
       $display("TDP_RAM18KX2 instance %m WRITE_WIDTH_A2 set to incorrect value, %d.  Values must be between 1 and 18.", WRITE_WIDTH_A2);
    #1 $stop;
    end

    if ((WRITE_WIDTH_B2 < 1) || (WRITE_WIDTH_B2 > 18)) begin
       $display("TDP_RAM18KX2 instance %m WRITE_WIDTH_B2 set to incorrect value, %d.  Values must be between 1 and 18.", WRITE_WIDTH_B2);
    #1 $stop;
    end

    if ((READ_WIDTH_A2 < 1) || (READ_WIDTH_A2 > 18)) begin
       $display("TDP_RAM18KX2 instance %m READ_WIDTH_A2 set to incorrect value, %d.  Values must be between 1 and 18.", READ_WIDTH_A2);
    #1 $stop;
    end

    if ((READ_WIDTH_B2 < 1) || (READ_WIDTH_B2 > 18)) begin
       $display("TDP_RAM18KX2 instance %m READ_WIDTH_B2 set to incorrect value, %d.  Values must be between 1 and 18.", READ_WIDTH_B2);
    #1 $stop;
    end

  end

endmodule
`endcelldefine

`endif