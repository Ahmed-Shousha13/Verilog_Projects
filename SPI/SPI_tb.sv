/*-------------types declared-------------*/
typedef enum logic [1:0]
{WRITE_A = 2'b00,
 WRITE   = 2'b01,
 READ_A  = 2'b10,
 READ    = 2'b11   } MODE;/*this will be used to 
                                  send the command to the slave*/
typedef struct{
bit [7:0] address;
bit [7:0] data;}
packet;/*packet containing where the data will be written 
        and the data itself*/
/*-------------interface-------------*/
interface SPI_int(input bit clk);
bit rst,SS_n,MOSI,MISO;
/*-------------modports-------------*/
modport top(input rst, SS_n, clk, MOSI, 
            output MISO);
modport tb(clocking cb,input clk, import send_slave, receive_slave);
/*-------------clocking block-------------*/
clocking cb @(posedge clk);
  input MISO;
  output rst,SS_n,MOSI;
endclocking

/*-------------tasks-------------*/
task automatic send_slave(ref packet info,input MODE op);
  bit [2:0] i;//counter to keep track of the Nth bit sent
  i = 3'b111;
  /*switch over to the state where I would be reading/writing*/
  if(op == WRITE || op == WRITE_A)begin
    cb.MOSI <= 1'b0;end
else if(op == READ || op == READ_A)begin
    cb.MOSI <= 1'b1;end
    @(negedge clk);// a clock cycle to transition over to the next state (read or write)

/*send the command*/
cb.MOSI <= op[1];
@(negedge clk);
cb.MOSI <= op[0];


repeat(8) begin//send the data/address over the MOSI port
    @(negedge clk);
    if(op == WRITE || op == READ)//I will need to send the data
      cb.MOSI <= info.data[i--];
    else if(op == WRITE_A || op ==READ_A)//I will need to send the address
      cb.MOSI <= info.address[i--];
    else
      $display("wrong mode, please input a valid mode in the code");
end
  
endtask

task automatic receive_slave(ref bit[7:0] data_read);
  data_read = 0;
  repeat(3)
  @(negedge clk);
  for(int i=7;i>=0;i--) begin
    @(negedge clk);
    data_read[i] = cb.MISO; 
  end
endtask
endinterface



/*-------------main testbench-------------*/
module SPI_tb#(parameter numpackets = 10)
              (SPI_int.tb inter);
bit [7:0] scoreboard[$];// a queue of the expected results
bit [7:0] resultboard[$];//a queue to keep track of the results outputted
bit [7:0] tempdata;//just a temporary place to store the returned data
packet    packetq[$];//a queue of packets to keep track of the packets needed to be sent
initial begin
/*port initializations*/
inter.cb.SS_n <= 1'b1;

/*initialize the queues*/
repeat (numpackets) begin
packetq.push_back('{$urandom,$urandom});//put random values for data in random places in the RAM
scoreboard.push_back(packetq[$].data);//initializing the scoreboard with values I am expecting the resultboard to have
end   
/*end of queue initializations*/
@(negedge inter.clk);
/*reset sequence*/
inter.cb.rst <= 1'b1;//just assert its value to be 1
#3 //some delay
inter.cb.rst <= 1'b0;//asserting a reset
#3
inter.cb.rst <= 1'b1;//de-asserting the reset
/*end of reset sequence*/

/*send all packets*/
for(int i =0;i <numpackets;i++) begin
  @(negedge inter.clk);//wait for a negative edge
  inter.cb.SS_n <= 1'b0;//go to state 1
  @(negedge inter.clk);//wait for a negative edge (now at state 1)
  inter.send_slave(.info(packetq[i]),.op(WRITE_A));//send over the write address
  @(negedge inter.clk);//data got sent to the RAM
  
  @(negedge inter.clk);//now I am back at the 0th state
  inter.cb.SS_n <= 1'b1;//state 0
  @(negedge inter.clk);
  inter.cb.SS_n <= 1'b0;//state 1
  @(negedge inter.clk);
  inter.send_slave(.info(packetq[i]),.op(READ_A));//send over the address from where I will read
  @(negedge inter.clk);//data got sent to the RAM
  
  @(negedge inter.clk);//now I am back at the 0th state
  inter.cb.SS_n <= 1'b1;
  @(negedge inter.clk);
  inter.cb.SS_n <= 1'b0;//state 1
  @(negedge inter.clk);
  inter.send_slave(.info(packetq[i]),.op(WRITE));//send over the data to be written
  @(negedge inter.clk);//data got sent to the RAM
  
  @(negedge inter.clk);//now I am back at the 0th state
  inter.cb.SS_n <= 1'b1;
  @(negedge inter.clk);
  inter.cb.SS_n <= 1'b0;//state 1
  @(negedge inter.clk);
  inter.send_slave(.info(packetq[i]),.op(READ));//send over a command to read the data
  @(negedge inter.clk);//data got sent to the RAM
  @(negedge inter.clk);//data got sent back to the slave
  @(negedge inter.clk);//slave is ready to send back the data
  inter.receive_slave(.data_read(tempdata));
  resultboard.push_back(tempdata);
  inter.cb.SS_n <= 1'b1;
end

/*now to check for all the results*/
foreach(scoreboard[i]) begin
  assert(scoreboard[i] == resultboard[i])
  $display("scoreboard[%0d]:%0d",i,scoreboard[i]," resultboard[%0d]:%0d",i,resultboard[i],"\ntest case passed");
  else
  $display("scoreboard[%0d]:%0d",i,scoreboard[i]," resultboard[%0d]:%0d",i,resultboard[i],"\ntest case failed");
  end
  //end of logic checking for values
  $finish;
end//end of the initial block
endmodule
/*-------------clock generator-------------*/
module clk_gen #(parameter H_PERIOD =5ns) 
                (clk);
  /*signals*/
  output bit clk;
  /*code*/
  initial begin
    clk = 0;
    forever #H_PERIOD clk <= ~clk;
  end
endmodule
  
/*-------------top-------------*/
module SPI_tb_top();
  /*port names*/
  bit clk;
  /*instantiations*/
  clk_gen generator(clk);
  SPI_int myint(clk);
  SPI_tb #(.numpackets(100))tb (myint.tb);
  SPI_wrapper tb_wrapper(.clk(clk), .rst(myint.rst), .SS_n(myint.SS_n), .MOSI(myint.MOSI), .MISO(myint.MISO));
endmodule
