module RAM(
input clk,rst,rx_valid,
input [9:0] din,
output reg tx_valid,
output reg [7:0] dout
);
integer i;
reg [7:0] memory [0:255];
reg [7:0] read_add;
reg [7:0] write_add;
  always @(posedge clk or negedge rst)
  begin /*beginning of the always block*/
  if (~rst)
    begin/*beginning of rst logic*/
    for(i=0;i<256;i = i+1)
      begin//beginning of the memory reset
         memory[i] = 8'b0;
      end//end of the memory reset
      read_add <=0;
      write_add <=0;
      tx_valid <=0;
      dout <=0; 
    end/*end of rst logic*/
    else
      begin//beginning of circuit logic
            if(rx_valid)
            begin
            case(din[9:8])
              2'b00:
              begin
              write_add <=din[7:0];
              tx_valid <= 1'b0;
              end
              2'b01:
              begin
              memory[write_add] <= din[7:0];
              tx_valid <=1'b0;
              end
              2'b10:
              begin
              read_add <= din[7:0];
              tx_valid <=1'b0;
              end
              2'b11:
              begin
              tx_valid <=1;
              dout <=memory[read_add];
              end
              endcase
              end
           else
           tx_valid <=1'b0;
         end
  end/*end of the always block*/
endmodule
