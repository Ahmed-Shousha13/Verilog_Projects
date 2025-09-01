module SPI_Slave(
input clk,rst,SS_n,
input tx_valid,MOSI,[7:0] tx_data,
output reg MISO,reg rx_valid, reg [9:0] rx_data
);

/*local parameters*/
localparam zero  = 2'b00,
           one   = 2'b01,
           two   = 2'b10,
           three = 2'b11;


/*general registers*/
reg [1:0]cur_state;//register for storing the current state
reg [1:0]nex_state = zero;//register for storing the next state
reg [7:0] temp_reg;//a register to store the data inputted
reg [3:0] counter;//a register to determine if enough data has been sent
reg busy;//a flag to lock from getting into the next state
reg read;//a flag to inform the SPI that it is receiving data

always @(*)
begin
cur_state = nex_state;
end
always @(posedge clk or negedge rst)
  begin//beginning of the always block
  if (~rst)
    begin//start of reset
      nex_state <= zero;
      cur_state <= zero;
      busy      <= 1'b0;
      counter   <= 0;
      temp_reg  <= 0;
      rx_data   <=0;
      rx_valid  <=0;
      MISO      <=0;
      read <=0;
    end//end of reset
    
  else
    begin//clock
    
    case(cur_state)
      zero:
        begin
          rx_valid <=1'b0;
          counter <=0;
          MISO <=0;
          rx_data <=0;
        end
      one:
        begin
          //another idle state, just waiting to receive the bits
        end
      two://read
       begin//read state beginning
        //1- receive
        if(rx_valid)
            rx_valid <=1'b0;
        else if(tx_valid)//reading from RAM
                  begin       
                    temp_reg <=tx_data;
                  end
        else if(busy)
          begin
            if(counter <10)
              begin
              rx_data <={rx_data[8:0],MOSI};
              counter <=counter+1;  
              end
            else//the full data has been received
              begin
                counter <=0;
                rx_valid <=1;//sending data to RAM
                busy <=0;
                read <= &rx_data[9:8];
              end
          end
        else if(read)//now I should be sending data to the master
          begin
            if(counter <8)
              begin
              MISO <=temp_reg[7];
              temp_reg <= {temp_reg[6:0],1'b0};
              counter <=counter+1;
            end
        else
          begin
            MISO <=0;
            read <=0;
          end
      end
       end//read state end
      three://write
       begin//write state beginning
        //1- receive
            if(counter < 10)//still receiving
              begin
              rx_data <= {rx_data[8:0],MOSI};//most significant bit received first
              counter <= counter+1;
              end
            else//all bits received
              begin
              rx_data <= rx_data; //preventing latches
              rx_valid <=1;//initiating RAM communication
              counter <=0;
              busy <=0;
            end
        
       end//write state end
    endcase
      end//clock
  end//end of the always block
  
  always @(posedge clk)//transition logic
  begin//beginning of the always block
    case(cur_state)
    
      zero://0th state does nth so no more logic is needed
      begin//0th state beginning(Idle)
        if(~SS_n)
          nex_state <= one;
        else
          nex_state <= zero;
      end//0th state end
      
      one: //1st state waits for the command
      begin//1st state beginning
        if(~SS_n)
          begin//~SS_n
            if(MOSI)//will go to the read states
            begin
              nex_state <= two;
              busy <= 1'b1;//to indicate that data is being sent
            end
            else//go to the write state
            begin
              nex_state <= three;
              busy <= 1'b1;//to indicate that data is being received
            end
          end//~SS_n
        else
          begin//SS_n
            nex_state <= zero;
          end//SS_n
      end//first state end
      
      two://reading state, sending the reading address 
      begin//2nd state
        if(SS_n || ~(busy || read))
            nex_state <= zero;
        else
          begin//means it is still receiving
            nex_state <= two;
          end
      end//end of the second state's transition
      
      three://writing state, I need to lock it until data is fully written
      begin//third state
        if(SS_n || (~busy))
        begin
            nex_state <= zero;
            rx_valid <= 1'b0;
        end
        else //means it is still sending
            nex_state <= three;
      end//end of the third state's transition
  
    endcase
  end//end of the always block
  
  
endmodule
