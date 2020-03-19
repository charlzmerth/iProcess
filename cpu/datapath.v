`include "arm_constants.v"

module datapath (
    input wire clk, reset,
    input wire [`CTRL_VECTOR_SIZE] decd_ctrl, exec_ctrl, memw_ctrl, wrbk_ctrl,
    input wire [31:0] decd_inst, exec_inst, memw_inst, wrbk_inst, pc_curr, alu_output,
    input wire [31:0] mem_read_data, data_regA, data_regB,
    output wire [31:0] mem_read_addr, mem_write_addr,
    output reg [31:0] mem_write_data, reg_write_data,
    output reg [31:0] alu_inA, alu_inB,
    output reg stall
  );


  // ====================HAZARD LOGIC====================

  reg [31:0] adjusted_mem_address;
  reg [31:0] data_write_value;
  reg [31:0] memw_alu_out, wrbk_alu_out;
  reg [31:0] wrbk_prepost_index;

  // Store instruction data buffer
  reg [31:0] memw_store_addr_buffer, memw_store_data_buffer;

  // Branch + link target buffer
  reg [31:0] exec_bnl_target, memw_bnl_target, wrbk_bnl_target;

  // "Two cycles ahead" ALU result
  wire [3:0] forwarding_reg = memw_ctrl[`WRITE_REG];
  wire [31:0] forwarding_data = memw_alu_out;

  // "Single cycle ahead" ALU result
  wire [3:0] regfile_bypass_reg = wrbk_ctrl[`WRITE_REG];
  wire [31:0] regfile_bypass_data = reg_write_data;

  // "Single cycle behind" ALU result
  reg [3:0] str_delay_reg_buffer;
  reg [31:0] str_delay_data_buffer;
  reg str_delay_write_executed;

  // Registers from which STR address and data originate
  wire [3:0] memw_store_addr_reg = memw_ctrl[`READ_REGA];
  wire [3:0] memw_store_data_reg = memw_ctrl[`READ_REGB];

  // Pipeline stall conditions
  wire data_inst_after_ldr_to_reg = (exec_ctrl[`WRITE_REG] == decd_ctrl[`READ_REGA] || exec_ctrl[`WRITE_REG] == decd_ctrl[`READ_REGB])
         && exec_ctrl[`INST_TYPE] == `LOAD_INST && exec_ctrl[`EXEC_THIS]
         && decd_ctrl[`INST_TYPE] == `DATA_INST && decd_ctrl[`EXEC_THIS];

  always @(*) begin
    // LDR hazard
    if (data_inst_after_ldr_to_reg || 0)
      stall = 1;
    else 
      stall = 0;
  end

  // Handle register data dependency
  always @(*) begin
    // Regiser A dependencies check
    if (exec_ctrl[`READ_REGA] == forwarding_reg && memw_ctrl[`EXEC_THIS])
      alu_inA = forwarding_data;
    else if (exec_ctrl[`READ_REGA] == regfile_bypass_reg && wrbk_ctrl[`EXEC_THIS])
      alu_inA = regfile_bypass_data;
    else
      alu_inA = data_regA;

    // Regiser B dependencies check
    if (exec_ctrl[`READ_REGB] == forwarding_reg && memw_ctrl[`EXEC_THIS])
      alu_inB = forwarding_data;
    else if (exec_ctrl[`READ_REGB] == regfile_bypass_reg && wrbk_ctrl[`EXEC_THIS])
      alu_inB = regfile_bypass_data;
    else
      alu_inB = data_regB;
  end

  // Handle STR data dependencies
  reg [31:0] raw_mem_address;
  always @(*) begin
    // Address register hazard check
    if (memw_store_addr_reg == regfile_bypass_reg && wrbk_ctrl[`EXEC_THIS])
      raw_mem_address = regfile_bypass_data;
    else if (memw_store_addr_reg == str_delay_reg_buffer && str_delay_write_executed)
      raw_mem_address = str_delay_data_buffer;
    else
      raw_mem_address = memw_store_addr_buffer;

    // Data register hazard check
    if (memw_store_data_reg == regfile_bypass_reg && wrbk_ctrl[`EXEC_THIS])
      mem_write_data = regfile_bypass_data;
    else if (memw_store_data_reg == str_delay_reg_buffer && str_delay_write_executed)
      mem_write_data = str_delay_data_buffer;
    else
      mem_write_data = memw_store_data_buffer;
  end

  // ====================REGISTER MANAGEMENT====================

  // Datapath pipelining
  always @(posedge clk) begin
    exec_bnl_target <= pc_curr + `PC_INCR;
    memw_bnl_target <= exec_bnl_target;
    wrbk_bnl_target <= memw_bnl_target;

    memw_alu_out <= alu_output;
    wrbk_alu_out <= memw_alu_out;

    str_delay_reg_buffer <= wrbk_ctrl[`WRITE_REG];
    str_delay_data_buffer <= reg_write_data;
    str_delay_write_executed <= wrbk_ctrl[`EXEC_THIS];

    wrbk_prepost_index <= adjusted_mem_address;
  end

  // Instructions are LDR/STR?
  wire wrbk_ldr_str = wrbk_ctrl[`INST_TYPE] == `LOAD_INST
                   || wrbk_ctrl[`INST_TYPE] == `STORE_INST;

  // Calculate register write value (data, load, branch+link, store+writeback instructions)
  always @(*) begin
    if (wrbk_ctrl[`INST_TYPE] == `BRANCH_INST) // branch_link, Reading from program counter
      reg_write_data = wrbk_bnl_target;

    else if (wrbk_ctrl[`INST_TYPE] == `DATA_INST) // Data inst result
      reg_write_data = wrbk_alu_out;

    else if (wrbk_ctrl[`INST_TYPE] == `LOAD_INST) // Load from mem
      reg_write_data = mem_read_data;

    // Unsupported: requires pipeline stall
    // else if (str_reg_writeback) // Writeback from STR instruction
    //   reg_write_data = wrbk_prepost_index;

    else
      reg_write_data = 32'bx;
  end


  // ====================MEMORY MANAGEMENT====================

  // Adjusted memory values
  wire [11:0] ls_imm_offset = memw_inst[`LS_IMM_OFFSET_MSB:`LS_IMM_OFFSET_LSB];
  wire add_not_sub = memw_inst[`LS_ADD_NOT_SUB];
  wire memw_ldr_str = memw_ctrl[`INST_TYPE] == `LOAD_INST
                   || memw_ctrl[`INST_TYPE] == `STORE_INST;

  reg [31:0] mem_access_addr;

  always @(posedge clk) begin
    memw_store_addr_buffer <= data_regA;
    memw_store_data_buffer <= data_regB;
  end

  assign mem_write_addr = mem_access_addr;
  assign mem_read_addr = mem_access_addr;

  // Compute adjusted memory address
  always @(*) begin
    if (add_not_sub)
      adjusted_mem_address = raw_mem_address + ls_imm_offset;
    else
      adjusted_mem_address = raw_mem_address + ~{20'b0, ls_imm_offset} + 1;
  end

  // Register address indexing variables
  wire ls_preindex = memw_inst[`LS_PRE_NOT_POST];

  // Calculate memory access address
  always @(*) begin
    if (memw_ldr_str)
      if (ls_preindex)
        mem_access_addr = adjusted_mem_address;
      else
        mem_access_addr = raw_mem_address;
    else
        mem_access_addr = 32'bx;
  end
endmodule