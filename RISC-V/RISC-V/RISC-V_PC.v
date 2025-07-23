module RISCV_PC(
input clk,rst,load,PCSrc,[31:0] Imm,
output reg [31:0] PC
);
reg [31:0] PCNext;
wire [31:0] PCplus4;
wire [31:0] PCplusimm;
assign PCplus4 = PC+4;
assign PCplusimm = PC+Imm;

always @(*)
begin
PCNext = PCSrc? PCplusimm:PCplus4;
end

always @(posedge clk or negedge rst)
begin//beginning of the always block
if(!rst)
  begin
  PC <=0;
end
else
  begin//beginning of the case where the posedge clk occurred 
  
    if(!load)
      PC <= PC;
    else//here I am loading the next instruction's address value
   PC <=PCNext;
  end//end of the case where the posedge clk occurred
  
end//end of the always block
  
  
  
  
endmodule
