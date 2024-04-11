`timescale 1ns / 1ps


module A_sp_slave(
          MAIN_CLK,		  
		  LINK_OK,  
		  EN_OUT,
		  S_CLK, //serial pins               
		  S_DATA,//serial pins
		  IN_REG_1, IN_REG_2,
		  CMD_IN, 
		  OUT_REG_1, OUT_REG_2, 
		  CMD_OUT 
    );

parameter DEV_ID    = 4'h1;
parameter GAP_PAUSE = 8'd100;	 	 

input     	MAIN_CLK;
output reg	LINK_OK;
output reg  EN_OUT;
 
input       S_CLK;  //in slave: S_CLK - input
inout     	S_DATA;   
	 

output reg [31:0]IN_REG_1, IN_REG_2;
input      [31:0]OUT_REG_1, OUT_REG_2;
	 
output reg [7:0]CMD_IN;
input      [7:0]CMD_OUT;

wire fDataIn;// filtered s_data
wire fClk;   // filtered s_clk
 

frFilter	clkFl (MAIN_CLK, S_CLK, fClk); //only in slave device
frFilter	dataFl(MAIN_CLK, S_DATA, fDataIn); 	
	
 	 

reg prepClk;
reg[7:0]crc8;

reg[7:0]crcShft; 
reg[7:0]bitCnt;
reg[7:0]rstOutCnt;
reg[79:0]crcReg;

reg sData;
 
wire [7:0]crcIn; 
wire [79:0]W_OUT_REG_; 


assign W_OUT_REG_[31:0 ] = OUT_REG_1;
assign W_OUT_REG_[63:32] = OUT_REG_2;
assign W_OUT_REG_[71:64] = CMD_OUT;
assign W_OUT_REG_[79:72] = crc8; 
 
wire [7 :0]startByte; 
assign startByte = {4'h6, DEV_ID[3:0]};
 
 
reg[87:0]inReg; 

assign crcIn = inReg[87:80]; 
 
reg [3:0]crcCnt; 
//---- SHIFT OUT DATA --------------	 

 
assign S_DATA = EN_OUT ? sData : 1'bZ;
 
task TSK_CLK_CONTROL;
	begin
		if(fClk != prepClk)begin
			prepClk <= fClk;
			rstOutCnt<=0; 
			if(fClk)begin                     
				 
			end	else begin
				bitCnt<=bitCnt+1'b1;					
			end	
		end else begin
			rstOutCnt<=rstOutCnt+1'b1;
			if(rstOutCnt>GAP_PAUSE)begin
				bitCnt     <= 0;
				rstOutCnt  <= 0;
			end
		end				
	end
endtask
 
task TSK_PUSH_PULL_DATA;
	begin
		sData        <= W_OUT_REG_[bitCnt-8];
		inReg[bitCnt]<=fDataIn;		
	end
endtask 
 
task TSK_GET_OUT_CRC;
		begin
			if(crcCnt < 10)begin
				crc8   <= crc8+crcReg[79:72];
				crcCnt <= crcCnt+1'b1; 
				crcReg <= crcReg << 8;
			end				
		end
endtask   
 
task TSK_DISABLE_OUTS;  
	begin
		//TRANSIT  <= 0; //in transit version
		EN_OUT   <= 0;	
		LINK_OK  <= 0;		
	end
endtask  

task TSK_DATA_DIRECTION_CONTROL;
	begin 
		if(inReg[7:0] == startByte)begin
			EN_OUT <= 1;
			crcCnt <= 0;
			crc8   <= 8'hA5;
			crcReg <= {8'h00, W_OUT_REG_[71:0]};
		end
	end 
endtask
 
task TSK_PREP_CRC_COUNTER;
	begin
		crcCnt <= 0;
		crc8   <= 8'hA5;
		crcReg <= inReg[79:0]; 	
	end
endtask 

task TSK_CHECK_CRC;
	begin
		if(crc8 == crcIn)begin
			LINK_OK  <= 1;		
			IN_REG_1 <= inReg[39: 8];
			IN_REG_2 <= inReg[71:40];
			CMD_IN   <= inReg[79:72];
		end 	
	end
endtask  
 
always@(posedge MAIN_CLK)begin
    TSK_CLK_CONTROL;
    TSK_PUSH_PULL_DATA;
    TSK_GET_OUT_CRC;

	if(bitCnt == 7'd00)TSK_DISABLE_OUTS;
	if(bitCnt == 7'd07)TSK_DATA_DIRECTION_CONTROL;
	if(bitCnt == 7'd79)if(!EN_OUT)TSK_PREP_CRC_COUNTER;
	if(bitCnt == 7'd88)if(!EN_OUT)TSK_CHECK_CRC;	
end 

//------------------------------------  

endmodule	
	
	
	