// Condition Codes
parameter COND_EQ = 4'b0000;
parameter COND_NE = 4'b0001;
parameter COND_CSHS = 4'b0010;
parameter COND_CCLO = 4'b0011;
parameter COND_MI = 4'b0100;
parameter COND_PL = 4'b0101;
parameter COND_VS = 4'b0110;
parameter COND_VC = 4'b0111;
parameter COND_HI = 4'b1000;
parameter COND_LS = 4'b1001;
parameter COND_GE = 4'b1010;
parameter COND_LT = 4'b1011;
parameter COND_GT = 4'b1110;
parameter COND_LE = 4'b1101;
parameter COND_AL = 4'b1110;
parameter COND_NV = 4'b1111;

// Global Instruction Constants
parameter COND_MSB = 31;
parameter COND_LSB = 28;
parameter RN_MSB = 19;
parameter RN_LSB = 16;
parameter RD_MSB = 15;
parameter RD_LSB = 12;
parameter RM_MSB = 3;
parameter RM_LSB = 0;

// Branch Instruction Bits
parameter BRANCH_CODE = 3'b101;
parameter B_LINK_BIT = 24;
parameter B_OFFSET_MSB = 23;
parameter B_OFFSET_LSB = 0;

// Data Processing Instruction Bits
parameter DATA_CODE = 3'b000;
// ========== SHIFT BITS HERE ========== //

// Load/Store Instruction Bits
parameter LS_IMMEDIATE_CODE = 3'b010;
parameter LS_IMMETIATE_OFFSET_MSB = 11;
parameter LS_IMMETIATE_OFFSET_LSB = 0;
