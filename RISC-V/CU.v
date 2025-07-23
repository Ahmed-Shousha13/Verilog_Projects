module RISCcu(
input [6:0]op, [2:0]funct3,
input funct7,Zero,Sign,
output reg PCSrc,ResultSrc,MemWrite,
output reg [2:0] ALUControl,
output reg ALUSrc,
output reg [1:0] ImmSrc,
output reg RegWrite
);
reg [1:0]ALUOp;
reg Branch;
always @(*)
begin
  case(op)
    7'b000_0011:
    begin
      {RegWrite,ImmSrc,ALUSrc,MemWrite,ResultSrc,Branch,ALUOp}={1'b1,2'b00,1'b1,1'b0,1'b1,1'b0,2'b00};
    end
  7'b010_0011:
    begin
       {RegWrite,ImmSrc,ALUSrc,MemWrite,ResultSrc,Branch,ALUOp}={1'b0,2'b01,1'b1,1'b1,1'b1,1'b0,2'b00};
    end
  7'b011_0011:
  begin
     {RegWrite,ImmSrc,ALUSrc,MemWrite,ResultSrc,Branch,ALUOp}={1'b1,2'b00,1'b0,1'b0,1'b0,1'b0,2'b10};
  end
  
  7'b001_0011:
  begin
     {RegWrite,ImmSrc,ALUSrc,MemWrite,ResultSrc,Branch,ALUOp}={1'b1,2'b00,1'b1,1'b0,1'b0,1'b0,2'b10};
  end
  7'b110_0011:
  begin
     {RegWrite,ImmSrc,ALUSrc,MemWrite,ResultSrc,Branch,ALUOp}={1'b0,2'b10,1'b0,1'b0,1'b1,1'b1,2'b01};
  end
  default:
  begin
    {RegWrite,ImmSrc,ALUSrc,MemWrite,ResultSrc,Branch,ALUOp}={1'b0,2'b00,1'b0,1'b0,1'b0,1'b0,2'b00};
  end
endcase
case(ALUOp)
  2'b00:
  begin
  ALUControl = 3'b000;
  PCSrc = 1'b0;
end
  2'b01://branching
  begin
      case(funct3)
        3'b000:
        begin
          PCSrc = Branch & Zero;
          ALUControl = 3'b010;
        end
        3'b001:
        begin
          PCSrc = Branch & !Zero;
          ALUControl = 3'b010;
        end
        3'b100:
        begin
          PCSrc = Branch & Sign;
          ALUControl = 3'b010;
        end
        default:
        begin
        PCSrc = 0;
       ALUControl = 3'b000;
     end
     endcase
        
    end
    2'b10:
    begin
      if(!(|funct3))
        begin
          if(&{op[5],funct7})
            begin
            ALUControl = 3'b010;
            PCSrc = 1'b0;
          end
            else
              begin
              ALUControl = 3'b000;
              PCSrc = 1'b0;
            end
          end
          else
            begin
              ALUControl = funct3;
              PCSrc = 1'b0;
            end
      end
      
      default:
      begin
        ALUControl = 3'b000;
        PCSrc = 1'b0;
        end
        endcase
end 
  
  
endmodule