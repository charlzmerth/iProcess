// A register file with variable size
module regfile
  #(parameter WORDS=32) (

  input wire clk;
  input wire reset;
  input wire write_en;

  input wire [31:0] w0_addr;
  input wire [31:0] w0;

  input wire [31:0] r0_addr;
  input wire [31:0] r1_addr;
  output wire [31:0] r0;
  output wire [31:0] r1;
  );

  reg [0:WORDS-1] [31:0] data;

  always @(posedge clk) begin
    if (reset)
	  data <= 0;
	else begin
	  r0 <= data[r0_addr];
	  r1 <= data[r1_addr];

	  if (write_en)
      data[w0_addr] <= w0;
	end
  end
endmodule
