module sign(
input [31:7] Instr,[1:0]Immext,
output reg [31:0] num_output
);
  
always @(*)
begin
  case(Immext)
    2'b00:
    num_output = {{20{Instr[31]}},Instr[31:20]};
    2'b01:
    num_output = {{20{Instr[31]}},Instr[31:25],Instr[11:7]};
    2'b10:
    num_output = {{20{Instr[31]}},Instr[7],Instr[30:25],Instr[11:8],1'b0};
    default:
    num_output =0;
endcase
end


  
endmodule
