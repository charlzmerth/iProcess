module sign_extend
  #(parameter IN=8,
    parameter OUT=16) (
	
	input wire [IN-1:0] in_wire;
	output wire [OUT-1:0] out_wire;
  );
  

  // Repeat MSB OUT-IN times, concatenate with in_wire
  assign out_wire = { OUT-IN {in_wire[IN-1]}, in_wire };
endmodule