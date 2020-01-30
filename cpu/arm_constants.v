// Prevent successive "includes" of this file
`ifndef _arm_constants
`define _arm_constants

// Design Constants
`define CODE_MEM_SIZE 128

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
`define COND_GT 4'b1110
`define COND_LE 4'b1101
`define COND_AL 4'b1110
`define COND_NV 4'b1111

// Global Instruction Constants
`define PC_INCR 4
`define COND_MSB 31
`define COND_LSB 28
`define CODE_MSB 27
`define CODE_LSB 25
`define RN_MSB 19
`define RN_LSB 16
`define RD_MSB 15
`define RD_LSB 12
`define RM_MSB 3
`define RM_LSB 0

// Branch Instruction Bits
`define BRANCH_CODE 3'b101
`define B_LINK_BIT 24
`define B_OFFSET_MSB 23
`define B_OFFSET_LSB 0
`define B_OFFSET_SHIFT 2

// Data Processing Instruction Bits
`define DATA_CODE 3'b000
// ========= SHIFT BITS HERE ========= //

// Load/Store Immediate Instruction Bits
`define LS_IMM_CODE 3'b010
`define LS_IMM_OFFSET_MSB 11
`define LS_IMM_OFFSET_LSB 0

// Load/Store Register Instruction Bits
`define LS_REG_CODE 3'b011;

`endif
