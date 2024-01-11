`include "./sim_models_internal/verilog/TDP_RAM18KX2.v"
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

	parameter DATA_WRITE_WIDTH1 = 18; // FIFO data write width, FIFO 1
  parameter DATA_READ_WIDTH1 = 18; // FIFO data read width, FIFO 1
  parameter FIFO1_TYPE = "SYNCHRONOUS"; // Synchronous or Asynchronous data transfer, FIFO 1 (SYNCHRONOUS/ASYNCHRONOUS)
  parameter [10:0] PROG_EMPTY_THRESH1 = 11'h004; // 11-bit Programmable empty depth, FIFO 1
  parameter [10:0] PROG_FULL_THRESH1 = 11'h004; // 11-bit Programmable full depth, FIFO 1
  
  localparam DATA_WIDTH1 = DATA_WRITE_WIDTH1;
  localparam  fifo_depth1 = (DATA_WIDTH1 <= 9) ? 2048 : 1024;

	// Testbench Variables
	parameter R_CLOCK_PERIOD = 20;
	parameter W_CLOCK_PERIOD = 20;
	// parameter DATA_WIDTH1 = 36;
  localparam DEPTH1 = (DATA_WIDTH1 <= 9) ? 2048 :  1024;

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

  parameter DATA_WRITE_WIDTH2 = 9; // FIFO data write width, FIFO 1
  parameter DATA_READ_WIDTH2 = 9; // FIFO data read width, FIFO 1
  parameter FIFO2_TYPE = "SYNCHRONOUS"; // Synchronous or Asynchronous data transfer, FIFO 1 (SYNCHRONOUS/ASYNCHRONOUS)
  parameter [10:0] PROG_EMPTY_THRESH2 = 11'h004; // 11-bit Programmable empty depth, FIFO 1
  parameter [10:0] PROG_FULL_THRESH2 = 11'h7fa; // 11-bit Programmable full depth, FIFO 1

  localparam DATA_WIDTH2 = DATA_WRITE_WIDTH2;
  localparam  fifo_depth2 = (DATA_WIDTH2 <= 9) ? 2048 : 1024;
  localparam DEPTH2 = (DATA_WIDTH2 <= 9) ? 2048 :  1024;

  // predictor output
  reg [DATA_WIDTH2-1:0] exp_dout2;
  reg [DATA_WIDTH2-1:0] local_queue2 [$];

	//clock//
	initial begin
		WR_CLK1 = 1'b0;
		forever #20 WR_CLK1 = ~WR_CLK1;
end

// initial begin
// 	RD_CLK1 = 1'b0;
// 	forever #15 RD_CLK1 = ~RD_CLK1;
// end

	initial begin
			RD_CLK1 = 1'b0;
			forever #20 RD_CLK1 = ~RD_CLK1;
	end

  //clock//
  initial begin
    WR_CLK2 = 1'b0;
    forever #20 WR_CLK2 = ~WR_CLK2;
  end

  // initial begin
  // 	RD_CLK2 = 1'b0;
  // 	forever #15 RD_CLK2 = ~RD_CLK2;
  // end

  initial begin
      RD_CLK2 = 1'b0;
      forever #20 RD_CLK2 = ~RD_CLK2;
  end

  FIFO18KX2 #(
  .DATA_WRITE_WIDTH1(DATA_WRITE_WIDTH1), // FIFO data write width, FIFO 1
  .DATA_READ_WIDTH1(DATA_READ_WIDTH1), // FIFO data read width, FIFO 1
  .FIFO_TYPE1(FIFO1_TYPE), // Synchronous or Asynchronous data transfer, FIFO 1 (SYNCHRONOUS/ASYNCHRONOUS)
  .PROG_EMPTY_THRESH1(PROG_EMPTY_THRESH1), // 11-bit Programmable empty depth, FIFO 1
  .PROG_FULL_THRESH1(PROG_FULL_THRESH1), // 11-bit Programmable full depth, FIFO 1
  .DATA_WRITE_WIDTH2(DATA_WRITE_WIDTH2), // FIFO data write width, FIFO 2 (1-18)
  .DATA_READ_WIDTH2(DATA_READ_WIDTH2), // FIFO data read width, FIFO 2 (1-18)
  .FIFO_TYPE2(FIFO2_TYPE), // Synchronous or Asynchronous data transfer, FIFO 2 (SYNCHRONOUS/ASYNCHRONOUS)
  .PROG_EMPTY_THRESH2(PROG_EMPTY_THRESH2), // 11-bit Programmable empty depth, FIFO 2
  .PROG_FULL_THRESH2(PROG_FULL_THRESH2) // 11-bit Programmable full depth, FIFO 2
) fifo18k_inst(
  .RESET1(RESET1), // Asynchrnous FIFO reset, FIFO 1
  .WR_CLK1(WR_CLK1), // Write clock, FIFO 1
  // .RD_CLK1(RD_CLK1), // Read clock, FIFO 1
  .RD_CLK1(1'h0), // Read clock, FIFO 1
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
        check_flags_fifo1();
      end
      begin
        $display("PROG_EMPTY_THRESH2 = %d", PROG_EMPTY_THRESH2);
		    $display("PROG_FULL_THRESH2 = %d", PROG_FULL_THRESH2);
        $display("--------------------------------------------");
        $display("check_flags_FIFO2");
        $display("--------------------------------------------");
        check_flags_fifo2();
      end
    join

    test_status(error);
    #100;
    $finish();

  end

	initial begin
		$dumpfile("wave.vcd");
		$dumpvars;
	end

	task check_flags_fifo1();
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
		$display("RD_DATA1 mismatch. DUT_Out: %0d, Expected_Out: %0d, Time: %0t", RD_DATA1, exp_dout,$time);
		error = error+1;
	end
	else if(debug)
		$display("RD_DATA1 match. DUT_Out: %0d, Expected_Out: %0d, Time: %0t", RD_DATA1, exp_dout,$time);
endtask

  // FIFO2

  task check_flags_fifo2();
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
      $display("RD_DATA2 mismatch. DUT_Out: %0d, Expected_Out: %0d, Time: %0t", RD_DATA, exp_dout,$time);
      error = error+1;
    end
    else if(debug)
      $display("RD_DATA2 match. DUT_Out: %0d, Expected_Out: %0d, Time: %0t", RD_DATA, exp_dout,$time);
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
					$display("                 Test Passed                  ");
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
					$display("                 Test Failed                  ");
					$display("----------------------------------------------");
				end
		end
endtask

endmodule