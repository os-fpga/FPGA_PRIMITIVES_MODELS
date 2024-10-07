
module DLY_SEL_DECODER_tb;

  // Parameters

  //Ports
  reg DLY_LOAD;
  reg DLY_ADJ;
  reg DLY_INCDEC;
  reg [4:0] DLY_ADDR;
  wire [2:0] DLY0_CNTRL;
  wire [2:0] DLY1_CNTRL;
  wire [2:0] DLY2_CNTRL;
  wire [2:0] DLY3_CNTRL;
  wire [2:0] DLY4_CNTRL;
  wire [2:0] DLY5_CNTRL;
  wire [2:0] DLY6_CNTRL;
  wire [2:0] DLY7_CNTRL;
  wire [2:0] DLY8_CNTRL;
  wire [2:0] DLY9_CNTRL;
  wire [2:0] DLY10_CNTRL;
  wire [2:0] DLY11_CNTRL;
  wire [2:0] DLY12_CNTRL;
  wire [2:0] DLY13_CNTRL;
  wire [2:0] DLY14_CNTRL;
  wire [2:0] DLY15_CNTRL;
  wire [2:0] DLY16_CNTRL;
  wire [2:0] DLY17_CNTRL;
  wire [2:0] DLY18_CNTRL;
  wire [2:0] DLY19_CNTRL;

	integer error=0;

  DLY_SEL_DECODER  DLY_SEL_DECODER_inst (
    .DLY_LOAD(DLY_LOAD),
    .DLY_ADJ(DLY_ADJ),
    .DLY_INCDEC(DLY_INCDEC),
    .DLY_ADDR(DLY_ADDR),
    .DLY0_CNTRL(DLY0_CNTRL),
    .DLY1_CNTRL(DLY1_CNTRL),
    .DLY2_CNTRL(DLY2_CNTRL),
    .DLY3_CNTRL(DLY3_CNTRL),
    .DLY4_CNTRL(DLY4_CNTRL),
    .DLY5_CNTRL(DLY5_CNTRL),
    .DLY6_CNTRL(DLY6_CNTRL),
    .DLY7_CNTRL(DLY7_CNTRL),
    .DLY8_CNTRL(DLY8_CNTRL),
    .DLY9_CNTRL(DLY9_CNTRL),
    .DLY10_CNTRL(DLY10_CNTRL),
    .DLY11_CNTRL(DLY11_CNTRL),
    .DLY12_CNTRL(DLY12_CNTRL),
    .DLY13_CNTRL(DLY13_CNTRL),
    .DLY14_CNTRL(DLY14_CNTRL),
    .DLY15_CNTRL(DLY15_CNTRL),
    .DLY16_CNTRL(DLY16_CNTRL),
    .DLY17_CNTRL(DLY17_CNTRL),
    .DLY18_CNTRL(DLY18_CNTRL),
    .DLY19_CNTRL(DLY19_CNTRL)
  );



	initial 
	begin
		DLY_LOAD=0;
		DLY_ADJ=0;
		DLY_INCDEC=0;
		DLY_ADDR=0;
		#5;
		repeat(100)
		begin
			DLY_LOAD=$urandom;
			DLY_ADJ=$urandom;
			DLY_INCDEC=$urandom;
			DLY_ADDR=$urandom;
			#10;
			if(DLY_ADDR===0)
			begin
					if(DLY0_CNTRL!=={DLY_LOAD, DLY_ADJ, DLY_INCDEC})
							error++;
			end

			if(DLY_ADDR===1)
			begin
					if(DLY1_CNTRL!=={DLY_LOAD, DLY_ADJ, DLY_INCDEC})
							error++;
			end

			if(DLY_ADDR===2)
			begin
					if(DLY2_CNTRL!=={DLY_LOAD, DLY_ADJ, DLY_INCDEC})
							error++;
			end
			if(DLY_ADDR===3)
			begin
					if(DLY3_CNTRL!=={DLY_LOAD, DLY_ADJ, DLY_INCDEC})
							error++;
			end
			if(DLY_ADDR===4)
			begin
					if(DLY4_CNTRL!=={DLY_LOAD, DLY_ADJ, DLY_INCDEC})
							error++;
			end
			if(DLY_ADDR===5)
			begin
					if(DLY5_CNTRL!=={DLY_LOAD, DLY_ADJ, DLY_INCDEC})
							error++;
			end
			if(DLY_ADDR===6)
			begin
					if(DLY6_CNTRL!=={DLY_LOAD, DLY_ADJ, DLY_INCDEC})
							error++;
			end
			if(DLY_ADDR===7)
			begin
					if(DLY7_CNTRL!=={DLY_LOAD, DLY_ADJ, DLY_INCDEC})
							error++;
			end
			if(DLY_ADDR===8)
			begin
					if(DLY8_CNTRL!=={DLY_LOAD, DLY_ADJ, DLY_INCDEC})
							error++;
			end
			if(DLY_ADDR===9)
			begin
					if(DLY9_CNTRL!=={DLY_LOAD, DLY_ADJ, DLY_INCDEC})
							error++;
			end
			if(DLY_ADDR===10)
			begin
					if(DLY10_CNTRL!=={DLY_LOAD, DLY_ADJ, DLY_INCDEC})
							error++;
			end
			if(DLY_ADDR===11)
			begin
					if(DLY11_CNTRL!=={DLY_LOAD, DLY_ADJ, DLY_INCDEC})
							error++;
			end
			if(DLY_ADDR===12)
			begin
					if(DLY12_CNTRL!=={DLY_LOAD, DLY_ADJ, DLY_INCDEC})
							error++;
			end
			if(DLY_ADDR===13)
			begin
					if(DLY13_CNTRL!=={DLY_LOAD, DLY_ADJ, DLY_INCDEC})
							error++;
			end
			if(DLY_ADDR===14)
			begin
					if(DLY14_CNTRL!=={DLY_LOAD, DLY_ADJ, DLY_INCDEC})
							error++;
			end
			if(DLY_ADDR===15)
			begin
					if(DLY15_CNTRL!=={DLY_LOAD, DLY_ADJ, DLY_INCDEC})
							error++;
			end
			if(DLY_ADDR===16)
			begin
					if(DLY16_CNTRL!=={DLY_LOAD, DLY_ADJ, DLY_INCDEC})
							error++;
			end
			if(DLY_ADDR===17)
			begin
					if(DLY17_CNTRL!=={DLY_LOAD, DLY_ADJ, DLY_INCDEC})
							error++;
			end
			if(DLY_ADDR===18)
			begin
					if(DLY18_CNTRL!=={DLY_LOAD, DLY_ADJ, DLY_INCDEC})
							error++;
			end
			if(DLY_ADDR===19)
			begin
					if(DLY19_CNTRL!=={DLY_LOAD, DLY_ADJ, DLY_INCDEC})
							error++;
			end
		
			#100;
		end
		if(error===0)
			$display("Test Passed");
		else
			$display("Test Failed");
		#1000;
		$finish;    
	end
	initial 
	begin
    $dumpfile("waves.vcd");
    $dumpvars;
	end
endmodule