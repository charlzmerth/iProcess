// Test bench for cpu
`timescale 1ns/10ps
`include "arm_constants.v"

module cpu_tb();
  // Input
  reg clk;
  reg reset;

  // Output
  wire led;
  wire [7:0] debug_port1;
  wire [7:0] debug_port2;
  wire [7:0] debug_port3;
  wire [7:0] debug_port4;
  wire [7:0] debug_port5;
  wire [7:0] debug_port6;
  wire [7:0] debug_port7;
  integer i;


  cpu dut (.clk, .reset, .led, .debug_port1, .debug_port2, .debug_port3, .debug_port4, .debug_port5, .debug_port6, .debug_port7);

  reg[15:0] condition;
  reg[23:0] opcode;

  // Test conditional execution
  always @(*) begin
    case (dut.inst[`COND_MSB:`COND_LSB])
      `COND_EQ: begin condition = "EQ"; end // cond_execute =  Z_flag; end
      `COND_NE: begin condition = "NE"; end // cond_execute = ~Z_flag; end
      `COND_CS: begin condition = "CS"; end // cond_execute =  C_flag; end
      `COND_CC: begin condition = "CC"; end // cond_execute = ~C_flag; end
      `COND_MI: begin condition = "MI"; end // cond_execute =  N_flag; end
      `COND_PL: begin condition = "PL"; end // cond_execute = ~N_flag; end
      `COND_VS: begin condition = "VS"; end // cond_execute =  V_flag; end
      `COND_VC: begin condition = "VC"; end // cond_execute = ~V_flag; end
      `COND_HI: begin condition = "HI"; end // cond_execute =  C_flag && ~Z_flag; end
      `COND_LS: begin condition = "LS"; end // cond_execute = ~C_flag || Z_flag; end
      `COND_GE: begin condition = "GE"; end // cond_execute =  N_flag == V_flag; end
      `COND_LT: begin condition = "LT"; end // cond_execute =  N_flag != V_flag; end
      `COND_GT: begin condition = "GT"; end // cond_execute = (Z_flag == 0) && (N_flag == V_flag); end
      `COND_LE: begin condition = "LE"; end // cond_execute = (Z_flag == 0) && (N_flag != V_flag); end
      `COND_AL: begin condition = "AL"; end // cond_execute =  1'b1; end
      `COND_NV: begin condition = "NV"; end // cond_execute =  1'bx; end
       default: begin condition = "HI"; end // cond_execute =  1'bx; end
    endcase
  end

  // Test opcode field
always @(*) begin
  case (dut.inst[`OP_MSB:`OP_LSB])
    `AND: begin opcode = "AND"; end
    `EOR: begin opcode = "EOR"; end
    `SUB: begin opcode = "SUB"; end
    `RSB: begin opcode = "RSB"; end
    `ADD: begin opcode = "ADD"; end
    `ADC: begin opcode = "ADC"; end
    `SBC: begin opcode = "SBC"; end
    `RSC: begin opcode = "RSC"; end
    `TST: begin opcode = "TST"; end
    `TEQ: begin opcode = "TEQ"; end
    `CMP: begin opcode = "CMP"; end
    `CMN: begin opcode = "CMN"; end
    `ORR: begin opcode = "ORR"; end
    `MOV: begin opcode = "MOV"; end
    `BIC: begin opcode = "BIC"; end
    `MVN: begin opcode = "MVN"; end
     default: begin opcode = "BYE"; end
  endcase
  end

  always @(posedge clk) begin
     $display("Instruction: %b", dut.inst);
     $display("RegA: %d RegB: %d WReg: %d", dut.read_regA, dut.read_regB, dut.write_reg);
     //      $display("Next PC: %b Offset: %b ", pc_next, u.extended_offset);
     if(dut.branch_inst) $display("PC: %h %s B", dut.pc_curr, condition);
     else if(dut.data_inst) $display("PC: %h %s %s" , dut.pc_curr, condition, opcode);
     else if(dut.load_inst)$display("PC: %h %s LDR" , dut.pc_curr, condition);
     else $display("PC: %h %s Unknown", dut.pc_curr, condition);
     $display("   ");
  end

  initial begin // Set up the clock
    clk <= 0;
    forever #(5000/2) clk <= ~clk;
  end

  initial begin
  						                        @(posedge clk);
	 reset <= 0;			               		@(posedge clk);
    reset <= 1;			               		@(posedge clk);
              			               		@(posedge clk);
    reset <= 0;					              @(posedge clk);

    for (i=0; i <= 50; i = i + 1) begin

//   	 $display("%b",debug_port1);
//       $display("%b",debug_port2);
//       $display("%b",debug_port3);
//       $display("%b",debug_port4);
//       $display("%b",debug_port5);
//       $display("%b",debug_port6);
//       $display("%b",debug_port7);
       @(posedge clk);
      end
      $stop;
    end

endmodule
