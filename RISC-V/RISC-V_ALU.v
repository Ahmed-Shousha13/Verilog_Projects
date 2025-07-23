module RISCV_ALU(
input [31:0] SrcA,SrcB,//inputs
input [2:0] ALUControl,//OP code
output reg [31:0] ALUResult,//resultant of the operation
output reg Zero_flag, Sign_flag//flags indicating the state of the output
);

always @(ALUControl or SrcA or SrcB)
begin//beginning of the always block
  case(ALUControl)
    
  3'b000://adding the 2 operands
  begin//beginning of the first instruction
    ALUResult = SrcA + SrcB;
    Zero_flag = !(|ALUResult);//reduction OR is used to check if there are any ones in the result
    Sign_flag = ALUResult[31];
  end//end of the first instruction
    
  3'b001://shifting left by a specific value
  begin//beginning of the second instruction
    ALUResult = SrcA<<SrcB;
    Zero_flag = !(|ALUResult);
    Sign_flag = ALUResult[31];
  end//end of the second instruction
  
  3'b010://subtracting the 2 operands
  begin //beginning of the third instruction
    ALUResult = SrcA - SrcB;
    Zero_flag = !(|ALUResult);
    Sign_flag = ALUResult[31];
  end//end of the third instruction
  
  3'b100://XOR between the 2 operands
  begin//beginning of the fourth instruction
    ALUResult = SrcA^SrcB;
    Zero_flag = !(|ALUResult);
    Sign_flag = ALUResult[31];
  end//end of the fourth instruction
  
  3'b101://shift right by a set value
  begin//beginning of the fifth instruction
    ALUResult = SrcA>>SrcB;
    Zero_flag = !(|ALUResult);
    Sign_flag = ALUResult[31];
  end//end of the fifth instruction
  
  3'b110:
  begin//beginning of the sixth instruction
    ALUResult = SrcA|SrcB;
    Zero_flag = !(|ALUResult);
    Sign_flag = ALUResult[31];
  end//end of the sixth instruction
  
  3'b111:
  begin//beginning of the seventh instruction
    ALUResult = SrcA&SrcB;
    Zero_flag = !(|ALUResult);
    Sign_flag = ALUResult[31];
  end//end of the seventh instruction
  
  default:
  begin//beginning of the default
    {ALUResult,Zero_flag,Sign_flag} = 0;
  end//end of the default
endcase//end of the case statement
  
end//end of the always block

endmodule
