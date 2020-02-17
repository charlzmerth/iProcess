`define BENCHMARK "./code.hex"

// Code memory for 32-bit CPU, where SIZE is # of bytes
module code_mem #(parameter SIZE=1024) (
    input wire clk, reset,
    input wire [31:0] addr,
    output reg [31:0] inst
  );

  wire [31:0] scaled_addr;
  assign scaled_addr = addr >> 2;

  // Store instructions as 32-bit words
  reg [31:0] data [0:(SIZE/4)-1];

  initial begin
    $readmemh(`BENCHMARK, data);
    $display("Running Testbench on %s", `BENCHMARK);
  end

  // Test if address is out of bounds
  always @(posedge clk) begin
      if (reset)
        inst <= data[0];
      else
        inst <= data[scaled_addr];
  end
endmodule
