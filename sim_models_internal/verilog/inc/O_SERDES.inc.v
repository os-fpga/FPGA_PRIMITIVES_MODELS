

    reg read_en;
	wire afull;
	wire fifo_empty;
	reg fifo_read_en;
	reg word_load_en_sync;
	reg [WIDTH-1:0] data_parallel_reg;
	reg [WIDTH-1:0] data_shift_reg;
	reg oe_parallel_reg;
	reg oe_shift_reg;
	wire fifo_data_oe;
	wire [WIDTH-1:0] fifo_read_data;
  

	// Synchronous FIFO
	SyncFIFO fifo1 (
		.clk(CLK_IN),
		.reset(RST),
		.wr_en(1'b1),
		.rd_en(fifo_read_en),
		.wr_data({OE,D}),
		.rd_data({fifo_data_oe,fifo_read_data}),
		.empty(fifo_empty),
		.full(),
		.almost_full(afull)
		);

	// Generating read enable signal for fifo				
	always @(posedge CLK_IN or negedge RST) 
	begin
		if(!RST)
			read_en <= 0;  
		else
			read_en <= afull;
	end

	// Word load enable signal to load fifo data
	always @(posedge PLL_CLK or negedge RST) 
	begin
		if(!RST)
			fifo_read_en <= 1'b0;
		else if(fifo_empty)
			fifo_read_en <= 1'b0;
		else if (afull)
			fifo_read_en <= 1'b1;
	end

	assign word_load_en_sync = LOAD_WORD && fifo_read_en ;


	// Parallel data register 
	always @(posedge PLL_CLK or negedge RST) 
	begin
		if(!RST)
		begin
			data_parallel_reg <= 'b0;
			oe_parallel_reg   <= 1'b0;
		end
		else if(word_load_en_sync)
		begin
			data_parallel_reg <= fifo_read_data;
			oe_parallel_reg   <= fifo_data_oe;
		end

	end

	// Shift Register
	always @(posedge PLL_CLK or negedge RST)
	begin
		if(!RST)
		begin
			data_shift_reg <= 0;
			oe_shift_reg   <= 0;
		end
		else if(word_load_en_sync)
		begin
			oe_shift_reg   <= oe_parallel_reg;
			data_shift_reg <= data_parallel_reg;
		end
		else
			data_shift_reg <= {data_shift_reg[WIDTH-2: 0],1'b0};
	end

	always @(negedge PLL_CLK)
	begin
		if(DATA_RATE=="DDR")
			data_shift_reg <= {data_shift_reg[WIDTH-2: 0],1'b0};
	end

	assign OE = oe_shift_reg;

	assign Q = data_shift_reg[WIDTH - 1];

