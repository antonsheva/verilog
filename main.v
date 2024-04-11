`timescale 1ns / 1ps

module main(MAIN_CLK, TEST_OUT,
			S_CLK_BRD, S_DATA_BRD,			
			A_RAM_3, D_RAM_3,
			A_RAM_4, D_RAM_4,
			A_RAM_7, D_RAM_7,
			CE_RAM_3, CE_RAM_4, CE_RAM_7,
			WE_RAM_3, WE_RAM_4, WE_RAM_7,
			
			FIFO_Q8_24, FIFO_Q8, FIFO_DQ8,
			FIFO_W24, FIFO_W8, 
			FIFO_R24, FIFO_R8, 
			FIFO_MR24, FIFO_MR8,
			FIFO_EF24, FIFO_EF8			
			);
			
`include "vars.v"
`include "initials.v"
`include "tasks.v"
`include "defines.v"	

A_sp_slave #(`DEV_ID, `PAUSE) sp(
          MAIN_CLK, 
		  linkOk,
		  en_out,
		  S_CLK_BRD,
		  S_DATA_BRD,
		  data_in_1, data_in_2,
		  cmd_in,
		  data_out_1, data_out_2,
		  cmd_out
		 );

ram r(	ram_address,
		ram_data,
		ram_inclock,
		ram_we,
		ram_q);		

always@(posedge MAIN_CLK)begin
	`CHK_NEW_PACK
	TSK_STATE;	
    if(aut < 8'd254) begin
		if(!stop_aut)aut<=aut+1'b1;
		case(cmd)				
			`CMD_WR_RAM: TSK_WR_RAM;			
			`CMD_RD_RAM: TSK_RD_RAM;
			
			`CMD_RD_FIFO_Q8 : TSK_RD_FIFO_Q8 ;  
			`CMD_RD_FIFO_Q24: TSK_RD_FIFO_Q24;  
			`CMD_WR_FIFO_D8 : TSK_WR_FIFO_D8 ;   
			`CMD_WR_FIFO_D24: TSK_WR_FIFO_D24;   
			
			`CMD_RESET_FIFO_8 : TSK_RESET_FIFO_8 ;
			`CMD_RESET_FIFO_24: TSK_RESET_FIFO_24;
			
			`CMD_SET_DIR  : TSK_SET_DATA_DIR(1'b1);
			`CMD_RESET_DIR: TSK_SET_DATA_DIR(1'b0);
 
			`CMD_SET_FIFO_DIR : TSK_SET_FIFO_DIR(1'b1);
			`CMD_RESET_FIFO_DIR : TSK_SET_FIFO_DIR(1'b0); 
			
			`CMD_FILL_RAM_PATT1 : TSK_LOAD_RAM(1'b0);
			`CMD_FILL_RAM_PATT2 : TSK_LOAD_RAM(1'b1);
			
			`CMD_WR_IN_RAM : TSK_WR_IN_RAM;
			`CMD_RD_IN_RAM : TSK_RD_IN_RAM;
		endcase	
	end 
	if(aut == 253)cmd_out<=cmd;
    if(aut == 254)TSK_FINISH;	 
end

endmodule