`timescale 1ns/1ps

module tb_sync_split_fifo_R18W18_R9W9;
reg clock0, clock2, clock1, clock3, we1, we2, re1, re2, rst_ptr1, rst_ptr2;
reg [17:0] din1;
reg [8:0] din2;
wire [17:0] dout1, dout12;
wire [8:0] dout2, dout22;
integer mismatch = 0;
wire EMPTY1,EPO1,EWM1,UNDERRUN1,FULL1,FMO1,FWM1,OVERRUN1, EMPTY2,EPO2,EWM2,UNDERRUN2,FULL2,FMO2,FWM2,OVERRUN2;
sync_split_fifo_R18W18_R9W9 u1 (.*);
FIFO18KX2 #(
    .DATA_WRITE_WIDTH1(5'd18),
    .DATA_READ_WIDTH1(5'd18),
    .DATA_WRITE_WIDTH2(5'd9),
    .DATA_READ_WIDTH2(5'd9)
) modelFIFO (
    .RESET1(rst_ptr1),
    .WR_CLK1(clock0),
    .RD_CLK1(clock1),
    .WR_EN1(we1),
    .RD_EN1(re1),
    .WR_DATA1(din1),
    .RD_DATA1(dout12),
    .EMPTY1(),
    .FULL1(),
    .ALMOST_EMPTY1(),
    .ALMOST_FULL1(),
    .PROG_EMPTY1(),
    .PROG_FULL1(),
    .OVERFLOW1(),
    .UNDERFLOW1(),

    .RESET2(rst_ptr2),
    .WR_CLK2(clock0),
    .RD_CLK2(clock1),
    .WR_EN2(we2),
    .RD_EN2(re2),
    .WR_DATA2(din2),
    .RD_DATA2(dout22),
    .EMPTY2(),
    .FULL2(),
    .ALMOST_EMPTY2(),
    .ALMOST_FULL2(),
    .PROG_EMPTY2(),
    .PROG_FULL2(),
    .OVERFLOW2(),
    .UNDERFLOW2()
);

initial begin
    `ifdef GATE
        $dumpfile("synth_R18W18_R9W9.vcd");
    `elsif PNR
        $dumpfile("pnr_R18W18_R9W9.vcd");
    `else
        $dumpfile("rtl_R18W18_R9W9.vcd");
    `endif
    $dumpvars;
end

initial begin
    re1 <= 1'b0;
    re2 <= 1'b0;
    we1 <= 1'b1;
    we2 <= 1'b1;
    for (integer i = 1; i <=50; i = i+1) begin
        din1 <= $random;
        din2 <= $random;
        repeat(1) @ (posedge clock0);
    end
    we1 <= 1'b0;
    we2 <= 1'b0;
    re1 <= 1'b1;
    re2 <= 1'b1;
    for (integer i=1; i<=50; i=i+1) begin
        if (dout1 !== dout12) begin
            $display("DOUT1 mismatch. din1: %0d, dout1: %0d, Entry No.: %0d", dout12, dout1, i);
            mismatch = mismatch+1;
        end 
        if (dout2 !== dout22) begin
            $display("DOUT2 mismatch. din2: %0d, dout2: %0d, Entry No.: %0d", dout22, dout2, i);
            mismatch = mismatch+1;
        end 
        repeat (1) @ (posedge clock0);
    end
    re1 <= 1'b0;
    re2 <= 1'b0;
    if(mismatch == 0)
        $display("\n**** All Comparison Matched ****\n**** Simulation Passed ****");
    else
        $display("%0d comparison(s) mismatched\nERROR: SIM: Simulation Failed", mismatch);
    #500;
    $finish;
end

initial begin
    clock0 = 1'b1;
    forever #5 clock0 = ~clock0;
end
initial begin
    clock2 = 1'b1;
    forever #5 clock2 = ~clock2;
end
initial begin
    clock1 = 1'b1;
    forever #5 clock1 = ~clock1;
end
initial begin
    clock3 = 1'b1;
    forever #5 clock3 = ~clock3;
end
initial begin
    rst_ptr1 = 1'b1;
    # 10;
    rst_ptr1 = 1'b0;
end
initial begin
    rst_ptr2 = 1'b1;
    # 10;
    rst_ptr2 = 1'b0;
end

endmodule
