// Prevent successive "includes" of this file
`ifndef _arm_constants
`define _arm_constants

// Design Constants
`define CODE_DATA "C:\\Users\\merthc\\Desktop\\iProcess\\testcode\\experimental\\add\\addtestcall.hex"
`define CODE_MEM_SIZE 1024
`define DATA_MEM_SIZE 4096
`define PC_REGISTER 15

// Pipeline Vectors
`define CTRL_VECTOR_SIZE 15:0
`define INST_TYPE 15:14
`define READ_REGA 13:10
`define READ_REGB 9:6
`define WRITE_REG 5:2
`define REG_WR_EN 1:1
`define COND_VALID 0:0

// Condition Codes
`define COND_EQ 4'b0000
`define COND_NE 4'b0001
`define COND_CS 4'b0010
`define COND_CC 4'b0011
`define COND_MI 4'b0100
`define COND_PL 4'b0101
`define COND_VS 4'b0110
`define COND_VC 4'b0111
`define COND_HI 4'b1000
`define COND_LS 4'b1001
`define COND_GE 4'b1010
`define COND_LT 4'b1011
`define COND_GT 4'b1100
`define COND_LE 4'b1101
`define COND_AL 4'b1110
`define COND_NV 4'b1111

// Instruction Types
`define DATA_INST 3'b00
`define LOAD_INST 3'b01
`define STORE_INST 3'b10
`define BRANCH_INST 3'b11

// Global Instruction Constants
`define PC_INCR 4
`define COND_MSB 31
`define COND_LSB 28
`define CODE_MSB 27
`define CODE_LSB 25
`define OP_MSB 24
`define OP_LSB 21
`define RN_MSB 19
`define RN_LSB 16
`define RD_MSB 15
`define RD_LSB 12
`define RM_MSB 3
`define RM_LSB 0

// Branch Instruction Bits
`define LINK_REGISTER 14
`define B_CODE 3'b101
`define B_LINK_BIT 24
`define B_OFFSET_MSB 23
`define B_OFFSET_LSB 0
`define B_OFFSET_SHIFT 2

// Data Processing Instruction Bits
`define S_UPDATE_BIT 20
`define D_CODE 3'b000
`define D_REG_CODE 3'b000
`define D_IMM_CODE 3'b001

// Shifting Instruction Bits
`define REG_SHIFT_IMM_MSB 11
`define REG_SHIFT_IMM_LSB 7
`define REG_SHIFT_CODE_MSB 6
`define REG_SHIFT_CODE_LSB 5
`define REG_SHIFT_REG_MSB 3
`define REG_SHIFT_REG_LSB 0

`define REG_SHIFT_CODE_LSR 2'b00
`define REG_SHIFT_CODE_LSL 2'b01
`define REG_SHIFT_CODE_ASR 2'b10
`define REG_SHIFT_CODE_RTR 2'b11

`define SHIFT_IMM_BIT 25
`define IMM_SHIFT_ROT_MSB 11
`define IMM_SHIFT_ROT_LSB 8
`define IMM_SHIFT_VAL_MSB 7
`define IMM_SHIFT_VAL_LSB 0

// Arithmetic Logic Unit Constants (opcodes)
`define AND 4'b0000
`define EOR 4'b0001
`define SUB 4'b0010
`define RSB 4'b0011
`define ADD 4'b0100
`define ADC 4'b0101
`define SBC 4'b0110
`define RSC 4'b0111
`define TST 4'b1000
`define TEQ 4'b1001
`define CMP 4'b1010
`define CMN 4'b1011
`define ORR 4'b1110
`define MOV 4'b1101
`define BIC 4'b1110
`define MVN 4'b1111

// Load/Store Immediate Instruction Bits
`define LS_IMM_CODE 3'b010
`define LS_PRE_NOT_POST 24
`define LS_ADD_NOT_SUB 23
`define LS_WRITEBACK_BIT 21
`define LS_IMM_LOAD_BIT 20
`define LS_BASE_REG_MSB 19
`define LS_BASE_REG_LSB 16
`define LS_DEST_REG_MSB 15
`define LS_DEST_REG_LSB 12
`define LS_IMM_OFFSET_MSB 11
`define LS_IMM_OFFSET_LSB 0

// Load/Store Register Instruction Bits
`define L_CODE 3'b011

`endif
