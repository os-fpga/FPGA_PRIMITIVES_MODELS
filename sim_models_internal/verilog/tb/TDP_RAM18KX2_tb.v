`timescale 1ns/1ps
// Self-Checking Testbench for TDP_RAM18KX2 simulation model
// Testbench Not modeled for ASymmetric RAM
// So, Keep the Write/Read Width Same for Both Ports

module TDP_RAM18KX2_tb();
	// Ports for 1st 18K RAM
	reg WEN_A1; // Write-enable port A, RAM 1
	reg WEN_B1; // Write-enable port B, RAM 1
	reg REN_A1; // Read-enable port A, RAM 1
	reg REN_B1; // Read-enable port B, RAM 1
	reg CLK_A1; // Clock port A, RAM 1
	reg CLK_B1; // Clock port B, RAM 1
	reg [1:0] BE_A1; // Byte-write enable port A, RAM 1
	reg [1:0] BE_B1; // Byte-write enable port B, RAM 1
	reg [13:0] ADDR_A1; // Address port A, RAM 1
	reg [13:0] ADDR_B1; // Address port B, RAM 1
	reg [WRITE_WIDTH_A1-1:0] WDATA_A1; // Write data port A, RAM 1
	reg [1:0] WPARITY_A1; // Write parity port A, RAM 1
	reg [WRITE_WIDTH_B1-1:0] WDATA_B1; // Write data port B, RAM 1
	reg [1:0] WPARITY_B1; // Write parity port B, RAM 1
	wire [READ_WIDTH_A1-1:0] RDATA_A1; // Read data port A, RAM 1
	wire [1:0] RPARITY_A1; // Read parity port A, RAM 1
	wire [READ_WIDTH_B1-1:0] RDATA_B1; // Read data port B, RAM 1
	wire [1:0] RPARITY_B1; // Read parity port B, RAM 1
	// Ports for 2nd 18K RAM
	reg WEN_A2; // Write-enable port A, RAM 2
	reg WEN_B2; // Write-enable port B, RAM 2
	reg REN_A2; // Read-enable port A, RAM 2
	reg REN_B2; // Read-enable port B, RAM 2
	reg CLK_A2; // Clock port A, RAM 2
	reg CLK_B2; // Clock port B, RAM 2
	reg [1:0] BE_A2; // Byte-write enable port A, RAM 2
	reg [1:0] BE_B2; // Byte-write enable port B, RAM 2
	reg [13:0] ADDR_A2; // Address port A, RAM 2
	reg [13:0] ADDR_B2; // Address port B, RAM 2
	reg [WRITE_WIDTH_A2-1:0] WDATA_A2; // Write data port A, RAM 2
	reg [1:0] WPARITY_A2; // Write parity port A, RAM 2
	reg [WRITE_WIDTH_B2-1:0] WDATA_B2; // Write data port B, RAM 2
	reg [1:0] WPARITY_B2; // Write parity port B, RAM 2
	wire [READ_WIDTH_A2-1:0] RDATA_A2; // Read data port A, RAM 2
	wire [1:0] RPARITY_A2; // Read parity port A, RAM 2
	wire [READ_WIDTH_B2-1:0] RDATA_B2; // Read data port B, RAM 2
	wire [1:0] RPARITY_B2; // Read parity port B, RAM 2

	/* verilator lint_off WIDTHCONCAT */
	/* verilator lint_off WIDTH */
	parameter [16383:0] INIT1 = {16384{1'b0}}; // Initial Contents of memory, RAM 1
	parameter [2047:0] INIT1_PARITY = {2048{1'b0}}; // Initial Contents of memory
	parameter WRITE_WIDTH_A1 = 18; // Write data width on port A, RAM 1 (1-18)
	parameter WRITE_WIDTH_B1 = 18; // Write data width on port B, RAM 1 (1-18)
	parameter READ_WIDTH_A1 = 18; // Read data width on port A, RAM 1 (1-18)
	parameter READ_WIDTH_B1 = 18; // Read data width on port B, RAM 1 (1-18)
	parameter [16383:0] INIT2 = {16384{1'b0}}; // Initial Contents of memory, RAM 2
	parameter [2047:0] INIT2_PARITY = {2048{1'b0}}; // Initial Contents of memory
	parameter WRITE_WIDTH_A2 = 9; // Write data width on port A, RAM 2 (1-18)
	parameter WRITE_WIDTH_B2 = 9; // Write data width on port B, RAM 2 (1-18)
	parameter READ_WIDTH_A2 = 9; // Read data width on port A, RAM 2 (1-18)
	parameter READ_WIDTH_B2 = 9; // Read data width on port B, RAM 2 (1-18)

//Local_RAM1
  localparam A1_DATA_WRITE_WIDTH = calc_data_width(WRITE_WIDTH_A1);
  localparam A1_WRITE_ADDR_WIDTH = calc_depth(A1_DATA_WRITE_WIDTH);
  localparam A1_DATA_READ_WIDTH = calc_data_width(READ_WIDTH_A1);
  localparam A1_READ_ADDR_WIDTH = calc_depth(A1_DATA_READ_WIDTH);
  localparam A1_DATA_WIDTH = (A1_DATA_WRITE_WIDTH > A1_DATA_READ_WIDTH) ? A1_DATA_WRITE_WIDTH : A1_DATA_READ_WIDTH;

localparam A1_PARITY_WRITE_WIDTH = calc_parity_width(WRITE_WIDTH_A1);
  localparam A1_PARITY_READ_WIDTH = calc_parity_width(READ_WIDTH_A1);
  localparam A1_PARITY_WIDTH = (A1_PARITY_WRITE_WIDTH > A1_PARITY_READ_WIDTH) ? A1_PARITY_WRITE_WIDTH : A1_PARITY_READ_WIDTH;

	localparam B1_DATA_WRITE_WIDTH = calc_data_width(WRITE_WIDTH_B1);
  localparam B1_WRITE_ADDR_WIDTH = calc_depth(B1_DATA_WRITE_WIDTH);
  localparam B1_DATA_READ_WIDTH = calc_data_width(READ_WIDTH_B1);
  localparam B1_READ_ADDR_WIDTH = calc_depth(B1_DATA_READ_WIDTH);
  localparam B1_DATA_WIDTH = (B1_DATA_WRITE_WIDTH > B1_DATA_READ_WIDTH) ? B1_DATA_WRITE_WIDTH : B1_DATA_READ_WIDTH;

	localparam B1_PARITY_WRITE_WIDTH = calc_parity_width(WRITE_WIDTH_B1);
  localparam B1_PARITY_READ_WIDTH = calc_parity_width(READ_WIDTH_B1);
  localparam B1_PARITY_WIDTH = (B1_PARITY_WRITE_WIDTH > B1_PARITY_READ_WIDTH) ? B1_PARITY_WRITE_WIDTH : B1_PARITY_READ_WIDTH;

	localparam RAM1_DATA_WIDTH = (A1_DATA_WIDTH > B1_DATA_WIDTH) ? A1_DATA_WIDTH : B1_DATA_WIDTH;
	localparam RAM1_PARITY_WIDTH = (A1_PARITY_WIDTH > B1_PARITY_WIDTH) ? A1_PARITY_WIDTH : B1_PARITY_WIDTH;
	localparam RAM1_ADDR_WIDTH = calc_depth(RAM1_DATA_WIDTH);

	reg [RAM1_DATA_WIDTH-1:0] local_ram1 [2**RAM1_ADDR_WIDTH-1:0];

	reg [RAM1_DATA_WIDTH-1:0] temp_ram1_data_a1;
	reg [RAM1_DATA_WIDTH-1:0] temp_ram1_data_b1;
	reg [1:0] temp_ram1_port;
	reg [RAM1_ADDR_WIDTH-1:0] temp_ram1_addr;

	// Parity Ram
	/* verilator lint_off LITENDIAN */
	reg [RAM1_PARITY_WIDTH-1:0] local_parity_ram1 [2**RAM1_ADDR_WIDTH-1:0];
	/* verilator lint_on LITENDIAN */

	integer f_p, g_p, h_p;
	integer f, g, h, i, j, k, m;

	// Initialize Parity RAM contents
	initial begin
		f_p = 0;
		for (g_p = 0; g_p < 2**RAM1_ADDR_WIDTH; g_p = g_p + 1)
			for (h_p = 0; h_p < RAM1_PARITY_WIDTH; h_p = h_p + 1) begin
				`ifdef SIM_VERILATOR
					local_parity_ram1[g_p][h_p] = INIT1_PARITY[f_p];
				`else
					local_parity_ram1[g_p][h_p] <= INIT1_PARITY[f_p];
				`endif
				f_p = f_p + 1;
			end
	end

	// Initialize Base RAM contents
		initial begin
			f = 0;
			for (g = 0; g < 2**RAM1_ADDR_WIDTH; g = g + 1)
				for (h = 0; h < RAM1_DATA_WIDTH; h = h + 1) begin
					`ifdef SIM_VERILATOR
						local_ram1[g][h] = INIT1[f];
					`else
						local_ram1[g][h] <= INIT1[f];
					`endif
					f = f + 1;
				end
		end

	//Local_RAM2
	localparam A2_DATA_WRITE_WIDTH = calc_data_width(WRITE_WIDTH_A2);
	localparam A2_WRITE_ADDR_WIDTH = calc_depth(A2_DATA_WRITE_WIDTH);
	localparam A2_DATA_READ_WIDTH = calc_data_width(READ_WIDTH_A2);
	localparam A2_READ_ADDR_WIDTH = calc_depth(A2_DATA_READ_WIDTH);
	localparam A2_DATA_WIDTH = (A2_DATA_WRITE_WIDTH > A2_DATA_READ_WIDTH) ? A2_DATA_WRITE_WIDTH : A2_DATA_READ_WIDTH;

	localparam A2_PARITY_WRITE_WIDTH = calc_parity_width(WRITE_WIDTH_A2);
	localparam A2_PARITY_READ_WIDTH = calc_parity_width(READ_WIDTH_A2);
	localparam A2_PARITY_WIDTH = (A2_PARITY_WRITE_WIDTH > A2_PARITY_READ_WIDTH) ? A2_PARITY_WRITE_WIDTH : A2_PARITY_READ_WIDTH;
	
	localparam B2_DATA_WRITE_WIDTH = calc_data_width(WRITE_WIDTH_B2);
	localparam B2_WRITE_ADDR_WIDTH = calc_depth(B2_DATA_WRITE_WIDTH);
	localparam B2_DATA_READ_WIDTH = calc_data_width(READ_WIDTH_B2);
	localparam B2_READ_ADDR_WIDTH = calc_depth(B2_DATA_READ_WIDTH);
	localparam B2_DATA_WIDTH = (B2_DATA_WRITE_WIDTH > B2_DATA_READ_WIDTH) ? B2_DATA_WRITE_WIDTH : B2_DATA_READ_WIDTH;

	localparam B2_PARITY_WRITE_WIDTH = calc_parity_width(WRITE_WIDTH_B2);
	localparam B2_PARITY_READ_WIDTH = calc_parity_width(READ_WIDTH_B2);
	localparam B2_PARITY_WIDTH = (B2_PARITY_WRITE_WIDTH > B2_PARITY_READ_WIDTH) ? B2_PARITY_WRITE_WIDTH : B2_PARITY_READ_WIDTH;

	localparam RAM2_DATA_WIDTH = (A2_DATA_WIDTH > B2_DATA_WIDTH) ? A2_DATA_WIDTH : B2_DATA_WIDTH;
	localparam RAM2_PARITY_WIDTH = (A2_PARITY_WIDTH > B2_PARITY_WIDTH) ? A2_PARITY_WIDTH : B2_PARITY_WIDTH;
	localparam RAM2_ADDR_WIDTH = calc_depth(RAM2_DATA_WIDTH);

	reg [RAM2_DATA_WIDTH-1:0] local_ram2 [2**RAM2_ADDR_WIDTH-1:0];

	reg [RAM2_DATA_WIDTH-1:0] temp_ram2_data_a2;
	reg [RAM2_DATA_WIDTH-1:0] temp_ram2_data_b2;
	reg [1:0] temp_ram2_port;
	reg [RAM2_ADDR_WIDTH-1:0] temp_ram2_addr;

	// Parity Ram
	/* verilator lint_off LITENDIAN */
	reg [RAM2_PARITY_WIDTH-1:0] local_parity_ram2 [2**RAM2_ADDR_WIDTH-1:0];
	/* verilator lint_on LITENDIAN */

	integer a, b, c, l, n, p, r;

	integer f_p2, g_p2, h_p2, i_p2, j_p2, k_p2, m_p2;

	// Initialize Parity RAM contents
	initial begin
		f_p2 = 0;
		for (g_p2 = 0; g_p2 < 2**RAM2_ADDR_WIDTH; g_p2 = g_p2 + 1)
			for (h_p2 = 0; h_p2 < RAM2_PARITY_WIDTH; h_p2 = h_p2 + 1) begin
				`ifdef SIM_VERILATOR
					local_parity_ram2[g_p2][h_p2] = INIT2_PARITY[f_p2];
				`else
					local_parity_ram2[g_p2][h_p2] <= INIT2_PARITY[f_p2];
				`endif
				f_p2 = f_p2 + 1;
			end
	end

	// Initialize Base RAM contents
  initial begin
    a = 0;
    for (b = 0; b < 2**RAM2_ADDR_WIDTH; b = b + 1)
      for (c = 0; c < RAM2_DATA_WIDTH; c = c + 1) begin
				`ifdef SIM_VERILATOR
        	local_ram2[b][c] = INIT2[a];
				`else
					local_ram2[b][c] <= INIT2[a];
				`endif
        a = a + 1;
      end
  end

	localparam RAM_DATA_WIDTH = (RAM1_DATA_WIDTH > RAM2_DATA_WIDTH) ? RAM1_DATA_WIDTH : RAM2_DATA_WIDTH;
	localparam RAM_ADDR_WIDTH = (RAM1_ADDR_WIDTH > RAM2_ADDR_WIDTH) ? RAM2_ADDR_WIDTH : RAM1_ADDR_WIDTH;
	integer error=0;
	// debug flag
  bit debug=1;

	//Clock Generation//
initial begin
	CLK_A1 = 1'b0;
	forever #45 CLK_A1 = ~CLK_A1;
end
	
initial begin
	CLK_B1 = 1'b0;
	forever #28 CLK_B1 = ~CLK_B1;
	end

initial begin
	CLK_A2 = 1'b0;
	forever #36 CLK_A2 = ~CLK_A2;
	end

initial begin
	CLK_B2 = 1'b0;
	forever #5 CLK_B2 = ~CLK_B2;
end

	TDP_RAM18KX2 #(
		.INIT1(INIT1), // Initial Contents of memory, RAM 1
		.INIT1_PARITY(INIT1_PARITY), // Initial Contents of memory
		.WRITE_WIDTH_A1(WRITE_WIDTH_A1), // Write data width on port A, RAM 1 (1-18)
		.WRITE_WIDTH_B1(WRITE_WIDTH_B1), // Write data width on port B, RAM 1 (1-18)
		.READ_WIDTH_A1(READ_WIDTH_A1), // Read data width on port A, RAM 1 (1-18)
		.READ_WIDTH_B1(READ_WIDTH_B1), // Read data width on port B, RAM 1 (1-18)
		.INIT2(INIT2), // Initial Contents of memory, RAM 2
		.INIT2_PARITY(INIT2_PARITY), // Initial Contents of memory
		.WRITE_WIDTH_A2(WRITE_WIDTH_A2), // Write data width on port A, RAM 2 (1-18)
		.WRITE_WIDTH_B2(WRITE_WIDTH_B2), // Write data width on port B, RAM 2 (1-18)
		.READ_WIDTH_A2(READ_WIDTH_A2), // Read data width on port A, RAM 2 (1-18)
		.READ_WIDTH_B2(READ_WIDTH_B2) // Read data width on port B, RAM 2 (1-18)
) 
tdp_ram18kx2_inst
	(
		// Ports for 1st 18K RAM
		.WEN_A1(WEN_A1), // Write-enable port A, RAM 1
		.WEN_B1(WEN_B1), // Write-enable port B, RAM 1
		.REN_A1(REN_A1), // Read-enable port A, RAM 1
		.REN_B1(REN_B1), // Read-enable port B, RAM 1
		.CLK_A1(CLK_A1), // Clock port A, RAM 1
		.CLK_B1(CLK_B1), // Clock port B, RAM 1
		.BE_A1(BE_A1), // Byte-write enable port A, RAM 1
		.BE_B1(BE_B1), // Byte-write enable port B, RAM 1
		.ADDR_A1(ADDR_A1), // Address port A, RAM 1
		.ADDR_B1(ADDR_B1), // Address port B, RAM 1
		.WDATA_A1(WDATA_A1), // Write data port A, RAM 1
		.WPARITY_A1(WPARITY_A1), // Write parity port A, RAM 1
		.WDATA_B1(WDATA_B1), // Write data port B, RAM 1
		.WPARITY_B1(WPARITY_B1), // Write parity port B, RAM 1
		.RDATA_A1(RDATA_A1), // Read data port A, RAM 1
		.RPARITY_A1(RPARITY_A1), // Read parity port A, RAM 1
		.RDATA_B1(RDATA_B1), // Read data port B, RAM 1
		.RPARITY_B1(RPARITY_B1), // Read parity port B, RAM 1
		// Ports for 2nd 18K RAM
		.WEN_A2(WEN_A2), // Write-enable port A, RAM 2
		.WEN_B2(WEN_B2), // Write-enable port B, RAM 2
		.REN_A2(REN_A2), // Read-enable port A, RAM 2
		.REN_B2(REN_B2), // Read-enable port B, RAM 2
		.CLK_A2(CLK_A2), // Clock port A, RAM 2
		.CLK_B2(CLK_B2), // Clock port B, RAM 2
		.BE_A2(BE_A2), // Byte-write enable port A, RAM 2
		.BE_B2(BE_B2), // Byte-write enable port B, RAM 2
		.ADDR_A2(ADDR_A2), // Address port A, RAM 2
		.ADDR_B2(ADDR_B2), // Address port B, RAM 2
		.WDATA_A2(WDATA_A2), // Write data port A, RAM 2
		.WPARITY_A2(WPARITY_A2), // Write parity port A, RAM 2
		.WDATA_B2(WDATA_B2), // Write data port B, RAM 2
		.WPARITY_B2(WPARITY_B2), // Write parity port B, RAM 2
		.RDATA_A2(RDATA_A2), // Read data port A, RAM 2
		.RPARITY_A2(RPARITY_A2), // Read parity port A, RAM 2
		.RDATA_B2(RDATA_B2), // Read data port B, RAM 2
		.RPARITY_B2(RPARITY_B2) // Read parity port B, RAM 2
	);

`ifdef VCD
	initial begin
		$dumpfile("wave.vcd");
		$dumpvars;
	end
`endif

	initial begin
	fork 
		begin
			// Corner Cases for RAM1
			directed_read_or_write('0,'0,'0,'0,1,0); // 0 on 0 - write - port1A
			directed_read_or_write('1,'1,'0,'0,1,1); // 0 on 1 - write - port1B
			directed_read_or_write('0,'0,'0,'0,0,0); // 0 on 0 - read - port1A
			directed_read_or_write('1,'1,'0,'0,0,1); // 0 on 1 - read -port1B
			// // Write Port1A
			directed_read_or_write('0,'0,'hdead,'0,1,0); // AddrA, AddrB, DataA, DataB, Write, PortAB
			directed_read_or_write('h5,'1,'1,'0,1,0); // AddrA, AddrB, DataA, DataB, Write, PortAB
			// Read Port1A
			directed_read_or_write('0,'0,'hdead,'0,0,0); // AddrA, AddrB, DataA, DataB, Write, PortAB
			directed_read_or_write('h5,'1,'1,'0,0,0); // AddrA, AddrB, DataA, DataB, Write, PortAB
			// Write Port1B
			directed_read_or_write('0,'0,'hbeef,'hbeef,1,1); // AddrA, AddrB, DataA, DataB, Write, PortAB
			directed_read_or_write('h5,'h5,'1,'1,1,1); // AddrA, AddrB, DataA, DataB, Write, PortAB
			// Read Port1B
			directed_read_or_write('0,'0,'hbeef,'hbeef,0,1); // AddrA, AddrB, DataA, DataB, Write, PortAB
			directed_read_or_write('h5,'h5,'1,'1,0,1); // AddrA, AddrB, DataA, DataB, Write, PortAB
			// Read after Write (Random)
			repeat (255) begin
				temp_ram1_data_a1 = $urandom_range(0, (2**RAM1_DATA_WIDTH)-1);
				temp_ram1_data_b1 = $urandom_range(0, (2**RAM1_DATA_WIDTH)-1);
				temp_ram1_port = $urandom_range(0, 1);
				temp_ram1_addr = $urandom_range(0, (2**RAM1_ADDR_WIDTH)-1);
				directed_read_or_write(temp_ram1_addr,temp_ram1_addr,temp_ram1_data_a1,temp_ram1_data_b1,1,temp_ram1_port); // AddrA, AddrB, DataA, DataB, Write, PortAB
				directed_read_or_write(temp_ram1_addr,temp_ram1_addr,temp_ram1_data_a1,temp_ram1_data_b1,0,temp_ram1_port); // AddrA, AddrB, DataA, DataB, Write, PortAB
			end
		end
	join
	fork
		begin
		// Corner Cases for RAM2
			directed_read_or_write('0,'0,'0,'0,1,2); // 0 on 0 - write - port2A
			directed_read_or_write('1,'1,'0,'0,1,3); // 0 on 1 - write - port2B
			directed_read_or_write('0,'0,'0,'0,0,2); // 0 on 0 - read - port2A
			directed_read_or_write('1,'1,'0,'0,0,3); // 0 on 1 - read - port2B
			// Write Port2B
			directed_read_or_write('0,'0,'hdead,'0,1,2); // AddrA, AddrB, DataA, DataB, Write, PortAB
			directed_read_or_write('h5,'1,'1,'0,1,2); // AddrA, AddrB, DataA, DataB, Write, PortAB
			// Read Port2B
			directed_read_or_write('0,'0,'hdead,'0,0,2); // AddrA, AddrB, DataA, DataB, Write, PortAB
			directed_read_or_write('h5,'1,'1,'0,0,2); // AddrA, AddrB, DataA, DataB, Write, PortAB
			// Write Port2A
			directed_read_or_write('0,'0,'hbeef,'hbeef,1,3); // AddrA, AddrB, DataA, DataB, Write, PortAB
			directed_read_or_write('h5,'h5,'1,'1,1,3); // AddrA, AddrB, DataA, DataB, Write, PortAB
			// Read Port2A
			directed_read_or_write('0,'0,'hbeef,'hbeef,0,3); // AddrA, AddrB, DataA, DataB, Write, PortAB
			directed_read_or_write('h5,'h5,'1,'1,0,3); // AddrA, AddrB, DataA, DataB, Write, PortAB
			// Read after Write (Random)
			repeat (255) begin
				temp_ram2_data_a2 = $urandom_range(0, (2**RAM2_DATA_WIDTH)-1);
				temp_ram2_data_b2 = $urandom_range(0, (2**RAM2_DATA_WIDTH)-1);
				temp_ram2_port = $urandom_range(2, 3);
				temp_ram2_addr = $urandom_range(0, (2**RAM2_ADDR_WIDTH)-1);
				directed_read_or_write(temp_ram2_addr,temp_ram2_addr,temp_ram2_data_a2,temp_ram2_data_b2,1,temp_ram2_port); // AddrA, AddrB, DataA, DataB, Write, PortAB
				directed_read_or_write(temp_ram2_addr,temp_ram2_addr,temp_ram2_data_a2,temp_ram2_data_b2,0,temp_ram2_port); // AddrA, AddrB, DataA, DataB, Read, PortAB
			end
		end
  join
  /* verilator lint_on WIDTHCONCAT */
  /* verilator lint_on WIDTH */

//   // // Collision Check
//   @(negedge CLK_A1);
//   ADDR_A1 = 'h0;
//   WEN_A1 = 1; WDATA_A1 = 'hFFFF;
//   ADDR_B1 = 'h0;
//   REN_B1 = 1; WDATA_B1 = 'hFFFF;

  // // RAM2

  // // Collision Check
  //   @(negedge CLK_A2);
  //   ADDR_A2 = 'h0;
  //   WEN_A2 = 1; WDATA_A2 = 'hFFFF;
  //   ADDR_B2 = 'h0;
  //   REN_B2 = 1; WDATA_B2 = 'hFFFF;

		test_status(error);
		#100;
		$finish();

end


  	/* verilator lint_off WIDTH */
  	/* verilator lint_off SELRANGE */
  	/* verilator lint_off IGNOREDRETURN */
	task directed_read_or_write(input reg [RAM_ADDR_WIDTH-1:0] d_addrA, input reg [RAM_ADDR_WIDTH-1:0] d_addrB, input reg [RAM_DATA_WIDTH-1:0] d_dinA, input reg [RAM_DATA_WIDTH-1:0] d_dinB, input reg write, input reg [1:0] portAB);
	if(write) begin
      if(portAB==2'b00)
        begin
          @(negedge CLK_A1);
          WEN_A1 = 1; WDATA_A1 = d_dinA; drive_addr(d_addrA, RAM1_ADDR_WIDTH, portAB); WPARITY_A1 = $urandom_range(0, (2**RAM1_PARITY_WIDTH)-1); BE_A1 = $urandom_range(0, 4); 
          //@(posedge CLK_A1) local_ram1[d_addrA] = WDATA_A1;
          @(posedge CLK_A1) local_ram1[d_addrA] = RAM1_Data_wrt_BE(d_addrA, d_dinA, WPARITY_A1, BE_A1);
          @(negedge CLK_A1);
          WEN_A1 = 0;
        end
      else if(portAB==2'b01)
        begin
          @(negedge CLK_B1);
          WEN_B1 = 1; WDATA_B1 = d_dinB; drive_addr(d_addrB, RAM1_ADDR_WIDTH, portAB); WPARITY_B1 = $urandom_range(0, (2**RAM1_PARITY_WIDTH)-1); BE_B1 = $urandom_range(0, 4);
          //@(posedge CLK_B1) local_ram1[d_addrB] = WDATA_B1;
          @(posedge CLK_B1) local_ram1[d_addrB] = RAM1_Data_wrt_BE(d_addrB, d_dinB, WPARITY_B1, BE_B1);
          @(negedge CLK_B1);
          WEN_B1 = 0;
        end
      else if(portAB==2'b10)
        begin
          @(negedge CLK_A2);
          WEN_A2 = 1; WDATA_A2 = d_dinA; drive_addr(d_addrA, RAM2_ADDR_WIDTH, portAB); WPARITY_A2 = $urandom_range(0, (2**RAM2_PARITY_WIDTH)-1); BE_A2 = $urandom_range(0, 4);
          //@(posedge CLK_A2) local_ram2[d_addrA] = WDATA_A2;
          @(posedge CLK_A2) local_ram2[d_addrA] = RAM2_Data_wrt_BE(d_addrA, d_dinA, WPARITY_A2, BE_A2);
          @(negedge CLK_A2); WEN_A2 = 0;
        end
      else if(portAB==2'b11)
        begin
          @(negedge CLK_B2);
          WEN_B2 = 1; WDATA_B2 = d_dinB; drive_addr(d_addrB, RAM2_ADDR_WIDTH, portAB); WPARITY_B2 = $urandom_range(0, (2**RAM2_PARITY_WIDTH)-1); BE_B2 = $urandom_range(0, 4);
          //@(posedge CLK_B2) local_ram2[d_addrB] = WDATA_B2;
          @(posedge CLK_B2) local_ram2[d_addrB] = RAM2_Data_wrt_BE(d_addrB, d_dinB, WPARITY_B2, BE_B2);
          @(negedge CLK_B2); WEN_B2 = 0;
        end
    end
    else begin
      if(portAB==2'b00)
        begin
          @(negedge CLK_A1);  WEN_A1 = 0; drive_addr(d_addrA, RAM1_ADDR_WIDTH, portAB);
          @(negedge CLK_A1);	REN_A1 = 1;
          @(negedge CLK_A1);	REN_A1 = 0;
          compare(RDATA_A1, local_ram1[d_addrA], d_addrA, 0);
          compare(RPARITY_A1, local_parity_ram1[d_addrA], d_addrA, 1);
        end
      else if(portAB==2'b01)
        begin
          @(negedge CLK_B1);   WEN_B1 = 0; drive_addr(d_addrB, RAM1_ADDR_WIDTH, portAB);
          @(negedge CLK_B1);	 REN_B1 = 1;
          @(negedge CLK_B1);	 REN_B1 = 0;
          compare(RDATA_B1, local_ram1[d_addrB], d_addrB, 0);
          compare(RPARITY_B1, local_parity_ram1[d_addrB], d_addrB, 1);
        end
      else if(portAB==2'b10)
        begin
          @(negedge CLK_A2);  WEN_A2 = 0; drive_addr(d_addrA, RAM2_ADDR_WIDTH, portAB);
          @(negedge CLK_A2);	REN_A2 = 1;
          @(negedge CLK_A2);	REN_A2 = 0;
          compare_RAM2(RDATA_A2, local_ram2[d_addrA], d_addrA, 0);
					compare_RAM2(RPARITY_A2, local_parity_ram2[d_addrA], d_addrA, 1);
        end
     else if(portAB==2'b11)
        begin
          @(negedge CLK_B2);  WEN_B2 = 0; drive_addr(d_addrA, RAM2_ADDR_WIDTH, portAB);
          @(negedge CLK_B2);	REN_B2 = 1;
          @(negedge CLK_B2);	REN_B2 = 0;
          compare_RAM2(RDATA_B2, local_ram2[d_addrB], d_addrB, 0);
					compare_RAM2(RPARITY_B2, local_parity_ram2[d_addrB], d_addrB, 1);
        end
    end
    //$display("Addr_A: %0h, Addr_B: %0h, WDATA_A1: %0h, WDATA_B1: %0h, Write/Read Enable: %0h, Port: %0h, Time: %0t", ADDR_A1, ADDR_B1, d_dinA, d_dinB, write, portAB,$time);

  endtask

	function integer calc_data_width;
    input integer width;
    if (width==9)
      calc_data_width = 8;
    else if (width==18) 
      calc_data_width = 16;
    else
      calc_data_width = width;
  endfunction

	function integer calc_parity_width;
    input integer width;
    if (width==9)
      calc_parity_width = 1;
    else if (width==18) 
      calc_parity_width = 2;
    else
      calc_parity_width = 0;
  endfunction

	function integer calc_depth;
    input integer width;
    if (width<=1)
      calc_depth = 14;
    else if (width<=2) 
      calc_depth = 13;
    else if (width<=4) 
      calc_depth = 12;
    else if (width<=9) 
      calc_depth = 11;
    else if (width<=18) 
      calc_depth = 10;
    else
      calc_depth = 0;
  endfunction

	function integer drive_addr(input reg [13:0] addr, input integer addr_width, input reg [1:0] portAB);
    if (addr_width == 10) begin
			if(portAB==2'b00)
				ADDR_A1[13:4] = addr;
			else if(portAB==2'b01)
				ADDR_B1[13:4] = addr;
			else if(portAB==2'b10)
				ADDR_A2[13:4] = addr;
			else if(portAB==2'b11)
				ADDR_B2[13:4] = addr;
		end
    else if (addr_width == 11) begin
			if(portAB==2'b00)
				ADDR_A1[13:3] = addr;
			else if(portAB==2'b01)
				ADDR_B1[13:3] = addr;
			else if(portAB==2'b10)
				ADDR_A2[13:3] = addr;
			else if(portAB==2'b11)
				ADDR_B2[13:3] = addr;
		end
    else if (addr_width == 12) begin
			if(portAB==2'b00)
				ADDR_A1[13:2] = addr;
			else if(portAB==2'b01)
				ADDR_B1[13:2] = addr;
			else if(portAB==2'b10)
				ADDR_A2[13:2] = addr;
			else if(portAB==2'b11)
				ADDR_B2[13:2] = addr;
		end
    else if (addr_width == 13) begin
			if(portAB==2'b00)
				ADDR_A1[13:1] = addr;
			else if(portAB==2'b01)
				ADDR_B1[13:1] = addr;
			else if(portAB==2'b10)
				ADDR_A2[13:1] = addr;
			else if(portAB==2'b11)
				ADDR_B2[13:1] = addr;
		end
    else if (addr_width == 14) begin
			if(portAB==2'b00)
				ADDR_A1[13:0] = addr;
			else if(portAB==2'b01)
				ADDR_B1[13:0] = addr;
			else if(portAB==2'b10)
				ADDR_A2[13:0] = addr;
			else if(portAB==2'b11)
				ADDR_B2[13:0] = addr;
		end
    else begin
      if(portAB==2'b00)
				ADDR_A1[13:0] = 0;
			else if(portAB==2'b01)
				ADDR_B1[13:0] = 0;
			else if(portAB==2'b10)
				ADDR_A2[13:0] = 0;
			else if(portAB==2'b11)
				ADDR_B2[13:0] = 0;
			end
    //$display("Addr_A: %0b, Addr_B: %0b, addr_width: %0d, Port: %0h, Time: %0t", ADDR_A1, ADDR_B1, addr_width, portAB,$time);	
  endfunction

	/* verilator lint_off LITENDIAN */
	function logic [RAM1_DATA_WIDTH-1:0] RAM1_Data_wrt_BE(input reg [RAM1_ADDR_WIDTH-1:0] addr, input reg [RAM1_DATA_WIDTH-1:0] din, input reg [RAM1_PARITY_WIDTH-1:0] parity, input reg [1:0] BE);
	/* verilator lint_on LITENDIAN */
    logic [RAM1_DATA_WIDTH-1:0] dout;
    if (RAM1_DATA_WIDTH > 9) begin
			case (BE)
				2'b00: dout = local_ram1[addr];
				2'b01: begin
					local_ram1[addr][7:0] = din[7:0];
					local_parity_ram1[addr][0] = parity[0];
					dout = local_ram1[addr];
				end
				2'b10: begin 
					local_ram1[addr][15:8] = din[15:8]; 
					local_parity_ram1[addr][1] = parity[1];
					dout = local_ram1[addr];
				end
				2'b11: begin 
					local_ram1[addr] = din;
					local_parity_ram1[addr][1:0] = parity; 
					dout = local_ram1[addr];
				end
			endcase
		end
		else begin
			if (RAM1_DATA_WIDTH == 8) begin
				local_ram1[addr] = din;
				local_parity_ram1[addr][0] = parity[0]; 
				dout = local_ram1[addr];
			end
			else begin
				local_ram1[addr] = din; 
				dout = local_ram1[addr];
			end
		end
    return dout;
  endfunction

	/* verilator lint_off LITENDIAN */
	function logic [RAM2_DATA_WIDTH-1:0] RAM2_Data_wrt_BE(input reg [RAM2_ADDR_WIDTH-1:0] addr, input reg [RAM2_DATA_WIDTH-1:0] din, input reg [RAM2_PARITY_WIDTH-1:0] parity, input reg [1:0] BE);
	/* verilator lint_on LITENDIAN */
    reg [RAM2_DATA_WIDTH-1:0] dout;
    if (RAM2_DATA_WIDTH > 9) begin
			case (BE)
				2'b00: dout = local_ram2[addr];
				2'b01: begin
					local_ram2[addr][7:0] = din[7:0];
					local_parity_ram2[addr][0] = parity[0];
					dout = local_ram2[addr];
				end
				2'b10: begin 
					local_ram2[addr][15:8] = din[15:8]; 
					local_parity_ram2[addr][1] = parity[1];
					dout = local_ram2[addr];
				end
				2'b11: begin 
					local_ram2[addr] = din;
					local_parity_ram2[addr][1:0] = parity; 
					dout = local_ram2[addr];
				end
			endcase
		end
		else begin
			if (RAM2_DATA_WIDTH == 8) begin
				local_ram2[addr] = din;
				local_parity_ram2[addr][0] = parity[0]; 
				dout = local_ram2[addr];
			end
			else begin
				local_ram2[addr] = din; 
				dout = local_ram2[addr];
			end
		end
    return dout;
  endfunction
  /* verilator lint_on WIDTH */
	/* verilator lint_on SELRANGE */

task test_status(input logic [31:0] error);
begin
	if(error === 32'h0)
    begin
			$display(""); 
			$display(""); 
			$display("                     $$$$$$$$$$$              ");
      $display("                    $$          $$            ");
      $display("       $$$        $$              $$          ");
      $display("      $   $      $$                $$         ");
      $display("      $    $    $$    $$      $$    $$        ");
      $display("      $    $   $$    $  $    $  $    $$       ");
      $display("      $    $  $$     $  $    $  $     $$      ");
      $display("     $$    $                           $$     ");
      $display("     $    $$$$$$                       $$     ");
      $display("    $$         $ $$$$$$$$$$$$$$$$$$$$  $$     ");
      $display("   $$    $$$$$$$  $$   $  $  $    $$   $$     ");
      $display("   $            $  $$  $  $  $   $$   $$      ");
      $display("   $     $$$$$$$    $$ $  $  $  $$   $$       ");
      $display("   $            $    $$$  $  $ $$   $$        ");
      $display("   $     $$$$$$$ $$   $$$$$$$$$$   $$         ");
      $display("   $$          $   $$             $$          ");
      $display("     $$$$$$$$$$      $$         $$            ");
      $display("                       $$$$$$$$$              ");
			$display("");
			$display("");	
			$display("----------------------------------------------");
      $display("                 TEST_PASSED                  ");
			$display("----------------------------------------------");
    end
    else   
    begin
			$display("");
			$display("");	
			$display("           |||||||||||||");
			$display("         ||| |||      ||");
			$display("|||     ||    || ||||||||||");
			$display("||||||||      ||||       ||");
			$display("||||          ||  ||||||||||");
			$display("||||           |||         ||");
			$display("||||           ||  ||||||||||");
			$display("||||            ||||        |");
			$display("||||             |||  ||||  |");
			$display("|||||||||          ||||     |");
			$display("|||     ||             |||||");
			$display("         |||       ||||||");
			$display("           ||      ||");
			$display("            |||     ||");
			$display("              ||    ||");
			$display("               |||   ||");
			$display("                 ||   |");
			$display("                  |   |");
			$display("                  || ||");
			$display("                   |||");
			$display("");
			$display("");	
      $display("----------------------------------------------");
      $display("                 TEST_FAILED                  ");
      $display("----------------------------------------------");
    end
end
endtask

task compare(input reg [RAM1_DATA_WIDTH-1:0] dout, exp_dout, input reg [RAM1_ADDR_WIDTH-1:0] addr, input reg parity);
	if (RAM1_PARITY_WIDTH < 1 && parity == 1)
		exp_dout = 0;
	if(dout !== exp_dout) begin
		if (parity)
			$display("Parity:: Write/Read Mismatch. Address: %0h, DUT_Out: %0h, Exp_Out: %0h, Time: %0t", addr, dout, exp_dout,$time);
		else
			$display("Data:: Write/Read Mismatch. Address: %0h, DUT_Out: %0h, Exp_Out: %0h, Time: %0t", addr, dout, exp_dout,$time);
		error = error+1;
	end
	else if(debug)
		if (parity)
			$display("Parity:: Write/Read MATCHED. Address: %0h, DUT_Out: %0h, Exp_Out: %0h, Time: %0t", addr, dout, exp_dout,$time);
		else
			$display("Data:: Write/Read MATCHED. Address: %0h, DUT_Out: %0h, Exp_Out: %0h, Time: %0t", addr, dout, exp_dout,$time);
endtask

task compare_RAM2(input reg [RAM2_DATA_WIDTH-1:0] dout, exp_dout, input reg [RAM2_ADDR_WIDTH-1:0] addr, input reg parity);
	if (RAM2_PARITY_WIDTH < 1 && parity == 1)
		exp_dout = 0;
	if(dout !== exp_dout) begin
		if (parity)
			$display("Parity_RAM2:: Write/Read Mismatch. Address: %0h, DUT_Out: %0h, Exp_Out: %0h, Time: %0t", addr, dout, exp_dout,$time);
		else
			$display("Data_RAM2:: Write/Read Mismatch. Address: %0h, DUT_Out: %0h, Exp_Out: %0h, Time: %0t", addr, dout, exp_dout,$time);
		error = error+1;
	end
	else if(debug)
		if (parity)
			$display("Parity_RAM2:: Write/Read MATCHED. Address: %0h, DUT_Out: %0h, Exp_Out: %0h, Time: %0t", addr, dout, exp_dout,$time);
		else
			$display("Data_RAM2:: Write/Read MATCHED. Address: %0h, DUT_Out: %0h, Exp_Out: %0h, Time: %0t", addr, dout, exp_dout,$time);
endtask

endmodule
