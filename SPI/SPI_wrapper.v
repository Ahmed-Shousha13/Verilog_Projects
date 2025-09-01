module SPI_wrapper(
input clk,rst,SS_n,MOSI,
output MISO
);
/*wires*/
wire tx_valid,rx_valid;
wire [7:0] tx_data;
wire [9:0] rx_data;
/*instantiations*/
SPI_Slave Slave_inst(
.clk(clk),
.rst(rst),
.MISO(MISO),
.MOSI(MOSI),
.SS_n(SS_n),
.tx_valid(tx_valid),
.rx_valid(rx_valid),
.tx_data(tx_data),
.rx_data(rx_data));
RAM RAM_inst(
.clk(clk),
.rst(rst),
.tx_valid(tx_valid),
.rx_valid(rx_valid),
.din(rx_data),
.dout(tx_data));

  
endmodule
