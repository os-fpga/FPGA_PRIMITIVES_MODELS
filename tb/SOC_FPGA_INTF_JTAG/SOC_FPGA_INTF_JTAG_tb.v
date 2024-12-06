`timescale 1ns/1ps

module SOC_FPGA_INTF_JTAG_tb;

  // Inputs
  reg BOOT_JTAG_TCK;
  reg BOOT_JTAG_TDO;
  reg BOOT_JTAG_EN;

  // Outputs
  wire BOOT_JTAG_TDI;
  wire BOOT_JTAG_TMS;
  wire BOOT_JTAG_TRSTN;

  reg [3:0] tdo;

  SOC_FPGA_INTF_JTAG dut (
    .BOOT_JTAG_TCK(BOOT_JTAG_TCK),
    .BOOT_JTAG_TDI(BOOT_JTAG_TDI),
    .BOOT_JTAG_TDO(BOOT_JTAG_TDO),
    .BOOT_JTAG_TMS(BOOT_JTAG_TMS),
    .BOOT_JTAG_TRSTN(BOOT_JTAG_TRSTN),
    .BOOT_JTAG_EN(BOOT_JTAG_EN)
  );


  initial begin
    BOOT_JTAG_TCK = 0;
    forever #5 BOOT_JTAG_TCK = ~BOOT_JTAG_TCK;
  end


  // Stimulus
  initial begin

    BOOT_JTAG_TDO = 1'b0;
    BOOT_JTAG_EN = 1'b0;

    #10;

    for (int i=0; i<10; i++) begin
        BOOT_JTAG_TDO = ~BOOT_JTAG_TDO;
      @(posedge BOOT_JTAG_TCK);
    end

    #10;

    BOOT_JTAG_EN = 1'b1;

    for (int i=0; i<10; i++) begin
        BOOT_JTAG_TDO = ~BOOT_JTAG_TDO;
      @(posedge BOOT_JTAG_TCK);
    end

    #10;
    $finish;
  end

  always @(posedge BOOT_JTAG_TCK) tdo <= BOOT_JTAG_TDO;

    initial begin 
      forever begin
        if(BOOT_JTAG_TRSTN && BOOT_JTAG_TMS)
         if (BOOT_JTAG_TDI == tdo) 
          $info("True BOOT_JTAG_TDI");
         else $error("False BOOT_JTAG_TDI %0d , BOOT_JTAG_TDO %0d ", BOOT_JTAG_TDI ,tdo );
        @(posedge BOOT_JTAG_TCK);
      end
    end

endmodule
