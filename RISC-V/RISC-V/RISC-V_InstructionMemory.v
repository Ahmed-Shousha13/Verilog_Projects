module InstructionMemory(
input [31:0]PC,
output [31:0] Instruction
);
reg [31:0] memory[0:63];
initial begin
  $readmemh("program.txt",memory);
end
assign Instruction = memory[PC[31:2]];
  
endmodule
