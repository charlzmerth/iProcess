`include "arm_constants.v"

// Decodes the given instruction type
module decode_inst (
    input wire [31:0] inst,
    input wire Z_flag, N_flag, C_flag, V_flag,
    input wire noop_curr,
    output wire noop_next,
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
      default: ctrl[`INST_TYPE] = 2'bx;
    endcase
  end

  // "Skip" next instruction if current instruction is a branch
  assign noop_next = ctrl[`INST_TYPE] == `BRANCH_INST;

  // Decode rest of instruction
  always @(*) begin
    ctrl[`READ_REGA] = inst[`RN_MSB:`RN_LSB];

    if (ctrl[`INST_TYPE] == `BRANCH_INST)
      ctrl[`WRITE_REG] = `LINK_REGISTER;
    else
      ctrl[`WRITE_REG] = inst[`RD_MSB:`RD_LSB];

    if (ctrl[`INST_TYPE] == `STORE_INST)
      ctrl[`READ_REGB] = inst[`RD_MSB:`RD_LSB];
    else
      ctrl[`READ_REGB] = inst[`RM_MSB:`RM_LSB];
  end

  // Write to register conditions
  wire branch_link = ctrl[`INST_TYPE] == `BRANCH_INST && inst[`B_LINK_BIT];
  wire data_write = ctrl[`INST_TYPE] == `DATA_INST;
  wire load_write = ctrl[`INST_TYPE] == `LOAD_INST;

  wire ls_preindex = inst[`LS_PRE_NOT_POST];
  wire writeback_bit = inst[`LS_WRITEBACK_BIT];
  wire str_reg_writeback = (ctrl[`INST_TYPE] == `STORE_INST) && (!ls_preindex || writeback_bit);
  //wire ls_reg_writeback = ldr_str && (!ls_preindex || writeback_bit);


  // Compute whether to write to register
  always @(*) begin
    ctrl[`REG_WR_EN] = ctrl[`EXEC_THIS] && (branch_link || data_write || load_write);
    // || str_reg_writeback && !(clear_pipeline);

    ctrl[`MEM_WR_EN] = ctrl[`EXEC_THIS] && (ctrl[`INST_TYPE] == `STORE_INST);
  end

  // Test conditional execution
  reg cond_valid;
  always @(*) begin
    case (inst[`COND_MSB:`COND_LSB])
     	`COND_EQ: begin cond_valid =  Z_flag; end
  	  `COND_NE: begin cond_valid = ~Z_flag; end
  	  `COND_CS: begin cond_valid =  C_flag; end
  	  `COND_CC: begin cond_valid = ~C_flag; end
  	  `COND_MI: begin cond_valid =  N_flag; end
  	  `COND_PL: begin cond_valid = ~N_flag; end
  	  `COND_VS: begin cond_valid =  V_flag; end
  	  `COND_VC: begin cond_valid = ~V_flag; end
  	  `COND_HI: begin cond_valid =  C_flag && ~Z_flag; end
  	  `COND_LS: begin cond_valid = ~C_flag || Z_flag; end
  	  `COND_GE: begin cond_valid =  N_flag == V_flag; end
  	  `COND_LT: begin cond_valid =  N_flag != V_flag; end
  	  `COND_GT: begin cond_valid = (Z_flag == 0) && (N_flag == V_flag); end
  	  `COND_LE: begin cond_valid = (Z_flag == 0) && (N_flag != V_flag); end
  	  `COND_AL: begin cond_valid =  1'b1; end
  	  `COND_NV: begin cond_valid =  1'bx; end
	     default: begin cond_valid =  1'bx; end
    endcase
  end

  always @(*) ctrl[`EXEC_THIS] = cond_valid && !noop_curr;
endmodule
