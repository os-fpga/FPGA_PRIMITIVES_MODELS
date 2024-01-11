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
	bit debug=0;

	//clock//
	initial begin
		WR_CLK = 1'b0;
		forever #20 WR_CLK = ~WR_CLK;
end

// initial begin
// 	RD_CLK = 1'b0;
// 	forever #15 RD_CLK = ~RD_CLK;
// end

	initial begin
			RD_CLK = 1'b0;
			forever #20 RD_CLK = ~RD_CLK;
	end

	 FIFO36K #(
		.DATA_WIDTH(DATA_WIDTH),
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
		$dumpfile("out/wave.vcd");
		$dumpvars;
	end

	task check_flags();
    integer i;
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
    if(debug) $display(" RD_EN = ",RD_EN, " RD_DATA = ",RD_DATA);
    if (UNDERFLOW)
      $display("FIFO is UNDERFLOW, POPing is UNDERFLOW");
    else if(EMPTY) begin
      $display("FIFO is EMPTY, POPing is UNDERFLOW");
      local_queue.delete();
    end
    else begin
      exp_dout = local_queue.pop_front();
      compare(RD_DATA, exp_dout);
    end
    @(negedge WR_CLK);
		RD_EN =0;
  endtask
  
  //task push(reg [32-1:0] in_din=$urandom_range(0, 2**32-1)); 
  task push(reg [DATA_WIDTH-1:0] in_din=$urandom_range(0, 2**DATA_WIDTH-1)); 
    @(negedge WR_CLK);
		WR_EN = 1; 
    WR_DATA = in_din;
    if(debug) $display(" WR_EN = ",WR_EN, " WR_DATA = ",WR_DATA);
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

task compare(input reg [DATA_WIDTH-1:0] RD_DATA, exp_dout);
	if(RD_DATA !== exp_dout) begin
		$display("RD_DATA mismatch. DUT_Out: %0d, Expected_Out: %0d, Time: %0t", RD_DATA, exp_dout,$time);
		error = error+1;
	end
	else if(debug)
		$display("RD_DATA match. DUT_Out: %0d, Expected_Out: %0d, Time: %0t", RD_DATA, exp_dout,$time);
endtask

endmodule