// Calculates the next PC, factoring in branches
module update_pc(
    input wire branch_inst, cond_execute,
    input wire [31:0] pc_in,
    input wire [31:0] inst,
    output reg [31:0] pc_out
  );

  // Branch Specific Calculations
  wire [23:0] offset_field;
  wire [31:0] extended_offset;
  assign offset_field = inst[`B_OFFSET_MSB:`B_OFFSET_LSB];

  sign_extend #(.IN(24), .OUT(32)) s (.in_wire(offset_field),
   .out_wire(extended_offset));

  // Calculate the next PC based on branch condition
  always @ (*) begin
    if (branch_inst && cond_execute)
      pc_out = pc_in + `PC_INCR + (extended_offset << `B_OFFSET_SHIFT);
    else
      pc_out = pc_in + `PC_INCR;
  end
endmodule
