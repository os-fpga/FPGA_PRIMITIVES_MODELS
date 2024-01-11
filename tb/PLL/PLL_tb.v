`timescale 1ps/1ps

module PLL_tb;

// Parameters
localparam  DIVIDE_CLK_IN_BY_2 = "TRUE";
localparam  PLL_MULT = 80;
localparam  PLL_DIV = 2;
localparam  PLL_POST_DIV = 2;

real        CLK_PERIOD = 25000;   // 25000ps =25ns = 40MHz

//Ports
reg   PLL_EN;
reg   CLK_IN;
wire  CLK_OUT;
wire  CLK_OUT_DIV2;
wire  CLK_OUT_DIV3;
wire  CLK_OUT_DIV4;
wire  SERDES_FAST_CLK;
wire  LOCK;

real  clk_out_start;
real  clk_out_period;
real  clk_out_period1;
real  expected_period;
real  CLK_DIV;

int error=0;

int clk_out_count2=0;
int clk_out_count3=0;
int clk_out_count4=0;
int clk2_count=0;
int clk3_count=0;
int clk4_count=0;


PLL # (
  .DIVIDE_CLK_IN_BY_2(DIVIDE_CLK_IN_BY_2),
  .PLL_MULT(PLL_MULT),
  .PLL_DIV(PLL_DIV),
  .PLL_POST_DIV(PLL_POST_DIV)
)
PLL_inst (
  .PLL_EN(PLL_EN),
  .CLK_IN(CLK_IN),
  .CLK_OUT(CLK_OUT),
  .CLK_OUT_DIV2(CLK_OUT_DIV2),
  .CLK_OUT_DIV3(CLK_OUT_DIV3),
  .CLK_OUT_DIV4(CLK_OUT_DIV4),
  .SERDES_FAST_CLK(SERDES_FAST_CLK),
  .LOCK(LOCK)
);

always #(CLK_PERIOD/2)  CLK_IN = ! CLK_IN ;

initial 
begin 
	PLL_EN = 0;
	CLK_IN=0;
  CLK_DIV= (DIVIDE_CLK_IN_BY_2 == "TRUE")?2:1;
	#100000;
	PLL_EN = 1;
  @(posedge LOCK);
  @(posedge CLK_OUT)
  clk_out_start=$realtime();
  @(posedge CLK_OUT)
  clk_out_period=$realtime()-clk_out_start;
  expected_period=(CLK_PERIOD*PLL_DIV*PLL_POST_DIV*CLK_DIV)/PLL_MULT;

  #1;
  // passing is if less than 10ps difference in period
  if( $abs(clk_out_period-expected_period) < 10)
    $display("CLOCK OUT Test Passed [less than 10ps difference] (actual / expected): %0d ps / %0d ps", clk_out_period, expected_period);
  else begin
    $display("CLOCK OUT Test Failed [more than 10ps difference] (actual / expected): %0d ps / %0d ps", clk_out_period, expected_period);
    end 

  fork
    // CLOCK OUT DIV2 TEST
    begin
      @(posedge CLK_OUT_DIV2);
      forever 
      begin
        @(posedge CLK_OUT_DIV2);
        clk2_count++;
        if(clk_out_count2!==2*clk2_count)
          error++;
      end
    end

    begin
      @(posedge CLK_OUT_DIV2);
      forever
      begin
        @(posedge CLK_OUT);
        clk_out_count2++;
      end
    end
    // CLOCK OUT DIV3 TEST
    begin
      @(posedge CLK_OUT_DIV3);
      forever 
      begin
        @(posedge CLK_OUT_DIV3);
        clk3_count++;
        
        if(clk_out_count3!==3*clk3_count)
          error++;
      end
    end

    begin
      @(posedge CLK_OUT_DIV3);
      forever
      begin
        @(posedge CLK_OUT);
        clk_out_count3++;
      end
      end
    // CLOCK OUT DIV4 TEST
    begin
      @(posedge CLK_OUT_DIV4);
      forever 
      begin
        @(posedge CLK_OUT_DIV4);
        clk4_count++;
        if(clk_out_count4!==4*clk4_count)
          error++;
      end
    end

    begin
      @(posedge CLK_OUT_DIV4);
      forever
      begin
        @(posedge CLK_OUT);
        clk_out_count4++;
      end
    end
  
  join
  
end

initial 
begin
	$dumpfile("waves.vcd");
	$dumpvars;

  repeat(500)@(posedge CLK_OUT_DIV4);
  if(error===0)
    $display("CLK DIV Test Passed");
  else 
    $display("CLK DIV Test Failed");

  $finish;
end

endmodule

