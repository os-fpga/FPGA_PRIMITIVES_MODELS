
module DLY_VALUE_MUX_tb;

  // Parameters

  //Ports
  reg [5:0] DLY_TAP_VAL_ARRAY[19:0];
  reg [4:0] DLY_ADDR;
  wire [5:0] DLY_TAP_VALUE;

  DLY_VALUE_MUX  DLY_VALUE_MUX_inst (
    .DLY_TAP_VAL_ARRAY(DLY_TAP_VAL_ARRAY),
    .DLY_ADDR(DLY_ADDR),
    .DLY_TAP_VALUE(DLY_TAP_VALUE)
  );


  initial 
  begin
      DLY_ADDR=0;
      for(integer i=0;i<20;i=i+1)
        DLY_TAP_VAL_ARRAY[i]=5'd0;
      #5;
      for(integer i=0;i<20;i=i+1)
        DLY_TAP_VAL_ARRAY[i]=$urandom;
     
    //   #1;
    //   for(integer i=0;i<20;i=i+1)
    //     $display("DLY_TAP_VAL_ARRAY[%0d] = %b", i, DLY_TAP_VAL_ARRAY[i]);
      #5;
      repeat(10)
      begin
          DLY_ADDR=$urandom;

          #10;
          if(DLY_ADDR<20)
          begin
              if(DLY_TAP_VALUE===DLY_TAP_VAL_ARRAY[DLY_ADDR])
                  $display("Test Passed");
              else
                  $display("Test Failed");
          end
          else 
          begin
              if(DLY_TAP_VALUE===5'd0)
                  $display("Test Passed");
              else
                  $display("Test Failed");
          end
          #100;
      end
      #1000;
      $finish;    
  end
  initial 
  begin
      $dumpfile("waves.vcd");
      $dumpvars;
  end
endmodule