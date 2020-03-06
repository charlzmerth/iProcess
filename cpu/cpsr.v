module cpsr (
    input wire clk, reset, update_CPSR, ignore_C_flag,
    input wire N_flag_temp, Z_flag_temp, C_flag_temp, V_flag_temp,
    output reg N_flag, Z_flag, C_flag, V_flag
  );

  always @(posedge clk) begin
    if (reset) begin
      N_flag <= 0;
      Z_flag <= 0;
      V_flag <= 0;
      C_flag <= 0;
    end
    else if (update_CPSR) begin
      N_flag <= N_flag_temp;
      Z_flag <= Z_flag_temp;
      V_flag <= V_flag_temp;

      if (~ignore_C_flag)
        C_flag <= C_flag_temp;
    end
  end
endmodule
