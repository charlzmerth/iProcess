// A register file for 32-bit ARM CPU
module regfile (
    input wire clk,
    input wire reset,
    input wire write_en,

    input wire [3:0] write_reg,
    input wire [31:0] write_data,

    input wire [3:0] read_regA,
    input wire [3:0] read_regB,
    output reg [31:0] read_dataA,
    output reg [31:0] read_dataB
  );

  reg [31:0] data [0:15];
  integer i;

  always @(posedge clk) begin
    if (reset) begin
  	  for (i = 0; i < 16; i++) begin
        data[i] <= 0;
      end
    end
  	else begin
  	  read_dataA <= data[read_regA];
  	  read_dataB <= data[read_regB];

  	  if (write_en)
        data[write_reg] <= write_data;
	end
  end
endmodule
