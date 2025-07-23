module Reg_File(
input WE3,clk,rst, [31:0] WD3, [4:0]A1,[4:0]A2,[4:0]A3,
output [31:0] RD1,[31:0]RD2 
);
reg [31:0] register_file [0:31];//32 entries and 32 bits per entry
integer i;
/*synchronous part(write)*/
always @(posedge clk or negedge rst)
begin//beginning of the always block
if(!rst)
  begin
for(i = 0;i<32; i = i+1)
begin
  register_file[i] = {32{1'b0}};
end
end
else
  begin
if(WE3)
  begin//beginning of the if
    register_file[A3] <= WD3;
  end//end of the if
  
else
  begin//beginning of the else
  //do nth
  end//end of the else
end
end//end of the always block

/*asynchronous part (read)*/
assign RD1 = register_file[A1];
assign RD2 = register_file[A2];
  
  
endmodule
