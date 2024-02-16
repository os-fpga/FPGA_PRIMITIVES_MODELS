// Copyright (C) 2023 RapidSilicon
//
// Monday, December 11, 2023

`default_nettype none

`timescale 1ns/1ps

module RS_TDP36K #(
    // Mode Bits
    parameter [0:80] MODE_BITS = {81{1'b0}},
    // Memory Initialization
    parameter [36863:0] INIT_i = {36864{1'b0}}
)
(
    // Ports
    input wire WEN_A1,
    input wire WEN_B1,
    input wire REN_A1,
    input wire REN_B1,
    (* clkbuf_sink *)
    input wire CLK_A1,
    (* clkbuf_sink *)
    input wire CLK_B1,
    input wire [1:0] BE_A1,
    input wire [1:0] BE_B1,
    input wire [14:0] ADDR_A1,
    input wire [14:0] ADDR_B1,
    input wire [17:0] WDATA_A1,
    input wire [17:0] WDATA_B1,
    output wire [17:0] RDATA_A1,
    output wire [17:0] RDATA_B1,
    input wire FLUSH1,
    input wire WEN_A2,
    input wire WEN_B2,
    input wire REN_A2,
    input wire REN_B2,
    (* clkbuf_sink *)
    input wire CLK_A2,
    (* clkbuf_sink *)
    input wire CLK_B2,
    input wire [1:0] BE_A2,
    input wire [1:0] BE_B2,
    input wire [13:0] ADDR_A2,
    input wire [13:0] ADDR_B2,
    input wire [17:0] WDATA_A2,
    input wire [17:0] WDATA_B2,
    output wire [17:0] RDATA_A2,
    output wire [17:0] RDATA_B2,
    input wire FLUSH2
);

    // First 18K RAMFIFO (41 bits)
    localparam [0:0] SYNC_FIFO1_i  = MODE_BITS[0];
    localparam [0:2] RMODE_A1_i    = MODE_BITS[1:3];
    localparam [0:2] RMODE_B1_i    = MODE_BITS[4:6];
    localparam [0:2] WMODE_A1_i    = MODE_BITS[7:9];
    localparam [0:2] WMODE_B1_i    = MODE_BITS[10:12];
    localparam [0:0] FMODE1_i      = MODE_BITS[13];
    localparam [0:0] POWERDN1_i    = MODE_BITS[14];
    localparam [0:0] SLEEP1_i      = MODE_BITS[15];
    localparam [0:0] PROTECT1_i    = MODE_BITS[16];
    localparam [0:11] UPAE1_i       = MODE_BITS[17:28];
    localparam [0:11] UPAF1_i       = MODE_BITS[29:40];

    // Second 18K RAMFIFO (39 bits)
    localparam [0:0] SYNC_FIFO2_i  = MODE_BITS[41];
    localparam [0:2] RMODE_A2_i    = MODE_BITS[42:44];
    localparam [0:2] RMODE_B2_i    = MODE_BITS[45:47];
    localparam [0:2] WMODE_A2_i    = MODE_BITS[48:50];
    localparam [0:2] WMODE_B2_i    = MODE_BITS[51:53];
    localparam [0:0] FMODE2_i      = MODE_BITS[54];
    localparam [0:0] POWERDN2_i    = MODE_BITS[55];
    localparam [0:0] SLEEP2_i      = MODE_BITS[56];
    localparam [0:0] PROTECT2_i    = MODE_BITS[57];
    localparam [0:10] UPAE2_i      = MODE_BITS[58:68];
    localparam [0:10] UPAF2_i      = MODE_BITS[69:79];

    // Split (1 bit)
    localparam [0:0] SPLIT_i       = MODE_BITS[80];

    // Memory Initialization
    localparam [18431:0]INIT1 = INIT_i[18431:0];
    localparam [18431:0]INIT2 = INIT_i[36863:18432];

    // Initialization Data
    function [32768-1:0] data();
        integer i;
        data = {32768{1'b0}};
        for (i = 0; i < 1024; i = i + 1) begin
            data[i*32 +:16]        = INIT1[i*18 +:16]; // Extracts every 16 bits from INIT1 and append in lower 16 bits of data
            data[i*32 + 16 +:16]   = INIT2[i*18 +:16]; // Extracts every 16 bits from INIT2 and append in upper 16 bits of data
        end
    endfunction

    // Initialization Parity
    function [4096-1:0] parity();
        integer i;
        parity = {4096{1'b0}};
        for (i = 0; i < 1024; i = i + 1) begin
            parity[i*4 +:2]        = INIT1[((i+1)*16+(2*i)) +:2]; // Extracts every 16th, 17th bit from INIT1 and append in lower 2 bits of parity
            parity[i*4 + 2 +:2]    = INIT2[((i+1)*16+(2*i)) +:2]; // Extracts every 16th, 17th bit from INIT2 and append in upper 2 bits of parity
        end
    endfunction

    // for TDP_RAM36K
    localparam [32767:0] data_i     = data() ;
    localparam [4095:0]  pairty_i   = parity();

    // RAM1 Data
    function [16384-1:0] data1();
        integer i;
        data1 = {16384{1'b0}};
        for (i = 0; i < 1024; i = i + 1) begin
            data1[i*16 +:16]        = INIT1[i*18 +:16]; // Extracts every 16 bit data from RAM1 
        end
    endfunction

    // RAM1 Parity
    function [2048-1:0] parity1();
        integer i;
        parity1 = {2048{1'b0}};
        for (i = 0; i < 1024; i = i + 1) begin
            parity1[i*2 +:2]        = INIT1[((i+1)*16+(2*i)) +:2]; // Extracts every 16th and 17th bit parity from RAM1
        end
    endfunction

    // RAM2 Data
    function [16384-1:0] data2();
        integer i;
        data2 = {16384{1'b0}};
        for (i = 0; i < 1024; i = i + 1) begin
            data2[i*16 +:16]        = INIT2[i*18 +:16]; // Extracts every 16 bit data from RAM2
        end
    endfunction

    // RAM2 Parity
    function [2048-1:0] parity2();
        integer i;
        parity2 = {2048{1'b0}};
        for (i = 0; i < 1024; i = i + 1) begin
            parity2[i*2 +:2]        = INIT2[((i+1)*16+(2*i)) +:2]; // Extracts every 16th and 17th bit parity from RAM2
        end
    endfunction

    // for TDP_RAM18KX2
    localparam [16383:0] data_i1    = data1();
    localparam [2047:0]  pairty_i1  = parity1();
    localparam [16383:0] data_i2    = data2();
    localparam [2047:0]  pairty_i2  = parity2();

    generate
        if (SPLIT_i == 1'b0) begin
            if(FMODE1_i == 1'b1) begin  // FIFO36K

                initial begin
                    if (!(WMODE_A1_i == 3'b110 || WMODE_A1_i == 3'b010 || WMODE_A1_i == 3'b100)) begin
                       $display("RS_TDP36K instance %m WMODE_A1_i set to incorrect value, %d.  Values must be either 3'b110, 3'b010 or 3'b110", WMODE_A1_i);
                    #1 $stop;
                    end
                    if (!(RMODE_B1_i == 3'b110 || RMODE_B1_i == 3'b010 || RMODE_B1_i == 3'b100)) begin
                       $display("RS_TDP36K instance %m RMODE_B1_i set to incorrect value, %d.  Values must be either 3'b110, 3'b010 or 3'b110", RMODE_B1_i);
                    #1 $stop;
                    end
                end

                localparam data_width_write = 
                    (WMODE_A1_i == 3'b110) ? 6'b100100 :
                    (WMODE_A1_i == 3'b010) ? 5'b10010 : 4'b1001;
                localparam data_width_read = 
                    (RMODE_B1_i == 3'b110) ? 6'b100100 :
                    (RMODE_B1_i == 3'b010) ? 5'b10010 : 4'b1001;
                localparam fifo_type   = (SYNC_FIFO1_i == 1'b1) ? "SYNCHRONOUS" : "ASYNCHRONOUS";

                wire [data_width_write - 1:0] wr_data;
                if (WMODE_A1_i == 3'b110) begin
                    assign wr_data = {WDATA_A2, WDATA_A1};
                end else if (WMODE_A1_i == 3'b010) begin
                    assign wr_data = WDATA_A1;
                end else if (WMODE_A1_i == 3'b100) begin
                    assign wr_data = {WDATA_A1[16], WDATA_A1[7:0]};
                end

                wire [data_width_read -1:0] rd_data;
                if (RMODE_B1_i == 3'b110) begin
                    assign {RDATA_B2, RDATA_B1} = rd_data;
                end else if (RMODE_B1_i == 3'b010) begin
                    assign {RDATA_B2, RDATA_B1} = {{18{1'bx}}, rd_data};
                end else if (RMODE_B1_i == 3'b100) begin
                    assign {RDATA_B2, RDATA_B1} = {{19{1'bx}}, rd_data[8], {8{1'bx}}, rd_data[7:0]};
                end

                FIFO36K #(
                    .DATA_WRITE_WIDTH(data_width_write),
                    .DATA_READ_WIDTH(data_width_read),
                    .FIFO_TYPE(fifo_type),
                    .PROG_FULL_THRESH(UPAF1_i),
                    .PROG_EMPTY_THRESH(UPAE1_i)
                ) FIFO36K (
                    .WR_DATA(wr_data),
                    .RD_DATA(rd_data),
                    .EMPTY(RDATA_A1[7]),
                    .FULL(RDATA_A1[3]),
                    .OVERFLOW(RDATA_A1[0]),
                    .UNDERFLOW(RDATA_A1[4]),
                    .RD_EN(REN_B1),
                    .WR_EN(WEN_A1),
                    .ALMOST_EMPTY(RDATA_A1[6]),
                    .ALMOST_FULL(RDATA_A1[2]),
                    .PROG_EMPTY(RDATA_A1[5]),
                    .PROG_FULL(RDATA_A1[1]),
                    .WR_CLK(CLK_A1),
                    .RD_CLK(CLK_B1),
                    .RESET(FLUSH1)
                );
            end else begin
                // Internal Write
                wire [31:0] WDATA_A;
                wire [31:0] WDATA_B;
                wire [3:0] WPARITY_A;
                wire [3:0] WPARITY_B;

                // Internal Read
                wire [31:0] RDATA_A;
                wire [31:0] RDATA_B;
                wire [3:0] RPARITY_A;
                wire [3:0] RPARITY_B;

                // Modes Mapping
                localparam write_mode_A =   MODE_BITS[7:9]   == 3'b110  ? 36 : 
                                            MODE_BITS[7:9]   == 3'b010  ? 18 : 
                                            MODE_BITS[7:9]   == 3'b100  ? 9  :
                                            MODE_BITS[7:9]   == 3'b001  ? 4  :
                                            MODE_BITS[7:9]   == 3'b011  ? 2  : 1 ;

                localparam read_mode_A  =   MODE_BITS[1:3]   == 3'b110  ? 36 : 
                                            MODE_BITS[1:3]   == 3'b010  ? 18 : 
                                            MODE_BITS[1:3]   == 3'b100  ? 9  :
                                            MODE_BITS[1:3]   == 3'b001  ? 4  :
                                            MODE_BITS[1:3]   == 3'b011  ? 2  : 1 ;

                localparam write_mode_B =   MODE_BITS[10:12] == 3'b110  ? 36 : 
                                            MODE_BITS[10:12] == 3'b010  ? 18 : 
                                            MODE_BITS[10:12] == 3'b100  ? 9  :
                                            MODE_BITS[10:12] == 3'b001  ? 4  :
                                            MODE_BITS[10:12] == 3'b011  ? 2  : 1 ;

                localparam read_mode_B  =   MODE_BITS[4:6]   == 3'b110  ? 36 : 
                                            MODE_BITS[4:6]   == 3'b010  ? 18 : 
                                            MODE_BITS[4:6]   == 3'b100  ? 9  :
                                            MODE_BITS[4:6]   == 3'b001  ? 4  :
                                            MODE_BITS[4:6]   == 3'b011  ? 2  : 1 ;

                // Write Data Port A
                assign WDATA_A   = {WDATA_A2[15:0],  WDATA_A1[15:0]};
                assign WPARITY_A = {WDATA_A2[17:16], WDATA_A1[17:16]};

                // Write Data Port B
                assign WDATA_B   = {WDATA_B2[15:0],  WDATA_B1[15:0]};
                assign WPARITY_B = {WDATA_B2[17:16], WDATA_B1[17:16]};

                // Read Data Port A
                assign RDATA_A1   = {RPARITY_A[1:0], RDATA_A[15:0]};
                assign RDATA_A2   = {RPARITY_A[3:2], RDATA_A[31:16]};

                // Read Data Port B
                assign RDATA_B1   = {RPARITY_B[1:0], RDATA_B[15:0]};
                assign RDATA_B2   = {RPARITY_B[3:2], RDATA_B[31:16]};

                // New Model TDP_RAM36K
                TDP_RAM36K #(
                    .INIT(data_i),                  // Initial Contents of data memory
                    .INIT_PARITY(pairty_i),         // Initial Contents of parity memory
                    .WRITE_WIDTH_A(write_mode_A),   // Write data width on port A 
                    .WRITE_WIDTH_B(write_mode_B),   // Write data width on port B 
                    .READ_WIDTH_A(read_mode_A),     // Read data width on port A 
                    .READ_WIDTH_B(read_mode_B)      // Read data width on port B 
                ) 
                tdp_ram36k_inst
                (
                    // Ports
                    .WEN_A(WEN_A1),             // Write-enable port A
                    .WEN_B(WEN_B1),             // Write-enable port B
                    .REN_A(REN_A1),             // Read-enable port A
                    .REN_B(REN_B1),             // Read-enable port B
                    .CLK_A(CLK_A1),             // Clock port A
                    .CLK_B(CLK_B1),             // Clock port B
                    .BE_A({BE_A2, BE_A1}),      // Byte-write enable port A
                    .BE_B({BE_B2, BE_B1}),      // Byte-write enable port B
                    .ADDR_A(ADDR_A1),           // Address port A
                    .ADDR_B(ADDR_B1),           // Address port B
                    .WDATA_A(WDATA_A),          // Write data port A
                    .WPARITY_A(WPARITY_A),      // Write parity port A
                    .WDATA_B(WDATA_B),          // Write data port B
                    .WPARITY_B(WPARITY_B),      // Write parity port B
                    .RDATA_A(RDATA_A[31:0]),    // Read data port A
                    .RPARITY_A(RPARITY_A[3:0]), // Read parity port A
                    .RDATA_B(RDATA_B[31:0]),    // Read data port B
                    .RPARITY_B(RPARITY_B[3:0])  // Read parity port B
                );

                initial 
                begin
                    // write data mode for Port A
                    case (write_mode_A)
                        36,
                        18,
                        9,
                        4,
                        2,
                        1
                        : begin end
                        default: begin
                            $error("Invalid write_mode_A %0d\n", write_mode_A);
                            $finish;
                        end
                    endcase

                    // read data mode for Port A
                    case (read_mode_A)
                        36,
                        18,
                        9,
                        4,
                        2,
                        1
                        : begin end
                        default: begin
                            $error("Invalid read_mode_A %0d\n", read_mode_A);
                            $finish;
                        end
                    endcase

                    // write data mode for Port B
                    case (write_mode_B)
                        36,
                        18,
                        9,
                        4,
                        2,
                        1
                        : begin end
                        default: begin
                            $error("Invalid write_mode_B %0d\n", write_mode_B);
                            $finish;
                        end
                    endcase

                    // read data mode for Port B
                    case (read_mode_B)
                        36,
                        18,
                        9,
                        4,
                        2,
                        1
                        : begin end
                        default: begin
                            $error("Invalid read_mode_B %0d\n", read_mode_B);
                            $finish;
                        end
                    endcase
                end
            end

        end else begin 
            if (FMODE1_i == 1'b1 || FMODE2_i == 1'b1) begin    // FIFO18KX2

                initial begin
                    if (!(WMODE_A1_i == 3'b010 || WMODE_A1_i == 3'b100)) begin
                       $display("RS_TDP36K instance %m WMODE_A1_i set to incorrect value, %d.  Values must be either 3'b110, 3'b010 or 3'b110", WMODE_A1_i);
                    #1 $stop;
                    end
                    if (!(RMODE_B1_i == 3'b010 || RMODE_B1_i == 3'b100)) begin
                       $display("RS_TDP36K instance %m RMODE_B1_i set to incorrect value, %d.  Values must be either 3'b110, 3'b010 or 3'b110", RMODE_B1_i);
                    #1 $stop;
                    end
                    if (!(WMODE_A2_i == 3'b010 || WMODE_A2_i == 3'b100)) begin
                       $display("RS_TDP36K instance %m WMODE_A2_i set to incorrect value, %d.  Values must be either 3'b110, 3'b010 or 3'b110", WMODE_A2_i);
                    #1 $stop;
                    end
                    if (!(RMODE_B2_i == 3'b010 || RMODE_B2_i == 3'b100)) begin
                       $display("RS_TDP36K instance %m RMODE_B2_i set to incorrect value, %d.  Values must be either 3'b110, 3'b010 or 3'b110", RMODE_B2_i);
                    #1 $stop;
                    end
                end

                localparam data_width_write1 = (WMODE_A1_i == 3'b010) ? 5'b10010 : 4'b1001;
                localparam data_width_read1 =  (RMODE_B1_i == 3'b010) ? 5'b10010 : 4'b1001;
                localparam data_width_write2 = (WMODE_A2_i == 3'b010) ? 5'b10010 : 4'b1001;
                localparam data_width_read2 =  (RMODE_B2_i == 3'b010) ? 5'b10010 : 4'b1001;
                localparam fifo_type1   = (SYNC_FIFO1_i == 1'b1) ? "SYNCHRONOUS" : "ASYNCHRONOUS";
                localparam fifo_type2   = (SYNC_FIFO2_i == 1'b1) ? "SYNCHRONOUS" : "ASYNCHRONOUS"; 

                wire [data_width_write1 - 1:0] wr_data1;
                if (WMODE_A1_i == 3'b010) begin
                    assign wr_data1 = WDATA_A1;
                end else if (WMODE_A1_i == 3'b100) begin
                    assign wr_data1 = {WDATA_A1[16], WDATA_A1[7:0]};
                end

                wire [data_width_read1 - 1:0] rd_data1;
                if (RMODE_B1_i == 3'b010) begin
                    assign RDATA_B1 = rd_data1;
                end else if (RMODE_B1_i == 3'b100) begin
                    assign RDATA_B1 = {1'bx, rd_data1[8], {8{1'bx}}, rd_data1[7:0]};
                end

                wire [data_width_write2 - 1:0] wr_data2;
                if (WMODE_A2_i == 3'b010) begin
                    assign wr_data2 = WDATA_A2;
                end else if (WMODE_A2_i == 3'b100) begin
                    assign wr_data2 = {WDATA_A2[16], WDATA_A2[7:0]};
                end
                wire [data_width_read2 - 1:0] rd_data2;
                if (RMODE_B2_i == 3'b010) begin
                    assign RDATA_B2 = rd_data2;
                end else if (RMODE_B2_i == 3'b100) begin
                    assign RDATA_B2 = {1'bx, rd_data2[8], {8{1'bx}}, rd_data2[7:0]};

                end

                FIFO18KX2 #(
                    .DATA_WRITE_WIDTH1(data_width_write1),
                    .DATA_READ_WIDTH1(data_width_read1),
                    .FIFO_TYPE1(fifo_type1),
                    .PROG_FULL_THRESH1(UPAF1_i),
                    .PROG_EMPTY_THRESH1(UPAE1_i),
                    .DATA_WRITE_WIDTH2(data_width_write2),
                    .DATA_READ_WIDTH2(data_width_read2),
                    .FIFO_TYPE2(fifo_type2),
                    .PROG_FULL_THRESH2(UPAF2_i),
                    .PROG_EMPTY_THRESH2(UPAE2_i)
                ) FIFO18KX2 (
                    .WR_DATA1(wr_data1),
                    .RD_DATA1(rd_data1),
                    .EMPTY1(RDATA_A1[7]),
                    .FULL1(RDATA_A1[3]),
                    .OVERFLOW1(RDATA_A1[0]),
                    .UNDERFLOW1(RDATA_A1[4]),
                    .RD_EN1(REN_B1),
                    .WR_EN1(WEN_A1),
                    .ALMOST_EMPTY1(RDATA_A1[6]),
                    .ALMOST_FULL1(RDATA_A1[2]),
                    .PROG_EMPTY1(RDATA_A1[5]),
                    .PROG_FULL1(RDATA_A1[1]),
                    .WR_CLK1(CLK_A1),
                    .RD_CLK1(CLK_B1),
                    .RESET1(FLUSH1),
                    .WR_DATA2(wr_data2),
                    .RD_DATA2(rd_data2),
                    .EMPTY2(RDATA_A2[7]),
                    .FULL2(RDATA_A2[3]),
                    .OVERFLOW2(RDATA_A2[0]),
                    .UNDERFLOW2(RDATA_A2[4]),
                    .RD_EN2(REN_B2),
                    .WR_EN2(WEN_A2),
                    .ALMOST_EMPTY2(RDATA_A2[6]),
                    .ALMOST_FULL2(RDATA_A2[2]),
                    .PROG_EMPTY2(RDATA_A2[5]),
                    .PROG_FULL2(RDATA_A2[1]),
                    .WR_CLK2(CLK_A2),
                    .RD_CLK2(CLK_B2),
                    .RESET2(FLUSH2)
                );
            end
            else if (FMODE1_i == 1'b0 || FMODE2_i == 1'b0) begin
                // Internal Write Port-1
                wire [31:0] WDATA_A11;
                wire [3:0] WPARITY_A11;
                wire [31:0] WDATA_B11;
                wire [3:0] WPARITY_B11;

                // Internal Read Port-1
                wire [31:0] RDATA_A11;
                wire [3:0] RPARITY_A11;
                wire [31:0] RDATA_B11;
                wire [3:0] RPARITY_B11;

                // Internal Write Port-2
                wire [31:0] WDATA_A22;
                wire [3:0] WPARITY_A22;
                wire [31:0] WDATA_B22;
                wire [3:0] WPARITY_B22;

                // Internal Read Port-2
                wire [31:0] RDATA_A22;
                wire [3:0] RPARITY_A22;
                wire [31:0] RDATA_B22;
                wire [3:0] RPARITY_B22;

                // Modes Mapping Port-1
                localparam write_mode_A1 =  MODE_BITS[7:9]   == 3'b010  ? 18 : 
                                            MODE_BITS[7:9]   == 3'b100  ? 9  :
                                            MODE_BITS[7:9]   == 3'b001  ? 4  :
                                            MODE_BITS[7:9]   == 3'b011  ? 2  : 1 ;

                localparam read_mode_A1  =  MODE_BITS[1:3]   == 3'b010  ? 18 : 
                                            MODE_BITS[1:3]   == 3'b100  ? 9  :
                                            MODE_BITS[1:3]   == 3'b001  ? 4  :
                                            MODE_BITS[1:3]   == 3'b011  ? 2  : 1 ;

                localparam write_mode_B1 =  MODE_BITS[10:12] == 3'b010  ? 18 : 
                                            MODE_BITS[10:12] == 3'b100  ? 9  :
                                            MODE_BITS[10:12] == 3'b001  ? 4  :
                                            MODE_BITS[10:12] == 3'b011  ? 2  : 1 ;

                localparam read_mode_B1  =  MODE_BITS[4:6]   == 3'b010  ? 18 : 
                                            MODE_BITS[4:6]   == 3'b100  ? 9  :
                                            MODE_BITS[4:6]   == 3'b001  ? 4  :
                                            MODE_BITS[4:6]   == 3'b011  ? 2  : 1 ;

                // Modes Mapping Port-2
                localparam write_mode_A2 =  MODE_BITS[48:50] == 3'b010  ? 18 : 
                                            MODE_BITS[48:50] == 3'b100  ? 9  :
                                            MODE_BITS[48:50] == 3'b001  ? 4  :
                                            MODE_BITS[48:50] == 3'b011  ? 2  : 1 ;

                localparam read_mode_A2  =  MODE_BITS[42:44] == 3'b010  ? 18 : 
                                            MODE_BITS[42:44] == 3'b100  ? 9  :
                                            MODE_BITS[42:44] == 3'b001  ? 4  :
                                            MODE_BITS[42:44] == 3'b011  ? 2  : 1 ;

                localparam write_mode_B2 =  MODE_BITS[51:53] == 3'b010  ? 18 : 
                                            MODE_BITS[51:53] == 3'b100  ? 9  :
                                            MODE_BITS[51:53] == 3'b001  ? 4  :
                                            MODE_BITS[51:53] == 3'b011  ? 2  : 1 ;

                localparam read_mode_B2  =  MODE_BITS[45:47] == 3'b010  ? 18 : 
                                            MODE_BITS[45:47] == 3'b100  ? 9  :
                                            MODE_BITS[45:47] == 3'b001  ? 4  :
                                            MODE_BITS[45:47] == 3'b011  ? 2  : 1 ;

                // Write Data Port-1
                assign WDATA_A11   = WDATA_A1[15:0];
                assign WPARITY_A11 = WDATA_A1[17:16];

                // Write Data Port-1
                assign WDATA_B11   = WDATA_B1[15:0];
                assign WPARITY_B11 = WDATA_B1[17:16];

                // Read Data Port-1
                assign RDATA_A1   = {RPARITY_A11[1:0], RDATA_A11[15:0]};

                // Read Data Port-1
                assign RDATA_B1   = {RPARITY_B11[1:0], RDATA_B11[15:0]};

                // Write Data Port-2
                assign WDATA_A22   = WDATA_A2[15:0];
                assign WPARITY_A22 = WDATA_A2[17:16];

                // Write Data Port-2
                assign WDATA_B22   = WDATA_B2[15:0];
                assign WPARITY_B22 = WDATA_B2[17:16];

                // Read Data Port-2
                assign RDATA_A2   = {RPARITY_A22[1:0], RDATA_A22[15:0]};

                // Read Data Port-2
                assign RDATA_B2   = {RPARITY_B22[1:0], RDATA_B22[15:0]};

                // New Model TDP_RAM18KX2
                TDP_RAM18KX2 # (
                    .INIT1(data_i1),                // Initial Contents of data memory, RAM 1
                    .INIT1_PARITY(pairty_i1),       // Initial Contents of parity memory, RAM 1
                    .WRITE_WIDTH_A1(write_mode_A1), // Write data width on port A, RAM 1 
                    .WRITE_WIDTH_B1(write_mode_B1), // Write data width on port B, RAM 1 
                    .READ_WIDTH_A1(read_mode_A1),   // Read data width on port A, RAM 1 
                    .READ_WIDTH_B1(read_mode_B1),   // Read data width on port B, RAM 1 
                    .INIT2(data_i2),                // Initial Contents of memory, RAM 2
                    .INIT2_PARITY(pairty_i2),       // Initial Contents of memory, RAM 2
                    .WRITE_WIDTH_A2(write_mode_A2), // Write data width on port A, RAM 2
                    .WRITE_WIDTH_B2(write_mode_B2), // Write data width on port B, RAM 2
                    .READ_WIDTH_A2(read_mode_A2),   // Read data width on port A, RAM 2
                    .READ_WIDTH_B2(read_mode_B2)    // Read data width on port B, RAM 2
                )
                TDP_RAM18KX2_inst (
                    .WEN_A1(WEN_A1),            // Write-enable port A, RAM 1
                    .WEN_B1(WEN_B1),            // Write-enable port B, RAM 1
                    .REN_A1(REN_A1),            // Read-enable port A, RAM 1
                    .REN_B1(REN_B1),            // Read-enable port B, RAM 1
                    .CLK_A1(CLK_A1),            // Clock port A, RAM 1
                    .CLK_B1(CLK_B1),            // Clock port B, RAM 1
                    .BE_A1(BE_A1),              // Byte-write enable port A, RAM 1
                    .BE_B1(BE_B1),              // Byte-write enable port B, RAM 1
                    .ADDR_A1(ADDR_A1),          // Address port A, RAM 1
                    .ADDR_B1(ADDR_B1),          // Address port B, RAM 1
                    .WDATA_A1(WDATA_A11),       // Write data port A, RAM 1
                    .WPARITY_A1(WPARITY_A11),   // Write parity port A, RAM 1
                    .WDATA_B1(WDATA_B11),       // Write data port B, RAM 1
                    .WPARITY_B1(WPARITY_B11),   // Write parity port B, RAM 1
                    .RDATA_A1(RDATA_A11),       // Read data port A, RAM 1
                    .RPARITY_A1(RPARITY_A11),   // Read parity port A, RAM 1
                    .RDATA_B1(RDATA_B11),       // Read data port B, RAM 1
                    .RPARITY_B1(RPARITY_B11),   // Read parity port B, RAM 1
                    .WEN_A2(WEN_A2),            // Write-enable port A, RAM 2
                    .WEN_B2(WEN_B2),            // Write-enable port B, RAM 2
                    .REN_A2(REN_A2),            // Read-enable port A, RAM 2
                    .REN_B2(REN_B2),            // Read-enable port B, RAM 2
                    .CLK_A2(CLK_A2),            // Clock port A, RAM 2
                    .CLK_B2(CLK_B2),            // Clock port B, RAM 2
                    .BE_A2(BE_A2),              // Byte-write enable port A, RAM 2
                    .BE_B2(BE_B2),              // Byte-write enable port B, RAM 2
                    .ADDR_A2(ADDR_A2),          // Address port A, RAM 2
                    .ADDR_B2(ADDR_B2),          // Address port B, RAM 2
                    .WDATA_A2(WDATA_A22),       // Write data port A, RAM 2
                    .WPARITY_A2(WPARITY_A22),   // Write parity port A, RAM 2
                    .WDATA_B2(WDATA_B22),       // Write data port B, RAM 2
                    .WPARITY_B2(WPARITY_B22),   // Write parity port B, RAM 2
                    .RDATA_A2(RDATA_A22),       // Read data port A, RAM 2
                    .RPARITY_A2(RPARITY_A22),   // Read parity port A, RAM 2
                    .RDATA_B2(RDATA_B22),       // Read data port B, RAM 2
                    .RPARITY_B2(RPARITY_B22)    // Read parity port B, RAM 2
                );

                initial begin
                    // write data mode for Port-1
                    case (write_mode_A1)
                        18,
                        9,
                        4,
                        2,
                        1
                        : begin end
                        default: begin
                            $error("Invalid write_mode_A1 %0d\n", write_mode_A1);
                            $finish;
                        end
                    endcase

                    // read data mode for Port-1
                    case (read_mode_A1)
                        18,
                        9,
                        4,
                        2,
                        1
                        : begin end
                        default: begin
                            $error("Invalid read_mode_A1 %0d\n", read_mode_A1);
                            $finish;
                        end
                    endcase

                    // write data mode for Port-1
                    case (write_mode_B1)
                        18,
                        9,
                        4,
                        2,
                        1
                        : begin end
                        default: begin
                            $error("Invalid write_mode_B1 %0d\n", write_mode_B1);
                            $finish;
                        end
                    endcase

                    // read data mode for Port-1
                    case (read_mode_B1)
                        18,
                        9,
                        4,
                        2,
                        1
                        : begin end
                        default: begin
                            $error("Invalid read_mode_B1 %0d\n", read_mode_B1);
                            $finish;
                        end
                    endcase

                    // write data mode for Port-2
                    case (write_mode_A2)
                        18,
                        9,
                        4,
                        2,
                        1
                        : begin end
                        default: begin
                            $error("Invalid write_mode_A2 %0d\n", write_mode_A2);
                            $finish;
                        end
                    endcase

                    // read data mode for Port-2
                    case (read_mode_A2)
                        18,
                        9,
                        4,
                        2,
                        1
                        : begin end
                        default: begin
                            $error("Invalid read_mode_A2 %0d\n", read_mode_A2);
                            $finish;
                        end
                    endcase

                    // write data mode for Port-2
                    case (write_mode_B2)
                        18,
                        9,
                        4,
                        2,
                        1
                        : begin end
                        default: begin
                            $error("Invalid write_mode_B2 %0d\n", write_mode_B2);
                            $finish;
                        end
                    endcase

                    // read data mode for Port-2
                    case (read_mode_B2)
                        18,
                        9,
                        4,
                        2,
                        1
                        : begin end
                        default: begin
                            $error("Invalid read_mode_B2 %0d\n", read_mode_B2);
                            $finish;
                        end
                    endcase
                end
            end
            else if (FMODE1_i == 1'b1 || FMODE2_i == 1'b0) begin
                initial begin
                    if (!(WMODE_A1_i == 3'b010 || WMODE_A1_i == 3'b100)) begin
                       $display("RS_TDP36K instance %m WMODE_A1_i set to incorrect value, %d.  Values must be either 3'b110, 3'b010 or 3'b110", WMODE_A1_i);
                    #1 $stop;
                    end
                    if (!(RMODE_B1_i == 3'b010 || RMODE_B1_i == 3'b100)) begin
                       $display("RS_TDP36K instance %m RMODE_B1_i set to incorrect value, %d.  Values must be either 3'b110, 3'b010 or 3'b110", RMODE_B1_i);
                    #1 $stop;
                    end
                end

                localparam data_width_write1 = (WMODE_A1_i == 3'b010) ? 5'b10010 : 4'b1001;
                localparam data_width_read1 =  (RMODE_B1_i == 3'b010) ? 5'b10010 : 4'b1001;
                localparam fifo_type1   = (SYNC_FIFO1_i == 1'b1) ? "SYNCHRONOUS" : "ASYNCHRONOUS";

                wire [data_width_write1 - 1:0] wr_data1;
                if (WMODE_A1_i == 3'b010) begin
                    assign wr_data1 = WDATA_A1;
                end else if (WMODE_A1_i == 3'b100) begin
                    assign wr_data1 = {WDATA_A1[16], WDATA_A1[7:0]};
                end

                wire [data_width_read1 - 1:0] rd_data1;
                if (RMODE_B1_i == 3'b010) begin
                    assign RDATA_B1 = rd_data1;
                end else if (RMODE_B1_i == 3'b100) begin
                    assign RDATA_B1 = {1'bx, rd_data1[8], {8{1'bx}}, rd_data1[7:0]};
                end

                FIFO18KX2 #(
                    .DATA_WRITE_WIDTH1(data_width_write1),
                    .DATA_READ_WIDTH1(data_width_read1),
                    .FIFO_TYPE1(fifo_type1),
                    .PROG_FULL_THRESH1(UPAF1_i),
                    .PROG_EMPTY_THRESH1(UPAE1_i)
                ) FIFO18KX2 (
                    .WR_DATA1(wr_data1),
                    .RD_DATA1(rd_data1),
                    .EMPTY1(RDATA_A1[7]),
                    .FULL1(RDATA_A1[3]),
                    .OVERFLOW1(RDATA_A1[0]),
                    .UNDERFLOW1(RDATA_A1[4]),
                    .RD_EN1(REN_B1),
                    .WR_EN1(WEN_A1),
                    .ALMOST_EMPTY1(RDATA_A1[6]),
                    .ALMOST_FULL1(RDATA_A1[2]),
                    .PROG_EMPTY1(RDATA_A1[5]),
                    .PROG_FULL1(RDATA_A1[1]),
                    .WR_CLK1(CLK_A1),
                    .RD_CLK1(CLK_B1),
                    .RESET1(FLUSH1)
                );

                // Internal Write Port-2
                wire [31:0] WDATA_A22;
                wire [3:0] WPARITY_A22;
                wire [31:0] WDATA_B22;
                wire [3:0] WPARITY_B22;

                // Internal Read Port-2
                wire [31:0] RDATA_A22;
                wire [3:0] RPARITY_A22;
                wire [31:0] RDATA_B22;
                wire [3:0] RPARITY_B22;

                // Modes Mapping Port-2
                localparam write_mode_A2 =  MODE_BITS[48:50] == 3'b010  ? 18 : 
                                            MODE_BITS[48:50] == 3'b100  ? 9  :
                                            MODE_BITS[48:50] == 3'b001  ? 4  :
                                            MODE_BITS[48:50] == 3'b011  ? 2  : 1 ;

                localparam read_mode_A2  =  MODE_BITS[42:44] == 3'b010  ? 18 : 
                                            MODE_BITS[42:44] == 3'b100  ? 9  :
                                            MODE_BITS[42:44] == 3'b001  ? 4  :
                                            MODE_BITS[42:44] == 3'b011  ? 2  : 1 ;

                localparam write_mode_B2 =  MODE_BITS[51:53] == 3'b010  ? 18 : 
                                            MODE_BITS[51:53] == 3'b100  ? 9  :
                                            MODE_BITS[51:53] == 3'b001  ? 4  :
                                            MODE_BITS[51:53] == 3'b011  ? 2  : 1 ;

                localparam read_mode_B2  =  MODE_BITS[45:47] == 3'b010  ? 18 : 
                                            MODE_BITS[45:47] == 3'b100  ? 9  :
                                            MODE_BITS[45:47] == 3'b001  ? 4  :
                                            MODE_BITS[45:47] == 3'b011  ? 2  : 1 ;
                
                // Write Data Port-2
                assign WDATA_A22   = WDATA_A2[15:0];
                assign WPARITY_A22 = WDATA_A2[17:16];

                // Write Data Port-2
                assign WDATA_B22   = WDATA_B2[15:0];
                assign WPARITY_B22 = WDATA_B2[17:16];

                // Read Data Port-2
                assign RDATA_A2   = {RPARITY_A22[1:0], RDATA_A22[15:0]};

                // Read Data Port-2
                assign RDATA_B2   = {RPARITY_B22[1:0], RDATA_B22[15:0]};

                // New Model TDP_RAM18KX2
                TDP_RAM18KX2 # (
                    .INIT2(data_i2),                       // Initial Contents of memory, RAM 2
                    .INIT2_PARITY(pairty_i2),                // Initial Contents of memory, RAM 2
                    .WRITE_WIDTH_A2(write_mode_A2), // Write data width on port A, RAM 2
                    .WRITE_WIDTH_B2(write_mode_B2), // Write data width on port B, RAM 2
                    .READ_WIDTH_A2(read_mode_A2),   // Read data width on port A, RAM 2
                    .READ_WIDTH_B2(read_mode_B2)    // Read data width on port B, RAM 2
                )
                TDP_RAM18KX2_inst (
                    .WEN_A2(WEN_A2),            // Write-enable port A, RAM 2
                    .WEN_B2(WEN_B2),            // Write-enable port B, RAM 2
                    .REN_A2(REN_A2),            // Read-enable port A, RAM 2
                    .REN_B2(REN_B2),            // Read-enable port B, RAM 2
                    .CLK_A2(CLK_A2),            // Clock port A, RAM 2
                    .CLK_B2(CLK_B2),            // Clock port B, RAM 2
                    .BE_A2(BE_A2),              // Byte-write enable port A, RAM 2
                    .BE_B2(BE_B2),              // Byte-write enable port B, RAM 2
                    .ADDR_A2(ADDR_A2),          // Address port A, RAM 2
                    .ADDR_B2(ADDR_B2),          // Address port B, RAM 2
                    .WDATA_A2(WDATA_A22),       // Write data port A, RAM 2
                    .WPARITY_A2(WPARITY_A22),   // Write parity port A, RAM 2
                    .WDATA_B2(WDATA_B22),       // Write data port B, RAM 2
                    .WPARITY_B2(WPARITY_B22),   // Write parity port B, RAM 2
                    .RDATA_A2(RDATA_A22),       // Read data port A, RAM 2
                    .RPARITY_A2(RPARITY_A22),   // Read parity port A, RAM 2
                    .RDATA_B2(RDATA_B22),       // Read data port B, RAM 2
                    .RPARITY_B2(RPARITY_B22)    // Read parity port B, RAM 2
                );

                initial begin
                    // write data mode for Port-2
                    case (write_mode_A2)
                        18,
                        9,
                        4,
                        2,
                        1
                        : begin end
                        default: begin
                            $error("Invalid write_mode_A2 %0d\n", write_mode_A2);
                            $finish;
                        end
                    endcase

                    // read data mode for Port-2
                    case (read_mode_A2)
                        18,
                        9,
                        4,
                        2,
                        1
                        : begin end
                        default: begin
                            $error("Invalid read_mode_A2 %0d\n", read_mode_A2);
                            $finish;
                        end
                    endcase

                    // write data mode for Port-2
                    case (write_mode_B2)
                        18,
                        9,
                        4,
                        2,
                        1
                        : begin end
                        default: begin
                            $error("Invalid write_mode_B2 %0d\n", write_mode_B2);
                            $finish;
                        end
                    endcase

                    // read data mode for Port-2
                    case (read_mode_B2)
                        18,
                        9,
                        4,
                        2,
                        1
                        : begin end
                        default: begin
                            $error("Invalid read_mode_B2 %0d\n", read_mode_B2);
                            $finish;
                        end
                    endcase
                end
            end
            else if (FMODE1_i == 1'b0 || FMODE2_i == 1'b1) begin
                // Internal Write Port-1
                wire [31:0] WDATA_A11;
                wire [3:0] WPARITY_A11;
                wire [31:0] WDATA_B11;
                wire [3:0] WPARITY_B11;

                // Internal Read Port-1
                wire [31:0] RDATA_A11;
                wire [3:0] RPARITY_A11;
                wire [31:0] RDATA_B11;
                wire [3:0] RPARITY_B11;

                // Modes Mapping Port-1
                localparam write_mode_A1 =  MODE_BITS[7:9]   == 3'b010  ? 18 : 
                                            MODE_BITS[7:9]   == 3'b100  ? 9  :
                                            MODE_BITS[7:9]   == 3'b001  ? 4  :
                                            MODE_BITS[7:9]   == 3'b011  ? 2  : 1 ;

                localparam read_mode_A1  =  MODE_BITS[1:3]   == 3'b010  ? 18 : 
                                            MODE_BITS[1:3]   == 3'b100  ? 9  :
                                            MODE_BITS[1:3]   == 3'b001  ? 4  :
                                            MODE_BITS[1:3]   == 3'b011  ? 2  : 1 ;

                localparam write_mode_B1 =  MODE_BITS[10:12] == 3'b010  ? 18 : 
                                            MODE_BITS[10:12] == 3'b100  ? 9  :
                                            MODE_BITS[10:12] == 3'b001  ? 4  :
                                            MODE_BITS[10:12] == 3'b011  ? 2  : 1 ;

                localparam read_mode_B1  =  MODE_BITS[4:6]   == 3'b010  ? 18 : 
                                            MODE_BITS[4:6]   == 3'b100  ? 9  :
                                            MODE_BITS[4:6]   == 3'b001  ? 4  :
                                            MODE_BITS[4:6]   == 3'b011  ? 2  : 1 ;
                
                // Write Data Port-1
                assign WDATA_A11   = WDATA_A1[15:0];
                assign WPARITY_A11 = WDATA_A1[17:16];

                // Write Data Port-1
                assign WDATA_B11   = WDATA_B1[15:0];
                assign WPARITY_B11 = WDATA_B1[17:16];

                // Read Data Port-1
                assign RDATA_A1   = {RPARITY_A11[1:0], RDATA_A11[15:0]};

                // Read Data Port-1
                assign RDATA_B1   = {RPARITY_B11[1:0], RDATA_B11[15:0]};

                // New Model TDP_RAM18KX2
                TDP_RAM18KX2 # (
                    .INIT1(data_i1),                       // Initial Contents of data memory, RAM 1
                    .INIT1_PARITY(pairty_i1),                // Initial Contents of parity memory, RAM 1
                    .WRITE_WIDTH_A1(write_mode_A1), // Write data width on port A, RAM 1
                    .WRITE_WIDTH_B1(write_mode_B1), // Write data width on port B, RAM 1
                    .READ_WIDTH_A1(read_mode_A1),   // Read data width on port A, RAM 1
                    .READ_WIDTH_B1(read_mode_B1)   // Read data width on port B, RAM 1
                )
                TDP_RAM18KX2_inst (
                    .WEN_A1(WEN_A1),            // Write-enable port A, RAM 1
                    .WEN_B1(WEN_B1),            // Write-enable port B, RAM 1
                    .REN_A1(REN_A1),            // Read-enable port A, RAM 1
                    .REN_B1(REN_B1),            // Read-enable port B, RAM 1
                    .CLK_A1(CLK_A1),            // Clock port A, RAM 1
                    .CLK_B1(CLK_B1),            // Clock port B, RAM 1
                    .BE_A1(BE_A1),              // Byte-write enable port A, RAM 1
                    .BE_B1(BE_B1),              // Byte-write enable port B, RAM 1
                    .ADDR_A1(ADDR_A1),          // Address port A, RAM 1
                    .ADDR_B1(ADDR_B1),          // Address port B, RAM 1
                    .WDATA_A1(WDATA_A11),       // Write data port A, RAM 1
                    .WPARITY_A1(WPARITY_A11),   // Write parity port A, RAM 1
                    .WDATA_B1(WDATA_B11),       // Write data port B, RAM 1
                    .WPARITY_B1(WPARITY_B11),   // Write parity port B, RAM 1
                    .RDATA_A1(RDATA_A11),       // Read data port A, RAM 1
                    .RPARITY_A1(RPARITY_A11),   // Read parity port A, RAM 1
                    .RDATA_B1(RDATA_B11),       // Read data port B, RAM 1
                    .RPARITY_B1(RPARITY_B11)   // Read parity port B, RAM 1
                );
                initial begin
                    // write data mode for Port-1
                    case (write_mode_A1)
                        18,
                        9,
                        4,
                        2,
                        1
                        : begin end
                        default: begin
                            $error("Invalid write_mode_A1 %0d\n", write_mode_A1);
                            $finish;
                        end
                    endcase

                    // read data mode for Port-1
                    case (read_mode_A1)
                        18,
                        9,
                        4,
                        2,
                        1
                        : begin end
                        default: begin
                            $error("Invalid read_mode_A1 %0d\n", read_mode_A1);
                            $finish;
                        end
                    endcase

                    // write data mode for Port-1
                    case (write_mode_B1)
                        18,
                        9,
                        4,
                        2,
                        1
                        : begin end
                        default: begin
                            $error("Invalid write_mode_B1 %0d\n", write_mode_B1);
                            $finish;
                        end
                    endcase

                    // read data mode for Port-1
                    case (read_mode_B1)
                        18,
                        9,
                        4,
                        2,
                        1
                        : begin end
                        default: begin
                            $error("Invalid read_mode_B1 %0d\n", read_mode_B1);
                            $finish;
                        end
                    endcase
                end

                initial begin
                    if (!(WMODE_A2_i == 3'b010 || WMODE_A2_i == 3'b100)) begin
                       $display("RS_TDP36K instance %m WMODE_A2_i set to incorrect value, %d.  Values must be either 3'b110, 3'b010 or 3'b110", WMODE_A2_i);
                    #1 $stop;
                    end
                    if (!(RMODE_B2_i == 3'b010 || RMODE_B2_i == 3'b100)) begin
                       $display("RS_TDP36K instance %m RMODE_B2_i set to incorrect value, %d.  Values must be either 3'b110, 3'b010 or 3'b110", RMODE_B2_i);
                    #1 $stop;
                    end
                end

                localparam data_width_write2 = (WMODE_A2_i == 3'b010) ? 5'b10010 : 4'b1001;
                localparam data_width_read2 =  (RMODE_B2_i == 3'b010) ? 5'b10010 : 4'b1001;
                localparam fifo_type2   = (SYNC_FIFO2_i == 1'b1) ? "SYNCHRONOUS" : "ASYNCHRONOUS"; 
                
                wire [data_width_write2 - 1:0] wr_data2;
                if (WMODE_A2_i == 3'b010) begin
                    assign wr_data2 = WDATA_A2;
                end else if (WMODE_A2_i == 3'b100) begin
                    assign wr_data2 = {WDATA_A2[16], WDATA_A2[7:0]};
                end
                wire [data_width_read2 - 1:0] rd_data2;
                if (RMODE_B2_i == 3'b010) begin
                    assign RDATA_B2 = rd_data2;
                end else if (RMODE_B2_i == 3'b100) begin
                    assign RDATA_B2 = {1'bx, rd_data2[8], {8{1'bx}}, rd_data2[7:0]};
                end

                FIFO18KX2 #(
                    .DATA_WRITE_WIDTH2(data_width_write2),
                    .DATA_READ_WIDTH2(data_width_read2),
                    .FIFO_TYPE2(fifo_type2),
                    .PROG_FULL_THRESH2(UPAF2_i),
                    .PROG_EMPTY_THRESH2(UPAE2_i)
                ) FIFO18KX2 (
                    .WR_DATA2(wr_data2),
                    .RD_DATA2(rd_data2),
                    .EMPTY2(RDATA_A2[7]),
                    .FULL2(RDATA_A2[3]),
                    .OVERFLOW2(RDATA_A2[0]),
                    .UNDERFLOW2(RDATA_A2[4]),
                    .RD_EN2(REN_B2),
                    .WR_EN2(WEN_A2),
                    .ALMOST_EMPTY2(RDATA_A2[6]),
                    .ALMOST_FULL2(RDATA_A2[2]),
                    .PROG_EMPTY2(RDATA_A2[5]),
                    .PROG_FULL2(RDATA_A2[1]),
                    .WR_CLK2(CLK_A2),
                    .RD_CLK2(CLK_B2),
                    .RESET2(FLUSH2)
                );
            end
        end
    endgenerate
endmodule
