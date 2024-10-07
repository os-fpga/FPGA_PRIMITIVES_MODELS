
module DLY_VALUE_MUX_tb;

  // Parameters

  //Ports
  reg [5:0] DLY_TAP0_VAL;
  reg [5:0] DLY_TAP1_VAL;
  reg [5:0] DLY_TAP2_VAL;
  reg [5:0] DLY_TAP3_VAL;
  reg [5:0] DLY_TAP4_VAL;
  reg [5:0] DLY_TAP5_VAL;
  reg [5:0] DLY_TAP6_VAL;
  reg [5:0] DLY_TAP7_VAL;
  reg [5:0] DLY_TAP8_VAL;
  reg [5:0] DLY_TAP9_VAL;
  reg [5:0] DLY_TAP10_VAL;
  reg [5:0] DLY_TAP11_VAL;
  reg [5:0] DLY_TAP12_VAL;
  reg [5:0] DLY_TAP13_VAL;
  reg [5:0] DLY_TAP14_VAL;
  reg [5:0] DLY_TAP15_VAL;
  reg [5:0] DLY_TAP16_VAL;
  reg [5:0] DLY_TAP17_VAL;
  reg [5:0] DLY_TAP18_VAL;
  reg [5:0] DLY_TAP19_VAL;
  reg [4:0] DLY_ADDR;
  wire [5:0] DLY_TAP_VALUE;
  integer error=0;

  DLY_VALUE_MUX  DLY_VALUE_MUX_inst (
    .DLY_TAP0_VAL(DLY_TAP0_VAL),
    .DLY_TAP1_VAL(DLY_TAP1_VAL),
    .DLY_TAP2_VAL(DLY_TAP2_VAL),
    .DLY_TAP3_VAL(DLY_TAP3_VAL),
    .DLY_TAP4_VAL(DLY_TAP4_VAL),
    .DLY_TAP5_VAL(DLY_TAP5_VAL),
    .DLY_TAP6_VAL(DLY_TAP6_VAL),
    .DLY_TAP7_VAL(DLY_TAP7_VAL),
    .DLY_TAP8_VAL(DLY_TAP8_VAL),
    .DLY_TAP9_VAL(DLY_TAP9_VAL),
    .DLY_TAP10_VAL(DLY_TAP10_VAL),
    .DLY_TAP11_VAL(DLY_TAP11_VAL),
    .DLY_TAP12_VAL(DLY_TAP12_VAL),
    .DLY_TAP13_VAL(DLY_TAP13_VAL),
    .DLY_TAP14_VAL(DLY_TAP14_VAL),
    .DLY_TAP15_VAL(DLY_TAP15_VAL),
    .DLY_TAP16_VAL(DLY_TAP16_VAL),
    .DLY_TAP17_VAL(DLY_TAP17_VAL),
    .DLY_TAP18_VAL(DLY_TAP18_VAL),
    .DLY_TAP19_VAL(DLY_TAP19_VAL),
    .DLY_ADDR(DLY_ADDR),
    .DLY_TAP_VALUE(DLY_TAP_VALUE)
  );


  initial 
  begin
      DLY_ADDR=0;
      DLY_TAP0_VAL   =  $urandom;
      DLY_TAP1_VAL   =  $urandom;
      DLY_TAP2_VAL   =  $urandom;
      DLY_TAP3_VAL   =  $urandom;
      DLY_TAP4_VAL   =  $urandom;
      DLY_TAP5_VAL   =  $urandom;
      DLY_TAP6_VAL   =  $urandom;
      DLY_TAP7_VAL   =  $urandom;
      DLY_TAP8_VAL   =  $urandom;
      DLY_TAP9_VAL   =  $urandom;
      DLY_TAP10_VAL  =  $urandom;
      DLY_TAP11_VAL  =  $urandom;
      DLY_TAP12_VAL  =  $urandom;
      DLY_TAP13_VAL  =  $urandom;
      DLY_TAP14_VAL  =  $urandom;
      DLY_TAP15_VAL  =  $urandom;
      DLY_TAP16_VAL  =  $urandom;
      DLY_TAP17_VAL  =  $urandom;
      DLY_TAP18_VAL  =  $urandom;
      DLY_TAP19_VAL  =  $urandom;
      #5;
      repeat(100)
      begin
          DLY_ADDR = $urandom;
          #10;
          if(DLY_ADDR===0)
			    begin
            if(DLY_TAP_VALUE!==DLY_TAP0_VAL)
              error++;
			    end
        
			    if(DLY_ADDR===1)
			    begin
            if(DLY_TAP_VALUE!==DLY_TAP1_VAL)
              error++;
			    end
        
			    if(DLY_ADDR===2)
			    begin
            if(DLY_TAP_VALUE!==DLY_TAP2_VAL)
              error++;
			    end
			    if(DLY_ADDR===3)
			    begin
            if(DLY_TAP_VALUE!==DLY_TAP3_VAL)
              error++;
			    end
			    if(DLY_ADDR===4)
			    begin
            if(DLY_TAP_VALUE!==DLY_TAP4_VAL)
              error++;
			    end
			    if(DLY_ADDR===5)
			    begin
            if(DLY_TAP_VALUE!==DLY_TAP5_VAL)
              error++;
			    end
			    if(DLY_ADDR===6)
			    begin
            if(DLY_TAP_VALUE!==DLY_TAP6_VAL)
              error++;
			    end
			    if(DLY_ADDR===7)
			    begin
            if(DLY_TAP_VALUE!==DLY_TAP7_VAL)
              error++;
			    end
			    if(DLY_ADDR===8)
			    begin
            if(DLY_TAP_VALUE!==DLY_TAP8_VAL)
              error++;
			    end
			    if(DLY_ADDR===9)
			    begin
            if(DLY_TAP_VALUE!==DLY_TAP9_VAL)
              error++;
			    end
			    if(DLY_ADDR===10)
			    begin
            if(DLY_TAP_VALUE!==DLY_TAP10_VAL)
              error++;
			    end
			    if(DLY_ADDR===11)
			    begin
            if(DLY_TAP_VALUE!==DLY_TAP11_VAL)
              error++;
			    end
			    if(DLY_ADDR===12)
			    begin
            if(DLY_TAP_VALUE!==DLY_TAP12_VAL)
              error++;
			    end
			    if(DLY_ADDR===13)
			    begin
            if(DLY_TAP_VALUE!==DLY_TAP13_VAL)
              error++;
			    end
			    if(DLY_ADDR===14)
			    begin
            if(DLY_TAP_VALUE!==DLY_TAP14_VAL)
              error++;
			    end
			    if(DLY_ADDR===15)
			    begin
            if(DLY_TAP_VALUE!==DLY_TAP15_VAL)
              error++;
			    end
			    if(DLY_ADDR===16)
			    begin
            if(DLY_TAP_VALUE!==DLY_TAP16_VAL)
              error++;
			    end
			    if(DLY_ADDR===17)
			    begin
            if(DLY_TAP_VALUE!==DLY_TAP17_VAL)
              error++;
			    end
			    if(DLY_ADDR===18)
			    begin
            if(DLY_TAP_VALUE!==DLY_TAP18_VAL)
              error++;
			    end
			    if(DLY_ADDR===19)
			    begin
            if(DLY_TAP_VALUE!==DLY_TAP19_VAL)
              error++;
			    end
          if(DLY_ADDR>20)
          begin
            if(DLY_TAP_VALUE!==5'd0)
              error++;
          end
    
          #100;
      end
      if(error===0)
			  $display("Test Passed");
		  else
			  $display("Test Failed");
      #1000;
      $finish;    
  end
  initial 
  begin
      $dumpfile("waves.vcd");
      $dumpvars;
  end

endmodule
