// ------------- RAM -------------
output [17:0]A_RAM_3;
inout  [7 :0]D_RAM_3;
output [17:0]A_RAM_4;
inout  [7 :0]D_RAM_4;
output [17:0]A_RAM_7;
inout  [7 :0]D_RAM_7;
output CE_RAM_3, CE_RAM_4, CE_RAM_7;
output WE_RAM_3, WE_RAM_4, WE_RAM_7;
reg ce_ram, we_ram;
reg [17:0]a_ram;
reg [23:0]d_ram;

assign A_RAM_3 = a_ram;
assign A_RAM_4 = a_ram;
assign A_RAM_7 = a_ram;

assign CE_RAM_3 = ce_ram;
assign CE_RAM_4 = ce_ram;
assign CE_RAM_7 = ce_ram;

assign WE_RAM_3 = we_ram;
assign WE_RAM_4 = we_ram;
assign WE_RAM_7 = we_ram;

assign D_RAM_3  = dir_data ? d_ram[7 : 0] : 8'hZZ;
assign D_RAM_4  = dir_data ? d_ram[15: 8] : 8'hZZ;
assign D_RAM_7  = dir_data ? d_ram[23:16] : 8'hZZ;
//---------------------------------


//---------- FIFO ------------------
inout      [7 :0] FIFO_DQ8;          
input	   [15:0] FIFO_Q8_24;        
input      [7 :0] FIFO_Q8;              
output reg FIFO_W24, FIFO_W8,          
		   FIFO_R24, FIFO_R8, 
		   FIFO_MR24, FIFO_MR8;
input	   FIFO_EF24, FIFO_EF8;	
reg [7:0]dq8;
reg dir_data;
reg dir_fifo8;

assign FIFO_DQ8 = dir_fifo8 ? dq8[7:0] : 8'hZZ; 
//---------------------------------

//----------SP 64------------------
input  MAIN_CLK;
output TEST_OUT;
input  S_CLK_BRD;    
inout  S_DATA_BRD;
   
reg [31:0]data_out_1, data_out_2;  
reg [7 :0]cmd_out;
wire[7 :0]cmd_in;
wire[31:0]data_in_1 , data_in_2;
wire linkOk;
wire en_out;
//----------------------------------

// -----------Main automat-----------
reg[7:0]aut;
reg[3:0]aut_sq;
reg stop_aut;
reg [1:0]old_pack;
reg [5:0]cmd;
wire[1:0]new_pack;

assign new_pack = cmd_in[7:6];
assign TEST_OUT   = linkOk; //data_out_1[29]; //
//----------------------------------

// ------ internal RAM -------------
reg ram_inclock;
reg	ram_we;
reg[10:0]ram_address;
reg[7 :0]ram_data;
wire[7:0]ram_q;	
//----------------------------------



