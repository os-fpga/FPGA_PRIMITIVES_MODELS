
module I_FAB_tb;

  // Parameters

  //Ports
  reg  I;
  wire  O;
  int error;

  I_FAB  I_FAB_inst (
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
        $display("I_FAB TEST PASSED");
    else
        $error("I_FAB TEST FAILED");
            
  end
  initial 
  begin
      $dumpfile("waves.vcd");
      $dumpvars;
  end

endmodule