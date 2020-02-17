module data_mem #(parameter SIZE=4096) (
    input wire clk,
    input wire reset,
    input wire write_en,

    input wire [31:0] write_addr,
    input wire [31:0] write_data,

    input wire [31:0] read_addrA,
    input wire [31:0] read_addrB,
    output reg [31:0] read_dataA,
    output reg [31:0] read_dataB
  );

  wire scaled_addrA;
  wire scaled_addrB;
  wire scaled_write_addr;
  
  assign scaled_addrA = read_addrA >> 2;
  assign scaled_addrB = read_addrB >> 2;
  assign scaled_write_addr = write_addr >> 2;

  // Store instructions as 32-bit words
  reg [31:0] data [0:(SIZE/4)-1];
  integer i;

  always @(posedge clk) begin
    if (reset) begin
      read_dataA <= 31'bx;
      read_dataB <= 31'bx;

      for (i = 0; i < SIZE/4; i++)
        data[i] <= 0;
    end
    else begin
      read_dataA <= data[scaled_addrA];
      read_dataB <= data[scaled_addrB];

      if (write_en)
        data[scaled_write_addr] <= write_data;
    end
  end
endmodule
