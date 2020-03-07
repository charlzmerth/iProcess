module datapath (
    input wire [`CTRL_VECTOR_SIZE] memw_ctrl, wrbk_ctrl,
    input wire [31:0] memw_inst,
    output reg mem_write_en, reg_write_en,
    output reg [3:0] read_regA, read_regB, write_reg,
    output reg [31:0] mem_read_addr, mem_write_addr
    output reg [31:0] mem_write_data, reg_write_value
  )

  // Write to memory only when memw instruction is a STR
  assign mem_write_en = memw_ctrl[`INST_TYPE] == `STORE_INST;

  // The offset for load/store instruction
  wire [11:0] ls_imm_offset = memw_inst[`LS_IMM_OFFSET_MSB:`LS_IMM_OFFSET_LSB];

  // Add the offset to the memory access address
  wire add_not_sub = memw_inst[`LS_ADD_NOT_SUB];

  // Use pre-indexing for load/store instruction
  wire ls_preindex = memw_inst[`LS_PRE_NOT_POST];

  // Writeback for pre-indexed load/store instruction
  wire writeback_bit = memw_inst[`LS_WRITEBACK_BIT];

  // Current memw instruction is a LDR/STR?
  wire memw_ldr_str = memw_ctrl[`INST_TYPE] == `LOAD_INST || memw_ctrl[`INST_TYPE] == `STORE_INST;

  // Current wrbk instruction is a LDR/STR?
  wire wrbk_ldr_str = wrbk_ctrl[`INST_TYPE] == `LOAD_INST || wrbk_ctrl[`INST_TYPE] == `STORE_INST;

  // Writeback on LDR/STR instruction
  wire ls_reg_writeback = memw_ldr_str && (!ls_preindex || writeback_bit);

  // Read registers from decode stage instruction
  always @(*) begin
    read_regA = decd_ctrl[`READ_REGA];
    read_regB = decd_ctrl[`READ_REGB];
  end

  always @(*) begin
    if (wrbk_ldr_str)
      write_reg = wrbk_ctrl[`READ_REGA];
    else
      write_reg = exec_ctrl[`WRITE_REG];
  end

  // Compute whether to write to register
  assign reg_write_en = branch_link
                     || (exec_ctrl[`INST_TYPE] == `DATA_INST)
                     || (memw_ctrl[`INST_TYPE] == `LOAD_INST)
                     || ls_reg_writeback;

  // Compute adjusted memory address
  reg [31:0] adjusted_mem_address;
  always @(*) begin
    if (add_not_sub)
      adjusted_mem_address = data_regA + ls_imm_offset;
    else
      adjusted_mem_address = data_regA + ~{20'b0, ls_imm_offset} + 1;
  end

  // Calculate register write value (data, load, branch+link, store+writeback instructions)
  always @(*) begin
    if (0) // Reading from program counter
      reg_write_value = pc_curr + `PC_INCR;
    else if (exec_ctrl[`INST_TYPE] == `DATA_INST) // Data inst result
      reg_write_value = alu_output;
    else if (memw_ctrl[`INST_TYPE] == `LOAD_INST) // Load from mem
      reg_write_value = read_mem_data;
    else if (wrbk_ctrl[`INST_TYPE] == `STORE_INST) // Post-indexing
      reg_write_value = adjusted_mem_address;
    else
      reg_write_value = 32'bx;
  end

  // Calculate memory access address
  always @(*) begin
    if (ls_preindex)
      mem_access_addr = adjusted_mem_address;
    else
      mem_access_addr = data_regA;
  end
