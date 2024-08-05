`timescale 1ns/1ps

module tb_sync_fifo_R36W36;
reg clock0, clock1, we1, re1, rst_ptr1;
reg [35:0] din1;
wire [35:0] dout1, dout2;
integer mismatch = 0;
wire EMPTY1,EPO1,EWM1,UNDERRUN1,FULL1,FMO1,FWM1,OVERRUN1;
sync_fifo_R36W36 u1 (.*);
FIFO36K #(
    .DATA_WRITE_WIDTH(6'd36),
    .DATA_READ_WIDTH(6'd36)
) modelFIFO (
    .RESET(rst_ptr1),
    .WR_CLK(clock0),
    .RD_CLK(clock1),
    .WR_EN(we1),
    .RD_EN(re1),
    .WR_DATA(din1),
    .RD_DATA(dout2),
    .EMPTY(),
    .FULL(),
    .ALMOST_EMPTY(),
    .ALMOST_FULL(),
    .PROG_EMPTY(),
    .PROG_FULL(),
    .OVERFLOW(),
    .UNDERFLOW()
);

initial begin
    `ifdef GATE
        $dumpfile("synth_R36W36.vcd");
    `elsif PNR
        $dumpfile("pnr_R36W36.vcd");
    `else
        $dumpfile("rtl_R36W36.vcd");
    `endif
    $dumpvars;
end

initial begin
    re1 <= 1'b0;
    we1 <= 1'b1;
    for (integer i = 1; i <=1024; i = i+1) begin
        din1 <= $random;
        repeat(1) @ (posedge clock0);
    end
    we1 <= 1'b0;
    re1 <= 1'b1;
    for (integer i=1; i<=1024; i=i+1) begin
        if (dout1 !== dout2) begin
            $display("DOUT1 mismatch. din1: %0d, dout1: %0d, Entry No.: %0d", dout2, dout1, i);
            mismatch = mismatch+1;
        end
        repeat (1) @ (posedge clock0);
    end
    re1 <= 1'b0;
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
    clock1 = 1'b1;
    forever #5 clock1 = ~clock1;
end

initial begin
    rst_ptr1 = 1'b1;
    # 10;
    rst_ptr1 = 1'b0;
end

endmodule
