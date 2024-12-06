`timescale 1ps/10fs

`ifndef CLK_IN_PERIOD
    `define CLK_IN_PERIOD 25ns // (313-62500ps)
`endif
`ifndef PARAM_DEV_FAMILY
    `define PARAM_DEV_FAMILY "VIRGO" // Device Family
`endif
`ifndef PARAM_DIVIDE_CLK_IN_BY_2
    `define PARAM_DIVIDE_CLK_IN_BY_2 "FALSE" // Enable input divider(TRUE/FALSE)
`endif
`ifndef PARAM_PLL_MULT 
    `define PARAM_PLL_MULT  16 // VCO clock multiplier value (16-640)
`endif
`ifndef PARAM_PLL_DIV
    `define PARAM_PLL_DIV   1 // VCO clock divider value (1-63)
`endif
`ifndef PARAM_PLL_MULT_FRAC
    `define PARAM_PLL_MULT_FRAC 0   // Fraction mode not supported
`endif
`ifndef PARAM_PLL_POST_DIV
    `define PARAM_PLL_POST_DIV 8'h12 // VCO clock post-divider value in Hexadecimal (11,12,13,14,15,16,17,22,23,24,25,26,27,33,34,35,36,37,44,45,46,47,55,56,57,66,67,77)	                                                
`endif

module PLL_tb();

    //signal declaration
	logic PLL_EN       ;// PLL Enable
	logic CLK_IN       ; // Clock input
	logic CLK_OUT      ; // Output clock, frequency is (CLK_IN/PLL_DIV)*(PLL_MULT/(PLL_POST_DIV0*PLL_POST_DIV1))
	logic CLK_OUT_DIV2 ; // CLK_OUT divided by 2 output
	logic CLK_OUT_DIV3 ; // CLK_OUT divided by 3 output
	logic CLK_OUT_DIV4 ; // CLK_OUT divided by 4 output
	logic FAST_CLK     ; // VCO clock output, frequency is (CLK_IN/PLL_DIV)*(PLL_MULT)
	logic LOCK         ; // PLL lock signal

    localparam       DEV_FAMILY         = `PARAM_DEV_FAMILY; 
	localparam       DIVIDE_CLK_IN_BY_2 = `PARAM_DIVIDE_CLK_IN_BY_2; 
	localparam       PLL_MULT           = `PARAM_PLL_MULT     ; 
	localparam       PLL_DIV            = `PARAM_PLL_DIV      ; 
	localparam       PLL_MULT_FRAC      = `PARAM_PLL_MULT_FRAC      ;
	localparam [7:0] PLL_POST_DIV       = `PARAM_PLL_POST_DIV     ; 

    //task related sigs
    real actual_clk_in_f,actual_Fout, actual_Fout2, actual_Fout3, actual_Fout4, actual_Fout_fast;
    real CLK_DIV;
    int error=0;

    //PLL instantiation
    PLL #(DEV_FAMILY, DIVIDE_CLK_IN_BY_2, PLL_MULT, PLL_DIV, PLL_MULT_FRAC,PLL_POST_DIV) dut(
            .PLL_EN(PLL_EN),
            .CLK_IN(CLK_IN),
            .CLK_OUT(CLK_OUT),
            .CLK_OUT_DIV2(CLK_OUT_DIV2),
            .CLK_OUT_DIV3(CLK_OUT_DIV3),
            .CLK_OUT_DIV4(CLK_OUT_DIV4),
            .FAST_CLK(FAST_CLK),
            .LOCK(LOCK)
    );

    always #(`CLK_IN_PERIOD/2)  CLK_IN = ! CLK_IN ;
    
    initial begin       
        CLK_IN = 1'b0;
        PLL_EN = 0;
        CLK_DIV= (DIVIDE_CLK_IN_BY_2 == "TRUE")?2:1;
        #5000;
        PLL_EN = 1;
        //wait for PLL lock
        @(posedge LOCK);
        @(posedge CLK_OUT);
        $display("Getting clock frequencies");
        monitor_clocks();
        $display("Checking clock frequencies");
        frequency_checker();
        repeat(300)@(posedge CLK_OUT_DIV4);
        if(error==0)
          $display("CLK DIV TESTS STATUS: PASSED");
        else 
          $display("CLK DIV TESTS STATUS: FAILED");
        $finish;
    end

    //comapare frequencies
    task compare_freq(real expected,real actual);
        if ($abs(expected-actual) < 0.01) begin
            $display("Frequency Matched.\nExpected:%f MHz, Actual:%f MHz",expected,actual);
        end
        else begin
            $display("Error: Frequency not matched.\nExpected:%f MHz, Actual:%f MHz",expected,actual);
            error++;
        end
    endtask


    task frequency_checker();
        real expected_Fout, expected_Fout2, expected_Fout3, expected_Fout4, expected_Fout_fast;
        real clk_in_f,pll_post_div0,pll_post_div1,pll_post_div;
        //clk_in_freq
        clk_in_f = 1/(`CLK_IN_PERIOD)*(1000000); //in Mhz
        pll_post_div = PLL_POST_DIV;
        pll_post_div1 = PLL_POST_DIV[7:4];
        pll_post_div0 = PLL_POST_DIV[3:0];

        $display("Inputs\nclk_in_f:\t %f\npll_div:%d\npll_mult:%d\npll_post_div:   %d\npll_post_div0:\t %d\npll_post_div1:\t %d\n",clk_in_f,PLL_DIV,PLL_MULT,PLL_POST_DIV, pll_post_div0, pll_post_div1);
        expected_Fout = (clk_in_f/(PLL_DIV*CLK_DIV))*(PLL_MULT/(pll_post_div1*pll_post_div0));
        expected_Fout2 = expected_Fout / 2;
        expected_Fout3 = expected_Fout / 3;
        expected_Fout4 = expected_Fout / 4;
        expected_Fout_fast = (clk_in_f/(PLL_DIV*CLK_DIV))*(PLL_MULT);

        //Comparison
        $display("Comparison for CLK_IN:");
        compare_freq(clk_in_f, actual_clk_in_f);
        $display("Comparison for CLK_OUT:");
        compare_freq(expected_Fout, actual_Fout);
        $display("Comparison for CLK_OUT_DIV2:");
        compare_freq(expected_Fout2, actual_Fout2);
        $display("Comparison for CLK_OUT_DIV3:");
        compare_freq(expected_Fout3, actual_Fout3);
        $display("Comparison for CLK_OUT_DIV4:");
        compare_freq(expected_Fout4, actual_Fout4);
        $display("Comparison for FAST_CLK:");
        compare_freq(expected_Fout_fast, actual_Fout_fast);

    endtask

    task monitor_clocks(); 
        real t0,t1,period;
      
        @(posedge CLK_IN) t0 = $realtime;
        @(posedge CLK_IN) t1 = $realtime;
        period = t1 - t0;
        actual_clk_in_f = (period != 0) ? (1.0 / period) * 1_000_000.0 : 0;

        @(posedge CLK_OUT) t0 = $realtime;
        @(posedge CLK_OUT) t1 = $realtime;
        period = t1 - t0;
        actual_Fout = (period != 0) ? (1.0 / period) * 1_000_000.0 : 0;

        @(posedge CLK_OUT_DIV2) t0 = $realtime;
        @(posedge CLK_OUT_DIV2) t1 = $realtime;
        period = t1 - t0;
        actual_Fout2 = (period != 0) ? (1.0 / period) * 1_000_000.0 : 0;

        @(posedge CLK_OUT_DIV3) t0 = $realtime;
        @(posedge CLK_OUT_DIV3) t1 = $realtime;
        period = t1 - t0;
        actual_Fout3 = (period != 0) ? (1.0 / period) * 1_000_000.0 : 0;

        @(posedge CLK_OUT_DIV4) t0 = $realtime;
        @(posedge CLK_OUT_DIV4) t1 = $realtime;
        period = t1 - t0;
        actual_Fout4 = (period != 0) ? (1.0 / period) * 1_000_000.0 : 0;

        @(posedge FAST_CLK) t0 = $realtime;
        @(posedge FAST_CLK) t1 = $realtime;
        period = t1 - t0;
        actual_Fout_fast = (period != 0) ? (1.0 / period) * 1_000_000.0 : 0;

    endtask

    initial begin
        $dumpfile("waveform.fst"); // Specify the name of the dump file
        $dumpvars(0, PLL_tb);      // Dump all variables in the testbench
    end

endmodule

