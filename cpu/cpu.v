// Include all global constants, such as condition codes
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

  wire reset;
  wire [31:0] inst;
  wire [3:0] read_regA, read_regB, write_reg;
  wire [31:0] data_regA, data_regB, pc_next;
  reg [31:0] pc_curr;
  wire branch_inst, data_inst, load_inst, write_en, cond_execute;
  // reg N_flag, Z_flag, C_flag, V_flag;

  assign reset = !resetn;

  code_mem #(.SIZE(`CODE_MEM_SIZE)) c (.clk(clk), .reset(reset), .addr(pc_next), .inst(inst));

  decode_inst d (.inst(inst), .read_regA(read_regA), .read_regB(read_regB), .write_reg(write_reg),
   .write_en(write_en), .branch_inst(branch_inst), .data_inst(data_inst), .load_inst(load_inst), .cond_execute(cond_execute));


  update_pc u (.inst(inst), .branch_inst(branch_inst), .pc_in(pc_curr), .pc_out(pc_next), .cond_execute(cond_execute));

  regfile r (.clk(clk), .reset(reset), .write_en(write_en),
    .write_reg(write_reg), .write_data(32'b0),
    .read_regA(read_regA), .data_regA(data_regA), .read_regB(read_regB), .data_regB(data_regB));

  // Instruction fetch and update
  always @(posedge clk) begin
    if (reset)
      pc_curr <= 0;
    else
      pc_curr <= pc_next;
  end

  // Controls the LED on the board
  assign led = 1'b1;

  // These are how you communicate back to the serial port debugger
  assign debug_port1 = pc_curr[7:0];
  assign debug_port2 = 0;
  assign debug_port3 = read_regA;
  assign debug_port4 = read_regB;
  assign debug_port5 = write_reg;
  assign debug_port6 = 0;
  assign debug_port7 = {branch_inst, data_inst, load_inst};

endmodule
