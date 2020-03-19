// Calculates the next PC, factoring in branches
`include "arm_constants.v"

module update_pc(
    input wire [`CTRL_VECTOR_SIZE] ctrl,
    input wire stall,
    input wire [31:0] pc_in,
    input wire [31:0] inst,
    output reg [31:0] pc_out
  );

  wire branch_inst = ctrl[`INST_TYPE] == `BRANCH_INST;
  wire cond_execute = ctrl[`EXEC_THIS];

  // Branch Specific Calculations
  wire [23:0] offset_field;
  wire [31:0] extended_offset;
  assign offset_field = inst[`B_OFFSET_MSB:`B_OFFSET_LSB];

  sign_extend #(.IN(24), .OUT(32)) s (.in_wire(offset_field),
   .out_wire(extended_offset));

  // Calculate the next PC based on branch condition
  always @ (*) begin
    if (stall)
      pc_out = pc_in;
    else if (branch_inst && cond_execute)
      pc_out = pc_in + (extended_offset << `B_OFFSET_SHIFT); // + `PC_INCR;
    else
      pc_out = pc_in + `PC_INCR;
  end
endmodule

module sign_extend
  #(parameter IN=8,
    parameter OUT=16) (

	input wire [IN-1:0] in_wire,
	output wire [OUT-1:0] out_wire
  );

  // Repeat MSB OUT-IN times, concatenate with in_wire
  assign out_wire = { {OUT-IN {in_wire[IN-1]}}, in_wire };
endmodule
