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

  // Reset Signals
  wire reset;
  assign reset = !resetn;

  // Program Counters
  reg [31:0] pc_curr;
  wire [31:0] pc_next;

  // Register Data
  wire reg_write_en;
  wire [31:0] alu_output;
  wire [31:0] data_regA, data_regB;
  reg [3:0] write_reg;
  reg [31:0] writeback_value, reg_write_value;

  // CPSR flags
  wire update_CPSR;
  wire N_flag, Z_flag, C_flag, V_flag;
  wire N_flag_temp, Z_flag_temp, C_flag_temp, V_flag_temp;

  // Memory variables
  reg [31:0] mem_access_addr;
  wire [31:0] read_mem_data, write_mem_data;
  wire mem_write_en = memw_inst == `STORE_INST;


  // ==========INSTRUCTION REGISTERS==========

  wire [31:0] code_mem_out;
  reg [31:0] ftch_inst, decd_inst, exec_inst, wrbk_inst, memw_inst;

  always @(*) begin
    ftch_inst = code_mem_out;
  end

  always @(posedge clk) begin
    if (reset) begin
      decd_inst <= 32'bx;
      exec_inst <= 32'bx;
      wrbk_inst <= 32'bx;
      memw_inst <= 32'bx;
    end
    else begin
      decd_inst <= ftch_inst;
      exec_inst <= decd_inst;
      memw_inst <= exec_inst;
      wrbk_inst <= memw_inst;
    end
  end


  // =============PIPELINE SIGNALS==================

  // FETCH

  // DECODE
  wire decd_cond_val;
  wire [1:0] decd_inst_type;
  wire [3:0] decd_read_regA, decd_read_regB, decd_write_reg;

  // EXECUTE
  wire exec_cond_val;
  wire [1:0] exec_inst_type;
  wire [3:0] exec_read_regA, exec_read_regB, exec_write_reg;

  // MEMORY
  wire memw_cond_val;
  wire [1:0] memw_inst_type;
  wire [3:0] memw_read_regA, memw_read_regB, memw_write_reg;

  // REGWRITE
  wire wrbk_cond_val;
  wire [1:0] wrbk_inst_type;
  wire [3:0] wrbk_read_regA, wrbk_read_regB, wrbk_write_reg;


  // =============MODULE INSTANTIATIONS==================

  cpsr c (.clk(clk), .reset(reset), .update_CPSR(update_CPSR), .ignore_C_flag(ignore_C_flag),
          .N_flag_temp(N_flag_temp), .Z_flag_temp, .C_flag_temp(C_flag_temp), .V_flag_temp(V_flag_temp),
          .N_flag(N_flag), .Z_flag(Z_flag), .C_flag(C_flag), .V_flag(V_flag));


  update_pc u (.inst(ftch_inst), .branch_inst(branch_inst), .pc_in(pc_curr),
      .pc_out(pc_next), .cond_execute(cond_execute));


  code_mem #(.SIZE(`CODE_MEM_SIZE)) cm (.clk(clk), .reset(reset),
      .addr(pc_curr), .inst(code_mem_out));


  decode_inst d (.inst(decd_inst), .read_regA(read_regA), .read_regB(read_regB),
      .write_reg(data_write_reg), .cond_execute(cond_execute),
	    .branch_inst(branch_inst), .data_inst(data_inst), .load_inst(load_inst), .store_inst(store_inst),
      .Z_flag(Z_flag), .C_flag(C_flag), .N_flag(N_flag), .V_flag(V_flag));


  regfile r (.clk(clk), .reset(reset), .write_en(reg_write_en),
      .write_reg(write_reg), .write_data(reg_write_value), .read_regA(read_regA),
      .data_regA(data_regA), .read_regB(read_regB), .data_regB(data_regB));


  alu a (.inst(exec_inst), .regA(data_regA), .regB(data_regB),
      .out(alu_output), .update_CPSR(update_CPSR), .ignore_C_flag(ignore_C_flag),
      .N_flag(N_flag_temp), .Z_flag(Z_flag_temp), .C_flag(C_flag_temp), .V_flag(V_flag_temp));


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
    if (???)
      reg_write_value = pc_curr + `PC_INCR;
    else if (exec_inst_type == `DATA_INST)
      reg_write_value = alu_output;
    else if (memw_inst == `LOAD_INST)
      reg_write_value = read_mem_data;
    else if (wrbk_inst_type == `STORE_INST)
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
