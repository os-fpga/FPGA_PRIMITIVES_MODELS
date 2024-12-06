module SOC_FPGA_INTF_AHB_S_tb(
    // input HRESETN_I, // None
    // input [31:0] HADDR, // None
    // input [2:0] HBURST, // None
    // input [3:0] HPROT, // None
    // input [2:0] HSIZE, // None
    // input [1:0] HTRANS, // None
    // input [31:0] HWDATA, // None
    // input HWRITE, // None
    // output logic [31:0] HRDATA, // None
    // output logic HREADY, // None
    // output logic HRESP, // None
    // input HCLK // None
);

parameter repeat_test=10;




    logic HRESETN_I; 
    logic [31:0] HADDR; 
    logic [2:0] HBURST; 
    logic HMASTLOCK; 
    logic [3:0] HPROT; 
    logic [2:0] HSIZE; 
    logic [1:0] HTRANS; 
    logic [3:0] HWBE; 
    logic [31:0] HWDATA; 
    logic HWRITE; 
    logic HSEL;
    logic [31:0] HRDATA; 
    logic HREADY; 
    logic HRESP; 

    logic HCLK; 
    
    logic [31:0] addr_i;
    logic [31:0] mem[1024];
    bit [2:0] wait_states;
    int error;
    enum logic [1:0] {IDLE, BUSY, NONSEQ, SEQ} htrans;
              
    SOC_FPGA_INTF_AHB_S ahb_m(
        .HRESETN_I(HRESETN_I), 
        .HADDR(HADDR), 
        .HBURST(HBURST), 
        .HMASTLOCK(HMASTLOCK), 
        .HPROT(HPROT), 
        .HSIZE(HSIZE), 
        .HTRANS(HTRANS), 
        .HWDATA(HWDATA), 
        .HWWRITE(HWRITE), 
        .HRDATA(HRDATA), 
        .HREADY(HREADY), 
        .HRESP(HRESP), 
        .HSEL(HSEL), 
        .HWBE(HWBE), 
        .HCLK(HCLK) 
    );

    initial begin
        int idx;
        // HRESETN_I <= 1'b0;
        // HREADY <= 1'b0;
        HCLK <= 0;
        HRESP <= 1'b0;
        // repeat(2) @(posedge HCLK);
        // HRESETN_I <= 1'b1;
        HREADY <= 1'b1;
        // HSEL <= 1'b1;

        // for(int i=0; i<20; i++) mem[i]=i+32'haaaaaaaa;
        // forever begin
        //     @(posedge HCLK) HRDATA <= mem[idx];
        //     if(idx>11) idx=0;
        //     else idx++;
        // end 
        
    end


    initial begin
        // #1;
        // @(posedge HCLK);
        // @(posedge HRESETN_I === 1'b1);
        $info("reset asserted in slave");
        forever begin

            wait_states = $urandom();
            $display("#################### wait states:%0d ###########################", wait_states);

            if(HTRANS==NONSEQ & HSEL === 1'b1)begin
                addr_i = HADDR;
                $info("addr:%0d", addr_i);
                for(int i=0; i< wait_states; i++) begin
                    HREADY <= 1'b0;
                    @(posedge HCLK);
                end
                @(negedge HCLK);
                if(HWRITE==0) begin
                    HRDATA <= mem[addr_i];
                end
                HREADY <= 1'b1;
                @(posedge HCLK);
                if(HWRITE==1) begin
                    mem[addr_i] <= HWDATA;
                    $info("******* write addr:%0d, write_data:0x%0x *************", addr_i, HWDATA);
                end                    
                HREADY <= 1'b1;
            
            end
            // @(posedge HCLK);
            #1;

        end
    end

    always #5 HCLK <= ~HCLK;

endmodule