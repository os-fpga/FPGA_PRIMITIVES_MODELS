
module CLK_BUF_tb;

  //Ports
  reg  I;
  wire  O;
  int error;

  CLK_BUF  CLK_BUF_inst (
    .I(I),
    .O(O)
  );

  initial 
  begin
    I = 0;
    error = 0;
    #3;
    I = 1;
    for(int i=0;i<=63;i++)
	begin
        #3;
		I = $urandom;
        #1;
		if(O!==I)
            error++;
	end

    if(error===0)
        $display("CLK BUFF TEST PASSED");
    else
        $error("CLK BUFF TEST FAILED");
            
  end
  initial 
  begin
      $dumpfile("waves.vcd");
      $dumpvars;
  end
endmodule