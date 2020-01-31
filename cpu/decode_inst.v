`include "arm_constants.v"

// Decodes the given instruction type
module decode_inst (
    input wire [31:0] inst,
    output reg [3:0] read_regA, read_regB, write_reg,
    output reg branch_inst, data_inst, load_inst, write_en, cond_execute
  );

  always @(*) begin
    read_regA = inst[`RM_MSB:`RM_LSB];
    read_regB = inst[`RN_MSB:`RN_LSB];
    write_reg = inst[`RD_MSB:`RD_LSB];

    case (inst[`CODE_MSB:`CODE_LSB])
      // Branch instruction
      `B_CODE: begin
                branch_inst = 1;
                data_inst = 0;
                load_inst = 0;
                write_en = 0;
              end

      // Data processing instruction
      `D_CODE: begin
                branch_inst = 0;
                data_inst = 1;
                load_inst = 0;
                write_en = 1;
              end

      // Load instruction
      `L_CODE: begin
                branch_inst = 0;
                data_inst = 0;
                load_inst = 1;
                write_en = 1;
              end

      default: {branch_inst, data_inst, load_inst} <= 'x;
    endcase
  end

    reg[15:0] condition;
    reg[23:0] opcode;


    // Test conditional execution
    always @(*) begin
      cond_execute = 1;
      case (inst[`COND_MSB:`COND_LSB])
        `COND_EQ: begin condition = "EQ"; end // cond_execute =  Z_flag; end
        `COND_NE: begin condition = "NE"; end // cond_execute = ~Z_flag; end
        `COND_CS: begin condition = "CS"; end // cond_execute =  C_flag; end
        `COND_CC: begin condition = "CC"; end // cond_execute = ~C_flag; end
        `COND_MI: begin condition = "MI"; end // cond_execute =  N_flag; end
        `COND_PL: begin condition = "PL"; end // cond_execute = ~N_flag; end
        `COND_VS: begin condition = "VS"; end // cond_execute =  V_flag; end
        `COND_VC: begin condition = "VC"; end // cond_execute = ~V_flag; end
        `COND_HI: begin condition = "HI"; end // cond_execute =  C_flag && ~Z_flag; end
        `COND_LS: begin condition = "LS"; end // cond_execute = ~C_flag || Z_flag; end
        `COND_GE: begin condition = "GE"; end // cond_execute =  N_flag == V_flag; end
        `COND_LT: begin condition = "LT"; end // cond_execute =  N_flag != V_flag; end
        `COND_GT: begin condition = "GT"; end // cond_execute = (Z_flag == 0) && (N_flag == V_flag); end
        `COND_LE: begin condition = "LE"; end // cond_execute = (Z_flag == 0) && (N_flag != V_flag); end
        `COND_AL: begin condition = "AL"; end // cond_execute =  1'b1; end
        `COND_NV: begin condition = "NV"; end // cond_execute =  1'bx; end
         default: begin condition = "HI"; end // cond_execute =  1'bx; end
      endcase
    end

    // Test opcode field
  always @(*) begin
    case (inst[`OP_MSB:`OP_LSB])
      `AND: begin opcode = "AND"; end
      `EOR: begin opcode = "EOR"; end
      `SUB: begin opcode = "SUB"; end
      `RSB: begin opcode = "RSB"; end
      `ADD: begin opcode = "ADD"; end
      `ADC: begin opcode = "ADC"; end
      `SBC: begin opcode = "SBC"; end
      `RSC: begin opcode = "RSC"; end
      `TST: begin opcode = "TST"; end
      `TEQ: begin opcode = "TEQ"; end
      `CMP: begin opcode = "CMP"; end
      `CMN: begin opcode = "CMN"; end
      `ORR: begin opcode = "ORR"; end
      `MOV: begin opcode = "MOV"; end
      `BIC: begin opcode = "BIC"; end
      `MVN: begin opcode = "MVN"; end
       default: begin opcode = "BYE"; end
    endcase
  end


endmodule
