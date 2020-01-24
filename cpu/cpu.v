module cpu(
  input wire clk,
  input wire nreset,
  output wire led,
  output wire [7:0] debug_port1,
  output wire [7:0] debug_port2,
  output wire [7:0] debug_port3,
  output wire [7:0] debug_port4,
  output wire [7:0] debug_port5,
  output wire [7:0] debug_port6,
  output wire [7:0] debug_port7
);

/*
1. inst = code_memory[pc]
2. pc = pc + 4
----clock cycle boundary
3. if (inst == branch)
4.     pc = compute_target(pc, inst)

5. r1 = register_file(rm(inst));
6. r2 = register_file(rn(inst));
*/

  reg [31:0] code_memory [0:31];
  wire [31:0] inst;
  wire loaded;

  always @(posedge clk) begin
    if (loaded == 0) begin
      inst <= code_memory[pc];
      pc <= pc + 4;
      loaded <= 1;
    end
    else begin
      if (inst == branch) begin
        pc = compute_target(pc, inst);
        loaded <= 0;
      end
    end
  end

  // Controls the LED on the board.
  assign led = 1'b1;

  // These are how you communicate back to the serial port debugger.
  assign debug_port1 = 8'h01;
  assign debug_port2 = 8'h02;
  assign debug_port3 = 8'h03;
  assign debug_port4 = 8'h04;
  assign debug_port5 = 8'h05;
  assign debug_port6 = 8'h06;
  assign debug_port7 = 8'h07;

endmodule
