`define BENCHMARK "../testcode/code.hex"

// Code memory for 32-bit CPU, where SIZE is # of bytes
module code_mem #(parameter SIZE=1024) (
    //input wire clk,
    input wire [31:0] addr,
    output reg [31:0] inst
  );

  // Store instructions as 32-bit words
  reg [31:0] data [0:(SIZE/4)-1];

  initial begin
    $readmemh(`BENCHMARK, data);
    $display("Running Testbench on %s", `BENCHMARK);
  end

  // Test if address is out of bounds
  always @(*) begin
    if (addr + 3 >= SIZE)
      inst = 'x;
    else
      inst = data[addr/4];
  end
endmodule
