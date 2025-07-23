module RISCV_top(
input clk,rst,load
);
//ALU wires
  wire [31:0] OP1;//first operand for the ALU
  wire [31:0] OP2;//second operand for the ALU
  wire [2:0] ALUControl;//control for which ALU operation
  wire [31:0] ALUResult;//to store the result
  wire Zero,Sign;//flags
  //PC wires
  wire PCSrc;
  wire [31:0] Imm;
  wire [31:0] PC;
  //Instruction memory wires
  wire [31:0] Instruction;
  //reg file wires
  wire [31:0] WD3;
  wire [31:0]RD2;
  //data memory wires
  wire [31:0] RD;
  //control unit wires
  wire RegWrite;
  wire MemWrite;
  wire ResultSrc;
  wire ALUSrc;
  wire [1:0] ImmSrc;
  //accessing the registers
  RISCV_ALU top_ALU(OP1,OP2,ALUControl,ALUResult,Zero,Sign);//works
  RISCV_PC  top_PC(clk,rst,load,PCSrc,Imm,PC);//works
  InstructionMemory topImemory(PC,Instruction);//works
  Reg_File topRegfile(.WE3(RegWrite),.clk(clk),.rst(rst),.WD3(WD3),.A1(Instruction[19:15]),.A2(Instruction[24:20]),.A3(Instruction[11:7]),.RD1(OP1),.RD2(RD2));//works
  Data_Memory topmemory(clk,MemWrite,ALUResult,RD2,RD);//works
  RISCcu mycontrolunit(.op(Instruction[6:0]),.funct3(Instruction[14:12]),.funct7(Instruction[30]),.Zero(Zero),.Sign(Sign),.PCSrc(PCSrc),
  .ResultSrc(ResultSrc),.MemWrite(MemWrite),.ALUControl(ALUControl),.ALUSrc(ALUSrc),.ImmSrc(ImmSrc),.RegWrite(RegWrite));
  sign topsignextension(Instruction[31:7],ImmSrc,Imm);//probably works
  RISC_MUX firstmux(ALUSrc,RD2,Imm,OP2);//works (of course)
  RISC_MUX secondmux(ResultSrc,ALUResult,RD,WD3);//works (of course)
endmodule

