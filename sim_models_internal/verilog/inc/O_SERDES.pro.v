

module SyncFIFO #(
	parameter DEPTH = 4,
    parameter DATA_WIDTH = 5
	)(
	input wire clk,    // core clock   
	input wire reset,     
	input wire wr_en,
	input wire rd_en,
	input wire [DATA_WIDTH-1:0] wr_data,
	output wire [DATA_WIDTH-1:0] rd_data,
	output wire empty,    
	output wire full,
	output wire almost_full      
	);

    reg [DATA_WIDTH-1:0] fifo [DEPTH-1:0];
    reg [DATA_WIDTH-1:0] rd_data_reg;
    reg [$clog2(DEPTH)-1:0] wr_ptr, rd_ptr;

    assign empty = (wr_ptr == rd_ptr);
    assign full = ((wr_ptr == rd_ptr - 1) || (wr_ptr == DEPTH - 1 && rd_ptr == 0));
	assign almost_full = !empty; //(wr_ptr >= (DEPTH - 4));
	
	always @(posedge clk or negedge reset)
	begin
		if(!reset)
		begin
			rd_data_reg <= 0;
			wr_ptr 		<= 0;
			rd_ptr 		<= 0;
			for (int i = 0; i< DEPTH; i++)
				fifo[i] <= '0;
		end
		else 
		begin
			if(wr_en && !full)
			begin
                fifo[wr_ptr] <= wr_data;
                wr_ptr <= wr_ptr + 1;
            end
            if(rd_en && !empty)
			begin
                rd_data_reg <= fifo[rd_ptr];
                rd_ptr <= rd_ptr + 1;
            end
		end
    end
	
    assign rd_data = rd_data_reg;

endmodule

