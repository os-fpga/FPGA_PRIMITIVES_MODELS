
module SOC_FPGA_INTF_JTAG_tb;

  //Ports
  reg  BOOT_JTAG_TCK;
  wire  BOOT_JTAG_TDI;
  reg  BOOT_JTAG_TDO;
  wire  BOOT_JTAG_TMS;
  wire  BOOT_JTAG_TRSTN;
  reg  BOOT_JTAG_EN;

  SOC_FPGA_INTF_JTAG  SOC_FPGA_INTF_JTAG_inst (
    .BOOT_JTAG_TCK(BOOT_JTAG_TCK),
    .BOOT_JTAG_TDI(BOOT_JTAG_TDI),
    .BOOT_JTAG_TDO(BOOT_JTAG_TDO),
    .BOOT_JTAG_TMS(BOOT_JTAG_TMS),
    .BOOT_JTAG_TRSTN(BOOT_JTAG_TRSTN),
    .BOOT_JTAG_EN(BOOT_JTAG_EN)
  );

always #5  BOOT_JTAG_TCK = ! BOOT_JTAG_TCK ;

initial begin
    $display("Simulation Passed");
    $finish;
end

// -----------------------------------------------
// Testbench doesn't include any testing material 
// because primitive doesn't have any logic.
// It has only IO Ports.
// -----------------------------------------------

endmodule