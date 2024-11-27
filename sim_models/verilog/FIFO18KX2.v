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


generate
  
if ( FIFO_TYPE1 == "SYNCHRONOUS" )  begin: SYNC1

  // FOR ASYNC FIFO1
    localparam WRITE_DATA_WIDTH1= DATA_WRITE_WIDTH1;
    localparam READ_DATA_WIDTH1= DATA_READ_WIDTH1;

    localparam  fifo_depth_write1 = (WRITE_DATA_WIDTH1 <= 9) ? 2048 : 1024;
    localparam  fifo_depth_read1 = (READ_DATA_WIDTH1 <= 9) ? 2048 :  1024;

    localparam  fifo_addr_width_write1 = (WRITE_DATA_WIDTH1 <= 9) ? 11 :  10;
    localparam  fifo_addr_width_read1 = (READ_DATA_WIDTH1 <= 9) ? 11 :  10;

  reg [fifo_addr_width_write1:0] fifo_wr_sync1 = {fifo_addr_width_write1{1'b0}};
  reg [fifo_addr_width_write1:0] fifo_wr_sync11 = {fifo_addr_width_write1{1'b0}};
  reg [fifo_addr_width_read1:0] fifo_rd_sync1 = {fifo_addr_width_read1{1'b0}};
  reg [fifo_addr_width_read1:0] fifo_rd_sync11 = {fifo_addr_width_read1{1'b0}};

    reg [fifo_addr_width_write1-1:0] async_fifo_wr_addr1 = {fifo_addr_width_write1{1'b0}};
    reg [fifo_addr_width_read1-1:0] async_fifo_rd_addr1 = {fifo_addr_width_read1{1'b0}};


    wire [15:0] ram_wr_data1;
    wire [1:0] ram_wr_parity1;

  // common
    reg fwft1 = 1'b0;  
    reg fall_through1;
    reg wr_data_fwft1;
    reg [DATA_READ_WIDTH1-1:0] fwft_data1 = {DATA_READ_WIDTH1{1'b0}}; 


    wire [15:0] ram_rd_data1; 
    wire [1:0]  ram_rd_parity1;
    wire ram_clk_b1;


  localparam W_PTR_WIDTH1 = $clog2(fifo_depth_write1);
  localparam R_PTR_WIDTH1 = $clog2(fifo_depth_read1);


  wire [W_PTR_WIDTH1:0] b_wptr_sync1, b_wptr_w1, b_wptr_sync1_for_a;
  wire [R_PTR_WIDTH1:0] b_rptr_sync1, b_rptr_w1, b_rptr_w11, b_rptr_sync1_for_a;


    if(DATA_READ_WIDTH1==9) begin
      assign RD_DATA1 = (fwft1 ? fwft_data1 : {ram_rd_parity1[0], ram_rd_data1[7:0]});    
    end

    if(DATA_READ_WIDTH1==18) begin
      assign RD_DATA1 = fwft1 ? fwft_data1 : {ram_rd_parity1[1], ram_rd_data1[15:8], ram_rd_parity1[0], ram_rd_data1[7:0]};    
    end

    if(DATA_WRITE_WIDTH1==9) begin       
      assign ram_wr_data1 = {{32-DATA_WRITE_WIDTH1{1'b0}}, WR_DATA1[DATA_WRITE_WIDTH1-2:0]};
      assign ram_wr_parity1 = {3'b000, WR_DATA1[DATA_WRITE_WIDTH1-1]};
    end
    
    if(DATA_WRITE_WIDTH1==18) begin 
      assign ram_wr_data1 = {{32-DATA_WRITE_WIDTH1{1'b0}}, WR_DATA1[16:9],WR_DATA1[7:0]};
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
        .CLK_B1(ram_clk_b1), // Clock port B, RAM 1
        .BE_A1(2'b11), // Byte-write enable port A, RAM 1
        .BE_B1(2'b11), // Byte-write enable port B, RAM 1
        .ADDR_A1({fifo_wr_sync1, {14-fifo_addr_width_write1{1'b0}}}), // Address port A, RAM 1
        .ADDR_B1({(fifo_rd_sync1+1'b1), {14-fifo_addr_width_read1{1'b0}}}), // Address port B, RAM 1
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


  localparam SCALING_FACTOR_WPTR1= (READ_DATA_WIDTH1>WRITE_DATA_WIDTH1)? (READ_DATA_WIDTH1/WRITE_DATA_WIDTH1):1;
  localparam SCALING_FACTOR_RPTR= (READ_DATA_WIDTH1<WRITE_DATA_WIDTH1)? (WRITE_DATA_WIDTH1/READ_DATA_WIDTH1):1;
  
  wire [W_PTR_WIDTH1:0] b_wptr_next1;
  wire [R_PTR_WIDTH1:0] b_rptr_next1;

  wire [W_PTR_WIDTH1:0] diff_ptr01, diff_ptr0_P1;
  wire wfull1, al_full1, p_full1; 

  assign b_wptr_next1 = fifo_wr_sync1+(WR_EN1 & !FULL1);
  assign b_rptr_next1 = fifo_rd_sync1+(RD_EN1 & !EMPTY1);
  

 assign diff_ptr01 =(WRITE_DATA_WIDTH1>READ_DATA_WIDTH1)? /* W>R */ ((((b_wptr_next1/SCALING_FACTOR_WPTR1  >= (fifo_rd_sync1/SCALING_FACTOR_RPTR))? (b_wptr_next1/SCALING_FACTOR_WPTR1-(fifo_rd_sync1/SCALING_FACTOR_RPTR)): (b_wptr_next1/SCALING_FACTOR_WPTR1+(1<<(W_PTR_WIDTH1+1))-(fifo_rd_sync1/SCALING_FACTOR_RPTR)))))

  : (  (READ_DATA_WIDTH1>WRITE_DATA_WIDTH1)? ( /* R>W */ ((((b_wptr_next1*SCALING_FACTOR_RPTR  >= (fifo_rd_sync1*SCALING_FACTOR_WPTR1))? (b_wptr_next1*SCALING_FACTOR_RPTR-(fifo_rd_sync1*SCALING_FACTOR_WPTR1)): (b_wptr_next1*SCALING_FACTOR_RPTR+(1<<(W_PTR_WIDTH1+1))-(fifo_rd_sync1*SCALING_FACTOR_WPTR1))))) ) 

  : /* R==W */ ((((b_wptr_next1  >= (fifo_rd_sync1 ))? (b_wptr_next1 - (fifo_rd_sync1)): (b_wptr_next1 + (1<<(W_PTR_WIDTH1+1))-(fifo_rd_sync1 ))))) ); 


 assign diff_ptr0_P1 =(WRITE_DATA_WIDTH1>READ_DATA_WIDTH1)? /* W>R */ ((((b_wptr_next1/SCALING_FACTOR_WPTR1  >= (fifo_rd_sync11/SCALING_FACTOR_RPTR))? (b_wptr_next1/SCALING_FACTOR_WPTR1-(fifo_rd_sync11/SCALING_FACTOR_RPTR)): (b_wptr_next1/SCALING_FACTOR_WPTR1+(1<<(W_PTR_WIDTH1+1))-(fifo_rd_sync11/SCALING_FACTOR_RPTR)))))

  : (  (READ_DATA_WIDTH1>WRITE_DATA_WIDTH1)? ( /* R>W */ ((((b_wptr_next1*SCALING_FACTOR_RPTR  >= (fifo_rd_sync11*SCALING_FACTOR_WPTR1))? (b_wptr_next1*SCALING_FACTOR_RPTR-(fifo_rd_sync11*SCALING_FACTOR_WPTR1)): (b_wptr_next1*SCALING_FACTOR_RPTR+(1<<(W_PTR_WIDTH1+1))-(fifo_rd_sync11*SCALING_FACTOR_WPTR1))))) ) 

  : /* R==W */ ((((b_wptr_next1  >= (fifo_rd_sync11 ))? (b_wptr_next1 - (fifo_rd_sync11)): (b_wptr_next1 + (1<<(W_PTR_WIDTH1+1))-(fifo_rd_sync11 ))))) ); 


// assign diff_ptr01 = b_wptr_next1-(b_rptr_next1/SCALING_FACTOR_RPTR);

  assign wfull1 = (WRITE_DATA_WIDTH1>READ_DATA_WIDTH1)? (diff_ptr01 == (1<<W_PTR_WIDTH1)) : (diff_ptr01 == (1<<W_PTR_WIDTH1)   );


  assign al_full1 = (WRITE_DATA_WIDTH1>READ_DATA_WIDTH1)? (diff_ptr01 == (1<<W_PTR_WIDTH1)-1): (diff_ptr01 == ((1<<W_PTR_WIDTH1)-1) );

  assign p_full1 = (WRITE_DATA_WIDTH1>READ_DATA_WIDTH1)? (diff_ptr0_P1 >= ((1<<W_PTR_WIDTH1)-PROG_FULL_THRESH1+1) ) :  ( (diff_ptr0_P1 >= ((1<<W_PTR_WIDTH1)-PROG_FULL_THRESH1+1) ) );

wire [R_PTR_WIDTH1:0] diff_ptr11,diff_ptr1_P1;

// assign diff_ptr11 = fifo_wr_sync1*SCALING_FACTOR_RPTR - b_rptr_next1*SCALING_FACTOR_WPTR1;

assign diff_ptr11 = (WRITE_DATA_WIDTH1 > READ_DATA_WIDTH1)?   ( ((fifo_wr_sync1*SCALING_FACTOR_RPTR) >= (b_rptr_next1*SCALING_FACTOR_WPTR1))? (fifo_wr_sync1*SCALING_FACTOR_RPTR-(b_rptr_next1*SCALING_FACTOR_WPTR1)): ((fifo_wr_sync1*SCALING_FACTOR_RPTR)+(1<<(R_PTR_WIDTH1+1))-(b_rptr_next1*SCALING_FACTOR_RPTR)/SCALING_FACTOR_RPTR))
 
 : ( (READ_DATA_WIDTH1 > WRITE_DATA_WIDTH1)?  (((fifo_wr_sync1/SCALING_FACTOR_WPTR1) >= (b_rptr_next1/SCALING_FACTOR_RPTR))? (fifo_wr_sync1/SCALING_FACTOR_WPTR1-(b_rptr_next1/SCALING_FACTOR_RPTR)): (fifo_wr_sync1/SCALING_FACTOR_WPTR1+(1<<(R_PTR_WIDTH1+1))-(b_rptr_next1/SCALING_FACTOR_RPTR)))  
 
 : (((fifo_wr_sync1) >= (b_rptr_next1))? (fifo_wr_sync1-(b_rptr_next1)): (fifo_wr_sync1+(1<<(W_PTR_WIDTH1+1))-(b_rptr_next1))) )   ;

// assign diff_ptr1_P1 = (WRITE_DATA_WIDTH1 > READ_DATA_WIDTH1)?   ( ((fifo_wr_sync1*SCALING_FACTOR_RPTR) >= (fifo_rd_sync1*SCALING_FACTOR_WPTR1))? (fifo_wr_sync1*SCALING_FACTOR_RPTR-(fifo_rd_sync1*SCALING_FACTOR_WPTR1)): ((fifo_wr_sync1*SCALING_FACTOR_RPTR)+(1<<(R_PTR_WIDTH1+1))-(fifo_rd_sync1*SCALING_FACTOR_RPTR)/SCALING_FACTOR_RPTR))
 
//  : ( (READ_DATA_WIDTH1 > WRITE_DATA_WIDTH1)?  (((fifo_wr_sync1/SCALING_FACTOR_WPTR1) >= (fifo_rd_sync1/SCALING_FACTOR_RPTR))? (fifo_wr_sync1/SCALING_FACTOR_WPTR1-(fifo_rd_sync1/SCALING_FACTOR_RPTR)): (fifo_wr_sync1/SCALING_FACTOR_WPTR1+(1<<(R_PTR_WIDTH1+1))-(fifo_rd_sync1/SCALING_FACTOR_RPTR)))  
 
//  : (((fifo_wr_sync1) >= (fifo_rd_sync1))? (fifo_wr_sync1-(fifo_rd_sync1)): (fifo_wr_sync1+(1<<(W_PTR_WIDTH1+1))-(fifo_rd_sync1))) )   ;

assign diff_ptr1_P1 = (WRITE_DATA_WIDTH1 > READ_DATA_WIDTH1)?   ( ((fifo_wr_sync11*SCALING_FACTOR_RPTR) >= (b_rptr_next1*SCALING_FACTOR_WPTR1))? (fifo_wr_sync11*SCALING_FACTOR_RPTR-(b_rptr_next1*SCALING_FACTOR_WPTR1)): ((fifo_wr_sync11*SCALING_FACTOR_RPTR)+(1<<(R_PTR_WIDTH1+1))-(b_rptr_next1*SCALING_FACTOR_RPTR)/SCALING_FACTOR_RPTR))
 
 : ( (READ_DATA_WIDTH1 > WRITE_DATA_WIDTH1)?  (((fifo_wr_sync11/SCALING_FACTOR_WPTR1) >= (b_rptr_next1/SCALING_FACTOR_RPTR))? (fifo_wr_sync11/SCALING_FACTOR_WPTR1-(b_rptr_next1/SCALING_FACTOR_RPTR)): (fifo_wr_sync11/SCALING_FACTOR_WPTR1+(1<<(R_PTR_WIDTH1+1))-(b_rptr_next1/SCALING_FACTOR_RPTR)))  
 
 : (((fifo_wr_sync11) >= (b_rptr_next1))? (fifo_wr_sync11-(b_rptr_next1)): (fifo_wr_sync11+(1<<(W_PTR_WIDTH1+1))-(b_rptr_next1))) )   ;


wire rempty1,al_empty1, p_empty1;

assign rempty1= (diff_ptr11<=0)?1:0;
assign al_empty1 = (diff_ptr11 ==1)? 1:0;
assign p_empty1 = (diff_ptr1_P1 ==PROG_EMPTY_THRESH1-1 || diff_ptr1_P1 <=PROG_EMPTY_THRESH1-1 )? 1:0;


always @(posedge WR_CLK1) begin
    if (RD_EN1) begin
          fifo_rd_sync1 <= fifo_rd_sync1+1;
          fwft1 <=0;
    end
    fifo_rd_sync11 <= fifo_rd_sync1;
end

always @(posedge WR_CLK1) begin
      if(WR_EN1) begin
        fifo_wr_sync1  <=  fifo_wr_sync1+1;
      end
        fifo_wr_sync11 <=  fifo_wr_sync1;
end

// fwft1 logic
always @(posedge WR_CLK1) begin
  
    if (WRITE_DATA_WIDTH1 >= READ_DATA_WIDTH1) begin

        if (!RESET1 && EMPTY1 && WR_EN1 && !fwft1) begin
                  fwft_data1 <= WR_DATA1;
                  fwft1 <= 1'b1;
        end
      
    end
    
    if (WRITE_DATA_WIDTH1 == 9 && READ_DATA_WIDTH1==18) begin

              fwft1 <= (!RESET1 && EMPTY1 && WR_EN1 && !fwft1)? 1 : fwft1;

              if(b_wptr_next1==1 || b_wptr_next1==4097 ) begin
                fwft_data1 [7:0] <= WR_DATA1[7:0] ;
                fwft_data1 [8] <= WR_DATA1[8] ;
              end
              if(b_wptr_next1==2 || b_wptr_next1==4098 ) begin
                fwft_data1 [16:9] <= WR_DATA1[7:0];
                fwft_data1 [17] <= WR_DATA1[8];
              end     
    end
end

always @(posedge WR_CLK1) begin
      if (RD_EN1) begin
        fwft1 <= 1'b0;
      end
end

always@(posedge WR_CLK1) begin
  if(WR_EN1 & FULL1) begin
    OVERFLOW1 <=1;
  end
  else begin
    OVERFLOW1 <=0;
  end
end

always@(posedge WR_CLK1) begin
  if(RD_EN1 & EMPTY1) begin
    UNDERFLOW1 <=1;
  end
  else begin
    UNDERFLOW1 <=0;
  end
end

always @(*) begin    
    if (OVERFLOW1) begin
        @(posedge WR_CLK1) begin
        $fatal(1,"\n Error: OVERFLOW1 Happend, RESET THE FIFO1 FIRST \n", OVERFLOW1 );             
        end 
     end
end

always @(*) begin    
    if (UNDERFLOW1) begin
        @(posedge RD_CLK1) begin
        $fatal(1,"\n Error: UNDERFLOW1 Happend, RESET THE FIFO1 FIRST \n", UNDERFLOW1 );             
        end 
     end
end

always @(fifo_depth_write1) begin    
    if (PROG_FULL_THRESH1>fifo_depth_write1-2) begin
        $fatal(1,"\n ERROR: PROG_FULL_THRESH1 is GREATER THAN fifo_depth_write1-2 \n" );             
     end
end

always @(fifo_depth_read1) begin    
    if (PROG_EMPTY_THRESH1>fifo_depth_read1-2) begin
        $fatal(1,"\n ERROR: PROG_EMPTY_THRESH1 is GREATER THAN fifo_depth_write1-2 \n" );             
     end
end


always @(posedge RESET1, posedge WR_CLK1) begin
   
        if (RESET1) begin
          fifo_wr_sync1 <= {fifo_addr_width_write1{1'b0}};
          fifo_rd_sync1 <= {fifo_addr_width_read1{1'b0}};
          EMPTY1        <= 1'b1;
          FULL1         <= 1'b0;
          ALMOST_EMPTY1 <= 1'b0;
          ALMOST_FULL1  <= 1'b0;
          PROG_EMPTY1   <= 1'b1;
          PROG_FULL1    <= 1'b0;
          OVERFLOW1     <= 1'b0;
          UNDERFLOW1    <= 1'b0;
          fwft1         <= 1'b0;
          fwft_data1    <= {READ_DATA_WIDTH1-1{1'b0}};
        end 
        else begin
          FULL1 <= wfull1;
          ALMOST_FULL1 <= al_full1;
          PROG_FULL1 <= p_full1;
          EMPTY1 <= rempty1;
          ALMOST_EMPTY1 <= al_empty1;
          PROG_EMPTY1 <= p_empty1;
        end
end 

assign ram_clk_b1 = WR_CLK1;

        initial begin
          #1;
          @(RD_CLK1);
          $display("\nWarning: FIFO36K instance %m RD_CLK1 should be tied to ground when FIFO36K is configured as FIFO1_TYPE=SYNCHRONOUS.");
        end

end else begin: ASYNC_FIFO1

reg fwft1;

always @(RESET1) begin
  fwft1 <=0;
end

wire ram_clk_b1;
wire rempty1,al_empty1, p_empty1;


localparam DATA_WIDTH_WRITE1 = DATA_WRITE_WIDTH1;
localparam DATA_WIDTH_READ1 = DATA_READ_WIDTH1;

  localparam  fifo_depth_write1 = (DATA_WIDTH_WRITE1 <= 9) ? 2048 :
                                 1024;

  localparam  fifo_depth_read1 = (DATA_WIDTH_READ1 <= 9) ? 2048 :
                                 1024;
  
  localparam  fifo_addr_width_r1 = (DATA_WIDTH_READ1 <= 9) ? 11 :
                                  10;
  localparam  fifo_addr_width_w1 = (DATA_WIDTH_WRITE1 <= 9) ? 11 :
                                  10;

  reg [fifo_addr_width_w1-1:0] fifo_wr_addr1 = {fifo_addr_width_w1{1'b0}};
  reg [fifo_addr_width_r1-1:0] fifo_rd_addr1 = {fifo_addr_width_r1{1'b0}};

  reg [DATA_WIDTH_READ1-1:0] fwft_data1 = {DATA_WIDTH_READ1{1'b0}};
  reg [DATA_WIDTH_READ1-1:0] fwft_data_temp1 ={DATA_WIDTH_READ1{1'b0}};


  wire [31:0] ram_wr_data1;
  wire [3:0] ram_wr_parity1;

  wire [31:0] ram_rd_data1; 
  wire [3:0]  ram_rd_parity1;

assign ram_clk_b1 = RD_CLK1;

localparam W_PTR_WIDTH1 = $clog2(fifo_depth_write1);
localparam R_PTR_WIDTH1 = $clog2(fifo_depth_read1);

wire [W_PTR_WIDTH1:0] b_wptr_sync1, b_wptr_w1, b_wptr_sync_for_a1;
wire [R_PTR_WIDTH1:0] b_rptr_sync1, b_rptr_w1, b_rptr_w11, b_rptr_sync_for_a1;


always @(fifo_depth_write1) begin    
    if (PROG_FULL_THRESH1>fifo_depth_write1-2) begin
        $fatal(1,"\n ERROR: PROG_FULL_THRESH1 is GREATER THAN fifo_depth_write1-2 \n" );             
     end
end

always @(fifo_depth_read1) begin    
    if (PROG_EMPTY_THRESH1>fifo_depth_read1-2) begin
        $fatal(1,"\n ERROR: PROG_EMPTY_THRESH1 is GREATER THAN fifo_depth_write1-2 \n" );             
     end
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
        .CLK_B1(RD_CLK1), // Clock port B, RAM 1
        .BE_A1(2'b11), // Byte-write enable port A, RAM 1
        .BE_B1(2'b11), // Byte-write enable port B, RAM 1
        .ADDR_A1({b_wptr_w1, {14-fifo_addr_width_w1{1'b0}}}), // Address port A, RAM 1
        .ADDR_B1({(b_rptr_w11), {14-fifo_addr_width_r1{1'b0}}}), // Address port B, RAM 1
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


/*-------------------------------------------------------------------*/

// generate

    if(DATA_WIDTH_READ1==9) begin
      assign RD_DATA1 = (fwft1 ? fwft_data1 : {ram_rd_parity1[0], ram_rd_data1[7:0]});    
    end

    if(DATA_WIDTH_READ1==18) begin
      assign RD_DATA1 = fwft1 ? fwft_data1 : {ram_rd_parity1[1], ram_rd_data1[15:8], ram_rd_parity1[0], ram_rd_data1[7:0]};    
    end

    if(DATA_WIDTH_WRITE1==9) begin       
      assign ram_wr_data1 = {{32-DATA_WIDTH_WRITE1{1'b0}}, WR_DATA1[DATA_WIDTH_WRITE1-2:0]};
      assign ram_wr_parity1 = {3'b000, WR_DATA1[DATA_WIDTH_WRITE1-1]};
    end
    
    if(DATA_WIDTH_WRITE1==18) begin 
      assign ram_wr_data1 = {{32-DATA_WIDTH_WRITE1{1'b0}}, WR_DATA1[16:9],WR_DATA1[7:0]};
      assign ram_wr_parity1 = {2'b00, WR_DATA1[17], WR_DATA1[8]};
    end


// endgenerate
  
/*---------Write pointer synchronizer ( 2 FLOPS) logic--------------*/


reg [W_PTR_WIDTH1:0] q11,q1_a1,d_out11;

  assign b_wptr_sync1 = d_out11;
  assign b_wptr_sync_for_a1 = q1_a1;

always @(*) begin
if(RESET1) begin
       q11 <= 0;
      d_out11 <= 0;
      q1_a1 <=0;  
end

end
  always@(posedge RD_CLK1) begin
      q11 <= b_wptr_w1;
      d_out11 <= q11;
      q1_a1 <= d_out11;
  end

/*-------------------------------------------------------------------*/

/*--------- Read pointer synchronizer (2 FLOPS ) logic --------------*/

reg [R_PTR_WIDTH1:0] q21, q2_a1, d_out21;

assign b_rptr_sync1 = d_out21;
assign b_rptr_sync_for_a1 = q2_a1;

always @(*) begin
  if(RESET1) begin
      q21 <= 0;
      d_out21 <= 0;
      q2_a1 <=0;
  end
end

always@(posedge WR_CLK1) begin
      q21 <= b_rptr_w1;
      d_out21 <= q21;
      q2_a1 <= d_out21;
end

/*-------------------------------------------------------------------*/

/* ---------------- Write pointer handler logic ---------------------*/


localparam SCALING_FACTOR_WPTR1= (DATA_WIDTH_READ1>DATA_WIDTH_WRITE1)? (DATA_WIDTH_READ1/DATA_WIDTH_WRITE1):1;
localparam SCALING_FACTOR_RPTR1= (DATA_WIDTH_READ1<DATA_WIDTH_WRITE1)? (DATA_WIDTH_WRITE1/DATA_WIDTH_READ1):1;


  wire [W_PTR_WIDTH1:0] b_wptr_next1;

  reg [W_PTR_WIDTH1:0] b_wptr1;

  wire wfull1, al_full1, p_full1; 

  wire [W_PTR_WIDTH1:0] diff_ptr01, diff_ptr21, diff_ptr0_for_a1;

  assign b_wptr_next1 = b_wptr1+(WR_EN1 & !FULL1);

  assign b_wptr_w1 = b_wptr1;


  assign diff_ptr01 =(DATA_WIDTH_WRITE1>DATA_WIDTH_READ1)? /* W>R */ ((((b_wptr_next1/SCALING_FACTOR_WPTR1  >= (b_rptr_sync1/SCALING_FACTOR_RPTR1))? (b_wptr_next1/SCALING_FACTOR_WPTR1-(b_rptr_sync1/SCALING_FACTOR_RPTR1)): (b_wptr_next1/SCALING_FACTOR_WPTR1+(1<<(W_PTR_WIDTH1+1))-(b_rptr_sync1/SCALING_FACTOR_RPTR1)))))

  : (  (DATA_WIDTH_READ1>DATA_WIDTH_WRITE1)? ( /* R>W */ ((((b_wptr_next1*SCALING_FACTOR_RPTR1  >= (b_rptr_sync1*SCALING_FACTOR_WPTR1))? (b_wptr_next1*SCALING_FACTOR_RPTR1-(b_rptr_sync1*SCALING_FACTOR_WPTR1)): (b_wptr_next1*SCALING_FACTOR_RPTR1+(1<<(W_PTR_WIDTH1+1))-(b_rptr_sync1*SCALING_FACTOR_WPTR1))))) ) 

  : /* R==W */ ((((b_wptr_next1  >= (b_rptr_sync1 ))? (b_wptr_next1 - (b_rptr_sync1)): (b_wptr_next1 + (1<<(W_PTR_WIDTH1+1))-(b_rptr_sync1 ))))) );  


  assign diff_ptr0_for_a1 =(DATA_WIDTH_WRITE1>DATA_WIDTH_READ1)? /* W>R */ ((((b_wptr_next1/SCALING_FACTOR_WPTR1  >= (b_rptr_sync_for_a1/SCALING_FACTOR_RPTR1))? (b_wptr_next1/SCALING_FACTOR_WPTR1-(b_rptr_sync_for_a1/SCALING_FACTOR_RPTR1)): (b_wptr_next1/SCALING_FACTOR_WPTR1+(1<<(W_PTR_WIDTH1+1))-(b_rptr_sync_for_a1/SCALING_FACTOR_RPTR1)))))

  : (  (DATA_WIDTH_READ1>DATA_WIDTH_WRITE1)? ( /* R>W */ ((((b_wptr_next1*SCALING_FACTOR_RPTR1  >= (b_rptr_sync_for_a1*SCALING_FACTOR_WPTR1))? (b_wptr_next1*SCALING_FACTOR_RPTR1-(b_rptr_sync_for_a1*SCALING_FACTOR_WPTR1)): (b_wptr_next1*SCALING_FACTOR_RPTR1+(1<<(W_PTR_WIDTH1+1))-(b_rptr_sync_for_a1*SCALING_FACTOR_WPTR1))))) ) 

  : /* R==W */ ((((b_wptr_next1  >= (b_rptr_sync_for_a1 ))? (b_wptr_next1 - (b_rptr_sync_for_a1)): (b_wptr_next1 + (1<<(W_PTR_WIDTH1+1))-(b_rptr_sync_for_a1 ))))) );  


  // assign wfull1 = (DATA_WIDTH_WRITE1>DATA_WIDTH_READ1)? (diff_ptr01 == (1<<W_PTR_WIDTH1)) : (diff_ptr01 == (1<<R_PTR_WIDTH1) );

  assign wfull1 = (DATA_WIDTH_WRITE1>DATA_WIDTH_READ1)? (diff_ptr01 == (1<<W_PTR_WIDTH1)) : (diff_ptr01 == (1<<W_PTR_WIDTH1)   );


  assign al_full1 = (DATA_WIDTH_WRITE1>DATA_WIDTH_READ1)? (diff_ptr01 == (1<<W_PTR_WIDTH1)-1): (diff_ptr01 == ((1<<W_PTR_WIDTH1)-1) );

  assign p_full1 = (DATA_WIDTH_WRITE1>DATA_WIDTH_READ1)? (diff_ptr0_for_a1 >= ((1<<W_PTR_WIDTH1)-PROG_FULL_THRESH1+1) ) :  ( (diff_ptr0_for_a1 >= ((1<<W_PTR_WIDTH1)-PROG_FULL_THRESH1+1) ) );


  // assign diff_ptr21 = ((((b_wptr_next1*SCALING_FACTOR_WPTR1-(b_rptr_sync1/SCALING_FACTOR_RPTR1)): (b_wptr_next1/SCALING_FACTOR_WPTR1+(1<<(W_PTR_WIDTH1+1))-(b_rptr_sync1/SCALING_FACTOR_RPTR1)))))



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

      FULL1 <= wfull1;
      ALMOST_FULL1 <= al_full1;
      PROG_FULL1 <= p_full1;

    end
  end

/*---------------------------------------------------------------*/

/*-----------  READ pointer handler logic -----------------------*/



wire [R_PTR_WIDTH1:0] diff_ptr11, diff_ptr1_for_a1;
reg  [R_PTR_WIDTH1:0] b_rptr_next1, b_rptr_next_temp1, b_rptr1;


// always @(posedge RD_CLK1) begin

//     if(RESET1) begin
//       b_rptr_next1 =0;
//       b_rptr1 <=0;
//     end
//     else begin
//       if((RD_EN1 & !EMPTY1)) begin
//         if (b_rptr_next1==(1<<R_PTR_WIDTH1+1)) begin  
//           b_rptr_next1 <=0;
//         end
//         else begin
//           b_rptr_next1 <= b_rptr_next1+1;      
//         end
//       end
//     end
// end

assign b_rptr_w1 = b_rptr1;

assign b_rptr_w11 =  b_rptr_w1+1'b1;  // (RD_EN1 & b_rptr_next1=='0)? 1: b_rptr_next1+1;

assign b_rptr_next1 = b_rptr1+(RD_EN1 & !EMPTY1);


assign diff_ptr11 = (DATA_WIDTH_WRITE1 > DATA_WIDTH_READ1)?   ( ((b_wptr_sync1*SCALING_FACTOR_RPTR1) >= (b_rptr_next1*SCALING_FACTOR_WPTR1))? (b_wptr_sync1*SCALING_FACTOR_RPTR1-(b_rptr_next1*SCALING_FACTOR_WPTR1)): ((b_wptr_sync1*SCALING_FACTOR_RPTR1)+(1<<(R_PTR_WIDTH1+1))-(b_rptr_next1*SCALING_FACTOR_RPTR1)/SCALING_FACTOR_RPTR1))
 
 : ( (DATA_WIDTH_READ1 > DATA_WIDTH_WRITE1)?  (((b_wptr_sync1/SCALING_FACTOR_WPTR1) >= (b_rptr_next1/SCALING_FACTOR_RPTR1))? (b_wptr_sync1/SCALING_FACTOR_WPTR1-(b_rptr_next1/SCALING_FACTOR_RPTR1)): (b_wptr_sync1/SCALING_FACTOR_WPTR1+(1<<(R_PTR_WIDTH1+1))-(b_rptr_next1/SCALING_FACTOR_RPTR1)))  
 
 : (((b_wptr_sync1) >= (b_rptr_next1))? (b_wptr_sync1-(b_rptr_next1)): (b_wptr_sync1+(1<<(W_PTR_WIDTH1+1))-(b_rptr_next1))) )   ;

assign diff_ptr1_for_a1 = (DATA_WIDTH_WRITE1 > DATA_WIDTH_READ1)?   ( ((b_wptr_sync_for_a1*SCALING_FACTOR_RPTR1) >= (b_rptr_next1*SCALING_FACTOR_WPTR1))? (b_wptr_sync_for_a1*SCALING_FACTOR_RPTR1-(b_rptr_next1*SCALING_FACTOR_WPTR1)): ((b_wptr_sync_for_a1*SCALING_FACTOR_RPTR1)+(1<<(R_PTR_WIDTH1+1))-(b_rptr_next1*SCALING_FACTOR_RPTR1)/SCALING_FACTOR_RPTR1))
 
 : ( (DATA_WIDTH_READ1 > DATA_WIDTH_WRITE1)?  (((b_wptr_sync_for_a1/SCALING_FACTOR_WPTR1) >= (b_rptr_next1/SCALING_FACTOR_RPTR1))? (b_wptr_sync_for_a1/SCALING_FACTOR_WPTR1-(b_rptr_next1/SCALING_FACTOR_RPTR1)): (b_wptr_sync_for_a1/SCALING_FACTOR_WPTR1+(1<<(R_PTR_WIDTH1+1))-(b_rptr_next1/SCALING_FACTOR_RPTR1)))  
 
 : (((b_wptr_sync_for_a1) >= (b_rptr_next1))? (b_wptr_sync_for_a1-(b_rptr_next1)): (b_wptr_sync_for_a1+(1<<(W_PTR_WIDTH1+1))-(b_rptr_next1))) )   ;


assign rempty1= (diff_ptr11==0)?1:0;

assign al_empty1 = (diff_ptr11 ==1)? 1:0;

assign p_empty1 = (diff_ptr1_for_a1 ==PROG_EMPTY_THRESH1-1 || diff_ptr1_for_a1 <=PROG_EMPTY_THRESH1-1 )? 1:0;


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
      PROG_EMPTY1 <= p_empty1;    
      
      if(DATA_WIDTH_READ1==9) begin
        if(b_rptr1==4095 & WR_EN1==0) begin
          ALMOST_EMPTY1 <=0;
        end
        else begin
          ALMOST_EMPTY1 <= al_empty1;
        end
      end
      else begin
        ALMOST_EMPTY1 <= al_empty1;      
      end      
    end 
    
  end


/*------------------------------------------------------------------*/

/*------------- Adding logic of First word fall through ------------*/
  always @ (posedge RD_CLK1) begin
        if(RD_EN1) begin
            fwft1 =0;
        end
  end

  always @(posedge WR_CLK1) begin
      if(RESET1) begin
        fwft1 =0;
      end
      else if (EMPTY1==1 & WR_EN1==1) begin
        fwft1 = 1 ;
      end
      else begin
        fwft1 = fwft1;
      end
  end

always @(*) begin
  if(fwft1) begin
    fwft_data1 <= fwft_data_temp1;
  end
end


    always@(posedge WR_CLK1) begin
// -1
        if (DATA_WIDTH_WRITE1 >= DATA_WIDTH_READ1) begin
        
            if (EMPTY1 && WR_EN1 && !RESET1) begin

              if (DATA_WIDTH_WRITE1==18 && DATA_WIDTH_READ1==18) begin
                if(b_wptr_next1==1 || b_wptr_next1==2049) begin
                  fwft_data_temp1 <= WR_DATA1;
                end
              end
              if (DATA_WIDTH_WRITE1==9 && DATA_WIDTH_READ1==9) begin
                if(b_wptr_next1==1 || b_wptr_next1==4097) begin
                  fwft_data_temp1 <= WR_DATA1;
                end
              end
              else if (DATA_WIDTH_WRITE1==18 && DATA_WIDTH_READ1==9) begin
                if(b_wptr_next1==1 || b_wptr_next1==2049) begin
                  fwft_data_temp1 <= {{WR_DATA1[8]},{WR_DATA1[7:0]}} ;  // DEVELOP LOGIC FOR OTHER WIDTH AS WELL
                end
              end

            end
        end
// -2          
        if (DATA_WIDTH_WRITE1 == 9 && DATA_WIDTH_READ1==18) begin
            if (EMPTY1 && WR_EN1 && !RESET1) begin

              if(b_wptr_next1==1 || b_wptr_next1==4097 ) begin
                fwft_data_temp1 [7:0] <= WR_DATA1[7:0] ;
                fwft_data_temp1 [8] <= WR_DATA1[8] ;
              end
              if(b_wptr_next1==2 || b_wptr_next1==4098 ) begin
                fwft_data_temp1 [16:9] <= WR_DATA1[7:0];
                fwft_data_temp1 [17] <= WR_DATA1[8];
              end     

           end

        end

  end


/*---------------------------------------------------------------*/

/*--------- Adding logic of OVERFLOW1 and UNDERFLOW1 -----------*/

    always @(posedge WR_CLK1) begin
      if (RESET1) begin
       OVERFLOW1 = 0;
      end
      else if (FULL1 & WR_EN1 ) begin
       OVERFLOW1 = 1;
      end
    end

    always @(posedge RD_CLK1) begin 
        if (RESET1) begin
          OVERFLOW1 = 0;
        end
        else if(RD_EN1 & OVERFLOW1) begin
          OVERFLOW1 = 0;
        end
    end

    always @(posedge RD_CLK1) begin

      if (RESET1) begin
        UNDERFLOW1 = 0;
      end
      else if (EMPTY1 & RD_EN1) begin
         UNDERFLOW1 = 1;
      end
    end

    always @(posedge WR_CLK1) begin
      if (RESET1) begin
       UNDERFLOW1 = 0;
      end
      else if (EMPTY1 & WR_EN1 ) begin
       UNDERFLOW1 = 0;
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

if ( FIFO_TYPE2 == "SYNCHRONOUS" )  begin: SYNC2

  // FOR ASYNC FIFO1
    localparam WRITE_DATA_WIDTH2= DATA_WRITE_WIDTH2;
    localparam READ_DATA_WIDTH2= DATA_READ_WIDTH2;

    localparam  fifo_depth_write2 = (WRITE_DATA_WIDTH2 <= 9) ? 2048 : 1024;
    localparam  fifo_depth_read2 = (READ_DATA_WIDTH2 <= 9) ? 2048 :  1024;

    localparam  fifo_addr_width_write2 = (WRITE_DATA_WIDTH2 <= 9) ? 11 :  10;
    localparam  fifo_addr_width_read2 = (READ_DATA_WIDTH2 <= 9) ? 11 :  10;

  reg [fifo_addr_width_write2:0] fifo_wr_sync2 = {fifo_addr_width_write2{1'b0}};
  reg [fifo_addr_width_write2:0] fifo_wr_sync12 = {fifo_addr_width_write2{1'b0}};
  reg [fifo_addr_width_read2:0] fifo_rd_sync2 = {fifo_addr_width_read2{1'b0}};
  reg [fifo_addr_width_read2:0] fifo_rd_sync12 = {fifo_addr_width_read2{1'b0}};

    reg [fifo_addr_width_write2-1:0] async_fifo_wr_addr2 = {fifo_addr_width_write2{1'b0}};
    reg [fifo_addr_width_read2-1:0] async_fifo_rd_addr2 = {fifo_addr_width_read2{1'b0}};


    wire [15:0] ram_wr_data2;
    wire [1:0] ram_wr_parity2;

  // common
    reg fwft2 = 1'b0;  
    reg fall_through2;
    reg wr_data_fwft2;
    reg [DATA_READ_WIDTH2-1:0] fwft_data2 = {DATA_READ_WIDTH2{1'b0}}; 


    wire [15:0] ram_rd_data2; 
    wire [1:0]  ram_rd_parity2;
    wire ram_clk_b2;


  localparam W_PTR_WIDTH2 = $clog2(fifo_depth_write2);
  localparam R_PTR_WIDTH2 = $clog2(fifo_depth_read2);


  wire [W_PTR_WIDTH2:0] b_wptr_sync2, b_wptr_w2, b_wptr_sync2_for_a;
  wire [R_PTR_WIDTH2:0] b_rptr_sync2, b_rptr_w2, b_rptr_w12, b_rptr_sync2_for_a;


    if(DATA_READ_WIDTH2==9) begin
      assign RD_DATA2 = (fwft2 ? fwft_data2 : {ram_rd_parity2[0], ram_rd_data2[7:0]});    
    end

    if(DATA_READ_WIDTH2==18) begin
      assign RD_DATA2 = fwft2 ? fwft_data2 : {ram_rd_parity2[1], ram_rd_data2[15:8], ram_rd_parity2[0], ram_rd_data2[7:0]};    
    end

    if(DATA_WRITE_WIDTH2==9) begin       
      assign ram_wr_data2 = {{32-DATA_WRITE_WIDTH2{1'b0}}, WR_DATA2[DATA_WRITE_WIDTH2-2:0]};
      assign ram_wr_parity2 = {3'b000, WR_DATA2[DATA_WRITE_WIDTH2-1]};
    end
    
    if(DATA_WRITE_WIDTH2==18) begin 
      assign ram_wr_data2 = {{32-DATA_WRITE_WIDTH2{1'b0}}, WR_DATA2[16:9],WR_DATA2[7:0]};
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
      .CLK_B2(ram_clk_b2), // Clock port B, RAM 2
      .BE_A2(2'b11), // Byte-write enable port A, RAM 2
      .BE_B2(2'b11), // Byte-write enable port B, RAM 2
      .ADDR_A2({fifo_wr_sync2, {14-fifo_addr_width_write2{1'b0}}}), // Address port A, RAM 2
      .ADDR_B2({ (fifo_rd_sync2+1'b1), {14-fifo_addr_width_read2{1'b0}}}), // Address port B, RAM 2
      .WDATA_A2(ram_wr_data2), // Write data port A, RAM 2
      .WPARITY_A2(ram_wr_parity2), // Write parity port A, RAM 2
      .WDATA_B2(16'h0000), // Write data port B, RAM 2
      .WPARITY_B2(2'b00), // Write parity port B, RAM 2
      .RDATA_A2(), // Read data port A, RAM 2
      .RPARITY_A2(), // Read parity port A, RAM 2
      .RDATA_B2(ram_rd_data2), // Read data port B, RAM 2
      .RPARITY_B2(ram_rd_parity2) // Read parity port B, RAM 2
    );


  localparam SCALING_FACTOR_WPTR2= (READ_DATA_WIDTH2>WRITE_DATA_WIDTH2)? (READ_DATA_WIDTH2/WRITE_DATA_WIDTH2):1;
  localparam SCALING_FACTOR_RPTR2= (READ_DATA_WIDTH2<WRITE_DATA_WIDTH2)? (WRITE_DATA_WIDTH2/READ_DATA_WIDTH2):1;
  
  wire [W_PTR_WIDTH2:0] b_wptr_next2;
  wire [R_PTR_WIDTH2:0] b_rptr_next2;

  wire [W_PTR_WIDTH2:0] diff_ptr02, diff_ptr0_P2;
  wire wfull2, al_full2, p_full2; 

  assign b_wptr_next2 = fifo_wr_sync2+(WR_EN2 & !FULL2);
  assign b_rptr_next2 = fifo_rd_sync2+(RD_EN2 & !EMPTY2);
  

 assign diff_ptr02 =(WRITE_DATA_WIDTH2>READ_DATA_WIDTH2)? /* W>R */ ((((b_wptr_next2/SCALING_FACTOR_WPTR2  >= (fifo_rd_sync2/SCALING_FACTOR_RPTR2))? (b_wptr_next2/SCALING_FACTOR_WPTR2-(fifo_rd_sync2/SCALING_FACTOR_RPTR2)): (b_wptr_next2/SCALING_FACTOR_WPTR2+(1<<(W_PTR_WIDTH2+1))-(fifo_rd_sync2/SCALING_FACTOR_RPTR2)))))

  : (  (READ_DATA_WIDTH2>WRITE_DATA_WIDTH2)? ( /* R>W */ ((((b_wptr_next2*SCALING_FACTOR_RPTR2  >= (fifo_rd_sync2*SCALING_FACTOR_WPTR2))? (b_wptr_next2*SCALING_FACTOR_RPTR2-(fifo_rd_sync2*SCALING_FACTOR_WPTR2)): (b_wptr_next2*SCALING_FACTOR_RPTR2+(1<<(W_PTR_WIDTH2+1))-(fifo_rd_sync2*SCALING_FACTOR_WPTR2))))) ) 

  : /* R==W */ ((((b_wptr_next2  >= (fifo_rd_sync2 ))? (b_wptr_next2 - (fifo_rd_sync2)): (b_wptr_next2 + (1<<(W_PTR_WIDTH2+1))-(fifo_rd_sync2 ))))) ); 


 assign diff_ptr0_P2 =(WRITE_DATA_WIDTH2>READ_DATA_WIDTH2)? /* W>R */ ((((b_wptr_next2/SCALING_FACTOR_WPTR2  >= (fifo_rd_sync12/SCALING_FACTOR_RPTR2))? (b_wptr_next2/SCALING_FACTOR_WPTR2-(fifo_rd_sync12/SCALING_FACTOR_RPTR2)): (b_wptr_next2/SCALING_FACTOR_WPTR2+(1<<(W_PTR_WIDTH2+1))-(fifo_rd_sync12/SCALING_FACTOR_RPTR2)))))

  : (  (READ_DATA_WIDTH2>WRITE_DATA_WIDTH2)? ( /* R>W */ ((((b_wptr_next2*SCALING_FACTOR_RPTR2  >= (fifo_rd_sync12*SCALING_FACTOR_WPTR2))? (b_wptr_next2*SCALING_FACTOR_RPTR2-(fifo_rd_sync12*SCALING_FACTOR_WPTR2)): (b_wptr_next2*SCALING_FACTOR_RPTR2+(1<<(W_PTR_WIDTH2+1))-(fifo_rd_sync12*SCALING_FACTOR_WPTR2))))) ) 

  : /* R==W */ ((((b_wptr_next2  >= (fifo_rd_sync12 ))? (b_wptr_next2 - (fifo_rd_sync12)): (b_wptr_next2 + (1<<(W_PTR_WIDTH2+1))-(fifo_rd_sync12 ))))) ); 


// assign diff_ptr02 = b_wptr_next2-(b_rptr_next2/SCALING_FACTOR_RPTR2);

  assign wfull2 = (WRITE_DATA_WIDTH2>READ_DATA_WIDTH2)? (diff_ptr02 == (1<<W_PTR_WIDTH2)) : (diff_ptr02 == (1<<W_PTR_WIDTH2)   );


  assign al_full2 = (WRITE_DATA_WIDTH2>READ_DATA_WIDTH2)? (diff_ptr02 == (1<<W_PTR_WIDTH2)-1): (diff_ptr02 == ((1<<W_PTR_WIDTH2)-1) );

  assign p_full2 = (WRITE_DATA_WIDTH2>READ_DATA_WIDTH2)? (diff_ptr0_P2 >= ((1<<W_PTR_WIDTH2)-PROG_FULL_THRESH2+1) ) :  ( (diff_ptr0_P2 >= ((1<<W_PTR_WIDTH2)-PROG_FULL_THRESH2+1) ) );

wire [R_PTR_WIDTH2:0] diff_ptr12,diff_ptr1_P2;

// assign diff_ptr12 = fifo_wr_sync2*SCALING_FACTOR_RPTR2 - b_rptr_next2*SCALING_FACTOR_WPTR2;

assign diff_ptr12 = (WRITE_DATA_WIDTH2 > READ_DATA_WIDTH2)?   ( ((fifo_wr_sync2*SCALING_FACTOR_RPTR2) >= (b_rptr_next2*SCALING_FACTOR_WPTR2))? (fifo_wr_sync2*SCALING_FACTOR_RPTR2-(b_rptr_next2*SCALING_FACTOR_WPTR2)): ((fifo_wr_sync2*SCALING_FACTOR_RPTR2)+(1<<(R_PTR_WIDTH2+1))-(b_rptr_next2*SCALING_FACTOR_RPTR2)/SCALING_FACTOR_RPTR2))
 
 : ( (READ_DATA_WIDTH2 > WRITE_DATA_WIDTH2)?  (((fifo_wr_sync2/SCALING_FACTOR_WPTR2) >= (b_rptr_next2/SCALING_FACTOR_RPTR2))? (fifo_wr_sync2/SCALING_FACTOR_WPTR2-(b_rptr_next2/SCALING_FACTOR_RPTR2)): (fifo_wr_sync2/SCALING_FACTOR_WPTR2+(1<<(R_PTR_WIDTH2+1))-(b_rptr_next2/SCALING_FACTOR_RPTR2)))  
 
 : (((fifo_wr_sync2) >= (b_rptr_next2))? (fifo_wr_sync2-(b_rptr_next2)): (fifo_wr_sync2+(1<<(W_PTR_WIDTH2+1))-(b_rptr_next2))) )   ;

// assign diff_ptr1_P2 = (WRITE_DATA_WIDTH2 > READ_DATA_WIDTH2)?   ( ((fifo_wr_sync2*SCALING_FACTOR_RPTR2) >= (fifo_rd_sync2*SCALING_FACTOR_WPTR2))? (fifo_wr_sync2*SCALING_FACTOR_RPTR2-(fifo_rd_sync2*SCALING_FACTOR_WPTR2)): ((fifo_wr_sync2*SCALING_FACTOR_RPTR2)+(1<<(R_PTR_WIDTH2+1))-(fifo_rd_sync2*SCALING_FACTOR_RPTR2)/SCALING_FACTOR_RPTR2))
 
//  : ( (READ_DATA_WIDTH2 > WRITE_DATA_WIDTH2)?  (((fifo_wr_sync2/SCALING_FACTOR_WPTR2) >= (fifo_rd_sync2/SCALING_FACTOR_RPTR2))? (fifo_wr_sync2/SCALING_FACTOR_WPTR2-(fifo_rd_sync2/SCALING_FACTOR_RPTR2)): (fifo_wr_sync2/SCALING_FACTOR_WPTR2+(1<<(R_PTR_WIDTH2+1))-(fifo_rd_sync2/SCALING_FACTOR_RPTR2)))  
 
//  : (((fifo_wr_sync2) >= (fifo_rd_sync2))? (fifo_wr_sync2-(fifo_rd_sync2)): (fifo_wr_sync2+(1<<(W_PTR_WIDTH2+1))-(fifo_rd_sync2))) )   ;

assign diff_ptr1_P2 = (WRITE_DATA_WIDTH2 > READ_DATA_WIDTH2)?   ( ((fifo_wr_sync12*SCALING_FACTOR_RPTR2) >= (b_rptr_next2*SCALING_FACTOR_WPTR2))? (fifo_wr_sync12*SCALING_FACTOR_RPTR2-(b_rptr_next2*SCALING_FACTOR_WPTR2)): ((fifo_wr_sync12*SCALING_FACTOR_RPTR2)+(1<<(R_PTR_WIDTH2+1))-(b_rptr_next2*SCALING_FACTOR_RPTR2)/SCALING_FACTOR_RPTR2))
 
 : ( (READ_DATA_WIDTH2 > WRITE_DATA_WIDTH2)?  (((fifo_wr_sync12/SCALING_FACTOR_WPTR2) >= (b_rptr_next2/SCALING_FACTOR_RPTR2))? (fifo_wr_sync12/SCALING_FACTOR_WPTR2-(b_rptr_next2/SCALING_FACTOR_RPTR2)): (fifo_wr_sync12/SCALING_FACTOR_WPTR2+(1<<(R_PTR_WIDTH2+1))-(b_rptr_next2/SCALING_FACTOR_RPTR2)))  
 
 : (((fifo_wr_sync12) >= (b_rptr_next2))? (fifo_wr_sync12-(b_rptr_next2)): (fifo_wr_sync12+(1<<(W_PTR_WIDTH2+1))-(b_rptr_next2))) )   ;


wire rempty2,al_empty2, p_empty2;

assign rempty2= (diff_ptr12<=0)?1:0;
assign al_empty2 = (diff_ptr12 ==1)? 1:0;
assign p_empty2 = (diff_ptr1_P2 ==PROG_EMPTY_THRESH2-1 || diff_ptr1_P2 <=PROG_EMPTY_THRESH2-1 )? 1:0;


always @(posedge WR_CLK2) begin
    if (RD_EN2) begin
          fifo_rd_sync2 <= fifo_rd_sync2+1;
          fwft2 <=0;
    end
    fifo_rd_sync12 <= fifo_rd_sync2;
end

always @(posedge WR_CLK2) begin
      if(WR_EN2) begin
        fifo_wr_sync2  <=  fifo_wr_sync2+1;
      end
        fifo_wr_sync12 <=  fifo_wr_sync2;
end

// fwft2 logic
always @(posedge WR_CLK2) begin
  
    if (EMPTY2 && WR_EN2 && !fwft2) begin
              fwft_data2 <= WR_DATA2;
              fwft2 <= 1'b1;
    end
    
    if (WRITE_DATA_WIDTH2 == 9 && READ_DATA_WIDTH2==18) begin

              fwft2 <= (EMPTY2 && WR_EN2 && !fwft2)? 1 : fwft2;

              if(b_wptr_next2==1 || b_wptr_next2==4097 ) begin
                fwft_data2 [7:0] <= WR_DATA2[7:0] ;
                fwft_data2 [8] <= WR_DATA2[8] ;
              end
              if(b_wptr_next2==2 || b_wptr_next2==4098 ) begin
                fwft_data2 [16:9] <= WR_DATA2[7:0];
                fwft_data2 [17] <= WR_DATA2[8];
              end     
    end
end

always @(posedge WR_CLK2) begin
      if (RD_EN2) begin
        fwft2 <= 1'b0;
      end
end

always@(posedge WR_CLK2) begin
  if(WR_EN2 & FULL2) begin
    OVERFLOW2 <=1;
  end
  else begin
    OVERFLOW2 <=0;
  end
end

always@(posedge WR_CLK2) begin
  if(RD_EN2 & EMPTY2) begin
    UNDERFLOW2 <=1;
  end
  else begin
    UNDERFLOW2 <=0;
  end
end

always @(*) begin    
    if (OVERFLOW2) begin
        @(posedge WR_CLK2) begin
        $fatal(1,"\n Error: OVERFLOW2 Happend, RESET2 THE FIFO2 FIRST \n", OVERFLOW2 );             
        end 
     end
end

always @(*) begin    
    if (UNDERFLOW2) begin
        @(posedge RD_CLK2) begin
        $fatal(1,"\n Error: UNDERFLOW2 Happend, RESET2 THE FIFO2 FIRST \n", UNDERFLOW2 );             
        end 
     end
end

always @(*) begin    
    if (PROG_FULL_THRESH2>fifo_depth_write2-2) begin
        $fatal(1,"\n ERROR: PROG_FULL_THRESH2 is GREATER THAN fifo_depth_write2-2 \n" );             
     end
end

always @(*) begin    
    if (PROG_EMPTY_THRESH2>fifo_depth_read2-2) begin
        $fatal(1,"\n ERROR: PROG_EMPTY_THRESH2 is GREATER THAN fifo_depth_write2-2 \n" );             
     end
end


always @(posedge RESET2, posedge WR_CLK2) begin
   
        if (RESET2) begin
          fifo_wr_sync2 <= {fifo_addr_width_write2{1'b0}};
          fifo_rd_sync2 <= {fifo_addr_width_read2{1'b0}};
          EMPTY2        <= 1'b1;
          FULL2         <= 1'b0;
          ALMOST_EMPTY2 <= 1'b0;
          ALMOST_FULL2  <= 1'b0;
          PROG_EMPTY2   <= 1'b1;
          PROG_FULL2    <= 1'b0;
          OVERFLOW2     <= 1'b0;
          UNDERFLOW2    <= 1'b0;
          fwft2         <= 1'b0;
          fwft_data2    <= {READ_DATA_WIDTH2-1{1'b0}};
        end 
        else begin
          FULL2 <= wfull2;
          ALMOST_FULL2 <= al_full2;
          PROG_FULL2 <= p_full2;
          EMPTY2 <= rempty2;
          ALMOST_EMPTY2 <= al_empty2;
          PROG_EMPTY2<= p_empty2;
        end
end 

assign ram_clk_b2 = WR_CLK2;

        initial begin
          #1;
          @(RD_CLK2);
          $display("\nWarning: FIFO36K instance %m RD_CLK2 should be tied to ground when FIFO36K is configured as FIFO1_TYPE=SYNCHRONOUS.");
        end

end else if (FIFO_TYPE2=="ASYNCHRONOUS") begin : ASYNC_FIFO2

reg fwft2;

always @(RESET2) begin
  fwft2 <=0;
end

wire ram_clk_b2;
wire rempty2,al_empty2, p_empty2;


localparam DATA_WIDTH_WRITE2 = DATA_WRITE_WIDTH2;
localparam DATA_WIDTH_READ2 = DATA_READ_WIDTH2;

  localparam  fifo_depth_write2 = (DATA_WIDTH_WRITE2 <= 9) ? 2048 :
                                 1024;

  localparam  fifo_depth_read2 = (DATA_WIDTH_READ2 <= 9) ? 2048 :
                                 1024;
  
  localparam  fifo_addr_width_r2 = (DATA_WIDTH_READ2 <= 9) ? 11 :
                                  10;
  localparam  fifo_addr_width_w2 = (DATA_WIDTH_WRITE2 <= 9) ? 11 :
                                  10;

  reg [fifo_addr_width_w2-1:0] fifo_wr_addr2 = {fifo_addr_width_w2{1'b0}};
  reg [fifo_addr_width_r2-1:0] fifo_rd_addr2 = {fifo_addr_width_r2{1'b0}};

  reg [DATA_WIDTH_READ2-1:0] fwft_data2 = {DATA_WIDTH_READ2{1'b0}};
  reg [DATA_WIDTH_READ2-1:0] fwft_data_temp2 ={DATA_WIDTH_READ2{1'b0}};


  wire [31:0] ram_wr_data2;
  wire [3:0] ram_wr_parity2;

  wire [31:0] ram_rd_data2; 
  wire [3:0]  ram_rd_parity2;

assign ram_clk_b2 = RD_CLK2;

localparam W_PTR_WIDTH2 = $clog2(fifo_depth_write2);
localparam R_PTR_WIDTH2 = $clog2(fifo_depth_read2);

wire [W_PTR_WIDTH2:0] b_wptr_sync2, b_wptr_w2, b_wptr_sync_for_a2;
wire [R_PTR_WIDTH2:0] b_rptr_sync2, b_rptr_w2, b_rptr_w12, b_rptr_sync_for_a2;


always @(fifo_depth_write2) begin    
    if (PROG_FULL_THRESH2>fifo_depth_write2-2) begin
        $fatal(1,"\n ERROR: PROG_FULL_THRESH2 is GREATER THAN fifo_depth_write2-2 \n" );             
     end
end

always @(fifo_depth_read2) begin    
    if (PROG_EMPTY_THRESH2>fifo_depth_read2-2) begin
        $fatal(1,"\n ERROR: PROG_FULL_THRESH2 is GREATER THAN fifo_depth_write2-2 \n" );             
     end
end


  // Use BRAM
      TDP_RAM18KX2 #(
        .INIT1({16384{1'b0}}), // Initial Contents of memory, RAM 1
        .INIT1_PARITY({2048{1'b0}}), // Initial Contents of memory
        .WRITE_WIDTH_A1(DATA_WRITE_WIDTH2), // Write data width on port A, RAM 1 (1-18)
        .WRITE_WIDTH_B1(DATA_WRITE_WIDTH2), // Write data width on port B, RAM 1 (1-18)
        .READ_WIDTH_A1(DATA_READ_WIDTH2), // Read data width on port A, RAM 1 (1-18)
        .READ_WIDTH_B1(DATA_READ_WIDTH2), // Read data width on port B, RAM 1 (1-18)
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
        .CLK_B2(RD_CLK2), // Clock port B, RAM 2
        .BE_A2(2'b11), // Byte-write enable port A, RAM 2
        .BE_B2(2'b11), // Byte-write enable port B, RAM 2
        .ADDR_A2({b_wptr_w2, {14-fifo_addr_width_w2{1'b0}}}), // Address port A, RAM 2
        .ADDR_B2({(b_rptr_w12), {14-fifo_addr_width_r2{1'b0}}}), // Address port B, RAM 2
        .WDATA_A2(ram_wr_data2), // Write data port A, RAM 2
        .WPARITY_A2(ram_wr_parity2), // Write parity port A, RAM 2
        .WDATA_B2(16'h0000), // Write data port B, RAM 2
        .WPARITY_B2(2'b00), // Write parity port B, RAM 2
        .RDATA_A2(), // Read data port A, RAM 2
        .RPARITY_A2(), // Read parity port A, RAM 2
        .RDATA_B2(ram_rd_data2), // Read data port B, RAM 2
        .RPARITY_B2(ram_rd_parity2) // Read parity port B, RAM 2
      );


/*-------------------------------------------------------------------*/

// generate

    if(DATA_WIDTH_READ2==9) begin
      assign RD_DATA2 = (fwft2 ? fwft_data2 : {ram_rd_parity2[0], ram_rd_data2[7:0]});    
    end

    if(DATA_WIDTH_READ2==18) begin
      assign RD_DATA2 = fwft2 ? fwft_data2 : {ram_rd_parity2[1], ram_rd_data2[15:8], ram_rd_parity2[0], ram_rd_data2[7:0]};    
    end

    if(DATA_WIDTH_WRITE2==9) begin       
      assign ram_wr_data2 = {{32-DATA_WIDTH_WRITE2{1'b0}}, WR_DATA2[DATA_WIDTH_WRITE2-2:0]};
      assign ram_wr_parity2 = {3'b000, WR_DATA2[DATA_WIDTH_WRITE2-1]};
    end
    
    if(DATA_WIDTH_WRITE2==18) begin 
      assign ram_wr_data2 = {{32-DATA_WIDTH_WRITE2{1'b0}}, WR_DATA2[16:9],WR_DATA2[7:0]};
      assign ram_wr_parity2 = {2'b00, WR_DATA2[17], WR_DATA2[8]};
    end

// endgenerate
  
/*---------Write pointer synchronizer ( 2 FLOPS) logic--------------*/


reg [W_PTR_WIDTH2:0] q12,q1_a2,d_out12;

  assign b_wptr_sync2 = d_out12;
  assign b_wptr_sync_for_a2 = q1_a2;

always @(*) begin
if(RESET2) begin
       q12 <= 0;
      d_out12 <= 0;
      q1_a2 <=0;  
end

end
  always@(posedge RD_CLK2) begin
      q12 <= b_wptr_w2;
      d_out12 <= q12;
      q1_a2 <= d_out12;
  end

/*-------------------------------------------------------------------*/

/*--------- Read pointer synchronizer (2 FLOPS ) logic --------------*/

reg [R_PTR_WIDTH2:0] q22, q2_a2, d_out22;

assign b_rptr_sync2 = d_out22;
assign b_rptr_sync_for_a2 = q2_a2;

always @(*) begin
  if(RESET2) begin
      q22 <= 0;
      d_out22 <= 0;
      q2_a2 <=0;
  end
end

always@(posedge WR_CLK2) begin
      q22 <= b_rptr_w2;
      d_out22 <= q22;
      q2_a2 <= d_out22;
end

/*-------------------------------------------------------------------*/

/* ---------------- Write pointer handler logic ---------------------*/


localparam SCALING_FACTOR_WPTR2= (DATA_WIDTH_READ2>DATA_WIDTH_WRITE2)? (DATA_WIDTH_READ2/DATA_WIDTH_WRITE2):1;
localparam SCALING_FACTOR_RPTR2= (DATA_WIDTH_READ2<DATA_WIDTH_WRITE2)? (DATA_WIDTH_WRITE2/DATA_WIDTH_READ2):1;


  wire [W_PTR_WIDTH2:0] b_wptr_next2;

  reg [W_PTR_WIDTH2:0] b_wptr2;

  wire wfull2, al_full2, p_full2; 

  wire [W_PTR_WIDTH2:0] diff_ptr02, diff_ptr22, diff_ptr0_for_a2;

  assign b_wptr_next2 = b_wptr2+(WR_EN2 & !FULL2);

  assign b_wptr_w2 = b_wptr2;


  assign diff_ptr02 =(DATA_WIDTH_WRITE2>DATA_WIDTH_READ2)? /* W>R */ ((((b_wptr_next2/SCALING_FACTOR_WPTR2  >= (b_rptr_sync2/SCALING_FACTOR_RPTR2))? (b_wptr_next2/SCALING_FACTOR_WPTR2-(b_rptr_sync2/SCALING_FACTOR_RPTR2)): (b_wptr_next2/SCALING_FACTOR_WPTR2+(1<<(W_PTR_WIDTH2+1))-(b_rptr_sync2/SCALING_FACTOR_RPTR2)))))

  : (  (DATA_WIDTH_READ2>DATA_WIDTH_WRITE2)? ( /* R>W */ ((((b_wptr_next2*SCALING_FACTOR_RPTR2  >= (b_rptr_sync2*SCALING_FACTOR_WPTR2))? (b_wptr_next2*SCALING_FACTOR_RPTR2-(b_rptr_sync2*SCALING_FACTOR_WPTR2)): (b_wptr_next2*SCALING_FACTOR_RPTR2+(1<<(W_PTR_WIDTH2+1))-(b_rptr_sync2*SCALING_FACTOR_WPTR2))))) ) 

  : /* R==W */ ((((b_wptr_next2  >= (b_rptr_sync2 ))? (b_wptr_next2 - (b_rptr_sync2)): (b_wptr_next2 + (1<<(W_PTR_WIDTH2+1))-(b_rptr_sync2 ))))) );  


  assign diff_ptr0_for_a2 =(DATA_WIDTH_WRITE2>DATA_WIDTH_READ2)? /* W>R */ ((((b_wptr_next2/SCALING_FACTOR_WPTR2  >= (b_rptr_sync_for_a2/SCALING_FACTOR_RPTR2))? (b_wptr_next2/SCALING_FACTOR_WPTR2-(b_rptr_sync_for_a2/SCALING_FACTOR_RPTR2)): (b_wptr_next2/SCALING_FACTOR_WPTR2+(1<<(W_PTR_WIDTH2+1))-(b_rptr_sync_for_a2/SCALING_FACTOR_RPTR2)))))

  : (  (DATA_WIDTH_READ2>DATA_WIDTH_WRITE2)? ( /* R>W */ ((((b_wptr_next2*SCALING_FACTOR_RPTR2  >= (b_rptr_sync_for_a2*SCALING_FACTOR_WPTR2))? (b_wptr_next2*SCALING_FACTOR_RPTR2-(b_rptr_sync_for_a2*SCALING_FACTOR_WPTR2)): (b_wptr_next2*SCALING_FACTOR_RPTR2+(1<<(W_PTR_WIDTH2+1))-(b_rptr_sync_for_a2*SCALING_FACTOR_WPTR2))))) ) 

  : /* R==W */ ((((b_wptr_next2  >= (b_rptr_sync_for_a2 ))? (b_wptr_next2 - (b_rptr_sync_for_a2)): (b_wptr_next2 + (1<<(W_PTR_WIDTH2+1))-(b_rptr_sync_for_a2 ))))) );  


  // assign wfull2 = (DATA_WIDTH_WRITE2>DATA_WIDTH_READ2)? (diff_ptr02 == (1<<W_PTR_WIDTH2)) : (diff_ptr02 == (1<<R_PTR_WIDTH2) );

  assign wfull2 = (DATA_WIDTH_WRITE2>DATA_WIDTH_READ2)? (diff_ptr02 == (1<<W_PTR_WIDTH2)) : (diff_ptr02 == (1<<W_PTR_WIDTH2)   );


  assign al_full2 = (DATA_WIDTH_WRITE2>DATA_WIDTH_READ2)? (diff_ptr02 == (1<<W_PTR_WIDTH2)-1): (diff_ptr02 == ((1<<W_PTR_WIDTH2)-1) );

  assign p_full2 = (DATA_WIDTH_WRITE2>DATA_WIDTH_READ2)? (diff_ptr0_for_a2 >= ((1<<W_PTR_WIDTH2)-PROG_FULL_THRESH2+1) ) :  ( (diff_ptr0_for_a2 >= ((1<<W_PTR_WIDTH2)-PROG_FULL_THRESH2+1) ) );


  // assign diff_ptr22 = ((((b_wptr_next2*SCALING_FACTOR_WPTR2-(b_rptr_sync2/SCALING_FACTOR_RPTR2)): (b_wptr_next2/SCALING_FACTOR_WPTR2+(1<<(W_PTR_WIDTH2+1))-(b_rptr_sync2/SCALING_FACTOR_RPTR2)))))



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

      FULL2 <= wfull2;
      ALMOST_FULL2 <= al_full2;
      PROG_FULL2 <= p_full2;

    end
  end

/*---------------------------------------------------------------*/

/*-----------  READ pointer handler logic -----------------------*/



wire [R_PTR_WIDTH2:0] diff_ptr12, diff_ptr1_for_a2;
reg  [R_PTR_WIDTH2:0] b_rptr_next2, b_rptr_next_temp2, b_rptr2;


// always @(posedge RD_CLK2) begin

//     if(RESET2) begin
//       b_rptr_next2 =0;
//       b_rptr2 <=0;
//     end
//     else begin
//       if((RD_EN2 & !EMPTY2)) begin
//         if (b_rptr_next2==(1<<R_PTR_WIDTH2+1)) begin  
//           b_rptr_next2 <=0;
//         end
//         else begin
//           b_rptr_next2 <= b_rptr_next2+1;      
//         end
//       end
//     end
// end

assign b_rptr_w2 = b_rptr2;

assign b_rptr_w12 =  b_rptr_w2+1'b1;  // (RD_EN2 & b_rptr_next2=='0)? 1: b_rptr_next2+1;

assign b_rptr_next2 = b_rptr2+(RD_EN2 & !EMPTY2);


assign diff_ptr12 = (DATA_WIDTH_WRITE2 > DATA_WIDTH_READ2)?   ( ((b_wptr_sync2*SCALING_FACTOR_RPTR2) >= (b_rptr_next2*SCALING_FACTOR_WPTR2))? (b_wptr_sync2*SCALING_FACTOR_RPTR2-(b_rptr_next2*SCALING_FACTOR_WPTR2)): ((b_wptr_sync2*SCALING_FACTOR_RPTR2)+(1<<(R_PTR_WIDTH2+1))-(b_rptr_next2*SCALING_FACTOR_RPTR2)/SCALING_FACTOR_RPTR2))
 
 : ( (DATA_WIDTH_READ2 > DATA_WIDTH_WRITE2)?  (((b_wptr_sync2/SCALING_FACTOR_WPTR2) >= (b_rptr_next2/SCALING_FACTOR_RPTR2))? (b_wptr_sync2/SCALING_FACTOR_WPTR2-(b_rptr_next2/SCALING_FACTOR_RPTR2)): (b_wptr_sync2/SCALING_FACTOR_WPTR2+(1<<(R_PTR_WIDTH2+1))-(b_rptr_next2/SCALING_FACTOR_RPTR2)))  
 
 : (((b_wptr_sync2) >= (b_rptr_next2))? (b_wptr_sync2-(b_rptr_next2)): (b_wptr_sync2+(1<<(W_PTR_WIDTH2+1))-(b_rptr_next2))) )   ;

assign diff_ptr1_for_a2 = (DATA_WIDTH_WRITE2 > DATA_WIDTH_READ2)?   ( ((b_wptr_sync_for_a2*SCALING_FACTOR_RPTR2) >= (b_rptr_next2*SCALING_FACTOR_WPTR2))? (b_wptr_sync_for_a2*SCALING_FACTOR_RPTR2-(b_rptr_next2*SCALING_FACTOR_WPTR2)): ((b_wptr_sync_for_a2*SCALING_FACTOR_RPTR2)+(1<<(R_PTR_WIDTH2+1))-(b_rptr_next2*SCALING_FACTOR_RPTR2)/SCALING_FACTOR_RPTR2))
 
 : ( (DATA_WIDTH_READ2 > DATA_WIDTH_WRITE2)?  (((b_wptr_sync_for_a2/SCALING_FACTOR_WPTR2) >= (b_rptr_next2/SCALING_FACTOR_RPTR2))? (b_wptr_sync_for_a2/SCALING_FACTOR_WPTR2-(b_rptr_next2/SCALING_FACTOR_RPTR2)): (b_wptr_sync_for_a2/SCALING_FACTOR_WPTR2+(1<<(R_PTR_WIDTH2+1))-(b_rptr_next2/SCALING_FACTOR_RPTR2)))  
 
 : (((b_wptr_sync_for_a2) >= (b_rptr_next2))? (b_wptr_sync_for_a2-(b_rptr_next2)): (b_wptr_sync_for_a2+(1<<(W_PTR_WIDTH2+1))-(b_rptr_next2))) )   ;


assign rempty2= (diff_ptr12==0)?1:0;

assign al_empty2 = (diff_ptr12 ==1)? 1:0;

assign p_empty2 = (diff_ptr1_for_a2 ==PROG_EMPTY_THRESH2-1 || diff_ptr1_for_a2 <=PROG_EMPTY_THRESH2-1 )? 1:0;


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
      PROG_EMPTY2 <= p_empty2;    
      
      if(DATA_WIDTH_READ2==9) begin
        if(b_rptr2==4095 & WR_EN2==0) begin
          ALMOST_EMPTY2 <=0;
        end
        else begin
          ALMOST_EMPTY2 <= al_empty2;
        end
      end
      else begin
        ALMOST_EMPTY2 <= al_empty2;      
      end      
    end 
    
  end


/*------------------------------------------------------------------*/

/*------------- Adding logic of First word fall through ------------*/
  always @ (posedge RD_CLK2) begin
        if(RD_EN2) begin
            fwft2 =0;
        end
  end

  always @(posedge WR_CLK2) begin
      if(RESET2) begin
        fwft2 =0;
      end
      else if (EMPTY2==1 & WR_EN2==1) begin
        fwft2 = 1 ;
      end
      else begin
        fwft2 = fwft2;
      end
  end

always @(*) begin
  if(fwft2) begin
    fwft_data2 <= fwft_data_temp2;
  end
end


    always@(posedge WR_CLK2) begin
// -1
        if (DATA_WIDTH_WRITE2 >= DATA_WIDTH_READ2) begin
        
            if (EMPTY2 && WR_EN2 && !RESET2) begin

              if (DATA_WIDTH_WRITE2==18 && DATA_WIDTH_READ2==18) begin
                if(b_wptr_next2==1 || b_wptr_next2==2049) begin
                  fwft_data_temp2 <= WR_DATA2;
                end
              end
              if (DATA_WIDTH_WRITE2==9 && DATA_WIDTH_READ2==9) begin
                if(b_wptr_next2==1 || b_wptr_next2==4097) begin
                  fwft_data_temp2 <= WR_DATA2;
                end
              end

              else if (DATA_WIDTH_WRITE2==18 && DATA_WIDTH_READ2==9) begin
                if(b_wptr_next2==1 || b_wptr_next2==2049) begin
                  fwft_data_temp2 <= {{WR_DATA2[8]},{WR_DATA2[7:0]}} ;  // DEVELOP LOGIC FOR OTHER WIDTH AS WELL
                end
              end

            end
        end
// -2          
        if (DATA_WIDTH_WRITE2 == 9 && DATA_WIDTH_READ2==18) begin
            if (EMPTY2 && WR_EN2 && !RESET2) begin

              if(b_wptr_next2==1 || b_wptr_next2==4097 ) begin
                fwft_data_temp2 [7:0] <= WR_DATA2[7:0] ;
                fwft_data_temp2 [8] <= WR_DATA2[8] ;
              end
              if(b_wptr_next2==2 || b_wptr_next2==4098 ) begin
                fwft_data_temp2 [16:9] <= WR_DATA2[7:0];
                fwft_data_temp2 [17] <= WR_DATA2[8];
              end     
           end
        end
  end


/*---------------------------------------------------------------*/

/*--------- Adding logic of OVERFLOW2 and UNDERFLOW2 -----------*/

    always @(posedge WR_CLK2) begin
      if (RESET2) begin
       OVERFLOW2 <= 0;
      end
      else if (FULL2 & WR_EN2 ) begin
       OVERFLOW2 = 1;
      end
    end

    always @(posedge RD_CLK2) begin 
        if (RESET2) begin
          OVERFLOW2 <= 0;
        end
        else if(RD_EN2 & OVERFLOW2) begin
          OVERFLOW2 = 0;
        end
    end

    always @(posedge RD_CLK2) begin

      if (RESET2) begin
        UNDERFLOW2 <= 0;
      end
      else if (EMPTY2 & RD_EN2) begin
         UNDERFLOW2 = 1;
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


always @(posedge WR_CLK2) begin    
    if (OVERFLOW2) begin
        @(posedge WR_CLK2) begin
        $fatal(1,"\n Error: OVERFLOW2 Happend, RESET2 THE FIFO FIRST \n", OVERFLOW2 );             
        end 
     end
end

always @(posedge RD_CLK2) begin    
    if (UNDERFLOW2) begin
        @(posedge RD_CLK2) begin
        $fatal(1,"\n Error: UNDERFLOW2 Happend, RESET2 THE FIFO FIRST \n", UNDERFLOW2 );             
        end 
     end
end
end

endgenerate


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
