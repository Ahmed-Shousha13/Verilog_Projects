module RISC_MUX(
input Sel,[31:0]first_sel,second_sel,
output [31:0]out
);
  assign out = Sel? second_sel:first_sel;
  
endmodule
