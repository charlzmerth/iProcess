`include "arm_constants.v"

// Decodes the given instruction type
module decode_inst (
    input wire [31:0] inst,
    output reg [3:0] read_regA, read_regB, write_reg,
    output reg branch_inst, data_inst, load_inst, store_inst, write_en, cond_execute
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

      // Load/Store instruction
      `L_CODE: begin
				 if (`LS_IMM_LOAD_BIT) begin
				   load_inst = 1;
				   store_inst = 0;
				   write_en = 1;
				 end else begin
				   load_inst = 0;
				   store_inst = 1;
				   write_en = 0;
				 end
				 
                 branch_inst = 0;
                 data_inst = 0;
               end

      default: {branch_inst, data_inst, load_inst} <= 32'bx;
    endcase
  end

  // Test conditional execution
  always @(*) begin
    cond_execute = 1;
    case (inst[`COND_MSB:`COND_LSB])
   	  `COND_EQ: begin cond_execute =  Z_flag; end
	  `COND_NE: begin cond_execute = ~Z_flag; end
	  `COND_CS: begin cond_execute =  C_flag; end
	  `COND_CC: begin cond_execute = ~C_flag; end
	  `COND_MI: begin cond_execute =  N_flag; end
	  `COND_PL: begin cond_execute = ~N_flag; end
	  `COND_VS: begin cond_execute =  V_flag; end
	  `COND_VC: begin cond_execute = ~V_flag; end
	  `COND_HI: begin cond_execute =  C_flag && ~Z_flag; end
	  `COND_LS: begin cond_execute = ~C_flag || Z_flag; end
	  `COND_GE: begin cond_execute =  N_flag == V_flag; end
	  `COND_LT: begin cond_execute =  N_flag != V_flag; end
	  `COND_GT: begin cond_execute = (Z_flag == 0) && (N_flag == V_flag); end
	  `COND_LE: begin cond_execute = (Z_flag == 0) && (N_flag != V_flag); end
	  `COND_AL: begin cond_execute =  1'b1; end
	  `COND_NV: begin cond_execute =  1'bx; end
	   default: begin cond_execute =  1'bx; end
    endcase
  end

endmodule
