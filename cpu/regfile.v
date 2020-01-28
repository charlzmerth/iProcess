// A register file for 32-bit ARM CPU
module regfile (
  input wire clk,
  input wire reset,
  input wire write_en,

  input wire [3:0] write_reg,
  input wire [31:0] write_data,

  input wire [3:0] read_reg0,
  input wire [3:0] read_reg1,
  output reg [31:0] read_data0,
  output reg [31:0] read_data1
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
  	  read_data0 <= data[read_reg0];
  	  read_data1 <= data[read_reg1];

  	  if (write_en)
        data[write_reg] <= write_data;
	end
  end
endmodule
