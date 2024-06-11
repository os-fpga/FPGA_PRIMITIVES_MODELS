
module FCLK_BUF_tb;

  //Ports
  reg  I;
  wire  O;
  int error;

  FCLK_BUF  FCLK_BUF_inst (
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
        $display("Test Passed");
    else
        $error("Test Failed");
            
  end
  initial 
  begin
      $dumpfile("waves.vcd");
      $dumpvars;
  end
  
endmodule