`import arm_constants.v

// Decodes the given instruction type
module decode_inst (
    input wire [31:0] inst;
    output reg [3:0] read_regA, read_regB, write_reg;
    output reg branch_inst, data_inst, load_inst, write_en, cond_execute;
  );

  always @(*) begin
    read_regA = isnt[`RM_MSB:`RM_LSB];
    read_regB = isnt[`RN_MSB:`RN_LSB];
    write_reg = inst[`RD_MSB:`RD_LSB];

    case (branch = inst[`COND_MSB:`COND_LSB])
      // Branch instruction
      B_CODE: begin
                branch_inst = 1;
                data_inst = 0;
                load_inst = 0;
                write_en = 0;
              end

      // Data processing instruction
      D_CODE: begin
                branch_inst = 0;
                data_inst = 1;
                load_inst = 0;
                write_en = 1;
              end

      // Load instruction
      L_CODE: begin
                branch_inst = 0;
                data_inst = 0;
                load_inst = 1;
                write_en = 1;
              end

      default: {branch_inst, data_inst, load_inst} <= 'x;
    endcase


    // Test conditional execution
    always @(*) begin
      case (inst[`COND_MSB:`COND_LSB])
        `COND_EQ: cond_execute =  Z_flag;
        `COND_NE: cond_execute = ~Z_flag;
        `COND_CS: cond_execute =  C_flag;
        `COND_CC: cond_execute = ~C_flag;
        `COND_MI: cond_execute =  N_flag;
        `COND_PL: cond_execute = ~N_flag;
        `COND_VS: cond_execute =  V_flag;
        `COND_VC: cond_execute = ~V_flag;
        `COND_HI: cond_execute =  C_flag && ~Z_flag;
        `COND_LS: cond_execute = ~C_flag || Z_flag;
        `COND_GE: cond_execute =  N_flag == V_flag;
        `COND_LT: cond_execute =  N_flag != V_flag;
        `COND_GT: cond_execute = (Z_flag == 0) && (N_flag == V_flag);
        `COND_LE: cond_execute = (Z_flag == 0) && (N_flag != V_flag);
        `COND_AL: cond_execute =  1'b1;
        `COND_NV: cond_execute =  1'bx;
         default: cond_execute =  1'bx;
      endcase
    end

  end
endmodule
