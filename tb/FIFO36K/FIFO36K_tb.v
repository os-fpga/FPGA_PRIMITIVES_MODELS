
`ifdef ASYNC_FIFO

module FIFO36K_tb();
  reg RESET; // Asynchrnous FIFO reset
  reg WR_CLK; // Write clock
  reg RD_CLK; // Read clock
  reg WR_EN; // Write enable
  reg RD_EN; // Read enable
  reg [DATA_WRITE_WIDTH-1:0] WR_DATA; // Write data
  wire [DATA_READ_WIDTH-1:0] RD_DATA; // Read data
  wire EMPTY; // FIFO empty flag
  wire FULL; // FIFO full flag
  wire ALMOST_EMPTY; // FIFO almost empty flag
  wire ALMOST_FULL; // FIFO almost full flag
  wire PROG_EMPTY; // FIFO programmable empty flag
  wire PROG_FULL; // FIFO programmable full flag
  wire OVERFLOW; // FIFO overflow error flag
  wire UNDERFLOW;// FIFO underflow error flag

  parameter DATA_WRITE_WIDTH = 9; // FIFO data width (1-36)
  parameter DATA_READ_WIDTH = 36; // FIFO data width (1-36)
  reg do_overflow =0;
  reg do_underflow =0;

  parameter FIFO_TYPE = "ASYNCHRONOUS"; // Synchronous or Asynchronous data transfer (SYNCHRONOUS/ASYNCHRONOUS)
  parameter [11:0] PROG_EMPTY_THRESH = 12'h200; // 12-bit Programmable empty depth
  parameter [11:0] PROG_FULL_THRESH = 12'h200; // 12-bit Programmable full depth

  // parameter DATA_WIDTH = 36;
  localparam DEPTH_WRITE = (DATA_WRITE_WIDTH <= 9) ? 4096 :
  (DATA_WRITE_WIDTH <= 18) ? 2048 :
  1024;

  localparam DEPTH_READ = (DATA_READ_WIDTH <= 9) ? 4096 :
  (DATA_READ_WIDTH <= 18) ? 2048 :
  1024;
  // predictor output
  reg [DATA_WRITE_WIDTH-1:0] exp_dout;

parameter W_PTR_WIDTH = $clog2(DEPTH_WRITE);
parameter R_PTR_WIDTH = $clog2(DEPTH_READ);

reg [8:0] pop_data1;
reg [8:0] pop_data2;
reg [8:0] pop_data3;
reg [8:0] pop_data4;

  // testbench variables
  integer error=0;
  integer count_n=0;
  integer count_enteries_push=0;
  integer count_enteries_pop=0;
  integer fwft_data1=0;
  integer fwft_data2=0;
  integer fwft_data3=0;
  integer fwft_data4=0;

  // integer rden_cnt=0;
  integer wren_cnt=0;
  reg [8:0] local_queue [$];
  integer fifo_number;
  bit debug=0;

  //clock//
  initial begin
    WR_CLK = 1'b0;
    forever #573 WR_CLK = ~WR_CLK;
end

  initial begin
      RD_CLK = 1'b0;
      forever #123 RD_CLK = ~RD_CLK;
  end

   FIFO36K #(
    .DATA_WRITE_WIDTH(DATA_WRITE_WIDTH),
    .DATA_READ_WIDTH  (DATA_READ_WIDTH),
    .FIFO_TYPE(FIFO_TYPE),
    .PROG_EMPTY_THRESH(PROG_EMPTY_THRESH), // 12-bit Programmable empty depth
    .PROG_FULL_THRESH(PROG_FULL_THRESH) // 12-bit Programmable full depth
   ) fifo36k_inst(
    .RESET(RESET), // Asynchrnous FIFO reset
    .WR_CLK(WR_CLK), // Write clock
    .RD_CLK(RD_CLK), // Read clock
    // .RD_CLK('h0), // Read clock
    .WR_EN(WR_EN), // Write enable
    .RD_EN(RD_EN), // Read enable
    .WR_DATA(WR_DATA), // Write data
    .RD_DATA(RD_DATA), // Read data
    .EMPTY(EMPTY), // FIFO empty flag
    .FULL(FULL), // FIFO full flag
    .ALMOST_EMPTY(ALMOST_EMPTY), // FIFO almost empty flag
    .ALMOST_FULL(ALMOST_FULL), // FIFO almost full flag
    .PROG_EMPTY(PROG_EMPTY), // FIFO programmable empty flag
    .PROG_FULL(PROG_FULL), // FIFO programmable full flag
    .OVERFLOW(OVERFLOW), // FIFO overflow error flag
    .UNDERFLOW(UNDERFLOW) // FIFO underflow error flag
    );

  initial begin
    $display("FIFO TYPE: %s---------------------", FIFO_TYPE);
    $display("PROG_EMPTY_THRESH = %d", PROG_EMPTY_THRESH);
    $display("PROG_FULL_THRESH = %d", PROG_FULL_THRESH);
    $display("--------------------------------------------");
    $display("check_flags");
    $display("--------------------------------------------");
    check_flags();

    test_status(error);
    #2;
    $finish();
  end

integer idx=0;
integer WgtR_Ratio=0;
integer RgtW_Ratio=0;
integer prog_f=0;
bit count_clk=0;
bit count_clk1=0;
bit check=0;

  initial begin
    

    // $dumpvars(0,cpu_tb.cpu0.cpu_dp.cpu_regs.data[idx]);
    $dumpfile("wave.vcd"); 
    $dumpvars(0,FIFO36K_tb);
    
    // $dumpvars(0,FIFO36K_tb.fifo36k_inst.b_rptr);
    // $dumpvars(0,FIFO36K_tb.fifo36k_inst.b_wptr);

    for (int idx = 0; idx < 10; idx = idx + 1)
    $dumpvars(0,FIFO36K_tb.fifo36k_inst.ASYNCRONOUS.FIFO_RAM_inst.RAM_DATA[idx]);
    // $dumpvars(0,FIFO36K_tb.fifo36k_inst.FIFO_RAM_inst.RAM_DATA);

    // $dumpvars(0,FIFO36K_tb.fifo36k_inst.g_wptr_sync);
    // $dumpvars(0,FIFO36K_tb.fifo36k_inst.g_rptr_next);
  end

task rd_cycle_d();
    repeat(3)@(posedge RD_CLK);
    @(negedge RD_CLK);
endtask

task wr_cycle_d();
    repeat(3)@(posedge WR_CLK);
    @(negedge WR_CLK);
endtask

task check_flags();
    integer i;
    // resetting ptrs
    $display("--------------------------------------------");
    $display("CHECK FLAGS: RESET PTRS---------------------");
    WR_EN = 0;
    RD_EN = 0;
    RESET = 1;
    repeat(2) @(posedge WR_CLK);
    repeat(2) @(posedge WR_CLK);
    RESET = 0;
//Assertion empty_ewm_fifo_flags failed!
if(PROG_EMPTY_THRESH>0) begin
    if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b1010_0000)
      begin $display("ERROR: EMPTY AND PROG EMPTY ARE NOT ASSERTED IN START"); error=error+1; end
    end
    else begin
    if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b1000_0000)
      begin $display("ERROR: EMPTY SHOULD BE ASSERTED IN START"); error=error+1; end
    end
    
    $display("CHECK FLAGS: Checking Flags on Each PUSH/POP Operation---------------------");


    assign WgtR_Ratio = (DATA_READ_WIDTH>=DATA_WRITE_WIDTH)?  1: DATA_WRITE_WIDTH/DATA_READ_WIDTH; // For example ? = 4
    assign RgtW_Ratio = (DATA_WRITE_WIDTH>=DATA_READ_WIDTH)?  1: DATA_READ_WIDTH/DATA_WRITE_WIDTH; // For example ? = 4

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

   
/////////////     //          //       /////////    //      //                       ////////////     //////////     ////////////   
//         //     //          //    //              //      //                       //         //   //       //     //         //
//         //     //          //    //              //      //                       //         //   //       //     //         //
//         //     //          //    //              //////////    =============      //         //   //       //     //         //
/////////////     //          //    ////////////    //      //    =============      ////////////    //       //     ////////////
//                //          //               //   //      //                       //              //       //     // 
//                //          //               //   //      //                       //              //       //     // 
//                  // // // //     ////////////    //      //                       //              ///////////     // 
//                     

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

if(DATA_WRITE_WIDTH==DATA_READ_WIDTH) begin

// Empty De Assert
    for (int i=0; i<DEPTH_WRITE; i++) begin

     
      if(i==0) begin

          fork 
          begin
           push();
          end 
          begin
            wait(count_clk); 
            repeat(3)@(posedge RD_CLK);
            @(negedge RD_CLK);                                   
          end
          join;
          if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0110_0000) begin      
                  begin  $display("ERROR PUSH: EMPTY SHOULD BE DE-ASSERTED )"); error=error+1; end
          end
          count_clk=0;
      end

      if(i==1) begin

          fork 
          begin
           push();
          end 
          begin
            wait(count_clk); 
            repeat(3)@(posedge RD_CLK);
            @(negedge RD_CLK);                                   
            if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0010_0000) begin      
            begin $display("ERROR PUSH: ALMOST EMPTY SHOULD BE DE-ASSERTED AFTER 2nd PUSH"); error=error+1; end
          end
          end
          begin
            if(PROG_EMPTY_THRESH==2) begin
            wait(count_clk); 
            repeat(4)@(posedge RD_CLK);
            @(negedge RD_CLK); 
            if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0000_0000) begin      
                    begin $display("ERROR PUSH: ALL FLAGS SHOULD BE DE-ASSERTED"); error=error+1; end
            end                          
            end
          end
          join;
          count_clk=0;

      end

      if(i>1 & i<PROG_EMPTY_THRESH-1) begin
       push();
       count_clk=0;
      end

      if(i==PROG_EMPTY_THRESH-1) begin

          fork 
          begin
           push();
          end 
          begin
            wait(count_clk); 
            repeat(4)@(posedge RD_CLK);
            @(negedge RD_CLK);                                   
            if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0000_0000) begin      
            begin $display("ERROR PUSH: ALL FLAGS SHOULD BE DE-ASSERTED"); error=error+1; end
          end
          end
          join;
          count_clk=0;
      end

      if(i>PROG_EMPTY_THRESH-1 & i< DEPTH_WRITE - PROG_FULL_THRESH) begin
       push();
       count_clk=0;
      end

      if(i==DEPTH_WRITE- PROG_FULL_THRESH) begin

       push();
       count_clk=0;
          if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0000_0010) begin      
              begin $display("ERROR PUSH: ONLY PROG_FULL SHOULD BE ASSERTED"); error=error+1; end
          end
                               
      end

      if(i>DEPTH_WRITE- PROG_FULL_THRESH & i< DEPTH_WRITE -2) begin
       push();
      end

      if(i==DEPTH_WRITE- 2) begin
          push();
          count_clk=0;
          if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0000_0110) begin      
              begin $display("ERROR PUSH: PROG_FULL AND ALMOST FULL SHOULD BE ASSERTED ONLY"); error=error+1; end
          end                     
      end

      if(i==DEPTH_WRITE- 1) begin
          push();
          count_clk=0;
          if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0000_1010) begin      
              begin $display("ERROR PUSH: PROG_FULL AND FULL SHOULD BE ASSERTED ONLY"); error=error+1; end
          end                     
      end

      if(do_overflow) begin
        repeat(1) begin
          push();
        end
  end
  end

end



//***********************************************************************************************************************//

if(DATA_READ_WIDTH == DATA_WRITE_WIDTH) begin

// FULL DE-ASSERT

  for (i=0; i<DEPTH_READ; i++) begin

        
        if(i==0) begin
          
          compare_pop_data();
          fork 
          begin
           @(negedge RD_CLK);
           RD_EN=1;
           @(posedge RD_CLK);
           count_clk=1;
           @(negedge RD_CLK);
           RD_EN=0;
           count_enteries_pop=count_enteries_pop+1;
           compare_pop_data();
          end 
          begin
            wait(count_clk); 
            repeat(3)@(posedge WR_CLK);
            @(negedge WR_CLK);                                   
          end
          join;
          if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0000_0110) begin
            begin $display("ERROR POP: ONLY PROG FULL and ALMOST FULL SHOULD BE ASSERTED %0b", {EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW}); error=error+1; end
          end
           count_clk=0;
        end


        if(i==1) begin
       
          fork 
          begin
           @(negedge RD_CLK);
           RD_EN=1;
           @(posedge RD_CLK);
           count_clk=1;
           @(negedge RD_CLK);
           RD_EN=0;
           count_enteries_pop=count_enteries_pop+1;
           compare_pop_data();
          end 
          begin
            wait(count_clk); 
            repeat(3)@(posedge WR_CLK);
            @(negedge WR_CLK);                                   
          end
          join;
          if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0000_0010) begin
            begin $display("ERROR POP: ONLY PROG FULL SHOULD BE ASSERTED %0b", {EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW}); error=error+1; end
          end
          count_clk=0;

        end

        if(i>1 & i<PROG_FULL_THRESH-1) begin
          pop();
          count_enteries_pop=count_enteries_pop+1;
          compare_pop_data();
        end
  
        if(i==PROG_FULL_THRESH-1) begin
          fork 
          begin
           @(negedge RD_CLK);
           RD_EN=1;
           @(posedge RD_CLK);
           count_clk=1;
           @(negedge RD_CLK);
           RD_EN=0;
          count_enteries_pop=count_enteries_pop+1;
          compare_pop_data();
          end 
          begin
            wait(count_clk); 
            repeat(4)@(posedge WR_CLK);
            @(negedge WR_CLK);                                   
          end
          join;
          if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0000_0000) begin
            begin $display("ERROR POP: ALL FLAGS SHOULD BE DEASSERTED %0b", {EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW}); error=error+1; end
          end
           count_clk=0;
        end

       if(i>PROG_FULL_THRESH-1 & i < DEPTH_READ-PROG_EMPTY_THRESH) begin
          pop();
          count_enteries_pop=count_enteries_pop+1;
          compare_pop_data();
        end        

        if(i==DEPTH_READ-PROG_EMPTY_THRESH)  begin
          fork 
          begin
           @(negedge RD_CLK);
           RD_EN=1;
           @(posedge RD_CLK);
           count_clk=1;
           @(negedge RD_CLK);
           RD_EN=0;
           count_enteries_pop=count_enteries_pop+1;
           compare_pop_data();

          end 
          begin
            wait(count_clk);
            @(negedge RD_CLK); 
            if(PROG_EMPTY_THRESH >2) begin
              if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0010_0000) begin
                begin $display("ERROR POP: ONLY PROG EMPTY SHOULD BE ASSERTED %0b", {EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW}); error=error+1; end
              end
            end
            if(PROG_EMPTY_THRESH ==2) begin
              if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0110_0000) begin
                begin $display("ERROR POP: ONLY PROG EMPTY  AND ALMOST EMPTY SHOULD BE ASSERTED %0b", {EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW}); error=error+1;  $display ("??????"); end
              end
            end
          end
          join;
           count_clk=0;
        end

       if(i>DEPTH_READ-PROG_EMPTY_THRESH & i < DEPTH_READ-1) begin
          pop();
          count_enteries_pop=count_enteries_pop+1;
          compare_pop_data();
        end 


        if(i==DEPTH_READ-1)  begin
          fork 
          begin
           @(negedge RD_CLK);
           RD_EN=1;
           @(posedge RD_CLK);
           count_clk=1;
           @(negedge RD_CLK);
           RD_EN=0;
          count_enteries_pop=count_enteries_pop+1;
          compare_pop_data();
          end 
          begin
            wait(count_clk);
            @(negedge RD_CLK); 
            if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b1010_0000) begin
              begin $display("ERROR : Only PROG_EMPTY AND ALMOST EMPTED SHOULD BE ASSERTED %0b", {EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW}); error=error+1; end
            end
          end
          join;
           count_clk=0;
        end

      if(do_underflow) begin
          @(negedge RD_CLK);
           RD_EN=1;
           @(posedge RD_CLK);
           count_clk=1;
           @(negedge RD_CLK);
           RD_EN=0;
          count_enteries_pop=count_enteries_pop+1;
          compare_pop_data();
      end


  end
end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

   
/////////////     //          //       /////////    //      //                       ////////////     //////////     ////////////   
//         //     //          //    //              //      //                       //         //   //       //     //         //
//         //     //          //    //              //      //                       //         //   //       //     //         //
//         //     //          //    //              //////////    =============      //         //   //       //     //         //
/////////////     //          //    ////////////    //      //                ||     ////////////    //       //     ////////////
//                //          //               //   //      //                ||     //              //       //     // 
//                //          //               //   //      //    =============      //              //       //     // 
//                  // // // //     ////////////    //      //                       //              ///////////     // 
//                     

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



if(  DATA_WRITE_WIDTH > DATA_READ_WIDTH  ) begin

for (int i=0; i<DEPTH_WRITE; i++) begin  //DEPTH_WRITE

  if(i==0) begin

          fork 
          begin
           push();
          end 
          begin
            wait(count_clk); 
            repeat(3)@(posedge RD_CLK);
            @(negedge RD_CLK);                                   
                    if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0010_0000) begin      
                  begin  $display("ERROR PUSH: ONLY ALMOST EMPTY SHOULD BE ASSERTED"); error=error+1; end
          end
          end
          begin
            
          if(PROG_EMPTY_THRESH <= (i+1)*WgtR_Ratio ) begin
          wait(count_clk);   
          repeat(4)@(posedge RD_CLK);
          @(negedge RD_CLK);
          if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0000_0000) begin      
                begin $display("ERROR PUSH: ALL FLAGS DEASSERTED"); error=error+1; end
          end
          end
          end
          join;
          count_clk=0;
  end
  
  if(i>0 & i<DEPTH_WRITE-PROG_FULL_THRESH) begin

      if(PROG_EMPTY_THRESH < WgtR_Ratio*(i+1) & PROG_EMPTY_THRESH > WgtR_Ratio*(i+2)) begin
            fork 
              begin
              push();
              end 
              begin
                wait(count_clk); 
                repeat(4)@(posedge RD_CLK);
                @(negedge RD_CLK);                                   
                        if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0000_0000) begin      
                      begin  $display("ERROR PUSH: ALL DEASSERTED"); error=error+1; end
              end
              end
              join;
              count_clk=0;
        end
        else begin
            push();
            count_clk=0;
        end
  end


  if(i==DEPTH_WRITE-PROG_FULL_THRESH) begin

          fork 
          begin
           push();
          end 
          begin
            wait(count_clk);  
            @(negedge WR_CLK);
            if(PROG_FULL_THRESH >2) begin                                
              if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0000_0010) begin      
              begin  $display("ERROR PUSH: ONLY PROG FULL SHOULD BE ASSERTED"); error=error+1; end
              end
            end
            else begin
              if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0000_0110) begin      
              begin  $display("ERROR PUSH: ONLY PROG FULL AND ALMOST FULL SHOULD BE ASSERTED"); error=error+1; end
              end
            end
          end
          join;
          count_clk=0;
  end

  if(i>DEPTH_WRITE-PROG_FULL_THRESH & i<DEPTH_WRITE-2) begin
          push();
          count_clk=0;
  end

  if(i==DEPTH_WRITE-2) begin

          fork 
          begin
           push();
          end 
          begin
            wait(count_clk);  
            @(negedge WR_CLK);                                
              if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0000_0110) begin      
              begin  $display("ERROR PUSH: ONLY PROG FULL AND ALMOST FULL SHOULD BE ASSERTED"); error=error+1; end
          end
          end
          join;
          count_clk=0;
  end

  if(i==DEPTH_WRITE-1) begin

          fork 
          begin
           push();
          end 
          begin
            wait(count_clk);  
            @(negedge WR_CLK);                                
              if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0000_1010) begin      
              begin  $display("ERROR PUSH: ONLY PROG FULL AND FULL SHOULD BE ASSERTED"); error=error+1; end
          end
          end
          join;
          count_clk=0;
  end

  if(do_overflow) begin
    repeat(1) begin
      push();
    end
  end

end

end

//*******************************************************************************************************************//

if(DATA_READ_WIDTH < DATA_WRITE_WIDTH) begin

// FULL DE-ASSERT

  for (int i=0; i<DEPTH_READ; i++) begin


        if(i<WgtR_Ratio-1) begin
          compare_pop_data();
          pop();
          count_enteries_pop=count_enteries_pop+1;
        end
        
        if(i==WgtR_Ratio-1) begin
          
          compare_pop_data();
          fork 
          begin
           @(negedge RD_CLK);
           RD_EN=1;
           @(posedge RD_CLK);
           count_clk=1;
           @(negedge RD_CLK);
           RD_EN=0;
           count_enteries_pop=count_enteries_pop+1;
           compare_pop_data();
          end 
          begin
            wait(count_clk); 
            repeat(3)@(posedge WR_CLK);
            @(negedge WR_CLK);                                   
          end
          join;
          if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0000_0110) begin
            begin $display("ERROR POP: ONLY PROG FULL and ALMOST FULL SHOULD BE ASSERTED %0b", {EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW}); error=error+1; end
          end
           count_clk=0;
        end

        if(i>WgtR_Ratio-1 & i <2*WgtR_Ratio-1) begin
          pop();
          count_enteries_pop=count_enteries_pop+1;
          compare_pop_data();
        end
        
        if(i==2*WgtR_Ratio-1) begin
          
          fork 
          begin
           @(negedge RD_CLK);
           RD_EN=1;
           @(posedge RD_CLK);
           count_clk=1;
           @(negedge RD_CLK);
           RD_EN=0;
           count_enteries_pop=count_enteries_pop+1;
           compare_pop_data();
          end 
          begin
            wait(count_clk); 
            repeat(3)@(posedge WR_CLK);
            @(negedge WR_CLK);                                   
          end
          join;
          if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0000_0010) begin
            begin $display("ERROR POP: ONLY PROG FULL SHOULD BE ASSERTED %0b", {EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW}); error=error+1; end
          end
          count_clk=0;
        end


        if(i >2*WgtR_Ratio-1 & i < (PROG_FULL_THRESH*WgtR_Ratio)-1) begin
          pop();
          count_enteries_pop=count_enteries_pop+1;
          compare_pop_data();
        end
        

        if(i==(PROG_FULL_THRESH*WgtR_Ratio)-1) begin
          fork 
          begin
           @(negedge RD_CLK);
           RD_EN=1;
           @(posedge RD_CLK);
           count_clk=1;
           @(negedge RD_CLK);
           RD_EN=0;
          count_enteries_pop=count_enteries_pop+1;
          compare_pop_data();
          end 
          begin
            wait(count_clk); 
            repeat(4)@(posedge WR_CLK);
            @(negedge WR_CLK);                                   
          end
          join;
          if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0000_0000) begin
            begin $display("ERROR POP: ALL FLAGS SHOULD BE DEASSERTED %0b", {EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW}); error=error+1; end
          end
           count_clk=0;
        end

     if( i> (PROG_FULL_THRESH*WgtR_Ratio)-1 & i < DEPTH_READ - (PROG_EMPTY_THRESH)) begin
          pop();
          count_enteries_pop=count_enteries_pop+1;
          compare_pop_data();
        end
        
      
        if(i==DEPTH_READ - PROG_EMPTY_THRESH)  begin
          fork 
          begin
           @(negedge RD_CLK);
           RD_EN=1;
           @(posedge RD_CLK);
           count_clk=1;
           @(negedge RD_CLK);
           RD_EN=0;
           count_enteries_pop=count_enteries_pop+1;
           compare_pop_data();
          end 
          begin
            wait(count_clk);
            @(negedge RD_CLK); 
            if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0010_0000) begin
              begin $display("ERROR POP: ONLY PROG EMPTY SHOULD BE ASSERTED %0b", {EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW}); error=error+1; end
            end
          end
          join;
           count_clk=0;
        end

     if( i> DEPTH_READ - PROG_EMPTY_THRESH & i < DEPTH_READ -2 ) begin
          pop();
          count_enteries_pop=count_enteries_pop+1;
          compare_pop_data();
        end
        
        if(i==DEPTH_READ-2)  begin
          fork 
          begin
           @(negedge RD_CLK);
           RD_EN=1;
           @(posedge RD_CLK);
           count_clk=1;
           @(negedge RD_CLK);
           RD_EN=0;
           count_enteries_pop=count_enteries_pop+1;
           compare_pop_data();

          end 
          begin
            wait(count_clk);
            @(negedge RD_CLK); 
            if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0110_0000) begin
              begin $display("ERROR POP: Only PROG_EMPTY AND ALMOST EMPTED SHOULD BE ASSERTED %0b", {EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW}); error=error+1; end
            end
          end
          join;
           count_clk=0;
        end

        if(i==DEPTH_READ-1)  begin
          fork 
          begin
           @(negedge RD_CLK);
           RD_EN=1;
           @(posedge RD_CLK);
           count_clk=1;
           @(negedge RD_CLK);
           RD_EN=0;
          count_enteries_pop=count_enteries_pop+1;
          compare_pop_data();
          end 
          begin
            wait(count_clk);
            @(negedge RD_CLK); 
            if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b1010_0000) begin
              begin $display("ERROR POP: EMPTY AND PROG_EMPTY SHOULD BE DE_ASSERTED ONLY %0b", {EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW}); error=error+1; end
            end
          end
          join;
           count_clk=0;
        end

      if(do_underflow) begin
          @(negedge RD_CLK);
           RD_EN=1;
           @(posedge RD_CLK);
           count_clk=1;
           @(negedge RD_CLK);
           RD_EN=0;
          count_enteries_pop=count_enteries_pop+1;
          compare_pop_data();
      end

  end

end



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

   
/////////////     //          //       /////////    //      //                       ////////////     //////////     ////////////   
//         //     //          //    //              //      //                       //         //   //       //     //         //
//         //     //          //    //              //      //                       //         //   //       //     //         //
//         //     //          //    //              //////////    =============      //         //   //       //     //         //
/////////////     //          //    ////////////    //      //    ||                 ////////////    //       //     ////////////
//                //          //               //   //      //    ||                 //              //       //     // 
//                //          //               //   //      //    =============      //              //       //     // 
//                  // // // //     ////////////    //      //                       //              ///////////     // 
//                     

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



if(DATA_WRITE_WIDTH < DATA_READ_WIDTH) begin

// Empty De Assert
      repeat(RgtW_Ratio) begin  // 1-4
        push();
        count_clk=0;
      end
      rd_cycle_d();
      if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0110_0000) begin      
              begin $display("ERROR PUSH: PROG_EMPTY AND ALMOST EMPTY SHOULD BE ASSERTED"); error=error+1; end
      end

// Almost Empty deassert
      repeat(RgtW_Ratio) begin // 5-8
          push();
        count_clk=0;

        end
      rd_cycle_d();
      if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0010_0000) begin      
              begin $display("ERROR PUSH: ONLY PROG EMPTY SHOULD BE ASSERTED"); error=error+1; end
      end

// prog empty de asset // 9-16
    for (int i=RgtW_Ratio; i<(RgtW_Ratio*PROG_EMPTY_THRESH)- RgtW_Ratio+1; i++ ) begin
      push();
        count_clk=0;    
    end
    // if(count>1) begin
    repeat(4)@(posedge RD_CLK);
    @(negedge RD_CLK);
    // end
    if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0000_0000) begin
            begin $display("ERROR PUSH: ALL FLAGS SHOULD BE DE ASSERTED"); error=error+1; end
    end

// prog full assert // 17-4980
    for (int i= (RgtW_Ratio*PROG_EMPTY_THRESH)- RgtW_Ratio+1; i< ( DEPTH_WRITE  - PROG_FULL_THRESH - (RgtW_Ratio-1) ); i++ ) begin
      push();
      count_clk=0;
    end
    // @(negedge RD_CLK);
    if(PROG_FULL_THRESH !=2) begin
    if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0000_0010) begin
            begin $display("ERROR PUSH: ONLY PROG FULL SHOULD BE ASSERTED"); error=error+1; end
    end
    end

    if(PROG_FULL_THRESH ==2) begin
    if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0000_0110) begin
            begin $display("ERROR PUSH: ONLY PROG FULL AND ALMOST FULL SHOULD BE ASSERTED"); error=error+1; end
    end
    end


   prog_f = ( DEPTH_WRITE  - PROG_FULL_THRESH - (RgtW_Ratio-1) );

  // almost full assert 

    for (int i= prog_f ; i < ( DEPTH_WRITE  - 2 - (RgtW_Ratio-1) ); i++ ) begin
      push();
      count_clk=0;  
    end
  
    if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0000_0110) begin
      begin $display("ERROR PUSH: ONLY PROG FULL AND ALMOST FULL SHOULD BE ASSERTED %0b", {EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW}); error=error+1; end
    end

  // full assert

   repeat(1) begin
    push();
    count_clk=0;
   end

    if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0000_1010) begin
      begin $display("ERROR PUSH: ONLY PROG FULL AND FULL SHOULD BE ASSERTED %0b", {EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW}); error=error+1; end
    end


// overflow

if(do_overflow) begin
   repeat(1) begin
    push();
    count_clk=0;
   end
end

end


//*****************************************************************************************************************//


if(DATA_READ_WIDTH > DATA_WRITE_WIDTH) begin

// FULL DE-ASSERT

  for (int i=0; i<DEPTH_READ; i++) begin


      if(i==0 ) begin
          compare_pop_data();
          fork begin
           @(negedge RD_CLK);
           RD_EN=1;
           @(posedge RD_CLK);
           count_clk=1;
           @(negedge RD_CLK);
           RD_EN=0;
          count_enteries_pop=count_enteries_pop+1;
          compare_pop_data();
          end 
          begin
            wait(count_clk); 
            repeat(3)@(posedge WR_CLK);
            @(negedge WR_CLK);                                   
          end
          begin

          if(PROG_FULL_THRESH<=1*RgtW_Ratio) begin
            wait(count_clk); 
            repeat(4)@(posedge WR_CLK);
                @(negedge WR_CLK);              
          
              if(PROG_FULL !== 1'b0) begin
                begin $display("ERROR POP: PROG FULL BE DE ASSRTED %0b", {EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW}); error=error+1; end            
              end
          end  

          end

          join;
          if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,OVERFLOW} !== 7'b0000_000) begin
            begin   $display("ERROR POP: ALL FLAGS SHOULD BE DE-ASSERTED %0b", {EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW}); error=error+1; end
          end
          count_clk=0;
      end

  if(i>0 & i<DEPTH_READ-PROG_EMPTY_THRESH) begin

      if(PROG_FULL_THRESH < RgtW_Ratio*(i+1) & PROG_FULL_THRESH > RgtW_Ratio*(i+2)) begin
            fork 
              begin
              @(negedge RD_CLK);
              RD_EN=1;
              @(posedge RD_CLK);
              count_clk=1;
              @(negedge RD_CLK);
              RD_EN=0;
              count_enteries_pop=count_enteries_pop+1;
              compare_pop_data();
              end 
              begin
                wait(count_clk); 
                repeat(4)@(posedge WR_CLK);
                @(negedge WR_CLK);                                   
                        if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0000_0000) begin      
                      begin  $display("ERROR PUSH: ONLY PROG FULL AND ALMOST FULL SHOULD BE ASSERTED"); error=error+1; end
              end
              end
              join;
              count_clk=0;
        end
        else begin
            pop();
            count_enteries_pop=count_enteries_pop+1;
            compare_pop_data();  
            count_clk=0;
        end
  end


  if(i==DEPTH_READ-PROG_EMPTY_THRESH) begin

          fork 
          begin
              @(negedge RD_CLK);
              RD_EN=1;
              @(posedge RD_CLK);
              count_clk=1;
              @(negedge RD_CLK);
              RD_EN=0;
            count_enteries_pop=count_enteries_pop+1;
            compare_pop_data();  
          end 
          begin
            wait(count_clk);  
            @(negedge RD_CLK);
            if(PROG_EMPTY_THRESH >2) begin                                
              if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0010_0000) begin      
              begin  $display("ERROR POP: ONLY PROG EMPTY SHOULD BE ASSERTED"); error=error+1; end
              end
            end
            else begin
              if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0110_0000) begin      
              begin  $display("ERROR POP: ONLY PROG EMPTY AND ALMOST EMPTY SHOULD BE ASSERTED"); error=error+1; end
              end
            end
          end
          join;
          count_clk=0;
  end


  if(i>DEPTH_READ-PROG_EMPTY_THRESH & i <DEPTH_READ-2) begin


              @(negedge RD_CLK);
              RD_EN=1;
              @(posedge RD_CLK);
              count_clk=1;
              @(negedge RD_CLK);
              RD_EN=0;
            count_enteries_pop=count_enteries_pop+1;
            compare_pop_data(); 
            count_clk=0; 
  end

  if(i==DEPTH_READ-2) begin

          fork 
          begin
              @(negedge RD_CLK);
              RD_EN=1;
              @(posedge RD_CLK);
              count_clk=1;
              @(negedge RD_CLK);
              RD_EN=0;
            count_enteries_pop=count_enteries_pop+1;
            compare_pop_data();  
          end 
          begin
            wait(count_clk);  
            @(negedge RD_CLK);
              if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b0110_0000) begin      
              begin  $display("ERROR POP: ONLY PROG EMPTY AND ALMOST EMPTY SHOULD BE ASSERTED"); error=error+1; end
              end
          end
          join;
          count_clk=0;
  end
  
    if(i==DEPTH_READ-1) begin

          fork 
          begin
              @(negedge RD_CLK);
              RD_EN=1;
              @(posedge RD_CLK);
              count_clk=1;
              @(negedge RD_CLK);
              RD_EN=0;
            count_enteries_pop=count_enteries_pop+1;
            compare_pop_data();  
          end 
          begin
            wait(count_clk);  
            @(negedge RD_CLK);
              if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b1010_0000) begin      
              begin  $display("ERROR POP: ONLY PROG EMPTY AND EMPTY SHOULD BE ASSERTED"); error=error+1; end
              end
          end
          join;
          count_clk=0;
  end

      if(do_underflow) begin
          @(negedge RD_CLK);
           RD_EN=1;
           @(posedge RD_CLK);
           count_clk=1;
           @(negedge RD_CLK);
           RD_EN=0;
          count_enteries_pop=count_enteries_pop+1;
          compare_pop_data();
      end


end
end
endtask : check_flags 

task push();
      @(negedge WR_CLK);
      WR_EN = 1;
      WR_DATA = $urandom_range(0, 2**DATA_WRITE_WIDTH-1);
      // WR_DATA = $random();
      @(posedge WR_CLK);
      count_clk=1;
      @(negedge WR_CLK);

/* ----------------------------------- push byte date ---------------------------------- */
// R-9 
   if (DATA_READ_WIDTH==9) begin
   
      if(DATA_WRITE_WIDTH==9) begin  // 9
    
        if (count_enteries_push==0) begin
       
           fwft_data1 = WR_DATA;
        
        end    
            local_queue.push_back({WR_DATA[8], WR_DATA[7:0]});
      end 

      else if(DATA_WRITE_WIDTH==18) begin  // 18
        
        if (count_enteries_push==0) begin
           fwft_data1 = {WR_DATA[8],WR_DATA[7:0]};
           fwft_data2 = {WR_DATA[17],WR_DATA[16:9]};
        end    
        local_queue.push_back({WR_DATA[8],WR_DATA[7:0]});  
        local_queue.push_back({WR_DATA[17],WR_DATA[16:9]});  
      end
      else begin     // 36
        if (count_enteries_push==0) begin
           fwft_data1 = {WR_DATA[8],WR_DATA[7:0]};
           fwft_data2 = {WR_DATA[17],WR_DATA[16:9]};
           fwft_data3 = {WR_DATA[26],WR_DATA[25:18]};
           fwft_data4 = {WR_DATA[35],WR_DATA[34:27]};
        end    
        local_queue.push_back({WR_DATA[8],WR_DATA[7:0]});  
        local_queue.push_back({WR_DATA[17],WR_DATA[16:9]});  
        local_queue.push_back({WR_DATA[26],WR_DATA[25:18]});  
        local_queue.push_back({WR_DATA[35],WR_DATA[34:27]});  
      end 
   end
// R-18
  if (DATA_READ_WIDTH==18) begin
   
      if(DATA_WRITE_WIDTH==9) begin  // 9
    
        if (count_enteries_push==0) begin
       
           fwft_data1 = WR_DATA;

        end

        else if (count_enteries_push==1) begin

           fwft_data2 = WR_DATA;
        
        end    
            local_queue.push_back({WR_DATA[8], WR_DATA[7:0]});
      end 

      else if(DATA_WRITE_WIDTH==18) begin  // 18
        
        if (count_enteries_push==0) begin
           fwft_data1 = {WR_DATA[8],WR_DATA[7:0]};
           fwft_data2 = {WR_DATA[17],WR_DATA[16:9]};
        end    
        local_queue.push_back({WR_DATA[8],WR_DATA[7:0]});  
        local_queue.push_back({WR_DATA[17],WR_DATA[16:9]});  
      end

      else begin     // 36
        if (count_enteries_push==0) begin
           fwft_data1 = {WR_DATA[8],WR_DATA[7:0]};
           fwft_data2 = {WR_DATA[17],WR_DATA[16:9]};
           fwft_data3 = {WR_DATA[26],WR_DATA[25:18]};
           fwft_data4 = {WR_DATA[35],WR_DATA[34:27]};
        end    
        local_queue.push_back({WR_DATA[8],WR_DATA[7:0]});  
        local_queue.push_back({WR_DATA[17],WR_DATA[16:9]});  
        local_queue.push_back({WR_DATA[26],WR_DATA[25:18]});  
        local_queue.push_back({WR_DATA[35],WR_DATA[34:27]});  
      end 
  end

// R-36

  if (DATA_READ_WIDTH==36) begin
   
      if(DATA_WRITE_WIDTH==9) begin  // 9
    
        if (count_enteries_push==0) begin
       
           fwft_data1 = WR_DATA;

        end

        else if (count_enteries_push==1) begin

           fwft_data2 = WR_DATA;
        
        end

        else if (count_enteries_push==2) begin

           fwft_data3 = WR_DATA;
        
        end 

        else if (count_enteries_push==3) begin

           fwft_data4 = WR_DATA;
        
        end     
            local_queue.push_back({WR_DATA[8], WR_DATA[7:0]});
      end 

      else if(DATA_WRITE_WIDTH==18) begin  // 18
        
        if (count_enteries_push==0) begin
           fwft_data1 = {WR_DATA[8],WR_DATA[7:0]};
           fwft_data2 = {WR_DATA[17],WR_DATA[16:9]};
        end
        else if (count_enteries_push==1) begin
           fwft_data3 = {WR_DATA[8],WR_DATA[7:0]};
           fwft_data4 = {WR_DATA[17],WR_DATA[16:9]};
        end   
        local_queue.push_back({WR_DATA[8],WR_DATA[7:0]});  
        local_queue.push_back({WR_DATA[17],WR_DATA[16:9]});  
      end

      else begin     // 36
        if (count_enteries_push==0) begin
           fwft_data1 = {WR_DATA[8],WR_DATA[7:0]};
           fwft_data2 = {WR_DATA[17],WR_DATA[16:9]};
           fwft_data3 = {WR_DATA[26],WR_DATA[25:18]};
           fwft_data4 = {WR_DATA[35],WR_DATA[34:27]};
        end    
        local_queue.push_back({WR_DATA[8],WR_DATA[7:0]});  
        local_queue.push_back({WR_DATA[17],WR_DATA[16:9]});  
        local_queue.push_back({WR_DATA[26],WR_DATA[25:18]});  
        local_queue.push_back({WR_DATA[35],WR_DATA[34:27]});  
      end 
  end

  count_enteries_push=count_enteries_push+1;

/* ----------------------------------------------------------------- */
      // $display("i== %0d ; check WR_DATA %0h; size %0d",i,WR_DATA, $size(WR_DATA));
      WR_EN=0;

endtask : push 

task compare_pop_data();

// R-9

  if (DATA_READ_WIDTH==9) begin
    
    if(DATA_WRITE_WIDTH==9) begin
        if (count_enteries_pop==4096) begin
          compare(RD_DATA[8:0], fwft_data1);
        end
        else begin
          exp_dout = local_queue.pop_front();
          compare(RD_DATA,exp_dout);
        end
    end

    if(DATA_WRITE_WIDTH==36) begin
        if (count_enteries_pop==4096) begin
          compare(RD_DATA, fwft_data1);
        end
        else begin
          exp_dout = local_queue.pop_front();
          compare(RD_DATA,exp_dout);
        end
    end

    if(DATA_WRITE_WIDTH==18) begin
        if (count_enteries_pop==4096) begin
          compare(RD_DATA, fwft_data1);
          exp_dout = local_queue.pop_front();
        end
        else begin
          exp_dout = local_queue.pop_front();
          compare(RD_DATA,exp_dout);
        end
    end

  end
///////////////////////////////////////////////////////////////////////////////////////

// R-18

  else if (DATA_READ_WIDTH==18 ) begin
    
    if(DATA_WRITE_WIDTH==9) begin
       if (count_enteries_pop==2048) begin

          compare({RD_DATA[8],RD_DATA[7:0]}, fwft_data1);
          compare({RD_DATA[17],RD_DATA[16:9]}, fwft_data2);

        end
        else begin
            pop_data1= local_queue.pop_front();
            pop_data2= local_queue.pop_front();
            compare({RD_DATA[8], RD_DATA[7:0]},   {pop_data1[8], pop_data1[7:0]});
            compare({RD_DATA[17], RD_DATA[16:9]}, {pop_data2[8], pop_data2[7:0]});
        end
    end
  
      if(DATA_WRITE_WIDTH==18) begin

       if (count_enteries_pop==2048) begin
          pop_data1= local_queue.pop_front();
          pop_data2= local_queue.pop_front();
          compare({RD_DATA[8],RD_DATA[7:0]}, fwft_data1);
          compare({RD_DATA[17],RD_DATA[16:9]}, fwft_data2);
        end
        
        else begin
          
          pop_data1= local_queue.pop_front();
          pop_data2= local_queue.pop_front();
          compare({RD_DATA[8], RD_DATA[7:0]},  {pop_data1[8], pop_data1[7:0]});
          compare({RD_DATA[17], RD_DATA[16:9]}, {pop_data2[8], pop_data2[7:0]});
        end
    end

      if(DATA_WRITE_WIDTH==36) begin

       if (count_enteries_pop==2048) begin

          compare({RD_DATA[8], RD_DATA[7:0]}, fwft_data1);
          compare({RD_DATA[17], RD_DATA[16:9]}, fwft_data2);
        end

        else begin
          pop_data1= local_queue.pop_front();
          pop_data2= local_queue.pop_front();
          compare({RD_DATA[8], RD_DATA[7:0]}, {pop_data1[8], pop_data1[7:0]});
          compare( {{RD_DATA[17], RD_DATA[16:9]}}, {{pop_data2[8], pop_data2[7:0]}});
        end
    end

  end 

///////////////////////////////////////////////////////////////////////////////////////

// R-36

  else if (DATA_READ_WIDTH==36 ) begin
    
    if(DATA_WRITE_WIDTH==9) begin

       if (count_enteries_pop==1024) begin

          compare({RD_DATA[8], RD_DATA[7:0]}, fwft_data1);
          compare({RD_DATA[17], RD_DATA[16:9]}, fwft_data2);
          compare({RD_DATA[26], RD_DATA[25:18]}, fwft_data3);
          compare({RD_DATA[35], RD_DATA[34:27]}, fwft_data4);

        end

        else begin
            pop_data1= local_queue.pop_front();
            pop_data2= local_queue.pop_front();
            pop_data3= local_queue.pop_front();
            pop_data4= local_queue.pop_front();
            compare({RD_DATA[8], RD_DATA[7:0]},  {pop_data1[8], pop_data1[7:0]});
            compare({RD_DATA[17], RD_DATA[16:9]}, {pop_data2[8], pop_data2[7:0]});
            compare({RD_DATA[26], RD_DATA[25:18]}, {pop_data3[8], pop_data3[7:0]});
            compare({RD_DATA[35], RD_DATA[34:27]}, {pop_data4[8], pop_data4[7:0]});
        //  $display("count_enteries_pop %0d  RD_DATA %0h", count_enteries_pop, RD_DATA);
        end
    end
  
      if(DATA_WRITE_WIDTH==18) begin

        if (count_enteries_pop==1024) begin

          compare({RD_DATA[8],RD_DATA[7:0]}, fwft_data1);
          compare({RD_DATA[17],RD_DATA[16:9]}, fwft_data2);
          compare({RD_DATA[26],RD_DATA[25:18]}, fwft_data3);
          compare({RD_DATA[35],RD_DATA[34:27]}, fwft_data4);

        end
        else begin

          pop_data1= local_queue.pop_front(); 
          pop_data2= local_queue.pop_front();
          pop_data3= local_queue.pop_front();
          pop_data4= local_queue.pop_front();

          compare({RD_DATA[8], RD_DATA[7:0]}, {pop_data1[8], pop_data1[7:0]});
          compare({RD_DATA[17], RD_DATA[16:9]}, {pop_data2[8], pop_data2[7:0]});
          compare({RD_DATA[26], RD_DATA[25:18]}, {pop_data3[8], pop_data3[7:0]});
          compare({RD_DATA[35], RD_DATA[34:27]}, {pop_data4[8], pop_data4[7:0]});

        //  $display("count_enteries_pop %0d  RD_DATA %0h", count_enteries_pop, RD_DATA);
        end
    end

      if(DATA_WRITE_WIDTH==36) begin

       if (count_enteries_pop==1024) begin   // Last enter poped is same as first word fall through

          compare({RD_DATA[8],RD_DATA[7:0]}, fwft_data1);
          compare({RD_DATA[17],RD_DATA[16:9]}, fwft_data2);
          compare({RD_DATA[26],RD_DATA[25:18]}, fwft_data3);
          compare({RD_DATA[35],RD_DATA[34:27]}, fwft_data4);

        end
        else begin
            pop_data1= local_queue.pop_front();
            pop_data2= local_queue.pop_front();
            pop_data3= local_queue.pop_front();
            pop_data4= local_queue.pop_front();
          compare({RD_DATA[8], RD_DATA[7:0]}, {pop_data1[8], pop_data1[7:0]});
          compare({RD_DATA[17], RD_DATA[16:9]}, {pop_data2[8], pop_data2[7:0]});
          compare({RD_DATA[26], RD_DATA[25:18]}, {pop_data3[8], pop_data3[7:0]});
          compare({RD_DATA[35], RD_DATA[34:27]}, {pop_data4[8], pop_data4[7:0]});
        end
    end

  end 
endtask


task pop();


    @(negedge RD_CLK);
    RD_EN = 1;
    @(negedge RD_CLK);
    // $display("i== %0d ; check RD_DATA %0h",i,RD_DATA);
    RD_EN=0;

    // count_enteries_pop=count_enteries_pop+1;


endtask : pop




// task pop_without_comparison();
//     @(negedge RD_CLK);
//     RD_EN = 1;
//     @(negedge RD_CLK);
//     // $display("i== %0d ; check RD_DATA %0h",i,RD_DATA);
//     RD_EN=0;
//     count_enteries_pop=count_enteries_pop+1;

// endtask

  task test_status(input logic [31:0] error);
    begin
      if(error === 32'h0)
        begin
          $display(""); 
          $display(""); 
          $display("                     $$$$$$$$$$$              ");
          $display("                    $$          $$            ");
          $display("       $$$        $$              $$          ");
          $display("      $   $      $$                $$         ");
          $display("      $    $    $$    $$      $$    $$        ");
          $display("      $    $   $$    $  $    $  $    $$       ");
          $display("      $    $  $$     $  $    $  $     $$      ");
          $display("     $$    $                           $$     ");
          $display("     $    $$$$$$                       $$     ");
          $display("    $$         $ $$$$$$$$$$$$$$$$$$$$  $$     ");
          $display("   $$    $$$$$$$  $$   $  $  $    $$   $$     ");
          $display("   $            $  $$  $  $  $   $$   $$      ");
          $display("   $     $$$$$$$    $$ $  $  $  $$   $$       ");
          $display("   $            $    $$$  $  $ $$   $$        ");
          $display("   $     $$$$$$$ $$   $$$$$$$$$$   $$         ");
          $display("   $$          $   $$             $$          ");
          $display("     $$$$$$$$$$      $$         $$            ");
          $display("                       $$$$$$$$$              ");
          $display("");
          $display(""); 
          $display("----------------------------------------------");
          $display("                 TEST_PASSED                  ");
          $display("----------------------------------------------");
        end
        else   
        begin
          $display("");
          $display(""); 
          $display("           |||||||||||||");
          $display("         ||| |||      ||");
          $display("|||     ||    || ||||||||||");
          $display("||||||||      ||||       ||");
          $display("||||          ||  ||||||||||");
          $display("||||           |||         ||");
          $display("||||           ||  ||||||||||");
          $display("||||            ||||        |");
          $display("||||             |||  ||||  |");
          $display("|||||||||          ||||     |");
          $display("|||     ||             |||||");
          $display("         |||       ||||||");
          $display("           ||      ||");
          $display("            |||     ||");
          $display("              ||    ||");
          $display("               |||   ||");
          $display("                 ||   |");
          $display("                  |   |");
          $display("                  || ||");
          $display("                   |||");
          $display("");
          $display(""); 
          $display("----------------------------------------------");
          $display("                 TEST_FAILED                  ");
          $display("----------------------------------------------");
        end
    end
endtask

integer count_cmp=0;

task compare(input reg [DATA_READ_WIDTH-1:0] RD_DATA, exp_dout);

  if(RD_DATA !== exp_dout) begin
    $display("RD_DATA mismatch. DUT_Out: %0h, Expected_Out: %0h, Time: %0t", RD_DATA, exp_dout,$time);
    error = error+1;
        count_cmp = count_cmp+1;

      $display("counting of byte compared including first word fall through, count is: %0d", count_cmp);

  end
  else if(debug) begin
    $display("RD_DATA match. DUT_Out: %0h, Expected_Out: %0h, Time: %0t", RD_DATA, exp_dout,$time);
    count_cmp = count_cmp+1;
    $display("counting of byte compared including first word fall through, count is: %0d", count_cmp);
  end
endtask

endmodule

`endif 

`ifdef SYNC_FIFO
module FIFO36K_tb();
  reg RESET; // Asynchrnous FIFO reset
  reg WR_CLK; // Write clock
  reg RD_CLK; // Read clock
  reg WR_EN; // Write enable
  reg RD_EN; // Read enable
  reg [DATA_WIDTH-1:0] WR_DATA; // Write data
  wire [DATA_WIDTH-1:0] RD_DATA; // Read data
  wire EMPTY; // FIFO empty flag
  wire FULL; // FIFO full flag
  wire ALMOST_EMPTY; // FIFO almost empty flag
  wire ALMOST_FULL; // FIFO almost full flag
  wire PROG_EMPTY; // FIFO programmable empty flag
  wire PROG_FULL; // FIFO programmable full flag
  wire OVERFLOW; // FIFO overflow error flag
  wire UNDERFLOW;// FIFO underflow error flag

  parameter DATA_WIDTH = 36; // FIFO data width (1-36)
  parameter FIFO_TYPE = "SYNCHRONOUS"; // Synchronous or Asynchronous data transfer (SYNCHRONOUS/ASYNCHRONOUS)
  parameter [11:0] PROG_EMPTY_THRESH = 12'h004; // 12-bit Programmable empty depth
  parameter [11:0] PROG_FULL_THRESH = 12'h004;// 12-bit Programmable full depth

  // Testbench Variables
  parameter R_CLOCK_PERIOD = 20;
  parameter W_CLOCK_PERIOD = 20;
  // parameter DATA_WIDTH = 36;
  localparam DEPTH = (DATA_WIDTH <= 9) ? 4096 :
  (DATA_WIDTH <= 18) ? 2048 :
  1024;
  // predictor output
  reg [DATA_WIDTH-1:0] exp_dout;

  // testbench variables
  integer error=0;
  // integer rden_cnt=0;
  integer wren_cnt=0;
  reg [DATA_WIDTH-1:0] local_queue [$];
  integer fifo_number;
  bit debug=1;

  //clock//
  initial begin
    WR_CLK = 1'b0;
    forever #20 WR_CLK = ~WR_CLK;
end

// initial begin
//  RD_CLK = 1'b0;
//  forever #15 RD_CLK = ~RD_CLK;
// end

  initial begin
      RD_CLK = 1'b0;
      forever #20 RD_CLK = ~RD_CLK;
  end

   FIFO36K #(
    .DATA_WRITE_WIDTH(DATA_WIDTH),
    .DATA_READ_WIDTH(DATA_WIDTH),
    .FIFO_TYPE(FIFO_TYPE),
    .PROG_EMPTY_THRESH(PROG_EMPTY_THRESH), // 12-bit Programmable empty depth
    .PROG_FULL_THRESH(PROG_FULL_THRESH) // 12-bit Programmable full depth
   ) fifo36k_inst(
    .RESET(RESET), // Asynchrnous FIFO reset
    .WR_CLK(WR_CLK), // Write clock
    // .RD_CLK(RD_CLK), // Read clock
    .RD_CLK('h0), // Read clock
    .WR_EN(WR_EN), // Write enable
    .RD_EN(RD_EN), // Read enable
    .WR_DATA(WR_DATA), // Write data
    .RD_DATA(RD_DATA), // Read data
    .EMPTY(EMPTY), // FIFO empty flag
    .FULL(FULL), // FIFO full flag
    .ALMOST_EMPTY(ALMOST_EMPTY), // FIFO almost empty flag
    .ALMOST_FULL(ALMOST_FULL), // FIFO almost full flag
    .PROG_EMPTY(PROG_EMPTY), // FIFO programmable empty flag
    .PROG_FULL(PROG_FULL), // FIFO programmable full flag
    .OVERFLOW(OVERFLOW), // FIFO overflow error flag
    .UNDERFLOW(UNDERFLOW) // FIFO underflow error flag
    );

  initial begin
    $display("FIFO TYPE: %s---------------------", FIFO_TYPE);
    $display("PROG_EMPTY_THRESH = %d", PROG_EMPTY_THRESH);
    $display("PROG_FULL_THRESH = %d", PROG_FULL_THRESH);
    $display("--------------------------------------------");
    $display("check_flags");
    $display("--------------------------------------------");
    check_flags();

    test_status(error);
    #100;
    $finish();
  end

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0,FIFO36K_tb);
    $dumpvars(0,FIFO36K_tb.i);

    for (int idx = 0; idx < DEPTH; idx = idx + 1)
    $dumpvars(0,FIFO36K_tb.fifo36k_inst.SYNCRONOUS.FIFO_RAM_inst.RAM_DATA[idx]);
  end
    integer i;

  task check_flags();
    // resetting ptrs
    $display("--------------------------------------------");
    $display("CHECK FLAGS: RESET PTRS---------------------");
    WR_EN = 0;
    RD_EN = 0;
    RESET = 1;
    repeat(2) @(negedge WR_CLK);
    repeat(2) @(negedge WR_CLK);
    RESET = 0;
    @(posedge WR_CLK);
    @(negedge WR_CLK);

    // if(debug) $display("CHECK FLAGS: EMPTY FIFO---------------------");
    $display("CHECK FLAGS: EMPTY FIFO---------------------");
    if(PROG_EMPTY_THRESH>0) begin
    if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b1010_0000)
      begin $display("Assertion empty_ewm_fifo_flags failed!"); error=error+1; end
    end
    else begin
    if ({EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW} !== 8'b1000_0000)
      begin $display("Assertion empty_fifo_flags failed!"); error=error+1; end
    end

    $display("CHECK FLAGS: Checking Flags on Each PUSH/POP Operation---------------------");
    for(i = 1 ; i<=DEPTH; i=i+1) begin
      push();
      // wren_cnt+=1;
      if(i==(DEPTH-1)) begin
        if(~ALMOST_FULL)
          begin $display("Assertion ALMOST_FULL failed!"); error=error+1; end

      repeat(1) @(posedge WR_CLK);
      repeat(1) @(negedge WR_CLK);
    //  if (PROG_EMPTY)
    //     begin $display("Assertion PROG_EMPTY_pop_fifo_flags failed!"); error=error+1; end
      if (EMPTY)
        begin $display("Assertion EMPTY_pop_fifo_flags failed!"); error=error+1; end
      if (ALMOST_EMPTY)
        begin $display("Assertion ALMOST_EMPTY_pop_fifo_flags failed!"); error=error+1; end
      end
      else begin
        if (ALMOST_FULL)
          begin $display("Assertion notfmo_fifo_flags failed!"); error=error+1; end
      end

      if(i>(DEPTH-PROG_FULL_THRESH)) begin
        if (~PROG_FULL)
          begin $display("Assertion fwm_fifo_flags failed!"); error=error+1; end

        repeat(2) @(posedge WR_CLK);
        repeat(1) @(negedge WR_CLK);
        // if (PROG_EMPTY)
        //   begin $display("Assertion PROG_EMPTY_pop_fifo_flags failed!"); error=error+1; end
        if (EMPTY)
          begin $display("Assertion not_empty_pop_fifo_flags failed!"); error=error+1; end
        if (ALMOST_EMPTY)
          begin $display("Assertion not_epo_pop_fifo_flags failed!"); error=error+1; end
        end
      else begin
        if (PROG_FULL)
          begin $display("Assertion notfwm_fifo_flags failed!"); error=error+1; end
    end

      if(i==DEPTH) begin
        if (~FULL)
          begin $display("Assertion full_fifo_flags failed!"); error=error+1; end

        repeat(1) @(posedge WR_CLK);
        repeat(1) @(negedge WR_CLK);
        // if (PROG_EMPTY)
        //   begin $display("Assertion ewm_pop_fifo_flags failed!"); error=error+1; end
        if (EMPTY)
          begin $display("Assertion not_empty_pop_fifo_flags failed!"); error=error+1; end
        if (ALMOST_EMPTY)
          begin $display("Assertion not_epo_pop_fifo_flags failed!"); error=error+1; end
        end
      else begin
        if (FULL)
          begin $display("Assertion notfull_fifo_flags failed!"); error=error+1; end
      end

      if (OVERFLOW)
        begin $display("Assertion no_overrun_fifo_flag failed!"); error=error+1; end
      repeat(1) @(posedge WR_CLK);
      repeat(1) @(negedge WR_CLK);
      if (UNDERFLOW)
        begin $display("Assertion no_underrun_fifo_flag failed!"); error=error+1; end
    end
    for(i = DEPTH ; i>=1; i=i-1) begin
      pop();
     
      if(PROG_EMPTY_THRESH>=i) begin
        if (~PROG_EMPTY)
          begin $display("Assertion PROG_EMPTY_pop_fifo_flags failed!"); error=error+1; end
        repeat(1) @(posedge WR_CLK);
        repeat(1) @(negedge WR_CLK);
        if (ALMOST_FULL)
          begin $display("Assertion ALMOST_FULL_fifo_flags failed!"); error=error+1; end
        // if (PROG_FULL)
        //   begin $display("Assertion PROG_FULL_fifo_flags failed!"); error=error+1; end
        if (FULL)
          begin $display("Assertion FULL_fifo_flags failed!"); error=error+1; end
        end
      else begin
        if (PROG_EMPTY)
          begin $display("Assertion PROG_EMPTY_pop_fifo_flags failed!"); error=error+1; end
        end

      if(i==1) begin
        if (~EMPTY)
          begin $display("Assertion EMPTY_pop_fifo_flags failed!"); error=error+1; end
        repeat(1) @(posedge WR_CLK);
        repeat(1) @(negedge WR_CLK);
        if (ALMOST_FULL)
          begin $display("Assertion ALMOST_FULL_fifo_flags failed!"); error=error+1; end
        // if (PROG_FULL)
        //   begin $display("Assertion PROG_FULL_fifo_flags failed!"); error=error+1; end
        if (FULL)
          begin $display("Assertion FULL_fifo_flags failed!"); error=error+1; end
        end
      else begin
        if (EMPTY)
          begin $display("Assertion EMPTY_pop_fifo_flags failed!"); error=error+1; end
        end

      if(i==2) begin
        if (~ALMOST_EMPTY)
          begin $display("Assertion ALMOST_EMPTY_pop_fifo_flags failed!"); error=error+1; end
        repeat(2) @(posedge WR_CLK);
        repeat(1) @(negedge WR_CLK);
        if (ALMOST_FULL)
          begin $display("Assertion ALMOST_FULL_fifo_flags failed!"); error=error+1; end
        // if (PROG_FULL)
        //   begin $display("Assertion PROG_FULL_fifo_flags failed!"); error=error+1; end
        if (FULL)
          begin $display("Assertion FULL_fifo_flags failed!"); error=error+1; end
        end
      else begin
        if (ALMOST_EMPTY)
          begin $display("Assertion ALMOST_EMPTY_pop_fifo_flags failed!"); error=error+1; end
        end

      if (UNDERFLOW)
        begin $display("Assertion UNDERFLOW_pop_fifo_flag failed!"); error=error+1; end
      repeat(1) @(posedge WR_CLK);
      repeat(1) @(negedge WR_CLK);
      if (OVERFLOW)
        begin $display("Assertion OVERFLOW_pop_fifo_flag failed!"); error=error+1; end
    // rden_cnt+=1;
    end
    $display("CHECK FLAGS: Read from EMPTY FIFO and Check UNDERFLOW Status---------------------");
    repeat (1) begin
    pop();
    // rden_cnt+=1;
    end
    if (~UNDERFLOW)
      begin $display("Assertion UNDERFLOW_fifo_flag failed!"); error=error+1; end

    $display("CHECK FLAGS: RESET PTRS after UNDERFLOW---------------------");
    RESET = 1;
    repeat(2) @(negedge WR_CLK);
    RESET = 0;
    @(posedge WR_CLK);
    @(negedge WR_CLK);

    $display("CHECK FLAGS: Push Data Into FIFO Until FULL---------------------");
    repeat(DEPTH) push();

    $display("CHECK FLAGS: Write into a FULL FIFO and Check OVERFLOW Status---------------------");
    repeat (1)push();
    if (~OVERFLOW)
      begin $display("Assertion OVERFLOW_fifo_flag failed!"); error=error+1; end


    repeat(20) @(negedge WR_CLK);

    $display("CHECK FLAGS: RESET PTRS after OVERFLOW---------------------");
    RESET = 1;
    repeat(2) @(negedge WR_CLK);
    RESET = 0;
    @(posedge WR_CLK);
    @(negedge WR_CLK);
    $display("CHECK FLAGS: EXIT---------------------------");

  endtask

  task pop();
    @(negedge WR_CLK);
    RD_EN = 1;
    @(posedge WR_CLK);

    if (UNDERFLOW)
      $display("FIFO is UNDERFLOW, POPing is UNDERFLOW");
    else if(EMPTY) begin
      $display("FIFO is EMPTY, POPing is UNDERFLOW");
      local_queue.delete();
    end
    else begin
      exp_dout = local_queue.pop_front();
    end
    @(negedge WR_CLK);
    RD_EN =0;
    if(debug) $display(" RD_DATA:   %0h",RD_DATA, "   Time: %t",$time);

  endtask
  
  //task push(reg [32-1:0] in_din=$urandom_range(0, 2**32-1)); 
  task push(reg [DATA_WIDTH-1:0] in_din=$urandom_range(0, 2**DATA_WIDTH-1)); 
    @(negedge WR_CLK);
    WR_EN = 1; 
    WR_DATA = in_din;
    // if(debug) $display(" WR_EN = ",WR_EN, " WR_DATA = ",WR_DATA);
    if (OVERFLOW) begin
      $display("FIFO is OVERFLOW, PUSHing is OVERFLOW");
    end
    else if(FULL) begin
      $display("FIFO is FULL, PUSHing is OVERFLOW");
      local_queue.delete();
    end
    else begin
      local_queue.push_back(WR_DATA);
    end
    @(negedge WR_CLK);
    WR_EN = 0;
  endtask

  task test_status(input logic [31:0] error);
    begin
      if(error === 32'h0)
        begin
          $display(""); 
          $display(""); 
          $display("                     $$$$$$$$$$$              ");
          $display("                    $$          $$            ");
          $display("       $$$        $$              $$          ");
          $display("      $   $      $$                $$         ");
          $display("      $    $    $$    $$      $$    $$        ");
          $display("      $    $   $$    $  $    $  $    $$       ");
          $display("      $    $  $$     $  $    $  $     $$      ");
          $display("     $$    $                           $$     ");
          $display("     $    $$$$$$                       $$     ");
          $display("    $$         $ $$$$$$$$$$$$$$$$$$$$  $$     ");
          $display("   $$    $$$$$$$  $$   $  $  $    $$   $$     ");
          $display("   $            $  $$  $  $  $   $$   $$      ");
          $display("   $     $$$$$$$    $$ $  $  $  $$   $$       ");
          $display("   $            $    $$$  $  $ $$   $$        ");
          $display("   $     $$$$$$$ $$   $$$$$$$$$$   $$         ");
          $display("   $$          $   $$             $$          ");
          $display("     $$$$$$$$$$      $$         $$            ");
          $display("                       $$$$$$$$$              ");
          $display("");
          $display(""); 
          $display("----------------------------------------------");
          $display("                 TEST_PASSED                  ");
          $display("----------------------------------------------");
        end
        else   
        begin
          $display("");
          $display(""); 
          $display("           |||||||||||||");
          $display("         ||| |||      ||");
          $display("|||     ||    || ||||||||||");
          $display("||||||||      ||||       ||");
          $display("||||          ||  ||||||||||");
          $display("||||           |||         ||");
          $display("||||           ||  ||||||||||");
          $display("||||            ||||        |");
          $display("||||             |||  ||||  |");
          $display("|||||||||          ||||     |");
          $display("|||     ||             |||||");
          $display("         |||       ||||||");
          $display("           ||      ||");
          $display("            |||     ||");
          $display("              ||    ||");
          $display("               |||   ||");
          $display("                 ||   |");
          $display("                  |   |");
          $display("                  || ||");
          $display("                   |||");
          $display("");
          $display(""); 
          $display("----------------------------------------------");
          $display("                 TEST_FAILED                  ");
          $display("----------------------------------------------");
        end
    end
endtask
integer count_cmp=0;
task compare(input reg [DATA_WIDTH-1:0] RD_DATA, exp_dout);
  if(RD_DATA !== exp_dout) begin
    $display("RD_DATA mismatch. DUT_Out: %0h, Expected_Out: %0h, Time: %0t", RD_DATA, exp_dout,$time);
    $display("count compared : %0d", count_cmp);
    error = error+1;
  end
  else if(debug) begin
    $display("RD_DATA match. DUT_Out: %0h, Expected_Out: %0h, Time: %0t", RD_DATA, exp_dout,$time);
        $display("count compared : %0d", count_cmp);
  end
    count_cmp= count_cmp+1;
endtask

endmodule

`endif 
