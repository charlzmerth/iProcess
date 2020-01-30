// Include all global constants, such as condition codes
`include constants.v

module cpu(
    input wire clk,
    input wire nreset,
    output wire led,
    output wire [7:0] debug_port1,
    output wire [7:0] debug_port2,
    output wire [7:0] debug_port3,
    output wire [7:0] debug_port4,
    output wire [7:0] debug_port5,
    output wire [7:0] debug_port6,
    output wire [7:0] debug_port7
  );

  wire loaded, branch;
  wire [31:0] inst;
  wire [4:0] regA, regB;
  wire [31:0] regA_data, regB_data;
  reg [31:0] pc_curr, pc_next;
  reg [31:0] code_memory [0:`CODE_MEM_SIZE-1];
  reg N_flag, Z_flag, C_flag, V_flag;

  assign branch = inst[`CODE_MSB:`CODE_LSB] = `BRANCH_CODE;

  update_pc u (.clk, .reset, .branch,
               .pc_in(pc_curr), .pc_out(pc_next));

  regfile r (.clk, .reset, .write_en(0'b0),
             .write_reg(4'b0), .write_data(32'b0),
             .read_regA(regA), .read_dataA(regA_data),
             .read_regB(regB), .read_dataB(regB_data));

  /*
  1. inst = code_memory[pc]
  2. pc = pc + 4
  ----clock cycle boundary
  3. if (inst == branch)
  4.     pc = compute_target(pc, inst)

  5. r1 = register_file(rm(inst));
  6. r2 = register_file(rn(inst));
  */

  // Instruction fetch and update
  always @(posedge clk) begin
    if (~loaded) begin
      inst <= code_memory[pc_curr];
      loaded <= 1;
    end
    else begin
      pc_curr <= pc_next;
      loaded <= 0;
      // =========== reassign registers ============
    end
  end

/*
  // Test conditional execution
  reg cond_execute;
  always @(*) begin
    case (inst[`COND_MSB:`COND_LSB])
      `COND_EQ: cond_execute <=  Z_flag;
      `COND_NE: cond_execute <= ~Z_flag;
      `COND_CS: cond_execute <=  C_flag;
      `COND_CC: cond_execute <= ~C_flag;
      `COND_MI: cond_execute <=  N_flag;
      `COND_PL: cond_execute <= ~N_flag;
      `COND_VS: cond_execute <=  V_flag;
      `COND_VC: cond_execute <= ~V_flag;
      `COND_HI: cond_execute <=  C_flag && ~Z_flag;
      `COND_LS: cond_execute <= ~C_flag || Z_flag;
      `COND_GE: cond_execute <=  N_flag == V_flag;
      `COND_LT: cond_execute <=  N_flag != V_flag;
      `COND_GT: cond_execute <= (Z_flag == 0) && (N_flag == V_flag);
      `COND_LE: cond_execute <= (Z_flag == 0) && (N_flag != V_flag);
      `COND_AL: cond_execute <=  1'b1;
      `COND_NV: cond_execute <=  1'bx;
       default: cond_execute <=  1'bx;
    endcase
  end
*/

  // Controls the LED on the board
  assign led = 1'b1;

  // These are how you communicate back to the serial port debugger
  assign debug_port1 = 8'h01;
  assign debug_port2 = 8'h02;
  assign debug_port3 = 8'h03;
  assign debug_port4 = 8'h04;
  assign debug_port5 = 8'h05;
  assign debug_port6 = 8'h06;
  assign debug_port7 = 8'h07;

endmodule
