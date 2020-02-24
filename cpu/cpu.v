/*
  Charlie Merth, Anabel Mathieson

  Top level module for 5-stage pipelined ARM 32-bit processor

  Instructions supported*:
    BL, MOV, MVN, LDR, STR, ADD, SUB
    CMP, TST, TEQ, EOR, BIC, ORR

  *Instructions requiring three register reads or two register
   writes remain unsupported
*/

`include "arm_constants.v"

module cpu(
    input wire clk,
    input wire resetn,
    output wire led,
    output wire [7:0] debug_port1,
    output wire [7:0] debug_port2,
    output wire [7:0] debug_port3,
    output wire [7:0] debug_port4,
    output wire [7:0] debug_port5,
    output wire [7:0] debug_port6,
    output wire [7:0] debug_port7
  );


  // =============GLOBAL VARIABLES============

  wire reset;
  assign reset = !resetn;

  reg [31:0] pc_curr;
  wire [31:0] pc_next;


  // =============CPSR FLAGS==================

  reg N_flag, Z_flag, C_flag, V_flag;
  always @(posedge clk) begin
    if (reset) begin
      N_flag <= 0;
      Z_flag <= 0;
      C_flag <= 0;
      V_flag <= 0;
    end
    else begin
      if (update_CPSR) begin
        N_flag <= N_flag_temp;
        Z_flag <= Z_flag_temp;
        V_flag <= V_flag_temp;
        if (!ignore_C_flag)
          C_flag <= C_flag_temp;
      end
    end
  end


  // ==========INSTRUCTION STAGE REGISTERS==========

  always @(*) begin
    ftch_inst = code_mem_data;
  end

  reg [2:0] cycle_state;
  reg [31:0] ftch_inst, decd_inst, exec_inst, wrbk_inst, memw_inst;
  always @(posedge clk) begin
  	// if (cycle_state == `STATE_WRBK || reset)
  	// 	ftch_inst <= code_mem_data;

    if (reset) begin
      cycle_state <= 0;

      decd_inst <= 32'bx;
      exec_inst <= 32'bx;
      wrbk_inst <= 32'bx;
      memw_inst <= 32'bx;
    end
    else begin
      cycle_state <= (cycle_state + 1) % 5;

      decd_inst <= ftch_inst;
      exec_inst <= decd_inst;
      memw_inst <= exec_inst;
      wrbk_inst <= memw_inst;
    end
  end


  // =============MODULE DECLARATIONS==================

  wire branch_inst, data_inst, load_inst, store_inst, cond_execute;
  update_pc u (.inst(ftch_inst), .branch_inst(branch_inst), .pc_in(pc_curr),
      .pc_out(pc_next), .cond_execute(cond_execute));


  wire [31:0] code_mem_data;
  code_mem #(.SIZE(`CODE_MEM_SIZE)) c (.clk(clk), .reset(reset),
      .addr(pc_curr), .inst(code_mem_data));


  wire [3:0] read_regA, read_regB, data_write_reg;
  decode_inst d (.inst(decd_inst), .read_regA(read_regA), .read_regB(read_regB),
      .write_reg(data_write_reg), .cond_execute(cond_execute),
	    .branch_inst(branch_inst), .data_inst(data_inst), .load_inst(load_inst), .store_inst(store_inst),
      .Z_flag(Z_flag), .C_flag(C_flag), .N_flag(N_flag), .V_flag(V_flag));

  wire reg_write_en;
  wire [31:0] alu_output;
  wire [31:0] data_regA, data_regB;
  reg [3:0] write_reg;
  reg [31:0] writeback_value, reg_write_value;
  regfile r (.clk(clk), .reset(reset), .write_en(reg_write_en),
      .write_reg(write_reg), .write_data(reg_write_value), .read_regA(read_regA),
      .data_regA(data_regA), .read_regB(read_regB), .data_regB(data_regB));


  wire update_CPSR, N_flag_temp, Z_flag_temp, C_flag_temp, V_flag_temp;
  alu a (.inst(exec_inst), .regA(data_regA), .regB(data_regB),
      .out(alu_output), .update_CPSR(update_CPSR), .ignore_C_flag(ignore_C_flag),
      .N_flag(N_flag_temp), .Z_flag(Z_flag_temp), .C_flag(C_flag_temp), .V_flag(V_flag_temp));


  wire [31:0] read_mem_data, write_mem_data;
  wire mem_write_en = store_inst && cycle_state == `STATE_MEMW;
  reg [31:0]  mem_access_addr;
  data_mem #(.SIZE(`DATA_MEM_SIZE)) dm (.clk(clk), .reset(reset), .write_en(mem_write_en),
      .write_addr(mem_access_addr), .write_data(data_regB),
      .read_addr(mem_access_addr), .read_data(read_mem_data));


  // =============REGISTER LOGIC==================

  reg reg_writeback;
  assign reg_write_en = (branch_inst && decd_inst[`B_LINK_BIT] && cycle_state == `STATE_DECD)
                     || (data_inst && cycle_state == `STATE_EXEC)
                     || (load_inst && cycle_state == `STATE_MEMW)
                     || (reg_writeback && cycle_state == `STATE_WRBK);

  always @(*) begin
    if ((load_inst || store_inst) && cycle_state == `STATE_WRBK)
      write_reg = read_regA;
    else
      write_reg = data_write_reg;
  end


  // =============MEMORY MANAGEMENT==================

  wire add_not_sub = memw_inst[`LS_ADD_NOT_SUB];
  wire ls_preindex = memw_inst[`LS_PRE_NOT_POST];
  wire writeback_bit = memw_inst[`LS_WRITEBACK_BIT];
  wire [11:0] ls_imm_offset = memw_inst[`LS_IMM_OFFSET_MSB:`LS_IMM_OFFSET_LSB];
  reg [31:0] adjusted_address;

  always @(*) begin
    if (cycle_state == `STATE_DECD)
      reg_write_value = pc_curr + `PC_INCR;
    else if (cycle_state == `STATE_EXEC)
      reg_write_value = alu_output;
    else if (cycle_state == `STATE_MEMW)
      reg_write_value = read_mem_data;
    else if (cycle_state == `STATE_WRBK)
      reg_write_value = adjusted_address;
    else
      reg_write_value = 32'bx;

    if ((load_inst || store_inst) && (!ls_preindex || writeback_bit))
      reg_writeback = 1;
    else
      reg_writeback = 0;

    if (add_not_sub)
      adjusted_address = data_regA + ls_imm_offset;
    else
      adjusted_address = data_regA + ~{20'b0, ls_imm_offset} + 1;
  end

  always @(*) begin
    if (ls_preindex)
      mem_access_addr = adjusted_address;
    else
      mem_access_addr = data_regA;
  end


  // =============PROGRAM COUNTER==================

  always @(posedge clk) begin
    if (reset)
      pc_curr <= 0;
    else
      if (cycle_state == `STATE_MEMW)
        if (write_reg == `PC_REGISTER)
          pc_curr <= alu_output;
        else
          pc_curr <= pc_next;
  end


  // =============DEBUGGING INFO==================

  assign debug_port1 = pc_curr[7:0];
  assign debug_port2 = 0;
  assign debug_port3 = read_regA;
  assign debug_port4 = read_regB;
  assign debug_port5 = write_reg;
  assign debug_port6 = 0;
  assign debug_port7 = {branch_inst, data_inst, load_inst};

  // Controls the LED on the board
  assign led = 1'b1;

endmodule
