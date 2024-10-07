
module DLY_SEL_DECODER_tb;

  // Parameters

  //Ports
  reg  DLY_LOAD;
  reg  DLY_ADJ;
  reg  DLY_INCDEC;
  reg [4:0] DLY_ADDR;
  wire [2:0] DLY_CNTRL[31:0];

  DLY_SEL_DECODER  DLY_SEL_DECODER_inst (
    .DLY_LOAD(DLY_LOAD),
    .DLY_ADJ(DLY_ADJ),
    .DLY_INCDEC(DLY_INCDEC),
    .DLY_ADDR(DLY_ADDR),
    .DLY_CNTRL(DLY_CNTRL)
  );


initial 
begin
    DLY_LOAD=0;
    DLY_ADJ=0;
    DLY_INCDEC=0;
    DLY_ADDR=0;
    #5;
    repeat(5)
    begin
        DLY_LOAD=$urandom;
        DLY_ADJ=$urandom;
        DLY_INCDEC=$urandom;
        DLY_ADDR=$urandom;
        #10;
        // $display("Bus Array Content:");
        // for (integer i = 0; i < 32; i = i + 1) begin
        //     $display("DLY_CNTRL[%0d] = %b", i, DLY_CNTRL[i]);
        //     #2;
        // end
        if(DLY_ADDR<20)
        begin
            if(DLY_CNTRL[DLY_ADDR]==={DLY_LOAD, DLY_ADJ, DLY_INCDEC})
                $display("Test Passed");
            else
                $display("Test Failed");
        end
        else 
        begin
            if(DLY_CNTRL[DLY_ADDR]===3'b000)
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
