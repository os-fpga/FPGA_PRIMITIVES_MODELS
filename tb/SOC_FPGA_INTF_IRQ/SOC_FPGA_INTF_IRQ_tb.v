
module SOC_FPGA_INTF_IRQ_tb;
  reg IRQ_CLK;
  reg IRQ_RST_N;
  reg [3:0] IRQ_SRC;
  wire [3:0] IRQ_SET;

  reg [3:0] irq_src;

    SOC_FPGA_INTF_IRQ soc_fpga_intf_irq(
    .IRQ_SRC(IRQ_SRC),
    .IRQ_SET(IRQ_SET),
    .IRQ_CLK(IRQ_CLK),
    .IRQ_RST_N(IRQ_RST_N)
    );

    initial begin
      //generating clock
      IRQ_CLK = 0;
      forever #5 IRQ_CLK = ~IRQ_CLK;
    end

    initial begin
      IRQ_SRC = 0;
      IRQ_RST_N = 0;

      repeat(2) @(posedge IRQ_CLK);
      IRQ_RST_N = 1;

      for (int i=0; i<10; i++) begin
        IRQ_SRC = $random();
        @(posedge IRQ_CLK);
      end

      $finish;

    end

    always @(posedge IRQ_CLK) irq_src <= IRQ_SRC;

    initial begin 
      forever begin
        if(IRQ_RST_N)
         if (IRQ_SET == irq_src) 
          $info("True IRQ_SET");
         else $error("False IRQ_SET %0d , IRQ_SRC %0d ", IRQ_SET ,irq_src );
        @(posedge IRQ_CLK);
      end
    end

endmodule
