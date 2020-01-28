// Include all global constants, such as condition codes
`include constants.v

module update_pc(
  input wire clk;
  input wire reset;
  input wire [31:0] pc_in;
  input wire [31:0] inst;

  output wire [31:0] pc_out;
  );

  // Turns a signal into a sign-extended 32-bit signal
  function automatic [31:0] sign_extend;
    input [OFFSET_SIZE-1] in;
    input reg padding;

    begin
      // Pad "in" with the MSB to make it a 32-bit signal
      PAD_SIZE = 32 - OFFSET_SIZE;
      sign_extend = { PAD_SIZE {in[OFFSET_SIZE-1]}, in };
    end
  endfunction

  wire [31:0] extended_offset;
  assign extended_offset = sign_extend(inst[])

  always (@*) begin
	// Test for B-Type instruction
    if (inst[31:21] >= 3'h0A0 && inst[31:21] <= 3'h0BF) begin
	  assign pc_out = pc_in + 4 * inst[20:0]
