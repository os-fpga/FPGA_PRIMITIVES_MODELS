module SOC_FPGA_INTF_AHB_M_tb;

parameter repeat_test=10;

    logic HRESETN_I; 
    logic [31:0] HADDR; 
    logic [2:0] HBURST; 
    logic [3:0] HPROT; 
    logic [2:0] HSIZE; 
    logic [1:0] HTRANS; 
    logic [31:0] HWDATA; 
    logic HWRITE; 
    logic [31:0] HRDATA; 
    logic HREADY; 
    logic HRESP; 
    logic HCLK; 
    
    logic trans_fail;
    logic [31:0] r_data;
    int error;
    enum logic [1:0] {IDLE, BUSY, NONSEQ, SEQ} htrans;
              
    SOC_FPGA_INTF_AHB_M ahb_s(
        .HRESETN_I(HRESETN_I), 
        .HADDR(HADDR), 
        .HBURST(HBURST), 
        .HPROT(HPROT), 
        .HSIZE(HSIZE), 
        .HTRANS(HTRANS), 
        .HWDATA(HWDATA), 
        .HWRITE(HWRITE), 
        .HRDATA(HRDATA), 
        .HREADY(HREADY), 
        .HRESP(HRESP), 
        .HCLK(HCLK) 
    );

    initial begin
        HRESETN_I <= 1'b0;
        HADDR <= '0; 
        HBURST <= '0; 
        HPROT <= '0; 
        HSIZE <= '0; 
        HTRANS <= '0; 
        HWDATA <= '0; 
        HWRITE <= '0; 
        HCLK <= '0;
        #10;
        repeat(2) @(posedge HCLK);
        HRESETN_I <= 1'b1;
        $info("Reset observed");
        for(int i=1; i<repeat_test; i++) begin
            write(i, 32'h5555_5555 + i);  
        end

        for(int i=1; i<repeat_test; i++) begin
            read(i, r_data);  
            compare(32'h5555_5555 + i, r_data);
        end
        
        if(error > 0)
        $info("TEST FAILED!");
        else $info("TEST PASSED!");

        $finish;
       
    end


    task write(
        input [31:0] addr,
        input [31:0] data
    );
        @(posedge HCLK);
        while(!HREADY)  @(posedge HCLK);
        HBURST <= 3'b000;
        HPROT <= '0;
        HSIZE <= 3'b010;
        HTRANS <= 2'b10;

        HWRITE <= 1'b1;
        HADDR <= addr;
        // @(posedge HCLK iff HREADY === 1);
        do begin
            @(posedge HCLK);
            if(HRESP) begin
                $fatal(1, "Error Response! Transfer Failed");
                return;
            end
        end
        while(!HREADY);
        HWDATA <= data;
    endtask

    task read(
        input [31:0] addr,
        output [31:0] data
    );
        @(posedge HCLK);
        while(!HREADY)  @(posedge HCLK);
        HBURST <= 3'b000;
        HPROT <= '0;
        HSIZE <= 3'b010;
        HTRANS <= 2'b10;

        HWRITE <= 1'b0;
        HADDR <= addr;
        // @(posedge HCLK iff HREADY === 1);
        do begin
            @(posedge HCLK);
            if(HRESP) begin
                $fatal(1, "Error Response! Transfer Failed");
                return;
            end
        end
        while(!HREADY);
        data = HRDATA;
        $info("read data: 0x%0x, HRDATA:0x%0x", data, HRDATA);
    endtask

    function void compare(logic [31:0] w_data, logic [31:0] r_data);
        if(w_data!=r_data) begin
            $info("Missmatch: input=0x%0x, output=0x%0x", w_data, r_data);
            error++;
        end
        else 
            $info("Match: input=0x%0x, output=0x%0x", w_data, r_data);
    endfunction

    always #5 HCLK <= ~HCLK;


        initial begin
            integer idx;
            $dumpfile("dump.vcd");
            $dumpvars();
            for(idx=0; idx<32; idx=idx+1)
                $dumpvars(0, SOC_FPGA_INTF_AHB_M_tb.ahb_s.mem[idx]);
          end

endmodule