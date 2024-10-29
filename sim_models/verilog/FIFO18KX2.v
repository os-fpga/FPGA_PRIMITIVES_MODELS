`timescale 1ns/1ps
`celldefine
//
// FIFO18KX2 simulation model
// Dual 18Kb FIFO
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

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


  //FIFO1 sync 
  localparam DATA_WIDTH1 = DATA_WRITE_WIDTH1; 
  localparam  fifo_depth1 = (DATA_WIDTH1 <= 9) ? 2048 : 1024;  
  localparam  fifo_addr_width1 = (DATA_WIDTH1 <= 9) ? 11 :  10;

  reg [fifo_addr_width1-1:0] fifo_wr_addr1 = {fifo_addr_width1{1'b0}};
  reg [fifo_addr_width1-1:0] fifo_rd_addr1 = {fifo_addr_width1{1'b0}};



  reg fall_through1;
  reg wr_data_fwft1;
  reg [DATA_WIDTH1-1:0] fwft_data1 = {DATA_WIDTH1{1'b0}};

// common
  reg fwft1 = 1'b0;  
  wire [15:0] ram_wr_data1;
  wire [1:0] ram_wr_parity1;

  wire [15:0] ram_rd_data1; 
  wire [1:0]  ram_rd_parity1;
  wire ram_clk_b1;
//  
  integer number_entries1 = 0;
  reg underrun_status1 = 0;
  reg overrun_status1 = 0;

// FOR ASYNC FIFO1
  localparam WRITE_DATA_WIDTH1= DATA_WRITE_WIDTH1;
  localparam READ_DATA_WIDTH1= DATA_READ_WIDTH1;
  
  localparam  fifo_depth_write1 = (WRITE_DATA_WIDTH1 <= 9) ? 2048 : 1024;
  localparam  fifo_depth_read1 = (READ_DATA_WIDTH1 <= 9) ? 2048 :  1024;

  localparam  fifo_addr_width_write1 = (WRITE_DATA_WIDTH1 <= 9) ? 11 :  10;
  localparam  fifo_addr_width_read1 = (READ_DATA_WIDTH1 <= 9) ? 11 :  10;


  reg [fifo_addr_width_write1-1:0] async_fifo_wr_addr1 = {fifo_addr_width_write1{1'b0}};
  reg [fifo_addr_width_read1-1:0] async_fifo_rd_addr1 = {fifo_addr_width_read1{1'b0}};
 
  reg [READ_DATA_WIDTH1-1:0] async_fwft_data1 = {READ_DATA_WIDTH1{1'b0}};

  assign async_ram_clk_b1 = RD_CLK1;

  parameter W_PTR_WIDTH1 = $clog2(fifo_depth_write1);
  parameter R_PTR_WIDTH1 = $clog2(fifo_depth_read1);

  wire [W_PTR_WIDTH1:0] b_wptr_sync1, b_wptr_w1, b_wptr_sync1_for_a;
  wire [R_PTR_WIDTH1:0] b_rptr_sync1, b_rptr_w1, b_rptr_w11, b_rptr_sync1_for_a;


  // generate



    if ( FIFO_TYPE1 == "SYNCHRONOUS" )  begin: sync


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
      tdp_ram18kx2_inst1
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
      );


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

      // assign ram_clk_b1 = RD_CLK1;
  

   always @(posedge WR_CLK1) begin
    if(RESET1)
    fwft1 <=0;
   end

    if(READ_DATA_WIDTH1==9) begin
      assign RD_DATA1 = (fwft1 ? async_fwft_data1 : {ram_rd_parity1[0], ram_rd_data1[7:0]});    
    end

    if(READ_DATA_WIDTH1==18) begin
      assign RD_DATA1 = fwft1 ? async_fwft_data1 : {ram_rd_parity1[1], ram_rd_data1[15:8], ram_rd_parity1[0], ram_rd_data1[7:0]};    
    end

    if(WRITE_DATA_WIDTH1==9) begin       
      assign ram_wr_data1 = {{16-WRITE_DATA_WIDTH1{1'b0}}, WR_DATA1[WRITE_DATA_WIDTH1-2:0]};
      assign ram_wr_parity1 = {3'b0, WR_DATA1[WRITE_DATA_WIDTH1-1]};
    end
    
    if(WRITE_DATA_WIDTH1==18) begin 
      assign ram_wr_data1 = {{18-WRITE_DATA_WIDTH1{1'b0}}, WR_DATA1[16:9],WR_DATA1[7:0]};
      assign ram_wr_parity1 = {2'b00, WR_DATA1[17], WR_DATA1[8]};
    end
    

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
      tdp_ram18kx2_inst1
      (
        // Ports for 1st 18K RAM
        .WEN_A1(WR_EN1), // Write-enable port A, RAM 1
        .WEN_B1(1'b0), // Write-enable port B, RAM 1
        .REN_A1(1'b0), // Read-enable port A, RAM 1
        .REN_B1(RD_EN1), // Read-enable port B, RAM 1
        .CLK_A1(WR_CLK1), // Clock port A, RAM 1
        .CLK_B1(async_ram_clk_b1), // Clock port B, RAM 1
        .BE_A1(2'b11), // Byte-write enable port A, RAM 1
        .BE_B1(2'b11), // Byte-write enable port B, RAM 1
        .ADDR_A1({b_wptr_w1, {14-fifo_addr_width_write1{1'b0}}}), // Address port A, RAM 1
        .ADDR_B1({b_rptr_w1, {14-fifo_addr_width_read1{1'b0}}}), // Address port B, RAM 1
        .WDATA_A1(ram_wr_data1), // Write data port A, RAM 1
        .WPARITY_A1(ram_wr_parity1), // Write parity port A, RAM 1
        .WDATA_B1(16'h0000), // Write data port B, RAM 1
        .WPARITY_B1(2'b00), // Write parity port B, RAM 1
        .RDATA_A1(), // Read data port A, RAM 1
        .RPARITY_A1(), // Read parity port A, RAM 1
        .RDATA_B1(ram_rd_data1), // Read data port B, RAM 1
        .RPARITY_B1(ram_rd_parity1), // Read parity port B, RAM 1
        // Ports for 2nd 18K RAM
        .WEN_A2(), // Write-enable port A, RAM 2
        .WEN_B2(), // Write-enable port B, RAM 2
        .REN_A2(), // Read-enable port A, RAM 2
        .REN_B2(), // Read-enable port B, RAM 2
        .CLK_A2(), // Clock port A, RAM 2
        .CLK_B2(), // Clock port B, RAM 2
        .BE_A2(), // Byte-write enable port A, RAM 2
        .BE_B2(), // Byte-write enable port B, RAM 2
        .ADDR_A2(), // Address port A, RAM 2
        .ADDR_B2(), // Address port B, RAM 2
        .WDATA_A2(), // Write data port A, RAM 2
        .WPARITY_A2(), // Write parity port A, RAM 2
        .WDATA_B2(), // Write data port B, RAM 2
        .WPARITY_B2(), // Write parity port B, RAM 2
        .RDATA_A2(), // Read data port A, RAM 2
        .RPARITY_A2(), // Read parity port A, RAM 2
        .RDATA_B2(), // Read data port B, RAM 2
        .RPARITY_B2() // Read parity port B, RAM 2
      );


//////

/*---------Write pointer synchronizer ( 2 FLOPS) logic--------------*/


  reg [W_PTR_WIDTH1:0] q11, q11_a, d_out11;

  assign b_wptr_sync1 = d_out11;
  assign b_wptr_sync1_for_a = q11_a;

  always@(posedge RD_CLK1) begin
    if(RESET1) begin
      q11 <= 0;
      d_out11 <= 0;
      q11_a <=0;
    end
    else begin
      q11 <= b_wptr_w1;
      d_out11 <= q11;
      q11_a <= d_out11;
    end
  end

/*-------------------------------------------------------------------*/

/*--------- Read pointer synchronizer (2 FLOPS ) logic --------------*/

reg [R_PTR_WIDTH1:0] q21, q21_a, d_out21;

assign b_rptr_sync1 = d_out21;
assign b_rptr_sync1_for_a = q21_a;

  always@(posedge WR_CLK1) begin
    if(RESET1) begin
      q21 <= 0;
      d_out21 <= 0;
      q21_a=0;
    end
    else begin
      q21 <= b_rptr_w1;
      d_out21 <= q21;
      q21_a <= d_out21;
    end
  end

/*-------------------------------------------------------------------*/

/* ---------------- Write pointer handler logic ---------------------*/

  localparam SCALING_FACTOR_WPTR1= (READ_DATA_WIDTH1>WRITE_DATA_WIDTH1)? (READ_DATA_WIDTH1/WRITE_DATA_WIDTH1):1;


  wire [W_PTR_WIDTH1:0] b_wptr_next1;

  reg [W_PTR_WIDTH1:0] b_wptr1;

  wire wfull1, al_full1, p_full1; 

  wire [W_PTR_WIDTH1:0] diff_ptr01, diff_ptr21, diff_ptr01_for_a;

  assign b_wptr_next1 = b_wptr1+(WR_EN1 & !FULL1);

  assign b_wptr_w1 = b_wptr1;

  reg [2:0] rem1,rem11, rem21, rem31;

  always @(posedge WR_CLK1) begin
    rem11 <= b_wptr_next1%(SCALING_FACTOR_WPTR1);
  end

 always @(posedge WR_CLK1) begin
    rem21 <= b_rptr_sync1%(SCALING_FACTOR_WPTR1);
  end

  assign diff_ptr01 =(WRITE_DATA_WIDTH1>READ_DATA_WIDTH1)? /* W>R */ ((((b_wptr_next1/SCALING_FACTOR_WPTR1  >= (b_rptr_sync1/SCALING_FACTOR_RPTR1))? (b_wptr_next1/SCALING_FACTOR_WPTR1-(b_rptr_sync1/SCALING_FACTOR_RPTR1)): (b_wptr_next1/SCALING_FACTOR_WPTR1+(1<<(W_PTR_WIDTH1+1))-(b_rptr_sync1/SCALING_FACTOR_RPTR1)))))

  : (  (READ_DATA_WIDTH1>WRITE_DATA_WIDTH1)? ( /* R>W */ ((((b_wptr_next1*SCALING_FACTOR_RPTR1  >= (b_rptr_sync1*SCALING_FACTOR_WPTR1))? (b_wptr_next1*SCALING_FACTOR_RPTR1-(b_rptr_sync1*SCALING_FACTOR_WPTR1)): (b_wptr_next1*SCALING_FACTOR_RPTR1+(1<<(W_PTR_WIDTH1+1))-(b_rptr_sync1*SCALING_FACTOR_WPTR1))))) ) 

  : /* R==W */ ((((b_wptr_next1  >= (b_rptr_sync1 ))? (b_wptr_next1 - (b_rptr_sync1)): (b_wptr_next1 + (1<<(W_PTR_WIDTH1+1))-(b_rptr_sync1 ))))) );  

  // assign wfull = (DATA_WIDTH_WRITE>DATA_WIDTH_READ)? (diff_ptr0 == (1<<W_PTR_WIDTH)) : (diff_ptr0 == (1<<R_PTR_WIDTH) );
 
  assign diff_ptr01_for_a=(WRITE_DATA_WIDTH1>READ_DATA_WIDTH1)? /* W>R */ ((((b_wptr_next1/SCALING_FACTOR_WPTR1  >= (b_rptr_sync1_for_a/SCALING_FACTOR_RPTR1))? (b_wptr_next1/SCALING_FACTOR_WPTR1-(b_rptr_sync1_for_a/SCALING_FACTOR_RPTR1)): (b_wptr_next1/SCALING_FACTOR_WPTR1+(1<<(W_PTR_WIDTH1+1))-(b_rptr_sync1_for_a/SCALING_FACTOR_RPTR1)))))

   : (  (READ_DATA_WIDTH1>WRITE_DATA_WIDTH1)? ( /* R>W */ ((((b_wptr_next1*SCALING_FACTOR_RPTR1  >= (b_rptr_sync1_for_a*SCALING_FACTOR_WPTR1))? (b_wptr_next1*SCALING_FACTOR_RPTR1-(b_rptr_sync1_for_a*SCALING_FACTOR_WPTR1)): (b_wptr_next1*SCALING_FACTOR_RPTR1+(1<<(W_PTR_WIDTH1+1))-(b_rptr_sync1_for_a*SCALING_FACTOR_WPTR1))))) ) 

  : /* R==W */ ((((b_wptr_next1  >= (b_rptr_sync1_for_a ))? (b_wptr_next1 - (b_rptr_sync1_for_a)): (b_wptr_next1 + (1<<(W_PTR_WIDTH1+1))-(b_rptr_sync1_for_a ))))) );  
  
  assign wfull1 = (WRITE_DATA_WIDTH1>READ_DATA_WIDTH1)? (diff_ptr01 == (1<<W_PTR_WIDTH1)) : ( (WRITE_DATA_WIDTH1<READ_DATA_WIDTH1)? (diff_ptr01 == (1<<R_PTR_WIDTH1+1)) : (diff_ptr01 == (1<<R_PTR_WIDTH1)) );


  assign al_full1 = (WRITE_DATA_WIDTH1>READ_DATA_WIDTH1)? (diff_ptr01 == (1<<W_PTR_WIDTH1)-1): ( (WRITE_DATA_WIDTH1<READ_DATA_WIDTH1)? (diff_ptr01 == ((1<<R_PTR_WIDTH1+1)-1) ) :  (diff_ptr01 == ((1<<R_PTR_WIDTH1)-1) ));

  assign p_full1 = (WRITE_DATA_WIDTH1>READ_DATA_WIDTH1)? (diff_ptr01_for_a >= ((1<<W_PTR_WIDTH1)-PROG_FULL_THRESH1+1) ) : ( (WRITE_DATA_WIDTH1<READ_DATA_WIDTH1)? ( (diff_ptr01_for_a >= ((1<<R_PTR_WIDTH1+1)-PROG_FULL_THRESH1+1) ) ) : ( (diff_ptr01_for_a >= ((1<<R_PTR_WIDTH1)-PROG_FULL_THRESH1+1) ) ) );


  always@(posedge WR_CLK1 or posedge RESET1) begin
    if(RESET1) begin
      b_wptr1 <= 0; // set default value
    end
    else begin
      b_wptr1 <= b_wptr_next1; // incr binary write pointer
    end
  end
  
  always@(posedge WR_CLK1 or posedge RESET1) begin
    if(RESET1) begin
      FULL1 <= 0;
      ALMOST_FULL1 <= 'b0;
      PROG_FULL1 <= 0;
    end
    else begin

      FULL1 <= wfull1 ;
      ALMOST_FULL1 <= al_full1 ; 
      PROG_FULL1 <= p_full1  ;
    end
  end

/*---------------------------------------------------------------*/

/*-----------  READ pointer handler logic -----------------------*/

localparam SCALING_FACTOR_RPTR1= (READ_DATA_WIDTH1<WRITE_DATA_WIDTH1)? (WRITE_DATA_WIDTH1/READ_DATA_WIDTH1):1;

wire [R_PTR_WIDTH1:0] diff_ptr11, diff_ptr11_for_a;
reg [R_PTR_WIDTH1:0] b_rptr_next1, b_rptr1;


always @(*) begin

    if(RESET1) begin
      b_rptr_next1 =0;
    end
    if((RD_EN1 & !EMPTY1)) begin
      if (b_rptr_next1==(1<<R_PTR_WIDTH1+1)) begin  
         b_rptr_next1 <=0;
      end
      else begin
        b_rptr_next1 = b_rptr_next1+1;      
      end
    end
end

assign b_rptr_w1 = b_rptr_next1;
assign b_rptr_w11 = b_rptr1;

assign diff_ptr11 = (WRITE_DATA_WIDTH1 > READ_DATA_WIDTH1)?   ( ((b_wptr_sync1*SCALING_FACTOR_RPTR1) >= (b_rptr_next1*SCALING_FACTOR_WPTR1))? (b_wptr_sync1*SCALING_FACTOR_RPTR1-(b_rptr_next1*SCALING_FACTOR_WPTR1)): (b_wptr_sync1*SCALING_FACTOR_RPTR1+(1<<(R_PTR_WIDTH1+1))-(b_rptr_next1*SCALING_FACTOR_WPTR1)))
 
 : ( (READ_DATA_WIDTH1 > WRITE_DATA_WIDTH1)?  (((b_wptr_sync1/SCALING_FACTOR_WPTR1) >= (b_rptr_next1/SCALING_FACTOR_RPTR1))? (b_wptr_sync1/SCALING_FACTOR_WPTR1-(b_rptr_next1/SCALING_FACTOR_RPTR1)): (b_wptr_sync1/SCALING_FACTOR_WPTR1+(1<<(R_PTR_WIDTH1+1))-(b_rptr_next1/SCALING_FACTOR_RPTR1)))  
 
 : (((b_wptr_sync1) >= (b_rptr_next1))? (b_wptr_sync1-(b_rptr_next1)): (b_wptr_sync1+(1<<(W_PTR_WIDTH1+1))-(b_rptr_next1))) )   ;


assign diff_ptr11_for_a = (WRITE_DATA_WIDTH1 > READ_DATA_WIDTH1)?   ( ((b_wptr_sync1_for_a*SCALING_FACTOR_RPTR1) >= (b_rptr_next1*SCALING_FACTOR_WPTR1))? (b_wptr_sync1_for_a*SCALING_FACTOR_RPTR1-(b_rptr_next1*SCALING_FACTOR_WPTR1)): (b_wptr_sync1_for_a*SCALING_FACTOR_RPTR1+(1<<(R_PTR_WIDTH1+1))-(b_rptr_next1*SCALING_FACTOR_WPTR1)))
 
 : ( (READ_DATA_WIDTH1 > WRITE_DATA_WIDTH1)?  (((b_wptr_sync1_for_a/SCALING_FACTOR_WPTR1) >= (b_rptr_next1/SCALING_FACTOR_RPTR1))? (b_wptr_sync1_for_a/SCALING_FACTOR_WPTR1-(b_rptr_next1/SCALING_FACTOR_RPTR1)): (b_wptr_sync1_for_a/SCALING_FACTOR_WPTR1+(1<<(R_PTR_WIDTH1+1))-(b_rptr_next1/SCALING_FACTOR_RPTR1)))  
 
 : (((b_wptr_sync1_for_a) >= (b_rptr_next1))? (b_wptr_sync1_for_a-(b_rptr_next1)): (b_wptr_sync1_for_a+(1<<(W_PTR_WIDTH1+1))-(b_rptr_next1))) )   ;



assign rempty1= (diff_ptr11==0)?1:0;

assign al_empty1 = (diff_ptr11 ==1)? 1:0;

assign p_empty1 = (diff_ptr11_for_a ==PROG_EMPTY_THRESH1-1 || diff_ptr11_for_a <=PROG_EMPTY_THRESH1-1 )? 1:0;


  always@(posedge RD_CLK1 or posedge RESET1) begin

    if(RESET1) begin
      b_rptr1 <= 0;
    end
    else begin
      b_rptr1 <= b_rptr_next1;
    end

  end
  
  always@(posedge RD_CLK1 or posedge RESET1) begin

    if(RESET1) begin 
      EMPTY1 <= 1;
      ALMOST_EMPTY1 <= 0;
      PROG_EMPTY1 <=1;
    end
    else begin

        
      EMPTY1 <= rempty1;
      ALMOST_EMPTY1 <= al_empty1;
      PROG_EMPTY1 <= p_empty1;    
      
    end 
  end


/*------------------------------------------------------------------*/

/*------------- Adding logic of First word fall through ------------*/

    always@(posedge WR_CLK1) begin
// -1
        if (WRITE_DATA_WIDTH1 >= READ_DATA_WIDTH1) begin
              fwft1 <= (EMPTY1 && WR_EN1 && !fwft1)? 1 : fwft1;
            if (EMPTY1 && WR_EN1 && !fwft1) begin
              if (WRITE_DATA_WIDTH1==READ_DATA_WIDTH1) begin
                async_fwft_data1 <= WR_DATA1;
              end
              else if (WRITE_DATA_WIDTH1==18 && READ_DATA_WIDTH1==9) begin
                async_fwft_data1 <= {{WR_DATA1[8]},{WR_DATA1[7:0]}} ;  // DEVELOP LOGIC FOR OTHER WIDTH AS WELL
              end

            end
        end
// -2          
        if (WRITE_DATA_WIDTH1 == 9 && READ_DATA_WIDTH1==18) begin

              fwft1 <= (EMPTY1 && WR_EN1 && !fwft1)? 1 : fwft1;

              if(b_wptr_next1==1 || b_wptr_next1==4097 ) begin
                async_fwft_data1 [7:0] <= WR_DATA1[7:0] ;
                async_fwft_data1 [8] <= WR_DATA1[8] ;
              end
              if(b_wptr_next1==2 || b_wptr_next1==4098 ) begin
                async_fwft_data1 [16:9] <= WR_DATA1[7:0];
                async_fwft_data1 [17] <= WR_DATA1[8];
              end     
        end

  end

  always @ (posedge RD_CLK1) begin
        if(RD_EN1) begin
            fwft1 =0;
        end
  end


/*---------------------------------------------------------------*/

/*--------- Adding logic of OVERFLOW and UNDERFLOW -----------*/

    always @(posedge WR_CLK1) begin
      if (RESET1) begin
       OVERFLOW1 <= 0;
      end
      else if (FULL1 & WR_EN1 ) begin
       OVERFLOW1 <= 1;
      end

    end

    always @(posedge RD_CLK1) begin 
        if (RESET1) begin
          OVERFLOW1 <= 0;
        end
        else if(RD_EN1 & OVERFLOW1) begin
          OVERFLOW1 <= 0;
        end
    end

    always @(posedge RD_CLK1) begin

      if (RESET1) begin
        UNDERFLOW1 <= 0;
      end
      else if (EMPTY1 & RD_EN1) begin
         UNDERFLOW1 <= 1;
      end
    end

    always @(posedge WR_CLK1) begin
      if (RESET1) begin
       UNDERFLOW1 <= 0;
      end
      else if (EMPTY1 & WR_EN1 ) begin
       UNDERFLOW1 <= 0;
      end

    end

always @(*) begin    
    if (OVERFLOW1) begin
        @(posedge WR_CLK1) begin
        $fatal(1,"\n Error: OVERFLOW1 Happend, RESET1 THE FIFO1 FIRST \n", OVERFLOW1 );             
        end 
     end
end

always @(*) begin    
    if (UNDERFLOW1) begin
        @(posedge RD_CLK1) begin
        $fatal(1,"\n Error: UNDERFLOW1 Happend, RESET1 THE FIFO1 FIRST \n", UNDERFLOW1 );             
        end 
     end
end


    end

  // endgenerate

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


// FOR ASYNC FIFO2
  localparam WRITE_DATA_WIDTH2= DATA_WRITE_WIDTH2;
  localparam READ_DATA_WIDTH2= DATA_READ_WIDTH2;
  
  localparam  fifo_depth_write2 = (WRITE_DATA_WIDTH2 <= 9) ? 2048 : 1024;
  localparam  fifo_depth_read2 = (READ_DATA_WIDTH2 <= 9) ? 2048 :  1024;

  localparam  fifo_addr_width_write2 = (WRITE_DATA_WIDTH2 <= 9) ? 11 :  10;
  localparam  fifo_addr_width_read2 = (READ_DATA_WIDTH2 <= 9) ? 11 :  10;


  reg [fifo_addr_width_write2-1:0] async_fifo_wr_addr2 = {fifo_addr_width_write2{1'b0}};
  reg [fifo_addr_width_read2-1:0] async_fifo_rd_addr2 = {fifo_addr_width_read2{1'b0}};
 
  reg [READ_DATA_WIDTH2-1:0] async_fwft_data2 = {READ_DATA_WIDTH2{1'b0}};

  assign async_ram_clk_b2 = RD_CLK2;

  parameter W_PTR_WIDTH2 = $clog2(fifo_depth_write2);
  parameter R_PTR_WIDTH2 = $clog2(fifo_depth_read2);

  wire [W_PTR_WIDTH2:0] b_wptr_sync2, b_wptr_w2, b_wptr_sync2_for_a;
  wire [R_PTR_WIDTH2:0] b_rptr_sync2, b_rptr_w2, b_rptr_w12, b_rptr_sync2_for_a;


  // generate


    if ( FIFO_TYPE2 == "SYNCHRONOUS" )  begin: sync_fifo2

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
    tdp_ram18kx2_inst2
    (
      // Ports for 1st 18K RAM
      .WEN_A1(), // Write-enable port A, RAM 1
      .WEN_B1(), // Write-enable port B, RAM 1
      .REN_A1(), // Read-enable port A, RAM 1
      .REN_B1(), // Read-enable port B, RAM 1
      .CLK_A1(), // Clock port A, RAM 1
      .CLK_B1(), // Clock port B, RAM 1
      .BE_A1(), // Byte-write enable port A, RAM 1
      .BE_B1(), // Byte-write enable port B, RAM 1
      .ADDR_A1(), // Address port A, RAM 1
      .ADDR_B1(), // Address port B, RAM 1
      .WDATA_A1(), // Write data port A, RAM 1
      .WPARITY_A1(), // Write parity port A, RAM 1
      .WDATA_B1(), // Write data port B, RAM 1
      .WPARITY_B1(), // Write parity port B, RAM 1
      .RDATA_A1(), // Read data port A, RAM 1
      .RPARITY_A1(), // Read parity port A, RAM 1
      .RDATA_B1(), // Read data port B, RAM 1
      .RPARITY_B1(), // Read parity port B, RAM 1
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
    );

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

      // assign ram_clk_b2 = RD_CLK2;

   always @(posedge WR_CLK2) begin
    if(RESET2)
    fwft2 <=0;
   end

    if(READ_DATA_WIDTH2==9) begin
      assign RD_DATA2 = (fwft2 ? async_fwft_data2 : {ram_rd_parity2[0], ram_rd_data2[7:0]});    
    end

    if(READ_DATA_WIDTH2==18) begin
      assign RD_DATA2 = fwft2 ? async_fwft_data2 : {ram_rd_parity2[1], ram_rd_data2[15:8], ram_rd_parity2[0], ram_rd_data2[7:0]};    
    end

    if(WRITE_DATA_WIDTH2==9) begin       
      assign ram_wr_data2 = {{16-WRITE_DATA_WIDTH2{1'b0}}, WR_DATA2[WRITE_DATA_WIDTH2-2:0]};
      assign ram_wr_parity2 = {3'b0, WR_DATA2[WRITE_DATA_WIDTH2-1]};
    end
    
    if(WRITE_DATA_WIDTH2==18) begin 
      assign ram_wr_data2 = {{18-WRITE_DATA_WIDTH2{1'b0}}, WR_DATA2[16:9],WR_DATA2[7:0]};
      assign ram_wr_parity2 = {2'b00, WR_DATA2[17], WR_DATA2[8]};
    end

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
      tdp_ram18kx2_inst2
      (
        // Ports for 1st 18K RAM
        .WEN_A1(), // Write-enable port A, RAM 1
        .WEN_B1(), // Write-enable port B, RAM 1
        .REN_A1(), // Read-enable port A, RAM 1
        .REN_B1(), // Read-enable port B, RAM 1
        .CLK_A1(), // Clock port A, RAM 1
        .CLK_B1(), // Clock port B, RAM 1
        .BE_A1(), // Byte-write enable port A, RAM 1
        .BE_B1(), // Byte-write enable port B, RAM 1
        .ADDR_A1(), // Address port A, RAM 1
        .ADDR_B1(), // Address port B, RAM 1
        .WDATA_A1(), // Write data port A, RAM 1
        .WPARITY_A1(), // Write parity port A, RAM 1
        .WDATA_B1(), // Write data port B, RAM 1
        .WPARITY_B1(), // Write parity port B, RAM 1
        .RDATA_A1(), // Read data port A, RAM 1
        .RPARITY_A1(), // Read parity port A, RAM 1
        .RDATA_B1(), // Read data port B, RAM 1
        .RPARITY_B1(), // Read parity port B, RAM 1
        // Ports for 2nd 18K RAM
        .WEN_A2(WR_EN2), // Write-enable port A, RAM 2
        .WEN_B2(1'b0), // Write-enable port B, RAM 2
        .REN_A2(1'b0), // Read-enable port A, RAM 2
        .REN_B2(RD_EN2), // Read-enable port B, RAM 2
        .CLK_A2(WR_CLK2), // Clock port A, RAM 2
        .CLK_B2(async_ram_clk_b2), // Clock port B, RAM 2
        .BE_A2(2'b11), // Byte-write enable port A, RAM 2
        .BE_B2(2'b11), // Byte-write enable port B, RAM 2
        .ADDR_A2({b_wptr_w2, {14-fifo_addr_width_write2{1'b0}}}), // Address port A, RAM 2
        .ADDR_B2({b_rptr_w2, {14-fifo_addr_width_read2{1'b0}}}), // Address port B, RAM 2
        .WDATA_A2(ram_wr_data2), // Write data port A, RAM 2
        .WPARITY_A2(ram_wr_parity2), // Write parity port A, RAM 2
        .WDATA_B2(16'h0000), // Write data port B, RAM 2
        .WPARITY_B2(2'b00), // Write parity port B, RAM 2
        .RDATA_A2(), // Read data port A, RAM 2
        .RPARITY_A2(), // Read parity port A, RAM 2
        .RDATA_B2(ram_rd_data2), // Read data port B, RAM 2
        .RPARITY_B2(ram_rd_parity2) // Read parity port B, RAM 2
      );


/*---------Write pointer synchronizer ( 2 FLOPS) logic--------------*/


  reg [W_PTR_WIDTH2:0] q12,q12_a, d_out12;

  assign b_wptr_sync2 = d_out12;
  assign b_wptr_sync2_for_a=q12_a;

  always@(posedge RD_CLK2) begin
    if(RESET2) begin
      q12 <= 0;
      d_out12 <= 0;
      q12_a <=0;
    end
    else begin
      q12 <= b_wptr_w2;
      d_out12 <= q12;
      q12_a <= d_out12;
    end
  end

/*-------------------------------------------------------------------*/

/*--------- Read pointer synchronizer (2 FLOPS ) logic --------------*/

reg [R_PTR_WIDTH2:0] q22,q22_a, d_out22;

assign b_rptr_sync2 = d_out22;
assign b_rptr_sync2_for_a= q22_a;

  always@(posedge WR_CLK2) begin
    if(RESET2) begin
      q22 <= 0;
      d_out22 <= 0;
      q22_a <=0;
    end
    else begin
      q22 <= b_rptr_w2;
      d_out22 <= q22;
      q22_a <= d_out22;
    end
  end

/*-------------------------------------------------------------------*/

/* ---------------- Write pointer handler logic ---------------------*/

  localparam SCALING_FACTOR_WPTR2= (READ_DATA_WIDTH2>WRITE_DATA_WIDTH2)? (READ_DATA_WIDTH2/WRITE_DATA_WIDTH2):1;


  wire [W_PTR_WIDTH2:0] b_wptr_next2;

  reg [W_PTR_WIDTH2:0] b_wptr2;

  wire wfull2, al_full2, p_full2; 

  wire [W_PTR_WIDTH2:0] diff_ptr02, diff_ptr22, diff_ptr02_for_a;

  assign b_wptr_next2 = b_wptr2+(WR_EN2 & !FULL2);

  assign b_wptr_w2 = b_wptr2;

  reg [2:0] rem2,rem12, rem22, rem32;

  always @(posedge WR_CLK2) begin
    rem12 <= b_wptr_next2%(SCALING_FACTOR_WPTR2);
  end

 always @(posedge WR_CLK2) begin
    rem22 <= b_rptr_sync2%(SCALING_FACTOR_WPTR2);
  end

  assign diff_ptr02 =(WRITE_DATA_WIDTH2>READ_DATA_WIDTH2)? /* W>R */ ((((b_wptr_next2/SCALING_FACTOR_WPTR2  >= (b_rptr_sync2/SCALING_FACTOR_RPTR2))? (b_wptr_next2/SCALING_FACTOR_WPTR2-(b_rptr_sync2/SCALING_FACTOR_RPTR2)): (b_wptr_next2/SCALING_FACTOR_WPTR2+(1<<(W_PTR_WIDTH2+1))-(b_rptr_sync2/SCALING_FACTOR_RPTR2)))))

  : (  (READ_DATA_WIDTH2>WRITE_DATA_WIDTH2)? ( /* R>W */ ((((b_wptr_next2*SCALING_FACTOR_RPTR2  >= (b_rptr_sync2*SCALING_FACTOR_WPTR2))? (b_wptr_next2*SCALING_FACTOR_RPTR2-(b_rptr_sync2*SCALING_FACTOR_WPTR2)): (b_wptr_next2*SCALING_FACTOR_RPTR2+(1<<(W_PTR_WIDTH2+1))-(b_rptr_sync2*SCALING_FACTOR_WPTR2))))) ) 

  : /* R==W */ ((((b_wptr_next2  >= (b_rptr_sync2 ))? (b_wptr_next2 - (b_rptr_sync2)): (b_wptr_next2 + (1<<(W_PTR_WIDTH2+1))-(b_rptr_sync2 ))))) );  

  // assign wfull = (DATA_WIDTH_WRITE>DATA_WIDTH_READ)? (diff_ptr0 == (1<<W_PTR_WIDTH)) : (diff_ptr0 == (1<<R_PTR_WIDTH) );
 
assign diff_ptr02_for_a= (WRITE_DATA_WIDTH2>READ_DATA_WIDTH2)? /* W>R */ ((((b_wptr_next2/SCALING_FACTOR_WPTR2  >= (b_rptr_sync2_for_a/SCALING_FACTOR_RPTR2))? (b_wptr_next2/SCALING_FACTOR_WPTR2-(b_rptr_sync2_for_a/SCALING_FACTOR_RPTR2)): (b_wptr_next2/SCALING_FACTOR_WPTR2+(1<<(W_PTR_WIDTH2+1))-(b_rptr_sync2_for_a/SCALING_FACTOR_RPTR2)))))

  : (  (READ_DATA_WIDTH2>WRITE_DATA_WIDTH2)? ( /* R>W */ ((((b_wptr_next2*SCALING_FACTOR_RPTR2  >= (b_rptr_sync2_for_a*SCALING_FACTOR_WPTR2))? (b_wptr_next2*SCALING_FACTOR_RPTR2-(b_rptr_sync2_for_a*SCALING_FACTOR_WPTR2)): (b_wptr_next2*SCALING_FACTOR_RPTR2+(1<<(W_PTR_WIDTH2+1))-(b_rptr_sync2_for_a*SCALING_FACTOR_WPTR2))))) ) 

  : /* R==W */ ((((b_wptr_next2  >= (b_rptr_sync2_for_a ))? (b_wptr_next2 - (b_rptr_sync2_for_a)): (b_wptr_next2 + (1<<(W_PTR_WIDTH2+1))-(b_rptr_sync2_for_a ))))) );  


  assign wfull2 = (WRITE_DATA_WIDTH2>READ_DATA_WIDTH2)? (diff_ptr02 == (1<<W_PTR_WIDTH2)) : ( (WRITE_DATA_WIDTH2<READ_DATA_WIDTH2)? (diff_ptr02 == (1<<R_PTR_WIDTH2+1)) : (diff_ptr02 == (1<<R_PTR_WIDTH2)) );


  assign al_full2 = (WRITE_DATA_WIDTH2>READ_DATA_WIDTH2)? (diff_ptr02 == (1<<W_PTR_WIDTH2)-1): ( (WRITE_DATA_WIDTH2<READ_DATA_WIDTH2)? (diff_ptr02 == ((1<<R_PTR_WIDTH2+1)-1) ) :  (diff_ptr02 == ((1<<R_PTR_WIDTH2)-1) ));

  assign p_full2 = (WRITE_DATA_WIDTH2>READ_DATA_WIDTH2)? (diff_ptr02_for_a >= ((1<<W_PTR_WIDTH2)-PROG_FULL_THRESH2+1) ) : ( (WRITE_DATA_WIDTH2<READ_DATA_WIDTH2)? ( (diff_ptr02_for_a >= ((1<<R_PTR_WIDTH2+1)-PROG_FULL_THRESH2+1) ) ) : ( (diff_ptr02_for_a >= ((1<<R_PTR_WIDTH2)-PROG_FULL_THRESH2+1) ) ) );


  always@(posedge WR_CLK2 or posedge RESET2) begin
    if(RESET2) begin
      b_wptr2 <= 0; // set default value
    end
    else begin
      b_wptr2 <= b_wptr_next2; // incr binary write pointer
    end
  end
  
  always@(posedge WR_CLK2 or posedge RESET2) begin
    if(RESET2) begin
      FULL2 <= 0;
      ALMOST_FULL2 <= 'b0;
      PROG_FULL2 <= 0;
    end
    else begin

      FULL2 <= wfull2 ;
      ALMOST_FULL2 <= al_full2 ; 
      PROG_FULL2 <= p_full2  ;
    end
  end

/*---------------------------------------------------------------*/

/*-----------  READ pointer handler logic -----------------------*/

localparam SCALING_FACTOR_RPTR2= (READ_DATA_WIDTH2<WRITE_DATA_WIDTH2)? (WRITE_DATA_WIDTH2/READ_DATA_WIDTH2):1;

wire [R_PTR_WIDTH2:0] diff_ptr12, diff_ptr12_for_a;
reg [R_PTR_WIDTH2:0] b_rptr_next2, b_rptr2;


always @(*) begin

    if(RESET2) begin
      b_rptr_next2 =0;
    end
    if((RD_EN2 & !EMPTY2)) begin
      if (b_rptr_next2==(1<<R_PTR_WIDTH2+1)) begin  
         b_rptr_next2 <=0;
      end
      else begin
        b_rptr_next2 = b_rptr_next2+1;      
      end
    end
end

assign b_rptr_w2 = b_rptr_next2;
assign b_rptr_w12 = b_rptr2;

assign diff_ptr12 = (WRITE_DATA_WIDTH2 > READ_DATA_WIDTH2)?   ( ((b_wptr_sync2*SCALING_FACTOR_RPTR2) >= (b_rptr_next2*SCALING_FACTOR_WPTR2))? (b_wptr_sync2*SCALING_FACTOR_RPTR2-(b_rptr_next2*SCALING_FACTOR_WPTR2)): (b_wptr_sync2*SCALING_FACTOR_RPTR2+(1<<(R_PTR_WIDTH2+1))-(b_rptr_next2*SCALING_FACTOR_WPTR2)))
 
 : ( (READ_DATA_WIDTH2 > WRITE_DATA_WIDTH2)?  (((b_wptr_sync2/SCALING_FACTOR_WPTR2) >= (b_rptr_next2/SCALING_FACTOR_RPTR2))? (b_wptr_sync2/SCALING_FACTOR_WPTR2-(b_rptr_next2/SCALING_FACTOR_RPTR2)): (b_wptr_sync2/SCALING_FACTOR_WPTR2+(1<<(R_PTR_WIDTH2+1))-(b_rptr_next2/SCALING_FACTOR_RPTR2)))  
 
 : (((b_wptr_sync2) >= (b_rptr_next2))? (b_wptr_sync2-(b_rptr_next2)): (b_wptr_sync2+(1<<(W_PTR_WIDTH2+1))-(b_rptr_next2))) )   ;


assign diff_ptr12_for_a= (WRITE_DATA_WIDTH2 > READ_DATA_WIDTH2)?   ( ((b_wptr_sync2_for_a*SCALING_FACTOR_RPTR2) >= (b_rptr_next2*SCALING_FACTOR_WPTR2))? (b_wptr_sync2_for_a*SCALING_FACTOR_RPTR2-(b_rptr_next2*SCALING_FACTOR_WPTR2)): (b_wptr_sync2_for_a*SCALING_FACTOR_RPTR2+(1<<(R_PTR_WIDTH2+1))-(b_rptr_next2*SCALING_FACTOR_WPTR2)))
 
 : ( (READ_DATA_WIDTH2 > WRITE_DATA_WIDTH2)?  (((b_wptr_sync2_for_a/SCALING_FACTOR_WPTR2) >= (b_rptr_next2/SCALING_FACTOR_RPTR2))? (b_wptr_sync2_for_a/SCALING_FACTOR_WPTR2-(b_rptr_next2/SCALING_FACTOR_RPTR2)): (b_wptr_sync2_for_a/SCALING_FACTOR_WPTR2+(1<<(R_PTR_WIDTH2+1))-(b_rptr_next2/SCALING_FACTOR_RPTR2)))  
 
 : (((b_wptr_sync2_for_a) >= (b_rptr_next2))? (b_wptr_sync2_for_a-(b_rptr_next2)): (b_wptr_sync2_for_a+(1<<(W_PTR_WIDTH2+1))-(b_rptr_next2))) )   ;


assign rempty2= (diff_ptr12==0)?1:0;

assign al_empty2 = (diff_ptr12 ==1)? 1:0;

assign p_empty2 = (diff_ptr12_for_a ==PROG_EMPTY_THRESH2-1 || diff_ptr12_for_a <=PROG_EMPTY_THRESH2-1 )? 1:0;


  always@(posedge RD_CLK2 or posedge RESET2) begin

    if(RESET2) begin
      b_rptr2 <= 0;
    end
    else begin
      b_rptr2 <= b_rptr_next2;
    end

  end
  
  always@(posedge RD_CLK2 or posedge RESET2) begin

    if(RESET2) begin 
      EMPTY2 <= 1;
      ALMOST_EMPTY2 <= 0;
      PROG_EMPTY2 <=1;
    end
    else begin

        
      EMPTY2 <= rempty2;
      ALMOST_EMPTY2 <= al_empty2;
      PROG_EMPTY2 <= p_empty2;    
      
    end 
  end


/*------------------------------------------------------------------*/

/*------------- Adding logic of First word fall through ------------*/

    always@(posedge WR_CLK2) begin

// -1
        if (WRITE_DATA_WIDTH2 >= READ_DATA_WIDTH2) begin
              fwft2 <= (EMPTY2 && WR_EN2 && !fwft2)? 1 : fwft2;
            if (EMPTY2 && WR_EN2 && !fwft2) begin
              if (WRITE_DATA_WIDTH2==READ_DATA_WIDTH2) begin
                async_fwft_data2 <= WR_DATA2;
              end
              else if (WRITE_DATA_WIDTH2==18 && READ_DATA_WIDTH2==9) begin
                async_fwft_data2 <= {{WR_DATA2[8]},{WR_DATA2[7:0]}} ;  // DEVELOP LOGIC FOR OTHER WIDTH AS WELL
              end

            end
        end
// -2          
        if (WRITE_DATA_WIDTH2 == 9 && READ_DATA_WIDTH2==18) begin

              fwft2 <= (EMPTY2 && WR_EN2 && !fwft2)? 1 : fwft2;
              
              if(b_wptr_next2==1 || b_wptr_next2==4097 ) begin
                async_fwft_data2 [7:0] <= WR_DATA2[7:0] ;
                async_fwft_data2 [8] <= WR_DATA2[8] ;
              end
              if(b_wptr_next2==2 || b_wptr_next2==4098 ) begin
                async_fwft_data2 [16:9] <= WR_DATA2[7:0];
                async_fwft_data2 [17] <= WR_DATA2[8];
              end     
        end


  end

  always @ (posedge RD_CLK2) begin
        if(RD_EN2) begin
            fwft2 =0;
        end
  end


/*---------------------------------------------------------------*/

/*--------- Adding logic of OVERFLOW and UNDERFLOW -----------*/

    always @(posedge WR_CLK2) begin
      if (RESET2) begin
       OVERFLOW2 <= 0;
      end
      else if (FULL2 & WR_EN2 ) begin
       OVERFLOW2 <= 1;
      end

    end

    always @(posedge RD_CLK2) begin 
        if (RESET2) begin
          OVERFLOW2 <= 0;
        end
        else if(RD_EN2 & OVERFLOW2) begin
          OVERFLOW2 <= 0;
        end
    end

    always @(posedge RD_CLK2) begin

      if (RESET2) begin
        UNDERFLOW2 <= 0;
      end
      else if (EMPTY2 & RD_EN2) begin
         UNDERFLOW2 <= 1;
      end
    end

    always @(posedge WR_CLK2) begin
      if (RESET2) begin
       UNDERFLOW2 <= 0;
      end
      else if (EMPTY2 & WR_EN2 ) begin
       UNDERFLOW2 <= 0;
      end

    end



always @(*) begin    
    if (OVERFLOW2) begin
        @(posedge WR_CLK2) begin
        $fatal(1,"\n Error: OVERFLOW2 Happend, RESET2 THE FIFO FIRST \n", OVERFLOW2 );             
        end 
     end
end

always @(*) begin    
    if (UNDERFLOW2) begin
        @(posedge RD_CLK2) begin
        $fatal(1,"\n Error: UNDERFLOW2 Happend, RESET2 THE FIFO FIRST \n", UNDERFLOW2 );             
        end 
     end
end



    end
 initial begin
    case(DATA_WRITE_WIDTH1)
      9 ,
      18: begin end
      default: begin
        $fatal(1,"\nError: FIFO18KX2 instance %m has parameter DATA_WRITE_WIDTH1 set to %d.  Valid values are 9, 18\n", DATA_WRITE_WIDTH1);
      end
    endcase
    case(DATA_READ_WIDTH1)
      9 ,
      18: begin end
      default: begin
        $fatal(1,"\nError: FIFO18KX2 instance %m has parameter DATA_READ_WIDTH1 set to %d.  Valid values are 9, 18\n", DATA_READ_WIDTH1);
      end
    endcase
    case(FIFO_TYPE1)
      "SYNCHRONOUS" ,
      "ASYNCHRONOUS": begin end
      default: begin
        $fatal(1,"\nError: FIFO18KX2 instance %m has parameter FIFO_TYPE1 set to %s.  Valid values are SYNCHRONOUS, ASYNCHRONOUS\n", FIFO_TYPE1);
      end
    endcase
    case(DATA_WRITE_WIDTH2)
      9 ,
      18: begin end
      default: begin
        $fatal(1,"\nError: FIFO18KX2 instance %m has parameter DATA_WRITE_WIDTH2 set to %d.  Valid values are 9, 18\n", DATA_WRITE_WIDTH2);
      end
    endcase
    case(DATA_READ_WIDTH2)
      9 ,
      18: begin end
      default: begin
        $fatal(1,"\nError: FIFO18KX2 instance %m has parameter DATA_READ_WIDTH2 set to %d.  Valid values are 9, 18\n", DATA_READ_WIDTH2);
      end
    endcase
    case(FIFO_TYPE2)
      "SYNCHRONOUS" ,
      "ASYNCHRONOUS": begin end
      default: begin
        $fatal(1,"\nError: FIFO18KX2 instance %m has parameter FIFO_TYPE2 set to %s.  Valid values are SYNCHRONOUS, ASYNCHRONOUS\n", FIFO_TYPE2);
      end
    endcase

  end

endmodule
`endcelldefine
