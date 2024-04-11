task TSK_SET_CE;
    begin
		ce_ram <= 1'b0;
	end            
endtask

task TSK_SET_DATA_DIR(input dir);
	dir_data <= dir;
endtask

task TSK_SET_FIFO_DIR(input dir);
    case(aut)
		1 : dir_fifo8 <= dir;
		2 : aut       <= 8'd250;
	endcase	 
endtask

task TSK_SET_WE;   
	we_ram <= 1'b0;
endtask

task TSK_RESET_CE;
	ce_ram <= 1'b1;
endtask

task TSK_RESET_WE;
    
	we_ram <= 1'b1;
endtask

task TSK_SET_ADDR;
	a_ram[17:0] <= data_in_1[17:0];
endtask
task TSK_SET_DATA;
	d_ram[23:0] <= data_in_2[23:0];
endtask

task TSK_COPY_RECEIVE_DATA;
	data_out_1[31:0] <= {14'h00,data_in_1[17:0]};
	data_out_2[31:0] <= {8'h00 ,data_in_2[23:0]};
endtask

task TSK_GET_RAM_DATA(input wordNum);
    if(!wordNum)begin
		data_out_1[7 : 0] <= D_RAM_3[7:0];
		data_out_1[15: 8] <= D_RAM_4[7:0];
		data_out_1[23:16] <= D_RAM_7[7:0];	
	end else begin
		data_out_2[7 : 0] <= D_RAM_3[7:0];
		data_out_2[15: 8] <= D_RAM_4[7:0];
		data_out_2[23:16] <= D_RAM_7[7:0];		
	end
endtask

task TSK_WR_RAM;
	case(aut)
		1 : begin 	TSK_SET_ADDR; 
					TSK_SET_DATA; 
					TSK_SET_DATA_DIR(1'b1); end
		4 : TSK_SET_CE;
		5 : TSK_SET_WE;
		10: TSK_RESET_WE;
		11: TSK_RESET_CE;
        12: TSK_SET_DATA_DIR(0);		
	endcase
endtask

task TSK_RD_RAM;
	case(aut)
		1 : TSK_SET_ADDR;
		2 : TSK_SET_CE;
		4 : TSK_GET_RAM_DATA(1'b0);
		5 : TSK_RESET_CE;
		6 : a_ram <= a_ram+1'b1;
		7 : TSK_SET_CE;
		9 : TSK_GET_RAM_DATA(1'b1);
		10: TSK_RESET_CE;
	endcase
endtask

task TSK_FINISH;
	 	ce_ram       <= 1'b1;
	 	we_ram       <= 1'b1;
		ram_we       <= 1'b0;		
		
		FIFO_W24     <= 1'b1;  
		FIFO_W8      <= 1'b1; 
		FIFO_R24     <= 1'b1;   
		FIFO_R8      <= 1'b1;  
		FIFO_MR24    <= 1'b1;  
		FIFO_MR8     <= 1'b1;   
		
        stop_aut     <= 1'b0;	
        aut_sq       <= 4'd0;	
       
endtask

task TSK_STATE;
	data_out_1[31] <= FIFO_EF24;
	data_out_1[30] <= FIFO_EF8;
    cmd_out        <= cmd_in;	
endtask	

task TSK_RD_FIFO_Q8;
	case(aut)
	    1  : FIFO_R8         <= 1'b0; 
		100: data_out_1[7:0] <= FIFO_Q8[7:0];
	    110: FIFO_R8         <= 1'b1;		
		120: aut             <= 8'd250;
	endcase
endtask

task TSK_RD_FIFO_Q24;
	case(aut)
	    1 : FIFO_R24         <= 1'b0; 
		9 : data_out_1[7 :0] <= FIFO_DQ8  [7 :0];
		10: data_out_1[23:8] <= FIFO_Q8_24[15:0];
		11: FIFO_R24         <= 1'b1;				
	endcase
endtask

task TSK_WR_FIFO_D8;
	case(aut)	    
		1 : begin dir_fifo8 <= 1'b1; dq8[7:0] <= data_in_1[7:0]; end 
		80 : FIFO_W8   <= 1'b0;
		120: FIFO_W8   <= 1'b1; 		
		130: dir_fifo8 <= 1'b0;
		140: aut       <= 8'd250;
	endcase
endtask

task TSK_WR_FIFO_D24;
	case(aut)
		10: FIFO_W24 <= 1'b0;
		11: FIFO_W24 <= 1'b1;
	 	12: aut      <= 8'd250;
	endcase
endtask

task TSK_RESET_FIFO_8;
	case(aut)
		1  : FIFO_MR8 <= 1'b0;
		100: FIFO_MR8 <= 1'b1;
		120: aut      <= 8'd250;	
	endcase	
endtask

task TSK_RESET_FIFO_24;
	case(aut)
		1 : FIFO_MR24 <= 1'b0;
		11: FIFO_MR24 <= 1'b1;
		12: aut       <= 8'd250;
	endcase	
endtask

task TSK_LOAD_RAM(input patt);
	case(aut)
		1 : begin 
				dir_data       <= 1'b1;
				we_ram         <= 1'b0;
				aut_sq         <= 4'd0;
				a_ram          <= 18'h00000;
				data_out_1[29] <= 1'b1;end
		3 : begin
				stop_aut <= 1'b1;
				aut      <= 4'd4;end
	    4 : TSK_FILL_RAM (patt);
		5 : TSK_FINISH; 
		
		7 :	aut       <= 8'd250;	
	endcase	
endtask

task TSK_FILL_RAM(input patt);
	aut_sq<=aut_sq+1'b1; 
	case(aut_sq)			
		1 : begin d_ram[23:16] <=a_ram[7:0];
				  d_ram[15: 8] <=a_ram[7:0];
				  d_ram[7 : 0] <=a_ram[7:0];end
		3 : if(patt)d_ram <= ~d_ram;		 
		5 : ce_ram <= 1'b0;
		7 : ce_ram <= 1'b1; 
	    8 : if(a_ram == 18'h3FFFF)begin
				data_out_1[29] <= 1'b0;
                aut            <= 4'd5;
				dir_data       <= 1'b0;				
				we_ram         <= 1'b1;end	 
		10: a_ram  <= a_ram+1'b1;
		11: aut_sq <= 4'd0;
		15:	aut    <= 8'd250;
	endcase
endtask
 
task TSK_WR_IN_RAM;
	case(aut)
		1:  begin ram_address[10:0]<=data_in_1[10: 0];
				  ram_data   [7 :0]<=data_in_1[23:16];
				  ram_we           <= 1;             	end		 
		3 : ram_inclock <= 1'b1;
		5 : ram_inclock <= 1'b0;
		
		10: begin ram_address   <=ram_address+1'b1;
				  ram_data[7 :0]<=data_in_1[31:24];	 	end	  
		13: ram_inclock <= 1'b1;
		15: ram_inclock <= 1'b0;

		20: begin ram_address   <=ram_address+1'b1;
				  ram_data[7 :0]<=data_in_2[7 : 0];	  	end	 
		23: ram_inclock <= 1'b1;
		25: ram_inclock <= 1'b0;

		30: begin ram_address   <=ram_address+1'b1;
				  ram_data[7 :0]<=data_in_2[15: 8];	 	end	  
		33: ram_inclock <= 1'b1;
		35: ram_inclock <= 1'b0;
		
		40: begin ram_address   <=ram_address+1'b1;
				  ram_data[7 :0]<=data_in_2[23:16];	 	end	  
		43: ram_inclock <= 1'b1;
		45: ram_inclock <= 1'b0;

		50: begin ram_address   <=ram_address+1'b1;
				  ram_data[7 :0]<=data_in_2[31:24];	 	end	  
		53: ram_inclock <= 1'b1;
		55: ram_inclock <= 1'b0;		

		60: ram_we <= 1'b0;
		65: aut    <= 8'd250;
	endcase
endtask

task TSK_RD_IN_RAM;
	case(aut)
		1 : ram_address[10:0]<=data_in_1[10: 0];
		3 : ram_inclock <= 1'b1; 
		5 : ram_inclock <= 1'b0;
		7 :	data_out_1[7:0]  <=ram_q[7:0];	 
		
		10 : ram_address<=ram_address+1'b1;
		13 : ram_inclock <= 1'b1; 
		15 : ram_inclock <= 1'b0;
		17 :	data_out_1[15:8]  <=ram_q[7:0]; 
		
		20: ram_address<=ram_address+1'b1;
		23: ram_inclock <= 1'b1; 
		25: ram_inclock <= 1'b0;
		27:	data_out_1[24:16]  <=ram_q[7:0];	
		
		30 : ram_address<=ram_address+1'b1;
		33 : ram_inclock <= 1'b1; 
		35 : ram_inclock <= 1'b0;
		37 : data_out_1[31:24]  <=ram_q[7:0];		
		
		40 : ram_address<=ram_address+1'b1;
		43 : ram_inclock <= 1'b1; 
		45 : ram_inclock <= 1'b0;
		47 : data_out_1[7:0]  <=ram_q[7:0]; 
		
		50 : ram_address<=ram_address+1'b1;
		53 : ram_inclock <= 1'b1; 
		55 : ram_inclock <= 1'b0;
		57 : data_out_2[15:8]  <=ram_q[7:0];	
		
		60 : ram_address<=ram_address+1'b1;
		63 : ram_inclock <= 1'b1; 
		65 : ram_inclock <= 1'b0;
		67 : data_out_2[23:16]  <=ram_q[7:0];			
		
		70 : ram_address<=ram_address+1'b1;
		73 : ram_inclock <= 1'b1; 
		75 : ram_inclock <= 1'b0;
		77 : data_out_2[31:24]  <=ram_q[7:0];	 

		80: aut <= 8'd250;		
	endcase

endtask



