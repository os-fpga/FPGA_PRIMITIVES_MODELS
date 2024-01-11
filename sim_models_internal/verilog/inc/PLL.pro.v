module post_div #(
  parameter  div = 2
)(
  input fref,
  input mes_done, 
  input rst_n, 
  input realtime vco_time, 
  output logic fout
);
  logic fc;
  clk_gen post_div_clk_gen
  (
    .clk(fc)
  );    // generate the clock at any frequency
  realtime half_cycle_fout;                   // time period to be set of the post vco clock 
  realtime fout_time;
  always@(posedge fref)                 
  begin
    if (mes_done) begin                         // we can generate both the clocks as we have the reference period of the FREF
      half_cycle_fout =  vco_time*div;  // No need to divide by two because we are using already the half cycle
      if(half_cycle_fout != 0)
        post_div_clk_gen.set_half_cycle(half_cycle_fout);  // reset the time period of the post vco clock
    end
  end
  assign fout_time = half_cycle_fout;
  assign fout = rst_n==1'b1 ?  fc:1'b0;
endmodule


interface clk_gen(
  output bit clk
);
  realtime  half_cycle;
  initial begin
    half_cycle = 10;
    clk = 0;
    forever #half_cycle clk = ~clk;
  end
  function void set_half_cycle(input realtime c);
    begin
      if (half_cycle == 0) begin
        $display("Error - can't set clock half_cycle to 0");
      end else begin
        half_cycle = c;
      end
    end
  endfunction
endinterface


module measure (
  input signal,
  output time period,
  output reg measured
);
  reg last_time_valid = 0;
  time last_time;
  always @(posedge signal) begin
    if (last_time_valid) begin
      period = $time - last_time;
      last_time_valid = 0;
      measured <= 1'b1;
    end else begin
      last_time = $time;
      last_time_valid = 1'b1;
      measured <= 1'b0;
    end
  end
endmodule

