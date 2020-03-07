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
  reg [3:0] read_regA, read_regB, write_reg;
  reg [31:0] reg_write_value;

  // CPSR flags
  wire update_CPSR;
  wire N_flag, Z_flag, C_flag, V_flag;
  wire N_flag_temp, Z_flag_temp, C_flag_temp, V_flag_temp;

  // Memory variables
  reg [31:0] mem_access_addr;
  wire [31:0] read_mem_data, write_mem_data;
  wire mem_write_en;


  // ==========INSTRUCTION PIPELINE==========

  wire [31:0] code_mem_out;
  reg [31:0] ftch_inst, decd_inst, exec_inst, wrbk_inst, memw_inst;

  always @(*) begin
    ftch_inst = code_mem_out;
  end

  // Pass instruction to next pipeline stage
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


  // =============CONTROL SIGNALS==================

  wire [`CTRL_VECTOR_SIZE] decd_ctrl;
  reg [`CTRL_VECTOR_SIZE] exec_ctrl;
  reg [`CTRL_VECTOR_SIZE] memw_ctrl;
  reg [`CTRL_VECTOR_SIZE] wrbk_ctrl;

  // Pass control signals to next pipeline stage
  always @(posedge clk) begin
    exec_ctrl <= decd_ctrl;
    memw_ctrl <= exec_ctrl;
    wrbk_ctrl <= memw_ctrl;
  end


  // =============MODULE INSTANTIATIONS==================

  // Handles CPSR flags
  cpsr c (.clk(clk), .reset(reset), .update_CPSR(update_CPSR), .ignore_C_flag(ignore_C_flag),
      .N_flag_temp(N_flag_temp), .Z_flag_temp, .C_flag_temp(C_flag_temp), .V_flag_temp(V_flag_temp),
      .N_flag(N_flag), .Z_flag(Z_flag), .C_flag(C_flag), .V_flag(V_flag));


  // Updates program counter
  update_pc u (.inst(???), .branch_inst(???), .pc_in(pc_curr),
      .pc_out(pc_next), .cond_execute(cond_execute));


  // Stores program executable code
  code_mem #(.SIZE(`CODE_MEM_SIZE)) cm (.clk(clk), .reset(reset),
      .addr(pc_next), .inst(code_mem_out));


  // Parses machine code into the control vector
  decode_inst di (.inst(decd_inst), .ctrl(decd_ctrl),
      .Z_flag(Z_flag), .C_flag(C_flag), .N_flag(N_flag), .V_flag(V_flag));


  // Register file block memory manager
  regfile r (.clk(clk), .reset(reset), .write_en(reg_write_en),
      .write_reg(write_reg), .write_data(reg_write_value), .read_regA(read_regA),
      .data_regA(data_regA), .read_regB(read_regB), .data_regB(data_regB));


  // Arithmetic logic unit (100% combinational)
  alu a (.inst(exec_inst), .regA(data_regA), .regB(data_regB),
      .out(alu_output), .update_CPSR(update_CPSR), .ignore_C_flag(ignore_C_flag),
      .N_flag(N_flag_temp), .Z_flag(Z_flag_temp), .C_flag(C_flag_temp), .V_flag(V_flag_temp));


  // Data RAM manager
  data_mem #(.SIZE(`DATA_MEM_SIZE)) dm (.clk(clk), .reset(reset), .write_en(mem_write_en),
      .write_addr(mem_write_addr), .write_data(data_regB),
      .read_addr(mem_read_addr), .read_data(read_mem_data));


  // Manages datapath dependencies
  datapath d (.memw_inst(memw_inst), .memw_ctrl(memw_ctrl), .wrbk_ctrl(wrbk_ctrl),
      .mem_write_en(mem_write_en), .reg_write_en(reg_write_en),
      .read_regA(read_regA), .read_regB(read_regB), .write_reg(write_reg), .reg_write_value(reg_write_value),
      .mem_write_addr(mem_write_addr), .mem_read_addr(mem_read_addr));


  // =============PROGRAM COUNTER==================

  // Update the program counter
  always @(posedge clk) begin
    if (reset)
      pc_curr <= 0;
    else
      // Writing to program counter register
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
  assign debug_port7 = {decd_ctrl[`INST_TYPE]};

  // Controls the LED on the board
  assign led = 1'b1;

endmodule
