`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:
// Design Name: 
// Module Name: test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module TDP_RAM36K_tb();
reg   [9:0] addr_A, addr_B;
reg   [35:0] din_A;
wire  [35:0] dout_dut, dout_wrap;
reg          clk;
reg          rst;
reg          wen_A;
reg          ren_B;

integer mismatch=0;
reg [6:0]cycle;

on_chip_memory wrapper(
.addr_A(addr_A),
.din_A(din_A),
.addr_B(addr_B),
.wen_A(wen_A),
.ren_B(ren_B),
.dout_B(dout_wrap),
.clk(clk)
);

ram dut (
.addr_A(addr_A),
.din_A(din_A),
.addr_B(addr_B),
.wen_A(wen_A),
.ren_B(ren_B),
.dout_B(dout_dut),
.clk(clk),
.rst(rst)
);

always #(10)   
clk = !clk;

integer i;
initial begin

    {clk, wen_A, ren_B, addr_A ,din_A, cycle, i} = 0;
    rst = 1'b1;
    #20;
    rst = 1'b0;
    repeat (1) @(posedge clk);
    
    // write and simulatnously reads from registered address
    for (i=0; i<= 1023; i=i+1)begin
        repeat (1) @ (posedge clk)
        addr_A <= i; wen_A <=1; ren_B<=0; din_A<= $random;
        cycle = cycle +1;
        // compare(cycle);
    end

    // not writing and reading from the last registered addr_A
    for (i=0; i<=1023; i=i+1)begin
        repeat (1) @ (posedge clk)
        addr_B <= i; wen_A <=0; ren_B<=1; 
        cycle = cycle +1;
        repeat (2) @ (posedge clk)
        compare(cycle);
    end

    // write and simulatnously reads from registered address when wen_A was 1
    for (i=0; i<=1023; i=i+1)begin
        repeat (1) @ (posedge clk)
        addr_A <= i; wen_A <=1; ren_B<=0; din_A<= $random;
        repeat (1) @ (posedge clk)
        addr_B <= i; wen_A <=0; ren_B<=1;
        cycle = cycle +2;
        compare(cycle);
    end

    if(mismatch == 0)
        $display("\n**** All Comparison Matched ***\nSimulation Passed");
    else
        $display("%0d comparison(s) mismatched\nERROR: SIM: Simulation Failed", mismatch);
    
    repeat (9) @(posedge clk); 
    $finish;
    end

    task compare(input integer cycle);
    //$display("\n Comparison at cycle %0d", cycle);
    if(dout_dut !== dout_wrap) begin
        $display("dout_A mismatch. Golden: %0h, Wrapper: %0h, Time: %0t", dout_dut, dout_wrap,$time);
        mismatch = mismatch+1;
    end
    endtask

    initial begin
        `ifdef GATE
            $dumpfile("post_synth.vcd");
        `elsif PNR
            $dumpfile("pnr.vcd");
        `else
            $dumpfile("rtl.vcd");
        `endif
        $dumpvars;
    end

endmodule

module ram (clk,rst, wen_A, ren_B, addr_A,addr_B, din_A, dout_B);
input clk;
input rst;
input wen_A, ren_B;
input [9:0] addr_A, addr_B;
input [35:0] din_A;
output reg [35:0] dout_B;
reg [35:0] RAM [1023:0];
integer i;
always @(posedge clk)
    begin
        if (rst) begin
                dout_B = 35'b0;
            end
        else 
            if (wen_A)
                RAM[addr_A] <= din_A;
            if (ren_B)
                if (wen_A)
                    dout_B <= din_A;
                else
                    dout_B <= RAM[addr_B];
    end

endmodule
