`include "arm_constants.v"

// Decodes the given instruction type
module decode_inst (
    input wire [31:0] inst,
    input wire Z_flag, N_flag, C_flag, V_flag,
    output reg [`CTRL_VECTOR_SIZE] ctrl
  );

  //  Determine instruction type
  always @(*) begin
    case (inst[`CODE_MSB:`CODE_LSB])
      `B_CODE:        ctrl[`INST_TYPE] = `BRANCH_INST;
      `D_REG_CODE:    ctrl[`INST_TYPE] = `DATA_INST;
      `D_IMM_CODE:    ctrl[`INST_TYPE] = `DATA_INST;
      `LS_IMM_CODE:   begin
                        if (inst[`LS_IMM_LOAD_BIT])
                          ctrl[`INST_TYPE] = `LOAD_INST;
                        else
                          ctrl[`INST_TYPE] = `STORE_INST;
                      end
      default: {ctrl[`INST_TYPE]} <= 2'bx;
    endcase
  end

  // Decode rest of instruction
  always @(*) begin
    ctrl[`READ_REGA] = inst[`RN_MSB:`RN_LSB];
    ctrl[`REG_WR_EN] = 0;

    if (ctrl[`INST_TYPE] == `BRANCH_INST)
      ctrl[`WRITE_REG] = `LINK_REGISTER;
    else
      ctrl[`WRITE_REG] = inst[`RD_MSB:`RD_LSB];

    if (ctrl[`INST_TYPE] == `STORE_INST)
      ctrl[`READ_REGB] = inst[`RD_MSB:`RD_LSB];
    else
      ctrl[`READ_REGB] = inst[`RM_MSB:`RM_LSB];
  end

  // Test conditional execution
  always @(*) begin
    case (inst[`COND_MSB:`COND_LSB])
     	`COND_EQ: begin ctrl[`COND_VALID] =  Z_flag; end
  	  `COND_NE: begin ctrl[`COND_VALID] = ~Z_flag; end
  	  `COND_CS: begin ctrl[`COND_VALID] =  C_flag; end
  	  `COND_CC: begin ctrl[`COND_VALID] = ~C_flag; end
  	  `COND_MI: begin ctrl[`COND_VALID] =  N_flag; end
  	  `COND_PL: begin ctrl[`COND_VALID] = ~N_flag; end
  	  `COND_VS: begin ctrl[`COND_VALID] =  V_flag; end
  	  `COND_VC: begin ctrl[`COND_VALID] = ~V_flag; end
  	  `COND_HI: begin ctrl[`COND_VALID] =  C_flag && ~Z_flag; end
  	  `COND_LS: begin ctrl[`COND_VALID] = ~C_flag || Z_flag; end
  	  `COND_GE: begin ctrl[`COND_VALID] =  N_flag == V_flag; end
  	  `COND_LT: begin ctrl[`COND_VALID] =  N_flag != V_flag; end
  	  `COND_GT: begin ctrl[`COND_VALID] = (Z_flag == 0) && (N_flag == V_flag); end
  	  `COND_LE: begin ctrl[`COND_VALID] = (Z_flag == 0) && (N_flag != V_flag); end
  	  `COND_AL: begin ctrl[`COND_VALID] =  1'b1; end
  	  `COND_NV: begin ctrl[`COND_VALID] =  1'bx; end
	     default: begin ctrl[`COND_VALID] =  1'bx; end
    endcase
  end
endmodule
