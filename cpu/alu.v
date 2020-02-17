`include "arm_constants.v"

module alu (
    input wire [31:0] inst,
    input wire [31:0] regA, regB,
    output reg [31:0] out,
    output wire update_CPSR,
    output reg N_flag, Z_flag, C_flag, V_flag
  );

  wire reg_shift;
  assign reg_shift = inst[`SHIFT_IMM_BIT];

  // Calculate opcode
  wire [2:0] opcode;
  assign opcode = inst[`OP_MSB:`OP_LSB];

  // Update CPSR based on instruction bits
  assign update_CPSR = (opcode == `TST) || (opcode == `TEQ) ||
                       (opcode == `CMP) || (opcode == `CMN) ||
                       inst[`S_UPDATE_BIT];

  // Instantiate shifter
  wire shifter_carry;
  wire [31:0] shifter_out;
  shifter s (.inst(inst), .reg_shift_value(regB),
             .result(shifter_out), .carry(shifter_carry));

  // Calculate CPSR values
  always @(*) begin
    N_flag = out[31];
    Z_flag = (out == 0);
    C_flag = 0;
    V_flag = (regA[31] ^ shifter_out[31]) == out[31];
  end

  // Perform designated arithmetic operation
  always @(*) begin
    case (opcode)
      `AND: begin out = regA & shifter_out; end
      `EOR: begin out = regA ^ shifter_out; end
      `SUB: begin out = regA + (~shifter_out + 1); end
      `RSB: begin out = shifter_out + (~regA + 1); end
      `ADD: begin out = regA + shifter_out; end
      `ADC: begin out = regA + shifter_out + C_flag; end
      `SBC: begin out = regA + (~shifter_out + 1) + (~{31'b0,~C_flag} + 1); end
      `RSC: begin out = shifter_out + (~regA + 1) + (~{31'b0,~C_flag} + 1); end
      `TST: begin out = regA & shifter_out; end
      `TEQ: begin out = regA ^ shifter_out; end
      `CMP: begin out = regA + (~shifter_out + 1); end
      `CMN: begin out = regA + shifter_out; end
      `ORR: begin out = regA | shifter_out; end
      `MOV: begin out = regA; end
      `BIC: begin out = regA & (~shifter_out); end
      `MVN: begin out = ~(regA); end
       default: begin out = 32'bx; end
    endcase
  end
endmodule

module shifter (
  	input wire [31:0]	inst, reg_shift_value,
  	output reg [31:0] result,
    output wire carry
	);

  assign carry = x;

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
