// Include all global constants, such as condition codes
`include "arm_constants.v"

module cpu(
    input wire clk,
    input wire reset,
    output wire led,
    output wire [7:0] debug_port1,
    output wire [7:0] debug_port2,
    output wire [7:0] debug_port3,
    output wire [7:0] debug_port4,
    output wire [7:0] debug_port5,
    output wire [7:0] debug_port6,
    output wire [7:0] debug_port7
  );

  wire [31:0] inst;
  wire [3:0] read_regA, read_regB, write_reg;
  wire [31:0] data_regA, data_regB , pc_next;
  reg [31:0] pc_curr;
  wire branch_inst, data_inst, load_inst, write_en, cond_execute;
  // reg N_flag, Z_flag, C_flag, V_flag;

  code_mem #(.SIZE(`CODE_MEM_SIZE)) c (.addr(pc_curr), .inst);

  decode_inst d (.inst, .read_regA, .read_regB,
    .write_reg, .write_en, .branch_inst, .data_inst, .load_inst, .cond_execute);

    always @(posedge clk) begin
      $display("Instruction: %b", inst);
      $display("Next PC: %b Offset: %b ", pc_next, u.extended_offset);
      if(branch_inst) $display("PC: %h %s B", pc_curr, d.condition);
      else if(data_inst) $display("PC: %h %s %s" , pc_curr, d.condition, d.opcode);
      else if(load_inst)$display("PC: %h %s LDR" , pc_curr, d.condition);
      else $display("PC: %h %s Unknown", pc_curr, d.condition);
    end

  update_pc u (.inst, .branch_inst, .pc_in(pc_curr), .pc_out(pc_next), .cond_execute);

  regfile r (.clk, .reset, .write_en,
    .write_reg, .write_data(32'b0),
    .read_regA, .data_regA, .read_regB, .data_regB);

  /*
  1. inst = code_memory[pc]
  2. pc = pc + 4

  ----clock cycle boundary

  3. if (inst == branch)
  4.     pc = compute_target(pc, inst)

  5. r1 = register_file(rm(inst));
  6. r2 = register_file(rn(inst));
  */

  // Instruction fetch and update
  always @(posedge clk) begin
    if (reset)
      pc_curr <= 0;
    else
      pc_curr <= pc_next;
  end

  // Controls the LED on the board
  assign led = 1'b1;

  // These are how you communicate back to the serial port debugger
  assign debug_port1 = 8'h01;
  assign debug_port2 = 8'h02;
  assign debug_port3 = 8'h03;
  assign debug_port4 = 8'h04;
  assign debug_port5 = 8'h05;
  assign debug_port6 = 8'h06;
  assign debug_port7 = 8'h07;

endmodule
