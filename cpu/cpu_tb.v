// Test bench for cpu
`timescale 1ns/1ns
`include "arm_constants.v"

module cpu_tb();
  // Input
  reg clk;
  reg resetn;

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


  cpu dut (.clk, .resetn, .led, .debug_port1, .debug_port2, .debug_port3, .debug_port4, .debug_port5, .debug_port6, .debug_port7);

  reg[15:0] condition;
  reg[23:0] opcode;

  // Test conditional execution
  always @(*) begin
    case (dut.decd_inst[`COND_MSB:`COND_LSB])
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
  case (dut.decd_inst[`OP_MSB:`OP_LSB])
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

/*
  always @(posedge clk) begin
     if (dut.cycle_state == `STATE_FTCH) begin
      $display("");
      $display("==========================================================================");
      $display("");
    end

     // Display instruction information
     $display("Cycle State: %d", dut.cycle_state);
     $display("");

     $display("Fetch Instruction:     %h", dut.ftch_inst);
     $display("Decode Instruction:    %h", dut.decd_inst);
     $display("Execute Instruction:   %h", dut.exec_inst);
     $display("Memory Instruction:    %h", dut.memw_inst);
     $display("Writeback Instruction: %h", dut.wrbk_inst);
     $display("");

     $display("RegA: %d | RegB: %d | WReg: %d", dut.read_regA, dut.read_regB, dut.write_reg);
     $display("RegA Read Data: %d | RegB Read Data: %d", dut.data_regA, dut.data_regB);
     $display("Register Write Data: %d", dut.reg_write_value);
     $display("");

     $display("Memory Access: %d", dut.mem_access_addr);
     $display("Memory Read Data: %d", dut.read_mem_data);
     $display("Memory Write Data: %d", dut.data_regB);
     //$display("offset: %d | add_not_sub: %b", dut.ls_imm_offset, dut.add_not_sub);
     $display("");

     if (dut.reg_write_en) begin
      $display("***************WRITING TO REGISERS***************");
      $display("");
     end

     if (dut.mem_write_en) begin
      $display("***************WRITING TO MEMORY***************");
      $display("");
     end


     // $display("scaled_write_addr: %d", dut.dm.scaled_write_addr);
     // $display("scaled_read_addr: %d", dut.dm.scaled_read_addr);

     $display("Frame Pointer: %d", dut.r.data[11]);
     $display("Stack Pointer: %d", dut.r.data[13]);
     $display("");

     $display("data: %b", dut.data_inst);
     $display("branch: %b", dut.branch_inst);
     $display("load: %b", dut.load_inst);
     $display("store: %b", dut.store_inst);
     $display("");

     // Display instruction type
     if(dut.branch_inst) begin $display("PC: %d %s B", dut.pc_curr/4, condition);  $display("Offset: %d", dut.u.extended_offset); end
     else if(dut.data_inst) $display("PC: %d %s %s" , dut.pc_curr/4, condition, opcode);
     else if(dut.load_inst)$display("PC: %d %s LDR" , dut.pc_curr/4, condition);
     else if(dut.store_inst)$display("PC: %d %s STR" , dut.pc_curr/4, condition);
     else $display("PC: %d %s Unknown", dut.pc_curr/4, condition);
     $display("Next PC: %d", dut.pc_next/4);

     // Display alu outputs
     $display("Alu Result: %d", dut.a.out);
     $display("Flags: Z:%b N:%b C:%b V:%b", dut.Z_flag, dut.N_flag, dut.C_flag, dut.V_flag);

     // Display branch information
//     $display("scaled_addr: %b addr: %b inst: %b", dut.c.scaled_addr, dut.c.addr, dut.c.inst);
//     $display("branch_inst: %b", dut.branch_inst);
     $display("conditional_execute: %b", dut.cond_execute);
     $display("Result: %d", dut.r.data[0]);

     // Print blank lines
     $display("");
     $display("");
  end
*/

  initial begin // Set up the clock
    clk <= 0;
    forever #(5000/2) clk <= ~clk;
  end

  initial begin
    resetn <= 0;			               		@(posedge clk);
    resetn <= 1;					              @(posedge clk);

    for (i=0; i <= 150; i = i + 1) begin

//   	 $display("%b",debug_port1);
//       $display("%b",debug_port2);
//       $display("%b",debug_port3);
//       $display("%b",debug_port4);
//       $display("%b",debug_port5);
//       $display("%b",debug_port6);
//       $display("%b",debug_port7);
       @(posedge clk);
      end
      $finish;
    end

endmodule
