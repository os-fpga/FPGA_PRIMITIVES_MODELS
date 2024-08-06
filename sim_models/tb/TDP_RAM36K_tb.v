`timescale 1ns/1ps
`celldefine
// Self-Checking Testbench for TDP_RAM36K simulation model
// Testbench Not modeled for ASymmetric RAM
// So, Keep the Write/Read Width Same for Both Ports

module TDP_RAM36K_tb();
	// Ports for 1st 18K RAM
	reg WEN_A; // Write-enable port A
	reg WEN_B; // Write-enable port B
	reg REN_A; // Read-enable port A
	reg REN_B; // Read-enable port B
	reg CLK_A; // Clock port A
	reg CLK_B; // Clock port B
	reg [3:0] BE_A; // Byte-write enable port A
	reg [3:0] BE_B; // Byte-write enable port B
	reg [14:0] ADDR_A; // Address port A
	reg [14:0] ADDR_B; // Address port B
	reg [WRITE_WIDTH_A-1:0] WDATA_A; // Write data port A
	reg [3:0] WPARITY_A; // Write parity port A
	reg [WRITE_WIDTH_B-1:0] WDATA_B; // Write data port B
	reg [3:0] WPARITY_B; // Write parity port B
	wire [READ_WIDTH_A-1:0] RDATA_A; // Read data port A
	wire [3:0] RPARITY_A; // Read parity port A
	wire [READ_WIDTH_B-1:0] RDATA_B; // Read data port B
	wire [3:0] RPARITY_B; // Read parity port B

	/* verilator lint_off WIDTHCONCAT */
	parameter [32767:0] INIT = {32768{1'b0}}; // Initial Contents of memory
	/* verilator lint_on WIDTHCONCAT */
	/* verilator lint_off WIDTHCONCAT */
  parameter [4095:0] INIT_PARITY = {4096{1'b0}}; // Initial Contents of memory
	/* verilator lint_on WIDTHCONCAT */
  parameter WRITE_WIDTH_A = 18; // Write data width on port A (1-36)
  parameter READ_WIDTH_A = 	18; // Read data width on port A (1-36)
  parameter WRITE_WIDTH_B = 18; // Write data width on port B (1-36)
  parameter READ_WIDTH_B = 	18; // Read data width on port B (1-36)

	//Local_RAM
  localparam A_DATA_WRITE_WIDTH = calc_data_width(WRITE_WIDTH_A);
  localparam A_WRITE_ADDR_WIDTH = calc_depth(A_DATA_WRITE_WIDTH);
  localparam A_DATA_READ_WIDTH = calc_data_width(READ_WIDTH_A);
  localparam A_READ_ADDR_WIDTH = calc_depth(A_DATA_READ_WIDTH);
  localparam A_DATA_WIDTH = (A_DATA_WRITE_WIDTH > A_DATA_READ_WIDTH) ? A_DATA_WRITE_WIDTH : A_DATA_READ_WIDTH;

	localparam A_PARITY_WRITE_WIDTH = calc_parity_width(WRITE_WIDTH_A);
  localparam A_PARITY_READ_WIDTH = calc_parity_width(READ_WIDTH_A);
  localparam A_PARITY_WIDTH = (A_PARITY_WRITE_WIDTH > A_PARITY_READ_WIDTH) ? A_PARITY_WRITE_WIDTH : A_PARITY_READ_WIDTH;

	localparam B_DATA_WRITE_WIDTH = calc_data_width(WRITE_WIDTH_B);
  localparam B_WRITE_ADDR_WIDTH = calc_depth(B_DATA_WRITE_WIDTH);
  localparam B_DATA_READ_WIDTH = calc_data_width(READ_WIDTH_B);
  localparam B_READ_ADDR_WIDTH = calc_depth(B_DATA_READ_WIDTH);
  localparam B_DATA_WIDTH = (B_DATA_WRITE_WIDTH > B_DATA_READ_WIDTH) ? B_DATA_WRITE_WIDTH : B_DATA_READ_WIDTH;

	localparam B_PARITY_WRITE_WIDTH = calc_parity_width(WRITE_WIDTH_B);
  localparam B_PARITY_READ_WIDTH = calc_parity_width(READ_WIDTH_B);
  localparam B_PARITY_WIDTH = (B_PARITY_WRITE_WIDTH > B_PARITY_READ_WIDTH) ? B_PARITY_WRITE_WIDTH : B_PARITY_READ_WIDTH;

	localparam RAM_DATA_WIDTH = (A_DATA_WIDTH > B_DATA_WIDTH) ? A_DATA_WIDTH : B_DATA_WIDTH;
	localparam RAM_PARITY_WIDTH = (A_PARITY_WIDTH > B_PARITY_WIDTH) ? A_PARITY_WIDTH : B_PARITY_WIDTH;
	localparam RAM_ADDR_WIDTH = calc_depth(RAM_DATA_WIDTH);

	reg [RAM_DATA_WIDTH-1:0] local_ram [2**RAM_ADDR_WIDTH-1:0];

	reg [RAM_DATA_WIDTH-1:0] temp_ram_data_a;
	reg [RAM_DATA_WIDTH-1:0] temp_ram_data_b;
	reg [0:0] temp_ram_port;
	reg [RAM_ADDR_WIDTH-1:0] temp_ram_addr;

	// Parity Ram
	/* verilator lint_off LITENDIAN */
	reg [RAM_PARITY_WIDTH-1:0] local_parity_ram [2**RAM_ADDR_WIDTH-1:0];
	/* verilator lint_on LITENDIAN */

	integer f_p, g_p, h_p;
	integer f, g, h, i, j, k, m;

	// Initialize Parity RAM contents
	initial begin
		f_p = 0;
		for (g_p = 0; g_p < 2**RAM_ADDR_WIDTH; g_p = g_p + 1)
			for (h_p = 0; h_p < RAM_PARITY_WIDTH; h_p = h_p + 1) begin
				`ifdef SIM_VERILATOR
					local_parity_ram[g_p][h_p] = INIT_PARITY[f_p];
				`else
					local_parity_ram[g_p][h_p] <= INIT_PARITY[f_p];
				`endif
				f_p = f_p + 1;
			end
	end

	// Initialize Base RAM contents
		initial begin
			f = 0;
			for (g = 0; g < 2**RAM_ADDR_WIDTH; g = g + 1)
				for (h = 0; h < RAM_DATA_WIDTH; h = h + 1) begin
					`ifdef SIM_VERILATOR
						local_ram[g][h] = INIT[f];
					`else
						local_ram[g][h] <= INIT[f];
					`endif
					f = f + 1;
				end
		end

	integer error=0;
	// debug flag
  bit debug=1;

	//Clock Generation//
initial begin
	CLK_A = 1'b0;
	forever #45 CLK_A = ~CLK_A;
end
	
initial begin
	CLK_B = 1'b0;
	forever #28 CLK_B = ~CLK_B;
	end

	TDP_RAM36K #(
		.INIT(INIT), // Initial Contents of memory
		.INIT_PARITY(INIT_PARITY), // Initial Contents of memory
		.WRITE_WIDTH_A(WRITE_WIDTH_A), // Write data width on port A (1-36)
		.WRITE_WIDTH_B(WRITE_WIDTH_B), // Write data width on port B (1-36)
		.READ_WIDTH_A(READ_WIDTH_A), // Read data width on port A (1-36)
		.READ_WIDTH_B(READ_WIDTH_B) // Read data width on port B (1-36)
) 
tdp_ram36k_inst
	(
		// Ports for 1st 18K RAM
		.WEN_A(WEN_A), // Write-enable port A
		.WEN_B(WEN_B), // Write-enable port B
		.REN_A(REN_A), // Read-enable port A
		.REN_B(REN_B), // Read-enable port B
		.CLK_A(CLK_A), // Clock port A
		.CLK_B(CLK_B), // Clock port B
		.BE_A(BE_A), // Byte-write enable port A
		.BE_B(BE_B), // Byte-write enable port B
		.ADDR_A(ADDR_A), // Address port A
		.ADDR_B(ADDR_B), // Address port B
		/* verilator lint_off WIDTH */
		.WDATA_A(WDATA_A), // Write data port A
		/* verilator lint_on WIDTH */
		.WPARITY_A(WPARITY_A), // Write parity port A
		/* verilator lint_off WIDTH */
		.WDATA_B(WDATA_B), // Write data port B
		/* verilator lint_on WIDTH */
		.WPARITY_B(WPARITY_B), // Write parity port B
		/* verilator lint_off WIDTH */
		.RDATA_A(RDATA_A), // Read data port A
		/* verilator lint_on WIDTH */
		.RPARITY_A(RPARITY_A), // Read parity port A
		/* verilator lint_off WIDTH */
		.RDATA_B(RDATA_B), // Read data port B
		/* verilator lint_on WIDTH */
		.RPARITY_B(RPARITY_B) // Read parity port B
	);

`ifdef VCD
	initial begin
		$dumpfile("wave.vcd");
		$dumpvars;
	end
`endif

	initial begin
		// Corner Cases for RAM1
		/* verilator lint_off WIDTH */
		directed_read_or_write('0,'0,'0,'0,1,0); // 0 on 0 - write - port1A
		directed_read_or_write('1,'1,'0,'0,1,1); // 0 on 1 - write - port1B
		directed_read_or_write('0,'0,'0,'0,0,0); // 0 on 0 - read - port1A
		directed_read_or_write('1,'1,'0,'0,0,1); // 0 on 1 - read -port1B
		// // // Write Port1A
		directed_read_or_write('0,'0,'hdead,'0,1,0); // AddrA, AddrB, DataA, DataB, Write, PortAB
		directed_read_or_write('h5,'1,'1,'0,1,0); // AddrA, AddrB, DataA, DataB, Write, PortAB
		// // Read Port1A
		directed_read_or_write('0,'0,'hdead,'0,0,0); // AddrA, AddrB, DataA, DataB, Write, PortAB
		directed_read_or_write('h5,'1,'1,'0,0,0); // AddrA, AddrB, DataA, DataB, Write, PortAB
		// // Write Port1B
		directed_read_or_write('0,'0,'hbeef,'hbeef,1,1); // AddrA, AddrB, DataA, DataB, Write, PortAB
		directed_read_or_write('h5,'h5,'1,'1,1,1); // AddrA, AddrB, DataA, DataB, Write, PortAB
		// Read Port1B
		directed_read_or_write('0,'0,'hbeef,'hbeef,0,1); // AddrA, AddrB, DataA, DataB, Write, PortAB
		directed_read_or_write('h5,'h5,'1,'1,0,1); // AddrA, AddrB, DataA, DataB, Write, PortAB
		// // Read after Write (Random)
		repeat (255) begin
			/* verilator lint_off WIDTH */
			temp_ram_data_a = $urandom_range(0, (2**RAM_DATA_WIDTH)-1);
			temp_ram_data_b = $urandom_range(0, (2**RAM_DATA_WIDTH)-1);
			/* verilator lint_on WIDTH */
			/* verilator lint_off WIDTH */
			temp_ram_port = $urandom_range(0, 1);
			// temp_ram_port = 0;
			/* verilator lint_on WIDTH */
			/* verilator lint_off WIDTH */
			temp_ram_addr = $urandom_range(0, (2**RAM_ADDR_WIDTH)-1);
			/* verilator lint_on WIDTH */
			directed_read_or_write(temp_ram_addr,temp_ram_addr,temp_ram_data_a,temp_ram_data_b,1,temp_ram_port); // AddrA, AddrB, DataA, DataB, Write, PortAB
			directed_read_or_write(temp_ram_addr,temp_ram_addr,temp_ram_data_a,temp_ram_data_b,0,temp_ram_port); // AddrA, AddrB, DataA, DataB, Write, PortAB
			/* verilator lint_on WIDTH */
		end

		// // Collision Check
		// /* verilator lint_off WIDTH */
		// @(negedge CLK_A);
		// ADDR_A = 'h0;
		// WEN_A = 1; WDATA_A = 'hFFFF;
		// ADDR_B = 'h0;
		// REN_B = 1; WDATA_B = 'hFFFF;
		// /* verilator lint_on WIDTH */
	  
		test_status(error);
		#100;
		$finish();

	end
	
	task directed_read_or_write(input reg [RAM_ADDR_WIDTH-1:0] d_addrA, input reg [RAM_ADDR_WIDTH-1:0] d_addrB, input reg [RAM_DATA_WIDTH-1:0] d_dinA, input reg [RAM_DATA_WIDTH-1:0] d_dinB, input reg write, input reg [0:0] portAB);
	if(write) begin
      if(portAB==1'b0)
        begin
          @(negedge CLK_A);
					/* verilator lint_off WIDTH */
					/* verilator lint_off IGNOREDRETURN */
          WEN_A = 1; WDATA_A = d_dinA; drive_addr(d_addrA, RAM_ADDR_WIDTH, portAB); WPARITY_A = $urandom_range(0, (2**RAM_PARITY_WIDTH)-1); //BE_A = 4'b1111; 
					BE_A = $urandom_range(0, 15);
					/* verilator lint_on WIDTH */
					/* verilator lint_on IGNOREDRETURN */
					/* verilator lint_off WIDTH */
          @(posedge CLK_A) local_ram[d_addrA] = RAM_Data_wrt_BE(d_addrA, d_dinA, WPARITY_A, BE_A);
					/* verilator lint_on WIDTH */
          @(negedge CLK_A);
          WEN_A = 0;
        end
      else if(portAB==1'b1)
        begin
          @(negedge CLK_B);
					/* verilator lint_off WIDTH */
					/* verilator lint_off IGNOREDRETURN */
          WEN_B = 1; WDATA_B = d_dinB; drive_addr(d_addrB, RAM_ADDR_WIDTH, portAB); WPARITY_B = $urandom_range(0, (2**RAM_PARITY_WIDTH)-1); //BE_B = 4'b1111;
					BE_B = $urandom_range(0, 15);
					/* verilator lint_on WIDTH */
					/* verilator lint_on IGNOREDRETURN */
					/* verilator lint_off WIDTH */
          @(posedge CLK_B) local_ram[d_addrB] = RAM_Data_wrt_BE(d_addrB, d_dinB, WPARITY_B, BE_B);
					/* verilator lint_on WIDTH */
          @(negedge CLK_B);
          WEN_B = 0;
        end
    end
    else begin
      if(portAB==1'b0)
        begin
					/* verilator lint_off WIDTH */
					/* verilator lint_off IGNOREDRETURN */
          @(negedge CLK_A);  WEN_A = 0; drive_addr(d_addrA, RAM_ADDR_WIDTH, portAB);
					/* verilator lint_on WIDTH */
					/* verilator lint_on IGNOREDRETURN */
					/* verilator lint_off WIDTH */
          @(negedge CLK_A);	REN_A = 1;
					/* verilator lint_on WIDTH */
          @(negedge CLK_A);	REN_A = 0;
					/* verilator lint_off WIDTH */
          compare(RDATA_A, local_ram[d_addrA], d_addrA, 0);
					/* verilator lint_on WIDTH */
					/* verilator lint_off WIDTH */
          compare(RPARITY_A, local_parity_ram[d_addrA], d_addrA, 1);
					/* verilator lint_on WIDTH */
        end
      else if(portAB==1'b1)
        begin
					/* verilator lint_off WIDTH */
					/* verilator lint_off IGNOREDRETURN */
          @(negedge CLK_B);   WEN_B = 0; drive_addr(d_addrB, RAM_ADDR_WIDTH, portAB);
					/* verilator lint_on WIDTH */
					/* verilator lint_on IGNOREDRETURN */
          @(negedge CLK_B);	 REN_B = 1;
          @(negedge CLK_B);	 REN_B = 0;
					/* verilator lint_off WIDTH */
          compare(RDATA_B, local_ram[d_addrB], d_addrB, 0);
					/* verilator lint_on WIDTH */
					/* verilator lint_off WIDTH */
          compare(RPARITY_B, local_parity_ram[d_addrB], d_addrB, 1);
					/* verilator lint_on WIDTH */
        end
    end

  endtask

function integer calc_data_width;
  input integer width;
  if (width==9)
	calc_data_width = 8;
  else if (width==18) 
	calc_data_width = 16;
  else if (width==27) 
	calc_data_width = 24;
  else if (width==36) 
	calc_data_width = 32;
  else
	calc_data_width = width;
endfunction

function integer calc_parity_width;
  input integer width;
  if (width==9)
	calc_parity_width = 1;
  else if (width==18) 
	calc_parity_width = 2;
  else if (width==27) 
	calc_parity_width = 3;
  else if (width==36) 
	calc_parity_width = 4;
  else
	calc_parity_width = 0;
endfunction

function integer calc_depth;
  input integer width;
  if (width<=1)
	calc_depth = 15;
  else if (width<=2) 
	calc_depth = 14;
  else if (width<=4) 
	calc_depth = 13;
  else if (width<=9) 
	calc_depth = 12;
  else if (width<=18) 
	calc_depth = 11;
  else if (width<=36) 
	calc_depth = 10;
  else
	calc_depth = 0;
endfunction

function integer drive_addr(input reg [14:0] addr, input integer addr_width, input reg [0:0] portAB);
    if (addr_width == 10) begin
			if(portAB==1'b0)
				/* verilator lint_off WIDTH */
				ADDR_A[14:5] = addr;
				/* verilator lint_on WIDTH */
			else if(portAB==1'b1)
				/* verilator lint_off WIDTH */
				ADDR_B[14:5] = addr;
				/* verilator lint_on WIDTH */
		end
    else if (addr_width == 11) begin
			if(portAB==1'b0)
				/* verilator lint_off WIDTH */
				ADDR_A[14:4] = addr;
				/* verilator lint_on WIDTH */
			else if(portAB==1'b1)
				/* verilator lint_off WIDTH */
				ADDR_B[14:4] = addr;
				/* verilator lint_on WIDTH */
		end
    else if (addr_width == 12) begin
			if(portAB==1'b0)
				/* verilator lint_off WIDTH */
				ADDR_A[14:3] = addr;
				/* verilator lint_on WIDTH */
			else if(portAB==1'b1)
				/* verilator lint_off WIDTH */
				ADDR_B[14:3] = addr;
				/* verilator lint_on WIDTH */
		end
    else if (addr_width == 13) begin
			if(portAB==1'b0)
				/* verilator lint_off WIDTH */
				ADDR_A[14:2] = addr;
				/* verilator lint_on WIDTH */
			else if(portAB==1'b1)
				/* verilator lint_off WIDTH */
				ADDR_B[14:2] = addr;
				/* verilator lint_on WIDTH */
		end
    else if (addr_width == 14) begin
			if(portAB==1'b0)
				/* verilator lint_off WIDTH */
				ADDR_A[14:1] = addr;
				/* verilator lint_on WIDTH */
			else if(portAB==1'b1)
				/* verilator lint_off WIDTH */
				ADDR_B[14:1] = addr;
				/* verilator lint_on WIDTH */
		end
		else if (addr_width == 15) begin
			if(portAB==1'b0)
				/* verilator lint_off WIDTH */
				ADDR_A[14:0] = addr;
				/* verilator lint_on WIDTH */
			else if(portAB==1'b1)
				/* verilator lint_off WIDTH */
				ADDR_B[14:0] = addr;
				/* verilator lint_on WIDTH */
		end
    else begin
      if(portAB==1'b0)
				/* verilator lint_off WIDTH */
				ADDR_A[14:0] = 0;
				/* verilator lint_on WIDTH */
			else if(portAB==1'b1)
				/* verilator lint_off WIDTH */
				ADDR_B[14:0] = 0;
				/* verilator lint_on WIDTH */
			end
  endfunction
	/* verilator lint_off LITENDIAN */
	function logic [RAM_DATA_WIDTH-1:0] RAM_Data_wrt_BE(input reg [RAM_ADDR_WIDTH-1:0] addr, input reg [RAM_DATA_WIDTH-1:0] din, input reg [RAM_PARITY_WIDTH-1:0] parity, input reg [3:0] BE);
    /* verilator lint_on LITENDIAN */
		logic [RAM_DATA_WIDTH-1:0] dout;
    if (RAM_DATA_WIDTH > 9) begin
			case (BE)
				4'b0000: dout = local_ram[addr];
				/* verilator lint_off SELRANGE */
				4'b0001: begin
					local_ram[addr][7:0] = din[7:0];
					local_parity_ram[addr][0] = parity[0];
					dout = local_ram[addr];
				end
				4'b0010: begin 
					local_ram[addr][15:8] = din[15:8]; 
					local_parity_ram[addr][1] = parity[1];
					dout = local_ram[addr];
				end
				4'b0011: begin 
					local_ram[addr][15:0] = din[15:0];
					local_parity_ram[addr][1:0] = parity[1:0]; 
					dout = local_ram[addr];
				end
				4'b0100: begin 
					if (RAM_DATA_WIDTH > 18) begin
						local_ram[addr][23:16] = din[23:16];
						local_parity_ram[addr][2] = parity[2];
					end 
					dout = local_ram[addr];
				end
				4'b0101: begin 
					local_ram[addr][7:0] = din[7:0];
					local_parity_ram[addr][0] = parity[0];
					if (RAM_DATA_WIDTH > 18) begin
						local_ram[addr][23:16] = din[23:16];
						local_parity_ram[addr][2] = parity[2]; 
					end
					dout = local_ram[addr];
				end
				4'b0110: begin 
					local_ram[addr][15:8] = din[15:8];
					local_parity_ram[addr][1] = parity[1];
					if (RAM_DATA_WIDTH > 18) begin
						local_ram[addr][23:16] = din[23:16];
						local_parity_ram[addr][2] = parity[2];
					end
					dout = local_ram[addr];
				end
				4'b0111: begin
						local_ram[addr][15:0] = din[15:0];
						local_parity_ram[addr][1:0] = parity[1:0];
						if (RAM_DATA_WIDTH > 18) begin
							local_ram[addr][23:16] = din[23:16];
							local_parity_ram[addr][2] = parity[2];
					end 
					dout = local_ram[addr];
				end
				4'b1000: begin 
					if (RAM_DATA_WIDTH > 18) begin
						local_ram[addr][31:24] = din[31:24];
						local_parity_ram[addr][3] = parity[3];
					end
					dout = local_ram[addr];
				end
				4'b1001: begin
					local_ram[addr][7:0] = din[7:0];
					local_parity_ram[addr][0] = parity[0];
					if (RAM_DATA_WIDTH > 18) begin
						local_ram[addr][31:24] = din[31:24];
						local_parity_ram[addr][3] = parity[3];
					end
					dout = local_ram[addr];
				end
				4'b1010: begin 
					local_ram[addr][15:8] = din[15:8];
					local_parity_ram[addr][1] = parity[1];
					if (RAM_DATA_WIDTH > 18) begin
						local_ram[addr][31:24] = din[31:24];
						local_parity_ram[addr][3] = parity[3];
					end
					dout = local_ram[addr];
				end
				4'b1011: begin 
					local_ram[addr][15:0] = din[15:0];
					local_parity_ram[addr][1:0] = parity[1:0];
					if (RAM_DATA_WIDTH > 18) begin
						local_ram[addr][31:24] = din[31:24];
						local_parity_ram[addr][3] = parity[3];
					end
					dout = local_ram[addr];
				end
				4'b1100: begin 
					if (RAM_DATA_WIDTH > 18) begin
						local_ram[addr][31:16] = din[31:16];
						local_parity_ram[addr][3:2] = parity[3:2];
					end
					dout = local_ram[addr];
				end
				4'b1101: begin 
					local_ram[addr][7:0] = din[7:0];
					local_parity_ram[addr][0] = parity[0];
					if (RAM_DATA_WIDTH > 18) begin
						local_ram[addr][31:16] = din[31:16];
						local_parity_ram[addr][3:2] = parity[3:2];
					end
					dout = local_ram[addr];
				end
				4'b1110: begin
					local_ram[addr][15:8] = din[15:8];
					local_parity_ram[addr][1] = parity[1];
					if (RAM_DATA_WIDTH > 18) begin
						local_ram[addr][31:16] = din[31:16];
						local_parity_ram[addr][3:2] = parity[3:2];
					end
					dout = local_ram[addr];
				end
				4'b1111: begin 
					local_ram[addr][15:0] = din[15:0];
					local_parity_ram[addr][1:0] = parity[1:0];
					if (RAM_DATA_WIDTH > 18) begin
						local_ram[addr][31:16] = din[31:16];
						local_parity_ram[addr][3:2] = parity[3:2];
					end
					dout = local_ram[addr];
					/* verilator lint_on SELRANGE */
				end
			endcase
		end
		else begin
			if (RAM_DATA_WIDTH == 8) begin
				local_ram[addr] = din;
				local_parity_ram[addr][0] = parity[0]; 
				dout = local_ram[addr];
			end
			else begin
				local_ram[addr] = din; 
				dout = local_ram[addr];
			end
		end
    return dout;
  endfunction

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

task compare(input bit [RAM_DATA_WIDTH-1:0] dout, exp_dout, input bit [RAM_ADDR_WIDTH-1:0] addr, input bit parity);
	if (RAM_PARITY_WIDTH < 1 && parity == 1)
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

endmodule