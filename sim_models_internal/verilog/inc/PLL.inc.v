
time measured_fref_per;                   // time period of input clk FREF
logic pre_div_out;				// output clk of the pre divider circuit 
logic mes_done;               		// check signal when time period is calcuated it is set to high
realtime half_cycle_prediv;                           // time period of the initial clock  
logic post_vco_out;  // clock which s at the output of the vco
realtime half_cycle_vco;                   // time period to be set of the post vco clock 
logic fc0, fc1,fc2,fc3;
realtime half_cycle_fout0,half_cycle_fout1,half_cycle_fout2,half_cycle_fout3;   
int counter=0;
logic DELAY_LOCK =1'b0;//

clk_gen pre_div_clk (
  .clk(pre_div_out)
);    		// start generating the clock at any frequency

measure i_m1 (
  .signal(CLK_IN), 
  .period(measured_fref_per), 
  .measured(mes_done)
  );     // measure the time period of the initial clock FREF
                      
always@(posedge CLK_IN) begin
  if (mes_done && (DIVIDE_CLK_IN_BY_2=="TRUE"))
  begin
      half_cycle_prediv = (measured_fref_per*PLL_DIV);    // The time period of the pre divider clock will be initial will be the time period of CLK_IN* DIV_CLK_IN 
      if(half_cycle_prediv != 0)
        pre_div_clk.set_half_cycle(half_cycle_prediv);       // Update the time period of predivider output clock.
  end
  else  if (mes_done && (DIVIDE_CLK_IN_BY_2=="FALSE"))
  begin
      half_cycle_prediv = (measured_fref_per*PLL_DIV)/2;    // The time period of the pre divider clock will be initial will be the time period of CLK_IN* DIV_CLK_IN 
      if(half_cycle_prediv != 0)
        pre_div_clk.set_half_cycle(half_cycle_prediv);       // Update the time period of predivider output clock.
  end
end

//VCO Generation
clk_gen post_vco_clk (
  .clk(post_vco_out)
);   // generate the clock at any frequency

always@(posedge CLK_IN) begin
  if (mes_done)                          // we can generate both the clocks as we have the reference period of the CLK_IN
  begin
    half_cycle_vco =  half_cycle_prediv/PLL_MULT;  // No need to divide by two because we are using already the half cycle
    if(half_cycle_vco != 0)
      post_vco_clk.set_half_cycle(half_cycle_vco);  // reset the time period of the post vco clock
  end
end

post_div #(.div(CLK_OUT0_DIV))
pd0
(
  .fref(CLK_IN), 
  .mes_done(mes_done),
  .rst_n(CLK_OUT0_EN), 
  .vco_time(half_cycle_vco),  
  .fout(CLK_OUT0)
  //.fout_time(half_cycle_fout0) 
  );
post_div #(.div(CLK_OUT1_DIV))
pd1
(
  .fref(CLK_IN), 
  .mes_done(mes_done),
  .rst_n(CLK_OUT1_EN), 
  .vco_time(half_cycle_vco), 
  .fout(CLK_OUT1)
  //.fout_time(half_cycle_fout1)
  );
post_div #(.div(CLK_OUT2_DIV))
pd2
(
  .fref(CLK_IN), 
  .mes_done(mes_done),
  .rst_n(CLK_OUT2_EN),
  .vco_time(half_cycle_vco), 
  .fout(CLK_OUT2)
  //.fout_time(half_cycle_fout2)
  );
post_div #(.div(CLK_OUT3_DIV))
pd3
(
  .fref(CLK_IN), 
  .mes_done(mes_done),
  .rst_n(CLK_OUT3_EN), 
  .vco_time(half_cycle_vco),  
  .fout(CLK_OUT3)
  //.fout_time(half_cycle_fout3) 
  );

// as per specification the lock is guaranted after the 2000 pfd (phase frequency detector) cycles. In the simulation model there is no pfd so a lock is set 
// as we will get the output from the pre divider
always @(posedge CLK_IN)
begin
    counter = counter + 1;
    if (counter == PLL_DIV)
        assign DELAY_LOCK = 1'b1;
end

assign LOCK = ~PLL_EN ? 1'b0 : DELAY_LOCK;
assign SERDES_FAST_CLK = post_vco_out;

