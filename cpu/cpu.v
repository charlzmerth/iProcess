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
        C_flag <= C_flag_temp;
        V_flag <= V_flag_temp;
      end
    end
  end


  // ==========INSTRUCTION STAGE REGISTERS==========

  reg [2:0] cycle_stage;
  reg [31:0] ftch_inst, decd_inst, exec_inst, wrbk_inst, memw_inst;
  always @(posedge clk) begin
	if (cycle_stage == `STAGE_FTCH)
		ftch_inst <= code_mem_data;
		
	cycle_stage <= (cycle_stage + 1) % 5;

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


  // =============MODULE DECLARATIONS==================

  wire branch_inst, data_inst, load_inst, store_inst, write_en, cond_execute;
  update_pc u (.inst(inst), .branch_inst(branch_inst), .pc_in(pc_curr),
  .pc_out(pc_next), .cond_execute(cond_execute));


  wire [31:0] code_mem_data;
  code_mem #(.SIZE(`CODE_MEM_SIZE)) c (.clk(clk), .reset(reset),
  .addr(pc_next), .inst(code_mem_data));


  wire [3:0] read_regA, read_regB, write_reg;
  decode_inst d (.inst(inst), .read_regA(read_regA), .read_regB(read_regB),
      .write_reg(write_reg), .write_en(write_en), .cond_execute(cond_execute),
	  .branch_inst(branch_inst), .data_inst(data_inst), .load_inst(load_inst), .store_inst(store_inst));


  wire [31:0] alu_output;
  wire [31:0] data_regA, data_regB;
  regfile r (.clk(clk), .reset(reset), .write_en(write_en && cycle_stage == `STAGE_WRBK),
  .write_reg(write_reg), .write_data(alu_output), .read_regA(read_regA),
  .data_regA(data_regA), .read_regB(read_regB), .data_regB(data_regB));


  wire update_CPSR, N_flag_temp, Z_flag_temp, C_flag_temp, V_flag_temp;
  alu a (.inst(inst), .regA(data_regA), .regB(data_regB),
      .reg_shift_value(data_regB), .out(alu_output), .update_CPSR(update_CPSR),
      .N_flag(N_flag_temp), .Z_flag(Z_flag_temp), .C_flag(C_flag_temp), .V_flag(V_flag_temp));


  wire [31:0] read_mem_addr, write_mem_addr, read_mem_data, write_mem_data;
  data_mem #(.SIZE(`DATA_MEM_SIZE)) dm (.clk(clk), .reset(reset), .write_en(store_inst && cycle_stage == `STAGE_MEMW),
      .write_addr(write_mem_addr), .write_data(write_mem_data),
      .read_addrA(read_mem_addr), .read_dataA(write_mem_data));


  // =============PROGRAM COUNTER==================

  always @(posedge clk) begin
    if (reset)
      pc_curr <= 0;
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
