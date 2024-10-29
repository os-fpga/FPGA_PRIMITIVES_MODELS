/*
NOTE: ASYNCRONOUS FIFO can be  asymmetric but synchronous only support symmetric
THERE ARE TWO FIFOs FIFO1 and FIFO2 both of the fifos are independent to each both of them can be asynchronous/asynchronous, 
fifo1 can synchronous and fifo2 asynchronous or vice versa. 

*/
 
module FIFO18KX2_tb();
  // FIFO1 Variables
	reg RESET1; // Asynchrnous FIFO reset
	reg WR_CLK1; // Write clock
	reg RD_CLK1; // Read clock
	reg WR_EN1; // Write enable
	reg RD_EN1; // Read enable
	reg [DATA_WRITE_WIDTH1-1:0] WR_DATA1; // Write data
	wire [DATA_READ_WIDTH1-1:0] RD_DATA1; // Read data
	wire EMPTY1; // FIFO empty flag
	wire FULL1; // FIFO full flag
	wire ALMOST_EMPTY1; // FIFO almost empty flag
	wire ALMOST_FULL1; // FIFO almost full flag
	wire PROG_EMPTY1; // FIFO programmable empty flag
	wire PROG_FULL1; // FIFO programmable full flag
	wire OVERFLOW1; // FIFO overflow error flag
	wire UNDERFLOW1;// FIFO underflow error flag

/***************************************  SETTINGS FOR FIFO 1 ***********************************/

  // Note: for syrounous (read and write freq is same) read and write data width should be same either 9, or 18. 
  // AND FIFO TYPE IS SET to "SYNCHRONOUS"
  // Note: for asyrounous (read and write freq is different) read and write data width can be same or different either 9, or 18. 
  // AND FIFO TYPE IS SET to "ASYNCHRONOUS"  

  bit is_fifo1_async=1;   // set it 1 for async and 0 for sync 
  

	parameter DATA_WRITE_WIDTH1 = 9; // FIFO data write width, FIFO 1
  parameter DATA_READ_WIDTH1 = 18; // FIFO data read width, FIFO 1
  parameter FIFO_TYPE1 = "ASYNCHRONOUS"; // Synchronous or Asynchronous data transfer, FIFO 1 (SYNCHRONOUS/ASYNCHRONOUS)
  parameter [10:0] PROG_EMPTY_THRESH1 = 11'h004; // 11-bit Programmable empty depth, FIFO 1
  parameter [10:0] PROG_FULL_THRESH1 = 11'h004; // 11-bit Programmable full depth, FIFO 1
  
  bit do_underflow1=0; // set to 1 if want to check underflow flag
  bit do_overflow1=0;  // set to 1 if want to check overflow flag

  	//clock//
	initial begin
		WR_CLK1 = 1'b0;
		forever #20 WR_CLK1 = ~WR_CLK1;
end


	initial begin
			RD_CLK1 = 1'b0;
			forever #2 RD_CLK1 = ~RD_CLK1;
	end
/*************************************************************************************************/


  localparam DATA_WIDTH1 = DATA_WRITE_WIDTH1;
  localparam  fifo_depth1 = (DATA_WIDTH1 <= 9) ? 2048 : 1024;

	// Testbench Variables
	parameter R_CLOCK_PERIOD = 20;
	parameter W_CLOCK_PERIOD = 20;
	// parameter DATA_WIDTH1 = 36;
  localparam DEPTH1 = (DATA_WIDTH1 <= 9) ? 2048 :  1024;

  localparam DEPTH_WRITE1 = (DATA_WRITE_WIDTH1 <= 9) ? 2048 :  1024;
  localparam DEPTH_READ1 = (DATA_READ_WIDTH1 <= 9) ? 2048 :  1024;


	// predictor output
	reg [DATA_WIDTH1-1:0] exp_dout1;

	// testbench variables
	integer error=0;
  // integer rden_cnt=0;
  integer wren_cnt=0;
	reg [DATA_WIDTH1-1:0] local_queue1 [$];
	integer fifo_number;
	bit debug=0;

  // FIFO2 Variables
  reg RESET2; // Asynchrnous FIFO reset
  reg WR_CLK2; // Write clock
  reg RD_CLK2; // Read clock
  reg WR_EN2; // Write enable
  reg RD_EN2; // Read enable
  reg [DATA_WRITE_WIDTH2-1:0] WR_DATA2; // Write data
  wire [DATA_READ_WIDTH2-1:0] RD_DATA2; // Read data
  wire EMPTY2; // FIFO empty flag
  wire FULL2; // FIFO full flag
  wire ALMOST_EMPTY2; // FIFO almost empty flag
  wire ALMOST_FULL2; // FIFO almost full flag
  wire PROG_EMPTY2; // FIFO programmable empty flag
  wire PROG_FULL2; // FIFO programmable full flag
  wire OVERFLOW2; // FIFO overflow error flag
  wire UNDERFLOW2;// FIFO underflow error flag


/***************************************  SETTINGS FOR FIFO 2 ***********************************/
   // Note: for syrounous (read and write freq is same) read and write data width should be same either 9, or 18. 
  // AND FIFO TYPE IS SET to "SYNCHRONOUS"
  // Note: for asyrounous (read and write freq is different) read and write data width can be same or different either 9, or 18. 
  // AND FIFO TYPE IS SET to "ASYNCHRONOUS"  
  
  bit is_fifo2_async=1;

  parameter DATA_WRITE_WIDTH2 = 9; // FIFO data write width, FIFO 1
  parameter DATA_READ_WIDTH2 = 18; // FIFO data read width, FIFO 1
  parameter FIFO_TYPE2 = "ASYNCHRONOUS"; // Synchronous or Asynchronous data transfer, FIFO 1 (SYNCHRONOUS/ASYNCHRONOUS)
  parameter [10:0] PROG_EMPTY_THRESH2 = 11'h004; // 11-bit Programmable empty depth, FIFO 1
  parameter [10:0] PROG_FULL_THRESH2 = 11'h004; // 11-bit Programmable full depth, FIFO 1
  bit do_underflow2=0; // set to 1 if want to check underflow flag
  bit do_overflow2=0;  // set to 1 if want to check overflow flag

  //clock//
  initial begin
    WR_CLK2 = 1'b0;
    forever #20 WR_CLK2 = ~WR_CLK2;
  end
  initial begin
      RD_CLK2 = 1'b0;
      forever #2 RD_CLK2 = ~RD_CLK2;
  end
/***********************************************************************************************/

  localparam DATA_WIDTH2 = DATA_WRITE_WIDTH2;
  localparam  fifo_depth2 = (DATA_WIDTH2 <= 9) ? 2048 : 1024;
  localparam DEPTH2 = (DATA_WIDTH2 <= 9) ? 2048 :  1024;

  localparam  fifo_depth_write2 = (DATA_WRITE_WIDTH2 <= 9) ? 2048 : 1024;
  localparam  fifo_depth_read2 = (DATA_READ_WIDTH2 <= 9) ? 2048 : 1024;

  localparam DEPTH_WRITE2 = (DATA_WRITE_WIDTH2 <= 9) ? 2048 :  1024;
  localparam DEPTH_READ2 = (DATA_READ_WIDTH2 <= 9) ? 2048 :  1024;


  // predictor output
  reg [DATA_WIDTH2-1:0] exp_dout2;
  reg [DATA_WIDTH2-1:0] local_queue2 [$];


  FIFO18KX2 #(
  .DATA_WRITE_WIDTH1(DATA_WRITE_WIDTH1), // FIFO data write width, FIFO 1
  .DATA_READ_WIDTH1(DATA_READ_WIDTH1), // FIFO data read width, FIFO 1
  .FIFO_TYPE1(FIFO_TYPE1), // Synchronous or Asynchronous data transfer, FIFO 1 (SYNCHRONOUS/ASYNCHRONOUS)
  .PROG_EMPTY_THRESH1(PROG_EMPTY_THRESH1), // 11-bit Programmable empty depth, FIFO 1
  .PROG_FULL_THRESH1(PROG_FULL_THRESH1), // 11-bit Programmable full depth, FIFO 1
  .DATA_WRITE_WIDTH2(DATA_WRITE_WIDTH2), // FIFO data write width, FIFO 2 (1-18)
  .DATA_READ_WIDTH2(DATA_READ_WIDTH2), // FIFO data read width, FIFO 2 (1-18)
  .FIFO_TYPE2(FIFO_TYPE2), // Synchronous or Asynchronous data transfer, FIFO 2 (SYNCHRONOUS/ASYNCHRONOUS)
  .PROG_EMPTY_THRESH2(PROG_EMPTY_THRESH2), // 11-bit Programmable empty depth, FIFO 2
  .PROG_FULL_THRESH2(PROG_FULL_THRESH2) // 11-bit Programmable full depth, FIFO 2
) fifo18k_inst(
  .RESET1(RESET1), // Asynchrnous FIFO reset, FIFO 1
  .WR_CLK1(WR_CLK1), // Write clock, FIFO 1
  .RD_CLK1(RD_CLK1), // Read clock, FIFO 1
  // .RD_CLK1(1'h0), // Read clock, FIFO 1
  .WR_EN1(WR_EN1), // Write enable, FIFO 1
  .RD_EN1(RD_EN1), // Read enable, FIFO 1
  .WR_DATA1(WR_DATA1), // Write data, FIFO 1
  .RD_DATA1(RD_DATA1), // Read data, FIFO 1
  .EMPTY1(EMPTY1), // FIFO empty flag, FIFO 1
  .FULL1(FULL1), // FIFO full flag, FIFO 1
  .ALMOST_EMPTY1(ALMOST_EMPTY1), // FIFO almost empty flag, FIFO 1
  .ALMOST_FULL1(ALMOST_FULL1), // FIFO almost full flag, FIFO 1
  .PROG_EMPTY1(PROG_EMPTY1), // FIFO programmable empty flag, FIFO 1
  .PROG_FULL1(PROG_FULL1), // FIFO programmable full flag, FIFO 1
  .OVERFLOW1(OVERFLOW1), // FIFO overflow error flag, FIFO 1
  .UNDERFLOW1(UNDERFLOW1), // FIFO underflow error flag, FIFO 1
  .RESET2(RESET2), // Asynchrnous FIFO reset, FIFO 2
  .WR_CLK2(WR_CLK2), // Write clock, FIFO 2
  .RD_CLK2(RD_CLK2), // Read clock, FIFO 2
  .WR_EN2(WR_EN2), // Write enable, FIFO 2
  .RD_EN2(RD_EN2), // Read enable, FIFO 2
  .WR_DATA2(WR_DATA2), // Write data, FIFO 2
  .RD_DATA2(RD_DATA2), // Read data, FIFO 2
  .EMPTY2(EMPTY2), // FIFO empty flag, FIFO 2
  .FULL2(FULL2), // FIFO full flag, FIFO 2
  .ALMOST_EMPTY2(ALMOST_EMPTY2), // FIFO almost empty flag, FIFO 2
  .ALMOST_FULL2(ALMOST_FULL2), // FIFO almost full flag, FIFO 2
  .PROG_EMPTY2(PROG_EMPTY2), // FIFO programmable empty flag, FIFO 2
  .PROG_FULL2(PROG_FULL2), // FIFO programmable full flag, FIFO 2
  .OVERFLOW2(OVERFLOW2), // FIFO overflow error flag, FIFO 2
  .UNDERFLOW2(UNDERFLOW2) // FIFO underflow error flag, FIFO 2
);

  initial begin
    fork
      begin
        RESET1 = 1;
        repeat(2) @(negedge WR_CLK1);
        RESET1 = 0;
      end
      begin
        RESET2 = 1;
        repeat(2) @(negedge WR_CLK2);
        RESET2 = 0;
      end
    join

    fork 
      begin
        $display("PROG_EMPTY_THRESH1 = %d", PROG_EMPTY_THRESH1);
		    $display("PROG_FULL_THRESH1 = %d", PROG_FULL_THRESH1);
		    $display("--------------------------------------------");
        $display("check_flags_FIFO1");
        $display("--------------------------------------------");
        if (is_fifo1_async) begin
          async_check_flags_fifo1();             // asynchronous
          async_check_flags_fifo1();             // asynchronous
        end 
        else begin
          sync_check_flags_fifo1();                // synchronous        
        end

      end
      begin
        $display("PROG_EMPTY_THRESH2 = %d", PROG_EMPTY_THRESH2);
		    $display("PROG_FULL_THRESH2 = %d", PROG_FULL_THRESH2);
        $display("--------------------------------------------");
        $display("check_flags_FIFO2");
        $display("--------------------------------------------");
        if (is_fifo2_async) begin
           async_check_flags_fifo2();   // asynchronous
           async_check_flags_fifo2();   // asynchronous        
        end
        else begin
          sync_check_flags_fifo2();      // synchronous        
        end

      end
    join

    test_status(error);
    #100;
    $finish();

  end

integer idx1=0;
integer WgtR_Ratio1=0;
integer RgtW_Ratio1=0;
integer prog_f1=0;
bit count_clk1=0;
bit count_clk11=0;
bit check1=0;


integer idx2=0;
integer WgtR_Ratio2=0;
integer RgtW_Ratio2=0;
integer prog_f2=0;
bit count_clk2=0;
bit count_clk12=0;
bit check2=0;

	initial begin
		$dumpfile("wave.vcd");
		$dumpvars(0,FIFO18KX2_tb);

//  for (int idx = 0; idx < 10; idx = idx + 1)
    // $dumpvars(0,FIFO18KX2_tb.fifo18k_inst.async.tdp_ram18kx2_inst1.RAM1_DATA[idx]);
	end




/**********************************  ASYNC FIFO1  ****************************************/
      /********************************************************************************/
             /*************************************************************/
                         /*************************************/
                                /**********************/

integer count_fifo1=0;
integer count1_fifo1=0;

task async_check_flags_fifo1();

    WR_EN1 = 0;
    RD_EN1 = 0;
    RESET1 = 1;
    repeat(2) @(posedge WR_CLK1);
    repeat(2) @(posedge WR_CLK1);
    RESET1 = 0;
//Assertion empty_ewm_fifo_flags failed!
if(PROG_EMPTY_THRESH1>0) begin
    if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b1010_0000)
      begin $display("ERROR: EMPTY AND PROG EMPTY ARE NOT ASSERTED IN START"); error=error+1; end
    end
    else begin
    if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b1000_0000)
      begin $display("ERROR: EMPTY SHOULD BE ASSERTED IN START"); error=error+1; end
    end
    
    $display("CHECK FLAGS: Checking Flags on Each PUSH/POP Operation---------------------");


    assign WgtR_Ratio1 = (DATA_READ_WIDTH1>=DATA_WRITE_WIDTH1)?  1: DATA_WRITE_WIDTH1/DATA_READ_WIDTH1; // For example ? = 4
    assign RgtW_Ratio1 = (DATA_WRITE_WIDTH1>=DATA_READ_WIDTH1)?  1: DATA_READ_WIDTH1/DATA_WRITE_WIDTH1; // For example ? = 4

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

if(DATA_WRITE_WIDTH1==DATA_READ_WIDTH1) begin

// Empty De Assert
    for (int i=0; i<DEPTH_WRITE1; i++) begin

     
      if(i==0) begin

          fork 
          begin
           push11();
          end 
          begin
            wait(count_clk1); 
            repeat(3)@(posedge RD_CLK1);
            @(negedge RD_CLK1);                                   
          end
          join;
          if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,OVERFLOW1} !== 6'b010_000) begin      
                  begin  $display("ERROR PUSH: EMPTY SHOULD BE DE-ASSERTED )"); error=error+1; end
          end
          count_clk1=0;
      end
      if(i==1) begin

          fork 
          begin
           push11();
          end 
          begin
            wait(count_clk1); 
            repeat(3)@(posedge RD_CLK1);
            @(negedge RD_CLK1);                                   
            if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,OVERFLOW1} !== 6'b000_000) begin      
            begin $display("ERROR PUSH: ALMOST EMPTY SHOULD BE DE-ASSERTED AFTER 2nd PUSH"); error=error+1; end
          end
          end
          join;
          count_clk1=0;
      end

      if(i>1 & i<PROG_EMPTY_THRESH1-1) begin
       push11();
       count_clk1=0;
      end

      if(i==PROG_EMPTY_THRESH1-1) begin

          fork 
          begin
           push11();
          end 
          begin
            wait(count_clk1); 
            repeat(4)@(posedge RD_CLK1);
            @(negedge RD_CLK1);                                   
            if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,OVERFLOW1} !== 6'b000_000) begin      
            begin $display("ERROR PUSH1: ALL FLAGS SHOULD BE DE-ASSERTED"); error=error+1; end
          end
          end
          join;
          count_clk1=0;
      end

      if(i>PROG_EMPTY_THRESH1-1 & i< DEPTH_WRITE1 - PROG_FULL_THRESH1) begin
       push11();
       count_clk1=0;
      end

      if(i==DEPTH_WRITE1- PROG_FULL_THRESH1) begin

       push11();
       count_clk1=0;
          if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,OVERFLOW1} !== 6'b000_000) begin      
              begin $display("ERROR PUSH: ONLY PROG_FULL SHOULD BE ASSERTED"); error=error+1; end
          end
                               
      end

      if(i>DEPTH_WRITE1- PROG_FULL_THRESH1 & i< DEPTH_WRITE1 -2) begin
       push11();
      end

      if(i==DEPTH_WRITE1- 2) begin
          push11();
          count_clk1=0;
          if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,OVERFLOW1} !== 8'b000_010) begin      
              begin $display("ERROR PUSH: PROG_FULL AND ALMOST FULL SHOULD BE ASSERTED ONLY"); error=error+1; end
          end                     
      end

      if(i==DEPTH_WRITE1- 1) begin
          push11();
          count_clk1=0;
          if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,OVERFLOW1} !== 8'b000_100) begin      
              begin $display("ERROR PUSH: PROG_FULL AND FULL SHOULD BE ASSERTED ONLY"); error=error+1; end
          end                     
      end

      if(do_overflow1) begin
        repeat(1) begin
          push11();
        end
      end
  end

end



// //***********************************************************************************************************************//

if(DATA_READ_WIDTH1 == DATA_WRITE_WIDTH1) begin

// FULL DE-ASSERT

  for (int i=0; i<DEPTH_READ1; i++) begin

        
        if(i==0) begin
          
          compare_pop_data_fifo1();
          fork 
          begin
           @(negedge RD_CLK1);
           RD_EN1=1;
           @(posedge RD_CLK1);
           count_clk1=1;
           @(negedge RD_CLK1);
           RD_EN1=0;
           count_enteries_pop_fifo1=count_enteries_pop_fifo1+1;
           compare_pop_data_fifo1();
          end 
          begin
            wait(count_clk1); 
            repeat(3)@(posedge WR_CLK1);
            @(negedge WR_CLK1);                                   
          end
          join;
          if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b0000_0110) begin
            begin $display("ERROR POP: ONLY PROG FULL and ALMOST FULL SHOULD BE ASSERTED %0b", {EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1}); error=error+1; end
          end
           count_clk1=0;
        end


        if(i==1) begin
       
          fork 
          begin
           @(negedge RD_CLK1);
           RD_EN1=1;
           @(posedge RD_CLK1);
           count_clk1=1;
           @(negedge RD_CLK1);
           RD_EN1=0;
           count_enteries_pop_fifo1=count_enteries_pop_fifo1+1;
           compare_pop_data_fifo1();
          end 
          begin
            wait(count_clk1); 
            repeat(3)@(posedge WR_CLK1);
            @(negedge WR_CLK1);                                   
          end
          join;
          if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b0000_0010) begin
            begin $display("ERROR POP: ONLY PROG FULL SHOULD BE ASSERTED %0b", {EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1}); error=error+1; end
          end
          count_clk1=0;

        end

        if(i>1 & i<PROG_FULL_THRESH1-1) begin
          pop11();
          count_enteries_pop_fifo1=count_enteries_pop_fifo1+1;
          compare_pop_data_fifo1();
        end
  
        if(i==PROG_FULL_THRESH1-1) begin
          fork 
          begin
           @(negedge RD_CLK1);
           RD_EN1=1;
           @(posedge RD_CLK1);
           count_clk1=1;
           @(negedge RD_CLK1);
           RD_EN1=0;
          count_enteries_pop_fifo1=count_enteries_pop_fifo1+1;
          compare_pop_data_fifo1();
          end 
          begin
            wait(count_clk1); 
            repeat(4)@(posedge WR_CLK1);
            @(negedge WR_CLK1);                                   
          end
          join;
          if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b0000_0000) begin
            begin $display("ERROR POP: ALL FLAGS SHOULD BE DEASSERTED %0b", {EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1}); error=error+1; end
          end
           count_clk1=0;
        end

       if(i>PROG_FULL_THRESH1-1 & i < DEPTH_READ1-PROG_EMPTY_THRESH1) begin
          pop11();
          count_enteries_pop_fifo1=count_enteries_pop_fifo1+1;
          compare_pop_data_fifo1();
        end        

        if(i==DEPTH_READ1-PROG_EMPTY_THRESH1)  begin
          fork 
          begin
           @(negedge RD_CLK1);
           RD_EN1=1;
           @(posedge RD_CLK1);
           count_clk1=1;
           @(negedge RD_CLK1);
           RD_EN1=0;
           count_enteries_pop_fifo1=count_enteries_pop_fifo1+1;
           compare_pop_data_fifo1();

          end 
          begin
            wait(count_clk1);
            @(negedge RD_CLK1); 
            if(PROG_EMPTY_THRESH1 >2) begin
              if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b0010_0000) begin
                begin $display("ERROR POP: ONLY PROG EMPTY SHOULD BE ASSERTED %0b", {EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1}); error=error+1; end
              end
            end
            if(PROG_EMPTY_THRESH1 ==2) begin
              if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b0110_0000) begin
                begin $display("ERROR POP: ONLY PROG EMPTY  AND ALMOST EMPTY SHOULD BE ASSERTED %0b", {EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1}); error=error+1;  $display ("??????"); end
              end
            end
          end
          join;
           count_clk1=0;
        end

       if(i>DEPTH_READ1-PROG_EMPTY_THRESH1 & i < DEPTH_READ1-1) begin
          pop11();
          count_enteries_pop_fifo1=count_enteries_pop_fifo1+1;
          compare_pop_data_fifo1();
        end 


        if(i==DEPTH_READ1-1)  begin
          fork 
          begin
           @(negedge RD_CLK1);
           RD_EN1=1;
           @(posedge RD_CLK1);
           count_clk1=1;
           @(negedge RD_CLK1);
           RD_EN1=0;
          count_enteries_pop_fifo1=count_enteries_pop_fifo1+1;
          compare_pop_data_fifo1();
          end 
          begin
            wait(count_clk1);
            @(negedge RD_CLK1); 
            if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b1010_0000) begin
              begin $display("ERROR : Only PROG_EMPTY AND ALMOST EMPTED SHOULD BE ASSERTED %0b", {EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1}); error=error+1; end
            end
          end
          join;
           count_clk1=0;
        end

      if(do_underflow1) begin
          @(negedge RD_CLK1);
           RD_EN1=1;
           @(posedge RD_CLK1);
           count_clk1=1;
           @(negedge RD_CLK1);
           RD_EN1=0;
          count_enteries_pop_fifo1=count_enteries_pop_fifo1+1;
          compare_pop_data_fifo1();
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



if(  DATA_WRITE_WIDTH1 > DATA_READ_WIDTH1  ) begin

for (int i=0; i<DEPTH_WRITE1; i++) begin  //DEPTH_WRITE

  if(i==0) begin

          fork 
          begin
           push11();
          end 
          begin
            wait(count_clk1); 
            repeat(3)@(posedge RD_CLK1);
            @(negedge RD_CLK1);                                   
                    if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b0010_0000) begin      
                  begin  $display("ERROR PUSH: ONLY PROG EMPTY SHOULD BE ASSERTED"); error=error+1; end
          end
          end
          begin
            
          if(PROG_EMPTY_THRESH1 <= (i+1)*WgtR_Ratio1 ) begin
          wait(count_clk1);   
          repeat(4)@(posedge RD_CLK1);
          @(negedge RD_CLK1);
          if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b0000_0000) begin      
                begin $display("ERROR PUSH: ALL FLAGS DEASSERTED"); error=error+1; end
          end
          end
          end
          join;
          count_clk1=0;
  end
  
  if(i>0 & i<DEPTH_WRITE1-PROG_FULL_THRESH1) begin

      if(PROG_EMPTY_THRESH1 < WgtR_Ratio1*(i+1) & PROG_EMPTY_THRESH1 > WgtR_Ratio1*(i+2)) begin
            fork 
              begin
              push11();
              end 
              begin
                wait(count_clk1); 
                repeat(4)@(posedge RD_CLK1);
                @(negedge RD_CLK1);                                   
                        if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b0000_0000) begin      
                      begin  $display("ERROR PUSH: ALL DEASSERTED"); error=error+1; end
              end
              end
              join;
              count_clk1=0;
        end
        else begin
            push11();
            count_clk1=0;
        end
  end


  if(i==DEPTH_WRITE1-PROG_FULL_THRESH1) begin

          fork 
          begin
           push11();
          end 
          begin
            wait(count_clk1);  
            @(negedge WR_CLK1);
            if(PROG_FULL_THRESH1 >2) begin                                
              if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b0000_0010) begin      
              begin  $display("ERROR PUSH: ONLY PROG FULL SHOULD BE ASSERTED"); error=error+1; end
              end
            end
            else begin
              if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b0000_0110) begin      
              begin  $display("ERROR PUSH: ONLY PROG FULL AND ALMOST FULL SHOULD BE ASSERTED"); error=error+1; end
              end
            end
          end
          join;
          count_clk1=0;
  end

  if(i>DEPTH_WRITE1-PROG_FULL_THRESH1 & i<DEPTH_WRITE1-2) begin
          push11();
          count_clk1=0;
  end

  if(i==DEPTH_WRITE1-2) begin

          fork 
          begin
           push11();
          end 
          begin
            wait(count_clk1);  
            @(negedge WR_CLK1);                                
              if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b0000_0110) begin      
              begin  $display("ERROR PUSH: ONLY PROG FULL AND ALMOST FULL SHOULD BE ASSERTED"); error=error+1; end
          end
          end
          join;
          count_clk1=0;
  end

  if(i==DEPTH_WRITE1-1) begin

          fork 
          begin
           push11();
          end 
          begin
            wait(count_clk1);  
            @(negedge WR_CLK1);                                
              if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b0000_1010) begin      
              begin  $display("ERROR PUSH: ONLY PROG FULL AND FULL SHOULD BE ASSERTED"); error=error+1; end
          end
          end
          join;
          count_clk1=0;
  end

  if(do_overflow1) begin
    repeat(1) begin
      push11();
    end
  end

end

end

// //*******************************************************************************************************************//

if(DATA_READ_WIDTH1 < DATA_WRITE_WIDTH1) begin

// FULL DE-ASSERT

  for (int i=0; i<DEPTH_READ1; i++) begin


        if(i<WgtR_Ratio1-1) begin
          compare_pop_data_fifo1();
          pop11();
          count_enteries_pop_fifo1=count_enteries_pop_fifo1+1;
        end
        
        if(i==WgtR_Ratio1-1) begin
          
          compare_pop_data_fifo1();
          fork 
          begin
           @(negedge RD_CLK1);
           RD_EN1=1;
           @(posedge RD_CLK1);
           count_clk1=1;
           @(negedge RD_CLK1);
           RD_EN1=0;
           count_enteries_pop_fifo1=count_enteries_pop_fifo1+1;
           compare_pop_data_fifo1();
          end 
          begin
            wait(count_clk1); 
            repeat(3)@(posedge WR_CLK1);
            @(negedge WR_CLK1);                                   
          end
          join;
          if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b0000_0110) begin
            begin $display("ERROR POP: ONLY PROG FULL and ALMOST FULL SHOULD BE ASSERTED %0b", {EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1}); error=error+1; end
          end
           count_clk1=0;
        end

        if(i>WgtR_Ratio1-1 & i <2*WgtR_Ratio1-1) begin
          pop11();
          count_enteries_pop_fifo1=count_enteries_pop_fifo1+1;
          compare_pop_data_fifo1();
        end
        
        if(i==2*WgtR_Ratio1-1) begin
          
          fork 
          begin
           @(negedge RD_CLK1);
           RD_EN1=1;
           @(posedge RD_CLK1);
           count_clk1=1;
           @(negedge RD_CLK1);
           RD_EN1=0;
           count_enteries_pop_fifo1=count_enteries_pop_fifo1+1;
           compare_pop_data_fifo1();
          end 
          begin
            wait(count_clk1); 
            repeat(3)@(posedge WR_CLK1);
            @(negedge WR_CLK1);                                   
          end
          join;
          if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b0000_0010) begin
            begin $display("ERROR POP: ONLY PROG FULL SHOULD BE ASSERTED %0b", {EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1}); error=error+1; end
          end
          count_clk1=0;
        end


        if(i >2*WgtR_Ratio1-1 & i < (PROG_FULL_THRESH1*WgtR_Ratio1)-1) begin
          pop11();
          count_enteries_pop_fifo1=count_enteries_pop_fifo1+1;
          compare_pop_data_fifo1();
        end
        

        if(i==(PROG_FULL_THRESH1*WgtR_Ratio1)-1) begin
          fork 
          begin
           @(negedge RD_CLK1);
           RD_EN1=1;
           @(posedge RD_CLK1);
           count_clk1=1;
           @(negedge RD_CLK1);
           RD_EN1=0;
          count_enteries_pop_fifo1=count_enteries_pop_fifo1+1;
          compare_pop_data_fifo1();
          end 
          begin
            wait(count_clk1); 
            repeat(4)@(posedge WR_CLK1);
            @(negedge WR_CLK1);                                   
          end
          join;
          if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b0000_0000) begin
            begin $display("ERROR POP: ALL FLAGS SHOULD BE DEASSERTED %0b", {EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1}); error=error+1; end
          end
           count_clk1=0;
        end

        if( i> (PROG_FULL_THRESH1*WgtR_Ratio1)-1 & i < DEPTH_READ1 - (PROG_EMPTY_THRESH1)) begin
          pop11();
          count_enteries_pop_fifo1=count_enteries_pop_fifo1+1;
          compare_pop_data_fifo1();
        end
        
      
        if(i==DEPTH_READ1 - PROG_EMPTY_THRESH1)  begin
          fork 
          begin
           @(negedge RD_CLK1);
           RD_EN1=1;
           @(posedge RD_CLK1);
           count_clk1=1;
           @(negedge RD_CLK1);
           RD_EN1=0;
           count_enteries_pop_fifo1=count_enteries_pop_fifo1+1;
           compare_pop_data_fifo1();
          end 
          begin
            wait(count_clk1);
            @(negedge RD_CLK1); 
            if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b0010_0000) begin
              begin $display("ERROR POP: ONLY PROG EMPTY SHOULD BE ASSERTED %0b", {EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1}); error=error+1; end
            end
          end
          join;
           count_clk1=0;
        end

     if( i> DEPTH_READ1 - PROG_EMPTY_THRESH1 & i < DEPTH_READ1 -2 ) begin
          pop11();
          count_enteries_pop_fifo1=count_enteries_pop_fifo1+1;
          compare_pop_data_fifo1();
        end
        
        if(i==DEPTH_READ1-2)  begin
          fork 
          begin
           @(negedge RD_CLK1);
           RD_EN1=1;
           @(posedge RD_CLK1);
           count_clk1=1;
           @(negedge RD_CLK1);
           RD_EN1=0;
           count_enteries_pop_fifo1=count_enteries_pop_fifo1+1;
           compare_pop_data_fifo1();

          end 
          begin
            wait(count_clk1);
            @(negedge RD_CLK1); 
            if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b0110_0000) begin
              begin $display("ERROR POP: Only PROG_EMPTY AND ALMOST EMPTED SHOULD BE ASSERTED %0b", {EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1}); error=error+1; end
            end
          end
          join;
           count_clk1=0;
        end

        if(i==DEPTH_READ1-1)  begin
          fork 
          begin
           @(negedge RD_CLK1);
           RD_EN1=1;
           @(posedge RD_CLK1);
           count_clk1=1;
           @(negedge RD_CLK1);
           RD_EN1=0;
          count_enteries_pop_fifo1=count_enteries_pop_fifo1+1;
          compare_pop_data_fifo1();
          end 
          begin
            wait(count_clk1);
            @(negedge RD_CLK1); 
            if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b1010_0000) begin
              begin $display("ERROR POP: EMPTY AND PROG_EMPTY SHOULD BE DE_ASSERTED ONLY %0b", {EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1}); error=error+1; end
            end
          end
          join;
           count_clk1=0;
        end

      // if(do_underflow1) begin
      //     @(negedge RD_CLK1);
      //      RD_EN1=1;
      //      @(posedge RD_CLK1);
      //      count_clk1=1;
      //      @(negedge RD_CLK1);
      //      RD_EN1=0;
      //     count_enteries_pop_fifo1=count_enteries_pop_fifo1+1;
      //     compare_pop_data_fifo1();
      // end

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



if(DATA_WRITE_WIDTH1 < DATA_READ_WIDTH1) begin

// Empty De Assert
      repeat(RgtW_Ratio1) begin  // 1-4
        push11();
        count_clk1=0;
      end
    repeat(3)@(posedge RD_CLK1);
    @(negedge RD_CLK1);
      if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b0110_0000) begin      
              begin $display("ERROR PUSH: PROG_EMPTY AND ALMOST EMPTY SHOULD BE ASSERTED"); error=error+1; end
      end

// Almost Empty deassert
      repeat(RgtW_Ratio1) begin // 5-8
          push11();
        count_clk1=0;
        end
    repeat(3)@(posedge RD_CLK1);
    @(negedge RD_CLK1); 
      if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b0010_0000) begin      
              begin $display("ERROR PUSH: ONLY PROG EMPTY SHOULD BE ASSERTED"); error=error+1; end
      end

// prog empty de asset // 9-16
    for (int i=RgtW_Ratio1+RgtW_Ratio1; i<(RgtW_Ratio1*PROG_EMPTY_THRESH1); i++ ) begin
      push11();
      count_clk1=0;    
    end
    // if(count>1) begin
    repeat(4)@(posedge RD_CLK1);
    @(negedge RD_CLK1);
    // end
    if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b0000_0000) begin
            begin $display("ERROR PUSH: ALL FLAGS SHOULD BE DE ASSERTED"); error=error+1; end
    end

// prog full assert // 17-4980
    for (int i=(RgtW_Ratio1*PROG_EMPTY_THRESH1) ; i< DEPTH_WRITE1-PROG_FULL_THRESH1+1; i++ ) begin
      push11();
      count_clk1=0;
    end

    // @(negedge RD_CLK1);
    if(PROG_FULL_THRESH1 !=2) begin
    if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b0000_0010) begin
            begin $display("ERROR PUSH: ONLY PROG FULL SHOULD BE ASSERTED"); error=error+1; end
    end
    end

    if(PROG_FULL_THRESH1 ==2) begin
    if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b0000_0110) begin
            begin $display("ERROR PUSH: ONLY PROG FULL AND ALMOST FULL SHOULD BE ASSERTED"); error=error+1; end
    end
    end


  // almost full assert 

    for (int i= DEPTH_WRITE1-PROG_FULL_THRESH1 ; i < DEPTH_WRITE1-2; i++ ) begin
      push11();
      count_clk1=0;  
    end
  
    if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b0000_0110) begin
      begin $display("ERROR PUSH: ONLY PROG FULL AND ALMOST FULL SHOULD BE ASSERTED %0b", {EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1}); error=error+1; end
    end

  // full assert

   repeat(1) begin
    push11();
    count_clk1=0;
   end

    if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b0000_1010) begin
      begin $display("ERROR PUSH: ONLY PROG FULL AND FULL SHOULD BE ASSERTED %0b", {EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1}); error=error+1; end
    end


// overflow

if(do_overflow1) begin
   repeat(1) begin
    push11();
    count_clk1=0;
   end
end

end


// //*****************************************************************************************************************//


if(DATA_READ_WIDTH1 > DATA_WRITE_WIDTH1) begin

// FULL DE-ASSERT

  for (int i=0; i<DEPTH_READ1; i++) begin


      if(i==0 ) begin
          compare_pop_data_fifo1();
          fork begin
           @(negedge RD_CLK1);
           RD_EN1=1;
           @(posedge RD_CLK1);
           count_clk1=1;
           @(negedge RD_CLK1);
           RD_EN1=0;
          count_enteries_pop_fifo1=count_enteries_pop_fifo1+1;
          compare_pop_data_fifo1();
          end 
          begin
            wait(count_clk1); 
            repeat(3)@(posedge WR_CLK1);
            @(negedge WR_CLK1);                                   
          end
          begin

          if(PROG_FULL_THRESH1<=1*RgtW_Ratio1) begin
            wait(count_clk1); 
            repeat(4)@(posedge WR_CLK1);
                @(negedge WR_CLK1);              
          
              if(PROG_FULL1 !== 1'b0) begin
                begin $display("ERROR POP: PROG FULL BE DE ASSRTED %0b", {EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1}); error=error+1; end            
              end
          end  
          end
          join;
          if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,OVERFLOW1} !== 7'b0000_000) begin
            begin   $display("ERROR POP: ALL FLAGS SHOULD BE DE-ASSERTED %0b", {EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1}); error=error+1; end
          end
          count_clk1=0;
      end

  if(i>0 & i<DEPTH_READ1-PROG_EMPTY_THRESH1) begin

      if(PROG_FULL_THRESH1 < RgtW_Ratio1*(i+1) & PROG_FULL_THRESH1 > RgtW_Ratio1*(i+2)) begin
            fork 
              begin
              @(negedge RD_CLK1);
              RD_EN1=1;
              @(posedge RD_CLK1);
              count_clk1=1;
              @(negedge RD_CLK1);
              RD_EN1=0;
              count_enteries_pop_fifo1=count_enteries_pop_fifo1+1;
              compare_pop_data_fifo1();
              end 
              begin
                wait(count_clk1); 
                repeat(4)@(posedge WR_CLK1);
                @(negedge WR_CLK1);                                   
                        if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b0000_0000) begin      
                      begin  $display("ERROR PUSH: ONLY PROG FULL AND ALMOST FULL SHOULD BE ASSERTED"); error=error+1; end
              end
              end
              join;
              count_clk1=0;
        end
        else begin
            pop11();
            count_enteries_pop_fifo1=count_enteries_pop_fifo1+1;
            compare_pop_data_fifo1();  
            count_clk1=0;
        end
  end


  if(i==DEPTH_READ1-PROG_EMPTY_THRESH1) begin

          fork 
          begin
              @(negedge RD_CLK1);
              RD_EN1=1;
              @(posedge RD_CLK1);
              count_clk1=1;
              @(negedge RD_CLK1);
              RD_EN1=0;
            count_enteries_pop_fifo1=count_enteries_pop_fifo1+1;
            compare_pop_data_fifo1();  
          end 
          begin
            wait(count_clk1);  
            @(negedge RD_CLK1);
            if(PROG_EMPTY_THRESH1 >2) begin                                
              if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b0010_0000) begin      
              begin  $display("ERROR POP: ONLY PROG EMPTY SHOULD BE ASSERTED"); error=error+1; end
              end
            end
            else begin
              if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b0110_0000) begin      
              begin  $display("ERROR POP: ONLY PROG EMPTY AND ALMOST EMPTY SHOULD BE ASSERTED"); error=error+1; end
              end
            end
          end
          join;
          count_clk1=0;
  end


  if(i>DEPTH_READ1-PROG_EMPTY_THRESH1 & i <DEPTH_READ1-2) begin


              @(negedge RD_CLK1);
              RD_EN1=1;
              @(posedge RD_CLK1);
              count_clk1=1;
              @(negedge RD_CLK1);
              RD_EN1=0;
            count_enteries_pop_fifo1=count_enteries_pop_fifo1+1;
            compare_pop_data_fifo1(); 
            count_clk1=0; 
  end

  if(i==DEPTH_READ1-2) begin

          fork 
          begin
              @(negedge RD_CLK1);
              RD_EN1=1;
              @(posedge RD_CLK1);
              count_clk1=1;
              @(negedge RD_CLK1);
              RD_EN1=0;
            count_enteries_pop_fifo1=count_enteries_pop_fifo1+1;
            compare_pop_data_fifo1();  
          end 
          begin
            wait(count_clk1);  
            @(negedge RD_CLK1);
              if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b0110_0000) begin      
              begin  $display("ERROR POP: ONLY PROG EMPTY AND ALMOST EMPTY SHOULD BE ASSERTED"); error=error+1; end
              end
          end
          join;
          count_clk1=0;
  end
  
    if(i==DEPTH_READ1-1) begin

          fork 
          begin
              @(negedge RD_CLK1);
              RD_EN1=1;
              @(posedge RD_CLK1);
              count_clk1=1;
              @(negedge RD_CLK1);
              RD_EN1=0;
            count_enteries_pop_fifo1=count_enteries_pop_fifo1+1;
            compare_pop_data_fifo1();  
          end 
          begin
            wait(count_clk1);  
            @(negedge RD_CLK1);
              if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b1010_0000) begin      
              begin  $display("ERROR POP: ONLY PROG EMPTY AND EMPTY SHOULD BE ASSERTED"); error=error+1; end
              end
          end
          join;
          count_clk1=0;
  end

      if(do_underflow1) begin
          @(negedge RD_CLK1);
           RD_EN1=1;
           @(posedge RD_CLK1);
           count_clk1=1;
           @(negedge RD_CLK1);
           RD_EN1=0;
          count_enteries_pop_fifo1=count_enteries_pop_fifo1+1;
          compare_pop_data_fifo1();
      end


end
end
endtask


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

task async_check_flags_fifo2();

    WR_EN2 = 0;
    RD_EN2 = 0;
    RESET2 = 1;
    repeat(2) @(posedge WR_CLK2);
    repeat(2) @(posedge WR_CLK2);
    RESET2 = 0;
//Assertion empty_ewm_fifo_flags failed!
if(PROG_EMPTY_THRESH2>0) begin
    if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b1010_0000)
      begin $display("ERROR: EMPTY AND PROG EMPTY ARE NOT ASSERTED IN START"); error=error+1; end
    end
    else begin
    if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b1000_0000)
      begin $display("ERROR: EMPTY SHOULD BE ASSERTED IN START"); error=error+1; end
    end
    
    $display("CHECK FLAGS: Checking Flags on Each PUSH/POP Operation---------------------");


    assign WgtR_Ratio2 = (DATA_READ_WIDTH2>=DATA_WRITE_WIDTH2)?  1: DATA_WRITE_WIDTH2/DATA_READ_WIDTH2; // For example ? = 4
    assign RgtW_Ratio2 = (DATA_WRITE_WIDTH2>=DATA_READ_WIDTH2)?  1: DATA_READ_WIDTH2/DATA_WRITE_WIDTH2; // For example ? = 4

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

if(DATA_WRITE_WIDTH2==DATA_READ_WIDTH2) begin

// Empty De Assert
    for (int i=0; i<DEPTH_WRITE2; i++) begin

     
      if(i==0) begin

          fork 
          begin
           push22();
          end 
          begin
            wait(count_clk2); 
            repeat(3)@(posedge RD_CLK2);
            @(negedge RD_CLK2);                                   
          end
          join;
          if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b0110_0000) begin      
                  begin  $display("ERROR PUSH: EMPTY SHOULD BE DE-ASSERTED )"); error=error+1; end
          end
          count_clk2=0;
      end


      if(i==1) begin

          fork 
          begin
           push22();
          end 
          begin
            wait(count_clk2); 
            repeat(3)@(posedge RD_CLK2);
            @(negedge RD_CLK2);                                   
            if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b0010_0000) begin      
            begin $display("ERROR PUSH: ALMOST EMPTY SHOULD BE DE-ASSERTED AFTER 2nd PUSH"); error=error+1; end
          end
          end
          join;
          count_clk2=0;
      end

      if(i>1 & i<PROG_EMPTY_THRESH2-1) begin
       push22();
       count_clk2=0;
      end

      if(i==PROG_EMPTY_THRESH2-1) begin

          fork 
          begin
           push22();
          end 
          begin
            wait(count_clk2); 
            repeat(4)@(posedge RD_CLK2);
            @(negedge RD_CLK2);                                   
            if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b0000_0000) begin      
            begin $display("ERROR PUSH1: ALL FLAGS SHOULD BE DE-ASSERTED"); error=error+1; end
          end
          end
          join;
          count_clk2=0;
      end

      if(i>PROG_EMPTY_THRESH2-1 & i< DEPTH_WRITE2 - PROG_FULL_THRESH2) begin
       push22();
       count_clk2=0;
      end

      if(i==DEPTH_WRITE2- PROG_FULL_THRESH2) begin

       push22();
       count_clk2=0;
          if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b0000_0010) begin      
              begin $display("ERROR PUSH: ONLY PROG_FULL SHOULD BE ASSERTED"); error=error+1; end
          end
                               
      end

      if(i>DEPTH_WRITE2- PROG_FULL_THRESH2 & i< DEPTH_WRITE2 -2) begin
       push22();
       count_clk2=0;
      end

      if(i==DEPTH_WRITE2- 2) begin
          push22();
          count_clk2=0;
          if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b000_0110) begin      
              begin $display("ERROR PUSH: PROG_FULL AND ALMOST FULL SHOULD BE ASSERTED ONLY"); error=error+1; end
          end                     
      end

      if(i==DEPTH_WRITE2- 1) begin
          push22();
          count_clk2=0;
          if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b0000_1010) begin      
              begin $display("ERROR PUSH: PROG_FULL AND FULL SHOULD BE ASSERTED ONLY"); error=error+1; end
          end                     
      end

      if(do_overflow2) begin
        repeat(1) begin
          push22();
        end
      end
  end

end



// //***********************************************************************************************************************//

if(DATA_READ_WIDTH2 == DATA_WRITE_WIDTH2) begin

// FULL DE-ASSERT

  for (int i=0; i<DEPTH_READ2; i++) begin

        
        if(i==0) begin
          
          compare_pop_data_fifo2();
          fork 
          begin
           @(negedge RD_CLK2);
           RD_EN2=1;
           @(posedge RD_CLK2);
           count_clk2=1;
           @(negedge RD_CLK2);
           RD_EN2=0;
           count_enteries_pop_fifo2=count_enteries_pop_fifo2+1;
           compare_pop_data_fifo2();
          end 
          begin
            wait(count_clk2); 
            repeat(3)@(posedge WR_CLK2);
            @(negedge WR_CLK2);                                   
          end
          join;
          if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b0000_0110) begin
            begin $display("ERROR POP: ONLY PROG FULL and ALMOST FULL SHOULD BE ASSERTED %0b", {EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2}); error=error+1; end
          end
           count_clk2=0;
        end

        if(i==1) begin
       
          fork 
          begin
           @(negedge RD_CLK2);
           RD_EN2=1;
           @(posedge RD_CLK2);
           count_clk2=1;
           @(negedge RD_CLK2);
           RD_EN2=0;
           count_enteries_pop_fifo2=count_enteries_pop_fifo2+1;
           compare_pop_data_fifo2();
          end 
          begin
            wait(count_clk2); 
            repeat(3)@(posedge WR_CLK2);
            @(negedge WR_CLK2);                                   
          end
          join;
          if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b0000_0010) begin
            begin $display("ERROR POP: ONLY PROG FULL SHOULD BE ASSERTED %0b", {EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2}); error=error+1; end
          end
          count_clk2=0;
        end

        if(i>1 & i<PROG_FULL_THRESH2-1) begin
          pop22();
          count_enteries_pop_fifo2=count_enteries_pop_fifo2+1;
          compare_pop_data_fifo2();
                    count_clk2=0;

        end
  
        if(i==PROG_FULL_THRESH2-1) begin
          fork 
          begin
           @(negedge RD_CLK2);
           RD_EN2=1;
           @(posedge RD_CLK2);
           count_clk2=1;
           @(negedge RD_CLK2);
           RD_EN2=0;
          count_enteries_pop_fifo2=count_enteries_pop_fifo2+1;
          compare_pop_data_fifo2();
          end 
          begin
            wait(count_clk2); 
            repeat(4)@(posedge WR_CLK2);
            @(negedge WR_CLK2);                                   
          end
          join;
          if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b0000_0000) begin
            begin $display("ERROR POP: ALL FLAGS SHOULD BE DEASSERTED %0b", {EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1}); error=error+1; end
          end
           count_clk2=0;
        end

       if(i>PROG_FULL_THRESH2-1 & i < DEPTH_READ2-PROG_EMPTY_THRESH2) begin
          pop22();
          count_enteries_pop_fifo2=count_enteries_pop_fifo2+1;
          compare_pop_data_fifo2();
                    count_clk2=0;

        end        

        if(i==DEPTH_READ2-PROG_EMPTY_THRESH2)  begin
          fork 
          begin
           @(negedge RD_CLK2);
           RD_EN2=1;
           @(posedge RD_CLK2);
           count_clk2=1;
           @(negedge RD_CLK2);
           RD_EN2=0;
           count_enteries_pop_fifo2=count_enteries_pop_fifo2+1;
           compare_pop_data_fifo2();

          end 
          begin
            wait(count_clk2);
            @(negedge RD_CLK2); 
            if(PROG_EMPTY_THRESH2 >2) begin
              if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b0010_0000) begin
                begin $display("ERROR POP: ONLY PROG EMPTY SHOULD BE ASSERTED %0b", {EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2}); error=error+1; end
              end
            end
            if(PROG_EMPTY_THRESH1 ==2) begin
              if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b0110_0000) begin
                begin $display("ERROR POP: ONLY PROG EMPTY  AND ALMOST EMPTY SHOULD BE ASSERTED %0b", {EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2}); error=error+1;  $display ("??????"); end
              end
            end
          end
          join;
           count_clk2=0;
        end

       if(i>DEPTH_READ2-PROG_EMPTY_THRESH2 & i < DEPTH_READ2-1) begin
          pop22();
          count_enteries_pop_fifo2=count_enteries_pop_fifo2+1;
          compare_pop_data_fifo2();
                    count_clk2=0;

        end 

        if(i==DEPTH_READ2-1)  begin
          fork 
          begin
           @(negedge RD_CLK2);
           RD_EN2=1;
           @(posedge RD_CLK2);
           count_clk2=1;
           @(negedge RD_CLK2);
           RD_EN2=0;
          count_enteries_pop_fifo2=count_enteries_pop_fifo2+1;
          compare_pop_data_fifo2();
          end 
          begin
            wait(count_clk2);
            @(negedge RD_CLK2); 
            if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b1010_0000) begin
              begin $display("ERROR : Only PROG_EMPTY AND ALMOST EMPTED SHOULD BE ASSERTED %0b", {EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2}); error=error+1; end
            end
          end
          join;
           count_clk2=0;
        end

      if(do_underflow2) begin
          @(negedge RD_CLK2);
           RD_EN2=1;
           @(posedge RD_CLK2);
           count_clk2=1;
           @(negedge RD_CLK2);
           RD_EN2=0;
          count_enteries_pop_fifo2=count_enteries_pop_fifo2+1;
          compare_pop_data_fifo2();
      end
  end

end


// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

   
// /////////////     //          //       /////////    //      //                       ////////////     //////////     ////////////   
// //         //     //          //    //              //      //                       //         //   //       //     //         //
// //         //     //          //    //              //      //                       //         //   //       //     //         //
// //         //     //          //    //              //////////    =============      //         //   //       //     //         //
// /////////////     //          //    ////////////    //      //                ||     ////////////    //       //     ////////////
// //                //          //               //   //      //                ||     //              //       //     // 
// //                //          //               //   //      //    =============      //              //       //     // 
// //                  // // // //     ////////////    //      //                       //              ///////////     // 
// //                     

// //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



if(  DATA_WRITE_WIDTH2 > DATA_READ_WIDTH2  ) begin

for (int i=0; i<DEPTH_WRITE2; i++) begin  //DEPTH_WRITE

  if(i==0) begin

          fork 
          begin
           push22();
          end 
          begin
            wait(count_clk2); 
            repeat(3)@(posedge RD_CLK2);
            @(negedge RD_CLK2);                                   
                    if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2}!== 8'b0010_0000) begin      
                  begin  $display("ERROR PUSH: ONLY PROG EMPTY SHOULD BE ASSERTED"); error=error+1; end
          end
          end
          begin
            
          if(PROG_EMPTY_THRESH2 <= (i+1)*WgtR_Ratio2 ) begin
          wait(count_clk2);   
          repeat(4)@(posedge RD_CLK2);
          @(negedge RD_CLK2);
          if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2}!== 8'b0000_0000) begin      
                begin $display("ERROR PUSH: ALL FLAGS DEASSERTED"); error=error+1; end
          end
          end
          end
          join;
          count_clk2=0;
  end
  
  if(i>0 & i<DEPTH_WRITE2-PROG_FULL_THRESH2) begin

      if(PROG_EMPTY_THRESH2 < WgtR_Ratio2*(i+1) & PROG_EMPTY_THRESH2 > WgtR_Ratio2*(i+2)) begin
            fork 
              begin
              push22();
              end 
              begin
                wait(count_clk2); 
                repeat(4)@(posedge RD_CLK2);
                @(negedge RD_CLK2);                                   
                        if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b0000_0000) begin      
                      begin  $display("ERROR PUSH: ALL DEASSERTED"); error=error+1; end
              end
              end
              join;
              count_clk1=0;
        end
        else begin
            push22();
            count_clk2=0;
        end
  end

  if(i==DEPTH_WRITE2-PROG_FULL_THRESH2) begin

          fork 
          begin
           push22();
          end 
          begin
            wait(count_clk2);  
            @(negedge WR_CLK2);
            if(PROG_FULL_THRESH2 >2) begin                                
              if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b0000_0010) begin      
              begin  $display("ERROR PUSH: ONLY PROG FULL SHOULD BE ASSERTED"); error=error+1; end
              end
            end
            else begin
              if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b0000_0110) begin      
              begin  $display("ERROR PUSH: ONLY PROG FULL AND ALMOST FULL SHOULD BE ASSERTED"); error=error+1; end
              end
            end
          end
          join;
          count_clk2=0;
  end

  if(i>DEPTH_WRITE2-PROG_FULL_THRESH2 & i<DEPTH_WRITE2-2) begin
          push22();
          count_clk2=0;
  end

  if(i==DEPTH_WRITE2-2) begin

          fork 
          begin
           push22();
          end 
          begin
            wait(count_clk2);  
            @(negedge WR_CLK2);                                
              if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b0000_0110) begin      
              begin  $display("ERROR PUSH: ONLY PROG FULL AND ALMOST FULL SHOULD BE ASSERTED"); error=error+1; end
          end
          end
          join;
          count_clk2=0;
  end

  if(i==DEPTH_WRITE2-1) begin

          fork 
          begin
           push22();
          end 
          begin
            wait(count_clk2);  
            @(negedge WR_CLK2);                                
              if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b0000_1010) begin      
              begin  $display("ERROR PUSH: ONLY PROG FULL AND FULL SHOULD BE ASSERTED"); error=error+1; end
          end
          end
          join;
          count_clk2=0;
  end

  if(do_overflow2) begin
    repeat(1) begin
      push22();
    end
  end

end

end

// // //*******************************************************************************************************************//

if(DATA_READ_WIDTH2 < DATA_WRITE_WIDTH2) begin

// FULL DE-ASSERT

  for (int i=0; i<DEPTH_READ2; i++) begin


        if(i<WgtR_Ratio2-1) begin
          compare_pop_data_fifo2();
          pop22();
          count_enteries_pop_fifo2=count_enteries_pop_fifo2+1;
        end
        
        if(i==WgtR_Ratio2-1) begin
          
          compare_pop_data_fifo2();
          fork 
          begin
           @(negedge RD_CLK2);
           RD_EN2=1;
           @(posedge RD_CLK2);
           count_clk2=1;
           @(negedge RD_CLK2);
           RD_EN2=0;
           count_enteries_pop_fifo2=count_enteries_pop_fifo2+1;
           compare_pop_data_fifo2();
          end 
          begin
            wait(count_clk2); 
            repeat(3)@(posedge WR_CLK2);
            @(negedge WR_CLK2);                                   
          end
          join;
          if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b0000_0110) begin
            begin $display("ERROR POP: ONLY PROG FULL and ALMOST FULL SHOULD BE ASSERTED %0b", {EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2}); error=error+1; end
          end
           count_clk2=0;
        end

        if(i>WgtR_Ratio2-1 & i <2*WgtR_Ratio2-1) begin
          pop22();
          count_enteries_pop_fifo2=count_enteries_pop_fifo2+1;
          compare_pop_data_fifo2();
        end
        
        if(i==2*WgtR_Ratio2-1) begin
          
          fork 
          begin
           @(negedge RD_CLK2);
           RD_EN2=1;
           @(posedge RD_CLK2);
           count_clk2=1;
           @(negedge RD_CLK2);
           RD_EN2=0;
           count_enteries_pop_fifo2=count_enteries_pop_fifo2+1;
           compare_pop_data_fifo2();
          end 
          begin
            wait(count_clk2); 
            repeat(3)@(posedge WR_CLK2);
            @(negedge WR_CLK2);                                   
          end
          join;
          if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b0000_0010) begin
            begin $display("ERROR POP: ONLY PROG FULL SHOULD BE ASSERTED %0b", {EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2}); error=error+1; end
          end
          count_clk2=0;
        end


        if(i >2*WgtR_Ratio2-1 & i < (PROG_FULL_THRESH2*WgtR_Ratio2)-1) begin
          pop22();
          count_enteries_pop_fifo2=count_enteries_pop_fifo2+1;
          compare_pop_data_fifo2();
        end
        

        if(i==(PROG_FULL_THRESH2*WgtR_Ratio2)-1) begin
          fork 
          begin
           @(negedge RD_CLK2);
           RD_EN2=1;
           @(posedge RD_CLK2);
           count_clk2=1;
           @(negedge RD_CLK2);
           RD_EN2=0;
          count_enteries_pop_fifo2=count_enteries_pop_fifo2+1;
          compare_pop_data_fifo2();
          end 
          begin
            wait(count_clk2); 
            repeat(4)@(posedge WR_CLK2);
            @(negedge WR_CLK2);                                   
          end
          join;
          if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b0000_0000) begin
            begin $display("ERROR POP: ALL FLAGS SHOULD BE DEASSERTED %0b", {EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2}); error=error+1; end
          end
           count_clk2=0;
        end

        if( i> (PROG_FULL_THRESH2*WgtR_Ratio2)-1 & i < DEPTH_READ2 - (PROG_EMPTY_THRESH2)) begin
          pop22();
          count_enteries_pop_fifo2=count_enteries_pop_fifo2+1;
          compare_pop_data_fifo2();
        end
        
      
        if(i==DEPTH_READ2 - PROG_EMPTY_THRESH2)  begin
          fork 
          begin
           @(negedge RD_CLK2);
           RD_EN2=1;
           @(posedge RD_CLK2);
           count_clk2=1;
           @(negedge RD_CLK2);
           RD_EN2=0;
           count_enteries_pop_fifo2=count_enteries_pop_fifo2+1;
           compare_pop_data_fifo2();
          end 
          begin
            wait(count_clk2);
            @(negedge RD_CLK2); 
            if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b0010_0000) begin
              begin $display("ERROR POP: ONLY PROG EMPTY SHOULD BE ASSERTED %0b", {EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2}); error=error+1; end
            end
          end
          join;
           count_clk2=0;
        end

     if( i> DEPTH_READ2 - PROG_EMPTY_THRESH2 & i < DEPTH_READ2 -2 ) begin
          pop22();
          count_enteries_pop_fifo2=count_enteries_pop_fifo2+1;
          compare_pop_data_fifo2();
        end
        
        if(i==DEPTH_READ2-2)  begin
          fork 
          begin
           @(negedge RD_CLK2);
           RD_EN2=1;
           @(posedge RD_CLK2);
           count_clk2=1;
           @(negedge RD_CLK2);
           RD_EN2=0;
           count_enteries_pop_fifo2=count_enteries_pop_fifo2+1;
           compare_pop_data_fifo2();

          end 
          begin
            wait(count_clk2);
            @(negedge RD_CLK2); 
            if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b0110_0000) begin
              begin $display("ERROR POP: Only PROG_EMPTY AND ALMOST EMPTED SHOULD BE ASSERTED %0b", {EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2}); error=error+1; end
            end
          end
          join;
           count_clk2=0;
        end

        if(i==DEPTH_READ2-1)  begin
          fork 
          begin
           @(negedge RD_CLK2);
           RD_EN2=1;
           @(posedge RD_CLK2);
           count_clk2=1;
           @(negedge RD_CLK2);
           RD_EN2=0;
          count_enteries_pop_fifo2=count_enteries_pop_fifo2+1;
          compare_pop_data_fifo2();
          end 
          begin
            wait(count_clk2);
            @(negedge RD_CLK2); 
            if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b1010_0000) begin
              begin $display("ERROR POP: EMPTY AND PROG_EMPTY SHOULD BE DE_ASSERTED ONLY %0b", {EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2}); error=error+1; end
            end
          end
          join;
           count_clk2=0;
        end

      if(do_underflow2) begin
          @(negedge RD_CLK2);
           RD_EN2=1;
           @(posedge RD_CLK2);
           count_clk2=1;
           @(negedge RD_CLK2);
           RD_EN2=0;
          count_enteries_pop_fifo2=count_enteries_pop_fifo2+1;
          compare_pop_data_fifo1();
      end

  end

end



// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

   
// /////////////     //          //       /////////    //      //                       ////////////     //////////     ////////////   
// //         //     //          //    //              //      //                       //         //   //       //     //         //
// //         //     //          //    //              //      //                       //         //   //       //     //         //
// //         //     //          //    //              //////////    =============      //         //   //       //     //         //
// /////////////     //          //    ////////////    //      //    ||                 ////////////    //       //     ////////////
// //                //          //               //   //      //    ||                 //              //       //     // 
// //                //          //               //   //      //    =============      //              //       //     // 
// //                  // // // //     ////////////    //      //                       //              ///////////     // 
// //                     

// //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



if(DATA_WRITE_WIDTH2 < DATA_READ_WIDTH2) begin

// Empty De Assert
      repeat(RgtW_Ratio2) begin  // 1-4
        push22();
        count_clk2=0;
      end
    repeat(3)@(posedge RD_CLK2);
    @(negedge RD_CLK2);
      if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b0110_0000) begin      
              begin $display("ERROR PUSH: PROG_EMPTY AND ALMOST EMPTY SHOULD BE ASSERTED"); error=error+1; end
      end

// Almost Empty deassert
      repeat(RgtW_Ratio2) begin // 5-8
          push22();
        count_clk2=0;
        end
    repeat(3)@(posedge RD_CLK2);
    @(negedge RD_CLK2); 
      if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b0010_0000) begin      
              begin $display("ERROR PUSH: ONLY PROG EMPTY SHOULD BE ASSERTED"); error=error+1; end
      end

// prog empty de asset // 9-16
    for (int i=RgtW_Ratio2+RgtW_Ratio2; i<(RgtW_Ratio2*PROG_EMPTY_THRESH2); i++ ) begin
      push22();
      count_clk2=0;    
    end
    // if(count>1) begin
    repeat(4)@(posedge RD_CLK2);
    @(negedge RD_CLK2);
    // end
    if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b0000_0000) begin
            begin $display("ERROR PUSH: ALL FLAGS SHOULD BE DE ASSERTED"); error=error+1; end
    end

// prog full assert // 17-4980
    for (int i=(RgtW_Ratio2*PROG_EMPTY_THRESH2) ; i< DEPTH_WRITE2-PROG_FULL_THRESH2+1; i++ ) begin
      push22();
      count_clk2=0;
    end

    // @(negedge RD_CLK1);
    if(PROG_FULL_THRESH2 !=2) begin
    if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b0000_0010) begin
            begin $display("ERROR PUSH: ONLY PROG FULL SHOULD BE ASSERTED"); error=error+1; end
    end
    end

    if(PROG_FULL_THRESH2 ==2) begin
    if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b0000_0110) begin
            begin $display("ERROR PUSH: ONLY PROG FULL AND ALMOST FULL SHOULD BE ASSERTED"); error=error+1; end
    end
    end


  // almost full assert 

    for (int i= DEPTH_WRITE2-PROG_FULL_THRESH2 ; i < DEPTH_WRITE2-2; i++ ) begin
      push22();
      count_clk2=0;  
    end
  
    if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b0000_0110) begin
      begin $display("ERROR PUSH: ONLY PROG FULL AND ALMOST FULL SHOULD BE ASSERTED %0b", {EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2}); error=error+1; end
    end

  // full assert

   repeat(1) begin
    push22();
    count_clk2=0;
   end

    if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b0000_1010) begin
      begin $display("ERROR PUSH: ONLY PROG FULL AND FULL SHOULD BE ASSERTED %0b", {EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2}); error=error+1; end
    end


// overflow

if(do_overflow2) begin
   repeat(1) begin
    push22();
    count_clk2=0;
   end
end

end


// // //*****************************************************************************************************************//


if(DATA_READ_WIDTH2 > DATA_WRITE_WIDTH2) begin

// FULL DE-ASSERT

  for (int i=0; i<DEPTH_READ2; i++) begin


      if(i==0 ) begin
          compare_pop_data_fifo2();
          fork begin
           @(negedge RD_CLK2);
           RD_EN2=1;
           @(posedge RD_CLK2);
           count_clk2=1;
           @(negedge RD_CLK2);
           RD_EN2=0;
          count_enteries_pop_fifo2=count_enteries_pop_fifo2+1;
          compare_pop_data_fifo2();
          end 
          begin
            wait(count_clk2); 
            repeat(3)@(posedge WR_CLK2);
            @(negedge WR_CLK2);                                   
          end
          begin

          if(PROG_FULL_THRESH2<=1*RgtW_Ratio2) begin
            wait(count_clk2); 
            repeat(4)@(posedge WR_CLK2);
                @(negedge WR_CLK2);              
          
              if(PROG_FULL2 !== 1'b0) begin
                begin $display("ERROR POP: PROG FULL BE DE ASSRTED %0b", {EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2}); error=error+1; end            
              end
          end  
          end
          join;
          if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b0000_0010) begin
            begin   $display("ERROR POP: ALL FLAGS SHOULD BE DE-ASSERTED %0b", {EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2}); error=error+1; end
          end
          count_clk2=0;
      end

  if(i>0 & i<DEPTH_READ2-PROG_EMPTY_THRESH2) begin

      if(PROG_FULL_THRESH2 < RgtW_Ratio2*(i+1) & PROG_FULL_THRESH2 > RgtW_Ratio2*(i+2)) begin
            fork 
              begin
              @(negedge RD_CLK2);
              RD_EN2=1;
              @(posedge RD_CLK2);
              count_clk2=1;
              @(negedge RD_CLK2);
              RD_EN2=0;
              count_enteries_pop_fifo2=count_enteries_pop_fifo2+1;
              compare_pop_data_fifo2();
              end 
              begin
                wait(count_clk2); 
                repeat(4)@(posedge WR_CLK2);
                @(negedge WR_CLK2);                                   
                        if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b0000_0000) begin      
                      begin  $display("ERROR PUSH: ONLY PROG FULL AND ALMOST FULL SHOULD BE ASSERTED"); error=error+1; end
              end
              end
              join;
              count_clk2=0;
        end
        else begin
            pop22();
            count_enteries_pop_fifo2=count_enteries_pop_fifo2+1;
            compare_pop_data_fifo2();  
            count_clk2=0;
        end
  end


  if(i==DEPTH_READ2-PROG_EMPTY_THRESH2) begin

          fork 
          begin
              @(negedge RD_CLK2);
              RD_EN2=1;
              @(posedge RD_CLK2);
              count_clk2=1;
              @(negedge RD_CLK2);
              RD_EN2=0;
            count_enteries_pop_fifo2=count_enteries_pop_fifo2+1;
            compare_pop_data_fifo2();  
          end 
          begin
            wait(count_clk2);  
            @(negedge RD_CLK2);
            if(PROG_EMPTY_THRESH2 >2) begin                                
              if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b0010_0000) begin      
              begin  $display("ERROR POP: ONLY PROG EMPTY SHOULD BE ASSERTED"); error=error+1; end
              end
            end
            else begin
              if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b0110_0000) begin      
              begin  $display("ERROR POP: ONLY PROG EMPTY AND ALMOST EMPTY SHOULD BE ASSERTED"); error=error+1; end
              end
            end
          end
          join;
          count_clk2=0;
  end


  if(i>DEPTH_READ2-PROG_EMPTY_THRESH2 & i <DEPTH_READ2-2) begin


              @(negedge RD_CLK2);
              RD_EN2=1;
              @(posedge RD_CLK2);
              count_clk2=1;
              @(negedge RD_CLK2);
              RD_EN2=0;
            count_enteries_pop_fifo2=count_enteries_pop_fifo2+1;
            compare_pop_data_fifo2(); 
            count_clk2=0; 
  end

  if(i==DEPTH_READ2-2) begin

          fork 
          begin
              @(negedge RD_CLK2);
              RD_EN2=1;
              @(posedge RD_CLK2);
              count_clk2=1;
              @(negedge RD_CLK2);
              RD_EN2=0;
            count_enteries_pop_fifo2=count_enteries_pop_fifo2+1;
            compare_pop_data_fifo2();  
          end 
          begin
            wait(count_clk2);  
            @(negedge RD_CLK2);
              if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b0110_0000) begin      
              begin  $display("ERROR POP: ONLY PROG EMPTY AND ALMOST EMPTY SHOULD BE ASSERTED"); error=error+1; end
              end
          end
          join;
          count_clk2=0;
  end
  
    if(i==DEPTH_READ2-1) begin

          fork 
          begin
              @(negedge RD_CLK2);
              RD_EN2=1;
              @(posedge RD_CLK2);
              count_clk2=1;
              @(negedge RD_CLK2);
              RD_EN2=0;
            count_enteries_pop_fifo2=count_enteries_pop_fifo2+1;
            compare_pop_data_fifo2();  
          end 
          begin
            wait(count_clk2);  
            @(negedge RD_CLK2);
              if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b1010_0000) begin      
              begin  $display("ERROR POP: ONLY PROG EMPTY AND EMPTY SHOULD BE ASSERTED"); error=error+1; end
              end
          end
          join;
          count_clk2=0;
  end

      // if(do_underflow2) begin
      //     @(negedge RD_CLK2);
      //      RD_EN2=1;
      //      @(posedge RD_CLK2);
      //      count_clk2=1;
      //      @(negedge RD_CLK2);
      //      RD_EN2=0;
      //     count_enteries_pop_fifo2=count_enteries_pop_fifo2+1;
      //     compare_pop_data_fifo2();
      // end


end
end
endtask


reg [8:0] fifo1_pop_data1;
reg [8:0] fifo1_pop_data2;
reg [8:0] fifo1_pop_data3;
reg [8:0] fifo1_pop_data4;
// integer prog_f1=0;
integer count_enteries_pop1=0;
integer fifo1_fwft_data1=0;
integer fifo1_fwft_data2=0;
integer fifo1_fwft_data3=0;
integer fifo1_fwft_data4=0;

reg [8:0] local_queue11 [$];  


integer count_enteries_push_fifo1=0;

task push11();

      @(negedge WR_CLK1);
      WR_EN1 = 1;
      WR_DATA1 = $urandom_range(0, 2**DATA_WRITE_WIDTH1-1);
      @(posedge WR_CLK1);
      count_clk1=1;
      @(negedge WR_CLK1);

// R-9 

   if (DATA_READ_WIDTH1==9) begin
   
      if(DATA_WRITE_WIDTH1==9) begin  // 9
    
        if (count_enteries_push_fifo1==0 || count_enteries_push_fifo1==2048) begin
       
           fifo1_fwft_data1 = WR_DATA1;
        
        end    
            local_queue11.push_back({WR_DATA1[8], WR_DATA1[7:0]});
      end 

      else if(DATA_WRITE_WIDTH1==18 ) begin  // 18
        
        if (count_enteries_push_fifo1==0 || count_enteries_push_fifo1==1024) begin
           fifo1_fwft_data1 = {WR_DATA1[8],WR_DATA1[7:0]};
           fifo1_fwft_data2 = {WR_DATA1[17],WR_DATA1[16:9]};
        end    
        local_queue11.push_back({WR_DATA1[8],WR_DATA1[7:0]});  
        local_queue11.push_back({WR_DATA1[17],WR_DATA1[16:9]});  
      end

   end

// R-18

  if (DATA_READ_WIDTH1==18) begin
   
      if(DATA_WRITE_WIDTH1==9 ) begin  // 9
    
        if (count_enteries_push_fifo1==0 || count_enteries_push_fifo1==2048) begin
       
           fifo1_fwft_data1 = WR_DATA1;

        end

        else if (count_enteries_push_fifo1==1 || count_enteries_push_fifo1==2049) begin

           fifo1_fwft_data2 = WR_DATA1;
        
        end    
            local_queue11.push_back({WR_DATA1[8], WR_DATA1[7:0]});
      end 

      else if(DATA_WRITE_WIDTH1==18) begin  // 18
        
        if (count_enteries_push_fifo1==0 || count_enteries_push_fifo1==1024) begin
           fifo1_fwft_data1 = {WR_DATA1[8],WR_DATA1[7:0]};
           fifo1_fwft_data2 = {WR_DATA1[17],WR_DATA1[16:9]};
        end    
        local_queue11.push_back({WR_DATA1[8],WR_DATA1[7:0]});  
        local_queue11.push_back({WR_DATA1[17],WR_DATA1[16:9]});  
      end

  end

  count_enteries_push_fifo1=count_enteries_push_fifo1+1;

  WR_EN1=0;

endtask

integer count_enteries_pop_fifo1=0;

task pop11();
    @(negedge RD_CLK1);
    RD_EN1 = 1;
    @(negedge RD_CLK1);
    RD_EN1=0;
    // count_enteries_pop_fifo1=count_enteries_pop_fifo1 +1;
endtask : pop11

task compare_pop_data_fifo1();

// R-9

  if (DATA_READ_WIDTH1==9) begin
    
    if(DATA_WRITE_WIDTH1==9) begin
        if (count_enteries_pop_fifo1==2048 || count_enteries_pop_fifo1==4096) begin
          compare1(RD_DATA1[8:0], fifo1_fwft_data1);
          exp_dout1 = local_queue11.pop_front();
        end
        else begin
          exp_dout1 = local_queue11.pop_front();
          compare1(RD_DATA1,exp_dout1);
        end
    end

    if(DATA_WRITE_WIDTH1==18) begin
        if (count_enteries_pop_fifo1==2048 || count_enteries_pop_fifo1==4096) begin
          exp_dout1 = local_queue11.pop_front();
          compare1(RD_DATA1, fifo1_fwft_data1);
        end
        else begin
          exp_dout1 = local_queue11.pop_front();
          compare1(RD_DATA1,exp_dout1);
        end
    end

  end

// R-18

  else if (DATA_READ_WIDTH1==18 ) begin
    
    if(DATA_WRITE_WIDTH1==9) begin
       if (count_enteries_pop_fifo1==1024 || count_enteries_pop_fifo1==2048) begin
            fifo1_pop_data1= local_queue11.pop_front();
            fifo1_pop_data2= local_queue11.pop_front();
          compare1({RD_DATA1[8],RD_DATA1[7:0]}, fifo1_fwft_data1);
          compare1({RD_DATA1[17],RD_DATA1[16:9]}, fifo1_fwft_data2);

        end
        else begin
            fifo1_pop_data1= local_queue11.pop_front();
            fifo1_pop_data2= local_queue11.pop_front();
            compare1({RD_DATA1[8], RD_DATA1[7:0]},  {fifo1_pop_data1[8], fifo1_pop_data1[7:0]});
            compare1({RD_DATA1[17], RD_DATA1[16:9]}, {fifo1_pop_data2[8], fifo1_pop_data2[7:0]});
        end
    end
  
      if(DATA_WRITE_WIDTH1==18) begin

       if (count_enteries_pop_fifo1==1024 || count_enteries_pop_fifo1==2048) begin
          fifo1_pop_data1= local_queue11.pop_front();
          fifo1_pop_data2= local_queue11.pop_front();
          compare1({RD_DATA1[8],RD_DATA1[7:0]}, fifo1_fwft_data1);
          compare1({RD_DATA1[17],RD_DATA1[16:9]}, fifo1_fwft_data2);
        end
        
        else begin
          
          fifo1_pop_data1= local_queue11.pop_front();
          fifo1_pop_data2= local_queue11.pop_front();
          compare1({RD_DATA1[8], RD_DATA1[7:0]},  {fifo1_pop_data1[8], fifo1_pop_data1[7:0]});
          compare1({RD_DATA1[17], RD_DATA1[16:9]}, {fifo1_pop_data2[8], fifo1_pop_data2[7:0]});
        end
    end
  end 

endtask

/***************************************************  END AYSNC FIFO1  *************************************************/



/**********************************  ASYNC FIFO2  ****************************************/
      /********************************************************************************/
             /*************************************************************/
                         /*************************************/
                                /**********************/

integer count_fifo2=0;
integer count1_fifo2=0;

reg [8:0] fifo2_pop_data1;
reg [8:0] fifo2_pop_data2;
reg [8:0] fifo2_pop_data3;
reg [8:0] fifo2_pop_data4;
integer fifo2_fwft_data1=0;
integer fifo2_fwft_data2=0;
integer fifo2_fwft_data3=0;
integer fifo2_fwft_data4=0;

reg [8:0] local_queue22 [$];


integer count_enteries_push_fifo2=0;

task push22();

      @(negedge WR_CLK2);
      WR_EN2 = 1;
      WR_DATA2 = $urandom_range(0, 2**DATA_WRITE_WIDTH2-1);    
      @(posedge WR_CLK2);
      count_clk2=1;

      @(negedge WR_CLK2);

// R-9 

   if (DATA_READ_WIDTH2==9) begin
   
      if(DATA_WRITE_WIDTH2==9) begin  // 9
    
        if (count_enteries_push_fifo2==0 || count_enteries_push_fifo2==2048) begin
       
           fifo2_fwft_data1 = WR_DATA2;
        
        end    
            local_queue22.push_back({WR_DATA2[8], WR_DATA2[7:0]});
      end 

      else if(DATA_WRITE_WIDTH2==18) begin  // 18
        
        if (count_enteries_push_fifo2==0 || count_enteries_push_fifo2==1024) begin
           fifo2_fwft_data1 = {WR_DATA2[8],WR_DATA2[7:0]};
           fifo2_fwft_data2 = {WR_DATA2[17],WR_DATA2[16:9]};
        end    
        local_queue22.push_back({WR_DATA2[8],WR_DATA2[7:0]});  
        local_queue22.push_back({WR_DATA2[17],WR_DATA2[16:9]});  
      end

   end

// R-18

  if (DATA_READ_WIDTH2==18) begin
   
      if(DATA_WRITE_WIDTH2==9) begin  // 9
    
        if (count_enteries_push_fifo2==0 || count_enteries_push_fifo2==2048) begin
       
           fifo2_fwft_data1 = WR_DATA2;

        end

        else if (count_enteries_push_fifo2==1 || count_enteries_push_fifo2==2049) begin

           fifo2_fwft_data2 = WR_DATA2;
        
        end    
            local_queue22.push_back({WR_DATA2[8], WR_DATA2[7:0]});
      end 

      else if(DATA_WRITE_WIDTH2==18) begin  // 18
        
        if (count_enteries_push_fifo2==0 || count_enteries_push_fifo2==1024) begin
           fifo2_fwft_data1 = {WR_DATA2[8],WR_DATA2[7:0]};
           fifo2_fwft_data2 = {WR_DATA2[17],WR_DATA2[16:9]};
        end    
        local_queue22.push_back({WR_DATA2[8],WR_DATA2[7:0]});  
        local_queue22.push_back({WR_DATA2[17],WR_DATA2[16:9]});  
      end
  end

  count_enteries_push_fifo2=count_enteries_push_fifo2+1;

  WR_EN2=0;

endtask

integer count_enteries_pop_fifo2=0;

task pop22();
    @(negedge RD_CLK2);
    RD_EN2 = 1;
    @(negedge RD_CLK2);
    RD_EN2=0;
    // count_enteries_pop_fifo2=count_enteries_pop_fifo2 +1;
endtask : pop22

task compare_pop_data_fifo2();

// R-9

  if (DATA_READ_WIDTH2==9) begin
    
    if(DATA_WRITE_WIDTH2==9) begin
        if (count_enteries_pop_fifo2==2048 || count_enteries_pop_fifo2==4096) begin
          compare2(RD_DATA2[8:0], fifo2_fwft_data1);
          exp_dout2 = local_queue22.pop_front();
        end
        else begin
          exp_dout2 = local_queue22.pop_front();
          compare2(RD_DATA2,exp_dout2);
        end
    end

    if(DATA_WRITE_WIDTH2==18) begin
        if (count_enteries_pop_fifo2==2048 || count_enteries_pop_fifo2==4096) begin
          exp_dout2 = local_queue22.pop_front();
          compare2(RD_DATA2, fifo2_fwft_data1);
        end
        else begin
          exp_dout2 = local_queue22.pop_front();
          compare2(RD_DATA2,exp_dout2);
        end
    end

  end

// R-18

  else if (DATA_READ_WIDTH2==18 ) begin
    
    if(DATA_WRITE_WIDTH2==9) begin
       if (count_enteries_pop_fifo2==1024 || count_enteries_pop_fifo2==2048) begin
            fifo2_pop_data1= local_queue22.pop_front();
            fifo2_pop_data2= local_queue22.pop_front();
          compare2({RD_DATA2[8],RD_DATA2[7:0]}, fifo2_fwft_data1);
          compare2({RD_DATA2[17],RD_DATA2[16:9]}, fifo2_fwft_data2);

        end
        else begin
            fifo2_pop_data1= local_queue22.pop_front();
            fifo2_pop_data2= local_queue22.pop_front();
            compare2({RD_DATA2[8], RD_DATA2[7:0]},  {fifo2_pop_data1[8], fifo2_pop_data1[7:0]});
            compare2({RD_DATA2[17], RD_DATA2[16:9]}, {fifo2_pop_data2[8], fifo2_pop_data2[7:0]});
        end
    end
  
      if(DATA_WRITE_WIDTH2==18) begin

       if (count_enteries_pop_fifo2==1024 || count_enteries_pop_fifo2==2048) begin
          fifo2_pop_data1= local_queue22.pop_front();
          fifo2_pop_data2= local_queue22.pop_front();
          compare2({RD_DATA2[8],RD_DATA2[7:0]}, fifo2_fwft_data1);
          compare2({RD_DATA2[17],RD_DATA2[16:9]}, fifo2_fwft_data2);
        end
        
        else begin
          
          fifo2_pop_data1= local_queue22.pop_front();
          fifo2_pop_data2= local_queue22.pop_front();
          compare2({RD_DATA2[8], RD_DATA2[7:0]},  {fifo2_pop_data1[8], fifo2_pop_data1[7:0]});
          compare2({RD_DATA2[17], RD_DATA2[16:9]}, {fifo2_pop_data2[8], fifo2_pop_data2[7:0]});
        end
    end
  end 

endtask

/***************************************************  END AYSNC FIFO2  *************************************************/


	task sync_check_flags_fifo1();
    integer i;
    // resetting ptrs
    $display("--------------------------------------------");
    $display("CHECK FLAGS1: RESET1 PTRS---------------------");
    WR_EN1 = 0;
    RD_EN1 = 0;
    RESET1 = 1;
    repeat(2) @(negedge WR_CLK1);
    repeat(2) @(negedge WR_CLK1);
    RESET1 = 0;
    @(posedge WR_CLK1);
    @(negedge WR_CLK1);

    $display("CHECK FLAGS1: EMPTY1 FIFO---------------------");
    if(PROG_EMPTY_THRESH1>0) begin
    if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b1010_0000)
      begin $display("Assertion empty_ewm_fifo_flags failed!"); error=error+1; end
    end
    else begin
    if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b1000_0000)
      begin $display("Assertion empty_fifo_flags failed!"); error=error+1; end
    end

    $display("CHECK FLAGS1: Checking Flags on Each PUSH/POP Operation---------------------");
    for(i = 1 ; i<=DEPTH1; i=i+1) begin
      push1();
      // wren_cnt+=1;
      if(i==(DEPTH1-1)) begin
        if(~ALMOST_FULL1)
          begin $display("Assertion ALMOST_FULL1_fifo_flags failed!"); error=error+1; end

      repeat(1) @(posedge WR_CLK1);
      repeat(1) @(negedge WR_CLK1);
      // if (PROG_EMPTY1)
      //   begin $error("Assertion PROG_EMPTY1_pop_fifo_flags failed!"); error=error+1; end
      if (EMPTY1)
        begin $display("Assertion EMPTY1_pop_fifo_flags failed!"); error=error+1; end
      if (ALMOST_EMPTY1)
        begin $display("Assertion ALMOST_EMPTY1_pop_fifo_flags failed!"); error=error+1; end
      end
      else begin
        if (ALMOST_FULL1)
          begin $display("Assertion ALMOST_FULL1_fifo_flags failed!"); error=error+1; end
      end

      if(i>(DEPTH1-PROG_FULL_THRESH1)) begin
        if (~PROG_FULL1)
          begin $display("Assertion PROG_FULL1_fifo_flags failed!"); error=error+1; end

        repeat(2) @(posedge WR_CLK1);
        repeat(1) @(negedge WR_CLK1);
        // if(PROG_EMPTY_THRESH1<i) begin
        //   if (PROG_EMPTY1)
        //     begin $error("Assertion PROG_EMPTY1_pop_fifo_flags failed!"); error=error+1; end
        // end
        if (EMPTY1)
          begin $display("Assertion EMPTY1_pop_fifo_flags failed!"); error=error+1; end
        if (ALMOST_EMPTY1)
          begin $display("Assertion ALMOST_EMPTY1_pop_fifo_flags failed!"); error=error+1; end
        end
      else begin
        if (PROG_FULL1)
          begin $error("Assertion PROG_FULL1_fifo_flags failed!"); error=error+1; end
        end

      if(i==DEPTH1) begin
        if (~FULL1)
          begin $display("Assertion FULL1_fifo_flags failed!"); error=error+1; end

        repeat(1) @(posedge WR_CLK1);
        repeat(1) @(negedge WR_CLK1);
        // if (PROG_EMPTY1)
        //   begin $error("Assertion PROG_EMPTY1_pop_fifo_flags failed!"); error=error+1; end
        if (EMPTY1)
          begin $display("Assertion EMPTY1_pop_fifo_flags failed!"); error=error+1; end
        if (ALMOST_EMPTY1)
          begin $display("Assertion ALMOST_EMPTY1_pop_fifo_flags failed!"); error=error+1; end
        end
      else begin
        if (FULL1)
          begin $display("Assertion FULL1_fifo_flags failed!"); error=error+1; end
        end

      if (OVERFLOW1)
        begin $display("Assertion OVERFLOW1_fifo_flag failed!"); error=error+1; end
      repeat(1) @(posedge WR_CLK1);
      repeat(1) @(negedge WR_CLK1);
      if (UNDERFLOW1)
        begin $display("Assertion UNDERFLOW1_fifo_flag failed!"); error=error+1; end
    end
    for(i = DEPTH1 ; i>=1; i=i-1) begin
      pop1();

      if(PROG_EMPTY_THRESH1>=i) begin
        if (~PROG_EMPTY1)
          begin $error("Assertion PROG_EMPTY1_pop_fifo_flags failed!"); error=error+1; end
        repeat(1) @(posedge WR_CLK1);
        repeat(1) @(negedge WR_CLK1);
        if (ALMOST_FULL1)
          begin $display("Assertion ALMOST_FULL1_fifo_flags failed!"); error=error+1; end
        // if (PROG_FULL1)
        //   begin $error("Assertion PROG_FULL1_fifo_flags failed!"); error=error+1; end
        if (FULL1)
          begin $display("Assertion FULL1_fifo_flags failed!"); error=error+1; end
        end
      else begin
        if (PROG_EMPTY1)
          begin $error("Assertion PROG_EMPTY1_pop_fifo_flags failed!"); error=error+1; end
        end

      if(i==1) begin
        if (~EMPTY1)
          begin $display("Assertion EMPTY1_pop_fifo_flags failed!"); error=error+1; end
        repeat(1) @(posedge WR_CLK1);
        repeat(1) @(negedge WR_CLK1);
        if (ALMOST_FULL1)
          begin $display("Assertion ALMOST_FULL1_fifo_flags failed!"); error=error+1; end
        // if (PROG_FULL1)
        //   begin $error("Assertion PROG_FULL1_fifo_flags failed!"); error=error+1; end
        if (FULL1)
          begin $display("Assertion FULL1_fifo_flags failed!"); error=error+1; end
        end
      else begin
        if (EMPTY1)
          begin $display("Assertion EMPTY1_pop_fifo_flags failed!"); error=error+1; end
        end

      if(i==2) begin
        if (~ALMOST_EMPTY1)
          begin $display("Assertion ALMOST_EMPTY1_pop_fifo_flags failed!"); error=error+1; end
        repeat(2) @(posedge WR_CLK1);
        repeat(1) @(negedge WR_CLK1);
        if (ALMOST_FULL1)
          begin $display("Assertion ALMOST_FULL1_fifo_flags failed!"); error=error+1; end
        // if (PROG_FULL1)
        //   begin $error("Assertion PROG_FULL1_fifo_flags failed!"); error=error+1; end
        if (FULL1)
          begin $display("Assertion FULL1_fifo_flags failed!"); error=error+1; end
        end
      else begin
        if (ALMOST_EMPTY1)
          begin $display("Assertion ALMOST_EMPTY1_pop_fifo_flags failed!"); error=error+1; end
        end

      if (UNDERFLOW1)
        begin $display("Assertion UNDERFLOW1_pop_fifo_flag failed!"); error=error+1; end
      repeat(1) @(posedge WR_CLK1);
      repeat(1) @(negedge WR_CLK1);
      if (OVERFLOW1)
        begin $display("Assertion OVERFLOW1_pop_fifo_flag failed!"); error=error+1; end
    // rden_cnt+=1;
    end
    $display("CHECK FLAGS1: Read from EMPTY FIFO and Check UNDERFLOW1 Status---------------------");
    repeat (1) begin
    pop1();
    // rden_cnt+=1;
    end
    if (~UNDERFLOW1)
      begin $display("Assertion UNDERFLOW1_fifo_flag failed!"); error=error+1; end

    $display("CHECK FLAGS1: RESET PTRS after UNDERFLOW1---------------------");
    RESET1 = 1;
    repeat(2) @(negedge WR_CLK1);
    RESET1 = 0;
    @(posedge WR_CLK1);
    @(negedge WR_CLK1);

    $display("CHECK FLAGS1: Push Data Into FIFO Until FULL1---------------------");
    repeat(DEPTH1) push1();

    $display("CHECK FLAGS1: Write into a FULL FIFO and Check OVERFLOW1 Status---------------------");
    repeat (1)push1();
    if (~OVERFLOW1)
      begin $display("Assertion OVERFLOW1_fifo_flag failed!"); error=error+1; end


    repeat(20) @(negedge WR_CLK1);

    $display("CHECK FLAGS1: RESET PTRS after OVERFLOW1---------------------");
    RESET1 = 1;
    repeat(2) @(negedge WR_CLK1);
    RESET1 = 0;
    @(posedge WR_CLK1);
    @(negedge WR_CLK1);
    $display("CHECK FLAGS1: EXIT---------------------------");

  endtask

	task pop1();
    @(negedge WR_CLK1);
    RD_EN1 = 1;
    if(debug) $display(" RD_EN1 = ",RD_EN1, " RD_DATA1 = ",RD_DATA1);
    if (UNDERFLOW1)
      $display("FIFO is UNDERFLOW1, POPing is UNDERFLOW1");
    else if(EMPTY1) begin
      $display("FIFO is EMPTY1, POPing is UNDERFLOW1");
      local_queue1.delete();
    end
    else begin
      exp_dout1 = local_queue1.pop_front();
      compare(RD_DATA1, exp_dout1);
    end
    @(negedge WR_CLK1);
		RD_EN1 =0;
  endtask
  
  //task push1(reg [32-1:0] in_din=$urandom_range(0, 2**32-1)); 
  task push1(reg [DATA_WIDTH1-1:0] in_din=$urandom_range(0, 2**DATA_WIDTH1-1)); 
    @(negedge WR_CLK1);
		WR_EN1 = 1; 
    WR_DATA1 = in_din;
    if(debug) $display(" WR_EN1 = ",WR_EN1, " WR_DATA1 = ",WR_DATA1);
    if (OVERFLOW1) begin
      $display("FIFO is OVERFLOW1, PUSHing is OVERFLOW1");
    end
    else if(FULL1) begin
      $display("FIFO is FULL1, PUSHing is OVERFLOW1");
      local_queue1.delete();
    end
    else begin
      local_queue1.push_back(WR_DATA1);
    end
    @(negedge WR_CLK1);
		WR_EN1 = 0;
  endtask

  task compare(input reg [DATA_WIDTH1-1:0] RD_DATA1, exp_dout);
	if(RD_DATA1 !== exp_dout) begin
		$display("RD_DATA1 mismatch. DUT_Out: %0h, Expected_Out: %h, Time: %0t", RD_DATA1, exp_dout,$time);
		error = error+1;
	end
	else if(debug)
		$display("RD_DATA1 match. DUT_Out: %0h, Expected_Out: %0h, Time: %0t", RD_DATA1, exp_dout,$time);
endtask

task compare1(input reg [8:0] RD_DATA1, exp_dout);
	if(RD_DATA1 !== exp_dout) begin
		$display("RD_DATA1 mismatch. DUT_Out: %0h, Expected_Out: %h, Time: %0t", RD_DATA1, exp_dout,$time);
		error = error+1;
	end
	else if(debug)
		$display("RD_DATA1 match. DUT_Out: %0h, Expected_Out: %0h, Time: %0t", RD_DATA1, exp_dout,$time);
endtask

  // FIFO2

 // FIFO2

  task sync_check_flags_fifo2();
    integer i;
    // resetting ptrs
    $display("--------------------------------------------");
    $display("CHECK FLAGS2: RESET2 PTRS---------------------");
    WR_EN2 = 0;
    RD_EN2 = 0;
    RESET2 = 1;
    repeat(2) @(negedge WR_CLK2);
    repeat(2) @(negedge WR_CLK2);
    RESET2 = 0;
    @(posedge WR_CLK2);
    @(negedge WR_CLK2);

    $display("CHECK FLAGS2: EMPTY2 FIFO---------------------");
    if(PROG_EMPTY_THRESH2>0) begin
    if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b1010_0000)
      begin $display("Assertion PROG_EMPTY_THRESH2_fifo_flags failed!"); error=error+1; end
    end
    else begin
    if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b1000_0000)
      begin $display("Assertion EMPTY2_fifo_flags failed!"); error=error+1; end
    end

    $display("CHECK FLAGS2: Checking Flags on Each PUSH/POP Operation---------------------");
    for(i = 1 ; i<=DEPTH2; i=i+1) begin
      push2();
      wren_cnt+=1;
      if(i==(DEPTH2-1)) begin
        if(~ALMOST_FULL2)
          begin $display("Assertion ALMOST_FULL2_fifo_flags failed!"); error=error+1; end

        repeat(1) @(posedge WR_CLK2);
        repeat(1) @(negedge WR_CLK2);
        // if (PROG_EMPTY2)
        //   begin $display("Assertion PROG_EMPTY2_pop_fifo_flags failed!"); error=error+1; end
        if (EMPTY2)
          begin $display("Assertion EMPTY2_pop_fifo_flags failed!"); error=error+1; end
        if (ALMOST_EMPTY2)
          begin $display("Assertion ALMOST_EMPTY2_pop_fifo_flags failed!"); error=error+1; end
      end
      else begin
        if (ALMOST_FULL2)
          begin $display("Assertion ALMOST_FULL2_fifo_flags failed!"); error=error+1; end
        end

      if(i>(DEPTH2-PROG_FULL_THRESH2)) begin
        if (~PROG_FULL2)
          begin $display("Assertion PROG_FULL2_fifo_flags failed!"); error=error+1; end

        repeat(2) @(posedge WR_CLK2);
        repeat(1) @(negedge WR_CLK2);
        // if (PROG_EMPTY2)
        //   begin $display("Assertion PROG_EMPTY2_pop_fifo_flags failed!"); error=error+1; end
        if (EMPTY2)
          begin $display("Assertion EMPTY2_pop_fifo_flags failed!"); error=error+1; end
        if (ALMOST_EMPTY2)
          begin $display("Assertion ALMOST_EMPTY2_pop_fifo_flags failed!"); error=error+1; end
        end
      else begin
        if (PROG_FULL2)
          begin $display("Assertion PROG_FULL2_fifo_flags failed!"); error=error+1; end
        end

      if(i==DEPTH2) begin
        if (~FULL2)
          begin $display("Assertion FULL2_fifo_flags failed!"); error=error+1; end

        repeat(1) @(posedge WR_CLK2);
        repeat(1) @(negedge WR_CLK2);
        // if (PROG_EMPTY2)
        //   begin $display("Assertion PROG_EMPTY2_pop_fifo_flags failed!"); error=error+1; end
        if (EMPTY2)
          begin $display("Assertion EMPTY2_pop_fifo_flags failed!"); error=error+1; end
        if (ALMOST_EMPTY2)
          begin $display("Assertion ALMOST_EMPTY2_pop_fifo_flags failed!"); error=error+1; end
        end
      else begin
        if (FULL2)
          begin $display("Assertion FULL2_fifo_flags failed!"); error=error+1; end
        end

     if (OVERFLOW2)
        begin $display("Assertion OVERFLOW2_fifo_flag failed!"); error=error+1; end
    repeat(1) @(posedge WR_CLK2);
    repeat(1) @(negedge WR_CLK2);
    if (UNDERFLOW2)
      begin $display("Assertion UNDERFLOW2_fifo_flag failed!"); error=error+1; end
    end
    for(i = DEPTH2 ; i>=1; i=i-1) begin
      pop2();

      if(PROG_EMPTY_THRESH2>=i) begin
        if (~PROG_EMPTY2)
          begin $display("Assertion PROG_EMPTY2_pop_fifo_flags failed!"); error=error+1; end
        repeat(1) @(posedge WR_CLK2);
        repeat(1) @(negedge WR_CLK2);
        if (ALMOST_FULL2)
          begin $display("Assertion ALMOST_FULL2_fifo_flags failed!"); error=error+1; end
        // if (PROG_FULL2)
        //   begin $display("Assertion PROG_FULL2_fifo_flags failed!"); error=error+1; end
        if (FULL2)
          begin $display("Assertion FULL2_fifo_flags failed!"); error=error+1; end
        end
      else begin
        if (PROG_EMPTY2)
          begin $display("Assertion PROG_EMPTY2_pop_fifo_flags failed!"); error=error+1; end
        end

      if(i==1) begin
        if (~EMPTY2)
          begin $display("Assertion EMPTY2_pop_fifo_flags failed!"); error=error+1; end
        repeat(1) @(posedge WR_CLK2);
        repeat(1) @(negedge WR_CLK2);
        if (ALMOST_FULL2)
          begin $display("Assertion ALMOST_FULL2_fifo_flags failed!"); error=error+1; end
        // if (PROG_FULL2)
        //   begin $display("Assertion PROG_FULL2_fifo_flags failed!"); error=error+1; end
        if (FULL2)
          begin $display("Assertion FULL2_fifo_flags failed!"); error=error+1; end
        end
      else begin
        if (EMPTY2)
          begin $display("Assertion EMPTY2_pop_fifo_flags failed!"); error=error+1; end
        end

      if(i==2) begin
        if (~ALMOST_EMPTY2)
          begin $display("Assertion ALMOST_EMPTY2_pop_fifo_flags failed!"); error=error+1; end
        repeat(2) @(posedge WR_CLK2);
        repeat(1) @(negedge WR_CLK2);
        if (ALMOST_FULL2)
          begin $display("Assertion ALMOST_FULL2_fifo_flags failed!"); error=error+1; end
        // if (PROG_FULL2)
        //   begin $display("Assertion PROG_FULL2_fifo_flags failed!"); error=error+1; end
        if (FULL2)
          begin $display("Assertion FULL2_fifo_flags failed!"); error=error+1; end
        end
      else begin
        if (ALMOST_EMPTY2)
          begin $display("Assertion ALMOST_EMPTY2_pop_fifo_flags failed!"); error=error+1; end
        end

      if (UNDERFLOW2)
        begin $display("Assertion UNDERFLOW2_pop_fifo_flag failed!"); error=error+1; end
      repeat(1) @(posedge WR_CLK2);
      repeat(1) @(negedge WR_CLK2);
      if (OVERFLOW2)
        begin $display("Assertion OVERFLOW2_pop_fifo_flag failed!"); error=error+1; end
    // rden_cnt+=1;
    end
    $display("CHECK FLAGS2: Read from EMPTY FIFO and Check UNDERFLOW2 Status---------------------");
    repeat (1) begin
    pop2();
    // rden_cnt+=1;
    end
    if (~UNDERFLOW2)
      begin $display("Assertion UNDERFLOW2_fifo_flag failed!"); error=error+1; end
    $display("CHECK FLAGS2: RESET PTRS after UNDERFLOW2---------------------");
    RESET2 = 1;
    repeat(2) @(negedge WR_CLK2);
    RESET2 = 0;
    @(posedge WR_CLK2);
    @(negedge WR_CLK2);

    $display("CHECK FLAGS2: Push Data Into FIFO Until FULL2---------------------");
    repeat(DEPTH2) push2();

    $display("CHECK FLAGS2: Write into a FULL FIFO and Check OVERFLOW2 Status---------------------");
    repeat (1)push2();
    if (~OVERFLOW2)
      begin $display("Assertion OVERFLOW2_fifo_flag failed!"); error=error+1; end


    repeat(20) @(negedge WR_CLK2);

    RESET2 = 1;
    repeat(2) @(negedge WR_CLK2);
    RESET2 = 0;
    @(posedge WR_CLK2);
    @(negedge WR_CLK2);
    $display("CHECK FLAGS2: EXIT---------------------------");

  endtask

	task pop2();
    @(negedge WR_CLK2);
    RD_EN2 = 1;
    if(debug) $display(" RD_EN2 = ",RD_EN2, " RD_DATA2 = ",RD_DATA2);
    if (UNDERFLOW2)
      $display("FIFO is UNDERFLOW2, POPing is UNDERFLOW2");
    else if(EMPTY2) begin
      $display("FIFO is EMPTY2, POPing is UNDERFLOW2");
      local_queue2.delete();
    end
    else begin
      exp_dout2 = local_queue2.pop_front();
      compare2(RD_DATA2, exp_dout2);
    end
    @(negedge WR_CLK2);
		RD_EN2 =0;
  endtask
  
  //task push2(reg [32-1:0] in_din=$urandom_range(0, 2**32-1)); 
  task push2(reg [DATA_WIDTH2-1:0] in_din=$urandom_range(0, 2**DATA_WIDTH2-1)); 
    @(negedge WR_CLK2);
		WR_EN2 = 1; 
    WR_DATA2 = in_din;
    if(debug) $display(" WR_EN2 = ",WR_EN2, " WR_DATA2 = ",WR_DATA2);
    if (OVERFLOW2) begin
      $display("FIFO is OVERFLOW2, PUSHing is OVERFLOW2");
    end
    else if(FULL2) begin
      $display("FIFO is FULL2, PUSHing is OVERFLOW2");
      local_queue2.delete();
    end
    else begin
      local_queue2.push_back(WR_DATA2);
    end
    @(negedge WR_CLK2);
		WR_EN2 = 0;
  endtask

  task compare2(input reg [DATA_WIDTH2-1:0] RD_DATA, exp_dout);
    if(RD_DATA !== exp_dout) begin
      $display("RD_DATA2 mismatch. DUT_Out: %0h, Expected_Out: %0h, Time: %0t", RD_DATA, exp_dout,$time);
      error = error+1;
    end
    else if(debug)
      $display("RD_DATA2 match. DUT_Out: %0h, Expected_Out: %0h, Time: %0t", RD_DATA, exp_dout,$time);
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

endmodule
