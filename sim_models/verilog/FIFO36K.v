`timescale 1ns/1ps
`celldefine
//
// FIFO36K simulation model
// 36Kb FIFO
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//

module FIFO36K #(
  parameter DATA_WRITE_WIDTH = 36, // FIFO data write width (9, 18, 36)
  parameter DATA_READ_WIDTH = 36, // FIFO data read width (9, 18, 36)
  parameter FIFO_TYPE = "SYNCHRONOUS", // Synchronous or Asynchronous data transfer (SYNCHRONOUS/ASYNCHRONOUS)
  parameter [11:0] PROG_EMPTY_THRESH = 12'h004, // 12-bit Programmable empty depth
  parameter [11:0] PROG_FULL_THRESH = 12'hffa // 12-bit Programmable full depth
) (
  input RESET, // Active high synchronous FIFO reset
  input WR_CLK, // Write clock
  input RD_CLK, // Read clock
  input WR_EN, // Write enable
  input RD_EN, // Read enable
  input [DATA_WRITE_WIDTH-1:0] WR_DATA, // Write data
  output [DATA_READ_WIDTH-1:0] RD_DATA, // Read data
  output reg EMPTY = 1'b1, // FIFO empty flag
  output reg FULL = 1'b0, // FIFO full flag
  output reg ALMOST_EMPTY = 1'b0, // FIFO almost empty flag
  output reg ALMOST_FULL = 1'b0, // FIFO almost full flag
  output reg PROG_EMPTY = 1'b1, // FIFO programmable empty flag
  output reg PROG_FULL = 1'b0, // FIFO programmable full flag
  output reg OVERFLOW = 1'b0, // FIFO overflow error flag
  output reg UNDERFLOW = 1'b0 // FIFO underflow error flag
);



if ( FIFO_TYPE == "SYNCHRONOUS" )  begin: SYNCRONOUS

  
  localparam DATA_WIDTH = DATA_WRITE_WIDTH;
  localparam  fifo_depth = (DATA_WIDTH <= 9) ? 4096 :
                           (DATA_WIDTH <= 18) ? 2048 :
                           1024;
  
  localparam  fifo_addr_width = (DATA_WIDTH <= 9) ? 12 :
                                (DATA_WIDTH <= 18) ? 11 :
                                10;

  reg [fifo_addr_width-1:0] fifo_wr_addr = {fifo_addr_width{1'b0}};
  reg [fifo_addr_width-1:0] fifo_rd_addr = {fifo_addr_width{1'b0}};

  wire [31:0] ram_wr_data;
  wire [3:0] ram_wr_parity;

  reg fwft = 1'b0;
  reg fall_through;
  reg wr_data_fwft;
  reg [DATA_WIDTH-1:0] fwft_data = {DATA_WIDTH{1'b0}};

  wire [31:0] ram_rd_data; 
  wire [3:0]  ram_rd_parity;
  wire ram_clk_b;
  
  integer number_entries = 0;
  reg underrun_status = 0;
  reg overrun_status = 0;

  TDP_RAM36K #(
    .INIT({32768{1'b0}}), // Initial Contents of memory
    .INIT_PARITY({2048{1'b0}}), // Initial Contents of memory
    .WRITE_WIDTH_A(DATA_WIDTH), // Write data width on port A (1-36)
    .READ_WIDTH_A(DATA_WIDTH), // Read data width on port A (1-36)
    .WRITE_WIDTH_B(DATA_WIDTH), // Write data width on port B (1-36)
    .READ_WIDTH_B(DATA_WIDTH) // Read data width on port B (1-36)
  ) FIFO_RAM_inst (
    .WEN_A(WR_EN), // Write-enable port A
    .WEN_B(1'b0), // Write-enable port B
    .REN_A(1'b0), // Read-enable port A
    .REN_B(RD_EN), // Read-enable port B
    .CLK_A(WR_CLK), // Clock port A
    .CLK_B(ram_clk_b), // Clock port B
    .BE_A(4'hf), // Byte-write enable port A
    .BE_B(4'h0), // Byte-write enable port B
    .ADDR_A({fifo_wr_addr, {15-fifo_addr_width{1'b0}}}), // Address port A, align MSBs and connect unused MSBs to logic 0
    .ADDR_B({fifo_rd_addr, {15-fifo_addr_width{1'b0}}}), // Address port B, align MSBs and connect unused MSBs to logic 0
    .WDATA_A(ram_wr_data), // Write data port A
    .WPARITY_A(ram_wr_parity), // Write parity data port A
    .WDATA_B(32'h00000000), // Write data port B
    .WPARITY_B(4'h0), // Write parity port B
    .RDATA_A(), // Read data port A
    .RPARITY_A(), // Read parity port A
    .RDATA_B(ram_rd_data), // Read data port B
    .RPARITY_B(ram_rd_parity) // Read parity port B
  ); 

  // always @(*) begin
     if ((DATA_WIDTH == 9)|| (DATA_WIDTH == 17) || (DATA_WIDTH == 25)) begin: one_parity
      assign ram_wr_data = {{32-DATA_WIDTH{1'b0}}, WR_DATA};
      assign ram_wr_parity = {3'b000, WR_DATA[DATA_WIDTH-1]};
      assign RD_DATA = fwft ? fwft_data : {ram_rd_parity[0], ram_rd_data[DATA_WIDTH-2:0]};
    end else if (DATA_WIDTH == 33) begin: width_33
      assign ram_wr_data = WR_DATA[31:0];
      assign ram_wr_parity = {3'b000, WR_DATA[32]};
      assign RD_DATA = fwft ? fwft_data : {ram_rd_parity[0], ram_rd_data[31:0]};
    end else if ((DATA_WIDTH == 18) || (DATA_WIDTH == 26)) begin: two_parity
      assign ram_wr_data = {{32-DATA_WIDTH{1'b0}}, WR_DATA};
      assign ram_wr_parity = {2'b00, WR_DATA[DATA_WIDTH-1:DATA_WIDTH-2]};
      assign RD_DATA = fwft ? fwft_data : {ram_rd_parity[1:0], ram_rd_data[DATA_WIDTH-3:0]};
    end else if (DATA_WIDTH == 34) begin: width_34
      assign ram_wr_data = WR_DATA[31:0];
      assign ram_wr_parity = {2'b00, WR_DATA[33:32]};
      assign RD_DATA = fwft ? fwft_data : {ram_rd_parity[1:0], ram_rd_data[31:0]};
    end else if (DATA_WIDTH == 27) begin: width_27
      assign ram_wr_data = {8'h00, WR_DATA[23:0]};
      assign ram_wr_parity = {1'b0, WR_DATA[26:24]};
      assign RD_DATA = fwft ? fwft_data : {ram_rd_parity[2:0], ram_rd_data[23:0]};
    end else if (DATA_WIDTH == 35) begin: width_35
      assign ram_wr_data = WR_DATA[31:0];
      assign ram_wr_parity = {1'b0, WR_DATA[34:32]};
      assign RD_DATA = fwft ? fwft_data : {ram_rd_parity[2:0], ram_rd_data[31:0]};
    end else if (DATA_WIDTH == 36) begin: width_36
      assign ram_wr_data = WR_DATA[31:0];
      assign ram_wr_parity = WR_DATA[35:32];
      assign RD_DATA = fwft ? fwft_data : {ram_rd_parity[3:0], ram_rd_data[31:0]};
    end else begin: no_parity
      assign ram_wr_data = fall_through ? wr_data_fwft : {{32-DATA_WIDTH{1'b0}}, WR_DATA};
      assign ram_wr_parity = 4'h0;
      assign RD_DATA = fwft ? fwft_data : ram_rd_data[DATA_WIDTH-1:0]; 
 end
  // end
  
      always @(posedge WR_CLK)
        if (WR_EN && !RD_EN) begin
          number_entries <= number_entries + 1;
          underrun_status = 0;
          if (number_entries >= fifo_depth)
            overrun_status  = 1;
        end
        else if (!WR_EN && RD_EN && number_entries == 0) begin
          number_entries <= 0;
          underrun_status = 1;
        end
        else if (!WR_EN && RD_EN) begin
          number_entries <= number_entries - 1;
          underrun_status = 0;
        end

      always @(posedge RESET, posedge WR_CLK)
        if (RESET) begin
          fifo_wr_addr <= {fifo_addr_width{1'b0}};
          fifo_rd_addr <= {fifo_addr_width{1'b0}};
          EMPTY        <= 1'b1;
          FULL         <= 1'b0;
          ALMOST_EMPTY <= 1'b0;
          ALMOST_FULL  <= 1'b0;
          PROG_EMPTY   <= 1'b1;
          PROG_FULL    <= 1'b0;
          OVERFLOW     <= 1'b0;
          UNDERFLOW    <= 1'b0;
          number_entries = 0;
          fwft         <= 1'b0;
          fwft_data    <= {DATA_WIDTH-1{1'b0}};
          underrun_status <=1'b0;
          overrun_status  <= 1'b0;
        end else begin
          if (WR_EN)
            fifo_wr_addr <= fifo_wr_addr + 1'b1;
          EMPTY        <= ((number_entries==0) && (underrun_status==0) || ((RD_EN && !WR_EN) && (number_entries==1)));
          FULL         <= ((number_entries==fifo_depth) || ((number_entries==(fifo_depth-1)) && WR_EN && !RD_EN));
          ALMOST_EMPTY <= (((number_entries==1) && !(RD_EN && !WR_EN)) ||  ((RD_EN && !WR_EN) && (number_entries==2)));
          ALMOST_FULL  <= (((number_entries==(fifo_depth-1)) && !(!RD_EN && WR_EN)) ||  ((!RD_EN && WR_EN) && (number_entries==fifo_depth-2)));
          PROG_EMPTY   <= ((number_entries) < (PROG_EMPTY_THRESH)) || ((RD_EN && !WR_EN) && ((number_entries) <= PROG_EMPTY_THRESH) );
          PROG_FULL    <= ((fifo_depth-number_entries) < (PROG_FULL_THRESH)) || ((!RD_EN && WR_EN) && ((fifo_depth-number_entries) <= PROG_FULL_THRESH) );
          UNDERFLOW    <= (EMPTY && RD_EN) || (underrun_status==1);
          OVERFLOW     <= (FULL && WR_EN) || (overrun_status==1);
          if (EMPTY && WR_EN && !fwft) begin
            fwft_data <= WR_DATA;
            fifo_rd_addr <= fifo_rd_addr + 1'b1;
            fwft <= 1'b1;
          end else if (RD_EN) begin
            fwft <= 1'b0;
            if (!(ALMOST_EMPTY && !WR_EN))
              fifo_rd_addr <= fifo_rd_addr + 1'b1;
          end
        end

        assign ram_clk_b = WR_CLK;

        initial begin
          #1;
          @(RD_CLK);
          $display("\nWarning: FIFO36K instance %m RD_CLK should be tied to ground when FIFO36K is configured as FIFO_TYPE=SYNCHRONOUS.");
        end

    end : SYNCRONOUS  // SYNCRONOUS LOGIC 


else begin: ASYNCRONOUS                // ASYNCRONOUS LOGIC 

reg fwft = 1'b0;


localparam DATA_WIDTH_WRITE = DATA_WRITE_WIDTH;
localparam DATA_WIDTH_READ = DATA_READ_WIDTH;

  localparam  fifo_depth_write = (DATA_WIDTH_WRITE <= 9) ? 4096 :
                                 (DATA_WIDTH_WRITE <= 18) ? 2048 :
                                 1024;

  localparam  fifo_depth_read = (DATA_WIDTH_READ <= 9) ? 4096 :
                                 (DATA_WIDTH_READ <= 18) ? 2048 :
                                 1024;
  
  localparam  fifo_addr_width_r = (DATA_WIDTH_READ <= 9) ? 12 :
                                  (DATA_WIDTH_READ <= 18) ? 11 :
                                  10;
  localparam  fifo_addr_width_w = (DATA_WIDTH_WRITE <= 9) ? 12 :
                                  (DATA_WIDTH_WRITE <= 18) ? 11 :
                                  10;

  reg [fifo_addr_width_w-1:0] fifo_wr_addr = {fifo_addr_width_w{1'b0}};
  reg [fifo_addr_width_r-1:0] fifo_rd_addr = {fifo_addr_width_r{1'b0}};

  reg [DATA_WIDTH_READ-1:0] fwft_data = {DATA_WIDTH_READ{1'b0}};

  wire [31:0] ram_wr_data;
  wire [3:0] ram_wr_parity;

  wire [31:0] ram_rd_data; 
  wire [3:0]  ram_rd_parity;

assign ram_clk_b = RD_CLK;

parameter W_PTR_WIDTH = $clog2(fifo_depth_write);
parameter R_PTR_WIDTH = $clog2(fifo_depth_read);

wire [W_PTR_WIDTH:0] b_wptr_sync, b_wptr_w, b_wptr_sync_for_a;
wire [R_PTR_WIDTH:0] b_rptr_sync, b_rptr_w, b_rptr_w1, b_rptr_sync_for_a;


  TDP_RAM36K #(
    .INIT({32768{1'b0}}), // Initial Contents of memory
    .INIT_PARITY({2048{1'b0}}), // Initial Contents of memory
    .WRITE_WIDTH_A(DATA_WIDTH_WRITE), // Write data width on port A (1-36)
    .READ_WIDTH_A(DATA_WIDTH_READ), // Read data width on port A (1-36)
    .WRITE_WIDTH_B(DATA_WIDTH_WRITE), // Write data width on port B (1-36)
    .READ_WIDTH_B(DATA_WIDTH_READ) // Read data width on port B (1-36)
  ) FIFO_RAM_inst (
    .WEN_A(WR_EN ), // Write-enable port A
    .WEN_B(1'b0), // Write-enable port B
    .REN_A(1'b0), // Read-enable port A
    .REN_B(RD_EN ), // Read-enable port B
    .CLK_A(WR_CLK), // Clock port A
    .CLK_B(ram_clk_b), // Clock port B 
    .BE_A(4'hf), // Byte-write enable port A
    .BE_B(4'h0), // Byte-write enable port B
    // .ADDR_A({fifo_wr_addr, {15-fifo_addr_width{1'b0}}}), // Address port A, align MSBs and connect unused MSBs to logic 0
    .ADDR_A({b_wptr_w,{15-fifo_addr_width_w{1'b0}}}), // Address port A, align MSBs and connect unused MSBs to logic 0
    // .ADDR_B({fifo_rd_addr, {15-fifo_addr_width{1'b0}}}), // Address port B, align MSBs and connect unused MSBs to logic 0
    .ADDR_B({b_rptr_w1,{15-fifo_addr_width_r{1'b0}}}), // Address port B, align MSBs and connect unused MSBs to logic 0
    .WDATA_A(ram_wr_data), // Write data port A
    .WPARITY_A(ram_wr_parity), // Write parity data port A
    .WDATA_B(32'h00000000), // Write data port B
    .WPARITY_B(4'h0), // Write parity port B
    .RDATA_A(), // Read data port A
    .RPARITY_A(), // Read parity port A
    .RDATA_B(ram_rd_data), // Read data port B
    .RPARITY_B(ram_rd_parity) // Read parity port B
  );

/*-------------------------------------------------------------------*/

// generate

    if(DATA_WIDTH_READ==9) begin
      assign RD_DATA = (fwft ? fwft_data : {ram_rd_parity[0], ram_rd_data[7:0]});    
    end

    if(DATA_WIDTH_READ==18) begin
      assign RD_DATA = fwft ? fwft_data : {ram_rd_parity[1], ram_rd_data[15:8], ram_rd_parity[0], ram_rd_data[7:0]};    
    end

    if(DATA_WIDTH_READ==36) begin
      assign RD_DATA = fwft ? fwft_data : {ram_rd_parity[3], ram_rd_data[31:24], ram_rd_parity[2], ram_rd_data[23:16], ram_rd_parity[1], ram_rd_data[15:8], ram_rd_parity[0], ram_rd_data[7:0]};    
    end

    if(DATA_WIDTH_WRITE==9) begin       
      assign ram_wr_data = {{32-DATA_WIDTH_WRITE{1'b0}}, WR_DATA[DATA_WIDTH_WRITE-2:0]};
      assign ram_wr_parity = {3'b000, WR_DATA[DATA_WIDTH_WRITE-1]};
    end
    
    if(DATA_WIDTH_WRITE==18) begin 
      assign ram_wr_data = {{32-DATA_WIDTH_WRITE{1'b0}}, WR_DATA[16:9],WR_DATA[7:0]};
      assign ram_wr_parity = {2'b00, WR_DATA[17], WR_DATA[8]};
    end
    
    if(DATA_WIDTH_WRITE==36) begin
      assign ram_wr_data = {WR_DATA[34:27], WR_DATA[25:18],WR_DATA[16:9],WR_DATA[7:0]};
      assign ram_wr_parity = {WR_DATA[35], WR_DATA[26], WR_DATA[17], WR_DATA[8]};
    end


// endgenerate
  
/*---------Write pointer synchronizer ( 2 FLOPS) logic--------------*/


  reg [W_PTR_WIDTH:0] q1,q1_a,d_out1;

  assign b_wptr_sync = d_out1;
  assign b_wptr_sync_for_a = q1_a;

  always@(posedge RD_CLK) begin
    if(RESET) begin
      q1 <= 0;
      d_out1 <= 0;
      q1_a <=0;
    end
    else begin
      q1 <= b_wptr_w;
      d_out1 <= q1;
      q1_a <= d_out1;
    end
  end

/*-------------------------------------------------------------------*/

/*--------- Read pointer synchronizer (2 FLOPS ) logic --------------*/

reg [R_PTR_WIDTH:0] q2, q2_a, d_out2;

assign b_rptr_sync = d_out2;
assign b_rptr_sync_for_a = q2_a;

  always@(posedge WR_CLK) begin
    if(RESET) begin
      q2 <= 0;
      d_out2 <= 0;
      q2_a <=0;
    end
    else begin

      q2 <= b_rptr_w;
      d_out2 <= q2;
      q2_a <= d_out2;
    end
  end

/*-------------------------------------------------------------------*/

/* ---------------- Write pointer handler logic ---------------------*/

  localparam SCALING_FACTOR_WPTR= (DATA_WIDTH_READ>DATA_WIDTH_WRITE)? (DATA_WIDTH_READ/DATA_WIDTH_WRITE):1;


  wire [W_PTR_WIDTH:0] b_wptr_next;

  reg [W_PTR_WIDTH:0] b_wptr;

  wire wfull, al_full, p_full; 

  wire [W_PTR_WIDTH:0] diff_ptr0, diff_ptr2, diff_ptr0_for_a;

  assign b_wptr_next = b_wptr+(WR_EN & !FULL);

  assign b_wptr_w = b_wptr;


  assign diff_ptr0 =(DATA_WIDTH_WRITE>DATA_WIDTH_READ)? /* W>R */ ((((b_wptr_next/SCALING_FACTOR_WPTR  >= (b_rptr_sync/SCALING_FACTOR_RPTR))? (b_wptr_next/SCALING_FACTOR_WPTR-(b_rptr_sync/SCALING_FACTOR_RPTR)): (b_wptr_next/SCALING_FACTOR_WPTR+(1<<(W_PTR_WIDTH+1))-(b_rptr_sync/SCALING_FACTOR_RPTR)))))

  : (  (DATA_WIDTH_READ>DATA_WIDTH_WRITE)? ( /* R>W */ ((((b_wptr_next*SCALING_FACTOR_RPTR  >= (b_rptr_sync*SCALING_FACTOR_WPTR))? (b_wptr_next*SCALING_FACTOR_RPTR-(b_rptr_sync*SCALING_FACTOR_WPTR)): (b_wptr_next*SCALING_FACTOR_RPTR+(1<<(W_PTR_WIDTH+1))-(b_rptr_sync*SCALING_FACTOR_WPTR))))) ) 

  : /* R==W */ ((((b_wptr_next  >= (b_rptr_sync ))? (b_wptr_next - (b_rptr_sync)): (b_wptr_next + (1<<(W_PTR_WIDTH+1))-(b_rptr_sync ))))) );  


  assign diff_ptr0_for_a =(DATA_WIDTH_WRITE>DATA_WIDTH_READ)? /* W>R */ ((((b_wptr_next/SCALING_FACTOR_WPTR  >= (b_rptr_sync_for_a/SCALING_FACTOR_RPTR))? (b_wptr_next/SCALING_FACTOR_WPTR-(b_rptr_sync_for_a/SCALING_FACTOR_RPTR)): (b_wptr_next/SCALING_FACTOR_WPTR+(1<<(W_PTR_WIDTH+1))-(b_rptr_sync_for_a/SCALING_FACTOR_RPTR)))))

  : (  (DATA_WIDTH_READ>DATA_WIDTH_WRITE)? ( /* R>W */ ((((b_wptr_next*SCALING_FACTOR_RPTR  >= (b_rptr_sync_for_a*SCALING_FACTOR_WPTR))? (b_wptr_next*SCALING_FACTOR_RPTR-(b_rptr_sync_for_a*SCALING_FACTOR_WPTR)): (b_wptr_next*SCALING_FACTOR_RPTR+(1<<(W_PTR_WIDTH+1))-(b_rptr_sync_for_a*SCALING_FACTOR_WPTR))))) ) 

  : /* R==W */ ((((b_wptr_next  >= (b_rptr_sync_for_a ))? (b_wptr_next - (b_rptr_sync_for_a)): (b_wptr_next + (1<<(W_PTR_WIDTH+1))-(b_rptr_sync_for_a ))))) );  


  // assign wfull = (DATA_WIDTH_WRITE>DATA_WIDTH_READ)? (diff_ptr0 == (1<<W_PTR_WIDTH)) : (diff_ptr0 == (1<<R_PTR_WIDTH) );

  assign wfull = (DATA_WIDTH_WRITE>DATA_WIDTH_READ)? (diff_ptr0 == (1<<W_PTR_WIDTH)) : (diff_ptr0 == (1<<W_PTR_WIDTH)   );


  assign al_full = (DATA_WIDTH_WRITE>DATA_WIDTH_READ)? (diff_ptr0 == (1<<W_PTR_WIDTH)-1): (diff_ptr0 == ((1<<W_PTR_WIDTH)-1) );

  assign p_full = (DATA_WIDTH_WRITE>DATA_WIDTH_READ)? (diff_ptr0_for_a >= ((1<<W_PTR_WIDTH)-PROG_FULL_THRESH+1) ) :  ( (diff_ptr0_for_a >= ((1<<W_PTR_WIDTH)-PROG_FULL_THRESH+1) ) );


  // assign diff_ptr2 = ((((b_wptr_next*SCALING_FACTOR_WPTR-(b_rptr_sync/SCALING_FACTOR_RPTR)): (b_wptr_next/SCALING_FACTOR_WPTR+(1<<(W_PTR_WIDTH+1))-(b_rptr_sync/SCALING_FACTOR_RPTR)))))



  always@(posedge WR_CLK or posedge RESET) begin
    if(RESET) begin
      b_wptr <= 0; // set default value
    end
    else begin
      b_wptr <= b_wptr_next; // incr binary write pointer
    end
  end
  
  always@(posedge WR_CLK or posedge RESET) begin

    if(RESET) begin
      FULL <= 0;
      ALMOST_FULL <= 'b0;
      PROG_FULL <= 0;
    end

    else begin

      FULL <= wfull;
      ALMOST_FULL <= al_full;
      PROG_FULL <= p_full;

    end
  end

/*---------------------------------------------------------------*/

/*-----------  READ pointer handler logic -----------------------*/

localparam SCALING_FACTOR_RPTR= (DATA_WIDTH_READ<DATA_WIDTH_WRITE)? (DATA_WIDTH_WRITE/DATA_WIDTH_READ):1;

wire [R_PTR_WIDTH:0] diff_ptr1, diff_ptr1_for_a;
reg [R_PTR_WIDTH:0] b_rptr_next, b_rptr;


always @(*) begin

    if(RESET) begin
      b_rptr_next =0;
      b_rptr <=0;
    end
    if((RD_EN & !EMPTY)) begin
      if (b_rptr_next==(1<<R_PTR_WIDTH+1)) begin  
         b_rptr_next <=0;
      end
      else begin
        b_rptr_next = b_rptr_next+1;      
      end
    end
end

assign b_rptr_w = b_rptr;

assign b_rptr_w1= b_rptr_next;

assign diff_ptr1 = (DATA_WIDTH_WRITE > DATA_WIDTH_READ)?   ( ((b_wptr_sync*SCALING_FACTOR_RPTR) >= (b_rptr_next*SCALING_FACTOR_WPTR))? (b_wptr_sync*SCALING_FACTOR_RPTR-(b_rptr_next*SCALING_FACTOR_WPTR)): ((b_wptr_sync*SCALING_FACTOR_RPTR)+(1<<(R_PTR_WIDTH+1))-(b_rptr_next*SCALING_FACTOR_RPTR)/SCALING_FACTOR_RPTR))
 
 : ( (DATA_WIDTH_READ > DATA_WIDTH_WRITE)?  (((b_wptr_sync/SCALING_FACTOR_WPTR) >= (b_rptr_next/SCALING_FACTOR_RPTR))? (b_wptr_sync/SCALING_FACTOR_WPTR-(b_rptr_next/SCALING_FACTOR_RPTR)): (b_wptr_sync/SCALING_FACTOR_WPTR+(1<<(R_PTR_WIDTH+1))-(b_rptr_next/SCALING_FACTOR_RPTR)))  
 
 : (((b_wptr_sync) >= (b_rptr_next))? (b_wptr_sync-(b_rptr_next)): (b_wptr_sync+(1<<(W_PTR_WIDTH+1))-(b_rptr_next))) )   ;

assign diff_ptr1_for_a = (DATA_WIDTH_WRITE > DATA_WIDTH_READ)?   ( ((b_wptr_sync_for_a*SCALING_FACTOR_RPTR) >= (b_rptr_next*SCALING_FACTOR_WPTR))? (b_wptr_sync_for_a*SCALING_FACTOR_RPTR-(b_rptr_next*SCALING_FACTOR_WPTR)): ((b_wptr_sync_for_a*SCALING_FACTOR_RPTR)+(1<<(R_PTR_WIDTH+1))-(b_rptr_next*SCALING_FACTOR_RPTR)/SCALING_FACTOR_RPTR))
 
 : ( (DATA_WIDTH_READ > DATA_WIDTH_WRITE)?  (((b_wptr_sync_for_a/SCALING_FACTOR_WPTR) >= (b_rptr_next/SCALING_FACTOR_RPTR))? (b_wptr_sync_for_a/SCALING_FACTOR_WPTR-(b_rptr_next/SCALING_FACTOR_RPTR)): (b_wptr_sync_for_a/SCALING_FACTOR_WPTR+(1<<(R_PTR_WIDTH+1))-(b_rptr_next/SCALING_FACTOR_RPTR)))  
 
 : (((b_wptr_sync_for_a) >= (b_rptr_next))? (b_wptr_sync_for_a-(b_rptr_next)): (b_wptr_sync_for_a+(1<<(W_PTR_WIDTH+1))-(b_rptr_next))) )   ;


assign rempty= (diff_ptr1==0)?1:0;

assign al_empty = (diff_ptr1 ==1)? 1:0;

assign p_empty = (diff_ptr1_for_a ==PROG_EMPTY_THRESH-1 || diff_ptr1_for_a <=PROG_EMPTY_THRESH-1 )? 1:0;


  always@(posedge RD_CLK or posedge RESET) begin

    if(RESET) begin
      b_rptr <= 0;
    end
    else begin
      b_rptr <= b_rptr_next;
    end

  end
  
  always@(posedge RD_CLK or posedge RESET) begin

    if(RESET) begin 
      EMPTY <= 1;
      ALMOST_EMPTY <= 0;
      PROG_EMPTY <=1;
    end
    else begin

        
      EMPTY <= rempty;
      
      if(DATA_WIDTH_READ==9) begin
        if(b_rptr==4095 & WR_EN==0) begin
          ALMOST_EMPTY <=0;
        end
        else begin
          ALMOST_EMPTY <= al_empty;
        end
      end
      else begin
        ALMOST_EMPTY <= al_empty;      
      end

      PROG_EMPTY <= p_empty;    
      
    end 
  end


/*------------------------------------------------------------------*/

/*------------- Adding logic of First word fall through ------------*/

    always@(posedge WR_CLK) begin
// -1
        if (DATA_WIDTH_WRITE >= DATA_WIDTH_READ) begin
              fwft <= (EMPTY && WR_EN && !fwft)? 1 : fwft;
            if (EMPTY && WR_EN && !fwft) begin
              if (DATA_WIDTH_WRITE==DATA_WIDTH_READ) begin
                fwft_data <= WR_DATA;
              end
              else if (DATA_WIDTH_WRITE==36 && DATA_WIDTH_READ==9) begin
                fwft_data <= {{WR_DATA[8]},{WR_DATA[7:0]}} ;  // DEVELOP LOGIC FOR OTHER WIDTH AS WELL
              end
              else if (DATA_WIDTH_WRITE==36 && DATA_WIDTH_READ==18) begin
                fwft_data <= {{WR_DATA[17]},{WR_DATA[16:9]}, {WR_DATA[8]}, {WR_DATA[7:0]}} ;  // DEVELOP LOGIC FOR OTHER WIDTH AS WELL
              end
              else if (DATA_WIDTH_WRITE==18 && DATA_WIDTH_READ==9) begin
                fwft_data <= {{WR_DATA[8]},{WR_DATA[7:0]}} ;  // DEVELOP LOGIC FOR OTHER WIDTH AS WELL
              end

            end
        end
// -2          
        if (DATA_WIDTH_WRITE == 9 && DATA_WIDTH_READ==18) begin

              // if(b_wptr_next==2 || b_wptr_next==4098 || b_wptr_next==2049) begin
              // fwft=1;
              // end   
              // else begin
              // fwft=fwft;
              // end  

              fwft <= (EMPTY && WR_EN && !fwft)? 1 : fwft;

              if(b_wptr_next==1 || b_wptr_next==4097 ) begin
                fwft_data [7:0] <= WR_DATA[7:0] ;
                fwft_data [8] <= WR_DATA[8] ;
              end
              if(b_wptr_next==2 || b_wptr_next==4098 ) begin
                fwft_data [16:9] <= WR_DATA[7:0];
                fwft_data [17] <= WR_DATA[8];
              end     
        end
// -3 
        if (DATA_WIDTH_WRITE == 9 && DATA_WIDTH_READ==36) begin

              // if(b_wptr_next==4 || b_wptr_next==8196 || b_wptr_next==4100) begin
              // fwft=1;
              // end   
              // else begin
              // fwft=fwft;
              // end  

              fwft <= (EMPTY && WR_EN && !fwft)? 1 : fwft;

              if(b_wptr_next==1 || b_wptr_next==4097) begin
                fwft_data [7:0] <= WR_DATA[7:0];
                fwft_data [8] <= WR_DATA[8];
              end
              if(b_wptr_next==2 || b_wptr_next==4098) begin
                fwft_data [16:9] <= WR_DATA[7:0];
                fwft_data [17] <= WR_DATA[8];
              end     
              if(b_wptr_next==3 || b_wptr_next==4099) begin
                fwft_data [25:18] <= WR_DATA[7:0] ;
                fwft_data [26] <= WR_DATA[8];
              end
              if(b_wptr_next==4 || b_wptr_next==4100) begin
                fwft_data [34:27] <= WR_DATA[7:0] ;
                fwft_data [35] <= WR_DATA[8];
              end   

        end
// -4 
        if (DATA_WIDTH_WRITE == 18 && DATA_WIDTH_READ==36) begin

              // if(b_wptr_next==2 || b_wptr_next==4098 || b_wptr_next==2049) begin
              // fwft=1;
              // end   
              // else begin
              // fwft=fwft;
              // end  
              
              fwft <= (EMPTY && WR_EN && !fwft)? 1 : fwft;

              if(b_wptr_next==1 || b_wptr_next==4097  ) begin
                // fwft_data [7:0] <= WR_DATA[7:0];
                // fwft_data [16:9] <= WR_DATA[16:9];
                // fwft_data [8] <= WR_DATA[8];
                // fwft_data [17] <= WR_DATA[17];
                fwft_data[17:0] <= WR_DATA;

              end
              if(b_wptr_next==2 || b_wptr_next==4098 ) begin
                // fwft_data [25:18] <= WR_DATA[7:0];
                // fwft_data [34:27] <= WR_DATA[16:9];
                // fwft_data [26] <= WR_DATA[8];
                // fwft_data [35] <= WR_DATA[17];
                fwft_data[35:18] <= WR_DATA;
              end       
        end


  end

  always @ (posedge RD_CLK) begin
        if(RD_EN) begin
            fwft =0;
        end
  end


/*---------------------------------------------------------------*/

/*--------- Adding logic of OVERFLOW and UNDERFLOW -----------*/

    always @(posedge WR_CLK) begin
      if (RESET) begin
       OVERFLOW <= 0;
      end
      else if (FULL & WR_EN ) begin
       OVERFLOW <= 1;
      end
    end

    always @(posedge RD_CLK) begin 
        if (RESET) begin
          OVERFLOW <= 0;
        end
        else if(RD_EN & OVERFLOW) begin
          OVERFLOW <= 0;
        end
    end

    always @(posedge RD_CLK) begin

      if (RESET) begin
        UNDERFLOW <= 0;
      end
      else if (EMPTY & RD_EN) begin
         UNDERFLOW <= 1;
      end
    end

    always @(posedge WR_CLK) begin
      if (RESET) begin
       UNDERFLOW <= 0;
      end
      else if (EMPTY & WR_EN ) begin
       UNDERFLOW <= 0;
      end
    end


always @(*) begin    
    if (OVERFLOW) begin
        @(posedge WR_CLK) begin
        $fatal(1,"\n Error: OVERFLOW Happend, RESET THE FIFO FIRST \n", OVERFLOW );             
        end 
     end
end

always @(*) begin    
    if (UNDERFLOW) begin
        @(posedge RD_CLK) begin
        $fatal(1,"\n Error: UNDERFLOW Happend, RESET THE FIFO FIRST \n", UNDERFLOW );             
        end 
     end
end

end : ASYNCRONOUS 
 initial begin
    case(DATA_WRITE_WIDTH)
      9 ,
      18 ,
      36: begin end
      default: begin
        $fatal(1,"\nError: FIFO36K instance %m has parameter DATA_WRITE_WIDTH set to %d.  Valid values are 9, 18, 36\n", DATA_WRITE_WIDTH);
      end
    endcase
    case(DATA_READ_WIDTH)
      9 ,
      18 ,
      36: begin end
      default: begin
        $fatal(1,"\nError: FIFO36K instance %m has parameter DATA_READ_WIDTH set to %d.  Valid values are 9, 18, 36\n", DATA_READ_WIDTH);
      end
    endcase
    case(FIFO_TYPE)
      "SYNCHRONOUS" ,
      "ASYNCHRONOUS": begin end
      default: begin
        $fatal(1,"\nError: FIFO36K instance %m has parameter FIFO_TYPE set to %s.  Valid values are SYNCHRONOUS, ASYNCHRONOUS\n", FIFO_TYPE);
      end
    endcase

  end

endmodule
`endcelldefine
