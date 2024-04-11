`define CHK_NEW_PACK    if(old_pack != new_pack)begin  			\
									old_pack <= new_pack;       \
									aut      <= 0;              \
									cmd      <= cmd_in[5:0];    \
									end
			
`define DEV_ID 4'h1
`define PAUSE  8'd60

			
`define CMD_WR_RAM         6'h01	
`define CMD_RD_RAM         6'h02	
`define CMD_RD_FIFO_Q8     6'h03
`define CMD_RD_FIFO_Q24    6'h04
`define CMD_WR_FIFO_D8     6'h05
`define CMD_WR_FIFO_D24    6'h06
`define CMD_RESET_FIFO_8   6'h07
`define CMD_RESET_FIFO_24  6'h08
`define CMD_SET_DIR        6'h09
`define CMD_RESET_DIR      6'h0A
`define CMD_SET_FIFO_DIR   6'h0B
`define CMD_RESET_FIFO_DIR 6'h0C
`define CMD_FILL_RAM_PATT1 6'h0D 
`define CMD_FILL_RAM_PATT2 6'h0E 

`define CMD_WR_IN_RAM      6'h0F 
`define CMD_RD_IN_RAM      6'h10 




