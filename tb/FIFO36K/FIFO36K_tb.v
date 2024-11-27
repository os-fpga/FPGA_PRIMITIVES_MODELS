
`ifdef ASYNC_FIFO

module FIFO36K_tb();

  parameter DATA_READ_WIDTH =9; // FIFO data width (1-36)
  parameter DATA_WRITE_WIDTH = 9; // FIFO data width (1-36)

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

  reg do_overflow =0;
  reg do_underflow =0;

  parameter FIFO_TYPE = "ASYNCHRONOUS"; // Synchronous or Asynchronous data transfer (SYNCHRONOUS/ASYNCHRONOUS)
  parameter [11:0] PROG_EMPTY_THRESH = 12'd1020; // 12-bit Programmable empty depth
  parameter [11:0] PROG_FULL_THRESH = 12'd1020; // 12-bit Programmable full depth

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
    forever #1 WR_CLK = ~WR_CLK;
  end

  initial begin
      RD_CLK = 1'b0;
      forever #2 RD_CLK = ~RD_CLK;
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
    repeat(5)@(posedge WR_CLK);
    repeat(5)@(posedge RD_CLK);
    check_flags();
    repeat(5)@(posedge WR_CLK);
    repeat(5)@(posedge RD_CLK);
    check_flags();
    // repeat(5)@(posedge WR_CLK);
    // repeat(5)@(posedge RD_CLK);
    // check_flags();
    // repeat(5)@(posedge WR_CLK);
    // repeat(5)@(posedge RD_CLK);
    // check_flags();

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

    // for (int idx = 0; idx < 10; idx = idx + 1)
    // $dumpvars(0,FIFO36K_tb.fifo36k_inst.ASYNCRONOUS.FIFO_RAM_inst.RAM_DATA[idx]);
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

///////////////////////////////////////////////////////
task PUSH_FLAGS1_FULL(input reg [5:0] in, input string str);

          fork 
          begin
           push();
          end 
          join;
          if ({EMPTY,ALMOST_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,OVERFLOW} !== in) begin      
                  begin  $display("%s", str); error=error+1; end
          end
          count_clk=0;
endtask

task PUSH_FLAGS1_EMPTY(input reg [5:0] in, input string str);

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
          if ({EMPTY,ALMOST_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,OVERFLOW} !== in) begin      
                  begin  $display("%s", str); error=error+1; end
          end
          count_clk=0;
endtask



task POP_FLAGS_EMPTY(input reg [5:0] in, input string str);

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
          join;
          if ({EMPTY,ALMOST_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,OVERFLOW} !== in) begin
            begin $display("%s %0b",str, {EMPTY,ALMOST_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,OVERFLOW}, $time); error=error+1; end
          end
           count_clk=0;
endtask



task POP_FLAGS_FULL(input reg [5:0] in, input string str);

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
          if ({EMPTY,ALMOST_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,OVERFLOW} !== in) begin
            begin $display("%s %0b",str, {EMPTY,ALMOST_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,OVERFLOW}, $time); error=error+1; end
          end
           count_clk=0;
endtask



task POP_FLAGS1(input reg [5:0] in, input string str);
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
          if ({EMPTY,ALMOST_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,OVERFLOW} !== in) begin
            begin $display("%s %0b",str, {EMPTY,ALMOST_EMPTY,PROG_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,PROG_FULL,OVERFLOW}); error=error+1; end
          end
           count_clk=0;
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

count_enteries_push=0;

// Empty De Assert

    for (int i=0; i<DEPTH_WRITE; i++) begin


      if(i==0) begin
          PUSH_FLAGS1_EMPTY(6'b010_000, "ERROR PUSH: EMPTY SHOULD BE DE-ASSERTED");
      end

      if(i>=1 & i<DEPTH_WRITE- 2) begin
        PUSH_FLAGS1_EMPTY(6'b000_000, "ERROR PUSH: ALMOST EMPTY SHOULD BE DE-ASSERTED ");
      end

      if(i==DEPTH_WRITE- 2) begin
        PUSH_FLAGS1_FULL(6'b000_010,"ERROR PUSH: ONLY ALMOST FULL SHOULD BE ASSERTED");                    
      end

      if(i==DEPTH_WRITE- 1) begin
          PUSH_FLAGS1_FULL(6'b000_100,"ERROR PUSH: ONLY FULL SHOULD BE ASSERTED");                  
      end

      if(i<PROG_EMPTY_THRESH-1) begin
        if (PROG_EMPTY !==1) begin $display("ERROR PUSH: PROG_EMPTY SHOULD BE ASSERTED"); error=error+1; end
      // $display("Check111111111");
      end

      if(i>DEPTH_WRITE-PROG_FULL_THRESH) begin
        if (PROG_FULL !==1) begin $display("ERROR PUSH: PROG_FULL SHOULD BE ASSERTED"); error=error+1; end
      // $display("Check2222222");
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

  count_enteries_pop=0;

  for (i=0; i<DEPTH_READ; i++) begin

        
        if(i==0) begin
          compare_pop_data();
          POP_FLAGS_FULL(6'b000_010,"ERROR POP??: ONLY PROG FULL and ALMOST FULL SHOULD BE ASSERTED");
        end

        if(i>=1 &  i< DEPTH_READ-2) begin
          POP_FLAGS_FULL(6'b000_000,"ERROR POP: NO SHOULD BE ASSERTED");
        end

        if(i==DEPTH_READ-2)  begin
          // if(DATA_READ_WIDTH ==9) begin
          // POP_FLAGS(6'b000_000,"ERROR?? POP: ONLY ALMOST EMPTY SHOULD BE ASSERTED");
          // end
          // else begin            
          POP_FLAGS_EMPTY(6'b010_000,"ERROR POP: ONLY ALMOST EMPTY SHOULD BE ASSERTED");          
          // end          
        end

        if(i==DEPTH_READ-1)  begin
          POP_FLAGS_EMPTY(6'b100_000,"ERROR POP: ONLY ALMOST EMPTY SHOULD BE ASSERTED");            
        end

//
      if(count_enteries_pop<PROG_FULL_THRESH-1) begin
        if (PROG_FULL !==1) begin $display("ERROR POP: PROG_FULL SHOULD BE ASSERTED"); error=error+1; end
      // $display("Check33333333");
      end

      if(DEPTH_READ-i<=PROG_EMPTY_THRESH) begin
        if (PROG_EMPTY !==1) begin $display("ERROR PUSH: PROG_EMPTY NOT ASSERTED"); error=error+1; end
      // $display("Check4444444");
      end
//
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

count_enteries_push=0;
local_queue.delete();

for (int i=0; i<DEPTH_WRITE; i++) begin  //DEPTH_WRITE

  if(i*WgtR_Ratio<PROG_EMPTY_THRESH) begin
      if (PROG_EMPTY !==1) begin $display("ERROR PUSH: PROG_EMPTY NOT ASSERTED"); error=error+1; end
  // $display("Check111111");
  end

  if(i>DEPTH_WRITE-PROG_FULL_THRESH) begin
    if (PROG_FULL !==1) begin $display("ERROR PUSH: PROG_FULL NOT ASSERTED"); error=error+1; end
  // $display("Check222222");
  end

  if(i==0) begin
      PUSH_FLAGS1_EMPTY(6'b000_000, "ERROR PUSH: ALL1 SHOULD BE DE-ASSERTED");
  end
  
  if(i>0 & i<DEPTH_WRITE-2) begin
    PUSH_FLAGS1_EMPTY(6'b000_000, "ERROR PUSH: ALL2 SHOULD BE DE-ASSERTED");
  end

  if(i==DEPTH_WRITE-2) begin
    PUSH_FLAGS1_FULL(6'b000_010, "ERROR PUSH: ONLY ALMOST FULL ASSERTED");
  end

  if(i==DEPTH_WRITE-1) begin
    PUSH_FLAGS1_FULL(6'b000_100, "ERROR PUSH: ONLY FULL SHOULD BE ASSERTED");
  end

  if(do_overflow) begin
    repeat(1) begin
      push();
    end
  end
// push();

end

end

//*******************************************************************************************************************//

if(DATA_READ_WIDTH < DATA_WRITE_WIDTH) begin

// FULL DE-ASSERT

count_enteries_pop=0;

for (int i=0; i<DEPTH_READ; i++) begin

        if(i<WgtR_Ratio-1) begin
          compare_pop_data();
          pop();
          count_enteries_pop=count_enteries_pop+1;
        end
        
        else if(i==WgtR_Ratio-1) begin
          compare_pop_data();
          POP_FLAGS_FULL(6'b000_010, "ERROR POP: ONLY ALMOST FULL SHOULD BE ASSERTED");
        end
        
        else if(i>WgtR_Ratio-1 & i<DEPTH_READ-2) begin
          pop();
          count_enteries_pop=count_enteries_pop+1;
          compare_pop_data();
        end
        
        else if(i==DEPTH_READ-2)  begin
          // if(DATA_READ_WIDTH==9) begin
          //   POP_FLAGS(6'b000_000, "ERROR POP: ALL SHOULD BE DE-ASSERTED");
          // end
          // else begin
            POP_FLAGS_EMPTY(6'b010_000, "ERROR POP: ONLY ALMOST EMPTY SHOULD BE ASSERTED");          
          // end
        end
        
        else if(i==DEPTH_READ-1) begin
          POP_FLAGS_EMPTY(6'b100_000, "ERROR POP: ALL SHOULD BE DE-ASSERTED");
        end
        else begin
          // pop();
        end
//

      if(i>DEPTH_READ-PROG_EMPTY_THRESH) begin
        if (PROG_EMPTY !==1) begin $display("ERROR PUSH: PROG_EMPTY NOT ASSERTED"); error=error+1; end
        // $display("Check33333");
      end

      if(i<PROG_FULL_THRESH) begin
        if (PROG_FULL !==1) begin $display("ERROR PUSH: PROG_FULL NOT ASSERTED"); error=error+1; end
        // $display("Check44444");
      end
//

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

count_enteries_push=0;
local_queue.delete();


  for(int i=0 ; i<DEPTH_WRITE; i++) begin

    if(i<RgtW_Ratio-1) begin
      push();
      count_clk=0;
    end
    else if(i==RgtW_Ratio-1) begin
      PUSH_FLAGS1_EMPTY(6'b010_000,"ERROR PUSH: ONLY ALMOST EMPTY SHOULD BE ASSERTED");
    end
    else if(i>RgtW_Ratio & i<DEPTH_WRITE-2) begin
      push();
      count_clk=0;    
    end
    else if (i==DEPTH_WRITE-2) begin
      PUSH_FLAGS1_FULL(6'b000_010,"ERROR PUSH: ONLY ALMOST EMPTY SHOULD BE ASSERTED");
    end
    else if (i==DEPTH_WRITE-1) begin
      PUSH_FLAGS1_FULL(6'b000_100,"ERROR PUSH: ONLY ALMOST EMPTY SHOULD BE ASSERTED");
    end
    else begin
      push();
      count_clk=0;    
    end

      if(i>DEPTH_WRITE-PROG_FULL_THRESH-1) begin
        if (PROG_FULL !==1) begin $display("ERROR PUSH: PROG_EMPTY NOT ASSERTED ", $time); error=error+1; end
        // $display("Check11111");
      end

      if(i*RgtW_Ratio<PROG_EMPTY_THRESH) begin
        if (PROG_EMPTY !==1) begin $display("ERROR PUSH: PROG_FULL NOT ASSERTED"); error=error+1; end
        // $display("Check2222");
      end
/*
put Code for prog empty and prog full flags

*/


// overflow

if(do_overflow) begin
   repeat(1) begin
    push();
    count_clk=0;
   end
end

end
end


//*****************************************************************************************************************//


if(DATA_READ_WIDTH > DATA_WRITE_WIDTH) begin

// FULL DE-ASSERT
count_enteries_pop=0;

  for (int i=0; i<DEPTH_READ; i++) begin

  if(i==0) begin
      compare_pop_data();
      POP_FLAGS_FULL(6'b000_000, "ERROR POP: ALL1 SHOULD BE DE-ASSERTED");
  end
  
  if(i>0 & i<DEPTH_READ-2) begin
    POP_FLAGS_FULL(6'b000_000, "ERROR POP: ALL2 SHOULD BE DE-ASSERTED");
  end
  if(i==DEPTH_READ-2) begin
    POP_FLAGS_EMPTY(6'b010_000, "ERROR POP: ONLY ALMOST FULL ASSERTED");
  end

  if(i==DEPTH_WRITE-1) begin
    POP_FLAGS_EMPTY(6'b100_000, "ERROR POP: ONLY FULL SHOULD BE ASSERTED");
  end

  if((i+1)*RgtW_Ratio< PROG_FULL_THRESH) begin
      if (PROG_FULL !==1) begin $display("ERROR POP: PROG_FULL NOT ASSERTED", $time); error=error+1; end
  // $display("Check3333");
  end

  if(i>=DEPTH_READ-PROG_EMPTY_THRESH/RgtW_Ratio) begin
    if (PROG_EMPTY !==1) begin $display("ERROR POP: PROG_EMPTY NOT ASSERTED"); error=error+1; end
  // $display("Check44444");
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
    
        if (count_enteries_push==0 || count_enteries_push==4096) begin
       
           fwft_data1 = WR_DATA;
        
        end    
            local_queue.push_back({WR_DATA[8], WR_DATA[7:0]});
      end 

      else if(DATA_WRITE_WIDTH==18 ) begin  // 18
        
        if (count_enteries_push==0 || count_enteries_push==2048) begin
           fwft_data1 = {WR_DATA[8],WR_DATA[7:0]};
           fwft_data2 = {WR_DATA[17],WR_DATA[16:9]};
        end    
        local_queue.push_back({WR_DATA[8],WR_DATA[7:0]});  
        local_queue.push_back({WR_DATA[17],WR_DATA[16:9]});  
      end
      else begin     // 36
        if (count_enteries_push==0 || count_enteries_push==1024) begin
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
    
        if (count_enteries_push==0 || count_enteries_push==4096) begin
       
           fwft_data1 = {WR_DATA[8],WR_DATA[7:0]};

        end

        else if (count_enteries_push==1 || count_enteries_push==4097) begin

           fwft_data2 ={WR_DATA[8],WR_DATA[7:0]};
        
        end    
            local_queue.push_back({WR_DATA[8], WR_DATA[7:0]});
      end 

      else if(DATA_WRITE_WIDTH==18) begin  // 18
        
        if (count_enteries_push==0 || count_enteries_push==2048) begin
           fwft_data1 = {WR_DATA[8],WR_DATA[7:0]};
           fwft_data2 = {WR_DATA[17],WR_DATA[16:9]};
        end    
        local_queue.push_back({WR_DATA[8],WR_DATA[7:0]});  
        local_queue.push_back({WR_DATA[17],WR_DATA[16:9]});  
      end

      else begin     // 36
        if (count_enteries_push==0 || count_enteries_push==1024) begin
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
    
        if (count_enteries_push==0 || count_enteries_push==4096) begin
       
           fwft_data1 = WR_DATA;

        end

        else if (count_enteries_push==1 || count_enteries_push==4097) begin

           fwft_data2 = WR_DATA;
        
        end

        else if (count_enteries_push==2 || count_enteries_push==4098) begin

           fwft_data3 = WR_DATA;
        
        end 

        else if (count_enteries_push==3 || count_enteries_push==4099) begin

           fwft_data4 = WR_DATA;
        
        end     
            local_queue.push_back({WR_DATA[8], WR_DATA[7:0]});
      end 

      else if(DATA_WRITE_WIDTH==18) begin  // 18
        
        if (count_enteries_push==0 || count_enteries_push==2048) begin
           fwft_data1 = {WR_DATA[8],WR_DATA[7:0]};
           fwft_data2 = {WR_DATA[17],WR_DATA[16:9]};
        end
        else if (count_enteries_push==1 || count_enteries_push==2049) begin
           fwft_data3 = {WR_DATA[8],WR_DATA[7:0]};
           fwft_data4 = {WR_DATA[17],WR_DATA[16:9]};
        end   
        local_queue.push_back({WR_DATA[8],WR_DATA[7:0]});  
        local_queue.push_back({WR_DATA[17],WR_DATA[16:9]});  
      end

      else begin     // 36
        if (count_enteries_push==0 || count_enteries_push==1024) begin
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
          compare(RD_DATA[8:0], fwft_data1);
          exp_dout = local_queue.pop_front();
        end
        else begin
          exp_dout = local_queue.pop_front();
          compare(RD_DATA[8:0],exp_dout);
        end
    end

    if(DATA_WRITE_WIDTH==18) begin
        if (count_enteries_pop==4096) begin
          compare(RD_DATA[8:0], fwft_data1);
          exp_dout = local_queue.pop_front();
        end
        else begin
          exp_dout = local_queue.pop_front();
          compare(RD_DATA[8:0],exp_dout);
        end
    end

  end
///////////////////////////////////////////////////////////////////////////////////////

// R-18

  else if (DATA_READ_WIDTH==18 ) begin
    
    if(DATA_WRITE_WIDTH==9) begin
       if (count_enteries_pop==2048 || count_enteries_pop==4096) begin

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
          pop_data1= local_queue.pop_front();
          pop_data2= local_queue.pop_front();
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

       if (count_enteries_pop==1024 || count_enteries_pop==2048) begin

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

        if (count_enteries_pop==1024 || count_enteries_pop==2048) begin

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
          compare({RD_DATA[35], RD_DATA[34:27]}, {pop_data4[8], pop_data4[7:0]});        end
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
    RD_EN=0;
endtask : pop


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

  parameter DATA_WIDTH_WRITE = 36; // FIFO data width (1-36)
  parameter DATA_WIDTH_READ = 36;   // FIFO data width (1-36)

  reg [DATA_WIDTH_WRITE-1:0] WR_DATA; // Write data
  wire [DATA_WIDTH_READ-1:0] RD_DATA; // Read data
  wire EMPTY; // FIFO empty flag
  wire FULL; // FIFO full flag
  wire ALMOST_EMPTY; // FIFO almost empty flag
  wire ALMOST_FULL; // FIFO almost full flag
  wire PROG_EMPTY; // FIFO programmable empty flag
  wire PROG_FULL; // FIFO programmable full flag
  wire OVERFLOW; // FIFO overflow error flag
  wire UNDERFLOW;// FIFO underflow error flag

  parameter FIFO_TYPE = "SYNCHRONOUS"; // Synchronous or Asynchronous data transfer (SYNCHRONOUS/ASYNCHRONOUS)
  parameter [11:0] PROG_EMPTY_THRESH = 12'd1000; // 12-bit Programmable empty depth
  parameter [11:0] PROG_FULL_THRESH = 12'd1022;// 12-bit Programmable full depth

  // 12 bit max value is 4096 , 

  // Testbench Variables
  parameter R_CLOCK_PERIOD = 20;
  parameter W_CLOCK_PERIOD = 20;
  // parameter DATA_WIDTH = 36;
  
  localparam DATA_WIDTH = (DATA_WIDTH_WRITE==DATA_WIDTH_READ)? DATA_WIDTH_WRITE : DATA_WIDTH_WRITE;

  localparam DEPTH = (DATA_WIDTH <= 9) ? 4096 :
  (DATA_WIDTH <= 18) ? 2048 :
  1024;
  
  localparam DEPTH_READ = (DATA_WIDTH_READ <= 9) ? 4096 :
  (DATA_WIDTH_READ <= 18) ? 2048 :
  1024;
  localparam DEPTH_WRITE = (DATA_WIDTH_WRITE <= 9) ? 4096 :
  (DATA_WIDTH_WRITE <= 18) ? 2048 :
  1024;  
  reg [8:0] exp_dout1;
  reg [8:0] local_queue1 [$];

  // predictor output
  reg [DATA_WIDTH-1:0] exp_dout;

  // testbench variables
  integer error=0;
  // integer rden_cnt=0;
  integer wren_cnt=0;
  reg [DATA_WIDTH-1:0] local_queue [$];
  integer fifo_number;
  bit debug=0;

  //clock//
  initial begin
    WR_CLK = 1'b0;
    forever #1 WR_CLK = ~WR_CLK;
end

// initial begin
//  RD_CLK = 1'b0;
//  forever #15 RD_CLK = ~RD_CLK;
// end

  initial begin
      RD_CLK = 1'b0;
      forever #1 RD_CLK = ~RD_CLK;
  end

   FIFO36K #(
    .DATA_WRITE_WIDTH(DATA_WIDTH_WRITE),
    .DATA_READ_WIDTH(DATA_WIDTH_READ),
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
    if(DATA_WIDTH_READ==DATA_WIDTH_WRITE) begin
      check_flags();
      check_flags();
      check_flags();
      check_flags();
    end
    else begin
      check_flags1();
      check_flags1();
      check_flags1();
      check_flags1();

    end

    test_status(error);
    #4;
    $finish();
  end

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0,FIFO36K_tb);
    // $dumpvars(0,FIFO36K_tb.i);

  //   for (int idx = 0; idx < DEPTH; idx = idx + 1)
  //   $dumpvars(0,FIFO36K_tb.fifo36k_inst.SYNCHRONOUS.FIFO_RAM_inst.RAM_DATA[idx]);
  end

integer i;

reg [8:0] pop_data1;
reg [8:0] pop_data2;
reg [8:0] pop_data3;
reg [8:0] pop_data4;

  // testbench variables
  integer count_n=0;
  bit count_clk=0;
  integer count_enteries_push=0;
  integer count_enteries_pop=0;
  integer fwft_data1=0;
  integer fwft_data2=0;
  integer fwft_data3=0;
  integer fwft_data4=0;
  reg do_overflow =0;
  reg do_underflow =0;


localparam WgtR_Ratio = (DATA_WIDTH_READ>=DATA_WIDTH_WRITE)?  1: DATA_WIDTH_WRITE/DATA_WIDTH_READ; // For example ? = 4
localparam RgtW_Ratio = (DATA_WIDTH_WRITE>=DATA_WIDTH_READ)?  1: DATA_WIDTH_READ/DATA_WIDTH_WRITE; // For example ? = 4



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
    count_enteries_push=0;
    for(i = 1 ; i<=DEPTH_WRITE+do_overflow; i=i+1) begin
    
    if(i==1) begin
      push111();
      @(posedge WR_CLK);
      @(negedge WR_CLK);
      // $display("time %t", $time);
      if ({EMPTY,ALMOST_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,OVERFLOW} !== 6'b010_000) begin      
                  begin  $display("ERROR PUSH: ONLY ALMOST EMPTY SHOULD BE ASSERTED"); error=error+1; end
      end
    end
    if(i>1 & i<DEPTH_WRITE-1) begin
      push111();
      @(posedge WR_CLK);
      @(negedge WR_CLK);
      // $display("time %t", $time);
      if ({EMPTY,ALMOST_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,OVERFLOW} !== 6'b000_000) begin      
                  begin  $display("ERROR PUSH: ALL SHOULD BE DE-ASSERTED"); error=error+1; end
      end
    end

    if(i==DEPTH_WRITE-1) begin
      push111();
      @(posedge WR_CLK);
      @(negedge WR_CLK);
      // $display("time %t", $time);
      if ({EMPTY,ALMOST_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,OVERFLOW} !== 6'b000_010) begin      
                  begin  $display("ERROR PUSH: ONLY ALMOST FULL SHOULD BE ASSERTED"); error=error+1; end
      end
    end

    if(i==DEPTH_WRITE) begin
      push111();
      @(posedge WR_CLK);
      @(negedge WR_CLK);
      // $display("time %t", $time);
      if ({EMPTY,ALMOST_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,OVERFLOW} !== 6'b000_100) begin      
                  begin  $display("ERROR PUSH: ONLY FULL SHOULD BE ASSERTED"); error=error+1; end
      end
    end

      if(i==DEPTH_WRITE & do_overflow) begin
      push111(); 
      @(posedge WR_CLK);
      if (OVERFLOW !== 1'b1) begin      
                  begin  $display("ERROR PUSH: OVERFLOW SHOULD BE 1"); error=error+1; end
      end            
    end
  
  if(i<=PROG_EMPTY_THRESH) begin
          if (PROG_EMPTY !== 1) begin      
                  begin  $display("ERROR PUSH: PROG EMPTY SHOULD BE ASSERTED"); error=error+1; end
      end
  end

 if(i>DEPTH_WRITE-PROG_FULL_THRESH) begin
          if (PROG_FULL !== 1) begin      
                  begin  $display("ERROR PUSH: PROG FULL SHOULD BE ASSERTED"); error=error+1; end
      end
  end

 end

count_enteries_pop=0;
for(integer i = 1 ; i<=DEPTH_READ+do_underflow; i=i+1) begin


if(i==1) begin
    compare_pop_data111();
    count_enteries_pop= count_enteries_pop+1;
    pop111();
    compare_pop_data111();
    count_enteries_pop= count_enteries_pop+1;
    @(posedge WR_CLK);
    @(negedge WR_CLK);
    if ({EMPTY,ALMOST_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,OVERFLOW} !== 6'b000_010) begin      
                  begin  $display("ERROR PUSH: ONLY ALMOST FULL SHOULD BE ASSERTED"); error=error+1; end
    end
end

if(i>1 & i<DEPTH_READ-1) begin
    pop111();
    compare_pop_data111();
    count_enteries_pop= count_enteries_pop+1;
    @(posedge WR_CLK);
    @(negedge WR_CLK);
    if ({EMPTY,ALMOST_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,OVERFLOW} !== 6'b000_000) begin      
                  begin  $display("ERROR PUSH: ONLY ALMOST FULL SHOULD BE ASSERTED"); error=error+1; end
    end
end

if(i==DEPTH_READ-1) begin
    pop111();
    compare_pop_data111();
    count_enteries_pop= count_enteries_pop+1;
    @(posedge WR_CLK);
    if ({EMPTY,ALMOST_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,OVERFLOW} !== 6'b010_000) begin      
                  begin  $display("ERROR PUSH: ONLY ALMOST FULL SHOULD BE ASSERTED"); error=error+1; end
    end
end

if(i==DEPTH_READ) begin
    pop111();
    compare_pop_data111();
    count_enteries_pop= count_enteries_pop+1;
    @(posedge WR_CLK);
    if ({EMPTY,ALMOST_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,OVERFLOW} !== 6'b100_000) begin      
                  begin  $display("ERROR PUSH: ONLY ALMOST FULL SHOULD BE ASSERTED"); error=error+1; end
    end
end

if(i==DEPTH_READ+do_underflow & do_underflow==1) begin
    pop111();
    @(posedge WR_CLK);
    if ({EMPTY,ALMOST_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,OVERFLOW} !== 6'b101_000) begin      
                  begin  $display("ERROR PUSH: EMPTY AND UNDERFLOW SHOULD BE ASSERTED"); error=error+1; end
    end
end
end

if(i<PROG_FULL_THRESH) begin
    if (PROG_FULL !== 1)
    begin $display("ERROR: PROG FULL SHOULD BE ASSERTED"); error=error+1; end
end

if(i>DEPTH_READ-PROG_EMPTY_THRESH) begin
    if (PROG_EMPTY !== 1)
    begin $display("ERROR: PROG EMPTY SHOULD BE ASSERTED"); error=error+1; end
end

endtask


task check_flags1();

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

  if(DATA_WIDTH_WRITE > DATA_WIDTH_READ) begin
  
  count_enteries_push=0;
  
  for(int i=0; i<DEPTH_WRITE+do_overflow; i++) begin
    
    if((i+1)*WgtR_Ratio<PROG_EMPTY_THRESH) begin
      if(PROG_EMPTY !==1) begin $display("ERROR PUSH: PROG_EMPTY SHOULD BE 1");error=error+1;  end
    end

    if(i>DEPTH_WRITE-PROG_FULL_THRESH) begin
      if(PROG_FULL !==1) begin $display("ERROR PUSH: PROG_FULL SHOULD BE 1");error=error+1;  end
    end

    if(i==0) begin
      
      if ({EMPTY,ALMOST_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,OVERFLOW} !== 6'b100_000) begin      
                  begin  $display("ERROR PUSH: ONLY EMPTY SHOULD BE ASSERTED"); error=error+1; end
      end
      push111();  
      @(posedge WR_CLK);
      @(negedge WR_CLK);
      if ({EMPTY,ALMOST_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,OVERFLOW} !== 6'b000_000) begin      
                  begin  $display("ERROR PUSH: ALL DE ASSERTED"); error=error+1; end
      end
    end
    
    if(i>0 & i< DEPTH_WRITE-2) begin
      push111();  
      @(posedge WR_CLK);
      @(negedge WR_CLK);
      if ({EMPTY,ALMOST_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,OVERFLOW} !== 6'b000_000) begin      
                  begin  $display("ERROR PUSH: ALL SHOULD BE DE ASSERTED"); error=error+1; end
      end
    end

    if(i== DEPTH_WRITE-2) begin
      push111();  
      @(posedge WR_CLK);
      @(negedge WR_CLK);
      if ({EMPTY,ALMOST_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,OVERFLOW} !== 6'b000_010) begin      
                  begin  $display("ERROR PUSH: ONLY ALMOST FULL SHOULD BE ASSERTED"); error=error+1; end
      end
    end

    if(i== DEPTH_WRITE-1) begin
      push111();  
      @(posedge WR_CLK);
      @(negedge WR_CLK);
      if ({EMPTY,ALMOST_EMPTY,UNDERFLOW,   FULL,ALMOST_FULL,OVERFLOW} !== 6'b000_100) begin      
                  begin  $display("ERROR PUSH: ONLY FULL SHOULD BE ASSERTED"); error=error+1; end
      end
    end

    if(i==DEPTH_WRITE & do_overflow) begin
      push111(); 
      @(posedge WR_CLK);
      if (OVERFLOW !== 1'b1) begin      
                  begin  $display("ERROR PUSH: OVERFLOW SHOULD BE 1"); error=error+1; end
      end            
    end

end

end

if(DATA_WIDTH_WRITE > DATA_WIDTH_READ) begin
    
    count_enteries_pop=0;

  for(int i=0; i<DEPTH_READ+do_underflow; i++) begin

    compare_pop_data111();
    count_enteries_pop= count_enteries_pop+1;
    pop111();
    
    if(i==WgtR_Ratio) begin

        if ({EMPTY,ALMOST_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,OVERFLOW} !== 8'b000_010)
        begin $display("ERROR: ONLY ALMOST FULL SHOULD BE ASSERTED"); error=error+1; end
    
    end
    if(i==DEPTH_READ-2) begin

        if ({EMPTY,ALMOST_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,OVERFLOW} !== 8'b010_000)
        begin $display("ERROR: ONLY ALMOST EMPTY SHOULD BE ASSERTED"); error=error+1; end
    
    end

    if(i==DEPTH_READ-1) begin

        if ({EMPTY,ALMOST_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,OVERFLOW} !== 8'b100_000)
        begin $display("ERROR: EMPTY SHOULD BE ASSERTED"); error=error+1; end
    
    end

    if(i<WgtR_Ratio*PROG_FULL_THRESH) begin
          if (PROG_FULL !== 1)
        begin $display("ERROR: PROG FULL SHOULD BE ASSERTED"); error=error+1; end
    end

    if(i>DEPTH_READ-PROG_EMPTY_THRESH) begin
          if (PROG_EMPTY !== 1)
        begin $display("ERROR: PROG EMPTY SHOULD BE ASSERTED"); error=error+1; end
    end

    if(i==DEPTH_READ-1 & do_underflow) begin
        pop111();
      if(UNDERFLOW !== 1) begin
        $display("POP ERROR: UNDERFLOW SHOULD BE 1");  error=error+1;
      end
    end

  end
end

if(DATA_WIDTH_WRITE < DATA_WIDTH_READ) begin

count_enteries_push=0;

  for(int i=0; i<DEPTH_WRITE+do_overflow; i++) begin

    if(i<RgtW_Ratio) begin
      push111();
      // count_clk=0;
    end
    if(i==RgtW_Ratio-1) begin
        push111();
        if ({EMPTY,ALMOST_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,OVERFLOW} !== 6'b010_000)
        begin $display("ERROR: ONLY ALMOST EMPTY SHOULD BE ASSERTED"); error=error+1; end
    end
    else if(i>RgtW_Ratio-1 & i<DEPTH_WRITE-2) begin
      push111();
    end
    else if (i==DEPTH_WRITE-2) begin
        if ({EMPTY,ALMOST_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,OVERFLOW} !== 6'b000_010)
        begin $display("ERROR: ONLY ALMOST FULL SHOULD BE ASSERTED"); error=error+1; end
    end
    else if (i==DEPTH_WRITE-1) begin
      push111();
        if ({EMPTY,ALMOST_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,OVERFLOW} !== 6'b000_100)
        begin $display("ERROR: ONLY FULL SHOULD BE ASSERTED"); error=error+1; end
    end
 
      if(i>DEPTH_WRITE-PROG_FULL_THRESH) begin
        if (PROG_FULL !==1) begin $display("ERROR PUSH: PROG_FULL SHOULD BE ASSERTED"); error=error+1; end
      end

      if(i<PROG_EMPTY_THRESH) begin
        if (PROG_EMPTY !==1) begin $display("ERROR PUSH: PROG_EMPTY SHOULD BE ASSERTED"); error=error+1; end
      end

    if(i==DEPTH_WRITE & do_overflow) begin
      push111();  
      if (OVERFLOW !== 1'b1) begin      
                  begin  $display("ERROR PUSH: OVERFLOW SHOULD BE 1"); error=error+1; end
      end            
    end

  end

end


if(DATA_WIDTH_WRITE < DATA_WIDTH_READ) begin
  
  count_enteries_pop=0;
  
  for(int i=0; i<DEPTH_READ+do_underflow; i++) begin

    compare_pop_data111();
    count_enteries_pop= count_enteries_pop+1;
    pop111();

      if(count_enteries_pop==2) begin

        if ({EMPTY,ALMOST_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,OVERFLOW} !== 8'b000_000)
        begin $display("ERROR: ALL FLAGS SHOULD BE DE ASSERTED"); error=error+1; end
               
      end

      if(count_enteries_pop==DEPTH_READ-1) begin

        if ({EMPTY,ALMOST_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,OVERFLOW} !== 8'b010_000)
        begin $display("ERROR: ONLY ALMOST EMPTY SHOULD BE ASSERTED ASSERTED"); error=error+1; end
               
      end

      if(count_enteries_pop==DEPTH_READ) begin

        if ({EMPTY,ALMOST_EMPTY,UNDERFLOW,FULL,ALMOST_FULL,OVERFLOW} !== 8'b100_000)
        begin $display("ERROR: EMPTY SHOULD BE ASSERTED "); error=error+1; end
               
      end

    if(i==DEPTH_READ-1 & do_underflow) begin
    pop111();
      if(UNDERFLOW !== 1) begin
        $display("POP ERROR: UNDERFLOW SHOULD BE 1");  error=error+1;
      end
    end

if(i*RgtW_Ratio <PROG_FULL_THRESH) begin
  if(PROG_FULL !==1) begin $display("ERROR: PROG FULL SHOULD BE 1 "); error=error+1; end
end

if(i> DEPTH_READ-PROG_EMPTY_THRESH) begin
  if(PROG_EMPTY !==1) begin $display("ERROR: PROG EMPTY SHOULD BE 1 "); error=error+1; end
end

end
end


endtask

task push111();
      @(negedge WR_CLK);
      WR_EN = 1;
      WR_DATA = $urandom_range(0, 2**DATA_WIDTH_WRITE-1);
      // WR_DATA = $random();
      @(posedge WR_CLK);
      count_clk=1;
      @(negedge WR_CLK);

/* ----------------------------------- push byte date ---------------------------------- */
// R-9 
   if (DATA_WIDTH_READ==9) begin
   
      if(DATA_WIDTH_WRITE==9) begin  // 9
    
        if (count_enteries_push==0 || count_enteries_push==4096) begin
       
           fwft_data1 = WR_DATA;
        
        end    
            local_queue.push_back({WR_DATA[8], WR_DATA[7:0]});
      end 

      else if(DATA_WIDTH_WRITE==18 ) begin  // 18
        
        if (count_enteries_push==0 || count_enteries_push==2048) begin
           fwft_data1 = {WR_DATA[8],WR_DATA[7:0]};
           fwft_data2 = {WR_DATA[17],WR_DATA[16:9]};
        end    
        local_queue.push_back({WR_DATA[8],WR_DATA[7:0]});  
        local_queue.push_back({WR_DATA[17],WR_DATA[16:9]});  
      end
      else begin     // 36
        if (count_enteries_push==0 || count_enteries_push==1024) begin
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
  if (DATA_WIDTH_READ==18) begin
   
      if(DATA_WIDTH_WRITE==9) begin  // 9
    
        if (count_enteries_push==0 || count_enteries_push==4096) begin
       
           fwft_data1 = WR_DATA;

        end

        else if (count_enteries_push==1 || count_enteries_push==4097) begin

           fwft_data2 = WR_DATA;
        
        end    
            local_queue.push_back({WR_DATA[8], WR_DATA[7:0]});
      end 

      else if(DATA_WIDTH_WRITE==18) begin  // 18
        
        if (count_enteries_push==0 || count_enteries_push==2048) begin
           fwft_data1 = {WR_DATA[8],WR_DATA[7:0]};
           fwft_data2 = {WR_DATA[17],WR_DATA[16:9]};
        end    
        local_queue.push_back({WR_DATA[8],WR_DATA[7:0]});  
        local_queue.push_back({WR_DATA[17],WR_DATA[16:9]});  
      end

      else begin     // 36
        if (count_enteries_push==0 || count_enteries_push==1024) begin
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

  if (DATA_WIDTH_READ==36) begin
   
      if(DATA_WIDTH_WRITE==9) begin  // 9
    
        if (count_enteries_push==0 || count_enteries_push==4096) begin
       
           fwft_data1 = WR_DATA;

        end

        else if (count_enteries_push==1 || count_enteries_push==4097) begin

           fwft_data2 = WR_DATA;
        
        end

        else if (count_enteries_push==2 || count_enteries_push==4098) begin

           fwft_data3 = WR_DATA;
        
        end 

        else if (count_enteries_push==3 || count_enteries_push==4099) begin

           fwft_data4 = WR_DATA;
        
        end     
            local_queue.push_back({WR_DATA[8], WR_DATA[7:0]});
      end 

      else if(DATA_WIDTH_WRITE==18) begin  // 18
        
        if (count_enteries_push==0 || count_enteries_push==2048) begin
           fwft_data1 = {WR_DATA[8],WR_DATA[7:0]};
           fwft_data2 = {WR_DATA[17],WR_DATA[16:9]};
        end
        else if (count_enteries_push==1 || count_enteries_push==2049) begin
           fwft_data3 = {WR_DATA[8],WR_DATA[7:0]};
           fwft_data4 = {WR_DATA[17],WR_DATA[16:9]};
        end   
        local_queue.push_back({WR_DATA[8],WR_DATA[7:0]});  
        local_queue.push_back({WR_DATA[17],WR_DATA[16:9]});  
      end

      else begin     // 36
        if (count_enteries_push==0 || count_enteries_push==1024) begin
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

endtask : push111 



task compare_pop_data111();

// R-9

  if (DATA_WIDTH_READ==9) begin
    
    if(DATA_WIDTH_WRITE==9) begin
        if (count_enteries_pop==4096) begin
          compare(RD_DATA[8:0], fwft_data1);
        end
        else begin
          exp_dout = local_queue.pop_front();
          compare(RD_DATA,exp_dout);
        end
    end

    if(DATA_WIDTH_WRITE==36) begin
        if (count_enteries_pop==4096) begin
          compare(RD_DATA[8:0], fwft_data1);
          exp_dout = local_queue.pop_front();
        end
        else begin
          exp_dout = local_queue.pop_front();
          compare(RD_DATA[8:0],exp_dout);
        end
    end

    if(DATA_WIDTH_WRITE==18) begin
        if (count_enteries_pop==4096) begin
          compare(RD_DATA[8:0], fwft_data1);
          exp_dout = local_queue.pop_front();
        end
        else begin
          exp_dout = local_queue.pop_front();
          compare(RD_DATA[8:0],exp_dout);
        end
    end

  end
///////////////////////////////////////////////////////////////////////////////////////

// R-18

  else if (DATA_WIDTH_READ==18 ) begin
    
    if(DATA_WIDTH_WRITE==9) begin
       if (count_enteries_pop==2048 || count_enteries_pop==4096) begin

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
  
      if(DATA_WIDTH_WRITE==18) begin

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

      if(DATA_WIDTH_WRITE==36) begin

       if (count_enteries_pop==2048) begin
          pop_data1= local_queue.pop_front();
          pop_data2= local_queue.pop_front();
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

  else if (DATA_WIDTH_READ==36 ) begin
    
    if(DATA_WIDTH_WRITE==9) begin

       if (count_enteries_pop==1024 || count_enteries_pop==2048) begin

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
  
      if(DATA_WIDTH_WRITE==18) begin

        if (count_enteries_pop==1024 || count_enteries_pop==2048) begin

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
          compare({RD_DATA[35], RD_DATA[34:27]}, {pop_data4[8], pop_data4[7:0]});        end
    end

      if(DATA_WIDTH_WRITE==36) begin

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


task pop111();
    @(negedge RD_CLK);
    RD_EN = 1;
    @(negedge RD_CLK);
    RD_EN=0;
endtask : pop111



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