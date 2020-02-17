`include "arm_constants.v"

module alu (
    input wire [31:0] inst,
    input wire [31:0] inA, inB, reg_shift_value,
    output wire [31:0] out,
    output wire update_CPSR,
    output reg N_flag, Z_flag, C_flag, V_flag
  );

  wire shifter_carry;
  wire [2:0] opcode;
  assign opcode = inst[`OP_MSB:`OP_LSB];

  assign update_CPSR = (opcode == `TST) || (opcode == `TEQ) ||
                       (opcode == `CMP) || (opcode == `CMN) ||
                       inst[`S_UPDATE_BIT];

  shifter s (.inst(inst), .reg_shift_value(reg_shift_value),
             .result(out), .shifter_carry(shifter_carry));

  always @(*) begin
    N_flag = out[31];
    Z_flag = out == 0;
    C_flag = 0;
    V_flag = (inA[31] ^ inB[31]) == out[31];
  end

  reg [31:0] out_temp;
  // Test opcode field
  always @(*) begin
    case (opcode)
      `AND: begin out_temp = inA & inB; end
      `EOR: begin out_temp = inA ^ inB; end
      `SUB: begin out_temp = inA - inB; end
      `RSB: begin out_temp = inB - inA; end
      `ADD: begin out_temp = inA + inB; end
      `ADC: begin out_temp = inA + inB + C_flag; end
      `SBC: begin out_temp = inA - inB - (~C_flag); end
      `RSC: begin out_temp = inB - inA - (~C_flag); end
      `TST: begin out_temp = 32'bx; end
      `TEQ: begin out_temp = 32'bx; end
      `CMP: begin out_temp = 32'bx; end
      `CMN: begin out_temp = 32'bx; end
      `ORR: begin out_temp = inA | inB; end
      `MOV: begin out_temp = inA; end
      `BIC: begin out_temp = inA & (~inB); end
      `MVN: begin out_temp = ~(inA); end
       default: begin out_temp = 32'bx; end
    endcase
  end
endmodule

module shifter (
  	input wire [31:0]	inst, reg_shift_value,
  	output reg [31:0] result,
    output reg shifter_carry
	);

  wire reg_shift;
  wire [1:0] reg_shift_code;
  wire [4:0] reg_shift_imm;
  wire [3:0] imm_rotate_imm;
  wire [7:0] imm_shift_val;

  assign reg_shift = inst[`SHIFT_IMM_BIT];
  assign reg_shift_code = inst[`REG_SHIFT_CODE_MSB:`REG_SHIFT_CODE_LSB];
  assign reg_shift_imm = inst[`REG_SHIFT_IMM_MSB:`REG_SHIFT_IMM_LSB];
  assign imm_rotate_imm = inst[`IMM_SHIFT_ROT_MSB:`IMM_SHIFT_ROT_LSB];
  assign imm_shift_val = inst[`IMM_SHIFT_VAL_MSB:`IMM_SHIFT_VAL_LSB];

	always @(*) begin
    if (reg_shift) begin
      case (reg_shift_code)
        `REG_SHIFT_CODE_LSR: result = reg_shift_value >> reg_shift_imm;
        `REG_SHIFT_CODE_LSL: result = reg_shift_value << reg_shift_imm;
        `REG_SHIFT_CODE_ASR: result = reg_shift_value >>> reg_shift_imm;
        `REG_SHIFT_CODE_RTR: result = {reg_shift_value, reg_shift_value} >> reg_shift_imm;
      endcase
    end
    else begin
      result = { imm_shift_val, imm_shift_val } >> (imm_rotate_imm << 1);
    end
	end
endmodule
