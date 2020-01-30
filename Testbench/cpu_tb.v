// Test bench for cpu
`timescale 1ns/10ps

module cpu_tb();


  // Input
  wire clk;
  wire nreset;

  // Output
  wire led;
  wire [7:0] debug_port1;
  wire [7:0] debug_port2;
  wire [7:0] debug_port3;
  wire [7:0] debug_port4;
  wire [7:0] debug_port5;
  wire [7:0] debug_port6;
  wire [7:0] debug_port7;

  cpu dut (.clk, .nreset, .led, .debug_port1, .debug_port2, .debug_port3, .debug_port4, .debug_port5, .debug_port6, .debug_port7);

  initial begin // Set up the clock
    clk <= 0;
    forever #(5000/2) clk <= ~clk;
  end

  initial begin
  						                        @(posedge clk);
		nreset = 0			               		@(posedge clk);
    nreset = 1			               		@(posedge clk);
    nreset = 0			               		@(posedge clk);
    					                        @(posedge clk);

    for (i=0; i <= 100; i = i + 1) begin
    	  $display("%b",debug_port1);
        $display("%b",debug_port2);
        $display("%b",debug_port3);
        $display("%b",debug_port4);
        $display("%b",debug_port5);
        $display("%b",debug_port6);
        $display("%b",debug_port7);
        @(posedge clk);
    end


endmodule
