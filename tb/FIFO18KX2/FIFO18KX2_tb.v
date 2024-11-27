/*

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
  parameter DATA_WRITE_WIDTH1 = 9; // choose (9,18) FIFO data write width, FIFO 1
  parameter DATA_READ_WIDTH1 = 18; // choose (9,18) FIFO data read width, FIFO 1
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


  parameter FIFO_TYPE1 = "SYNCHRONOUS"; // Synchronous or Asynchronous data transfer, FIFO 1 (SYNCHRONOUS/ASYNCHRONOUS)
  parameter [10:0] PROG_EMPTY_THRESH1 = 11'd1022; // 11-bit Programmable empty depth, FIFO 1
  parameter [10:0] PROG_FULL_THRESH1 = 11'd1948; // 11-bit Programmable full depth, FIFO 1
  
  localparam  fifo_depth_write1 = (DATA_WRITE_WIDTH1 <= 9) ? 2048 : 1024;
  localparam  fifo_depth_read1 = (DATA_READ_WIDTH1 <= 9) ? 2048 : 1024;
 

  localparam DEPTH_WRITE1 = (DATA_WRITE_WIDTH1 <= 9) ? 2048 :  1024;
  localparam DEPTH_READ1 = (DATA_READ_WIDTH1 <= 9) ? 2048 :  1024;

	// predictor output
	reg [8:0] exp_dout1;

	// testbench variables
	integer error=0;

	reg [8:0] local_queue1 [$];

	bit debug1=1; // set it to 1 to see comparison of push/pop data in FIFO1
  bit debug2=1; // set it to 1 to see comparison of push/pop data in FIFO2
  
  bit count_clk1=0;
  bit count_clk2=0;

  reg do_overflow1 =0;
  reg do_underflow1 =0;

  reg do_overflow2 =0;
  reg do_underflow2 =0;

  reg RESET2; // Asynchrnous FIFO reset
  reg WR_CLK2; // Write clock
  reg RD_CLK2; // Read clock
  reg WR_EN2; // Write enable
  reg RD_EN2; // Read enable
  parameter DATA_WRITE_WIDTH2 = 18; // FIFO data write width, FIFO 1
  parameter DATA_READ_WIDTH2 = 9; // FIFO data read width, FIFO 1
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

  parameter FIFO_TYPE2 = "SYNCHRONOUS"; // Synchronous or Asynchronous data transfer, FIFO 1 (SYNCHRONOUS/ASYNCHRONOUS)

  parameter [10:0] PROG_EMPTY_THRESH2 = 11'd104; // 11-bit Programmable empty depth, FIFO 1
  parameter [10:0] PROG_FULL_THRESH2 = 11'd504; // 11-bit Programmable full depth, FIFO 1

  localparam  fifo_depth_write2 = (DATA_WRITE_WIDTH2 <= 9) ? 2048 : 1024;
  localparam  fifo_depth_read2 = (DATA_READ_WIDTH2 <= 9) ? 2048 : 1024;

  localparam DEPTH_WRITE2 = (DATA_WRITE_WIDTH2 <= 9) ? 2048 :  1024;
  localparam DEPTH_READ2 = (DATA_READ_WIDTH2 <= 9) ? 2048 :  1024;


  // predictor output
  reg [8:0] exp_dout2;

 /* 

 FOR SYNCHRONOUS READ AND WRITE FREQUENCY SHOULD BE SAME AND FOR ASYNCHRONOUS 
         READ AND WRITE FREQUENCY COULD BE SAME OR DIFFERENT 

*/

  	//clock//
  	initial begin
  		WR_CLK1 = 1'b0;
  		forever #1 WR_CLK1 = ~WR_CLK1;
    end

  	initial begin
			RD_CLK1 = 1'b0;
			forever #1 RD_CLK1 = ~RD_CLK1;
	  end

    //clock//
    initial begin
      WR_CLK2 = 1'b0;
      forever #20 WR_CLK2 = ~WR_CLK2;
    end

    initial begin
        RD_CLK2 = 1'b0;
        forever #20 RD_CLK2 = ~RD_CLK2;
    end

integer WgtR_Ratio1, RgtW_Ratio1;

assign WgtR_Ratio1 = (DATA_READ_WIDTH1>=DATA_WRITE_WIDTH1)?  1: DATA_WRITE_WIDTH1/DATA_READ_WIDTH1; // For example ? = 4
assign RgtW_Ratio1 = (DATA_WRITE_WIDTH1>=DATA_READ_WIDTH1)?  1: DATA_READ_WIDTH1/DATA_WRITE_WIDTH1; // For example ? = 4

integer WgtR_Ratio2, RgtW_Ratio2;

assign WgtR_Ratio2 = (DATA_READ_WIDTH2>=DATA_WRITE_WIDTH2)?  1: DATA_WRITE_WIDTH2/DATA_READ_WIDTH2; // For example ? = 4
assign RgtW_Ratio2 = (DATA_WRITE_WIDTH2>=DATA_READ_WIDTH2)?  1: DATA_READ_WIDTH2/DATA_WRITE_WIDTH2; // For example ? = 4




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
) FIFO18K_INST(
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
        RESET2 = 1;
        repeat(2) @(negedge WR_CLK2);
        RESET2 = 0;
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
        if(FIFO_TYPE1 == "SYNCHRONOUS") begin
              if(DEPTH_WRITE1==DEPTH_READ1) begin
              sync_check_flags_fifo1_sync();                // synchronous          
              end
              if(DEPTH_WRITE1!==DEPTH_READ1) begin
              sync_check_flags_fifo1_asymmetric();                // synchronous          
              end
        end
        else if(FIFO_TYPE1=="ASYNCHRONOUS") begin
          async_check_flags_fifo1();
        end        
      end
      begin

        $display("PROG_EMPTY_THRESH2 = %d", PROG_EMPTY_THRESH2);
		    $display("PROG_FULL_THRESH2 = %d", PROG_FULL_THRESH2);
        $display("--------------------------------------------");
        $display("check_flags_FIFO2");
        $display("--------------------------------------------");
        if(FIFO_TYPE2=="SYNCHRONOUS") begin
            if(DEPTH_WRITE2 == DEPTH_READ2) begin
            sync_check_flags_fifo2_symmetric();                // synchronous          
            end
            if(DEPTH_WRITE2 !== DEPTH_READ2) begin
            sync_check_flags_fifo2_asymmetric();                // synchronous          
            end            
        end
        else if(FIFO_TYPE2=="ASYNCHRONOUS") begin
          async_check_flags_fifo2();
        end  

      end
    join

    test_status(error);
    #100;
    $finish();

  end

	initial begin
		$dumpfile("wave.vcd");
		$dumpvars(0,FIFO18KX2_tb);

//  for (int idx = 0; idx < 10; idx = idx + 1)
    // $dumpvars(0,FIFO18KX2_tb.fifo18k_inst.async.tdp_ram18kx2_inst1.RAM1_DATA[idx]);
	end



////////////////////////////////////////   FIFO-1  ////////////////////////////////////////////


reg [8:0] fifo1_pop_data1;
reg [8:0] fifo1_pop_data2;
reg [8:0] fifo1_pop_data3;
reg [8:0] fifo1_pop_data4;
integer fifo1_fwft_data1=0;
integer fifo1_fwft_data2=0;
integer fifo1_fwft_data3=0;
integer fifo1_fwft_data4=0;


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
    
        if (count_enteries_push_fifo1==0) begin
       
           fifo1_fwft_data1 = WR_DATA1;
        
        end    
            local_queue1.push_back({WR_DATA1[8], WR_DATA1[7:0]});
      end 

      else if(DATA_WRITE_WIDTH1==18) begin  // 18
        
        if (count_enteries_push_fifo1==0) begin
           fifo1_fwft_data1 = {WR_DATA1[8],WR_DATA1[7:0]};
           fifo1_fwft_data2 = {WR_DATA1[17],WR_DATA1[16:9]};
        end    
        local_queue1.push_back({WR_DATA1[8],WR_DATA1[7:0]});  
        local_queue1.push_back({WR_DATA1[17],WR_DATA1[16:9]});  
      end

   end

// R-18

  if (DATA_READ_WIDTH1==18) begin
   
      if(DATA_WRITE_WIDTH1==9) begin  // 9
    
        if (count_enteries_push_fifo1==0) begin
       
           fifo1_fwft_data1 = WR_DATA1;

        end

        else if (count_enteries_push_fifo1==1) begin

           fifo1_fwft_data2 = WR_DATA1;
        
        end    
            local_queue1.push_back({WR_DATA1[8], WR_DATA1[7:0]});
      end 

      else if(DATA_WRITE_WIDTH1==18) begin  // 18
        
        if (count_enteries_push_fifo1==0) begin
           fifo1_fwft_data1 = {WR_DATA1[8],WR_DATA1[7:0]};
           fifo1_fwft_data2 = {WR_DATA1[17],WR_DATA1[16:9]};
        end    
        local_queue1.push_back({WR_DATA1[8],WR_DATA1[7:0]});  
        local_queue1.push_back({WR_DATA1[17],WR_DATA1[16:9]});  
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
endtask : pop11

task compare_pop_data_fifo1();

// R-9

  if (DATA_READ_WIDTH1==9) begin
    
    if(DATA_WRITE_WIDTH1==9) begin
        if (count_enteries_pop_fifo1==2048) begin
          compare1(RD_DATA1[8:0], fifo1_fwft_data1);
        end
        else begin
          exp_dout1 = local_queue1.pop_front();
          compare1(RD_DATA1,exp_dout1);
        end
    end

    if(DATA_WRITE_WIDTH1==18) begin
        if (count_enteries_pop_fifo1==2048) begin
          compare1(RD_DATA1, fifo1_fwft_data1);
          exp_dout1 = local_queue1.pop_front();
        end
        else begin
          exp_dout1 = local_queue1.pop_front();
          compare1(RD_DATA1,exp_dout1);
        end
    end

  end

// R-18

  else if (DATA_READ_WIDTH1==18 ) begin
    
    if(DATA_WRITE_WIDTH1==9) begin
       if (count_enteries_pop_fifo1==1024) begin

          compare1({RD_DATA1[8],RD_DATA1[7:0]}, fifo1_fwft_data1);
          compare1({RD_DATA1[17],RD_DATA1[16:9]}, fifo1_fwft_data2);

        end
        else begin
            fifo1_pop_data1= local_queue1.pop_front();
            fifo1_pop_data2= local_queue1.pop_front();
            compare1({RD_DATA1[8], RD_DATA1[7:0]},  {fifo1_pop_data1[8], fifo1_pop_data1[7:0]});
            compare1({RD_DATA1[17], RD_DATA1[16:9]}, {fifo1_pop_data2[8], fifo1_pop_data2[7:0]});
        end
    end
  
      if(DATA_WRITE_WIDTH1==18) begin

       if (count_enteries_pop_fifo1==1024) begin
          fifo1_pop_data1= local_queue1.pop_front();
          fifo1_pop_data2= local_queue1.pop_front();
          compare1({RD_DATA1[8],RD_DATA1[7:0]}, fifo1_fwft_data1);
          compare1({RD_DATA1[17],RD_DATA1[16:9]}, fifo1_fwft_data2);
        end
        
        else begin
          
          fifo1_pop_data1= local_queue1.pop_front();
          fifo1_pop_data2= local_queue1.pop_front();
          compare1({RD_DATA1[8], RD_DATA1[7:0]},  {fifo1_pop_data1[8], fifo1_pop_data1[7:0]});
          compare1({RD_DATA1[17], RD_DATA1[16:9]}, {fifo1_pop_data2[8], fifo1_pop_data2[7:0]});
        end
    end
  end 

endtask


  task sync_check_flags_fifo1_sync();

    $display("--------------------------------------------");
    $display("CHECK FLAGS: RESET1 PTRS---------------------");
    WR_EN1 = 0;
    RD_EN1 = 0;
    RESET1 = 1;
    repeat(2) @(negedge WR_CLK1);
    repeat(2) @(negedge WR_CLK1);
    RESET1 = 0;
    @(posedge WR_CLK1);
    @(negedge WR_CLK1);

    // if(debug) $display("CHECK FLAGS: EMPTY1 FIFO---------------------");
    $display("CHECK FLAGS: EMPTY1 FIFO---------------------");
    if(PROG_EMPTY_THRESH1>0) begin
    if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b1010_0000)
      begin $display("Assertion empty_ewm_fifo_flags failed!"); error=error+1; end
    end
    else begin
    if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b1000_0000)
      begin $display("Assertion empty_fifo_flags failed!"); error=error+1; end
    end

    $display("CHECK FLAGS: Checking Flags on Each PUSH/POP Operation---------------------");
    count_enteries_push_fifo1=0;
  
  for(integer i = 1 ; i<=DEPTH_WRITE1+do_overflow1; i=i+1) begin
    
    if(i==1) begin
      push11();
      @(posedge WR_CLK1);
      @(negedge WR_CLK1);
      // $display("time %t", $time);
      if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,OVERFLOW1} !== 6'b010_000) begin      
                  begin  $display("ERROR PUSH: ONLY ALMOST EMPTY1 SHOULD BE ASSERTED"); error=error+1; end
      end
    end
    if(i>1 & i<DEPTH_WRITE1-1) begin
      push11();
      @(posedge WR_CLK1);
      @(negedge WR_CLK1);
      // $display("time %t", $time);
      if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,OVERFLOW1} !== 6'b000_000) begin      
                  begin  $display("ERROR PUSH: ALL SHOULD BE DE-ASSERTED"); error=error+1; end
      end
    end

    if(i==DEPTH_WRITE1-1) begin
      push11();
      @(posedge WR_CLK1);
      @(negedge WR_CLK1);
      // $display("time %t", $time);
      if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,OVERFLOW1} !== 6'b000_010) begin      
                  begin  $display("ERROR PUSH: ONLY ALMOST FULL1 SHOULD BE ASSERTED"); error=error+1; end
      end
    end

    if(i==DEPTH_WRITE1) begin
      push11();
      @(posedge WR_CLK1);
      @(negedge WR_CLK1);
      // $display("time %t", $time);
      if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,OVERFLOW1} !== 6'b000_100) begin      
                  begin  $display("ERROR PUSH: ONLY FULL1 SHOULD BE ASSERTED"); error=error+1; end
      end
    end

      if(i==DEPTH_WRITE1 & do_overflow1) begin
      push11(); 
      @(posedge WR_CLK1);
      if (OVERFLOW1 !== 1'b1) begin      
                  begin  $display("ERROR PUSH: OVERFLOW1 SHOULD BE 1"); error=error+1; end
      end            
    end
  
  if(i<=PROG_EMPTY_THRESH1) begin
          if (PROG_EMPTY1 !== 1) begin      
                  begin  $display("ERROR PUSH: PROG EMPTY1 SHOULD BE ASSERTED"); error=error+1; end
      end
  end

 if(i>DEPTH_WRITE1-PROG_FULL_THRESH1) begin
          if (PROG_FULL1 !== 1) begin      
                  begin  $display("ERROR PUSH: PROG FULL1 SHOULD BE ASSERTED"); error=error+1; end
      end
  end

 end

count_enteries_pop_fifo1=0;
for(integer i = 1 ; i<=DEPTH_READ1+do_underflow1; i=i+1) begin

if(i==1) begin
    compare_pop_data_fifo1();
    count_enteries_pop_fifo1= count_enteries_pop_fifo1+1;
    pop11();
    compare_pop_data_fifo1();
    count_enteries_pop_fifo1= count_enteries_pop_fifo1+1;
    @(posedge WR_CLK1);
    @(negedge WR_CLK1);
    if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,OVERFLOW1} !== 6'b000_010) begin      
                  begin  $display("ERROR PUSH: ONLY ALMOST FULL1 SHOULD BE ASSERTED"); error=error+1; end
    end
end

if(i>1 & i<DEPTH_READ1-1) begin
    pop11();
    compare_pop_data_fifo1();
    count_enteries_pop_fifo1= count_enteries_pop_fifo1+1;
    @(posedge WR_CLK1);
    @(negedge WR_CLK1);
    if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,OVERFLOW1} !== 6'b000_000) begin      
                  begin  $display("ERROR PUSH: ONLY ALMOST FULL1 SHOULD BE ASSERTED"); error=error+1; end
    end
end

if(i==DEPTH_READ1-1) begin
    pop11();
    compare_pop_data_fifo1();
    count_enteries_pop_fifo1= count_enteries_pop_fifo1+1;
    @(posedge WR_CLK1);
    if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,OVERFLOW1} !== 6'b010_000) begin      
                  begin  $display("ERROR PUSH: ONLY ALMOST FULL1 SHOULD BE ASSERTED"); error=error+1; end
    end
end

if(i==DEPTH_READ1) begin
    pop11();
    compare_pop_data_fifo1();
    count_enteries_pop_fifo1= count_enteries_pop_fifo1+1;
    @(posedge WR_CLK1);
    if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,OVERFLOW1} !== 6'b100_000) begin      
                  begin  $display("ERROR PUSH: ONLY ALMOST FULL1 SHOULD BE ASSERTED"); error=error+1; end
    end
end

if(i==DEPTH_READ1+do_underflow1 & do_underflow1==1) begin
    pop11();
    @(posedge WR_CLK1);
    if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,OVERFLOW1} !== 6'b101_000) begin      
                  begin  $display("ERROR PUSH: EMPTY1 AND UNDERFLOW1 SHOULD BE ASSERTED"); error=error+1; end
    end
end

if(i<PROG_FULL_THRESH1) begin
    if (PROG_FULL1 !== 1)
    begin $display("ERROR: PROG FULL1 SHOULD BE ASSERTED"); error=error+1; end
end

if(i>DEPTH_READ1-PROG_EMPTY_THRESH1) begin
    if (PROG_EMPTY1 !== 1)
    begin $display("ERROR: PROG EMPTY1 SHOULD BE ASSERTED"); error=error+1; end
end


end


  endtask

task sync_check_flags_fifo1_asymmetric();
// RESET1ting ptrs


    $display("--------------------------------------------");
    $display("CHECK FLAGS: RESET1 PTRS---------------------");
    WR_EN1 = 0;
    RD_EN1 = 0;
    RESET1 = 1;
    repeat(2) @(negedge WR_CLK1);
    repeat(2) @(negedge WR_CLK1);
    RESET1 = 0;
    @(posedge WR_CLK1);
    @(negedge WR_CLK1);

  if( DATA_WRITE_WIDTH1> DATA_READ_WIDTH1) begin
  
  count_enteries_push_fifo1=0;
  
  for(int i=0; i<DEPTH_WRITE1+do_overflow1; i++) begin
    
    if((i+1)*WgtR_Ratio1<PROG_EMPTY_THRESH1) begin
      if(PROG_EMPTY1 !==1) begin $display("ERROR PUSH: PROG_EMPTY1 SHOULD BE 1");error=error+1;  end
    end

    if(i>DEPTH_WRITE1-PROG_FULL_THRESH1) begin
      if(PROG_FULL1 !==1) begin $display("ERROR PUSH: PROG_FULL1 SHOULD BE 1");error=error+1;  end
    end

    if(i==0) begin
      
      if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,OVERFLOW1} !== 6'b100_000) begin      
                  begin  $display("ERROR PUSH: ONLY EMPTY1 SHOULD BE ASSERTED"); error=error+1; end
      end
      push11();  
      @(posedge WR_CLK1);
      @(negedge WR_CLK1);
      if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,OVERFLOW1} !== 6'b000_000) begin      
                  begin  $display("ERROR PUSH: ALL DE ASSERTED"); error=error+1; end
      end
    end
    
    if(i>0 & i< DEPTH_WRITE1-2) begin
      push11();  
      @(posedge WR_CLK1);
      @(negedge WR_CLK1);
      if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,OVERFLOW1} !== 6'b000_000) begin      
                  begin  $display("ERROR PUSH: ALL SHOULD BE DE ASSERTED"); error=error+1; end
      end
    end

    if(i== DEPTH_WRITE1-2) begin
      push11();  
      @(posedge WR_CLK1);
      @(negedge WR_CLK1);
      if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,OVERFLOW1} !== 6'b000_010) begin      
                  begin  $display("ERROR PUSH: ONLY ALMOST FULL1 SHOULD BE ASSERTED"); error=error+1; end
      end
    end

    if(i== DEPTH_WRITE1-1) begin
      push11();  
      @(posedge WR_CLK1);
      @(negedge WR_CLK1);
      if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,OVERFLOW1} !== 6'b000_100) begin      
                  begin  $display("ERROR PUSH: ONLY FULL1 SHOULD BE ASSERTED"); error=error+1; end
      end
    end

    if(i==DEPTH_WRITE1 & do_overflow1) begin
      push11(); 
      @(posedge WR_CLK1);
      if (OVERFLOW1 !== 1'b1) begin      
                  begin  $display("ERROR PUSH: OVERFLOW1 SHOULD BE 1"); error=error+1; end
      end            
    end

end

end

if(DATA_WRITE_WIDTH1 > DATA_READ_WIDTH1) begin
    
    count_enteries_pop_fifo1=0;

  for(int i=0; i<DEPTH_READ1+do_underflow1; i++) begin

    compare_pop_data_fifo1();
    count_enteries_pop_fifo1= count_enteries_pop_fifo1+1;
    pop11();
    
    if(i==WgtR_Ratio1) begin

        if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,OVERFLOW1} !== 6'b000_010)
        begin $display("ERROR: ONLY ALMOST FULL1 SHOULD BE ASSERTED"); error=error+1; end
    
    end
    if(i==DEPTH_READ1-2) begin

        if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,OVERFLOW1} !== 8'b010_000)
        begin $display("ERROR: ONLY ALMOST EMPTY1 SHOULD BE ASSERTED"); error=error+1; end
    
    end

    if(i==DEPTH_READ1-1) begin

        if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,OVERFLOW1} !== 8'b100_000)
        begin $display("ERROR: EMPTY1 SHOULD BE ASSERTED"); error=error+1; end
    
    end

    if(i<WgtR_Ratio1*PROG_FULL_THRESH1) begin
          if (PROG_FULL1 !== 1)
        begin $display("ERROR: PROG FULL1 SHOULD BE ASSERTED"); error=error+1; end
    end

    if(i>DEPTH_READ1-PROG_EMPTY_THRESH1) begin
          if (PROG_EMPTY1 !== 1)
        begin $display("ERROR: PROG EMPTY1 SHOULD BE ASSERTED"); error=error+1; end
    end

    if(i==DEPTH_READ1-1 & do_underflow1) begin
        pop11();
      if(UNDERFLOW1 !== 1) begin
        $display("POP ERROR: UNDERFLOW1 SHOULD BE 1");  error=error+1;
      end
    end

  end
end

if(DATA_WRITE_WIDTH1 < DATA_READ_WIDTH1) begin

count_enteries_push_fifo1=0;

  for(int i=0; i<DEPTH_WRITE1+do_overflow1; i++) begin

    if(i<RgtW_Ratio1) begin
      push11();
      // count_clk=0;
    end
    if(i==RgtW_Ratio1-1) begin
        push11();
        if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,OVERFLOW1} !== 6'b010_000)
        begin $display("ERROR: ONLY ALMOST EMPTY1 SHOULD BE ASSERTED"); error=error+1; end
    end
    else if(i>RgtW_Ratio1-1 & i<DEPTH_WRITE1-2) begin
      push11();
    end
    else if (i==DEPTH_WRITE1-2) begin
        if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,OVERFLOW1} !== 6'b000_010)
        begin $display("ERROR: ONLY ALMOST FULL1 SHOULD BE ASSERTED"); error=error+1; end
    end
    else if (i==DEPTH_WRITE1-1) begin
      push11();
        if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,OVERFLOW1} !== 6'b000_100)
        begin $display("ERROR: ONLY FULL1 SHOULD BE ASSERTED"); error=error+1; end
    end
 
      if(i>DEPTH_WRITE1-PROG_FULL_THRESH1) begin
        if (PROG_FULL1 !==1) begin $display("ERROR PUSH: PROG_FULL1 SHOULD BE ASSERTED"); error=error+1; end
      end

      if(i<PROG_EMPTY_THRESH1) begin
        if (PROG_EMPTY1 !==1) begin $display("ERROR PUSH: PROG_EMPTY1 SHOULD BE ASSERTED"); error=error+1; end
      end

    if(i==DEPTH_WRITE1 & do_overflow1) begin
      push11();  
      if (OVERFLOW1 !== 1'b1) begin      
                  begin  $display("ERROR PUSH: OVERFLOW1 SHOULD BE 1"); error=error+1; end
      end            
    end

  end

end


if(DATA_WRITE_WIDTH1 < DATA_READ_WIDTH1) begin
  
  count_enteries_pop_fifo1=0;
  
  for(int i=0; i<DEPTH_READ1+do_underflow1; i++) begin

    compare_pop_data_fifo1();
    count_enteries_pop_fifo1= count_enteries_pop_fifo1+1;
    pop11();

      if(count_enteries_pop_fifo1==2) begin

        if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,OVERFLOW1} !== 8'b000_000)
        begin $display("ERROR: ALL FLAGS SHOULD BE DE ASSERTED"); error=error+1; end
               
      end

      if(count_enteries_pop_fifo1==DEPTH_READ1-1) begin

        if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,OVERFLOW1} !== 8'b010_000)
        begin $display("ERROR: ONLY ALMOST EMPTY1 SHOULD BE ASSERTED ASSERTED"); error=error+1; end
               
      end

      if(count_enteries_pop_fifo1==DEPTH_READ1) begin

        if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,OVERFLOW1} !== 8'b100_000)
        begin $display("ERROR: EMPTY1 SHOULD BE ASSERTED "); error=error+1; end
               
      end

    if(i==DEPTH_READ1-1 & do_underflow1) begin
    pop11();
      if(UNDERFLOW1 !== 1) begin
        $display("POP ERROR: UNDERFLOW1 SHOULD BE 1");  error=error+1;
      end
    end

if(i*RgtW_Ratio1 <PROG_FULL_THRESH1) begin
  if(PROG_FULL1 !==1) begin $display("ERROR: PROG FULL1 SHOULD BE 1 "); error=error+1; end
end

if(i> DEPTH_READ1-PROG_EMPTY_THRESH1) begin
  if(PROG_EMPTY1 !==1) begin $display("ERROR: PROG EMPTY1 SHOULD BE 1 "); error=error+1; end
end

end
end

endtask


task PUSH_FLAGS1_FULL1(input reg [5:0] in1, input string str1);

          fork 
          begin
           push11();
          end 
          join;
          if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,OVERFLOW1} !== in1) begin      
                  begin  $display("%s", str1); error=error+1; end
          end
          count_clk1=0;
endtask

task PUSH_FLAGS1_EMPTY1(input reg [5:0] in1, input string str1);

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
          if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,   FULL1,ALMOST_FULL1,OVERFLOW1} !== in1) begin      
                  begin  $display("%s", str1); error=error+1; end
          end
          count_clk1=0;
endtask



task POP_FLAGS_EMPTY1(input reg [5:0] in1, input string str1);

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
          join;
          if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,OVERFLOW1} !== in1) begin
            begin $display("%s %0b",str1, {EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,OVERFLOW1}, $time); error=error+1; end
          end
           count_clk1=0;
endtask



task POP_FLAGS_FULL1(input reg [5:0] in1, input string str1);

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
          if ({EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,OVERFLOW1} !== in1) begin
            begin $display("%s %0b",str1, {EMPTY1,ALMOST_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,OVERFLOW1}, $time); error=error+1; end
          end
           count_clk1=0;
endtask

task async_check_flags_fifo1();
    integer i;
    // resetting ptrs
    $display("--------------------------------------------");
    $display("CHECK FLAGS: RESET1 PTRS---------------------");
    WR_EN1 = 0;
    RD_EN1 = 0;
    RESET1 = 1;
    repeat(2) @(posedge WR_CLK1);
    repeat(2) @(posedge WR_CLK1);
    RESET1 = 0;
//Assertion empty_ewm_fifo_flags failed!
if(PROG_EMPTY_THRESH1>0) begin
    if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b1010_0000)
      begin $display("ERROR: EMPTY1 AND PROG EMPTY1 ARE NOT ASSERTED in1 START"); error=error+1; end
    end
    else begin
    if ({EMPTY1,ALMOST_EMPTY1,PROG_EMPTY1,UNDERFLOW1,FULL1,ALMOST_FULL1,PROG_FULL1,OVERFLOW1} !== 8'b1000_0000)
      begin $display("ERROR: EMPTY1 SHOULD BE ASSERTED in1 START"); error=error+1; end
    end
    
    $display("CHECK FLAGS: Checking Flags on Each push11/pop11 Operation---------------------");

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

count_enteries_push_fifo1=0;

// EMPTY1 De Assert

    for (int i=0; i<DEPTH_WRITE1; i++) begin


      if(i==0) begin
          PUSH_FLAGS1_EMPTY1(6'b010_000, "ERROR push11: EMPTY1 SHOULD BE DE-ASSERTED");
      end

      if(i>=1 & i<DEPTH_WRITE1- 2) begin
        PUSH_FLAGS1_EMPTY1(6'b000_000, "ERROR push11: ALMOST EMPTY1 SHOULD BE DE-ASSERTED ");
      end

      if(i==DEPTH_WRITE1- 2) begin
        PUSH_FLAGS1_FULL1(6'b000_010,"ERROR push11: ONLY ALMOST FULL1 SHOULD BE ASSERTED");                    
      end

      if(i==DEPTH_WRITE1- 1) begin
          PUSH_FLAGS1_FULL1(6'b000_100,"ERROR push11: ONLY FULL1 SHOULD BE ASSERTED");                  
      end

      if(i<PROG_EMPTY_THRESH1-1) begin
        if (PROG_EMPTY1 !==1) begin $display("ERROR push11: PROG_EMPTY1 SHOULD BE ASSERTED"); error=error+1; end
      // $display("Check111111111");
      end

      if(i>DEPTH_WRITE1-PROG_FULL_THRESH1) begin
        if (PROG_FULL1 !==1) begin $display("ERROR push11: PROG_FULL1 SHOULD BE ASSERTED"); error=error+1; end
      // $display("Check2222222");
      end

      if(do_overflow1) begin
        repeat(1) begin
          push11();
      end
      
  end
end
end



//***********************************************************************************************************************//

if(DATA_READ_WIDTH1 == DATA_WRITE_WIDTH1) begin

// FULL1 DE-ASSERT

  count_enteries_pop_fifo1=0;

  for (i=0; i<DEPTH_READ1; i++) begin

        
        if(i==0) begin
          compare_pop_data_fifo1();
          POP_FLAGS_FULL1(6'b000_010,"ERROR pop11??: ONLY PROG FULL1 and ALMOST FULL1 SHOULD BE ASSERTED");
        end

        if(i>=1 &  i< DEPTH_READ1-2) begin
          POP_FLAGS_FULL1(6'b000_000,"ERROR pop11: NO SHOULD BE ASSERTED");
        end

        if(i==DEPTH_READ1-2)  begin
          // if(DATA_READ_WIDTH1 ==9) begin
          // POP_FLAGS(6'b000_000,"ERROR?? pop11: ONLY ALMOST EMPTY1 SHOULD BE ASSERTED");
          // end
          // else begin            
          POP_FLAGS_EMPTY1(6'b010_000,"ERROR pop11: ONLY ALMOST EMPTY1 SHOULD BE ASSERTED");          
          // end          
        end

        if(i==DEPTH_READ1-1)  begin
          POP_FLAGS_EMPTY1(6'b100_000,"ERROR pop11: ONLY ALMOST EMPTY1 SHOULD BE ASSERTED");            
        end

//
      if(count_enteries_pop_fifo1<PROG_FULL_THRESH1-1) begin
        if (PROG_FULL1 !==1) begin $display("ERROR pop11: PROG_FULL1 SHOULD BE ASSERTED"); error=error+1; end
      // $display("Check33333333");
      end

      if(DEPTH_READ1-i<=PROG_EMPTY_THRESH1) begin
        if (PROG_EMPTY1 !==1) begin $display("ERROR push11: PROG_EMPTY1 NOT ASSERTED"); error=error+1; end
      // $display("Check4444444");
      end
//
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

count_enteries_push_fifo1=0;

for (int i=0; i<DEPTH_WRITE1; i++) begin  //DEPTH_WRITE1

  if(i*WgtR_Ratio1<PROG_EMPTY_THRESH1) begin
      if (PROG_EMPTY1 !==1) begin $display("ERROR push11: PROG_EMPTY1 NOT ASSERTED"); error=error+1; end
  // $display("Check111111");
  end

  if(i>DEPTH_WRITE1-PROG_FULL_THRESH1) begin
    if (PROG_FULL1 !==1) begin $display("ERROR push11: PROG_FULL1 NOT ASSERTED"); error=error+1; end
  // $display("Check222222");
  end

  if(i==0) begin
      PUSH_FLAGS1_EMPTY1(6'b000_000, "ERROR push11: ALL1 SHOULD BE DE-ASSERTED");
  end
  
  if(i>0 & i<DEPTH_WRITE1-2) begin
    PUSH_FLAGS1_EMPTY1(6'b000_000, "ERROR push11: ALL2 SHOULD BE DE-ASSERTED");
  end

  if(i==DEPTH_WRITE1-2) begin
    PUSH_FLAGS1_FULL1(6'b000_010, "ERROR push11: ONLY ALMOST FULL1 ASSERTED");
  end

  if(i==DEPTH_WRITE1-1) begin
    PUSH_FLAGS1_FULL1(6'b000_100, "ERROR push11: ONLY FULL1 SHOULD BE ASSERTED");
  end

  if(do_overflow1) begin
    repeat(1) begin
      push11();
    end
  end
// push11();

end

end

//*******************************************************************************************************************//

if(DATA_READ_WIDTH1 < DATA_WRITE_WIDTH1) begin

// FULL1 DE-ASSERT

count_enteries_pop_fifo1=0;

for (int i=0; i<DEPTH_READ1; i++) begin

        if(i<WgtR_Ratio1-1) begin
          compare_pop_data_fifo1();
          pop11();
          count_enteries_pop_fifo1=count_enteries_pop_fifo1+1;
        end
        
        else if(i==WgtR_Ratio1-1) begin
          compare_pop_data_fifo1();
          POP_FLAGS_FULL1(6'b000_010, "ERROR pop11: ONLY ALMOST FULL1 SHOULD BE ASSERTED");
        end
        
        else if(i>WgtR_Ratio1-1 & i<DEPTH_READ1-2) begin
          pop11();
          count_enteries_pop_fifo1=count_enteries_pop_fifo1+1;
          compare_pop_data_fifo1();
        end
        
        else if(i==DEPTH_READ1-2)  begin
          // if(DATA_READ_WIDTH1==9) begin
          //   POP_FLAGS(6'b000_000, "ERROR pop11: ALL SHOULD BE DE-ASSERTED");
          // end
          // else begin
            POP_FLAGS_EMPTY1(6'b010_000, "ERROR pop11: ONLY ALMOST EMPTY1 SHOULD BE ASSERTED");          
          // end
        end
        
        else if(i==DEPTH_READ1-1) begin
          POP_FLAGS_EMPTY1(6'b100_000, "ERROR pop11: ALL SHOULD BE DE-ASSERTED");
        end
        else begin
          // pop11();
        end
//

      if(i>DEPTH_READ1-PROG_EMPTY_THRESH1) begin
        if (PROG_EMPTY1 !==1) begin $display("ERROR push11: PROG_EMPTY1 NOT ASSERTED"); error=error+1; end
        // $display("Check33333");
      end

      if(i<PROG_FULL_THRESH1) begin
        if (PROG_FULL1 !==1) begin $display("ERROR push11: PROG_FULL1 NOT ASSERTED"); error=error+1; end
        // $display("Check44444");
      end
//

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
/////////////     //          //    ////////////    //      //    ||                 ////////////    //       //     ////////////
//                //          //               //   //      //    ||                 //              //       //     // 
//                //          //               //   //      //    =============      //              //       //     // 
//                  // // // //     ////////////    //      //                       //              ///////////     // 
//                     

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


if(DATA_WRITE_WIDTH1 < DATA_READ_WIDTH1) begin

count_enteries_push_fifo1=0;

  for(int i=0 ; i<DEPTH_WRITE1; i++) begin

    if(i<RgtW_Ratio1-1) begin
      push11();
      count_clk1=0;
    end
    else if(i==RgtW_Ratio1-1) begin
      PUSH_FLAGS1_EMPTY1(6'b010_000,"ERROR push11: ONLY ALMOST EMPTY1 SHOULD BE ASSERTED");
    end
    else if(i>RgtW_Ratio1 & i<DEPTH_WRITE1-2) begin
      push11();
      count_clk1=0;    
    end
    else if (i==DEPTH_WRITE1-2) begin
      PUSH_FLAGS1_FULL1(6'b000_010,"ERROR push11: ONLY ALMOST EMPTY1 SHOULD BE ASSERTED");
    end
    else if (i==DEPTH_WRITE1-1) begin
      PUSH_FLAGS1_FULL1(6'b000_100,"ERROR push11: ONLY ALMOST EMPTY1 SHOULD BE ASSERTED");
    end
    else begin
      push11();
      count_clk1=0;    
    end

      if(i>DEPTH_WRITE1-PROG_FULL_THRESH1-1) begin
        if (PROG_FULL1 !==1) begin $display("ERROR push11: PROG_EMPTY1 NOT ASSERTED ", $time); error=error+1; end
        // $display("Check11111");
      end

      if(i*RgtW_Ratio1<PROG_EMPTY_THRESH1) begin
        if (PROG_EMPTY1 !==1) begin $display("ERROR push11: PROG_FULL1 NOT ASSERTED"); error=error+1; end
        // $display("Check2222");
      end
/*
put Code for prog EMPTY1 and prog FULL1 flags

*/


// OVERFLOW1

if(do_overflow1) begin
   repeat(1) begin
    push11();
    count_clk1=0;
   end
end

end
end


//*****************************************************************************************************************//


if(DATA_READ_WIDTH1 > DATA_WRITE_WIDTH1) begin

// FULL1 DE-ASSERT
count_enteries_pop_fifo1=0;

  for (int i=0; i<DEPTH_READ1; i++) begin

  if(i==0) begin
      compare_pop_data_fifo1();
      POP_FLAGS_FULL1(6'b000_000, "ERROR pop11: ALL1 SHOULD BE DE-ASSERTED");
  end
  
  if(i>0 & i<DEPTH_READ1-2) begin
    POP_FLAGS_FULL1(6'b000_000, "ERROR pop11: ALL2 SHOULD BE DE-ASSERTED");
  end
  if(i==DEPTH_READ1-2) begin
    POP_FLAGS_EMPTY1(6'b010_000, "ERROR pop11: ONLY ALMOST FULL1 ASSERTED");
  end

  if(i==DEPTH_WRITE1-1) begin
    POP_FLAGS_EMPTY1(6'b100_000, "ERROR pop11: ONLY FULL1 SHOULD BE ASSERTED");
  end

  if((i+1)*RgtW_Ratio1< PROG_FULL_THRESH1) begin
      if (PROG_FULL1 !==1) begin $display("ERROR pop11: PROG_FULL1 NOT ASSERTED", $time); error=error+1; end
  // $display("Check3333");
  end

  if(i>=DEPTH_READ1-PROG_EMPTY_THRESH1/RgtW_Ratio1) begin
    if (PROG_EMPTY1 !==1) begin $display("ERROR pop11: PROG_EMPTY1 NOT ASSERTED"); error=error+1; end
  // $display("Check44444");
  end
  end
end

endtask :  async_check_flags_fifo1



////////////////////////////////////////////  END FIFO-1    ///////////////////////////////////////////



/////////////////////////////////////////////   FIFO-2    /////////////////////////////////////////////


reg [8:0] fifo2_pop_data1;
reg [8:0] fifo2_pop_data2;
reg [8:0] fifo2_pop_data3;
reg [8:0] fifo2_pop_data4;
integer fifo2_fwft_data1=0;
integer fifo2_fwft_data2=0;
integer fifo2_fwft_data3=0;
integer fifo2_fwft_data4=0;

reg [8:0] local_queue2 [$];


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
    
        if (count_enteries_push_fifo2==0) begin
       
           fifo2_fwft_data1 = WR_DATA2;
        
        end    
            local_queue2.push_back({WR_DATA2[8], WR_DATA2[7:0]});
      end 

      else if(DATA_WRITE_WIDTH2==18) begin  // 18
        
        if (count_enteries_push_fifo2==0) begin
           fifo2_fwft_data1 = {WR_DATA2[8],WR_DATA2[7:0]};
           fifo2_fwft_data2 = {WR_DATA2[17],WR_DATA2[16:9]};
        end    
        local_queue2.push_back({WR_DATA2[8],WR_DATA2[7:0]});  
        local_queue2.push_back({WR_DATA2[17],WR_DATA2[16:9]});  
      end

   end

// R-18

  if (DATA_READ_WIDTH2==18) begin
   
      if(DATA_WRITE_WIDTH2==9) begin  // 9
    
        if (count_enteries_push_fifo2==0) begin
       
           fifo2_fwft_data1 = WR_DATA2;

        end

        else if (count_enteries_push_fifo2==1) begin

           fifo2_fwft_data2 = WR_DATA2;
        
        end    
            local_queue2.push_back({WR_DATA2[8], WR_DATA2[7:0]});
      end 

      else if(DATA_WRITE_WIDTH2==18) begin  // 18
        
        if (count_enteries_push_fifo2==0) begin
           fifo2_fwft_data1 = {WR_DATA2[8],WR_DATA2[7:0]};
           fifo2_fwft_data2 = {WR_DATA2[17],WR_DATA2[16:9]};
        end    
        local_queue2.push_back({WR_DATA2[8],WR_DATA2[7:0]});  
        local_queue2.push_back({WR_DATA2[17],WR_DATA2[16:9]});  
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
        if (count_enteries_pop_fifo2==2048) begin
          compare2(RD_DATA2[8:0], fifo2_fwft_data1);
        end
        else begin
          exp_dout2 = local_queue2.pop_front();
          compare2(RD_DATA2,exp_dout2);
        end
    end

    if(DATA_WRITE_WIDTH2==18) begin
        if (count_enteries_pop_fifo2==2048) begin
          compare2(RD_DATA2, fifo2_fwft_data1);
          exp_dout2 = local_queue2.pop_front();
        end
        else begin
          exp_dout2 = local_queue2.pop_front();
          compare2(RD_DATA2,exp_dout2);
        end
    end

  end

// R-18

  else if (DATA_READ_WIDTH2==18 ) begin
    
    if(DATA_WRITE_WIDTH2==9) begin
       if (count_enteries_pop_fifo2==1024) begin

          compare2({RD_DATA2[8],RD_DATA2[7:0]}, fifo2_fwft_data1);
          compare2({RD_DATA2[17],RD_DATA2[16:9]}, fifo2_fwft_data2);

        end
        else begin
            fifo2_pop_data1= local_queue2.pop_front();
            fifo2_pop_data2= local_queue2.pop_front();
            compare2({RD_DATA2[8], RD_DATA2[7:0]},  {fifo2_pop_data1[8], fifo2_pop_data1[7:0]});
            compare2({RD_DATA2[17], RD_DATA2[16:9]}, {fifo2_pop_data2[8], fifo2_pop_data2[7:0]});
        end
    end
  
      if(DATA_WRITE_WIDTH2==18) begin

       if (count_enteries_pop_fifo2==1024) begin
          fifo2_pop_data1= local_queue2.pop_front();
          fifo2_pop_data2= local_queue2.pop_front();
          compare2({RD_DATA2[8],RD_DATA2[7:0]}, fifo2_fwft_data1);
          compare2({RD_DATA2[17],RD_DATA2[16:9]}, fifo2_fwft_data2);
        end
        
        else begin
          
          fifo2_pop_data1= local_queue2.pop_front();
          fifo2_pop_data2= local_queue2.pop_front();
          compare2({RD_DATA2[8], RD_DATA2[7:0]},  {fifo2_pop_data1[8], fifo2_pop_data1[7:0]});
          compare2({RD_DATA2[17], RD_DATA2[16:9]}, {fifo2_pop_data2[8], fifo2_pop_data2[7:0]});
        end
    end
  end 

endtask


task sync_check_flags_fifo2_symmetric();

    $display("--------------------------------------------");
    $display("CHECK FLAGS: RESET2 PTRS---------------------");
    WR_EN2 = 0;
    RD_EN2 = 0;
    RESET2 = 1;
    repeat(2) @(negedge WR_CLK2);
    repeat(2) @(negedge WR_CLK2);
    RESET2 = 0;
    @(posedge WR_CLK2);
    @(negedge WR_CLK2);

    // if(debug) $display("CHECK FLAGS: EMPTY2 FIFO---------------------");
    $display("CHECK FLAGS: EMPTY2 FIFO---------------------");
    if(PROG_EMPTY_THRESH2>0) begin
    if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b1010_0000)
      begin $display("Assertion empty_ewm_fifo_flags failed!"); error=error+1; end
    end
    else begin
    if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b1000_0000)
      begin $display("Assertion empty_fifo_flags failed!"); error=error+1; end
    end

    $display("CHECK FLAGS: Checking Flags on Each PUSH/POP Operation---------------------");
    count_enteries_push_fifo2=0;
  
  for(integer i = 1 ; i<=DEPTH_WRITE2+do_overflow2; i=i+1) begin
    
    if(i==1) begin
      push22();
      @(posedge WR_CLK2);
      @(negedge WR_CLK2);
      // $display("time %t", $time);
      if ({EMPTY2,ALMOST_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,OVERFLOW2} !== 6'b010_000) begin      
                  begin  $display("ERROR PUSH: ONLY ALMOST EMPTY2 SHOULD BE ASSERTED"); error=error+1; end
      end
    end
    if(i>1 & i<DEPTH_WRITE2-1) begin
      push22();
      @(posedge WR_CLK2);
      @(negedge WR_CLK2);
      // $display("time %t", $time);
      if ({EMPTY2,ALMOST_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,OVERFLOW2} !== 6'b000_000) begin      
                  begin  $display("ERROR PUSH: ALL SHOULD BE DE-ASSERTED"); error=error+1; end
      end
    end

    if(i==DEPTH_WRITE2-1) begin
      push22();
      @(posedge WR_CLK2);
      @(negedge WR_CLK2);
      // $display("time %t", $time);
      if ({EMPTY2,ALMOST_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,OVERFLOW2} !== 6'b000_010) begin      
                  begin  $display("ERROR PUSH: ONLY ALMOST FULL2 SHOULD BE ASSERTED"); error=error+1; end
      end
    end

    if(i==DEPTH_WRITE2) begin
      push22();
      @(posedge WR_CLK2);
      @(negedge WR_CLK2);
      // $display("time %t", $time);
      if ({EMPTY2,ALMOST_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,OVERFLOW2} !== 6'b000_100) begin      
                  begin  $display("ERROR PUSH: ONLY FULL2 SHOULD BE ASSERTED"); error=error+1; end
      end
    end

      if(i==DEPTH_WRITE2 & do_overflow2) begin
      push22(); 
      @(posedge WR_CLK2);
      if (OVERFLOW2 !== 1'b1) begin      
                  begin  $display("ERROR PUSH: OVERFLOW2 SHOULD BE 1"); error=error+1; end
      end            
    end
  
  if(i<=PROG_EMPTY_THRESH2) begin
          if (PROG_EMPTY2 !== 1) begin      
                  begin  $display("ERROR PUSH: PROG EMPTY2 SHOULD BE ASSERTED"); error=error+1; end
      end
  end

 if(i>DEPTH_WRITE2-PROG_FULL_THRESH2) begin
          if (PROG_FULL2 !== 1) begin      
                  begin  $display("ERROR PUSH: PROG FULL2 SHOULD BE ASSERTED"); error=error+1; end
      end
  end

 end

count_enteries_pop_fifo2=0;
for(integer i = 1 ; i<=DEPTH_READ2+do_underflow2; i=i+1) begin


if(i==1) begin
    compare_pop_data_fifo2();
    count_enteries_pop_fifo2= count_enteries_pop_fifo2+1;
    pop22();
    compare_pop_data_fifo2();
    count_enteries_pop_fifo2= count_enteries_pop_fifo2+1;
    @(posedge WR_CLK2);
    @(negedge WR_CLK2);
    if ({EMPTY2,ALMOST_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,OVERFLOW2} !== 6'b000_010) begin      
                  begin  $display("ERROR PUSH: ONLY ALMOST FULL2 SHOULD BE ASSERTED"); error=error+1; end
    end
end

if(i>1 & i<DEPTH_READ2-1) begin
    pop22();
    compare_pop_data_fifo2();
    count_enteries_pop_fifo2= count_enteries_pop_fifo2+1;
    @(posedge WR_CLK2);
    @(negedge WR_CLK2);
    if ({EMPTY2,ALMOST_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,OVERFLOW2} !== 6'b000_000) begin      
                  begin  $display("ERROR PUSH: ALL SHOULD BE DE-ASSERTED"); error=error+1; end
    end
end

if(i==DEPTH_READ2-1) begin
    pop22();
    compare_pop_data_fifo2();
    count_enteries_pop_fifo2= count_enteries_pop_fifo2+1;
    @(posedge WR_CLK2);
    if ({EMPTY2,ALMOST_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,OVERFLOW2} !== 6'b010_000) begin      
                  begin  $display("ERROR PUSH: ONLY ALMOST EMPTY2 SHOULD BE ASSERTED"); error=error+1; end
    end
end

if(i==DEPTH_READ2) begin
    pop22();
    compare_pop_data_fifo2();
    count_enteries_pop_fifo2= count_enteries_pop_fifo2+1;
    @(posedge WR_CLK2);
    if ({EMPTY2,ALMOST_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,OVERFLOW2} !== 6'b100_000) begin      
                  begin  $display("ERROR PUSH: ONLY EMPTY2 SHOULD BE ASSERTED"); error=error+1; end
    end
end

if(i==DEPTH_READ2+do_underflow2 & do_underflow2==1) begin
    pop22();
    @(posedge WR_CLK2);
    if ({EMPTY2,ALMOST_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,OVERFLOW2} !== 6'b101_000) begin      
                  begin  $display("ERROR PUSH: EMPTY2 AND UNDERFLOW2 SHOULD BE ASSERTED"); error=error+1; end
    end
end

if(i<PROG_FULL_THRESH2) begin
    if (PROG_FULL2 !== 1)
    begin $display("ERROR: PROG FULL2 SHOULD BE ASSERTED"); error=error+1; end
end

if(i>DEPTH_READ2-PROG_EMPTY_THRESH2) begin
    if (PROG_EMPTY2 !== 1)
    begin $display("ERROR: PROG EMPTY2 SHOULD BE ASSERTED"); error=error+1; end
end


end

endtask

task sync_check_flags_fifo2_asymmetric();
// RESET1ting ptrs


    $display("--------------------------------------------");
    $display("CHECK FLAGS: RESET2 PTRS---------------------");
    WR_EN2 = 0;
    RD_EN2 = 0;
    RESET2 = 1;
    repeat(2) @(negedge WR_CLK2);
    repeat(2) @(negedge WR_CLK2);
    RESET2 = 0;
    @(posedge WR_CLK2);
    @(negedge WR_CLK2);

  if( DATA_WRITE_WIDTH2> DATA_READ_WIDTH2) begin
  
  count_enteries_push_fifo2=0;
  
  for(int i=0; i<DEPTH_WRITE2+do_overflow2; i++) begin
    
    if((i+1)*WgtR_Ratio2<PROG_EMPTY_THRESH2) begin
      if(PROG_EMPTY2 !==1) begin $display("ERROR PUSH: PROG_EMPTY2 SHOULD BE 1");error=error+1;  end
    end

    if(i>DEPTH_WRITE2-PROG_FULL_THRESH2) begin
      if(PROG_FULL2 !==1) begin $display("ERROR PUSH: PROG_FULL2 SHOULD BE 1");error=error+1;  end
    end

    if(i==0) begin
      
      if ({EMPTY2,ALMOST_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,OVERFLOW2} !== 6'b100_000) begin      
                  begin  $display("ERROR PUSH: ONLY EMPTY2 SHOULD BE ASSERTED"); error=error+1; end
      end
      push22();  
      @(posedge WR_CLK2);
      @(negedge WR_CLK2);
      if ({EMPTY2,ALMOST_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,OVERFLOW2} !== 6'b000_000) begin      
                  begin  $display("ERROR PUSH: ALL DE ASSERTED"); error=error+1; end
      end
    end
    
    if(i>0 & i< DEPTH_WRITE2-2) begin
      push22();  
      @(posedge WR_CLK2);
      @(negedge WR_CLK2);
      if ({EMPTY2,ALMOST_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,OVERFLOW2} !== 6'b000_000) begin      
                  begin  $display("ERROR PUSH: ALL SHOULD BE DE ASSERTED"); error=error+1; end
      end
    end

    if(i== DEPTH_WRITE2-2) begin
      push22();  
      @(posedge WR_CLK2);
      @(negedge WR_CLK2);
      if ({EMPTY2,ALMOST_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,OVERFLOW2} !== 6'b000_010) begin      
                  begin  $display("ERROR PUSH:?? ONLY ALMOST FULL2 SHOULD BE ASSERTED"); error=error+1; end
      end
    end

    if(i== DEPTH_WRITE2-1) begin
      push22();  
      @(posedge WR_CLK2);
      @(negedge WR_CLK2);
      if ({EMPTY2,ALMOST_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,OVERFLOW2} !== 6'b000_100) begin      
                  begin  $display("ERROR PUSH: ONLY FULL2 SHOULD BE ASSERTED"); error=error+1; end
      end
    end

    if(i==DEPTH_WRITE2 & do_overflow2) begin
      push22(); 
      @(posedge WR_CLK2);
      if (OVERFLOW2 !== 1'b1) begin      
                  begin  $display("ERROR PUSH: OVERFLOW2 SHOULD BE 1"); error=error+1; end
      end            
    end

end

end

if(DATA_WRITE_WIDTH2 > DATA_READ_WIDTH2) begin
    
    count_enteries_pop_fifo2=0;

  for(int i=0; i<DEPTH_READ2+do_underflow2; i++) begin

    compare_pop_data_fifo2();
    count_enteries_pop_fifo2= count_enteries_pop_fifo2+1;
    pop22();
    
    if(i==WgtR_Ratio2) begin

        if ({EMPTY2,ALMOST_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,OVERFLOW2} !== 6'b000_010)
        begin $display("ERROR: ONLY ALMOST FULL2 SHOULD BE ASSERTED"); error=error+1; end
    
    end
    if(i==DEPTH_READ2-2) begin

        if ({EMPTY2,ALMOST_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,OVERFLOW2} !== 8'b010_000)
        begin $display("ERROR: ONLY ALMOST EMPTY2 SHOULD BE ASSERTED"); error=error+1; end
    
    end

    if(i==DEPTH_READ2-1) begin

        if ({EMPTY2,ALMOST_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,OVERFLOW2} !== 8'b100_000)
        begin $display("ERROR: EMPTY2 SHOULD BE ASSERTED"); error=error+1; end
    
    end

    if(i<WgtR_Ratio2*PROG_FULL_THRESH2) begin
          if (PROG_FULL2 !== 1)
        begin $display("ERROR: PROG FULL2 SHOULD BE ASSERTED"); error=error+1; end
    end

    if(i>DEPTH_READ2-PROG_EMPTY_THRESH2) begin
          if (PROG_EMPTY2 !== 1)
        begin $display("ERROR: PROG EMPTY2 SHOULD BE ASSERTED"); error=error+1; end
    end

    if(i==DEPTH_READ2-1 & do_underflow2) begin
        pop22();
      if(UNDERFLOW2 !== 1) begin
        $display("POP ERROR: UNDERFLOW2 SHOULD BE 1");  error=error+1;
      end
    end

  end
end

if(DATA_WRITE_WIDTH2 < DATA_READ_WIDTH2) begin

count_enteries_push_fifo2=0;

  for(int i=0; i<DEPTH_WRITE2+do_overflow2; i++) begin

    if(i<RgtW_Ratio2) begin
      push22();
      // count_clk=0;
    end
    if(i==RgtW_Ratio2-1) begin
        push22();
        if ({EMPTY2,ALMOST_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,OVERFLOW2} !== 6'b010_000)
        begin $display("ERROR: ONLY ALMOST EMPTY2 SHOULD BE ASSERTED"); error=error+1; end
    end
    else if(i>RgtW_Ratio2-1 & i<DEPTH_WRITE2-2) begin
      push22();
    end
    else if (i==DEPTH_WRITE2-2) begin
        if ({EMPTY2,ALMOST_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,OVERFLOW2} !== 6'b000_010)
        begin $display("ERROR: ONLY ALMOST FULL2 SHOULD BE ASSERTED"); error=error+1; end
    end
    else if (i==DEPTH_WRITE2-1) begin
      push22();
        if ({EMPTY2,ALMOST_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,OVERFLOW2} !== 6'b000_100)
        begin $display("ERROR: ONLY FULL2 SHOULD BE ASSERTED"); error=error+1; end
    end
 
      if(i>DEPTH_WRITE2-PROG_FULL_THRESH2) begin
        if (PROG_FULL2 !==1) begin $display("ERROR PUSH: PROG_FULL2 SHOULD BE ASSERTED"); error=error+1; end
      end

      if(i<PROG_EMPTY_THRESH2) begin
        if (PROG_EMPTY2 !==1) begin $display("ERROR PUSH: PROG_EMPTY2 SHOULD BE ASSERTED"); error=error+1; end
      end

    if(i==DEPTH_WRITE2 & do_overflow2) begin
      push22();  
      if (OVERFLOW2 !== 1'b1) begin      
                  begin  $display("ERROR PUSH: OVERFLOW2 SHOULD BE 1"); error=error+1; end
      end            
    end

  end

end


if(DATA_WRITE_WIDTH2 < DATA_READ_WIDTH2) begin
  
  count_enteries_pop_fifo2=0;
  
  for(int i=0; i<DEPTH_READ2+do_underflow2; i++) begin

    compare_pop_data_fifo2();
    count_enteries_pop_fifo2= count_enteries_pop_fifo2+1;
    pop22();

      if(count_enteries_pop_fifo2==2) begin

        if ({EMPTY2,ALMOST_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,OVERFLOW2} !== 8'b000_000)
        begin $display("ERROR: ALL FLAGS SHOULD BE DE ASSERTED"); error=error+1; end
               
      end

      if(count_enteries_pop_fifo2==DEPTH_READ2-1) begin

        if ({EMPTY2,ALMOST_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,OVERFLOW2} !== 8'b010_000)
        begin $display("ERROR: ONLY ALMOST EMPTY2 SHOULD BE ASSERTED ASSERTED"); error=error+1; end
               
      end

      if(count_enteries_pop_fifo2==DEPTH_READ2) begin

        if ({EMPTY2,ALMOST_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,OVERFLOW2} !== 8'b100_000)
        begin $display("ERROR: EMPTY2 SHOULD BE ASSERTED "); error=error+1; end
               
      end

    if(i==DEPTH_READ2-1 & do_underflow2) begin
    pop22();
      if(UNDERFLOW2 !== 1) begin
        $display("POP ERROR: UNDERFLOW2 SHOULD BE 1");  error=error+1;
      end
    end

if(i*RgtW_Ratio2 <PROG_FULL_THRESH2) begin
  if(PROG_FULL2 !==1) begin $display("ERROR: PROG FULL2 SHOULD BE 1 "); error=error+1; end
end

if(i> DEPTH_READ2-PROG_EMPTY_THRESH2) begin
  if(PROG_EMPTY2 !==1) begin $display("ERROR: PROG EMPTY2 SHOULD BE 1 "); error=error+1; end
end

end
end

endtask


task PUSH_FLAGS1_FULL2(input reg [5:0] in2, input string str2);

          fork 
          begin
           push22();
          end 
          join;
          if ({EMPTY2,ALMOST_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,OVERFLOW2} !== in2) begin      
                  begin  $display("%s", str2); error=error+1; end
          end
          count_clk2=0;
endtask

task PUSH_FLAGS1_EMPTY2(input reg [5:0] in2, input string str2);

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
          if ({EMPTY2,ALMOST_EMPTY2,UNDERFLOW2,   FULL2,ALMOST_FULL2,OVERFLOW2} !== in2) begin      
                  begin  $display("%s", str2); error=error+1; end
          end
          count_clk2=0;
endtask



task POP_FLAGS_EMPTY2(input reg [5:0] in2, input string str2);

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
          join;
          if ({EMPTY2,ALMOST_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,OVERFLOW2} !== in2) begin
            begin $display("%s %0b",str2, {EMPTY2,ALMOST_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,OVERFLOW2}, $time); error=error+1; end
          end
           count_clk2=0;
endtask



task POP_FLAGS_FULL2(input reg [5:0] in2, input string str2);

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
          if ({EMPTY2,ALMOST_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,OVERFLOW2} !== in2) begin
            begin $display("%s %0b",str2, {EMPTY2,ALMOST_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,OVERFLOW2}, $time); error=error+1; end
          end
           count_clk2=0;
endtask

task async_check_flags_fifo2();
    integer i;
    // resetting ptrs
    $display("--------------------------------------------");
    $display("CHECK FLAGS: RESET2 PTRS---------------------");
    WR_EN2 = 0;
    RD_EN2 = 0;
    RESET2 = 1;
    repeat(2) @(posedge WR_CLK2);
    repeat(2) @(posedge WR_CLK2);
    RESET2 = 0;
//Assertion empty_ewm_fifo_flags failed!
if(PROG_EMPTY_THRESH2>0) begin
    if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b1010_0000)
      begin $display("ERROR: EMPTY2 AND PROG EMPTY2 ARE NOT ASSERTED in2 START"); error=error+1; end
    end
    else begin
    if ({EMPTY2,ALMOST_EMPTY2,PROG_EMPTY2,UNDERFLOW2,FULL2,ALMOST_FULL2,PROG_FULL2,OVERFLOW2} !== 8'b1000_0000)
      begin $display("ERROR: EMPTY2 SHOULD BE ASSERTED in2 START"); error=error+1; end
    end
    
    $display("CHECK FLAGS: Checking Flags on Each push22/pop11 Operation---------------------");

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

count_enteries_push_fifo2=0;

// EMPTY2 De Assert

    for (int i=0; i<DEPTH_WRITE2; i++) begin


      if(i==0) begin
          PUSH_FLAGS1_EMPTY2(6'b010_000, "ERROR push22: EMPTY2 SHOULD BE DE-ASSERTED");
      end

      if(i>=1 & i<DEPTH_WRITE2- 2) begin
        PUSH_FLAGS1_EMPTY2(6'b000_000, "ERROR push22: ALMOST EMPTY2 SHOULD BE DE-ASSERTED ");
      end

      if(i==DEPTH_WRITE2- 2) begin
        PUSH_FLAGS1_FULL2(6'b000_010,"ERROR push22: ONLY ALMOST FULL2 SHOULD BE ASSERTED");                    
      end

      if(i==DEPTH_WRITE2- 1) begin
          PUSH_FLAGS1_FULL2(6'b000_100,"ERROR push22: ONLY FULL2 SHOULD BE ASSERTED");                  
      end

      if(i<PROG_EMPTY_THRESH2-1) begin
        if (PROG_EMPTY2 !==1) begin $display("ERROR push22: PROG_EMPTY2 SHOULD BE ASSERTED"); error=error+1; end
      // $display("Check111111111");
      end

      if(i>DEPTH_WRITE2-PROG_FULL_THRESH2) begin
        if (PROG_FULL2 !==1) begin $display("ERROR push22: PROG_FULL2 SHOULD BE ASSERTED"); error=error+1; end
      // $display("Check2222222");
      end

      if(do_overflow2) begin
        repeat(1) begin
          push22();
      end
      
  end
end
end



//***********************************************************************************************************************//

if(DATA_READ_WIDTH2 == DATA_WRITE_WIDTH2) begin

// FULL2 DE-ASSERT

  count_enteries_pop_fifo2=0;

  for (i=0; i<DEPTH_READ2; i++) begin

        
        if(i==0) begin
          compare_pop_data_fifo2();
          POP_FLAGS_FULL2(6'b000_010,"ERROR pop11??: ONLY PROG FULL2 and ALMOST FULL2 SHOULD BE ASSERTED");
        end

        if(i>=1 &  i< DEPTH_READ2-2) begin
          POP_FLAGS_FULL2(6'b000_000,"ERROR pop11: NO SHOULD BE ASSERTED");
        end

        if(i==DEPTH_READ2-2)  begin
          // if(DATA_READ_WIDTH2 ==9) begin
          // POP_FLAGS(6'b000_000,"ERROR?? pop11: ONLY ALMOST EMPTY2 SHOULD BE ASSERTED");
          // end
          // else begin            
          POP_FLAGS_EMPTY2(6'b010_000,"ERROR pop11: ONLY ALMOST EMPTY2 SHOULD BE ASSERTED");          
          // end          
        end

        if(i==DEPTH_READ2-1)  begin
          POP_FLAGS_EMPTY2(6'b100_000,"ERROR pop11: ONLY ALMOST EMPTY2 SHOULD BE ASSERTED");            
        end

//
      if(count_enteries_pop_fifo2<PROG_FULL_THRESH2-1) begin
        if (PROG_FULL2 !==1) begin $display("ERROR pop11: PROG_FULL2 SHOULD BE ASSERTED"); error=error+1; end
      // $display("Check33333333");
      end

      if(DEPTH_READ2-i<=PROG_EMPTY_THRESH2) begin
        if (PROG_EMPTY2 !==1) begin $display("ERROR push22: PROG_EMPTY2 NOT ASSERTED"); error=error+1; end
      // $display("Check4444444");
      end
//
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


if(  DATA_WRITE_WIDTH2 > DATA_READ_WIDTH2  ) begin

count_enteries_push_fifo2=0;

for (int i=0; i<DEPTH_WRITE2; i++) begin  //DEPTH_WRITE2

  if(i*WgtR_Ratio2<PROG_EMPTY_THRESH2) begin
      if (PROG_EMPTY2 !==1) begin $display("ERROR push22: PROG_EMPTY2 NOT ASSERTED"); error=error+1; end
  // $display("Check111111");
  end

  if(i>DEPTH_WRITE2-PROG_FULL_THRESH2) begin
    if (PROG_FULL2 !==1) begin $display("ERROR push22: PROG_FULL2 NOT ASSERTED"); error=error+1; end
  // $display("Check222222");
  end

  if(i==0) begin
      PUSH_FLAGS1_EMPTY2(6'b000_000, "ERROR push22: ALL1 SHOULD BE DE-ASSERTED");
  end
  
  if(i>0 & i<DEPTH_WRITE2-2) begin
    PUSH_FLAGS1_EMPTY2(6'b000_000, "ERROR push22: ALL2 SHOULD BE DE-ASSERTED");
  end

  if(i==DEPTH_WRITE2-2) begin
    PUSH_FLAGS1_FULL2(6'b000_010, "ERROR push22: ONLY ALMOST FULL2 ASSERTED");
  end

  if(i==DEPTH_WRITE2-1) begin
    PUSH_FLAGS1_FULL2(6'b000_100, "ERROR push22: ONLY FULL2 SHOULD BE ASSERTED");
  end

  if(do_overflow2) begin
    repeat(1) begin
      push22();
    end
  end
// push22();

end

end

//*******************************************************************************************************************//

if(DATA_READ_WIDTH2 < DATA_WRITE_WIDTH2) begin

// FULL2 DE-ASSERT

count_enteries_pop_fifo2=0;

for (int i=0; i<DEPTH_READ2; i++) begin

        if(i<WgtR_Ratio2-1) begin
          compare_pop_data_fifo2();
          pop22();
          count_enteries_pop_fifo2=count_enteries_pop_fifo2+1;
        end
        
        else if(i==WgtR_Ratio2-1) begin
          compare_pop_data_fifo2();
          POP_FLAGS_FULL2(6'b000_010, "ERROR pop11: ONLY ALMOST FULL2 SHOULD BE ASSERTED");
        end
        
        else if(i>WgtR_Ratio2-1 & i<DEPTH_READ2-2) begin
          pop22();
          count_enteries_pop_fifo2=count_enteries_pop_fifo2+1;
          compare_pop_data_fifo2();
        end
        
        else if(i==DEPTH_READ2-2)  begin
          // if(DATA_READ_WIDTH2==9) begin
          //   POP_FLAGS(6'b000_000, "ERROR pop11: ALL SHOULD BE DE-ASSERTED");
          // end
          // else begin
            POP_FLAGS_EMPTY2(6'b010_000, "ERROR pop11: ONLY ALMOST EMPTY2 SHOULD BE ASSERTED");          
          // end
        end
        
        else if(i==DEPTH_READ2-1) begin
          POP_FLAGS_EMPTY2(6'b100_000, "ERROR pop11: ALL SHOULD BE DE-ASSERTED");
        end
        else begin
          // pop11();
        end
//

      if(i>DEPTH_READ2-PROG_EMPTY_THRESH2) begin
        if (PROG_EMPTY2 !==1) begin $display("ERROR push22: PROG_EMPTY2 NOT ASSERTED"); error=error+1; end
        // $display("Check33333");
      end

      if(i<PROG_FULL_THRESH2) begin
        if (PROG_FULL2 !==1) begin $display("ERROR push22: PROG_FULL2 NOT ASSERTED"); error=error+1; end
        // $display("Check44444");
      end
//

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


if(DATA_WRITE_WIDTH2 < DATA_READ_WIDTH2) begin

count_enteries_push_fifo2=0;

  for(int i=0 ; i<DEPTH_WRITE2; i++) begin

    if(i<RgtW_Ratio2-1) begin
      push22();
      count_clk2=0;
    end
    else if(i==RgtW_Ratio2-1) begin
      PUSH_FLAGS1_EMPTY2(6'b010_000,"ERROR push22: ONLY ALMOST EMPTY2 SHOULD BE ASSERTED");
    end
    else if(i>RgtW_Ratio2 & i<DEPTH_WRITE2-2) begin
      push22();
      count_clk2=0;    
    end
    else if (i==DEPTH_WRITE2-2) begin
      PUSH_FLAGS1_FULL2(6'b000_010,"ERROR push22: ONLY ALMOST EMPTY2 SHOULD BE ASSERTED");
    end
    else if (i==DEPTH_WRITE2-1) begin
      PUSH_FLAGS1_FULL2(6'b000_100,"ERROR push22: ONLY ALMOST EMPTY2 SHOULD BE ASSERTED");
    end
    else begin
      push22();
      count_clk2=0;    
    end

      if(i>DEPTH_WRITE2-PROG_FULL_THRESH2-1) begin
        if (PROG_FULL2 !==1) begin $display("ERROR push22: PROG_EMPTY2 NOT ASSERTED ", $time); error=error+1; end
        // $display("Check11111");
      end

      if(i*RgtW_Ratio2<PROG_EMPTY_THRESH2) begin
        if (PROG_EMPTY2 !==1) begin $display("ERROR push22: PROG_FULL2 NOT ASSERTED"); error=error+1; end
        // $display("Check2222");
      end
/*
put Code for prog EMPTY2 and prog FULL2 flags

*/


// OVERFLOW2

if(do_overflow2) begin
   repeat(1) begin
    push22();
    count_clk2=0;
   end
end

end
end


//*****************************************************************************************************************//


if(DATA_READ_WIDTH2 > DATA_WRITE_WIDTH2) begin

// FULL2 DE-ASSERT
count_enteries_pop_fifo2=0;

  for (int i=0; i<DEPTH_READ2; i++) begin

  if(i==0) begin
      compare_pop_data_fifo2();
      POP_FLAGS_FULL2(6'b000_000, "ERROR pop11: ALL1 SHOULD BE DE-ASSERTED");
  end
  
  if(i>0 & i<DEPTH_READ2-2) begin
    POP_FLAGS_FULL2(6'b000_000, "ERROR pop11: ALL2 SHOULD BE DE-ASSERTED");
  end
  if(i==DEPTH_READ2-2) begin
    POP_FLAGS_EMPTY2(6'b010_000, "ERROR pop11: ONLY ALMOST FULL2 ASSERTED");
  end

  if(i==DEPTH_WRITE2-1) begin
    POP_FLAGS_EMPTY2(6'b100_000, "ERROR pop11: ONLY FULL2 SHOULD BE ASSERTED");
  end

  if((i+1)*RgtW_Ratio2< PROG_FULL_THRESH2) begin
      if (PROG_FULL2 !==1) begin $display("ERROR pop11: PROG_FULL2 NOT ASSERTED", $time); error=error+1; end
  // $display("Check3333");
  end

  if(i>=DEPTH_READ2-PROG_EMPTY_THRESH2/RgtW_Ratio2) begin
    if (PROG_EMPTY2 !==1) begin $display("ERROR pop11: PROG_EMPTY2 NOT ASSERTED"); error=error+1; end
  // $display("Check44444");
  end
  end
end

endtask :  async_check_flags_fifo2


task compare1(input reg [8:0] RD_DATA1, exp_dout1);

	if(RD_DATA1 !== exp_dout1) begin
		$display("RD_DATA1 mismatch. DUT_Out1: %0h, Expected_Out1: %h, Time: %0t", RD_DATA1, exp_dout1,$time);
		error = error+1;
	end
	else if(debug1)
		$display("RD_DATA1 match. DUT_Out1: %0h, Expected_Out1: %0h, Time: %0t", RD_DATA1, exp_dout1,$time);
endtask

task compare2(input reg [8:0] RD_DATA2, exp_dout2);

  if(RD_DATA2 !== exp_dout2) begin
    $display("RD_DATA2 mismatch. DUT_Out2: %0h, Expected_Out2: %h, Time: %0t", RD_DATA2, exp_dout2,$time);
    error = error+1;
  end
  else if(debug2)
    $display("RD_DATA2 match. DUT_Out2: %0h, Expected_Out2: %0h, Time: %0t", RD_DATA2, exp_dout2,$time);

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
