// Test bench for ALU
`timescale 1ns/10ps

// Meaning of signals in and out of the ALU:

// Flags:
// N_flag: whether the out output is negative if interpreted as 2's comp.
// Z_flag: whether the out output was a 32-bit zero.
// V_flag: on an add or subtract, whether the computation overflowed if the inputs are interpreted as 2's comp.
// C_flag: on an add or subtract, whether the computation produced a carry-out.

// cntrl			Operation						Notes:
// 000:			out = B						value of V_flag and C_flag unimportant
// 010:			out = A + B
// 011:			out = A - B
// 100:			out = bitwise A & B		value of V_flag and C_flag unimportant
// 101:			out = bitwise A | B		value of V_flag and C_flag unimportant
// 110:			out = bitwise A XOR B	value of V_flag and C_flag unimportant

module alu_tb();

	parameter delay = 100000;

  reg	[31:0] regA, regB;
	reg	[31:0] inst;
	wire	[31:0] out;
	wire	N_flag, Z_flag, V_flag, C_flag;
  wire update_CPSR, ignore_C_flag;

//	parameter ALU_PASS_B=3'b000, ALU_ADD=3'b010, ALU_SUBTRACT=3'b011, ALU_AND=3'b100, ALU_OR=3'b101, ALU_XOR=3'b110;


	alu dut (.regA, .regB, .inst, .out, .update_CPSR, .ignore_C_flag, .N_flag, .Z_flag, .V_flag, .C_flag);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	integer i;
	initial begin

//		$display("%t testing PASS_A operations", $time);
//		inst = ALU_PASS_B;
//		for (i=0; i<100; i++) begin
//			regA = $random(); regB = $random();
//			#(delay);
//			assert(out == regB && N_flag == regB[31] && Z_flag == (regB == '0));
//		end

		$display("%t testing addition", $time);
		    // 32'b1110 0000 1000 0000 0000 0000 0000 0010
		inst = 32'b11100000100000000000000000000010;
		$display("inst = %b", inst);
		regA = 32'b1; regB = 32'b1;
		#(delay);
//		assert(out == 32'b10 && C_flag == 0 && V_flag == 0 && N_flag == 0 && Z_flag == 0);
		$display("out = %b", out);
		$display("shifter_out = %b", dut.shifter_out);
		$display("imm_shift_val = %b", dut.s.imm_shift_val);
		$display("C_flag = %b", C_flag);
		$display("V_flag = %b", V_flag);
		$display("N_flag = %b", N_flag);
		$display("Z_flag = %b", Z_flag);
	end
endmodule
