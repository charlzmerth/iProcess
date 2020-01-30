`import arm_constants.v
module decode_inst (
    input wire [31:0] inst;
    output reg [3:0] read_regA, read_regB, write_reg;
    output reg branch_inst, data_inst, load_inst, write_en;
  );

  // Constants for instruction type
  parameter BRANCH_INST = 2'b00;
  parameter DATA_INST = 2'b01;
  parameter LOAD_INST = 2'b10;

  always @(*) begin
    read_regA = isnt[`RM_MSB:`RM_LSB];
    read_regB = isnt[`RN_MSB:`RN_LSB];
    write_reg = inst[`RD_MSB:`RD_LSB];

    case (branch = inst[`COND_MSB:`COND_LSB])
      // Branch instruction
      B_CODE: begin
                branch_inst = 1;
                data_inst = 0;
                load_inst = 0;
              end

      // Data processing instruction
      D_CODE: begin
                branch_inst = 0;
                data_inst = 1;
                load_inst = 0;
              end

      // Load instruction
      L_CODE: begin
                branch_inst = 0;
                data_inst = 0;
                load_inst = 1;
              end

      default: {branch_inst, data_inst, load_inst} <= 'x;
    endcase
  end
endmodule
