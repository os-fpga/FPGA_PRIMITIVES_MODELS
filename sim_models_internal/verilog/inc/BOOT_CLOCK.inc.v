localparam HALF_PERIOD = PERIOD/2.0;

			   
  always
    #HALF_PERIOD O <= ~O;
