// A register file for 32-bit ARM CPU
module regfile (
    input wire clk,
    input wire reset,
    input wire write_en,

    input wire [3:0] write_reg,
    input wire [31:0] write_data,

    input wire [3:0] read_regA,
    input wire [3:0] read_regB,
    output reg [31:0] data_regA,
    output reg [31:0] data_regB
  );

  reg [31:0] data [0:15];
  integer i;

  always @(posedge clk) begin
    if (reset) begin
  	  for (i = 0; i < 16; i=i+1) begin
        data[i] <= 0;
      end
    end
  	else begin
  	  data_regA <= data[read_regA];
  	  data_regB <= data[read_regB];

  	  if (write_en)
        data[write_reg] <= write_data;
	  end
  end
endmodule
