
  time period = 0.0;  // This is the calculated period for OUTPUT_CLOCK after PLL_LOCK
  localparam  ddr_multiplier   = (DATA_RATE == "DDR") ? 2.0 : 1.0; // If operating in DDR, must multiply period by 2
  localparam  phase_multiplier = (CLOCK_PHASE == 90) ? 0.25 :      // Phase offset
                                 (CLOCK_PHASE == 180) ? 0.5 :
                                 (CLOCK_PHASE == 270) ? 0.75 :
                                 0;
  
  reg clock_enabled = 1'b0; // Enables clock 256 cycles after LOCK

  always begin
    if (!clock_enabled && PLL_LOCK) begin
      @(posedge PLL_CLK);
      period = $realtime;
      @(posedge PLL_CLK);
      period = ($realtime - period);
      period = period*ddr_multiplier*2.0; // Calculated period for output clock
      clock_enabled = 1'b1;
      repeat(254)
        @(posedge PLL_CLK);  //  Wait 256 PLL_CLKs after lock to enable clock
      #(period*phase_multiplier);
    end else if (!PLL_LOCK) begin
      clock_enabled = 1'b0;
      @(posedge PLL_LOCK);
    end else
      if (CLK_EN) begin
        #(period/2.0) OUTPUT_CLK = ~OUTPUT_CLK;
      end else begin
        OUTPUT_CLK = 1'b0;
        @(posedge CLK_EN);
      end
  end
