module data_mem #(parameter SIZE=4096) (
    input wire clk,
    input wire reset,
    input wire write_en,

    input wire [31:0] write_addr,
    input wire [31:0] write_data,

    input wire [31:0] read_addr,
    output reg [31:0] read_data
  );

  wire [31:0] scaled_read_addr;
  wire [31:0] scaled_write_addr;

  assign scaled_read_addr = read_addr >> 2;
  assign scaled_write_addr = write_addr >> 2;

  // Store instructions as 32-bit words
  reg [31:0] data [0:(SIZE/4)-1];

  integer i;
  always @(posedge clk) begin
    if (reset) begin
      read_data <= 31'bx;

      for (i = 0; i < SIZE/4; i=i+1)
        data[i] <= 0;
    end
    else begin
      read_data <= data[scaled_read_addr];

      if (write_en)
        data[scaled_write_addr] <= write_data;
    end
  end
endmodule
