module Data_Memory(
  input clk, WE, [31:0]A,[31:0]WD,
  output [31:0]RD
  );
  /*memory units*/
  reg [31:0]data_reg[0:63];
  /*synchronous part (write)*/
  always @(posedge clk)
  begin
    if(WE)
      begin/*beginning of the if*/
        if(A[31])
      data_reg[-(A[31:2])] <= WD;
    else
      data_reg[A[31:2]] <=WD;
    end/*end of the if*/
    else
      begin
        /*do nth*/
      end
  end
  
  
  
  /*asynchronous part (read)*/
  assign RD = data_reg[A[31]? -(A[31:2]):A[31:2]];
  endmodule
