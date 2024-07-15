
module O_FAB_tb;

  // Parameters

  //Ports
  reg  I;
  wire  O;
  int error;

  O_FAB  O_FAB_inst (
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
        $display("O_FAB Test Passed");
    else
        $error("O_FAB Test Failed");
            
  end
  initial 
  begin
      $dumpfile("O_FAB.vcd");
      $dumpvars;
  end

endmodule